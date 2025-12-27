#!/usr/bin/env bash
#
# select-next-task.sh - Determine next task(s) respecting dependencies and parallelism
#
# Usage: select-next-task.sh [--json] [--all-parallel] [--plan FILE] [--state FILE]
#
# Reads plan-state.json (or parses plan.md as fallback) and determines:
# - The next pending task that has all dependencies satisfied
# - Parallel tasks that can be run together
# - Blocked tasks and their missing dependencies
#
# Dependencies: jq (recommended for JSON mode, falls back to grep parsing)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN_FILE=".devloop/plan.md"
STATE_FILE=""
OUTPUT_JSON=false
ALL_PARALLEL=false

# Colors
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
BLUE='\033[34m'
CYAN='\033[36m'
RESET='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --json) OUTPUT_JSON=true; shift ;;
        --all-parallel) ALL_PARALLEL=true; shift ;;
        --plan) PLAN_FILE="$2"; shift 2 ;;
        --state) STATE_FILE="$2"; shift 2 ;;
        -h|--help)
            cat <<EOF
Usage: select-next-task.sh [OPTIONS]

Determine next task(s) to execute respecting dependencies and parallelism.

Options:
  --json          Output as JSON
  --all-parallel  Include all parallel tasks in same group
  --plan FILE     Specify plan file (default: .devloop/plan.md)
  --state FILE    Specify state file (default: auto-detect)
  -h, --help      Show this help

Output (default):
  Prints next task ID and description.
  With --all-parallel, prints all tasks in same parallel group.

Output (--json):
  {
    "next_task": "4.1",
    "description": "Task description",
    "parallel_group": "A",  // if applicable
    "parallel_tasks": ["4.1", "4.2"],  // if --all-parallel
    "dependencies_met": true,
    "blocked_reason": null
  }

Exit codes:
  0 - Task found
  1 - No tasks pending (all complete or blocked)
  2 - Plan/state file not found
EOF
            exit 0
            ;;
        *) shift ;;
    esac
done

# Auto-detect state file
if [ -z "$STATE_FILE" ]; then
    STATE_FILE="$(dirname "$PLAN_FILE")/plan-state.json"
fi

# Check for jq
HAS_JQ=false
if command -v jq &>/dev/null; then
    HAS_JQ=true
fi

