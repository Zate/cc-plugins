#!/bin/bash
# Devloop SessionStart hook
# Detects project context and provides rich initial context for the agent
# Sets environment variables for use by agents

set -euo pipefail

# Detect primary project language
detect_language() {
    if [ -f "go.mod" ] || [ -f "go.sum" ]; then
        echo "go"
        return
    fi

    if [ -f "package.json" ]; then
        if [ -f "tsconfig.json" ] || grep -q '"typescript"' package.json 2>/dev/null; then
            echo "typescript"
        else
            echo "javascript"
        fi
        return
    fi

    if [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        echo "java"
        return
    fi

    if [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ] || [ -f "Pipfile" ]; then
        echo "python"
        return
    fi

    if [ -f "Cargo.toml" ]; then
        echo "rust"
        return
    fi

    if [ -f "Gemfile" ]; then
        echo "ruby"
        return
    fi

    # Check by file extension prevalence - single find pass for performance
    local counts
    counts=$(find . -maxdepth 3 \( \
        -name "*.go" -o \
        -name "*.ts" -o -name "*.tsx" -o \
        -name "*.js" -o -name "*.jsx" -o \
        -name "*.java" -o \
        -name "*.py" \
    \) 2>/dev/null | awk -F. '{ext=tolower($NF); count[ext]++} END {
        print "go=" (count["go"]+0)
        print "ts=" (count["ts"]+0) + (count["tsx"]+0)
        print "js=" (count["js"]+0) + (count["jsx"]+0)
        print "java=" (count["java"]+0)
        print "py=" (count["py"]+0)
    }')

    local go_count=$(echo "$counts" | grep "^go=" | cut -d= -f2)
    local ts_count=$(echo "$counts" | grep "^ts=" | cut -d= -f2)
    local js_count=$(echo "$counts" | grep "^js=" | cut -d= -f2)
    local java_count=$(echo "$counts" | grep "^java=" | cut -d= -f2)
    local py_count=$(echo "$counts" | grep "^py=" | cut -d= -f2)

    # Default to 0 if empty
    go_count=${go_count:-0}
    ts_count=${ts_count:-0}
    js_count=${js_count:-0}
    java_count=${java_count:-0}
    py_count=${py_count:-0}

    local max=$go_count
    local lang="go"

    if [ "$ts_count" -gt "$max" ]; then max=$ts_count; lang="typescript"; fi
    if [ "$js_count" -gt "$max" ]; then max=$js_count; lang="javascript"; fi
    if [ "$java_count" -gt "$max" ]; then max=$java_count; lang="java"; fi
    if [ "$py_count" -gt "$max" ]; then max=$py_count; lang="python"; fi

    if [ "$max" -gt 0 ]; then
        echo "$lang"
    else
        echo "unknown"
    fi
}

# Detect framework based on language
detect_framework() {
    local lang=$1

    case "$lang" in
        typescript|javascript)
            if [ -f "package.json" ]; then
                if grep -q '"react"' package.json 2>/dev/null; then
                    if grep -q '"next"' package.json 2>/dev/null; then
                        echo "nextjs"
                    else
                        echo "react"
                    fi
                    return
                fi
                if grep -q '"vue"' package.json 2>/dev/null; then echo "vue"; return; fi
                if grep -q '"@angular/core"' package.json 2>/dev/null; then echo "angular"; return; fi
                if grep -q '"express"' package.json 2>/dev/null; then echo "express"; return; fi
                if grep -q '"@nestjs/core"' package.json 2>/dev/null; then echo "nestjs"; return; fi
                if grep -q '"fastify"' package.json 2>/dev/null; then echo "fastify"; return; fi
            fi
            ;;
        java)
            if [ -f "pom.xml" ]; then
                if grep -q "spring-boot" pom.xml 2>/dev/null; then echo "spring-boot"; return; fi
                if grep -q "spring" pom.xml 2>/dev/null; then echo "spring"; return; fi
            fi
            if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
                if grep -q "spring" build.gradle* 2>/dev/null; then echo "spring-boot"; return; fi
            fi
            ;;
        python)
            if [ -f "requirements.txt" ]; then
                if grep -qi "django" requirements.txt 2>/dev/null; then echo "django"; return; fi
                if grep -qi "flask" requirements.txt 2>/dev/null; then echo "flask"; return; fi
                if grep -qi "fastapi" requirements.txt 2>/dev/null; then echo "fastapi"; return; fi
            fi
            if [ -f "pyproject.toml" ]; then
                if grep -qi "django" pyproject.toml 2>/dev/null; then echo "django"; return; fi
                if grep -qi "fastapi" pyproject.toml 2>/dev/null; then echo "fastapi"; return; fi
            fi
            ;;
        go)
            if [ -f "go.mod" ]; then
                if grep -q "gin-gonic" go.mod 2>/dev/null; then echo "gin"; return; fi
                if grep -q "labstack/echo" go.mod 2>/dev/null; then echo "echo"; return; fi
                if grep -q "gofiber/fiber" go.mod 2>/dev/null; then echo "fiber"; return; fi
                if grep -q "go-chi/chi" go.mod 2>/dev/null; then echo "chi"; return; fi
                if grep -q "gorilla/mux" go.mod 2>/dev/null; then echo "gorilla"; return; fi
            fi
            ;;
    esac

    echo "none"
}

