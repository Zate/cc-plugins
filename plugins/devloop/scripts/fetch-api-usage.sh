#!/bin/bash
# Fetch API usage from Anthropic OAuth endpoint
# Cross-platform with caching
#
# Usage: ./fetch-api-usage.sh [--no-cache]
# Output: JSON with usage stats or error
#
# Cache: /tmp/claude-usage-cache.json (60 second TTL)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_MAX_AGE=60  # seconds

# Parse args
NO_CACHE=false
if [ "${1:-}" = "--no-cache" ]; then
    NO_CACHE=true
fi

# Check cache
check_cache() {
    if [ "$NO_CACHE" = true ]; then
        return 1
    fi

    if [ ! -f "$CACHE_FILE" ]; then
        return 1
    fi

    local cache_age
    local file_mtime

    # Platform-specific file modification time
    case "$(uname -s)" in
        Darwin)
            file_mtime=$(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
            ;;
        Linux)
            file_mtime=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
            ;;
        *)
            return 1
            ;;
    esac

    local now
    now=$(date +%s)
    cache_age=$((now - file_mtime))

    if [ "$cache_age" -lt "$CACHE_MAX_AGE" ]; then
        cat "$CACHE_FILE"
        return 0
    fi

    return 1
}

# Fetch fresh usage from API
fetch_usage() {
    local token
    token=$("$SCRIPT_DIR/get-oauth-token.sh" 2>/dev/null) || {
        echo '{"error": "Could not get OAuth token"}' >&2
        return 1
    }

    if [ -z "$token" ]; then
        echo '{"error": "Empty OAuth token"}' >&2
        return 1
    fi

    local response
    response=$(curl -s \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        -H "User-Agent: claude-code/devloop" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null) || {
        echo '{"error": "API request failed"}' >&2
        return 1
    }

    # Validate response has expected structure
    if echo "$response" | grep -q '"five_hour"' 2>/dev/null; then
        echo "$response" > "$CACHE_FILE"
        echo "$response"
        return 0
    else
        echo '{"error": "Invalid API response", "raw": "'"$response"'"}' >&2
        return 1
    fi
}

# Parse usage into simple format
parse_usage() {
    local json="$1"

    if command -v jq &> /dev/null; then
        local five_hour seven_day opus

        five_hour=$(echo "$json" | jq -r '.five_hour.utilization // 0' 2>/dev/null | cut -d. -f1)
        seven_day=$(echo "$json" | jq -r '.seven_day.utilization // 0' 2>/dev/null | cut -d. -f1)
        opus=$(echo "$json" | jq -r '.seven_day_opus.utilization // 0' 2>/dev/null | cut -d. -f1)

        cat <<EOF
{
  "five_hour_pct": ${five_hour:-0},
  "seven_day_pct": ${seven_day:-0},
  "opus_pct": ${opus:-0},
  "raw": $json
}
EOF
    else
        # Fallback without jq - just return raw
        echo "$json"
    fi
}

# Main execution
main() {
    local usage

    # Try cache first
    if usage=$(check_cache 2>/dev/null); then
        parse_usage "$usage"
        return 0
    fi

    # Fetch fresh
    if usage=$(fetch_usage 2>/dev/null); then
        parse_usage "$usage"
        return 0
    fi

    # Return error JSON
    echo '{"error": "Could not fetch API usage"}'
    return 1
}

main "$@"
