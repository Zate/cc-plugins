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
MIN_BINARY_VERSION="0.6.0"
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

# Resolve the cwd Claude Code is actually running in. When the hook is invoked
# by Claude Code, the session payload is piped in on stdin and contains a `cwd`
# field. Fall back to $PWD only when stdin is a terminal (manual invocation).
HOOK_INPUT=""
if [[ ! -t 0 ]]; then
    HOOK_INPUT=$(cat 2>/dev/null || true)
fi
STDIN_CWD=""
if [[ -n "$HOOK_INPUT" ]] && command -v jq &>/dev/null; then
    STDIN_CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd // ""' 2>/dev/null || echo "")
fi
SEARCH_DIR="${STDIN_CWD:-$PWD}"

# Project detection chain: explicit env var, then git repo at the hook cwd,
# then basename of a non-git cwd. Anything else falls through to fail-closed.
PROJECT_NAME="${CTX_PROJECT:-}"
if [[ -z "$PROJECT_NAME" && -d "$SEARCH_DIR" ]]; then
    if command -v git &>/dev/null; then
        REPO_ROOT=$(git -C "$SEARCH_DIR" rev-parse --show-toplevel 2>/dev/null || echo "")
        [[ -n "$REPO_ROOT" ]] && PROJECT_NAME=$(basename "$REPO_ROOT" | tr '[:upper:]' '[:lower:]')
    fi
fi

# Get ctx hook output (with plugin primer if available)
PRIMER_ARGS=()
if [[ -f "$PLUGIN_ROOT/primer.md" ]]; then
    PRIMER_ARGS+=("--primer-file=$PLUGIN_ROOT/primer.md")
fi
# Fail closed: when no project could be determined, tell ctx to load zero
# nodes rather than every pinned node across all projects.
# --fail-closed landed after 0.6.2; use version check (CURRENT_VER already parsed above).
FAIL_CLOSED_MIN="0.6.3"
HAS_FAIL_CLOSED=false
if [[ -n "$CURRENT_VER" && "$CURRENT_VER" != "dev" ]]; then
    if printf '%s\n%s' "$FAIL_CLOSED_MIN" "$CURRENT_VER" | sort -V | head -1 | grep -q "^${FAIL_CLOSED_MIN}$"; then
        HAS_FAIL_CLOSED=true
    fi
elif [[ "$CURRENT_VER" == "dev" ]]; then
    HAS_FAIL_CLOSED=true
fi
if [[ -z "$PROJECT_NAME" ]]; then
    if $HAS_FAIL_CLOSED; then
        PRIMER_ARGS+=("--fail-closed")
    else
        # Binary too old for --fail-closed. Use a sentinel project name that
        # won't match any real nodes so the filter still excludes everything.
        PROJECT_NAME="__undetected__"
    fi
fi
CTX_OUTPUT=$("$CTX_BIN" hook session-start --project="$PROJECT_NAME" "${PRIMER_ARGS[@]}" 2>/dev/null || echo '{}')

# Extract additionalContext
CTX_CONTEXT=""
if command -v jq &> /dev/null; then
    CTX_CONTEXT=$(echo "$CTX_OUTPUT" | jq -r '.hookSpecificOutput.additionalContext // ""' 2>/dev/null || echo "")
fi

# Combine hints + context (skill is available via /ctx if needed)
COMBINED=""
[[ -n "$BINARY_HINT" ]] && COMBINED="$BINARY_HINT"
if [[ -n "$CTX_CONTEXT" ]]; then
    [[ -n "$COMBINED" ]] && COMBINED="$COMBINED

$CTX_CONTEXT" || COMBINED="$CTX_CONTEXT"
fi

if [[ -z "$COMBINED" ]]; then
    echo '{"suppressOutput":false,"systemMessage":"ctx: ready (empty context)"}'
    exit 0
fi

# Count nodes for status
NODE_COUNT=$(echo "$CTX_CONTEXT" | grep -c '^\- \[' 2>/dev/null || echo "0")

# Build status message — include upgrade warning if needed
STATUS="ctx: ${NODE_COUNT} nodes loaded"
if [[ -n "$BINARY_HINT" ]]; then
    STATUS="ctx: UPGRADE REQUIRED (v${CURRENT_VER} -> v${MIN_BINARY_VERSION}+). Run /ctx:setup"
fi

# Output JSON
if command -v jq &> /dev/null; then
    jq -n --arg ctx "$COMBINED" --arg status "$STATUS" \
        '{suppressOutput: false, systemMessage: $status, hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
else
    echo "$CTX_OUTPUT"
fi
