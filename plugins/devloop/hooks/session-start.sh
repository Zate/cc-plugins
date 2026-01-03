#!/bin/bash
# Devloop SessionStart hook - v3.1 with local config support
# Quick project detection, no heavy processing
# Optimized for speed and low token overhead

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

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
        local total
        local done
        total=$(grep -c "^- \[" .devloop/plan.md 2>/dev/null) || total=0
        done=$(grep -c "^- \[x\]" .devloop/plan.md 2>/dev/null) || done=0
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

get_git_workflow_config() {
    # Check if local.md exists and has git config enabled
    if [ -f ".devloop/local.md" ]; then
        # Quick check for git config without full parsing
        if grep -q "auto-branch:\s*true" .devloop/local.md 2>/dev/null || \
           grep -q "auto_branch:\s*true" .devloop/local.md 2>/dev/null; then
            echo "git-flow"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

get_pr_status() {
    # Check if on a feature branch with open PR
    local branch
    branch=$(git branch --show-current 2>/dev/null || echo "")

    if [ -z "$branch" ] || [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
        echo ""
        return
    fi

    # Check for open PR (quick check, don't block on failure)
    if command -v gh &> /dev/null; then
        local pr_info
        pr_info=$(gh pr view --json number,reviewDecision,state 2>/dev/null || echo "")
        if [ -n "$pr_info" ]; then
            local number state review
            number=$(echo "$pr_info" | jq -r '.number // empty' 2>/dev/null)
            state=$(echo "$pr_info" | jq -r '.state // empty' 2>/dev/null)
            review=$(echo "$pr_info" | jq -r '.reviewDecision // empty' 2>/dev/null)

            if [ "$state" = "OPEN" ] && [ -n "$number" ]; then
                if [ -n "$review" ] && [ "$review" != "null" ]; then
                    echo "PR #$number ($review)"
                    return
                else
                    echo "PR #$number"
                    return
                fi
            fi
        fi
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

LANG=$(detect_language)
PROJECT=$(get_project_name)
PLAN=$(get_plan_status)
FRESH=$(check_fresh_start)
BRANCH=$(get_git_branch)
GIT_WORKFLOW=$(get_git_workflow_config)
PR_STATUS=$(get_pr_status)

# Build minimal context message
CONTEXT="## devloop v3.0

**Project**: $PROJECT"
[ "$LANG" != "unknown" ] && CONTEXT="$CONTEXT ($LANG)"
[ -n "$BRANCH" ] && CONTEXT="$CONTEXT | branch: $BRANCH"

if [ "$PLAN" != "none" ]; then
    CONTEXT="$CONTEXT
**Plan**: $PLAN tasks complete"
fi

# Show PR status if on feature branch with open PR
if [ -n "$PR_STATUS" ]; then
    CONTEXT="$CONTEXT
**PR**: $PR_STATUS"
fi

if [ "$FRESH" = "true" ]; then
    CONTEXT="$CONTEXT

**⚡ Fresh start detected** → Run \`/devloop:continue\` to resume"
fi

CONTEXT="$CONTEXT

**Commands**: /devloop, /devloop:continue, /devloop:spike, /devloop:fresh"

# Add ship command if git workflow is configured
if [ -n "$GIT_WORKFLOW" ]; then
    CONTEXT="$CONTEXT, /devloop:ship"
fi

CONTEXT="$CONTEXT
**Skills**: Load on demand with \`Skill: skill-name\` (see skills/INDEX.md)"

# Build status line
STATUS="devloop: $PROJECT"
[ "$LANG" != "unknown" ] && STATUS="$STATUS ($LANG)"
[ "$PLAN" != "none" ] && STATUS="$STATUS | plan: $PLAN"
[ -n "$PR_STATUS" ] && STATUS="$STATUS | $PR_STATUS"

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
