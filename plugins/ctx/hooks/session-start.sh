#!/bin/bash
# ctx SessionStart hook
# 1. Ensure ctx binary is installed
# 2. Check for updates (at most once per day)
# 3. Ensure database exists
# 4. Compose and inject stored knowledge
# 5. Inject using-ctx skill content
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

# Check for updates at most once per day
UPDATE_HINT=""
UPDATE_CHECK_FILE="$HOME/.ctx/.last-update-check"
SHOULD_CHECK=false
if [ ! -f "$UPDATE_CHECK_FILE" ]; then
    SHOULD_CHECK=true
else
    LAST_CHECK=$(cat "$UPDATE_CHECK_FILE" 2>/dev/null || echo "0")
    NOW=$(date +%s)
    AGE=$(( NOW - LAST_CHECK ))
    if [ "$AGE" -gt 86400 ]; then
        SHOULD_CHECK=true
    fi
fi

if [ "$SHOULD_CHECK" = "true" ]; then
    date +%s > "$UPDATE_CHECK_FILE" 2>/dev/null || true
    CHECK_RESULT=$(bash "$PLUGIN_ROOT/scripts/check-update.sh" 2>/dev/null || echo "check-failed:error")
    case "$CHECK_RESULT" in
        update-available:*)
            CURRENT_V=$(echo "$CHECK_RESULT" | cut -d: -f2)
            LATEST_V=$(echo "$CHECK_RESULT" | cut -d: -f3)
            UPDATE_HINT="**ctx update available:** ${CURRENT_V} → ${LATEST_V}. Run \`/ctx:setup\` to upgrade."
            ;;
    esac
fi

# Ensure database exists
if [ ! -f "$HOME/.ctx/store.db" ]; then
    ctx init >&2
fi

# Detect current project from git repo name
PROJECT_NAME=""
if command -v git &>/dev/null; then
    REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$REPO_ROOT" ]; then
        PROJECT_NAME=$(basename "$REPO_ROOT" | tr '[:upper:]' '[:lower:]')
    fi
fi

# Get ctx hook output (already outputs proper JSON with additionalContext)
CTX_OUTPUT=$(ctx hook session-start --project="$PROJECT_NAME" 2>/dev/null || echo '{}')

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

# Combine ctx knowledge + skill enforcement + update hint
COMBINED=""
if [ -n "$UPDATE_HINT" ]; then
    COMBINED="$UPDATE_HINT"
fi
if [ -n "$CTX_CONTEXT" ]; then
    if [ -n "$COMBINED" ]; then
        COMBINED="$COMBINED

$CTX_CONTEXT"
    else
        COMBINED="$CTX_CONTEXT"
    fi
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
