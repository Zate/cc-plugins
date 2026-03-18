#!/bin/bash
# Nyx Stop hook — memory promotion nudge
# Checks if there's an active dimension with unsaved state

set -euo pipefail

NYX_HOME="${NYX_HOME:-$HOME/.nyx}"

# Stop hooks only support: continue, suppressOutput, stopReason, systemMessage
# No hookSpecificOutput for Stop events.

# Early exit if no nyx home
if [ ! -d "$NYX_HOME/.git" ]; then
    echo '{}'
    exit 0
fi

# Check current branch
CURRENT_BRANCH=$(git -C "$NYX_HOME" branch --show-current 2>/dev/null || echo "")

# Only nudge if on a dimension branch
if [[ "$CURRENT_BRANCH" != dim/* ]]; then
    echo '{}'
    exit 0
fi

CURRENT_DIM="${CURRENT_BRANCH#dim/}"

# Check for uncommitted changes in nyx home
HAS_CHANGES=$(git -C "$NYX_HOME" status --porcelain 2>/dev/null | head -1)

MSG="nyx: dimension $CURRENT_DIM active"
if [ -n "$HAS_CHANGES" ]; then
    MSG="$MSG (uncommitted changes — consider /nyx:prepare)"
fi

if command -v jq &> /dev/null; then
    ESCAPED_MSG=$(printf '%s' "$MSG" | jq -Rs '.')
    cat <<EOF
{
  "systemMessage": ${ESCAPED_MSG}
}
EOF
else
    cat <<EOF
{
  "systemMessage": "$MSG"
}
EOF
fi

exit 0
