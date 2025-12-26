#!/bin/bash
# Centralized token usage tracking for devloop
# Stores statistics in ~/.claude/devloop-stats/
#
# Usage:
#   ./token-tracker.sh start <type> <name> [project]  - Start tracking an invocation
#   ./token-tracker.sh end <invocation_id>            - End tracking, record delta
#   ./token-tracker.sh log <type> <name> <tokens> [project]  - Direct log entry
#   ./token-tracker.sh stats [project]                - Show usage statistics
#   ./token-tracker.sh report [days]                  - Generate usage report
#   ./token-tracker.sh top [n]                        - Top n token consumers
#
# Types: agent, skill, command, session
# Stored in: ~/.claude/devloop-stats/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATS_DIR="$HOME/.claude/devloop-stats"
USAGE_LOG="$STATS_DIR/usage-log.jsonl"
ACTIVE_DIR="$STATS_DIR/active"
SUMMARY_FILE="$STATS_DIR/summary.json"

# Ensure directories exist
init_dirs() {
    mkdir -p "$STATS_DIR" "$ACTIVE_DIR"

    # Initialize summary if needed
    if [ ! -f "$SUMMARY_FILE" ]; then
        cat > "$SUMMARY_FILE" <<EOF
{
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "total_invocations": 0,
  "total_tokens": 0,
  "by_type": {},
  "by_project": {},
  "by_agent": {}
}
EOF
    fi
}

# Get current API usage snapshot
get_usage_snapshot() {
    local usage
    usage=$("$SCRIPT_DIR/fetch-api-usage.sh" --no-cache 2>/dev/null) || echo '{}'

    if command -v jq &> /dev/null; then
        local five_hour seven_day
        five_hour=$(echo "$usage" | jq -r '.five_hour_pct // 0' 2>/dev/null)
        seven_day=$(echo "$usage" | jq -r '.seven_day_pct // 0' 2>/dev/null)
        echo "${five_hour:-0}:${seven_day:-0}"
    else
        echo "0:0"
    fi
}

# Get current context/token info from Claude Code (if available)
get_token_snapshot() {
    # This would ideally come from Claude Code's context
    # For now, return placeholder - will be populated by hooks
    echo "0"
}

# Start tracking an invocation
cmd_start() {
    local type="${1:-unknown}"
    local name="${2:-unknown}"
    local project="${3:-$(basename "$(pwd)")}"

    init_dirs

    # Generate invocation ID
    local inv_id="inv_$(date +%s)_$$"

    # Get usage snapshot
    local usage_snap
    usage_snap=$(get_usage_snapshot)
    local five_hour_start seven_day_start
    five_hour_start=$(echo "$usage_snap" | cut -d: -f1)
    seven_day_start=$(echo "$usage_snap" | cut -d: -f2)

    # Create active tracking file
    cat > "$ACTIVE_DIR/$inv_id.json" <<EOF
{
  "invocation_id": "$inv_id",
  "type": "$type",
  "name": "$name",
  "project": "$project",
  "session_id": "${CLAUDE_SESSION_ID:-unknown}",
  "start_time": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "start_5hr_pct": $five_hour_start,
  "start_7day_pct": $seven_day_start
}
EOF

    # Return the invocation ID
    echo "$inv_id"
}

