#!/bin/bash
# Devloop SessionStart hook
# Detects project context and provides rich initial context for the agent
# Sets environment variables for use by agents
# Runs worklog rotation check on session start
# Initializes session tracking for context usage monitoring

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/../scripts"

# Session tracking initialization (runs quietly)
SESSION_TRACKER="$SCRIPTS_DIR/session-tracker.sh"
SESSION_ID="${CLAUDE_SESSION_ID:-$(date +%s)}"
if [ -f "$SESSION_TRACKER" ]; then
    "$SESSION_TRACKER" start "$SESSION_ID" >/dev/null 2>&1 || true
fi

# Worklog rotation check (runs quietly, only rotates if needed)
ROTATION_SCRIPT="$SCRIPTS_DIR/rotate-worklog.sh"
if [ -f "$ROTATION_SCRIPT" ] && [ -f ".devloop/worklog.md" ]; then
    ROTATION_RESULT=$("$ROTATION_SCRIPT" --quiet 2>/dev/null || true)
    if echo "$ROTATION_RESULT" | grep -q '"rotated": true' 2>/dev/null; then
        ROTATED_FILE=$(echo "$ROTATION_RESULT" | grep -o '"archiveFile": "[^"]*"' | sed 's/"archiveFile": "\([^"]*\)"/\1/')
        WORKLOG_ROTATED=true
        WORKLOG_ARCHIVE="$ROTATED_FILE"
    else
        WORKLOG_ROTATED=false
        WORKLOG_ARCHIVE=""
    fi
else
    WORKLOG_ROTATED=false
    WORKLOG_ARCHIVE=""
fi

# Plan state sync (runs quietly if plan exists, creates/updates plan-state.json)
SYNC_PLAN_SCRIPT="$SCRIPTS_DIR/sync-plan-state.sh"
if [ -f "$SYNC_PLAN_SCRIPT" ] && [ -f ".devloop/plan.md" ]; then
    "$SYNC_PLAN_SCRIPT" ".devloop/plan.md" --output ".devloop/plan-state.json" >/dev/null 2>&1 || true
fi

# ============================================================================
# Project Detection Functions
# ============================================================================

detect_language() {
    if [ -f "go.mod" ] || [ -f "go.sum" ]; then echo "go"; return; fi
    if [ -f "package.json" ]; then
        if [ -f "tsconfig.json" ] || grep -q '"typescript"' package.json 2>/dev/null; then
            echo "typescript"
        else
            echo "javascript"
        fi
        return
    fi
    if [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then echo "java"; return; fi
    if [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ] || [ -f "Pipfile" ]; then echo "python"; return; fi
    if [ -f "Cargo.toml" ]; then echo "rust"; return; fi
    if [ -f "Gemfile" ]; then echo "ruby"; return; fi

    # Check by file extension prevalence
    local counts
    counts=$(find . -maxdepth 3 \( -name "*.go" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.java" -o -name "*.py" \) 2>/dev/null | awk -F. '{ext=tolower($NF); count[ext]++} END {
        print "go=" (count["go"]+0) " ts=" (count["ts"]+0) + (count["tsx"]+0) " js=" (count["js"]+0) + (count["jsx"]+0) " java=" (count["java"]+0) " py=" (count["py"]+0)
    }')

    local go_count=$(echo "$counts" | grep -o 'go=[0-9]*' | cut -d= -f2)
    local ts_count=$(echo "$counts" | grep -o 'ts=[0-9]*' | cut -d= -f2)
    local max=${go_count:-0} lang="go"

    [ "${ts_count:-0}" -gt "$max" ] && { max=$ts_count; lang="typescript"; }
    [ "$max" -gt 0 ] && echo "$lang" || echo "unknown"
}

detect_framework() {
    local lang=$1
    case "$lang" in
        typescript|javascript)
            if [ -f "package.json" ]; then
                grep -q '"next"' package.json 2>/dev/null && { echo "nextjs"; return; }
                grep -q '"react"' package.json 2>/dev/null && { echo "react"; return; }
                grep -q '"vue"' package.json 2>/dev/null && { echo "vue"; return; }
                grep -q '"express"' package.json 2>/dev/null && { echo "express"; return; }
            fi ;;
        java)
            grep -q "spring" pom.xml build.gradle* 2>/dev/null && { echo "spring-boot"; return; } ;;
        python)
            if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
                grep -qi "fastapi" requirements.txt pyproject.toml 2>/dev/null && { echo "fastapi"; return; }
                grep -qi "django" requirements.txt pyproject.toml 2>/dev/null && { echo "django"; return; }
            fi ;;
        go)
            if [ -f "go.mod" ]; then
                grep -q "gin-gonic\|labstack/echo\|gofiber" go.mod 2>/dev/null && { echo "gin"; return; }
            fi ;;
    esac
    echo "none"
}

