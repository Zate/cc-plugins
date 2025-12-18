#!/bin/bash
# Devloop Pre-Commit Hook
# Validates that the plan file is updated before allowing git commit
#
# This hook checks:
# 1. If a devloop plan exists
# 2. If there are completed tasks without Progress Log entries
# 3. If enforcement mode is strict, blocks commits when plan is out of sync

set -euo pipefail

# Get the tool input (git command) from first argument
TOOL_INPUT="${1:-}"

# Only process git commit commands
if [[ ! "$TOOL_INPUT" =~ "git commit" ]]; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Check if devloop plan exists
PLAN_FILE=".claude/devloop-plan.md"
LOCAL_CONFIG=".claude/devloop.local.md"

if [ ! -f "$PLAN_FILE" ]; then
    # No plan file = no enforcement needed
    echo '{"decision": "approve"}'
    exit 0
fi

# Read enforcement mode from local config (default: advisory)
ENFORCEMENT="advisory"
if [ -f "$LOCAL_CONFIG" ]; then
    # Parse YAML frontmatter for enforcement setting
    CONFIGURED=$(grep -E "^enforcement:" "$LOCAL_CONFIG" 2>/dev/null | sed 's/enforcement:[[:space:]]*//' | tr -d ' ' || true)
    if [ -n "$CONFIGURED" ]; then
        ENFORCEMENT="$CONFIGURED"
    fi
fi

# Check for completed tasks that might not be logged
# Look for [x] tasks and compare with Progress Log entries
COMPLETED_TASKS=$(grep -E "^\s*-\s*\[x\]" "$PLAN_FILE" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
PROGRESS_ENTRIES=$(grep -E "^-\s*[0-9]{4}-[0-9]{2}-[0-9]{2}.*Completed" "$PLAN_FILE" 2>/dev/null | wc -l | tr -d ' ' || echo "0")

# Get last update timestamp from plan
LAST_UPDATED=$(grep -E "^\*\*Updated\*\*:" "$PLAN_FILE" 2>/dev/null | head -1 | sed 's/.*: *//' || echo "")

# Check if plan was updated recently (within last 10 minutes)
# This is a heuristic - if Updated timestamp is recent, assume plan is in sync
PLAN_RECENTLY_UPDATED=false
if [ -n "$LAST_UPDATED" ]; then
    # Parse the timestamp (format: YYYY-MM-DD HH:MM)
    PLAN_EPOCH=$(date -j -f "%Y-%m-%d %H:%M" "$LAST_UPDATED" "+%s" 2>/dev/null || echo "0")
    CURRENT_EPOCH=$(date "+%s")
    DIFF=$((CURRENT_EPOCH - PLAN_EPOCH))

    # 10 minutes = 600 seconds
    if [ "$DIFF" -lt 600 ] && [ "$DIFF" -ge 0 ]; then
        PLAN_RECENTLY_UPDATED=true
    fi
fi

# If plan was recently updated, approve
if [ "$PLAN_RECENTLY_UPDATED" = true ]; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Warning case: completed tasks significantly exceed progress entries
# This might indicate tasks were marked complete but not logged
if [ "$COMPLETED_TASKS" -gt "$PROGRESS_ENTRIES" ]; then
    DIFF=$((COMPLETED_TASKS - PROGRESS_ENTRIES))

    if [ "$ENFORCEMENT" = "strict" ]; then
        # In strict mode, block the commit
        cat <<EOF
{
  "decision": "block",
  "message": "Plan sync required: $DIFF completed task(s) may not have Progress Log entries. Update .claude/devloop-plan.md before committing. Set enforcement: advisory in .claude/devloop.local.md to allow override."
}
EOF
        exit 0
    else
        # In advisory mode, warn but allow
        cat <<EOF
{
  "decision": "warn",
  "message": "Plan may be out of sync: $DIFF completed task(s) without matching Progress Log entries. Consider updating .claude/devloop-plan.md."
}
EOF
        exit 0
    fi
fi

# All checks passed
echo '{"decision": "approve"}'
exit 0
