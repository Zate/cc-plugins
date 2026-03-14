#!/bin/bash
# Context Guard - Stop Hook
# Gracefully exits ralph loop when context exceeds threshold
set -euo pipefail

RALPH_STATE=".claude/ralph-loop.local.md"
CONTEXT_FILE=".claude/context-usage.json"
LOCAL_CONFIG=".devloop/local.md"
THRESHOLD=70  # Default

# Early exit if no ralph loop active (most common case)
[[ -f "$RALPH_STATE" ]] || exit 0
[[ -f "$CONTEXT_FILE" ]] || exit 0

# Read threshold from local config if available
if [[ -f "$LOCAL_CONFIG" ]]; then
    CONFIG_THRESHOLD=$(grep -oP 'context_threshold:\s*\K[0-9]+' "$LOCAL_CONFIG" 2>/dev/null || true)
    [[ -n "$CONFIG_THRESHOLD" ]] && THRESHOLD="$CONFIG_THRESHOLD"
fi

# Read context percentage
CONTEXT_PCT=$(jq -r '.context_pct // 0' "$CONTEXT_FILE" 2>/dev/null || echo "0")
[[ "$CONTEXT_PCT" =~ ^[0-9]+$ ]] || exit 0

# Check threshold and remove state file if exceeded
if [[ $CONTEXT_PCT -ge $THRESHOLD ]]; then
    echo "Context at ${CONTEXT_PCT}% (threshold: ${THRESHOLD}%). Stopping ralph loop." >&2
    echo "Run /devloop:fresh then /devloop:run to resume." >&2
    rm -f "$RALPH_STATE"
fi