detect_test_framework() {
    local lang=$1
    case "$lang" in
        typescript|javascript)
            [ -f "package.json" ] && {
                grep -q '"vitest"' package.json 2>/dev/null && { echo "vitest"; return; }
                grep -q '"jest"' package.json 2>/dev/null && { echo "jest"; return; }
            } ;;
        go) echo "go-test"; return ;;
        java) echo "junit"; return ;;
        python) echo "pytest"; return ;;
    esac
    echo "unknown"
}

detect_project_type() {
    local lang=$1 framework=$2
    [ -d "cmd" ] && [ "$lang" = "go" ] && { echo "cli"; return; }
    case "$framework" in
        react|vue|angular) echo "frontend"; return ;;
        nextjs) echo "fullstack"; return ;;
        express|spring-boot|django|fastapi|gin) echo "backend"; return ;;
    esac
    echo "unknown"
}

# ============================================================================
# Project Info Functions
# ============================================================================

get_project_name() {
    [ -f "package.json" ] && { grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' package.json 2>/dev/null | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/' | grep -v '^$' && return; }
    [ -f "go.mod" ] && { head -1 go.mod | sed 's/module //' | sed 's|.*/||' | grep -v '^$' && return; }
    basename "$(pwd)"
}

get_project_description() {
    [ -f "package.json" ] && { grep -o '"description"[[:space:]]*:[[:space:]]*"[^"]*"' package.json 2>/dev/null | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/' | grep -v '^$' && return; }
    echo ""
}

get_key_directories() {
    local dirs=""
    for dir in src lib app cmd pkg api server client frontend backend components pages tests docs plugins templates scripts; do
        [ -d "$dir" ] && dirs="$dirs $dir"
    done
    echo "$dirs" | xargs
}

get_git_info() {
    [ -d ".git" ] || { echo "not-a-git-repo"; return; }
    local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local status=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    local remote=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||' | sed 's|\.git$||' || echo "")
    echo "branch=$branch,uncommitted=$status,repo=$remote"
}

get_claude_md_summary() {
    [ -f "CLAUDE.md" ] && { awk '/^[^#\[]/ && NF {print; exit}' CLAUDE.md 2>/dev/null | head -c 300 && return; }
    echo ""
}

get_config_files() {
    local configs=""
    for file in CLAUDE.md .devloop/local.md .env.example docker-compose.yml Dockerfile Makefile; do
        [ -f "$file" ] && configs="$configs $file"
    done
    echo "$configs" | xargs
}

get_project_size() {
    local count=$(find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.go" -o -name "*.py" -o -name "*.java" \) -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -lt 20 ] && echo "small ($count files)" || echo "medium ($count files)"
}

get_language_skill() {
    local lang=$1 framework=$2
    case "$lang" in
        go) echo "go-patterns" ;;
        python) echo "python-patterns" ;;
        java) echo "java-patterns" ;;
        typescript|javascript) [ "$framework" = "react" ] || [ "$framework" = "nextjs" ] && echo "react-patterns" || echo "" ;;
        *) echo "" ;;
    esac
}

# ============================================================================
# Source plan detection scripts (if available)
# ============================================================================

if [ -f "$SCRIPTS_DIR/detect-plan.sh" ]; then
    source "$SCRIPTS_DIR/detect-plan.sh"
else
    # Fallback implementations
    get_active_plan() { [ -f ".devloop/plan.md" ] && { local n=$(grep -m1 "^# " .devloop/plan.md | sed 's/^# //'); echo "name=$n"; } || echo ""; }
    get_fresh_start_state() { echo ""; }
    validate_fresh_start_state() { echo "invalid"; }
    check_migration_needed() { echo "false"; }
    get_bug_count() { echo ""; }
fi

# ============================================================================
# Main Execution
# ============================================================================

