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

# Minimum binary version required by this plugin version
MIN_BINARY_VERSION="0.3.0"

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

# Check binary version against minimum requirement
BINARY_HINT=""
CURRENT_RAW=$(ctx version 2>/dev/null || echo "")
CURRENT_VER=$(echo "$CURRENT_RAW" | grep -oP 'ctx \K[^\s]+' 2>/dev/null || echo "")
if [ -z "$CURRENT_VER" ] || [ "$CURRENT_VER" = "dev" ]; then
    BINARY_HINT="**ctx binary is a dev build** - run \`/ctx:setup\` to install the release version (v${MIN_BINARY_VERSION}+)."
elif [ -n "$MIN_BINARY_VERSION" ]; then
    # Strip leading v for comparison
    CUR_CLEAN="${CURRENT_VER#v}"
    NEWER=$(printf '%s\n%s\n' "$CUR_CLEAN" "$MIN_BINARY_VERSION" | sort -V | tail -1)
    if [ "$NEWER" != "$CUR_CLEAN" ] && [ "$CUR_CLEAN" != "$MIN_BINARY_VERSION" ]; then
        BINARY_HINT="**ctx binary outdated:** v${CUR_CLEAN} installed, v${MIN_BINARY_VERSION}+ required. Run \`/ctx:setup\` to upgrade."
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
            UPDATE_HINT="**ctx update available:** ${CURRENT_V} --> ${LATEST_V}. Run \`/ctx:setup\` to upgrade."
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

# Combine ctx knowledge + skill enforcement + hints
COMBINED=""
if [ -n "$BINARY_HINT" ]; then
    COMBINED="$BINARY_HINT"
fi
if [ -n "$UPDATE_HINT" ]; then
    if [ -n "$COMBINED" ]; then
        COMBINED="$COMBINED
$UPDATE_HINT"
    else
        COMBINED="$UPDATE_HINT"
    fi
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
