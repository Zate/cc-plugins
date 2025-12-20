#!/bin/bash
# Devloop Pre-Commit Hook
# Validates plan sync and runs linting before allowing git commit
#
# This hook checks:
# 1. If a devloop plan exists and is in sync
# 2. If there are completed tasks without Progress Log entries
# 3. If enforcement mode is strict, blocks commits when plan is out of sync
# 4. Runs golangci-lint on staged Go files (if golangci-lint is available)

set -euo pipefail

# Get the tool input (git command) from first argument
TOOL_INPUT="${1:-}"

# Only process git commit commands
if [[ ! "$TOOL_INPUT" =~ "git commit" ]]; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Default values
PLAN_FILE=""
LOCAL_CONFIG=".devloop/local.md"
ENFORCEMENT="advisory"

# Check if devloop plan exists (prefer .devloop/, fallback to .claude/)
if [ -f ".devloop/plan.md" ]; then
    PLAN_FILE=".devloop/plan.md"
    LOCAL_CONFIG=".devloop/local.md"
elif [ -f ".claude/devloop-plan.md" ]; then
    # Legacy location fallback
    PLAN_FILE=".claude/devloop-plan.md"
    LOCAL_CONFIG=".claude/devloop.local.md"
fi

# Read enforcement mode from local config (default: advisory)
if [ -f "$LOCAL_CONFIG" ]; then
    # Parse YAML frontmatter for enforcement setting
    CONFIGURED=$(grep -E "^enforcement:" "$LOCAL_CONFIG" 2>/dev/null | sed 's/enforcement:[[:space:]]*//' | tr -d ' ' || true)
    if [ -n "$CONFIGURED" ]; then
        ENFORCEMENT="$CONFIGURED"
    fi
fi

# ============================================
# Plan Sync Check (only if plan file exists)
# ============================================
if [ -z "$PLAN_FILE" ]; then
    # No plan file, skip plan sync checks
    : # no-op, continue to linting
else

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
  "message": "Plan sync required: $DIFF completed task(s) may not have Progress Log entries. Update $PLAN_FILE before committing. Set enforcement: advisory in $LOCAL_CONFIG to allow override."
}
EOF
        exit 0
    else
        # In advisory mode, warn but allow
        cat <<EOF
{
  "decision": "warn",
  "message": "Plan may be out of sync: $DIFF completed task(s) without matching Progress Log entries. Consider updating $PLAN_FILE."
}
EOF
        exit 0
    fi
fi
# End of plan file check block

fi  # End of "if [ -z "$PLAN_FILE" ]" else block

# ============================================
# Go Linting Check (if golangci-lint is available AND this is a Go project)
# ============================================

# Check if golangci-lint is installed AND this is a Go project (has go.mod)
if command -v golangci-lint &> /dev/null && [ -f "go.mod" ]; then
    # Get staged Go files
    STAGED_GO_FILES=$(git diff --cached --name-only --diff-filter=ACMR | grep '\.go$' || true)

    if [ -n "$STAGED_GO_FILES" ]; then
        # Run golangci-lint on staged files
        # Use --fast for quick feedback, --new-from-rev to only check staged changes
        LINT_OUTPUT=""
        LINT_FAILED=false

        for file in $STAGED_GO_FILES; do
            if [ -f "$file" ]; then
                FILE_DIR=$(dirname "$file")
                FILE_NAME=$(basename "$file")

                # Run lint on the specific file
                FILE_LINT=$(cd "$FILE_DIR" && golangci-lint run --fast "$FILE_NAME" 2>&1 || true)

                if [ -n "$FILE_LINT" ]; then
                    LINT_OUTPUT="${LINT_OUTPUT}${FILE_LINT}\n"
                    LINT_FAILED=true
                fi
            fi
        done

        if [ "$LINT_FAILED" = true ]; then
            # Count issues
            ISSUE_COUNT=$(echo -e "$LINT_OUTPUT" | grep -c '\.go:' || echo "0")

            if [ "$ENFORCEMENT" = "strict" ]; then
                # In strict mode, block the commit
                cat <<EOF
{
  "decision": "block",
  "message": "golangci-lint: $ISSUE_COUNT issue(s) found in staged Go files. Fix before committing or set enforcement: advisory in $LOCAL_CONFIG"
}
EOF
                exit 0
            else
                # In advisory mode, warn but allow
                cat <<EOF
{
  "decision": "warn",
  "message": "golangci-lint: $ISSUE_COUNT issue(s) in staged Go files. Consider fixing before push."
}
EOF
                exit 0
            fi
        fi
    fi
fi

# All checks passed
echo '{"decision": "approve"}'
exit 0