LANGUAGE=$(detect_language)
FRAMEWORK=$(detect_framework "$LANGUAGE")
TEST_FRAMEWORK=$(detect_test_framework "$LANGUAGE")
PROJECT_TYPE=$(detect_project_type "$LANGUAGE" "$FRAMEWORK")
PROJECT_NAME=$(get_project_name)
PROJECT_DESC=$(get_project_description)
KEY_DIRS=$(get_key_directories)
GIT_INFO=$(get_git_info)
CLAUDE_MD=$(get_claude_md_summary)
CONFIG_FILES=$(get_config_files)
PROJECT_SIZE=$(get_project_size)
ACTIVE_PLAN=$(get_active_plan)
FRESH_START=$(get_fresh_start_state)
OPEN_BUGS=$(get_bug_count)
NEEDS_MIGRATION=$(check_migration_needed)
LANGUAGE_SKILL=$(get_language_skill "$LANGUAGE" "$FRAMEWORK")

# Write to environment file if available
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
    {
        echo "export FEATURE_DEV_PROJECT_LANGUAGE=$LANGUAGE"
        echo "export FEATURE_DEV_FRAMEWORK=$FRAMEWORK"
        echo "export FEATURE_DEV_PROJECT_TYPE=$PROJECT_TYPE"
    } >> "$CLAUDE_ENV_FILE"
fi

# Check fresh start validation
FRESH_START_DETECTED=false
VALIDATION_WARNING=""

if [ -f ".devloop/next-action.json" ]; then
    VALIDATION_RESULT=$(validate_fresh_start_state)
    case "$VALIDATION_RESULT" in
        valid) FRESH_START_DETECTED=true ;;
        stale:*)
            STATE_AGE_DAYS=$(echo "$VALIDATION_RESULT" | cut -d: -f2)
            VALIDATION_WARNING="⚠️ **Fresh Start State Detected - Stale** (${STATE_AGE_DAYS} days old)