# Detect test framework
detect_test_framework() {
    local lang=$1

    case "$lang" in
        typescript|javascript)
            if [ -f "package.json" ]; then
                if grep -q '"vitest"' package.json 2>/dev/null; then echo "vitest"; return; fi
                if grep -q '"jest"' package.json 2>/dev/null; then echo "jest"; return; fi
                if grep -q '"mocha"' package.json 2>/dev/null; then echo "mocha"; return; fi
                if grep -q '"playwright"' package.json 2>/dev/null; then echo "playwright"; return; fi
                if grep -q '"cypress"' package.json 2>/dev/null; then echo "cypress"; return; fi
            fi
            ;;
        go) echo "go-test"; return ;;
        java) echo "junit"; return ;;
        python)
            if [ -f "pytest.ini" ] || ([ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml 2>/dev/null); then
                echo "pytest"; return
            fi
            if [ -f "requirements.txt" ] && grep -q "pytest" requirements.txt 2>/dev/null; then
                echo "pytest"; return
            fi
            echo "unittest"; return
            ;;
        rust) echo "cargo-test"; return ;;
        ruby)
            if [ -f "Gemfile" ] && grep -q "rspec" Gemfile 2>/dev/null; then
                echo "rspec"; return
            fi
            echo "minitest"; return
            ;;
    esac

    echo "unknown"
}

# Detect project type
detect_project_type() {
    local lang=$1
    local framework=$2

    # CLI indicators
    if [ -d "cmd" ] && [ "$lang" = "go" ]; then echo "cli"; return; fi
    if [ -f "go.mod" ] && grep -q "cobra\|urfave/cli" go.mod 2>/dev/null; then echo "cli"; return; fi
    if [ -f "package.json" ] && grep -q '"bin"' package.json 2>/dev/null; then echo "cli"; return; fi

    # Frontend frameworks
    case "$framework" in
        react|vue|angular)
            if [ -d "server" ] || [ -d "api" ] || [ -d "backend" ]; then
                echo "fullstack"
            else
                echo "frontend"
            fi
            return
            ;;
        nextjs) echo "fullstack"; return ;;
        express|nestjs|fastify|spring-boot|spring|django|flask|fastapi|gin|echo|fiber|chi|gorilla)
            if [ -d "frontend" ] || [ -d "client" ] || [ -d "web" ]; then
                echo "fullstack"
            else
                echo "backend"
            fi
            return
            ;;
    esac

    # Library indicators
    if [ -f "setup.py" ] && grep -q "packages=" setup.py 2>/dev/null; then echo "library"; return; fi
    if [ -f "Cargo.toml" ] && grep -q '\[lib\]' Cargo.toml 2>/dev/null; then echo "library"; return; fi

    echo "unknown"
}

