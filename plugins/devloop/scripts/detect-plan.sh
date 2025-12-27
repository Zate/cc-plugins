#!/usr/bin/env bash
#
# detect-plan.sh - Plan file discovery and state detection
#
# Usage: detect-plan.sh [--check-fresh-start] [--check-migration]
#
# Output: JSON with plan info, fresh start state, migration status
#
# This script is sourced by session-start.sh or can be called standalone.

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

# Check for fresh start state from /devloop:fresh
get_fresh_start_state() {
    local state_file=".devloop/next-action.json"

    if [ ! -f "$state_file" ]; then
        echo ""
        return
    fi

    # Parse JSON - prefer jq, fallback to grep/sed
    if command -v jq &> /dev/null; then
        local plan=$(jq -r '.plan // ""' "$state_file" 2>/dev/null || echo "")
        local phase=$(jq -r '.phase // ""' "$state_file" 2>/dev/null || echo "")
        local summary=$(jq -r '.summary // ""' "$state_file" 2>/dev/null || echo "")
        local next_task=$(jq -r '.next_pending // ""' "$state_file" 2>/dev/null || echo "")
    else
        # Fallback: grep/sed parsing
        local plan=$(grep -o '"plan"[[:space:]]*:[[:space:]]*"[^"]*"' "$state_file" 2>/dev/null | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
        local phase=$(grep -o '"phase"[[:space:]]*:[[:space:]]*"[^"]*"' "$state_file" 2>/dev/null | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
        local summary=$(grep -o '"summary"[[:space:]]*:[[:space:]]*"[^"]*"' "$state_file" 2>/dev/null | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
        local next_task=$(grep -o '"next_pending"[[:space:]]*:[[:space:]]*"[^"]*"' "$state_file" 2>/dev/null | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
    fi

    if [ -n "$plan" ] && [ -n "$summary" ]; then
        echo "plan=$plan,phase=$phase,summary=$summary,next=$next_task"
    else
        echo ""
    fi
}

# Validate fresh start state file
# Returns: "valid", "stale:<age_days>", "no_plan", "invalid"
validate_fresh_start_state() {
    local state_file=".devloop/next-action.json"

    if [ ! -f "$state_file" ]; then
        echo "invalid"
        return
    fi

    # Parse timestamp
    local timestamp=""
    if command -v jq &> /dev/null; then
        timestamp=$(jq -r '.timestamp // ""' "$state_file" 2>/dev/null || echo "")
    else
        timestamp=$(grep -o '"timestamp"[[:space:]]*:[[:space:]]*"[^"]*"' "$state_file" 2>/dev/null | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
    fi

    if [ -z "$timestamp" ]; then
        echo "invalid"
        return
    fi

    # Calculate age in days
    local age_days=0
    local state_epoch=0
    local now_epoch=0

    if command -v date &> /dev/null; then
        # Try Linux date format first
        state_epoch=$(date -d "$timestamp" +%s 2>/dev/null || echo "0")

        # If that failed, try macOS date format
        if [ "$state_epoch" -eq 0 ]; then
            state_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$timestamp" +%s 2>/dev/null || echo "0")
        fi

        now_epoch=$(date +%s)

        if [ "$state_epoch" -gt 0 ]; then
            age_days=$(( (now_epoch - state_epoch) / 86400 ))
        fi
    fi

    # Check if state is stale (>7 days)
    if [ "$age_days" -gt 7 ]; then
        echo "stale:$age_days"
        return
    fi

    # Check if plan.md still exists
    if [ ! -f ".devloop/plan.md" ]; then
        echo "no_plan"
        return
    fi

    echo "valid"
}

# Check for existing devloop plan (prefer .devloop/, fallback to .claude/)
get_active_plan() {
    local plan_file=""

    # Prefer new .devloop/ location
    if [ -f ".devloop/plan.md" ]; then
        plan_file=".devloop/plan.md"
    elif [ -f ".claude/devloop-plan.md" ]; then
        # Legacy location fallback
        plan_file=".claude/devloop-plan.md"
    fi

    if [ -n "$plan_file" ]; then
        # Extract plan name from first heading
        local plan_name=$(grep -m1 "^# " "$plan_file" 2>/dev/null | sed 's/^# //' | head -c 50)
        # Count completed vs total tasks
        local total=$(grep -c "^\s*- \[" "$plan_file" 2>/dev/null || echo "0")
        local done=$(grep -c "^\s*- \[x\]" "$plan_file" 2>/dev/null || echo "0")
        if [ -n "$plan_name" ]; then
            echo "name=$plan_name,done=$done,total=$total,file=$plan_file"
            return
        fi
    fi

    # Check for other plan files
    for plan_file in docs/PLAN.md docs/plan.md PLAN.md plan.md; do
        if [ -f "$plan_file" ]; then
            local plan_name=$(grep -m1 "^# " "$plan_file" 2>/dev/null | sed 's/^# //' | head -c 50)
            if [ -n "$plan_name" ]; then
                echo "name=$plan_name,file=$plan_file"
                return
            fi
        fi
    done

    echo ""
}

# Detect if legacy devloop files exist that could be migrated
check_migration_needed() {
    local needs_migration=false

    if [ ! -d ".devloop" ]; then
        if [ -f ".claude/devloop-plan.md" ] || [ -f ".claude/devloop-worklog.md" ] || [ -d ".claude/issues" ] || [ -d ".claude/bugs" ]; then
            needs_migration=true
        fi
    fi

    echo "$needs_migration"
}

# Check for open bugs/issues
get_bug_count() {
    local issues_dir=""
    if [ -d ".devloop/issues" ]; then
        issues_dir=".devloop/issues"
    elif [ -d ".claude/issues" ]; then
        issues_dir=".claude/issues"
    elif [ -d ".claude/bugs" ]; then
        issues_dir=".claude/bugs"
    fi

    if [ -n "$issues_dir" ]; then
        local open=$(grep -l "status: open" "$issues_dir"/*.md 2>/dev/null | wc -l | tr -d ' ' || echo "0")
        if [ "$open" -gt 0 ]; then
            echo "$open"
            return
        fi
    fi
    echo ""
}

# Main execution when called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    CHECK_FRESH_START=false
    CHECK_MIGRATION=false
    OUTPUT_JSON=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --check-fresh-start) CHECK_FRESH_START=true; shift ;;
            --check-migration) CHECK_MIGRATION=true; shift ;;
            --json) OUTPUT_JSON=true; shift ;;
            -h|--help)
                echo "Usage: detect-plan.sh [--check-fresh-start] [--check-migration] [--json]"
                exit 0
                ;;
            *) shift ;;
        esac
    done

    ACTIVE_PLAN=$(get_active_plan)
    FRESH_START=""
    FRESH_START_VALID=""
    MIGRATION_NEEDED=""
    BUG_COUNT=""

    if [ "$CHECK_FRESH_START" = true ] || [ -f ".devloop/next-action.json" ]; then
        FRESH_START=$(get_fresh_start_state)
        FRESH_START_VALID=$(validate_fresh_start_state)
    fi

    if [ "$CHECK_MIGRATION" = true ]; then
        MIGRATION_NEEDED=$(check_migration_needed)
    fi

    BUG_COUNT=$(get_bug_count)

    if [ "$OUTPUT_JSON" = true ]; then
        cat <<EOF
{
  "active_plan": "$ACTIVE_PLAN",
  "fresh_start": "$FRESH_START",
  "fresh_start_valid": "$FRESH_START_VALID",
  "migration_needed": "$MIGRATION_NEEDED",
  "bug_count": "$BUG_COUNT"
}
EOF
    else
        echo "Active Plan: ${ACTIVE_PLAN:-none}"
        [ -n "$FRESH_START" ] && echo "Fresh Start: $FRESH_START (valid: $FRESH_START_VALID)"
        [ -n "$MIGRATION_NEEDED" ] && echo "Migration Needed: $MIGRATION_NEEDED"
        [ -n "$BUG_COUNT" ] && echo "Open Bugs: $BUG_COUNT"
    fi
fi
