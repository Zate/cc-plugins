#!/usr/bin/env bash
#
# format-plan-status.sh - Format plan status for display
#
# Usage: format-plan-status.sh [--brief] [--markdown] [--json]
#
# Reads plan progress and formats it for different output contexts.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Format brief one-line status
format_brief() {
    local plan_name="$1"
    local done="$2"
    local total="$3"
    local percentage="$4"

    if [ "$total" -eq 0 ]; then
        echo "No tasks in plan"
    elif [ "$done" -eq "$total" ]; then
        echo "Plan complete ($total tasks)"
    else
        echo "$done/$total tasks ($percentage%)"
    fi
}

# Format markdown status block
format_markdown() {
    local plan_name="$1"
    local current_phase="$2"
    local done="$3"
    local total="$4"
    local percentage="$5"
    local next_task="$6"

    local status_emoji="🔄"
    if [ "$done" -eq "$total" ] && [ "$total" -gt 0 ]; then
        status_emoji="✅"
    elif [ "$percentage" -ge 75 ]; then
        status_emoji="🟢"
    elif [ "$percentage" -ge 50 ]; then
        status_emoji="🟡"
    elif [ "$percentage" -ge 25 ]; then
        status_emoji="🟠"
    else
        status_emoji="🔴"
    fi

    cat <<EOF
## Plan Status $status_emoji

**Plan**: $plan_name
**Phase**: ${current_phase:-"Not specified"}
**Progress**: $done/$total tasks ($percentage%)

EOF

    # Progress bar
    local bar_width=20
    local filled=$((percentage * bar_width / 100))
    local empty=$((bar_width - filled))
    printf '**['
    for ((i=0; i<filled; i++)); do printf '█'; done
    for ((i=0; i<empty; i++)); do printf '░'; done
    printf ']**\n\n'

    if [ -n "$next_task" ]; then
        echo "**Next**: $next_task"
    else
        echo "**Next**: All tasks complete!"
    fi
}

# Format JSON status
format_json() {
    local plan_name="$1"
    local current_phase="$2"
    local done="$3"
    local total="$4"
    local percentage="$5"
    local next_task="$6"

    cat <<EOF
{
  "plan_name": "$plan_name",
  "current_phase": "$current_phase",
  "done": $done,
  "total": $total,
  "percentage": $percentage,
  "next_task": "$(echo "$next_task" | sed 's/"/\\"/g')",
  "complete": $([ "$done" -eq "$total" ] && [ "$total" -gt 0 ] && echo "true" || echo "false")
}
EOF
}

# Main
main() {
    local format="brief"
    local plan_file=".devloop/plan.md"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --brief) format="brief"; shift ;;
            --markdown) format="markdown"; shift ;;
            --json) format="json"; shift ;;
            --plan) plan_file="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: format-plan-status.sh [--brief|--markdown|--json] [--plan FILE]"
                echo ""
                echo "Format plan status for display."
                echo ""
                echo "Options:"
                echo "  --brief     One-line status (default)"
                echo "  --markdown  Full markdown block"
                echo "  --json      JSON output"
                echo "  --plan FILE Specify plan file (default: .devloop/plan.md)"
                exit 0
                ;;
            *) shift ;;
        esac
    done

    # Get progress using calculate-progress.sh
    if [ -f "$SCRIPT_DIR/calculate-progress.sh" ]; then
        local progress=$("$SCRIPT_DIR/calculate-progress.sh" --json "$plan_file" 2>/dev/null)
    else
        echo "Error: calculate-progress.sh not found" >&2
        exit 1
    fi

    if echo "$progress" | grep -q '"error"'; then
        case "$format" in
            json) echo "$progress" ;;
            *) echo "Error: Plan not found" >&2 ;;
        esac
        exit 1
    fi

    # Parse JSON response
    local plan_name=$(echo "$progress" | grep -o '"plan_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
    local current_phase=$(echo "$progress" | grep -o '"current_phase"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
    local done=$(echo "$progress" | grep -o '"done"[[:space:]]*:[[:space:]]*[0-9]*' | sed 's/.*: *//')
    local total=$(echo "$progress" | grep -o '"total"[[:space:]]*:[[:space:]]*[0-9]*' | sed 's/.*: *//')
    local percentage=$(echo "$progress" | grep -o '"percentage"[[:space:]]*:[[:space:]]*[0-9]*' | sed 's/.*: *//')
    local next_task=$(echo "$progress" | grep -o '"next_task"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')

    case "$format" in
        brief) format_brief "$plan_name" "$done" "$total" "$percentage" ;;
        markdown) format_markdown "$plan_name" "$current_phase" "$done" "$total" "$percentage" "$next_task" ;;
        json) format_json "$plan_name" "$current_phase" "$done" "$total" "$percentage" "$next_task" ;;
    esac
}

main "$@"
