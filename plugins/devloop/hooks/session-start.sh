#!/bin/bash
# Devloop SessionStart hook - v3.0 minimal version
# Quick project detection, no heavy processing
# Optimized for speed and low token overhead

set -euo pipefail

# ============================================================================
# Fast Detection Functions
# ============================================================================

detect_language() {
    [ -f "go.mod" ] && { echo "go"; return; }
    [ -f "package.json" ] && { 
        [ -f "tsconfig.json" ] && { echo "typescript"; return; }
        echo "javascript"; return
    }
    [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] && { echo "python"; return; }
    [ -f "pom.xml" ] || [ -f "build.gradle" ] && { echo "java"; return; }
    [ -f "Cargo.toml" ] && { echo "rust"; return; }
    echo "unknown"
}

get_project_name() {
    basename "$(pwd)"
}

get_plan_status() {
    if [ -f ".devloop/plan.md" ]; then
        local total=$(grep -c "^- \[" .devloop/plan.md 2>/dev/null || echo "0")
        local done=$(grep -c "^- \[x\]" .devloop/plan.md 2>/dev/null || echo "0")
        echo "$done/$total"
    else
        echo "none"
    fi
}

check_fresh_start() {
    [ -f ".devloop/next-action.json" ] && echo "true" || echo "false"
}

get_git_branch() {
    git branch --show-current 2>/dev/null || echo ""
}

# ============================================================================
# Main Execution
# ============================================================================

LANG=$(detect_language)
PROJECT=$(get_project_name)
PLAN=$(get_plan_status)
FRESH=$(check_fresh_start)
BRANCH=$(get_git_branch)

# Build minimal context message
CONTEXT="## devloop v3.0

**Project**: $PROJECT"
[ "$LANG" != "unknown" ] && CONTEXT="$CONTEXT ($LANG)"
[ -n "$BRANCH" ] && CONTEXT="$CONTEXT | branch: $BRANCH"

if [ "$PLAN" != "none" ]; then
    CONTEXT="$CONTEXT
**Plan**: $PLAN tasks complete"
fi

if [ "$FRESH" = "true" ]; then
    CONTEXT="$CONTEXT

**⚡ Fresh start detected** → Run \`/devloop:continue\` to resume"
fi

CONTEXT="$CONTEXT

**Commands**: /devloop, /devloop:continue, /devloop:spike, /devloop:fresh
**Skills**: Load on demand with \`Skill: skill-name\` (see skills/INDEX.md)"

# Build status line
STATUS="devloop: $PROJECT"
[ "$LANG" != "unknown" ] && STATUS="$STATUS ($LANG)"
[ "$PLAN" != "none" ] && STATUS="$STATUS | plan: $PLAN"

# Output JSON
if command -v jq &> /dev/null; then
    ESCAPED_CONTEXT=$(printf '%s' "$CONTEXT" | jq -Rs '.')
    ESCAPED_STATUS=$(printf '%s' "$STATUS" | jq -Rs '.')
    cat <<EOF
{
  "systemMessage": ${ESCAPED_STATUS},
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": ${ESCAPED_CONTEXT}
  }
}
EOF
else
    # Fallback without jq
    ESCAPED_CONTEXT=$(printf '%s' "$CONTEXT" | sed 's/"/\\"/g' | tr '\n' ' ')
    cat <<EOF
{
  "systemMessage": "$STATUS",
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$ESCAPED_CONTEXT"
  }
}
EOF
fi

exit 0
