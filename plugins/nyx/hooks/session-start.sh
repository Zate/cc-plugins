#!/bin/bash
# Nyx SessionStart hook — bootstrap orientation
# Reads dimension state from git branches in ~/.nyx/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
NYX_HOME="${NYX_HOME:-$HOME/.nyx}"

# JSON helper for no-op output
noop_json() {
    cat <<'NOOP'
{
  "suppressOutput": true,
  "systemMessage": "",
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": ""
  }
}
NOOP
}

# Early exit if nyx home doesn't exist
if [ ! -d "$NYX_HOME/.git" ]; then
    noop_json
    exit 0
fi

# Get current branch (dimension)
CURRENT_BRANCH=$(git -C "$NYX_HOME" branch --show-current 2>/dev/null || echo "")
CURRENT_DIM=""
if [[ "$CURRENT_BRANCH" == dim/* ]]; then
    CURRENT_DIM="${CURRENT_BRANCH#dim/}"
fi

# Count active dimensions
DIM_COUNT=$(git -C "$NYX_HOME" branch --list 'dim/*' 2>/dev/null | wc -l | tr -d '[:space:]')

# Read current dimension's active focus
FOCUS=""
if [ -n "$CURRENT_DIM" ] && [ -f "$NYX_HOME/dimensions/$CURRENT_DIM.md" ]; then
    FOCUS=$(sed -n '/^## Active Focus/,/^## /{/^## Active Focus/d;/^## /d;p;}' "$NYX_HOME/dimensions/$CURRENT_DIM.md" 2>/dev/null | head -3 | tr '\n' ' ' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
fi

# Read version from plugin.json
NYX_VERSION=$(jq -r '.version // "0.x"' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null || echo "0.x")

# Build context
CONTEXT="## Nyx v${NYX_VERSION}

**Home**: $NYX_HOME"

if [ -n "$CURRENT_DIM" ]; then
    CONTEXT="$CONTEXT
**Dimension**: $CURRENT_DIM (branch: $CURRENT_BRANCH)"
    if [ -n "$FOCUS" ]; then
        CONTEXT="$CONTEXT
**Focus**: $FOCUS"
    fi
elif [ "$CURRENT_BRANCH" = "main" ]; then
    CONTEXT="$CONTEXT
**Branch**: main (no active dimension)"
fi

if [ "$DIM_COUNT" -gt 0 ]; then
    if [ -n "$CURRENT_DIM" ] && [ "$DIM_COUNT" -gt 1 ]; then
        OTHER=$((DIM_COUNT - 1))
        CONTEXT="$CONTEXT
**Other dimensions**: $OTHER available"
    elif [ -z "$CURRENT_DIM" ]; then
        CONTEXT="$CONTEXT
**Dimensions**: $DIM_COUNT available"
    fi
fi

CONTEXT="$CONTEXT

**Skills**: /nyx, /nyx:dimension, /nyx:forge, /nyx:prepare, /nyx:status"

# Build status line
STATUS="nyx"
if [ -n "$CURRENT_DIM" ]; then
    STATUS="nyx: $CURRENT_DIM"
    [ "$DIM_COUNT" -gt 1 ] && STATUS="$STATUS (+$((DIM_COUNT - 1)))"
fi

# Output JSON
if command -v jq &> /dev/null; then
    ESCAPED_CONTEXT=$(printf '%s' "$CONTEXT" | jq -Rs '.')
    ESCAPED_STATUS=$(printf '%s' "$STATUS" | jq -Rs '.')
    cat <<EOF
{
  "suppressOutput": true,
  "systemMessage": ${ESCAPED_STATUS},
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": ${ESCAPED_CONTEXT}
  }
}
EOF
else
    ESCAPED_CONTEXT=$(printf '%s' "$CONTEXT" | sed 's/"/\\"/g' | tr '\n' ' ')
    cat <<EOF
{
  "suppressOutput": true,
  "systemMessage": "$STATUS",
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$ESCAPED_CONTEXT"
  }
}
EOF
fi

exit 0