# End tracking and record results
cmd_end() {
    local inv_id="${1:-}"
    local tokens_used="${2:-0}"

    if [ -z "$inv_id" ]; then
        echo "Error: invocation_id required" >&2
        return 1
    fi

    local active_file="$ACTIVE_DIR/$inv_id.json"
    if [ ! -f "$active_file" ]; then
        echo "Error: No active invocation found: $inv_id" >&2
        return 1
    fi

    init_dirs

    # Read start data
    local start_data
    start_data=$(cat "$active_file")

    # Get end usage snapshot
    local usage_snap
    usage_snap=$(get_usage_snapshot)
    local five_hour_end seven_day_end
    five_hour_end=$(echo "$usage_snap" | cut -d: -f1)
    seven_day_end=$(echo "$usage_snap" | cut -d: -f2)

    if command -v jq &> /dev/null; then
        # Extract start values
        local type name project start_time
        local five_hour_start seven_day_start
        type=$(echo "$start_data" | jq -r '.type')
        name=$(echo "$start_data" | jq -r '.name')
        project=$(echo "$start_data" | jq -r '.project')
        start_time=$(echo "$start_data" | jq -r '.start_time')
        five_hour_start=$(echo "$start_data" | jq -r '.start_5hr_pct')
        seven_day_start=$(echo "$start_data" | jq -r '.start_7day_pct')
        session_id=$(echo "$start_data" | jq -r '.session_id')

        # Calculate deltas
        local five_hour_delta=$((five_hour_end - five_hour_start))
        local seven_day_delta=$((seven_day_end - seven_day_start))

        # Create log entry
        local log_entry
        log_entry=$(cat <<EOF
{"timestamp":"$(date -u +"%Y-%m-%dT%H:%M:%SZ")","invocation_id":"$inv_id","type":"$type","name":"$name","project":"$project","session_id":"$session_id","start_time":"$start_time","end_time":"$(date -u +"%Y-%m-%dT%H:%M:%SZ")","tokens_used":$tokens_used,"5hr_delta":$five_hour_delta,"7day_delta":$seven_day_delta,"5hr_end":$five_hour_end,"7day_end":$seven_day_end}
EOF
)

        # Append to log
        echo "$log_entry" >> "$USAGE_LOG"

        # Update summary
        update_summary "$type" "$name" "$project" "$tokens_used" "$five_hour_delta" "$seven_day_delta"

        # Clean up active file
        rm -f "$active_file"

        # Output result
        echo "Tracked: $type/$name - tokens: $tokens_used, 5hr: +${five_hour_delta}%, 7day: +${seven_day_delta}%"
    else
        # Fallback without jq
        echo "{\"type\":\"$type\",\"name\":\"$name\",\"tokens\":$tokens_used}" >> "$USAGE_LOG"
        rm -f "$active_file"
        echo "Tracked (basic): tokens=$tokens_used"
    fi
}

# Direct log entry (for simpler tracking)
cmd_log() {
    local type="${1:-unknown}"
    local name="${2:-unknown}"
    local tokens="${3:-0}"
    local project="${4:-$(basename "$(pwd)")}"

    init_dirs

    # Get current usage
    local usage_snap
    usage_snap=$(get_usage_snapshot)
    local five_hour seven_day
    five_hour=$(echo "$usage_snap" | cut -d: -f1)
    seven_day=$(echo "$usage_snap" | cut -d: -f2)

    # Create log entry
    local log_entry
    log_entry=$(cat <<EOF
{"timestamp":"$(date -u +"%Y-%m-%dT%H:%M:%SZ")","type":"$type","name":"$name","project":"$project","session_id":"${CLAUDE_SESSION_ID:-unknown}","tokens_used":$tokens,"5hr_pct":$five_hour,"7day_pct":$seven_day}
EOF
)

    echo "$log_entry" >> "$USAGE_LOG"

    # Update summary
    update_summary "$type" "$name" "$project" "$tokens" "0" "0"

    echo "Logged: $type/$name - $tokens tokens"
}

