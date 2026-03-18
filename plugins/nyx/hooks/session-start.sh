#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
NYX_DIR="$HOME/.claude/nyx"
DIM_DIR="$NYX_DIR/dimensions"
CURRENT_FILE="$NYX_DIR/current"

# Early exit if nyx hasn't been set up (no dimensions directory)
if [ ! -d "$DIM_DIR" ]; then
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
    exit 0
fi

# Read current dimension
CURRENT=""
if [ -f "$CURRENT_FILE" ]; then
    CURRENT=$(cat "$CURRENT_FILE" 2>/dev/null | tr -d '[:space:]')
fi

# Count active dimensions
ACTIVE_COUNT=0
if [ -d "$DIM_DIR" ]; then
    ACTIVE_COUNT=$(grep -rl "status: active" "$DIM_DIR"/*.md 2>/dev/null | wc -l | tr -d '[:space:]')
fi

# Read current dimension's active focus
FOCUS=""
if [ -n "$CURRENT" ] && [ -f "$DIM_DIR/$CURRENT.md" ]; then
    # Extract Active Focus section (between ## Active Focus and next ##)
    FOCUS=$(sed -n '/^## Active Focus/,/^## /{/^## Active Focus/d;/^## /d;p;}' "$DIM_DIR/$CURRENT.md" 2>/dev/null | head -3 | tr '\n' ' ' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
fi

# Read version from plugin.json
NYX_VERSION=$(jq -r '.version // "0.x"' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null || echo "0.x")

# Build context
CONTEXT="## Nyx v${NYX_VERSION}"

if [ -n "$CURRENT" ]; then
    CONTEXT="$CONTEXT
**Dimension**: $CURRENT"
    if [ -n "$FOCUS" ]; then
        CONTEXT="$CONTEXT
**Focus**: $FOCUS"
    fi
fi

if [ "$ACTIVE_COUNT" -gt 1 ]; then
    OTHER=$((ACTIVE_COUNT - 1))
    CONTEXT="$CONTEXT
**Other dimensions**: $OTHER active"
elif [ "$ACTIVE_COUNT" -eq 0 ] && [ -z "$CURRENT" ]; then
    CONTEXT="$CONTEXT
No active dimensions."
fi

CONTEXT="$CONTEXT

**Skills**: /nyx, /nyx:dimension, /nyx:forge, /nyx:prepare, /nyx:status"

# Build status line
STATUS="nyx"
if [ -n "$CURRENT" ]; then
    STATUS="nyx: $CURRENT"
    [ "$ACTIVE_COUNT" -gt 1 ] && STATUS="$STATUS (+$((ACTIVE_COUNT - 1)))"
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