# ============================================
# JSON Mode (preferred - reads plan-state.json)
# ============================================
select_from_json() {
    local state_file="$1"

    if [ ! -f "$state_file" ]; then
        return 1
    fi

    if [ "$HAS_JQ" = false ]; then
        # Simple fallback without jq
        return 1
    fi

    # Get completed task IDs for dependency checking
    local completed_ids
    completed_ids=$(jq -r '.tasks | to_entries[] | select(.value.status == "complete" or .value.status == "skipped") | .key' "$state_file" 2>/dev/null | tr '\n' ',' | sed 's/,$//')

    # Get all pending tasks sorted by phase and task number
    local pending_tasks
    pending_tasks=$(jq -r '
        .tasks | to_entries[]
        | select(.value.status == "pending")
        | [.key, .value.phase, .value.description, (.value.parallel_group // ""), (.value.depends_on // [] | join(","))]
        | @tsv
    ' "$state_file" 2>/dev/null | sort -t$'\t' -k2,2n -k1,1V)

    if [ -z "$pending_tasks" ]; then
        # No pending tasks
        if [ "$OUTPUT_JSON" = true ]; then
            echo '{"next_task": null, "reason": "all_complete", "message": "All tasks complete or blocked"}'
        else
            echo "All tasks complete!"
        fi
        exit 1
    fi

    # Check each pending task for dependency satisfaction
    local first_available=""
    local first_available_desc=""
    local first_parallel_group=""
    local blocked_tasks=()

    while IFS=$'\t' read -r task_id phase desc parallel_group deps; do
        [ -z "$task_id" ] && continue

        local deps_met=true
        local missing_deps=()

        if [ -n "$deps" ]; then
            IFS=',' read -ra dep_array <<< "$deps"
            for dep in "${dep_array[@]}"; do
                dep=$(echo "$dep" | tr -d ' ')
                [ -z "$dep" ] && continue
                if ! echo ",$completed_ids," | grep -q ",$dep,"; then
                    deps_met=false
                    missing_deps+=("$dep")
                fi
            done
        fi

        if [ "$deps_met" = true ]; then
            if [ -z "$first_available" ]; then
                first_available="$task_id"
                first_available_desc="$desc"
                first_parallel_group="$parallel_group"
            fi
            # Found a valid next task
            break
        else
            blocked_tasks+=("$task_id:${missing_deps[*]}")
        fi
    done <<< "$pending_tasks"

    if [ -z "$first_available" ]; then
        # All pending tasks are blocked
        if [ "$OUTPUT_JSON" = true ]; then
            local blocked_json="["
            local first=true
            for bt in "${blocked_tasks[@]}"; do
                local tid="${bt%%:*}"
                local deps="${bt#*:}"
                [ "$first" = false ] && blocked_json+=","
                first=false
                blocked_json+="{\"task\":\"$tid\",\"blocked_by\":\"$deps\"}"
            done
            blocked_json+="]"
            echo "{\"next_task\": null, \"reason\": \"all_blocked\", \"blocked_tasks\": $blocked_json}"
        else
            echo "All pending tasks are blocked by unmet dependencies:"
            for bt in "${blocked_tasks[@]}"; do
                echo "  - Task ${bt%%:*} blocked by: ${bt#*:}"
            done
        fi
        exit 1
    fi

    # Get parallel tasks if requested
    local parallel_tasks=()
    if [ "$ALL_PARALLEL" = true ] && [ -n "$first_parallel_group" ]; then
        parallel_tasks=($(jq -r ".parallel_groups[\"$first_parallel_group\"][]?" "$state_file" 2>/dev/null))

        # Filter to only pending tasks with deps met
        local valid_parallel=()
        for pt in "${parallel_tasks[@]}"; do
            local pt_status=$(jq -r ".tasks[\"$pt\"].status // \"\"" "$state_file" 2>/dev/null)
            if [ "$pt_status" = "pending" ]; then
                # Check deps for this task
                local pt_deps=$(jq -r ".tasks[\"$pt\"].depends_on // [] | join(\",\")" "$state_file" 2>/dev/null)
                local pt_deps_met=true
                if [ -n "$pt_deps" ]; then
                    IFS=',' read -ra pt_dep_array <<< "$pt_deps"
                    for dep in "${pt_dep_array[@]}"; do
                        dep=$(echo "$dep" | tr -d ' ')
                        [ -z "$dep" ] && continue
                        if ! echo ",$completed_ids," | grep -q ",$dep,"; then
                            pt_deps_met=false
                            break
                        fi
                    done
                fi
                if [ "$pt_deps_met" = true ]; then
                    valid_parallel+=("$pt")
                fi
            fi
        done
        parallel_tasks=("${valid_parallel[@]}")
    fi

    # Output result
    if [ "$OUTPUT_JSON" = true ]; then
        local json="{\"next_task\": \"$first_available\""
        json+=", \"description\": \"$(echo "$first_available_desc" | sed 's/"/\\"/g')\""
        json+=", \"phase\": $(jq -r ".tasks[\"$first_available\"].phase // 1" "$state_file" 2>/dev/null)"

        if [ -n "$first_parallel_group" ]; then
            json+=", \"parallel_group\": \"$first_parallel_group\""
        fi

        if [ ${#parallel_tasks[@]} -gt 1 ]; then
            json+=", \"parallel_tasks\": [\"$(echo "${parallel_tasks[@]}" | sed 's/ /", "/g')\"]"
        fi

        json+=", \"dependencies_met\": true"
        json+=", \"blocked_reason\": null"

        # Add acceptance criteria if available
        local acceptance=$(jq -r ".tasks[\"$first_available\"].acceptance // \"\"" "$state_file" 2>/dev/null)
        if [ -n "$acceptance" ]; then
            json+=", \"acceptance\": \"$(echo "$acceptance" | sed 's/"/\\"/g')\""
        fi

        # Add files if available
        local files=$(jq -r ".tasks[\"$first_available\"].files // [] | join(\", \")" "$state_file" 2>/dev/null)
        if [ -n "$files" ]; then
            json+=", \"files\": \"$(echo "$files" | sed 's/"/\\"/g')\""
        fi

        json+="}"
        echo "$json"
    else
        echo -e "${GREEN}Next Task:${RESET} $first_available"
        echo -e "${BLUE}Description:${RESET} $first_available_desc"

        if [ -n "$first_parallel_group" ]; then
            echo -e "${CYAN}Parallel Group:${RESET} $first_parallel_group"
        fi

        if [ ${#parallel_tasks[@]} -gt 1 ]; then
            echo -e "${YELLOW}Can run in parallel:${RESET} ${parallel_tasks[*]}"
        fi

        # Show acceptance criteria
        local acceptance=$(jq -r ".tasks[\"$first_available\"].acceptance // \"\"" "$state_file" 2>/dev/null)
        if [ -n "$acceptance" ]; then
            echo -e "${BLUE}Acceptance:${RESET} $acceptance"
        fi

        # Show files
        local files=$(jq -r ".tasks[\"$first_available\"].files // [] | join(\", \")" "$state_file" 2>/dev/null)
        if [ -n "$files" ]; then
            echo -e "${BLUE}Files:${RESET} $files"
        fi
    fi

    exit 0
}

# ============================================
# Markdown Fallback Mode (backward compatible)
# ============================================
select_from_markdown() {
    local plan_file="$1"

    if [ ! -f "$plan_file" ]; then
        if [ "$OUTPUT_JSON" = true ]; then
            echo '{"error": "Plan file not found"}'
        else
            echo "Error: Plan file not found: $plan_file" >&2
        fi
        exit 2
    fi

    # Find first pending task
    local next_line
    next_line=$(grep -m1 -E '^\s*-\s*\[\s\]\s*Task\s+[0-9]+\.[0-9]+' "$plan_file" 2>/dev/null || echo "")

    if [ -z "$next_line" ]; then
        if [ "$OUTPUT_JSON" = true ]; then
            echo '{"next_task": null, "reason": "all_complete"}'
        else
            echo "All tasks complete!"
        fi
        exit 1
    fi

    # Parse the line
    local task_id desc parallel_group deps

    # Extract task ID (e.g., "4.1")
    task_id=$(echo "$next_line" | grep -oE 'Task\s+[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+')

    # Extract description (everything after "Task N.M:" up to [parallel:] or [depends:])
    desc=$(echo "$next_line" | sed -E 's/.*Task\s+[0-9]+\.[0-9]+:?\s*//' | sed -E 's/\[parallel:[A-Za-z]+\]//' | sed -E 's/\[depends:[0-9.,]+\]//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

    # Extract parallel group
    parallel_group=$(echo "$next_line" | grep -oE '\[parallel:([A-Za-z]+)\]' | grep -oE '[A-Za-z]+$' || echo "")

    # Extract dependencies
    deps=$(echo "$next_line" | grep -oE '\[depends:([0-9.,]+)\]' | grep -oE '[0-9.,]+' || echo "")

    if [ "$OUTPUT_JSON" = true ]; then
        local json="{\"next_task\": \"$task_id\""
        json+=", \"description\": \"$(echo "$desc" | sed 's/"/\\"/g')\""

        if [ -n "$parallel_group" ]; then
            json+=", \"parallel_group\": \"$parallel_group\""
        fi

        json+=", \"source\": \"markdown\"}"
        echo "$json"
    else
        echo -e "${GREEN}Next Task:${RESET} $task_id"
        echo -e "${BLUE}Description:${RESET} $desc"

        if [ -n "$parallel_group" ]; then
            echo -e "${CYAN}Parallel Group:${RESET} $parallel_group"
        fi

        echo -e "${YELLOW}(Note: Using markdown fallback - JSON state not available)${RESET}"
    fi

    exit 0
}

# ============================================
# Main Execution
# ============================================
main() {
    # Try JSON mode first
    if [ -f "$STATE_FILE" ] && [ "$HAS_JQ" = true ]; then
        if select_from_json "$STATE_FILE"; then
            exit 0
        fi
    fi

    # Fall back to markdown parsing
    if [ -f "$PLAN_FILE" ]; then
        select_from_markdown "$PLAN_FILE"
    else
        if [ "$OUTPUT_JSON" = true ]; then
            echo '{"error": "No plan file found", "checked": ["'"$STATE_FILE"'", "'"$PLAN_FILE"'"]}'
        else
            echo "Error: No plan file found" >&2
            echo "Checked: $STATE_FILE, $PLAN_FILE" >&2
        fi
        exit 2
    fi
}

main