Delete: \`rm .devloop/next-action.json\` or force resume: \`/devloop:continue\`" ;;
        no_plan) VALIDATION_WARNING="⚠️ **Fresh Start State - Plan Missing**

Delete stale state: \`rm .devloop/next-action.json\`" ;;
        invalid) VALIDATION_WARNING="⚠️ **Fresh Start State - Invalid**

Delete: \`rm .devloop/next-action.json\`" ;;
    esac
fi

# Build context message
CONTEXT_MSG="## Devloop Project Context

**Project**: $PROJECT_NAME"
[ -n "$PROJECT_DESC" ] && CONTEXT_MSG="$CONTEXT_MSG
**Description**: $PROJECT_DESC"

CONTEXT_MSG="$CONTEXT_MSG

**Tech Stack**:
- Language: $LANGUAGE
- Framework: $FRAMEWORK
- Test Framework: $TEST_FRAMEWORK
- Project Type: $PROJECT_TYPE
- Size: $PROJECT_SIZE

**Skills**: 28 available → Load on demand with \`Skill: skill-name\`"
[ -n "$LANGUAGE_SKILL" ] && CONTEXT_MSG="$CONTEXT_MSG
  → Primary: \`Skill: $LANGUAGE_SKILL\` (detected $LANGUAGE project)"
CONTEXT_MSG="$CONTEXT_MSG
  → Index: \`Read: plugins/devloop/skills/INDEX.md\` for full list"

[ -n "$KEY_DIRS" ] && CONTEXT_MSG="$CONTEXT_MSG

**Key Directories**: $KEY_DIRS"
[ -n "$CONFIG_FILES" ] && CONTEXT_MSG="$CONTEXT_MSG
**Config Files**: $CONFIG_FILES"

if [ "$GIT_INFO" != "not-a-git-repo" ]; then
    GIT_BRANCH=$(echo "$GIT_INFO" | sed 's/branch=\([^,]*\).*/\1/')
    GIT_UNCOMMITTED=$(echo "$GIT_INFO" | sed 's/.*uncommitted=\([^,]*\).*/\1/')
    GIT_REPO=$(echo "$GIT_INFO" | sed 's/.*repo=//')
    CONTEXT_MSG="$CONTEXT_MSG

**Git Status**:
- Branch: $GIT_BRANCH"
    [ "$GIT_UNCOMMITTED" -gt 0 ] && CONTEXT_MSG="$CONTEXT_MSG
- Uncommitted changes: $GIT_UNCOMMITTED files"
    [ -n "$GIT_REPO" ] && CONTEXT_MSG="$CONTEXT_MSG
- Repository: $GIT_REPO"
fi

[ -n "$CLAUDE_MD" ] && CONTEXT_MSG="$CONTEXT_MSG

**From CLAUDE.md**: $CLAUDE_MD..."

if [ -n "$ACTIVE_PLAN" ]; then
    PLAN_NAME=$(echo "$ACTIVE_PLAN" | sed 's/name=\([^,]*\).*/\1/')
    PLAN_DONE=$(echo "$ACTIVE_PLAN" | grep -o 'done=[0-9]*' | sed 's/done=//' || true)
    PLAN_TOTAL=$(echo "$ACTIVE_PLAN" | grep -o 'total=[0-9]*' | sed 's/total=//' || true)
    CONTEXT_MSG="$CONTEXT_MSG

**Active Plan**: $PLAN_NAME"
    [ -n "$PLAN_DONE" ] && [ -n "$PLAN_TOTAL" ] && CONTEXT_MSG="$CONTEXT_MSG ($PLAN_DONE/$PLAN_TOTAL tasks complete)
  → Use \`/devloop:continue\` to resume"
fi

[ -n "$OPEN_BUGS" ] && [ "$OPEN_BUGS" -gt 0 ] && CONTEXT_MSG="$CONTEXT_MSG

**Open Bugs**: $OPEN_BUGS tracked → Use \`/devloop:bugs\` to manage"

[ "$WORKLOG_ROTATED" = true ] && CONTEXT_MSG="$CONTEXT_MSG

**Worklog Rotated**: Archived to \`$WORKLOG_ARCHIVE\`"

[ "$NEEDS_MIGRATION" = "true" ] && CONTEXT_MSG="$CONTEXT_MSG

**Migration Available**: Legacy files in \`.claude/\`. Consider \`/devloop:onboard\` for migration."

CONTEXT_MSG="$CONTEXT_MSG

**Available Commands**: /devloop, /devloop:continue, /devloop:quick, /devloop:spike, /devloop:review, /devloop:ship, /devloop:bug, /devloop:bugs"

[ -n "$VALIDATION_WARNING" ] && CONTEXT_MSG="$CONTEXT_MSG

---

$VALIDATION_WARNING"

if [ "$FRESH_START_DETECTED" = true ]; then
    CONTEXT_MSG="$CONTEXT_MSG

---

**CRITICAL - Fresh Start Auto-Resume Detected**

A fresh start state file exists at \`.devloop/next-action.json\`.

**Your immediate action**: Execute \`/devloop:continue\` command NOW.

Do NOT wait for user input. Do NOT ask questions. Immediately invoke the continue command.
The continue command will:
1. Read and parse the next-action.json file
2. Delete the state file (single-use)
3. Display the resumption context to the user
4. Continue with the next pending task

This is an automatic resume from a previous fresh start. Proceed immediately."
fi

# Build status message
if [ "$FRESH_START_DETECTED" = true ]; then
    STATUS_MSG="🔄 Fresh start detected - auto-resuming work..."
else
    STATUS_MSG="devloop: $PROJECT_NAME"
    [ "$LANGUAGE" != "unknown" ] && STATUS_MSG="$STATUS_MSG ($LANGUAGE${FRAMEWORK:+/$FRAMEWORK})"
    [ -n "$ACTIVE_PLAN" ] && STATUS_MSG="$STATUS_MSG | plan: $(echo "$ACTIVE_PLAN" | sed 's/name=\([^,]*\).*/\1/')"
fi

# Output JSON
if command -v jq &> /dev/null; then
    ESCAPED_MSG=$(printf '%s' "$CONTEXT_MSG" | jq -Rs '.')
    ESCAPED_STATUS=$(printf '%s' "$STATUS_MSG" | jq -Rs '.')
    cat <<EOF
{
  "systemMessage": ${ESCAPED_STATUS},
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": ${ESCAPED_MSG}
  }
}
EOF
else
    ESCAPED_MSG=$(printf '%s' "$CONTEXT_MSG" | awk 'BEGIN{ORS="\\n"}{gsub(/\\/,"\\\\");gsub(/"/,"\\\"");gsub(/\t/,"\\t");print}' | sed '$ s/\\n$//')
    ESCAPED_STATUS=$(printf '%s' "$STATUS_MSG" | sed 's/"/\\"/g')
    cat <<EOF
{
  "systemMessage": "$ESCAPED_STATUS",
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$ESCAPED_MSG"
  }
}
EOF
fi

exit 0
