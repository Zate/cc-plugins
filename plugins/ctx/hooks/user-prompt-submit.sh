#!/bin/bash
# ctx UserPromptSubmit hook
# Proactively query memory based on user prompt keywords
set -euo pipefail

# Read stdin JSON to get the prompt
# Input: {"hook_event_name": "UserPromptSubmit", "input": "..."}
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.input // ""')

if [ -z "$PROMPT" ]; then
    exit 0
fi

# Call ctx binary to find relevant nodes
# Note: ctx prompt-submit handles keyword extraction internally
CTX_OUTPUT=$(ctx hook prompt-submit --prompt="$PROMPT" 2>/dev/null || echo "{}")

# If ctx found nodes, they will be in additionalContext
if echo "$CTX_OUTPUT" | grep -q "additionalContext"; then
    echo "$CTX_OUTPUT"
else
    # Output empty hook response if nothing found
    echo '{"suppressOutput": true}'
fi
