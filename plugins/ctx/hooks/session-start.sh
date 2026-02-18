#!/bin/bash
# ctx SessionStart hook
# Check ctx binary exists, call ctx hook, inject stored knowledge + skill
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# Check for ctx binary (also check ~/.local/bin which may not be in PATH)
CTX_BIN=""
if command -v ctx &> /dev/null; then
    CTX_BIN="ctx"
elif [[ -x "$HOME/.local/bin/ctx" ]]; then
    CTX_BIN="$HOME/.local/bin/ctx"
fi

if [[ -z "$CTX_BIN" ]]; then
    echo '{"suppressOutput":false,"systemMessage":"ctx: not installed. Run /ctx:setup to install."}'
    exit 0
fi

# Minimum binary version required by this plugin
MIN_BINARY_VERSION="0.3.1"
BINARY_HINT=""
if RAW_VERSION=$("$CTX_BIN" version 2>/dev/null); then
    CURRENT_VER=$(echo "$RAW_VERSION" | sed -n 's/ctx \([^ ]*\).*/\1/p' | sed 's/^v//')
    if [[ "$CURRENT_VER" == "dev" ]]; then
        BINARY_HINT="**ctx binary is a dev build** - run \`/ctx:setup\` to install the release version (v${MIN_BINARY_VERSION}+)."
    elif [[ -n "$CURRENT_VER" ]]; then
        # Compare versions (works for semver x.y.z)
        if printf '%s\n%s' "$MIN_BINARY_VERSION" "$CURRENT_VER" | sort -V | head -1 | grep -q "^${CURRENT_VER}$" && [[ "$CURRENT_VER" != "$MIN_BINARY_VERSION" ]]; then
            BINARY_HINT="**ctx binary outdated:** v${CURRENT_VER} installed, v${MIN_BINARY_VERSION}+ required. Run \`/ctx:setup\` to upgrade."
        fi
    fi
fi

# Detect current project from git repo
PROJECT_NAME=""
if command -v git &>/dev/null; then
    REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
    [[ -n "$REPO_ROOT" ]] && PROJECT_NAME=$(basename "$REPO_ROOT" | tr '[:upper:]' '[:lower:]')
fi

# Get ctx hook output
CTX_OUTPUT=$("$CTX_BIN" hook session-start --project="$PROJECT_NAME" 2>/dev/null || echo '{}')

# Extract additionalContext
CTX_CONTEXT=""
if command -v jq &> /dev/null; then
    CTX_CONTEXT=$(echo "$CTX_OUTPUT" | jq -r '.hookSpecificOutput.additionalContext // ""' 2>/dev/null || echo "")
fi

# Read using-ctx skill content (strip frontmatter)
SKILL_CONTENT=""
if [[ -f "$PLUGIN_ROOT/skills/using-ctx/SKILL.md" ]]; then
    SKILL_CONTENT=$(awk 'BEGIN{skip=0} /^---$/{skip++; next} skip>=2{print}' "$PLUGIN_ROOT/skills/using-ctx/SKILL.md")
fi

# Combine hints + context + skill
COMBINED=""
[[ -n "$BINARY_HINT" ]] && COMBINED="$BINARY_HINT"
if [[ -n "$CTX_CONTEXT" ]]; then
    [[ -n "$COMBINED" ]] && COMBINED="$COMBINED

$CTX_CONTEXT" || COMBINED="$CTX_CONTEXT"
fi
if [[ -n "$SKILL_CONTENT" ]]; then
    [[ -n "$COMBINED" ]] && COMBINED="$COMBINED

$SKILL_CONTENT" || COMBINED="$SKILL_CONTENT"
fi

if [[ -z "$COMBINED" ]]; then
    echo '{"suppressOutput":false,"systemMessage":"ctx: ready (empty context)"}'
    exit 0
fi

# Count nodes for status
NODE_COUNT=$(echo "$CTX_CONTEXT" | grep -c '^\- \[' 2>/dev/null || echo "0")

# Output JSON
if command -v jq &> /dev/null; then
    jq -n --arg ctx "$COMBINED" --arg status "ctx: ${NODE_COUNT} nodes loaded" \
        '{suppressOutput: false, systemMessage: $status, hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
else
    echo "$CTX_OUTPUT"
fi
