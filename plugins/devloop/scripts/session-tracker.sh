#!/bin/bash
# Session tracking for devloop
# Tracks context usage and API limits across sessions
#
# Usage:
#   ./session-tracker.sh start [session_id]  - Record session start
#   ./session-tracker.sh end [session_id]    - Record session end
#   ./session-tracker.sh status              - Show current session status
#   ./session-tracker.sh history [n]         - Show last n sessions
#   ./session-tracker.sh suggest             - Suggest if clear is needed
#
# Data stored in: .devloop/sessions.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSIONS_FILE=".devloop/sessions.json"
CURRENT_SESSION_FILE=".devloop/.current-session.json"

# Ensure .devloop directory exists
ensure_devloop_dir() {
    mkdir -p .devloop
}

# Initialize sessions file if needed
init_sessions_file() {
    if [ ! -f "$SESSIONS_FILE" ]; then
        cat > "$SESSIONS_FILE" <<EOF
{
  "sessions": [],
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    fi
}

# Read context from stdin (if provided by Claude Code)
read_context_from_stdin() {
    local input=""

    # Check if stdin has data (non-blocking)
    if read -t 0.1 -r line 2>/dev/null; then
        input="$line"
        while IFS= read -r -t 0.1 line 2>/dev/null; do
            input="$input$line"
        done
    fi

    echo "$input"
}

# Parse context window info from JSON input
parse_context_info() {
    local input="$1"

    if [ -z "$input" ]; then
        echo '{"context_pct": 0, "tokens_used": 0}'
        return
    fi

    if command -v jq &> /dev/null; then
        local current_usage size input_tokens output_tokens pct total_tokens

        # Get context window usage
        current_usage=$(echo "$input" | jq -r '.context_window.current_usage // {}' 2>/dev/null)
        size=$(echo "$input" | jq -r '.context_window.context_window_size // 0' 2>/dev/null)

        if [ -n "$current_usage" ] && [ "$current_usage" != "{}" ] && [ "$size" != "0" ]; then
            local input_t cache_create cache_read
            input_t=$(echo "$current_usage" | jq -r '.input_tokens // 0' 2>/dev/null)
            cache_create=$(echo "$current_usage" | jq -r '.cache_creation_input_tokens // 0' 2>/dev/null)
            cache_read=$(echo "$current_usage" | jq -r '.cache_read_input_tokens // 0' 2>/dev/null)

            local current=$((input_t + cache_create + cache_read))
            pct=$((current * 100 / size))
        else
            pct=0
        fi

        # Get total tokens
        input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0' 2>/dev/null)
        output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0' 2>/dev/null)
        total_tokens=$((input_tokens + output_tokens))

        # Get model
        local model
        model=$(echo "$input" | jq -r '.model.display_name // "unknown"' 2>/dev/null)

        cat <<EOF
{
  "context_pct": $pct,
  "tokens_used": $total_tokens,
  "input_tokens": $input_tokens,
  "output_tokens": $output_tokens,
  "context_window_size": $size,
  "model": "$model"
}
EOF
    else
        echo '{"context_pct": 0, "tokens_used": 0}'
    fi
}

# Record session start
cmd_start() {
    local session_id="${1:-$(date +%s)}"
    ensure_devloop_dir
    init_sessions_file

    # Read context from stdin if available
    local stdin_data
    stdin_data=$(read_context_from_stdin)
    local context_info
    context_info=$(parse_context_info "$stdin_data")

    # Get API usage
    local api_usage
    api_usage=$("$SCRIPT_DIR/fetch-api-usage.sh" 2>/dev/null) || api_usage='{"error": "unavailable"}'

    # Extract values
    local context_pct tokens model
    if command -v jq &> /dev/null; then
        context_pct=$(echo "$context_info" | jq -r '.context_pct // 0' 2>/dev/null)
        tokens=$(echo "$context_info" | jq -r '.tokens_used // 0' 2>/dev/null)
        model=$(echo "$context_info" | jq -r '.model // "unknown"' 2>/dev/null)
        five_hour=$(echo "$api_usage" | jq -r '.five_hour_pct // 0' 2>/dev/null)
        seven_day=$(echo "$api_usage" | jq -r '.seven_day_pct // 0' 2>/dev/null)
    else
        context_pct=0
        tokens=0
        model="unknown"
        five_hour=0
        seven_day=0
    fi

    # Get project name
    local project
    project=$(basename "$(pwd)")

    # Save current session state
    cat > "$CURRENT_SESSION_FILE" <<EOF
{
  "session_id": "$session_id",
  "start_time": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "start_context_pct": $context_pct,
  "start_tokens": $tokens,
  "model": "$model",
  "project": "$project",
  "api_limits_start": {
    "five_hour": ${five_hour:-0},
    "seven_day": ${seven_day:-0}
  }
}
EOF

    echo "Session $session_id started (context: ${context_pct}%)"
}

# Record session end
cmd_end() {
    local session_id="${1:-}"
    ensure_devloop_dir

    if [ ! -f "$CURRENT_SESSION_FILE" ]; then
        echo "No active session to end"
        return 1
    fi

    # Read current session state
    local start_data
    start_data=$(cat "$CURRENT_SESSION_FILE")

    # Read context from stdin if available
    local stdin_data
    stdin_data=$(read_context_from_stdin)
    local context_info
    context_info=$(parse_context_info "$stdin_data")

    # Get API usage
    local api_usage
    api_usage=$("$SCRIPT_DIR/fetch-api-usage.sh" --no-cache 2>/dev/null) || api_usage='{"error": "unavailable"}'

    # Extract values
    if command -v jq &> /dev/null; then
        # Start values
        local start_time start_context start_tokens model project
        start_time=$(echo "$start_data" | jq -r '.start_time' 2>/dev/null)
        start_context=$(echo "$start_data" | jq -r '.start_context_pct // 0' 2>/dev/null)
        start_tokens=$(echo "$start_data" | jq -r '.start_tokens // 0' 2>/dev/null)
        model=$(echo "$start_data" | jq -r '.model // "unknown"' 2>/dev/null)
        project=$(echo "$start_data" | jq -r '.project // "unknown"' 2>/dev/null)
        session_id=$(echo "$start_data" | jq -r '.session_id' 2>/dev/null)

        # End values
        local end_context end_tokens
        end_context=$(echo "$context_info" | jq -r '.context_pct // 0' 2>/dev/null)
        end_tokens=$(echo "$context_info" | jq -r '.tokens_used // 0' 2>/dev/null)
        five_hour=$(echo "$api_usage" | jq -r '.five_hour_pct // 0' 2>/dev/null)
        seven_day=$(echo "$api_usage" | jq -r '.seven_day_pct // 0' 2>/dev/null)

        # Calculate deltas
        local tokens_delta=$((end_tokens - start_tokens))
        local context_delta=$((end_context - start_context))

        # Build session record
        local session_record
        session_record=$(cat <<EOF
{
  "session_id": "$session_id",
  "project": "$project",
  "model": "$model",
  "start_time": "$start_time",
  "end_time": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "start_context_pct": $start_context,
  "end_context_pct": $end_context,
  "context_delta": $context_delta,
  "start_tokens": $start_tokens,
  "end_tokens": $end_tokens,
  "tokens_used": $tokens_delta,
  "api_limits": {
    "five_hour": ${five_hour:-0},
    "seven_day": ${seven_day:-0}
  }
}
EOF
)

        # Append to sessions file
        local updated_sessions
        local now_timestamp
        now_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        updated_sessions=$(jq --argjson session "$session_record" --arg now "$now_timestamp" '
          .sessions += [$session] |
          .last_updated = $now
        ' "$SESSIONS_FILE")

        echo "$updated_sessions" > "$SESSIONS_FILE"

        # Clean up current session
        rm -f "$CURRENT_SESSION_FILE"

        # Output summary
        echo "Session ended:"
        echo "  Context: ${start_context}% → ${end_context}% (Δ ${context_delta}%)"
        echo "  Tokens: ${tokens_delta} used"
        echo "  API limits: 5hr ${five_hour}%, 7day ${seven_day}%"

        # Suggestion based on context
        if [ "$end_context" -ge 80 ]; then
            echo ""
            echo "⚠️  Context is at ${end_context}% - consider /clear before next session"
        elif [ "$end_context" -ge 60 ]; then
            echo ""
            echo "💡 Context is at ${end_context}% - /clear recommended soon"
        fi
    else
        echo "Session ended (jq not available for detailed stats)"
        rm -f "$CURRENT_SESSION_FILE"
    fi
}

# Show current session status
cmd_status() {
    if [ -f "$CURRENT_SESSION_FILE" ]; then
        echo "Active session:"
        if command -v jq &> /dev/null; then
            jq '.' "$CURRENT_SESSION_FILE"
        else
            cat "$CURRENT_SESSION_FILE"
        fi
    else
        echo "No active session"
    fi

    if [ -f "$SESSIONS_FILE" ]; then
        echo ""
        echo "Session history:"
        if command -v jq &> /dev/null; then
            local count
            count=$(jq '.sessions | length' "$SESSIONS_FILE")
            echo "  Total sessions tracked: $count"

            local avg_context avg_tokens
            avg_context=$(jq '[.sessions[].context_delta] | add / length | floor' "$SESSIONS_FILE" 2>/dev/null || echo "N/A")
            avg_tokens=$(jq '[.sessions[].tokens_used] | add / length | floor' "$SESSIONS_FILE" 2>/dev/null || echo "N/A")
            echo "  Avg context growth: ${avg_context}%"
            echo "  Avg tokens/session: $avg_tokens"
        fi
    fi
}

# Show session history
cmd_history() {
    local limit="${1:-5}"

    if [ ! -f "$SESSIONS_FILE" ]; then
        echo "No session history"
        return
    fi

    echo "Last $limit sessions:"
    if command -v jq &> /dev/null; then
        jq -r --argjson n "$limit" '
          .sessions | .[-$n:] | reverse | .[] |
          "\(.start_time | split("T")[0]) | \(.project) | \(.model) | ctx: \(.start_context_pct)%→\(.end_context_pct)% | tokens: \(.tokens_used)"
        ' "$SESSIONS_FILE"
    else
        tail -n 20 "$SESSIONS_FILE"
    fi
}

# Suggest whether to clear
cmd_suggest() {
    # Get API usage
    local api_usage
    api_usage=$("$SCRIPT_DIR/fetch-api-usage.sh" 2>/dev/null) || api_usage='{}'

    if command -v jq &> /dev/null; then
        local five_hour seven_day
        five_hour=$(echo "$api_usage" | jq -r '.five_hour_pct // 0' 2>/dev/null)
        seven_day=$(echo "$api_usage" | jq -r '.seven_day_pct // 0' 2>/dev/null)

        echo "Current API usage:"
        echo "  5-hour: ${five_hour}%"
        echo "  7-day: ${seven_day}%"

        # Check for patterns in history
        if [ -f "$SESSIONS_FILE" ]; then
            local last_context
            last_context=$(jq '.sessions[-1].end_context_pct // 0' "$SESSIONS_FILE" 2>/dev/null)

            if [ "$last_context" -ge 80 ]; then
                echo ""
                echo "🔴 CLEAR RECOMMENDED"
                echo "   Last session ended at ${last_context}% context"
            elif [ "$last_context" -ge 60 ]; then
                echo ""
                echo "🟡 CLEAR SUGGESTED"
                echo "   Last session ended at ${last_context}% context"
            else
                echo ""
                echo "🟢 Context looks healthy"
            fi
        fi

        if [ "${five_hour:-0}" -ge 90 ]; then
            echo ""
            echo "⚠️  5-hour limit at ${five_hour}% - consider waiting"
        fi
    else
        echo "Install jq for detailed suggestions"
    fi
}

# Main
case "${1:-status}" in
    start)   cmd_start "${2:-}" ;;
    end)     cmd_end "${2:-}" ;;
    status)  cmd_status ;;
    history) cmd_history "${2:-5}" ;;
    suggest) cmd_suggest ;;
    *)
        echo "Usage: $0 {start|end|status|history|suggest}"
        exit 1
        ;;
esac
