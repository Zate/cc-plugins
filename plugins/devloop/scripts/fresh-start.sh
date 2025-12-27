#!/usr/bin/env bash
#
# fresh-start.sh - Save plan state for fresh context restart
#
# Usage: fresh-start.sh [plan-file]
#
# Reads the devloop plan and saves the current state to .devloop/next-action.json
# This allows resuming work after clearing conversation context.
#
# Dependencies: None (pure bash)
# Outputs: .devloop/next-action.json
# Exit codes: 0=success, 1=no plan found, 2=invalid plan

set -euo pipefail

# Find and change to project root (directory containing .devloop/ or .git/)
find_project_root() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.devloop" ] || [ -d "$dir/.git" ]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    # Fallback to current directory
    echo "$PWD"
    return 1
}

# Change to project root
PROJECT_ROOT=$(find_project_root)
cd "$PROJECT_ROOT" || exit 1

# Color output helpers
if [ -t 1 ]; then
    BOLD='\033[1m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    RED='\033[0;31m'
    RESET='\033[0m'
else
    BOLD=''
    GREEN=''
    YELLOW=''
    RED=''
    RESET=''
fi

# Helper functions
log_info() {
    echo -e "${GREEN}✓${RESET} $*"
}

log_warn() {
    echo -e "${YELLOW}⚠${RESET} $*"
}

log_error() {
    echo -e "${RED}✗${RESET} $*" >&2
}

# Escape string for JSON
json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    echo "$s"
}