# Get project name
get_project_name() {
    # From package.json
    if [ -f "package.json" ]; then
        local name=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' package.json 2>/dev/null | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')
        if [ -n "$name" ]; then echo "$name"; return; fi
    fi

    # From go.mod
    if [ -f "go.mod" ]; then
        local name=$(head -1 go.mod | sed 's/module //' | sed 's|.*/||')
        if [ -n "$name" ]; then echo "$name"; return; fi
    fi

    # From pyproject.toml
    if [ -f "pyproject.toml" ]; then
        local name=$(grep -o 'name[[:space:]]*=[[:space:]]*"[^"]*"' pyproject.toml 2>/dev/null | head -1 | sed 's/.*= *"\([^"]*\)".*/\1/')
        if [ -n "$name" ]; then echo "$name"; return; fi
    fi

    # From Cargo.toml
    if [ -f "Cargo.toml" ]; then
        local name=$(grep -o 'name[[:space:]]*=[[:space:]]*"[^"]*"' Cargo.toml 2>/dev/null | head -1 | sed 's/.*= *"\([^"]*\)".*/\1/')
        if [ -n "$name" ]; then echo "$name"; return; fi
    fi

    # Fallback to directory name
    basename "$(pwd)"
}

# Get project description
get_project_description() {
    # From package.json
    if [ -f "package.json" ]; then
        local desc=$(grep -o '"description"[[:space:]]*:[[:space:]]*"[^"]*"' package.json 2>/dev/null | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')
        if [ -n "$desc" ] && [ "$desc" != "null" ]; then echo "$desc"; return; fi
    fi

    # From pyproject.toml
    if [ -f "pyproject.toml" ]; then
        local desc=$(grep -o 'description[[:space:]]*=[[:space:]]*"[^"]*"' pyproject.toml 2>/dev/null | head -1 | sed 's/.*= *"\([^"]*\)".*/\1/')
        if [ -n "$desc" ]; then echo "$desc"; return; fi
    fi

    # From README first line (after title)
    if [ -f "README.md" ]; then
        local desc=$(sed -n '3p' README.md 2>/dev/null | head -c 200)
        if [ -n "$desc" ] && [[ ! "$desc" =~ ^# ]] && [[ ! "$desc" =~ ^\[ ]]; then
            echo "$desc"
            return
        fi
    fi

    echo ""
}

# Get key directories
get_key_directories() {
    local dirs=""

    # Common source directories
    for dir in src lib app cmd pkg internal api server client frontend backend components pages routes controllers models services utils hooks tests test __tests__ spec e2e plugins templates docs scripts bin; do
        if [ -d "$dir" ]; then
            dirs="$dirs $dir"
        fi
    done

    echo "$dirs" | xargs
}

# Get git info
get_git_info() {
    if [ -d ".git" ]; then
        local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        local status=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        local remote=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||' | sed 's|\.git$||' || echo "")

        echo "branch=$branch,uncommitted=$status,repo=$remote"
    else
        echo "not-a-git-repo"
    fi
}

# Check for CLAUDE.md
get_claude_md_summary() {
    if [ -f "CLAUDE.md" ]; then
        # Get first meaningful paragraph (skip empty lines and headers)
        local summary=$(awk '/^[^#\[]/ && NF {print; exit}' CLAUDE.md 2>/dev/null | head -c 300)
        if [ -n "$summary" ]; then
            echo "$summary"
            return
        fi
    fi
    echo ""
}

# Check for important config files
get_config_files() {
    local configs=""

    for file in CLAUDE.md .claude/settings.json .devloop/local.md .claude/devloop.local.md .env.example docker-compose.yml Dockerfile Makefile justfile; do
        if [ -f "$file" ]; then
            configs="$configs $file"
        fi
    done

    echo "$configs" | xargs
}

# Detect if legacy devloop files exist that could be migrated
check_migration_needed() {
    # Check if legacy files exist in .claude/ but .devloop/ doesn't exist yet
    local needs_migration=false

    if [ ! -d ".devloop" ]; then
        if [ -f ".claude/devloop-plan.md" ] || [ -f ".claude/devloop-worklog.md" ] || [ -d ".claude/issues" ] || [ -d ".claude/bugs" ]; then
            needs_migration=true
        fi
    fi

    echo "$needs_migration"
}

# Check for open bugs/issues (prefer .devloop/, fallback to .claude/)
get_bug_count() {
    local issues_dir=""
    if [ -d ".devloop/issues" ]; then
        issues_dir=".devloop/issues"
    elif [ -d ".claude/issues" ]; then
        issues_dir=".claude/issues"
    elif [ -d ".claude/bugs" ]; then
        issues_dir=".claude/bugs"
    fi

    if [ -n "$issues_dir" ]; then
        local open=$(grep -l "status: open" "$issues_dir"/*.md 2>/dev/null | wc -l | tr -d ' ' || echo "0")
        if [ "$open" -gt 0 ]; then
            echo "$open"
            return
        fi
    fi
    echo ""
}

# Get relevant skills based on detected language and framework
get_relevant_skills() {
    local lang=$1
    local framework=$2
    local project_type=$3
    local skills=""

    # Language-specific skills
    case "$lang" in
        go)
            skills="go-patterns"
            ;;
        python)
            skills="python-patterns"
            ;;
        java)
            skills="java-patterns"
            ;;
        typescript|javascript)
            # React gets react-patterns, general TS/JS gets architecture-patterns
            case "$framework" in
                react|nextjs)
                    skills="react-patterns"
                    ;;
                *)
                    skills="architecture-patterns"
                    ;;
            esac
            ;;
    esac

    # Add testing-strategies for all known languages
    if [ "$lang" != "unknown" ]; then
        if [ -n "$skills" ]; then
            skills="$skills, testing-strategies"
        else
            skills="testing-strategies"
        fi
    fi

    # Add database-patterns for backend/fullstack projects
    case "$project_type" in
        backend|fullstack)
            skills="$skills, database-patterns"
            ;;
    esac

    # Add api-design for backend projects with web frameworks
    case "$framework" in
        express|nestjs|fastify|spring-boot|spring|django|flask|fastapi|gin|echo|fiber|chi|gorilla)
            skills="$skills, api-design"
            ;;
    esac

    echo "$skills"
}

# Check for existing devloop plan (prefer .devloop/, fallback to .claude/)
get_active_plan() {
    local plan_file=""

    # Prefer new .devloop/ location
    if [ -f ".devloop/plan.md" ]; then
        plan_file=".devloop/plan.md"
    elif [ -f ".claude/devloop-plan.md" ]; then
        # Legacy location fallback
        plan_file=".claude/devloop-plan.md"
    fi

    if [ -n "$plan_file" ]; then
        # Extract plan name from first heading
        local plan_name=$(grep -m1 "^# " "$plan_file" 2>/dev/null | sed 's/^# //' | head -c 50)
        # Count completed vs total tasks
        local total=$(grep -c "^\s*- \[" "$plan_file" 2>/dev/null || echo "0")
        local done=$(grep -c "^\s*- \[x\]" "$plan_file" 2>/dev/null || echo "0")
        if [ -n "$plan_name" ]; then
            echo "name=$plan_name,done=$done,total=$total"
            return
        fi
    fi

    # Check for other plan files
    for plan_file in docs/PLAN.md docs/plan.md PLAN.md plan.md; do
        if [ -f "$plan_file" ]; then
            local plan_name=$(grep -m1 "^# " "$plan_file" 2>/dev/null | sed 's/^# //' | head -c 50)
            if [ -n "$plan_name" ]; then
                echo "name=$plan_name,file=$plan_file"
                return
            fi
        fi
    done

    echo ""
}

# Count files for size estimation
get_project_size() {
    local count=$(find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.go" -o -name "*.py" -o -name "*.java" -o -name "*.rs" -o -name "*.rb" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/vendor/*" -not -path "*/dist/*" -not -path "*/build/*" 2>/dev/null | wc -l | tr -d ' ')

    if [ "$count" -lt 20 ]; then
        echo "small ($count files)"
    elif [ "$count" -lt 100 ]; then
        echo "medium ($count files)"
    elif [ "$count" -lt 500 ]; then
        echo "large ($count files)"
    else
        echo "very-large ($count files)"
    fi
}

# Main execution
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
OPEN_BUGS=$(get_bug_count)
NEEDS_MIGRATION=$(check_migration_needed)
RELEVANT_SKILLS=$(get_relevant_skills "$LANGUAGE" "$FRAMEWORK" "$PROJECT_TYPE")

# Write to environment file if available
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
    {
        echo "export FEATURE_DEV_PROJECT_LANGUAGE=$LANGUAGE"
        echo "export FEATURE_DEV_FRAMEWORK=$FRAMEWORK"
        echo "export FEATURE_DEV_TEST_FRAMEWORK=$TEST_FRAMEWORK"
        echo "export FEATURE_DEV_PROJECT_TYPE=$PROJECT_TYPE"
        echo "export FEATURE_DEV_PROJECT_NAME=\"$PROJECT_NAME\""
    } >> "$CLAUDE_ENV_FILE"
fi

# Build rich context message
CONTEXT_MSG="## Devloop Project Context

**Project**: $PROJECT_NAME"

if [ -n "$PROJECT_DESC" ]; then
    CONTEXT_MSG="$CONTEXT_MSG
**Description**: $PROJECT_DESC"
fi

CONTEXT_MSG="$CONTEXT_MSG

**Tech Stack**:
- Language: $LANGUAGE
- Framework: $FRAMEWORK
- Test Framework: $TEST_FRAMEWORK
- Project Type: $PROJECT_TYPE
- Size: $PROJECT_SIZE"

if [ -n "$RELEVANT_SKILLS" ]; then
    CONTEXT_MSG="$CONTEXT_MSG

**Relevant Skills**: $RELEVANT_SKILLS
  → Invoke with \`Skill: <skill-name>\` for language-specific guidance"
fi

if [ -n "$KEY_DIRS" ]; then
    CONTEXT_MSG="$CONTEXT_MSG

**Key Directories**: $KEY_DIRS"
fi

if [ -n "$CONFIG_FILES" ]; then
    CONTEXT_MSG="$CONTEXT_MSG
**Config Files**: $CONFIG_FILES"
fi

if [ "$GIT_INFO" != "not-a-git-repo" ]; then
    # Parse git info
    GIT_BRANCH=$(echo "$GIT_INFO" | sed 's/branch=\([^,]*\).*/\1/')
    GIT_UNCOMMITTED=$(echo "$GIT_INFO" | sed 's/.*uncommitted=\([^,]*\).*/\1/')
    GIT_REPO=$(echo "$GIT_INFO" | sed 's/.*repo=//')

    CONTEXT_MSG="$CONTEXT_MSG

**Git Status**:
- Branch: $GIT_BRANCH"

    if [ "$GIT_UNCOMMITTED" -gt 0 ]; then
        CONTEXT_MSG="$CONTEXT_MSG
- Uncommitted changes: $GIT_UNCOMMITTED files"
    fi

    if [ -n "$GIT_REPO" ]; then
        CONTEXT_MSG="$CONTEXT_MSG
- Repository: $GIT_REPO"
    fi
fi

if [ -n "$CLAUDE_MD" ]; then
    CONTEXT_MSG="$CONTEXT_MSG

**From CLAUDE.md**: $CLAUDE_MD..."
fi

# Add active plan info if exists
if [ -n "$ACTIVE_PLAN" ]; then
    PLAN_NAME=$(echo "$ACTIVE_PLAN" | sed 's/name=\([^,]*\).*/\1/')
    # Use || true to prevent exit on no match with set -e
    PLAN_DONE=$(echo "$ACTIVE_PLAN" | grep -o 'done=[0-9]*' | sed 's/done=//' || true)
    PLAN_TOTAL=$(echo "$ACTIVE_PLAN" | grep -o 'total=[0-9]*' | sed 's/total=//' || true)

    CONTEXT_MSG="$CONTEXT_MSG

**Active Plan**: $PLAN_NAME"
    if [ -n "$PLAN_DONE" ] && [ -n "$PLAN_TOTAL" ]; then
        CONTEXT_MSG="$CONTEXT_MSG ($PLAN_DONE/$PLAN_TOTAL tasks complete)
  → Use \`/devloop:continue\` to resume"
    fi
fi

# Add bug count if any
if [ -n "$OPEN_BUGS" ] && [ "$OPEN_BUGS" -gt 0 ]; then
    CONTEXT_MSG="$CONTEXT_MSG

**Open Bugs**: $OPEN_BUGS tracked → Use \`/devloop:bugs\` to manage"
fi

# Add migration notice if legacy files detected
if [ "$NEEDS_MIGRATION" = "true" ]; then
    CONTEXT_MSG="$CONTEXT_MSG

**Migration Available**: Legacy devloop files found in \`.claude/\`. Consider migrating to \`.devloop/\` for cleaner separation. Use AskUserQuestion to offer migration when the user runs a devloop command."
fi

CONTEXT_MSG="$CONTEXT_MSG

**Available Commands**: /devloop, /devloop:continue, /devloop:quick, /devloop:spike, /devloop:review, /devloop:ship, /devloop:bug, /devloop:bugs"

# Build brief status message for user display
STATUS_MSG="devloop: $PROJECT_NAME"
if [ "$LANGUAGE" != "unknown" ]; then
    STATUS_MSG="$STATUS_MSG ($LANGUAGE"
    if [ "$FRAMEWORK" != "none" ]; then
        STATUS_MSG="$STATUS_MSG/$FRAMEWORK"
    fi
    STATUS_MSG="$STATUS_MSG)"
fi
if [ -n "$ACTIVE_PLAN" ]; then
    PLAN_NAME=$(echo "$ACTIVE_PLAN" | sed 's/name=\([^,]*\).*/\1/')
    STATUS_MSG="$STATUS_MSG | plan: $PLAN_NAME"
fi

# Escape for JSON - use jq if available, fallback to more robust escaping
# Using hookSpecificOutput.additionalContext adds context to Claude's context
# WITHOUT displaying it in the terminal output (unlike systemMessage which is visible)
# systemMessage is shown to user but NOT added to context - used for brief status
if command -v jq &> /dev/null; then
    # Use jq for proper JSON encoding
    ESCAPED_MSG=$(printf '%s' "$CONTEXT_MSG" | jq -Rs '.')
    ESCAPED_STATUS=$(printf '%s' "$STATUS_MSG" | jq -Rs '.')
    # Output: brief status to user, full context to Claude
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
    # Fallback: escape backslashes, quotes, and control characters
    ESCAPED_MSG=$(printf '%s' "$CONTEXT_MSG" | awk '
        BEGIN { ORS = "\\n" }
        {
            gsub(/\\/, "\\\\")    # Escape backslashes first
            gsub(/"/, "\\\"")      # Escape double quotes
            gsub(/\t/, "\\t")      # Escape tabs
            gsub(/\r/, "\\r")      # Escape carriage returns
            print
        }
    ' | sed '$ s/\\n$//')
    ESCAPED_STATUS=$(printf '%s' "$STATUS_MSG" | sed 's/"/\\"/g')
    # Output: brief status to user, full context to Claude
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
