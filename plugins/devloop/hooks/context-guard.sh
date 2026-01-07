#!/bin/bash

# Devloop Context Guard - Stop Hook
# Monitors context usage and gracefully exits ralph loop when threshold exceeded
#
# This hook runs on Stop events and checks:
# 1. Is ralph-loop active? (state file exists)
# 2. Is context usage above threshold?
# If both true, removes ralph state file so ralph-loop's hook will allow exit

set -euo pipefail

# Default threshold (can be overridden in .devloop/local.md)
DEFAULT_THRESHOLD=70

RALPH_STATE_FILE=".claude/ralph-loop.local.md"
CONTEXT_FILE=".claude/context-usage.json"
LOCAL_CONFIG=".devloop/local.md"

# If no ralph loop active, nothing to do
if [[ ! -f "$RALPH_STATE_FILE" ]]; then
    exit 0
fi

# If no context file, statusline hasn't run yet - continue
if [[ ! -f "$CONTEXT_FILE" ]]; then
    exit 0
fi

# Read threshold from local config if available
THRESHOLD=$DEFAULT_THRESHOLD
if [[ -f "$LOCAL_CONFIG" ]]; then
    # Parse YAML frontmatter for context_threshold
    CONFIG_THRESHOLD=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$LOCAL_CONFIG" | grep '^context_threshold:' | sed 's/context_threshold: *//' || echo "")
    if [[ "$CONFIG_THRESHOLD" =~ ^[0-9]+$ ]]; then
        THRESHOLD=$CONFIG_THRESHOLD
    fi
fi

# Read current context percentage
CONTEXT_PCT=$(jq -r '.context_pct // 0' "$CONTEXT_FILE" 2>/dev/null || echo "0")

# Validate it's a number
if [[ ! "$CONTEXT_PCT" =~ ^[0-9]+$ ]]; then
    exit 0
fi

# Check if context exceeds threshold
if [[ $CONTEXT_PCT -ge $THRESHOLD ]]; then
    echo "⚠️  Context usage at ${CONTEXT_PCT}% (threshold: ${THRESHOLD}%)" >&2
    echo "   Gracefully stopping ralph loop to preserve context quality." >&2
    echo "" >&2
    echo "   Run /devloop:fresh then /devloop:continue to resume with fresh context." >&2

    # Remove ralph state file - ralph-loop's hook will then allow exit
    rm -f "$RALPH_STATE_FILE"
fi

exit 0
