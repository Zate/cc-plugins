#!/usr/bin/env bash
#
# sync-plan-state.sh - Parse plan.md and generate plan-state.json
#
# Usage: sync-plan-state.sh [plan-file] [--output FILE]
#
# Parses .devloop/plan.md (or specified file) and outputs a structured
# JSON representation to .devloop/plan-state.json (or specified file).
#
# Task markers recognized:
#   [ ] - Pending
#   [x] / [X] - Completed
#   [~] - In progress
#   [!] - Blocked
#   [-] - Skipped
#
# Dependencies: jq (optional but recommended)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN_FILE=".devloop/plan.md"
OUTPUT_FILE=""
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --output|-o) OUTPUT_FILE="$2"; shift 2 ;;
        --verbose|-v) VERBOSE=true; shift ;;
        -h|--help)
            echo "Usage: sync-plan-state.sh [plan-file] [--output FILE] [--verbose]"
            echo ""
            echo "Parse plan.md and generate plan-state.json"
            echo ""
            echo "Options:"
            echo "  --output, -o FILE   Output file (default: .devloop/plan-state.json)"
            echo "  --verbose, -v       Show detailed parsing info"
            echo ""
            echo "Default plan file: .devloop/plan.md"
            exit 0
            ;;
        -*)
            # Skip unknown options but don't fail
            shift
            ;;
        *)
            PLAN_FILE="$1"
            shift
            ;;
    esac
done

# Set default output file based on plan file location
if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="$(dirname "$PLAN_FILE")/plan-state.json"
fi

# Verify plan file exists
if [ ! -f "$PLAN_FILE" ]; then
    echo "Error: Plan file not found: $PLAN_FILE" >&2
    exit 1
fi

# Helper: escape string for JSON
json_escape() {
    local s="$1"
    # Escape backslashes, quotes, and control characters
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    echo "$s"
}

# Helper: convert task marker to status
marker_to_status() {
    case "$1" in
        "[ ]") echo "pending" ;;
        "[x]"|"[X]") echo "complete" ;;
        "[~]") echo "in_progress" ;;
        "[!]") echo "blocked" ;;
        "[-]") echo "skipped" ;;
        *) echo "pending" ;;
    esac
}

# Extract plan name from first # heading
get_plan_name() {
    grep -m1 "^# " "$PLAN_FILE" 2>/dev/null | sed 's/^# //' | head -c 200
}

# Extract plan status from **Status**: line
get_plan_status() {
    local status
    status=$(grep -oE '\*\*Status\*\*:\s*[A-Za-z_ ]+' "$PLAN_FILE" 2>/dev/null | head -1 | sed 's/.*:\s*//' | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    case "$status" in
        planning|in_progress|review|complete|archived) echo "$status" ;;
        "in progress") echo "in_progress" ;;
        *) echo "planning" ;;
    esac
}

# Extract created date
get_created_date() {
    grep -oE '\*\*Created\*\*:\s*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$PLAN_FILE" 2>/dev/null | head -1 | sed 's/.*:\s*//' || echo ""
}

# Extract updated timestamp
get_updated_timestamp() {
    grep -oE '\*\*Updated\*\*:\s*[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9:Z+-]+' "$PLAN_FILE" 2>/dev/null | head -1 | sed 's/.*:\s*//' || echo ""
}

# Extract current phase number
get_current_phase() {
    local phase
    phase=$(grep -oE '\*\*Current Phase\*\*:\s*(Phase\s+)?[0-9]+' "$PLAN_FILE" 2>/dev/null | head -1 | grep -oE '[0-9]+$' || echo "")
    if [ -n "$phase" ]; then
        echo "$phase"
    else
        echo "1"
    fi
}

# Count tasks by status
count_tasks() {
    local completed pending in_progress blocked skipped total done_count percentage
    completed=$(grep -cE '^\s*-\s*\[[xX]\]' "$PLAN_FILE" 2>/dev/null | tr -d '[:space:]' || echo "0")
    pending=$(grep -cE '^\s*-\s*\[\s\]' "$PLAN_FILE" 2>/dev/null | tr -d '[:space:]' || echo "0")
    in_progress=$(grep -cE '^\s*-\s*\[~\]' "$PLAN_FILE" 2>/dev/null | tr -d '[:space:]' || echo "0")
    blocked=$(grep -cE '^\s*-\s*\[!\]' "$PLAN_FILE" 2>/dev/null | tr -d '[:space:]' || echo "0")
    skipped=$(grep -cE '^\s*-\s*\[-\]' "$PLAN_FILE" 2>/dev/null | tr -d '[:space:]' || echo "0")
    # Ensure numbers are valid
    completed=${completed:-0}
    pending=${pending:-0}
    in_progress=${in_progress:-0}
    blocked=${blocked:-0}
    skipped=${skipped:-0}
    total=$((completed + pending + in_progress + blocked + skipped))
    done_count=$((completed + skipped))
    percentage=0
    if [ "$total" -gt 0 ]; then
        percentage=$((done_count * 100 / total))
    fi
    echo "$completed,$pending,$in_progress,$blocked,$skipped,$total,$done_count,$percentage"
}

