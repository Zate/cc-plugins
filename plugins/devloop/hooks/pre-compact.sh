#!/bin/bash
# pre-compact.sh — Inject devloop plan state into compaction custom instructions.
# PreCompact hooks: stdout is captured and merged into compaction customInstructions.
# Output plain text only — no JSON wrapper.
set -euo pipefail

PLAN_FILE=".devloop/plan.md"

if [ ! -f "$PLAN_FILE" ]; then
    exit 0
fi

TITLE=$(grep -m 1 "^# " "$PLAN_FILE" 2>/dev/null || echo "Active Plan")
PENDING=$(grep "^- \[ \]" "$PLAN_FILE" 2>/dev/null | head -n 5)

if [ -z "$PENDING" ]; then
    exit 0
fi

echo "IMPORTANT: A devloop plan is active. Preserve its state in your summary."
echo "$TITLE"
echo "Pending tasks:"
echo "$PENDING"
