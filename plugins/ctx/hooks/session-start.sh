#!/bin/bash
# ctx SessionStart hook
# 1. Ensure ctx binary is installed
# 2. Ensure database exists
# 3. Compose and inject stored knowledge
# 4. Inject using-ctx skill content
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# Check for ctx binary, install if missing
if ! command -v ctx &> /dev/null; then
    # Check ~/.local/bin specifically (may not be in PATH yet)
    if [ -x "$HOME/.local/bin/ctx" ]; then
        export PATH="$HOME/.local/bin:$PATH"
    else
        bash "$PLUGIN_ROOT/scripts/install-binary.sh" >&2
        export PATH="$HOME/.local/bin:$PATH"
        if ! command -v ctx &> /dev/null; then
            echo '{"suppressOutput":true,"systemMessage":"ctx: binary installation failed. Run /ctx:setup to install manually."}'
            exit 0
        fi
    fi
fi

# Ensure database exists
if [ ! -f "$HOME/.ctx/store.db" ]; then
    ctx init >&2
fi

# Get ctx hook output (already outputs proper JSON with additionalContext)
CTX_OUTPUT=$(ctx hook session-start 2>/dev/null || echo '{}')

# Extract the additionalContext from ctx output
CTX_CONTEXT=""
if command -v jq &> /dev/null; then
    CTX_CONTEXT=$(echo "$CTX_OUTPUT" | jq -r '.hookSpecificOutput.additionalContext // ""' 2>/dev/null || echo "")
fi

# Read the using-ctx skill content
SKILL_CONTENT=""
if [ -f "$PLUGIN_ROOT/skills/using-ctx/SKILL.md" ]; then
    # Strip frontmatter
    SKILL_CONTENT=$(awk 'BEGIN{skip=0} /^---$/{skip++; next} skip>=2{print}' "$PLUGIN_ROOT/skills/using-ctx/SKILL.md")
fi

# Combine ctx knowledge + skill enforcement
COMBINED=""
if [ -n "$CTX_CONTEXT" ]; then
    COMBINED="$CTX_CONTEXT"
fi
if [ -n "$SKILL_CONTENT" ]; then
    if [ -n "$COMBINED" ]; then
        COMBINED="$COMBINED

$SKILL_CONTENT"
    else
        COMBINED="$SKILL_CONTENT"
    fi
fi

if [ -z "$COMBINED" ]; then
    echo '{"suppressOutput":true,"systemMessage":"ctx: ready (empty context)"}'
    exit 0
fi

# Count nodes for status message (rough extraction)
NODE_COUNT=$(echo "$CTX_CONTEXT" | grep -c '^\- \[' 2>/dev/null || echo "0")
STATUS="ctx: ${NODE_COUNT} nodes loaded"

# Output JSON
if command -v jq &> /dev/null; then
    ESCAPED_COMBINED=$(printf '%s' "$COMBINED" | jq -Rs '.')
    ESCAPED_STATUS=$(printf '%s' "$STATUS" | jq -Rs '.')
    cat <<EOF
{
  "suppressOutput": true,
  "systemMessage": ${ESCAPED_STATUS},
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": ${ESCAPED_COMBINED}
  }
}
EOF
else
    # Fallback: just pass through ctx output
    echo "$CTX_OUTPUT"
fi

exit 0
