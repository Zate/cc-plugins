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

    # Check for plan-state.json alongside plan.md
    local plan_dir=$(dirname "$plan_file")
    local state_file="$plan_dir/plan-state.json"

    local plan_name current_phase done total percentage next_task

    if [ -f "$state_file" ]; then
        # Read from plan-state.json (faster, no parsing)
        if command -v jq &>/dev/null; then
            # Use jq for robust JSON parsing
            plan_name=$(jq -r '.plan_name // "Unknown Plan"' "$state_file" 2>/dev/null)
            current_phase=$(jq -r '.current_phase // 1' "$state_file" 2>/dev/null)
            done=$(jq -r '.stats.done // 0' "$state_file" 2>/dev/null)
            total=$(jq -r '.stats.total // 0' "$state_file" 2>/dev/null)
            percentage=$(jq -r '.stats.percentage // 0' "$state_file" 2>/dev/null)
            next_task=$(jq -r '.next_task // ""' "$state_file" 2>/dev/null)

            # Convert phase number to "Phase N" format for compatibility
            if [ -n "$current_phase" ] && [ "$current_phase" != "null" ]; then
                local phase_name=$(jq -r ".phases[] | select(.number == $current_phase) | .name" "$state_file" 2>/dev/null)
                if [ -n "$phase_name" ] && [ "$phase_name" != "null" ]; then
                    current_phase="Phase $current_phase: $phase_name"
                else
                    current_phase="Phase $current_phase"
                fi
            else
                current_phase=""
            fi

            # Convert null next_task to empty string
            [ "$next_task" = "null" ] && next_task=""
        else
            # Fallback: basic grep/sed parsing (less robust)
            plan_name=$(grep -o '"plan_name"[[:space:]]*:[[:space:]]*"[^"]*"' "$state_file" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "Unknown Plan")
            current_phase=$(grep -o '"current_phase"[[:space:]]*:[[:space:]]*[0-9]*' "$state_file" | sed 's/.*: *//' || echo "1")
            done=$(grep -o '"done"[[:space:]]*:[[:space:]]*[0-9]*' "$state_file" | sed 's/.*: *//' || echo "0")
            total=$(grep -o '"total"[[:space:]]*:[[:space:]]*[0-9]*' "$state_file" | sed 's/.*: *//' || echo "0")
            percentage=$(grep -o '"percentage"[[:space:]]*:[[:space:]]*[0-9]*' "$state_file" | sed 's/.*: *//' || echo "0")
            next_task=$(grep -o '"next_task"[[:space:]]*:[[:space:]]*"[^"]*"' "$state_file" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")

            # Format current_phase as "Phase N"
            [ -n "$current_phase" ] && current_phase="Phase $current_phase"
        fi
    else
        # Fallback: use calculate-progress.sh (backward compatibility)
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

        # Parse JSON response from calculate-progress.sh
        plan_name=$(echo "$progress" | grep -o '"plan_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "Unknown Plan")
        current_phase=$(echo "$progress" | grep -o '"current_phase"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
        done=$(echo "$progress" | grep -o '"done"[[:space:]]*:[[:space:]]*[0-9]*' | sed 's/.*: *//' || echo "0")
        total=$(echo "$progress" | grep -o '"total"[[:space:]]*:[[:space:]]*[0-9]*' | sed 's/.*: *//' || echo "0")
        percentage=$(echo "$progress" | grep -o '"percentage"[[:space:]]*:[[:space:]]*[0-9]*' | sed 's/.*: *//' || echo "0")
        next_task=$(echo "$progress" | grep -o '"next_task"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
    fi

    # Ensure numeric variables have valid values
    done=${done:-0}
    total=${total:-0}
    percentage=${percentage:-0}

    case "$format" in
        brief) format_brief "$plan_name" "$done" "$total" "$percentage" ;;
        markdown) format_markdown "$plan_name" "$current_phase" "$done" "$total" "$percentage" "$next_task" ;;
        json) format_json "$plan_name" "$current_phase" "$done" "$total" "$percentage" "$next_task" ;;
    esac
}

main "$@"
