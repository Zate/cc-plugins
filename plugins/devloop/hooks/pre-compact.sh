#!/bin/bash
# Devloop PreCompact hook
# Injects current plan status into the summarization context
set -euo pipefail

PLAN_FILE=".devloop/plan.md"

if [ -f "$PLAN_FILE" ]; then
    # Extract current phase and pending tasks
    STATUS=$(grep -m 1 "^# " "$PLAN_FILE" || echo "Active Plan")
    TASKS=$(grep "^- \[ \]" "$PLAN_FILE" | head -n 5)
    
    CONTEXT="IMPORTANT for summary: Current Devloop Plan is active.
$STATUS
Pending tasks:
$TASKS"

    cat <<EOF
{
  "suppressOutput": true,
  "systemMessage": "devloop: plan preserved for compact",
  "hookSpecificOutput": {
    "hookEventName": "PreCompact",
    "additionalContext": "$CONTEXT"
  }
}
EOF
else
    echo '{"suppressOutput": true}'
fi