# Update summary statistics
update_summary() {
    local type="$1"
    local name="$2"
    local project="$3"
    local tokens="$4"
    local five_hr_delta="$5"
    local seven_day_delta="$6"

    if ! command -v jq &> /dev/null; then
        return
    fi

    # Update summary atomically
    local updated
    local now_ts
    now_ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    updated=$(jq \
        --arg type "$type" \
        --arg name "$name" \
        --arg project "$project" \
        --argjson tokens "$tokens" \
        --arg now "$now_ts" \
        '
        .total_invocations += 1 |
        .total_tokens += $tokens |
        .last_updated = $now |

        # Update by_type
        .by_type[$type] = (.by_type[$type] // {count: 0, tokens: 0}) |
        .by_type[$type].count += 1 |
        .by_type[$type].tokens += $tokens |

        # Update by_project
        .by_project[$project] = (.by_project[$project] // {count: 0, tokens: 0}) |
        .by_project[$project].count += 1 |
        .by_project[$project].tokens += $tokens |

        # Update by_agent (for agent type)
        if $type == "agent" then
            .by_agent[$name] = (.by_agent[$name] // {count: 0, tokens: 0}) |
            .by_agent[$name].count += 1 |
            .by_agent[$name].tokens += $tokens
        else . end
        ' "$SUMMARY_FILE" 2>/dev/null) || return

    echo "$updated" > "$SUMMARY_FILE"
}

# Show statistics
cmd_stats() {
    local project="${1:-}"

    init_dirs

    if [ ! -f "$SUMMARY_FILE" ]; then
        echo "No statistics recorded yet"
        return
    fi

    if ! command -v jq &> /dev/null; then
        echo "Install jq for detailed statistics"
        cat "$SUMMARY_FILE"
        return
    fi

    echo "=== Devloop Token Usage Statistics ==="
    echo ""

    # Overall stats
    local total_inv total_tokens
    total_inv=$(jq '.total_invocations' "$SUMMARY_FILE")
    total_tokens=$(jq '.total_tokens' "$SUMMARY_FILE")

    echo "Total invocations: $total_inv"
    echo "Total tokens used: $total_tokens"
    echo ""

    # By type
    echo "By Type:"
    jq -r '.by_type | to_entries | sort_by(-.value.tokens) | .[] | "  \(.key): \(.value.count) calls, \(.value.tokens) tokens"' "$SUMMARY_FILE"
    echo ""

    # By agent (if any)
    local agent_count
    agent_count=$(jq '.by_agent | length' "$SUMMARY_FILE")
    if [ "$agent_count" -gt 0 ]; then
        echo "By Agent:"
        jq -r '.by_agent | to_entries | sort_by(-.value.tokens) | .[] | "  \(.key): \(.value.count) calls, \(.value.tokens) tokens"' "$SUMMARY_FILE"
        echo ""
    fi

    # By project
    echo "By Project:"
    jq -r '.by_project | to_entries | sort_by(-.value.tokens) | .[] | "  \(.key): \(.value.count) calls, \(.value.tokens) tokens"' "$SUMMARY_FILE"

    # If specific project requested
    if [ -n "$project" ]; then
        echo ""
        echo "=== Project: $project ==="
        jq --arg p "$project" '.by_project[$p] // {count: 0, tokens: 0}' "$SUMMARY_FILE"
    fi
}

# Generate detailed report
cmd_report() {
    local days="${1:-7}"

    init_dirs

    if [ ! -f "$USAGE_LOG" ]; then
        echo "No usage log found"
        return
    fi

    if ! command -v jq &> /dev/null; then
        echo "Install jq for detailed reports"
        tail -20 "$USAGE_LOG"
        return
    fi

    local cutoff
    cutoff=$(date -u -d "$days days ago" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v-${days}d +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "2000-01-01")

    echo "=== Token Usage Report (Last $days days) ==="
    echo ""

    # Daily breakdown
    echo "Daily Usage:"
    jq -rs --arg cutoff "$cutoff" '
        [.[] | select(.timestamp >= $cutoff)] |
        group_by(.timestamp | split("T")[0]) |
        .[] |
        {
            date: .[0].timestamp | split("T")[0],
            invocations: length,
            tokens: [.[].tokens_used] | add
        }
    ' "$USAGE_LOG" 2>/dev/null | jq -r '.date + ": " + (.invocations|tostring) + " invocations, " + (.tokens|tostring) + " tokens"' || echo "  (no data)"

    echo ""

    # Top consumers
    echo "Top Token Consumers:"
    jq -rs --arg cutoff "$cutoff" '
        [.[] | select(.timestamp >= $cutoff)] |
        group_by(.name) |
        map({name: .[0].name, type: .[0].type, count: length, tokens: [.[].tokens_used] | add}) |
        sort_by(-.tokens) |
        .[:10]
    ' "$USAGE_LOG" 2>/dev/null | jq -r '.[] | "  \(.type)/\(.name): \(.count) calls, \(.tokens) tokens"' || echo "  (no data)"

    echo ""

    # Recent high-usage invocations
    echo "Recent High-Usage Invocations:"
    jq -rs '
        sort_by(-.tokens_used) |
        .[:5] |
        .[] |
        "\(.timestamp | split("T")[0]) \(.type)/\(.name) (\(.project)): \(.tokens_used) tokens"
    ' "$USAGE_LOG" 2>/dev/null || echo "  (no data)"
}

# Show top N token consumers
cmd_top() {
    local n="${1:-10}"

    init_dirs

    if [ ! -f "$USAGE_LOG" ]; then
        echo "No usage log found"
        return
    fi

    if ! command -v jq &> /dev/null; then
        echo "Install jq for top consumers"
        return
    fi

    echo "=== Top $n Token Consumers ==="
    echo ""

    # Group by name and sum tokens
    jq -rs --argjson n "$n" '
        group_by(.name) |
        map({
            name: .[0].name,
            type: .[0].type,
            count: length,
            total_tokens: ([.[].tokens_used] | add),
            avg_tokens: (([.[].tokens_used] | add) / length | floor),
            projects: ([.[].project] | unique)
        }) |
        sort_by(-.total_tokens) |
        .[:$n]
    ' "$USAGE_LOG" 2>/dev/null | jq -r '.[] | "\(.type)/\(.name):\n  Total: \(.total_tokens) tokens (\(.count) calls, avg \(.avg_tokens))\n  Projects: \(.projects | join(", "))\n"'
}

# Show recent invocations
cmd_recent() {
    local n="${1:-20}"

    init_dirs

    if [ ! -f "$USAGE_LOG" ]; then
        echo "No usage log found"
        return
    fi

    echo "=== Recent $n Invocations ==="
    tail -n "$n" "$USAGE_LOG" | while read -r line; do
        if command -v jq &> /dev/null; then
            echo "$line" | jq -r '"\(.timestamp | split("T") | .[0] + " " + (.[1] | split(".")[0])) | \(.type)/\(.name) | \(.tokens_used) tokens | 5hr:\(.["5hr_delta"] // 0)% 7day:\(.["7day_delta"] // 0)%"' 2>/dev/null || echo "$line"
        else
            echo "$line"
        fi
    done
}

# Export data for analysis
cmd_export() {
    local format="${1:-json}"

    init_dirs

    case "$format" in
        json)
            cat "$USAGE_LOG"
            ;;
        csv)
            echo "timestamp,type,name,project,tokens_used,5hr_delta,7day_delta"
            jq -rs '.[] | [.timestamp, .type, .name, .project, .tokens_used, .["5hr_delta"] // 0, .["7day_delta"] // 0] | @csv' "$USAGE_LOG" 2>/dev/null
            ;;
        *)
            echo "Formats: json, csv"
            ;;
    esac
}

# Main command router
case "${1:-stats}" in
    start)   cmd_start "${2:-}" "${3:-}" "${4:-}" ;;
    end)     cmd_end "${2:-}" "${3:-}" ;;
    log)     cmd_log "${2:-}" "${3:-}" "${4:-}" "${5:-}" ;;
    stats)   cmd_stats "${2:-}" ;;
    report)  cmd_report "${2:-7}" ;;
    top)     cmd_top "${2:-10}" ;;
    recent)  cmd_recent "${2:-20}" ;;
    export)  cmd_export "${2:-json}" ;;
    *)
        echo "Usage: $0 {start|end|log|stats|report|top|recent|export}"
        echo ""
        echo "Commands:"
        echo "  start <type> <name> [project]  - Start tracking invocation"
        echo "  end <invocation_id> [tokens]   - End tracking, record results"
        echo "  log <type> <name> <tokens>     - Direct log entry"
        echo "  stats [project]                - Show statistics"
        echo "  report [days]                  - Generate usage report"
        echo "  top [n]                        - Top n token consumers"
        echo "  recent [n]                     - Recent n invocations"
        echo "  export [json|csv]              - Export raw data"
        exit 1
        ;;
esac