# Find plan file in standard locations
find_plan_file() {
    local candidates=(
        ".devloop/plan.md"
        "docs/PLAN.md"
        "PLAN.md"
    )

    for candidate in "${candidates[@]}"; do
        if [ -f "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

# Extract plan name from first # heading
get_plan_name() {
    local plan_file="$1"
    grep -m1 "^# " "$plan_file" 2>/dev/null | sed 's/^# //' | sed 's/^Devloop Plan: //' | head -c 200 || echo "Unknown Plan"
}

# Extract current phase from metadata or inferred from tasks
get_current_phase() {
    local plan_file="$1"

    # Try to extract from **Current Phase**: metadata
    local phase
    phase=$(grep -m1 '^\*\*Current Phase\*\*:' "$plan_file" 2>/dev/null | sed 's/^\*\*Current Phase\*\*:[[:space:]]*//' | sed 's/Phase //' | head -c 100)

    if [ -z "$phase" ]; then
        # Fallback: Find the phase heading before the first pending task
        local first_pending_line
        first_pending_line=$(grep -n -m1 -E '^\s*-\s*\[\s\]' "$plan_file" 2>/dev/null | cut -d: -f1)

        if [ -n "$first_pending_line" ]; then
            phase=$(head -n "$first_pending_line" "$plan_file" | grep -oE '###[[:space:]]+Phase[[:space:]]+[0-9]+:[[:space:]]*.+' | tail -1 | sed 's/###[[:space:]]*//' || echo "")
        fi
    fi

    [ -z "$phase" ] && phase="Phase 1"
    echo "$phase"
}

# Count tasks by marker
count_tasks() {
    local plan_file="$1"

    # Use simpler pattern: - [marker]
    local completed=$(grep -cE '^-[[:space:]]*\[[xX]\]' "$plan_file" 2>/dev/null || echo "0")
    local pending=$(grep -cE '^-[[:space:]]*\[[[:space:]]\]' "$plan_file" 2>/dev/null || echo "0")
    local in_progress=$(grep -cE '^-[[:space:]]*\[~\]' "$plan_file" 2>/dev/null || echo "0")
    local blocked=$(grep -cE '^-[[:space:]]*\[!\]' "$plan_file" 2>/dev/null || echo "0")
    local skipped=$(grep -cE '^-[[:space:]]*\[-\]' "$plan_file" 2>/dev/null || echo "0")

    # Strip any whitespace and ensure numeric
    completed=$(echo "$completed" | tr -d '[:space:]')
    pending=$(echo "$pending" | tr -d '[:space:]')
    in_progress=$(echo "$in_progress" | tr -d '[:space:]')
    blocked=$(echo "$blocked" | tr -d '[:space:]')
    skipped=$(echo "$skipped" | tr -d '[:space:]')

    # Ensure all are valid numbers
    completed=${completed:-0}
    pending=${pending:-0}
    in_progress=${in_progress:-0}
    blocked=${blocked:-0}
    skipped=${skipped:-0}

    # Total includes all task markers
    local total=$((completed + pending + in_progress + blocked + skipped))

    echo "$completed,$pending,$total"
}

# Find last completed task (last line with [x])
get_last_completed() {
    local plan_file="$1"

    # Look for pattern: - [x] Task N.M: Description
    local task_line
    task_line=$(grep -E '^-[[:space:]]*\[[xX]\]' "$plan_file" 2>/dev/null | tail -1)

    if [ -z "$task_line" ]; then
        echo ""
        return
    fi

    # Extract Task N.M and description up to first bracket or marker
    local task
    if [[ "$task_line" =~ Task[[:space:]]+([0-9]+\.[0-9]+):[[:space:]]*([^\[]*) ]]; then
        local task_id="${BASH_REMATCH[1]}"
        local task_desc="${BASH_REMATCH[2]}"
        # Trim trailing whitespace
        task_desc=$(echo "$task_desc" | sed 's/[[:space:]]*$//')
        task="Task $task_id: $task_desc"
    else
        # Fallback: just get everything after the marker
        task=$(echo "$task_line" | sed 's/^-[[:space:]]*\[[xX]\][[:space:]]*//' | head -c 200)
    fi

    echo "$task"
}

# Find next pending task (first line with [ ])
get_next_pending() {
    local plan_file="$1"

    # Look for pattern: - [ ] Task N.M: Description
    local task_line
    task_line=$(grep -m1 -E '^-[[:space:]]*\[[[:space:]]\]' "$plan_file" 2>/dev/null)

    if [ -z "$task_line" ]; then
        echo ""
        return
    fi

    # Extract Task N.M and description up to first bracket or marker
    local task
    if [[ "$task_line" =~ Task[[:space:]]+([0-9]+\.[0-9]+):[[:space:]]*([^\[]*) ]]; then
        local task_id="${BASH_REMATCH[1]}"
        local task_desc="${BASH_REMATCH[2]}"
        # Trim trailing whitespace
        task_desc=$(echo "$task_desc" | sed 's/[[:space:]]*$//')
        task="Task $task_id: $task_desc"
    else
        # Fallback: just get everything after the marker
        task=$(echo "$task_line" | sed 's/^-[[:space:]]*\[[[:space:]]\][[:space:]]*//' | head -c 200)
    fi

    echo "$task"
}

# Generate progress summary
generate_summary() {
    local completed="$1"
    local total="$2"
    local phase="$3"
    local last_completed="$4"

    local percentage=0
    if [ "$total" -gt 0 ]; then
        percentage=$((completed * 100 / total))
    fi

    local summary="Completed $completed of $total tasks ($percentage%)."

    # Add current phase
    [ -n "$phase" ] && summary="$summary Current phase: $phase."

    # Add last completed if available
    [ -n "$last_completed" ] && summary="$summary Last completed: $last_completed."

    # Truncate to 200 chars
    echo "$summary" | head -c 200
}

# Main execution
main() {
    local plan_file=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                cat <<EOF
Usage: fresh-start.sh [plan-file]

Save current devloop plan state to .devloop/next-action.json for resuming
work after clearing conversation context.

Options:
  -h, --help     Show this help message

Default plan file discovery order:
  1. .devloop/plan.md
  2. docs/PLAN.md
  3. PLAN.md

Exit codes:
  0 - Success (state saved)
  1 - No plan found
  2 - Invalid plan (no tasks)
EOF
                exit 0
                ;;
            *)
                plan_file="$1"
                shift
                ;;
        esac
    done

    # Find plan file if not specified
    if [ -z "$plan_file" ]; then
        if ! plan_file=$(find_plan_file); then
            log_error "No plan file found"
            echo ""
            echo "Checked locations:"
            echo "  - .devloop/plan.md"
            echo "  - docs/PLAN.md"
            echo "  - PLAN.md"
            echo ""
            echo "Tip: Create a plan with /devloop or specify a plan file explicitly"
            exit 1
        fi
    fi

    # Verify plan file exists
    if [ ! -f "$plan_file" ]; then
        log_error "Plan file not found: $plan_file"
        exit 1
    fi

    # Extract plan information
    local plan_name
    plan_name=$(get_plan_name "$plan_file")

    local current_phase
    current_phase=$(get_current_phase "$plan_file")

    local counts
    counts=$(count_tasks "$plan_file")
    IFS=',' read -r completed pending total <<< "$counts"

    # Check if plan has tasks
    if [ "$total" -eq 0 ]; then
        log_error "Plan has no tasks"
        echo ""
        echo "The plan file exists but contains no task markers."
        echo "Add tasks to the plan before using fresh start."
        exit 2
    fi

    local last_completed
    last_completed=$(get_last_completed "$plan_file")

    local next_pending
    next_pending=$(get_next_pending "$plan_file")

    # Check if plan is complete
    if [ "$pending" -eq 0 ] && [ "$completed" -eq "$total" ]; then
        log_warn "All tasks are complete"
        echo ""
        echo "Consider using /devloop:ship to finalize the feature instead."
        echo ""
        echo "Fresh start state will be saved anyway for reference."
    fi

    # Generate summary
    local summary
    summary=$(generate_summary "$completed" "$total" "$current_phase" "$last_completed")

    # Create timestamp in ISO 8601 format
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Build JSON output
    local output_file=".devloop/next-action.json"
    local json_content
    json_content=$(cat <<EOF
{
  "timestamp": "$timestamp",
  "plan": "$(json_escape "$plan_name")",
  "phase": "$(json_escape "$current_phase")",
  "total_tasks": $((total)),
  "completed_tasks": $((completed)),
  "pending_tasks": $((pending)),
  "last_completed": $([ -n "$last_completed" ] && echo "\"$(json_escape "$last_completed")\"" || echo "null"),
  "next_pending": $([ -n "$next_pending" ] && echo "\"$(json_escape "$next_pending")\"" || echo "null"),
  "summary": "$(json_escape "$summary")",
  "reason": "fresh_start"
}
EOF
)

    # Ensure .devloop directory exists
    mkdir -p .devloop

    # Write to file
    echo "$json_content" > "$output_file"

    # Calculate completion percentage (force numeric)
    local completion_pct=0
    if [ "$total" -gt 0 ]; then
        completion_pct=$((completed * 100 / total))
    fi

    # Display success message
    echo ""
    echo -e "${BOLD}## Fresh Start State Saved ✓${RESET}"
    echo ""
    echo "Your devloop progress has been saved to \`.devloop/next-action.json\`."
    echo ""
    echo -e "${BOLD}### Current Progress${RESET}"
    echo -e "${BOLD}Plan${RESET}: $plan_name"
    echo -e "${BOLD}Phase${RESET}: $current_phase"
    echo -e "${BOLD}Completed${RESET}: $((completed))/$((total)) tasks ($((completion_pct))%)"
    echo ""

    if [ -n "$last_completed" ]; then
        echo -e "${BOLD}Last completed${RESET}: $last_completed"
    fi

    if [ -n "$next_pending" ]; then
        echo -e "${BOLD}Next up${RESET}: $next_pending"
    else
        echo -e "${BOLD}Next up${RESET}: All tasks complete!"
    fi

    echo ""
    echo -e "${BOLD}### To Resume with Fresh Context${RESET}"
    echo ""
    echo "1. ${BOLD}Clear context${RESET}: Run \`/clear\` to reset conversation"
    echo "2. ${BOLD}Resume work${RESET}: Run \`/devloop:continue\` to pick up where you left off"
    echo ""
    echo "The saved state will be automatically detected on your next session."
    echo ""
    echo -e "${BOLD}### Alternative: Dismiss State${RESET}"
    echo ""
    echo "If you change your mind, delete the state file:"
    echo "\`\`\`bash"
    echo "rm .devloop/next-action.json"
    echo "\`\`\`"
    echo ""
    echo "---"
    echo ""
    echo "${BOLD}Tip${RESET}: Fresh starts are useful after completing 5-10 tasks or when context feels heavy."

    log_info "State saved to: $output_file"
    exit 0
}

main "$@"
