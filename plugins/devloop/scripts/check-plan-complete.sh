#!/bin/bash
# check-plan-complete.sh - Check if all plan tasks are complete
#
# Usage:
#   ./check-plan-complete.sh [plan-file]
#
# Output (JSON):
#   {"complete": true/false, "total": N, "done": N, "pending": N, "partial": N}
#
# Exit codes:
#   0 - All tasks complete
#   1 - Tasks still pending
#   2 - No plan file found

set -euo pipefail

PLAN_FILE="${1:-.devloop/plan.md}"

if [ ! -f "$PLAN_FILE" ]; then
    echo '{"error": "no_plan", "message": "Plan file not found"}'
    exit 2
fi

# Count task markers (excluding code blocks)
# - [ ] = pending
# - [x] = completed
# - [~] = partial/in-progress
# - [!] = blocked (also counts as pending)

# Filter out code blocks first, then count tasks
# Task pattern: starts with optional whitespace, then "- [" followed by space, x, ~, or !
filter_code_blocks() {
    awk '
        /^```/ { in_code = !in_code; next }
        !in_code { print }
    ' "$1"
}

# Count only actual task markers: "- [ ]", "- [x]", "- [~]", "- [!]"
TOTAL=$(filter_code_blocks "$PLAN_FILE" | grep -cE "^[[:space:]]*- \[[ x~!]\]" 2>/dev/null) || TOTAL=0
DONE=$(filter_code_blocks "$PLAN_FILE" | grep -cE "^[[:space:]]*- \[x\]" 2>/dev/null) || DONE=0
PARTIAL=$(filter_code_blocks "$PLAN_FILE" | grep -cE "^[[:space:]]*- \[~\]" 2>/dev/null) || PARTIAL=0
BLOCKED=$(filter_code_blocks "$PLAN_FILE" | grep -cE "^[[:space:]]*- \[!\]" 2>/dev/null) || BLOCKED=0

# Pending = Total - Done - Partial - Blocked, but we treat partial/blocked as pending
PENDING=$((TOTAL - DONE))

# Determine if complete
if [ "$TOTAL" -eq 0 ]; then
    COMPLETE="false"
elif [ "$DONE" -eq "$TOTAL" ]; then
    COMPLETE="true"
else
    COMPLETE="false"
fi

# Output JSON
cat <<EOF
{"complete": $COMPLETE, "total": $TOTAL, "done": $DONE, "pending": $PENDING, "partial": $PARTIAL, "blocked": $BLOCKED}
EOF

# Exit code based on completion
if [ "$COMPLETE" = "true" ]; then
    exit 0
else
    exit 1
fi
