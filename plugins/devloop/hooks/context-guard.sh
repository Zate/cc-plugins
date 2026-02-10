#!/bin/bash
# Context Guard - Stop Hook
# Gracefully exits ralph loop when context exceeds threshold
set -euo pipefail

RALPH_STATE=".claude/ralph-loop.local.md"
CONTEXT_FILE=".claude/context-usage.json"
THRESHOLD=70  # Fixed default

# Early exit if no ralph loop active (most common case)
[[ -f "$RALPH_STATE" ]] || exit 0
[[ -f "$CONTEXT_FILE" ]] || exit 0

# Read context percentage
CONTEXT_PCT=$(jq -r '.context_pct // 0' "$CONTEXT_FILE" 2>/dev/null || echo "0")
[[ "$CONTEXT_PCT" =~ ^[0-9]+$ ]] || exit 0

# Check threshold and remove state file if exceeded
if [[ $CONTEXT_PCT -ge $THRESHOLD ]]; then
    echo "Context at ${CONTEXT_PCT}% (threshold: ${THRESHOLD}%). Stopping ralph loop." >&2
    echo "Run /devloop:fresh then /devloop:run to resume." >&2
    rm -f "$RALPH_STATE"
fi
