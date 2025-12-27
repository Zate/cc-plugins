#!/usr/bin/env bash
#
# calculate-progress.sh - Task counting and completion percentage calculation
#
# Usage: calculate-progress.sh [plan-file]
#
# Output: JSON with task counts and completion metrics
#
# Optimization: If plan-state.json exists alongside plan.md, reads counts
# from JSON (fast) instead of parsing markdown. Falls back to markdown
# parsing if JSON is missing or unavailable (backward compatible).
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

# Read task counts from plan-state.json if available
read_from_json() {
    local json_file="$1"

    if [ ! -f "$json_file" ]; then
        return 1
    fi

    # Check if jq is available for robust JSON parsing
    if command -v jq &> /dev/null; then
        local completed=$(jq -r '.stats.completed // 0' "$json_file" 2>/dev/null || echo "0")
        local pending=$(jq -r '.stats.pending // 0' "$json_file" 2>/dev/null || echo "0")
        local in_progress=$(jq -r '.stats.in_progress // 0' "$json_file" 2>/dev/null || echo "0")
        local blocked=$(jq -r '.stats.blocked // 0' "$json_file" 2>/dev/null || echo "0")
        local skipped=$(jq -r '.stats.skipped // 0' "$json_file" 2>/dev/null || echo "0")
        local total=$(jq -r '.stats.total // 0' "$json_file" 2>/dev/null || echo "0")
        local done=$(jq -r '.stats.done // 0' "$json_file" 2>/dev/null || echo "0")
        local percentage=$(jq -r '.stats.percentage // 0' "$json_file" 2>/dev/null || echo "0")

        echo "completed=$completed,pending=$pending,in_progress=$in_progress,blocked=$blocked,skipped=$skipped,total=$total,done=$done,percentage=$percentage"
        return 0
    else
        # Fallback: simple grep parsing (fragile but works for simple cases)
        local stats_line=$(grep -A10 '"stats"' "$json_file" 2>/dev/null || echo "")
        if [ -z "$stats_line" ]; then
            return 1
        fi

        local completed=$(echo "$stats_line" | grep -o '"completed":[[:space:]]*[0-9]*' | grep -o '[0-9]*$' || echo "0")
        local pending=$(echo "$stats_line" | grep -o '"pending":[[:space:]]*[0-9]*' | grep -o '[0-9]*$' || echo "0")
        local in_progress=$(echo "$stats_line" | grep -o '"in_progress":[[:space:]]*[0-9]*' | grep -o '[0-9]*$' || echo "0")
        local blocked=$(echo "$stats_line" | grep -o '"blocked":[[:space:]]*[0-9]*' | grep -o '[0-9]*$' || echo "0")
        local skipped=$(echo "$stats_line" | grep -o '"skipped":[[:space:]]*[0-9]*' | grep -o '[0-9]*$' || echo "0")
        local total=$(echo "$stats_line" | grep -o '"total":[[:space:]]*[0-9]*' | grep -o '[0-9]*$' || echo "0")
        local done=$(echo "$stats_line" | grep -o '"done":[[:space:]]*[0-9]*' | grep -o '[0-9]*$' || echo "0")
        local percentage=$(echo "$stats_line" | grep -o '"percentage":[[:space:]]*[0-9]*' | grep -o '[0-9]*$' || echo "0")

        echo "completed=$completed,pending=$pending,in_progress=$in_progress,blocked=$blocked,skipped=$skipped,total=$total,done=$done,percentage=$percentage"
        return 0
    fi
}

