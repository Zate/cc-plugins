#!/bin/bash
# check-devloop-state.sh - Detect current devloop state for smart command routing
#
# Usage:
#   ./check-devloop-state.sh
#
# Output (JSON):
#   {
#     "state": "active_plan|uncommitted|clean|not_setup",
#     "priority": 1-7,
#     "details": { ... state-specific details ... },
#     "suggestions": ["suggestion1", "suggestion2", ...]
#   }
#
# States (in priority order):
#   1. not_setup     - .devloop/ doesn't exist
#   2. active_plan   - Plan with pending tasks
#   3. uncommitted   - Git changes detected
#   4. open_bugs     - Bug issues in .devloop/issues/
#   5. backlog       - Features/tasks in backlog
#   6. complete_plan - Plan exists but all done
#   7. clean         - Everything done, ready for new work

set -euo pipefail

# Get script directory for calling sibling scripts
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Initialize result
STATE="clean"
PRIORITY=7
DETAILS="{}"
SUGGESTIONS="[]"

# Helper to build JSON array
json_array() {
    local items=("$@")
    local result="["
    local first=true
    for item in "${items[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            result+=","
        fi
        result+="\"$item\""
    done
    result+="]"
    echo "$result"
}

# Check 1: Is devloop set up?
if [ ! -d ".devloop" ]; then
    STATE="not_setup"
    PRIORITY=1
    DETAILS='{"message": "No .devloop directory found"}'
    SUGGESTIONS=$(json_array "Set up devloop" "Create first spike" "Start new task")
else
    # Check 2: Is there an active plan with pending tasks?
    if [ -f ".devloop/plan.md" ]; then
        # Run plan check - exit code 1 means pending tasks (not an error)
        PLAN_STATUS=$("$SCRIPT_DIR/check-plan-complete.sh" .devloop/plan.md 2>/dev/null) || true
        if [ -z "$PLAN_STATUS" ] || echo "$PLAN_STATUS" | grep -q '"error"'; then
            PLAN_STATUS='{"complete": false, "total": 0, "done": 0, "pending": 0}'
        fi
        PLAN_COMPLETE=$(echo "$PLAN_STATUS" | grep -o '"complete": *[^,}]*' | cut -d: -f2 | tr -d ' ')
        PLAN_TOTAL=$(echo "$PLAN_STATUS" | grep -o '"total": *[0-9]*' | cut -d: -f2 | tr -d ' ')
        PLAN_DONE=$(echo "$PLAN_STATUS" | grep -o '"done": *[0-9]*' | cut -d: -f2 | tr -d ' ')
        PLAN_PENDING=$(echo "$PLAN_STATUS" | grep -o '"pending": *[0-9]*' | cut -d: -f2 | tr -d ' ')

        # Get plan title
        PLAN_TITLE=$(head -1 .devloop/plan.md | sed 's/^# //' | sed 's/^Devloop Plan: //')

        # Get next task
        NEXT_TASK=$(grep -m1 '^\s*- \[ \]' .devloop/plan.md 2>/dev/null | sed 's/^[[:space:]]*- \[ \] //' || echo "")

        if [ "$PLAN_COMPLETE" = "false" ] && [ "$PLAN_TOTAL" -gt 0 ]; then
            STATE="active_plan"
            PRIORITY=2
            DETAILS="{\"plan_title\": \"$PLAN_TITLE\", \"total\": $PLAN_TOTAL, \"done\": $PLAN_DONE, \"pending\": $PLAN_PENDING, \"next_task\": \"$NEXT_TASK\"}"
            SUGGESTIONS=$(json_array "Continue plan" "Ship current progress" "View plan" "Start fresh")
        elif [ "$PLAN_COMPLETE" = "true" ]; then
            STATE="complete_plan"
            PRIORITY=6
            DETAILS="{\"plan_title\": \"$PLAN_TITLE\", \"total\": $PLAN_TOTAL}"
            SUGGESTIONS=$(json_array "Archive and start new" "Ship completed work" "Review before shipping")
        fi
    fi

    # Check 3: Uncommitted git changes (only if not active plan)
    if [ "$STATE" = "clean" ] || [ "$STATE" = "complete_plan" ]; then
        if command -v git &> /dev/null && git rev-parse --git-dir &> /dev/null; then
            GIT_CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            if [ "$GIT_CHANGES" -gt 0 ]; then
                STAGED=$(git diff --cached --stat 2>/dev/null | tail -1 | grep -oE '[0-9]+ file' | cut -d' ' -f1 || echo "0")
                UNSTAGED=$(git diff --stat 2>/dev/null | tail -1 | grep -oE '[0-9]+ file' | cut -d' ' -f1 || echo "0")

                if [ "$STATE" != "active_plan" ]; then
                    STATE="uncommitted"
                    PRIORITY=3
                    DETAILS="{\"total_changes\": $GIT_CHANGES, \"staged\": \"$STAGED\", \"unstaged\": \"$UNSTAGED\"}"
                    SUGGESTIONS=$(json_array "Commit changes" "Review changes" "Start new work" "Stash and continue")
                fi
            fi
        fi
    fi

    # Check 4: Open bugs in issues (only if clean state)
    if [ "$STATE" = "clean" ] && [ -d ".devloop/issues" ]; then
        BUG_COUNT=$(grep -l 'type: bug' .devloop/issues/*.md 2>/dev/null | xargs -I{} grep -l 'status: open' {} 2>/dev/null | wc -l | tr -d ' ') || BUG_COUNT=0
        if [ "$BUG_COUNT" -gt 0 ]; then
            STATE="open_bugs"
            PRIORITY=4
            DETAILS="{\"bug_count\": $BUG_COUNT}"
            SUGGESTIONS=$(json_array "Fix a bug" "View open bugs" "Start new feature" "Create spike")
        fi
    fi

    # Check 5: Features in backlog (only if still clean)
    if [ "$STATE" = "clean" ] && [ -d ".devloop/issues" ]; then
        FEATURE_COUNT=$(grep -l 'type: feature' .devloop/issues/*.md 2>/dev/null | xargs -I{} grep -l 'status: open' {} 2>/dev/null | wc -l | tr -d ' ') || FEATURE_COUNT=0
        if [ "$FEATURE_COUNT" -gt 0 ]; then
            STATE="backlog"
            PRIORITY=5
            DETAILS="{\"feature_count\": $FEATURE_COUNT}"
            SUGGESTIONS=$(json_array "Work on backlog item" "View backlog" "Create new spike" "Start fresh task")
        fi
    fi
fi

# If still clean, set default suggestions
if [ "$STATE" = "clean" ]; then
    DETAILS='{"message": "Ready for new work"}'
    SUGGESTIONS=$(json_array "Start new spike" "Create new issue" "View GitHub issues" "Quick task")
fi

# Output summary line then full JSON
echo "devloop: state=$STATE priority=$PRIORITY"
cat <<EOF
{
  "state": "$STATE",
  "priority": $PRIORITY,
  "details": $DETAILS,
  "suggestions": $SUGGESTIONS
}
EOF
