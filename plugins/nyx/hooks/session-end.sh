#!/bin/bash
set -euo pipefail

NYX_DIR="$HOME/.claude/nyx"
DIM_DIR="$NYX_DIR/dimensions"
CURRENT_FILE="$NYX_DIR/current"

# Early exit if no nyx setup
if [ ! -d "$DIM_DIR" ]; then
    echo '{"suppressOutput":true,"systemMessage":"","hookSpecificOutput":{"hookEventName":"Stop","additionalContext":""}}'
    exit 0
fi

# Check for active dimension
CURRENT=""
if [ -f "$CURRENT_FILE" ]; then
    CURRENT=$(cat "$CURRENT_FILE" 2>/dev/null | tr -d '[:space:]')
fi

# If no active dimension, no-op
if [ -z "$CURRENT" ]; then
    echo '{"suppressOutput":true,"systemMessage":"","hookSpecificOutput":{"hookEventName":"Stop","additionalContext":""}}'
    exit 0
fi

# Check if dimension state file exists
if [ ! -f "$DIM_DIR/$CURRENT.md" ]; then
    echo '{"suppressOutput":true,"systemMessage":"","hookSpecificOutput":{"hookEventName":"Stop","additionalContext":""}}'
    exit 0
fi

# Output reminder
CONTEXT="Active dimension: $CURRENT. Consider running /nyx:prepare before clearing to checkpoint your state."

if command -v jq &> /dev/null; then
    ESCAPED_CONTEXT=$(printf '%s' "$CONTEXT" | jq -Rs '.')
    cat <<EOF
{
  "suppressOutput": true,
  "systemMessage": "nyx: session ending",
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": ${ESCAPED_CONTEXT}
  }
}
EOF
else
    cat <<EOF
{
  "suppressOutput": true,
  "systemMessage": "nyx: session ending",
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "$CONTEXT"
  }
}
EOF
fi

exit 0