# Parse phases and tasks - outputs JSON fragments
parse_plan() {
    local current_phase_num=""
    local current_phase_name=""
    local current_phase_goal=""
    local next_task=""
    local line_num=0
    local in_task_block=false
    local current_task_id=""
    local current_task_desc=""
    local current_task_status=""
    local current_task_parallel=""
    local current_task_deps=""
    local current_task_acceptance=""
    local current_task_files=""
    local current_task_notes=""

    # Use temporary files for collecting data
    local tmp_dir
    tmp_dir=$(mktemp -d)
    local phases_file="$tmp_dir/phases"
    local tasks_file="$tmp_dir/tasks"
    local parallel_file="$tmp_dir/parallel"
    local deps_file="$tmp_dir/deps"

    # Initialize files
    touch "$phases_file" "$tasks_file" "$parallel_file" "$deps_file"

    # Track phase data
    declare -A phase_tasks
    declare -A phase_stats

    # Function to flush current task to tasks_file
    flush_task() {
        if [ -z "$current_task_id" ]; then
            return
        fi

        local task_json="{\"id\": \"$current_task_id\""
        task_json+=", \"description\": \"$(json_escape "$current_task_desc")\""
        task_json+=", \"status\": \"$current_task_status\""
        task_json+=", \"phase\": ${current_phase_num:-1}"
        [ -n "$current_task_parallel" ] && task_json+=", \"parallel_group\": \"$current_task_parallel\""
        [ -n "$current_task_acceptance" ] && task_json+=", \"acceptance\": \"$(json_escape "$current_task_acceptance")\""
        [ -n "$current_task_files" ] && task_json+=", \"files\": [\"$(echo "$current_task_files" | sed 's/, */", "/g')\"]"
        [ -n "$current_task_notes" ] && task_json+=", \"notes\": \"$(json_escape "$current_task_notes")\""
        [ -n "$current_task_deps" ] && task_json+=", \"depends_on\": [\"$(echo "$current_task_deps" | sed 's/,/", "/g')\"]"
        task_json+="}"

        echo "$current_task_id|$task_json" >> "$tasks_file"

        # Track parallel groups
        if [ -n "$current_task_parallel" ]; then
            echo "$current_task_parallel|$current_task_id" >> "$parallel_file"
        fi

        # Track dependencies
        if [ -n "$current_task_deps" ]; then
            echo "$current_task_id|$current_task_deps" >> "$deps_file"
        fi

        # Update phase task list
        if [ -n "$current_phase_num" ]; then
            if [ -n "${phase_tasks[$current_phase_num]:-}" ]; then
                phase_tasks[$current_phase_num]="${phase_tasks[$current_phase_num]},$current_task_id"
            else
                phase_tasks[$current_phase_num]="$current_task_id"
            fi

            # Update phase stats
            local stats="${phase_stats[$current_phase_num]:-0,0,0}"
            IFS=',' read -r p_total p_complete p_pending <<< "$stats"
            p_total=$((p_total + 1))
            if [ "$current_task_status" = "complete" ] || [ "$current_task_status" = "skipped" ]; then
                p_complete=$((p_complete + 1))
            else
                p_pending=$((p_pending + 1))
            fi
            phase_stats[$current_phase_num]="$p_total,$p_complete,$p_pending"
        fi

        # Track first pending task
        if [ -z "$next_task" ] && [ "$current_task_status" = "pending" ]; then
            next_task="$current_task_id"
        fi

        # Reset task variables
        current_task_id=""
        current_task_desc=""
        current_task_status=""
        current_task_parallel=""
        current_task_deps=""
        current_task_acceptance=""
        current_task_files=""
        current_task_notes=""
        in_task_block=false
    }

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Detect phase header: ### Phase N: Name
        if [[ "$line" =~ ^###[[:space:]]+Phase[[:space:]]+([0-9]+):?[[:space:]]*(.*) ]]; then
            # Flush any pending task before starting new phase
            flush_task

            current_phase_num="${BASH_REMATCH[1]}"
            current_phase_name="${BASH_REMATCH[2]}"
            current_phase_goal=""
            phase_tasks[$current_phase_num]=""
            phase_stats[$current_phase_num]="0,0,0"
            [ "$VERBOSE" = true ] && echo "Found Phase $current_phase_num: $current_phase_name" >&2
            continue
        fi

        # Detect phase goal: **Goal**: ...
        if [[ "$line" =~ ^\*\*Goal\*\*:[[:space:]]*(.*) ]]; then
            current_phase_goal="${BASH_REMATCH[1]}"
            continue
        fi

        # Detect task line - supports two formats:
        # Format 1: "- [ ] Task 2.8: Description"
        # Format 2: "- [ ] **2.8** Description"
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(\[[^]]*\])[[:space:]]*(Task[[:space:]]+)?(\*\*)?([0-9]+\.[0-9]+)(\*\*)?(:[[:space:]]*|[[:space:]]+)(.*) ]]; then
            # Flush previous task before starting new one
            flush_task

            local marker="${BASH_REMATCH[1]}"
            # BASH_REMATCH[2] = "Task " or empty, [3] = first "**" or empty, [4] = task ID, [5] = second "**" or empty, [6] = ": " or " ", [7] = description
            current_task_id="${BASH_REMATCH[4]}"
            local desc="${BASH_REMATCH[7]}"
            current_task_status=$(marker_to_status "$marker")

            # Extract parallel group: [parallel:X]
            if [[ "$desc" =~ \[parallel:([A-Za-z]+)\] ]]; then
                current_task_parallel="${BASH_REMATCH[1]}"
                desc=$(echo "$desc" | sed 's/\[parallel:[A-Za-z]*\]//')
            fi

            # Extract dependencies: [depends:N.M] or [depends:N.M,N.N]
            if [[ "$desc" =~ \[depends:([0-9.,]+)\] ]]; then
                current_task_deps="${BASH_REMATCH[1]}"
                desc=$(echo "$desc" | sed 's/\[depends:[0-9.,]*\]//')
            fi

            # Trim description
            current_task_desc=$(echo "$desc" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            in_task_block=true

            [ "$VERBOSE" = true ] && echo "Found Task $current_task_id: $current_task_desc (status: $current_task_status)" >&2
            continue
        fi

        # Detect task metadata lines (indented under task)
        if [ "$in_task_block" = true ] && [[ "$line" =~ ^[[:space:]]+-[[:space:]]+ ]]; then
            # Acceptance criteria
            if [[ "$line" =~ Acceptance:[[:space:]]*(.*) ]]; then
                current_task_acceptance="${BASH_REMATCH[1]}"
            fi
            # Files
            if [[ "$line" =~ Files:[[:space:]]*(.*) ]]; then
                current_task_files="${BASH_REMATCH[1]}"
                # Clean up backticks
                current_task_files=$(echo "$current_task_files" | sed 's/`//g')
            fi
            # Notes
            if [[ "$line" =~ Notes:[[:space:]]*(.*) ]]; then
                current_task_notes="${BASH_REMATCH[1]}"
            fi
            continue
        fi

        # End task block on non-indented non-empty line (except next section)
        if [ "$in_task_block" = true ] && [[ ! "$line" =~ ^[[:space:]] ]] && [ -n "$line" ] && [[ ! "$line" =~ ^### ]]; then
            flush_task
        fi
    done < "$PLAN_FILE"

    # Flush final task
    flush_task

    # Build phases JSON array
    local phases_json="["
    local first_phase=true
    for pnum in $(echo "${!phase_tasks[@]}" | tr ' ' '\n' | sort -n); do
        local task_ids="${phase_tasks[$pnum]}"
        local stats="${phase_stats[$pnum]:-0,0,0}"
        IFS=',' read -r p_total p_complete p_pending <<< "$stats"

        # Determine phase status
        local p_status="pending"
        if [ "$p_complete" -eq "$p_total" ] && [ "$p_total" -gt 0 ]; then
            p_status="complete"
        elif [ "$p_complete" -gt 0 ] || [ "$p_pending" -lt "$p_total" ]; then
            p_status="in_progress"
        fi

        # Get phase name
        local p_name
        p_name=$(grep -oE "### Phase $pnum:[[:space:]]*.+" "$PLAN_FILE" | head -1 | sed "s/### Phase $pnum:[[:space:]]*//")
        local p_goal
        p_goal=$(grep -A2 "### Phase $pnum" "$PLAN_FILE" | grep -oE "\*\*Goal\*\*:[[:space:]]*.+" | head -1 | sed 's/\*\*Goal\*\*:[[:space:]]*//' || echo "")

        [ "$first_phase" = false ] && phases_json+=", "
        first_phase=false

        phases_json+="{\"number\": $pnum"
        phases_json+=", \"name\": \"$(json_escape "$p_name")\""
        [ -n "$p_goal" ] && phases_json+=", \"goal\": \"$(json_escape "$p_goal")\""
        phases_json+=", \"status\": \"$p_status\""
        phases_json+=", \"task_ids\": [\"$(echo "$task_ids" | sed 's/,/", "/g')\"]"
        phases_json+=", \"stats\": {\"total\": $p_total, \"completed\": $p_complete, \"pending\": $p_pending}}"
    done
    phases_json+="]"

    # Build tasks JSON object
    local tasks_json="{"
    local first_task=true
    while IFS='|' read -r tid tjson; do
        [ -z "$tid" ] && continue
        [ "$first_task" = false ] && tasks_json+=", "
        first_task=false
        tasks_json+="\"$tid\": $tjson"
    done < "$tasks_file"
    tasks_json+="}"

    # Build parallel_groups JSON object
    local parallel_json="{"
    declare -A parallel_map
    while IFS='|' read -r group tid; do
        [ -z "$group" ] && continue
        if [ -n "${parallel_map[$group]:-}" ]; then
            parallel_map[$group]="${parallel_map[$group]},$tid"
        else
            parallel_map[$group]="$tid"
        fi
    done < "$parallel_file"
    local first_group=true
    for g in $(echo "${!parallel_map[@]}" | tr ' ' '\n' | sort); do
        [ "$first_group" = false ] && parallel_json+=", "
        first_group=false
        parallel_json+="\"$g\": [\"$(echo "${parallel_map[$g]}" | sed 's/,/", "/g')\"]"
    done
    parallel_json+="}"

    # Build dependencies JSON object
    local deps_json="{"
    local first_dep=true
    while IFS='|' read -r tid deps; do
        [ -z "$tid" ] && continue
        [ "$first_dep" = false ] && deps_json+=", "
        first_dep=false
        deps_json+="\"$tid\": [\"$(echo "$deps" | sed 's/,/", "/g')\"]"
    done < "$deps_file"
    deps_json+="}"

    # Cleanup
    rm -rf "$tmp_dir"

    # Output
    echo "PHASES:$phases_json"
    echo "TASKS:$tasks_json"
    echo "PARALLEL:$parallel_json"
    echo "DEPS:$deps_json"
    echo "NEXT:$next_task"
}

# Main execution
main() {
    local plan_name
    plan_name=$(get_plan_name)
    local plan_status
    plan_status=$(get_plan_status)
    local created
    created=$(get_created_date)
    local updated
    updated=$(get_updated_timestamp)
    local current_phase
    current_phase=$(get_current_phase)
    local last_sync
    last_sync=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Count tasks
    local counts
    counts=$(count_tasks)
    IFS=',' read -r completed pending in_progress blocked skipped total done_count percentage <<< "$counts"

    # Parse phases and tasks
    local parsed_data
    parsed_data=$(parse_plan)
    local phases_json
    phases_json=$(echo "$parsed_data" | grep "^PHASES:" | sed 's/^PHASES://')
    local tasks_json
    tasks_json=$(echo "$parsed_data" | grep "^TASKS:" | sed 's/^TASKS://')
    local parallel_json
    parallel_json=$(echo "$parsed_data" | grep "^PARALLEL:" | sed 's/^PARALLEL://')
    local deps_json
    deps_json=$(echo "$parsed_data" | grep "^DEPS:" | sed 's/^DEPS://')
    local next_task
    next_task=$(echo "$parsed_data" | grep "^NEXT:" | sed 's/^NEXT://')

    # Build final JSON
    local output_json
    output_json=$(cat <<EOF
{
  "schema_version": "1.0.0",
  "plan_file": "$PLAN_FILE",
  "last_sync": "$last_sync",
  "plan_name": "$(json_escape "$plan_name")",
  "status": "$plan_status",
  "created": "$created",
  "updated": "$updated",
  "current_phase": $current_phase,
  "stats": {
    "total": $total,
    "completed": $completed,
    "pending": $pending,
    "in_progress": $in_progress,
    "blocked": $blocked,
    "skipped": $skipped,
    "done": $done_count,
    "percentage": $percentage
  },
  "phases": $phases_json,
  "tasks": $tasks_json,
  "parallel_groups": $parallel_json,
  "dependencies": $deps_json,
  "next_task": $([ -n "$next_task" ] && echo "\"$next_task\"" || echo "null")
}
EOF
)

    # Pretty-print if jq available, otherwise output raw
    if command -v jq &> /dev/null; then
        echo "$output_json" | jq . > "$OUTPUT_FILE"
    else
        echo "$output_json" > "$OUTPUT_FILE"
    fi

    echo "Synced plan state to: $OUTPUT_FILE" >&2
    if [ "$VERBOSE" = true ]; then
        echo "  Total tasks: $total, Complete: $completed, Pending: $pending" >&2
    fi
}

main