# Count tasks by status marker (markdown parsing fallback)
count_tasks() {
    local plan_file="$1"

    if [ ! -f "$plan_file" ]; then
        echo "error=Plan file not found: $plan_file"
        return 1
    fi

    # Try to read from JSON first (optimization)
    local json_file="${plan_file%.md}-state.json"
    local counts
    if counts=$(read_from_json "$json_file" 2>/dev/null); then
        echo "$counts"
        return 0
    fi

    # Fallback: Parse markdown (backward compatible)
    # Count different task states (grep -c always succeeds and returns a number)
    local completed=$(grep -cE '^\s*-\s*\[[xX]\]' "$plan_file" 2>/dev/null)
    local pending=$(grep -cE '^\s*-\s*\[\s\]' "$plan_file" 2>/dev/null)
    local in_progress=$(grep -cE '^\s*-\s*\[~\]' "$plan_file" 2>/dev/null)
    local blocked=$(grep -cE '^\s*-\s*\[!\]' "$plan_file" 2>/dev/null)
    local skipped=$(grep -cE '^\s*-\s*\[-\]' "$plan_file" 2>/dev/null)

    # Ensure all are valid numbers (fallback to 0 if empty/failed)
    completed=${completed:-0}
    pending=${pending:-0}
    in_progress=${in_progress:-0}
    blocked=${blocked:-0}
    skipped=${skipped:-0}

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

    # Try to read from JSON first (optimization)
    local json_file="${plan_file%.md}-state.json"
    if [ -f "$json_file" ] && command -v jq &> /dev/null; then
        local next_id=$(jq -r '.next_task // ""' "$json_file" 2>/dev/null)
        if [ -n "$next_id" ] && [ "$next_id" != "null" ]; then
            # Get task description from tasks object
            local next_desc=$(jq -r ".tasks[\"$next_id\"].description // \"\"" "$json_file" 2>/dev/null)
            if [ -n "$next_desc" ]; then
                echo "$next_desc" | head -c 100
                return
            fi
        fi
    fi

    # Fallback: Parse markdown
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

    # Try to read from JSON first (optimization)
    local json_file="${plan_file%.md}-state.json"
    if [ -f "$json_file" ] && command -v jq &> /dev/null; then
        local phase_num=$(jq -r '.current_phase // ""' "$json_file" 2>/dev/null)
        if [ -n "$phase_num" ] && [ "$phase_num" != "null" ]; then
            # Get phase name from phases array
            local phase_name=$(jq -r ".phases[] | select(.number == $phase_num) | .name // \"\"" "$json_file" 2>/dev/null)
            if [ -n "$phase_name" ]; then
                echo "Phase $phase_num: $phase_name" | head -c 50
                return
            fi
        fi
    fi

    # Fallback: Parse markdown
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

    # Try to read from JSON first (optimization)
    local json_file="${plan_file%.md}-state.json"
    if [ -f "$json_file" ] && command -v jq &> /dev/null; then
        local name=$(jq -r '.plan_name // ""' "$json_file" 2>/dev/null)
        if [ -n "$name" ] && [ "$name" != "null" ]; then
            echo "$name" | head -c 80
            return
        fi
    fi

    # Fallback: Parse markdown
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

    # Parse counts (use [0-9]+ to require at least one digit, fallback to 0)
    local completed=$(echo "$counts" | grep -o 'completed=[0-9]\+' | cut -d= -f2)
    local pending=$(echo "$counts" | grep -o 'pending=[0-9]\+' | cut -d= -f2)
    local in_progress=$(echo "$counts" | grep -o 'in_progress=[0-9]\+' | cut -d= -f2)
    local blocked=$(echo "$counts" | grep -o 'blocked=[0-9]\+' | cut -d= -f2)
    local skipped=$(echo "$counts" | grep -o 'skipped=[0-9]\+' | cut -d= -f2)
    local total=$(echo "$counts" | grep -o 'total=[0-9]\+' | cut -d= -f2)
    local done=$(echo "$counts" | grep -o 'done=[0-9]\+' | cut -d= -f2)
    local percentage=$(echo "$counts" | grep -o 'percentage=[0-9]\+' | cut -d= -f2)

    # Ensure all variables have valid values
    completed=${completed:-0}
    pending=${pending:-0}
    in_progress=${in_progress:-0}
    blocked=${blocked:-0}
    skipped=${skipped:-0}
    total=${total:-0}
    done=${done:-0}
    percentage=${percentage:-0}

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
