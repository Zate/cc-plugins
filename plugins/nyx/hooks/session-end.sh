#!/bin/bash
# Nyx Stop hook — memory promotion nudge
# Checks if there's an active dimension with unsaved state

set -euo pipefail

NYX_HOME="${NYX_HOME:-$HOME/.nyx}"

# JSON helper for no-op output
noop_json() {
    echo '{"suppressOutput":true,"systemMessage":"","hookSpecificOutput":{"hookEventName":"Stop","additionalContext":""}}'
}

# Early exit if no nyx home
if [ ! -d "$NYX_HOME/.git" ]; then
    noop_json
    exit 0
fi

# Check current branch
CURRENT_BRANCH=$(git -C "$NYX_HOME" branch --show-current 2>/dev/null || echo "")

# Only nudge if on a dimension branch
if [[ "$CURRENT_BRANCH" != dim/* ]]; then
    noop_json
    exit 0
fi

CURRENT_DIM="${CURRENT_BRANCH#dim/}"

# Check for uncommitted changes in nyx home
HAS_CHANGES=$(git -C "$NYX_HOME" status --porcelain 2>/dev/null | head -1)

CONTEXT="Active dimension: $CURRENT_DIM."
if [ -n "$HAS_CHANGES" ]; then
    CONTEXT="$CONTEXT Uncommitted changes in Nyx home. Consider running /nyx:prepare before clearing to checkpoint your state."
else
    CONTEXT="$CONTEXT Consider running /nyx:prepare before clearing if decisions were made this session."
fi

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
