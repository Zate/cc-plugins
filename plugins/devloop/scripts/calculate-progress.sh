#!/usr/bin/env bash
#
# calculate-progress.sh - Task counting and completion percentage calculation
#
# Usage: calculate-progress.sh [plan-file]
#
# Output: JSON with task counts and completion metrics
#
# Task markers recognized:
#   [x] / [X] - Completed
#   [ ] - Pending
#   [~] - In progress
#   [!] - Blocked
#   [-] - Skipped

set -euo pipefail

# Default plan file location
PLAN_FILE="${1:-.devloop/plan.md}"

# Count tasks by status marker
count_tasks() {
    local plan_file="$1"

    if [ ! -f "$plan_file" ]; then
        echo "error=Plan file not found: $plan_file"
        return 1
    fi

    # Count different task states
    local completed=$(grep -cE '^\s*-\s*\[[xX]\]' "$plan_file" 2>/dev/null || echo "0")
    local pending=$(grep -cE '^\s*-\s*\[\s\]' "$plan_file" 2>/dev/null || echo "0")
    local in_progress=$(grep -cE '^\s*-\s*\[~\]' "$plan_file" 2>/dev/null || echo "0")
    local blocked=$(grep -cE '^\s*-\s*\[!\]' "$plan_file" 2>/dev/null || echo "0")
    local skipped=$(grep -cE '^\s*-\s*\[-\]' "$plan_file" 2>/dev/null || echo "0")

    # Calculate totals
    local total=$((completed + pending + in_progress + blocked + skipped))
    local done=$((completed + skipped))  # Skipped counts as "done" for progress

    # Calculate percentage (avoid division by zero)
    local percentage=0
    if [ "$total" -gt 0 ]; then
        percentage=$((done * 100 / total))
    fi

    echo "completed=$completed,pending=$pending,in_progress=$in_progress,blocked=$blocked,skipped=$skipped,total=$total,done=$done,percentage=$percentage"
}

# Get next pending task
get_next_task() {
    local plan_file="$1"

    if [ ! -f "$plan_file" ]; then
        echo ""
        return
    fi

    # Find first pending task ([ ] marker)
    local next_task=$(grep -m1 -E '^\s*-\s*\[\s\]' "$plan_file" 2>/dev/null | sed 's/.*\[ \]//' | sed 's/^\s*//' | head -c 100)

    echo "$next_task"
}

# Get current phase from plan
get_current_phase() {
    local plan_file="$1"

    if [ ! -f "$plan_file" ]; then
        echo ""
        return
    fi

    # Look for "Current Phase" in plan metadata
    local phase=$(grep -o 'Current Phase:[^#]*' "$plan_file" 2>/dev/null | sed 's/Current Phase:\s*//' | sed 's/\*//g' | head -c 50)

    if [ -z "$phase" ]; then
        # Fallback: find the phase heading before the first pending task
        local task_line=$(grep -n -m1 -E '^\s*-\s*\[\s\]' "$plan_file" 2>/dev/null | cut -d: -f1)
        if [ -n "$task_line" ]; then
            phase=$(head -n "$task_line" "$plan_file" | grep -o '### Phase [^#]*' | tail -1 | sed 's/### //')
        fi
    fi

    echo "$phase"
}

# Get plan name
get_plan_name() {
    local plan_file="$1"

    if [ ! -f "$plan_file" ]; then
        echo ""
        return
    fi

    local name=$(grep -m1 "^# " "$plan_file" 2>/dev/null | sed 's/^# //' | head -c 80)
    echo "$name"
}

# Main execution
main() {
    local output_json=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --json) output_json=true; shift ;;
            -h|--help)
                echo "Usage: calculate-progress.sh [--json] [plan-file]"
                echo ""
                echo "Calculate task completion metrics from a devloop plan."
                echo ""
                echo "Options:"
                echo "  --json    Output as JSON"
                echo ""
                echo "Default plan file: .devloop/plan.md"
                exit 0
                ;;
            *) PLAN_FILE="$1"; shift ;;
        esac
    done

    if [ ! -f "$PLAN_FILE" ]; then
        if [ "$output_json" = true ]; then
            echo '{"error": "Plan file not found"}'
        else
            echo "Error: Plan file not found: $PLAN_FILE" >&2
        fi
        exit 1
    fi

    local counts=$(count_tasks "$PLAN_FILE")
    local next_task=$(get_next_task "$PLAN_FILE")
    local current_phase=$(get_current_phase "$PLAN_FILE")
    local plan_name=$(get_plan_name "$PLAN_FILE")

    # Parse counts
    local completed=$(echo "$counts" | grep -o 'completed=[0-9]*' | cut -d= -f2)
    local pending=$(echo "$counts" | grep -o 'pending=[0-9]*' | cut -d= -f2)
    local in_progress=$(echo "$counts" | grep -o 'in_progress=[0-9]*' | cut -d= -f2)
    local blocked=$(echo "$counts" | grep -o 'blocked=[0-9]*' | cut -d= -f2)
    local skipped=$(echo "$counts" | grep -o 'skipped=[0-9]*' | cut -d= -f2)
    local total=$(echo "$counts" | grep -o 'total=[0-9]*' | cut -d= -f2)
    local done=$(echo "$counts" | grep -o 'done=[0-9]*' | cut -d= -f2)
    local percentage=$(echo "$counts" | grep -o 'percentage=[0-9]*' | cut -d= -f2)

    if [ "$output_json" = true ]; then
        cat <<EOF
{
  "plan_name": "$plan_name",
  "plan_file": "$PLAN_FILE",
  "current_phase": "$current_phase",
  "completed": $completed,
  "pending": $pending,
  "in_progress": $in_progress,
  "blocked": $blocked,
  "skipped": $skipped,
  "total": $total,
  "done": $done,
  "percentage": $percentage,
  "next_task": "$(echo "$next_task" | sed 's/"/\\"/g')"
}
EOF
    else
        echo "Plan: $plan_name"
        echo "Phase: ${current_phase:-unknown}"
        echo "Progress: $done/$total ($percentage%)"
        echo ""
        echo "Tasks:"
        echo "  Completed: $completed"
        echo "  Pending: $pending"
        echo "  In Progress: $in_progress"
        echo "  Blocked: $blocked"
        echo "  Skipped: $skipped"
        echo ""
        if [ -n "$next_task" ]; then
            echo "Next: $next_task"
        else
            echo "Next: (all tasks complete)"
        fi
    fi
}

main "$@"
