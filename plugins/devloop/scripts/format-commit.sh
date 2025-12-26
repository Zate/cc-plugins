#!/bin/bash
# format-commit.sh - Generate conventional commit messages from task context
#
# Central script for formatting commit messages following conventional commits
# and atomic-commits skill guidelines.
#
# Usage:
#   format-commit.sh "task-description" [file-list]
#   format-commit.sh --type TYPE "description"
#   format-commit.sh --tasks "1.1,1.2" "combined description"
#   format-commit.sh --breaking "description"
#
# Output: Formatted commit message ready for: git commit -F -
#
# Examples:
#   format-commit.sh "implement user authentication"
#   format-commit.sh --type feat --scope auth "add login endpoint - Task 2.1"
#   format-commit.sh --tasks "2.1,2.2" "implement auth with tests"

set -uo pipefail

# Commit types following conventional commits
declare -A TYPE_DESCRIPTIONS=(
    ["feat"]="A new feature"
    ["fix"]="A bug fix"
    ["docs"]="Documentation only changes"
    ["style"]="Formatting, missing semi colons, etc"
    ["refactor"]="Code change that neither fixes a bug nor adds a feature"
    ["perf"]="Performance improvement"
    ["test"]="Adding or correcting tests"
    ["build"]="Changes to build system or dependencies"
    ["ci"]="Changes to CI configuration"
    ["chore"]="Other changes that don't modify src or test files"
    ["revert"]="Reverts a previous commit"
)

# Helper functions
error() { echo "Error: $1" >&2; }

# Detect commit type from description
detect_type() {
    local desc="$1"
    desc=$(echo "$desc" | tr '[:upper:]' '[:lower:]')

    # Check for explicit type prefix
    if [[ "$desc" =~ ^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert): ]]; then
        echo "${BASH_REMATCH[1]}"
        return
    fi

    # Keyword-based detection
    case "$desc" in
        *"add"*|*"implement"*|*"create"*|*"new"*)
            echo "feat"
            ;;
        *"fix"*|*"bug"*|*"repair"*|*"correct"*)
            echo "fix"
            ;;
        *"test"*|*"spec"*|*"coverage"*)
            echo "test"
            ;;
        *"doc"*|*"readme"*|*"comment"*)
            echo "docs"
            ;;
        *"refactor"*|*"restructure"*|*"reorganize"*|*"extract"*|*"move"*)
            echo "refactor"
            ;;
        *"performance"*|*"optimize"*|*"speed"*|*"faster"*)
            echo "perf"
            ;;
        *"build"*|*"dependency"*|*"package"*)
            echo "build"
            ;;
        *"ci"*|*"pipeline"*|*"workflow"*)
            echo "ci"
            ;;
        *"update"*|*"upgrade"*|*"bump"*)
            echo "chore"
            ;;
        *)
            echo "feat"  # Default to feat
            ;;
    esac
}

# Extract scope from file paths
extract_scope() {
    local files="$1"

    if [ -z "$files" ]; then
        return
    fi

    # Common scope patterns
    local scope=""

    # Check for common directories
    if echo "$files" | grep -q "auth\|login\|session"; then
        scope="auth"
    elif echo "$files" | grep -q "api\|endpoint\|handler"; then
        scope="api"
    elif echo "$files" | grep -q "ui\|component\|view"; then
        scope="ui"
    elif echo "$files" | grep -q "db\|database\|migration\|model"; then
        scope="db"
    elif echo "$files" | grep -q "test\|spec"; then
        scope="test"
    elif echo "$files" | grep -q "config\|settings"; then
        scope="config"
    elif echo "$files" | grep -q "hook"; then
        scope="hooks"
    elif echo "$files" | grep -q "skill"; then
        scope="skills"
    elif echo "$files" | grep -q "command"; then
        scope="commands"
    elif echo "$files" | grep -q "agent"; then
        scope="agents"
    elif echo "$files" | grep -q "script"; then
        scope="scripts"
    fi

    echo "$scope"
}

# Extract task references from description
extract_tasks() {
    local desc="$1"

    # Look for Task X.Y patterns
    local tasks=""
    while [[ "$desc" =~ Task[[:space:]]+([0-9]+\.[0-9]+) ]]; do
        if [ -n "$tasks" ]; then
            tasks="$tasks, ${BASH_REMATCH[1]}"
        else
            tasks="${BASH_REMATCH[1]}"
        fi
        desc="${desc#*${BASH_REMATCH[0]}}"
    done

    echo "$tasks"
}

# Clean description (remove type prefix and task refs if we'll add them back)
clean_description() {
    local desc="$1"

    # Remove type prefix (feat: fix: etc)
    desc=$(echo "$desc" | sed 's/^[a-z]*([a-z]*): //')
    desc=$(echo "$desc" | sed 's/^[a-z]*: //')

    # Remove standalone "- Task X.Y" suffix
    desc=$(echo "$desc" | sed 's/ - Task [0-9]\+\.[0-9]\+$//')

    # Trim whitespace
    desc=$(echo "$desc" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    echo "$desc"
}

# Format the commit message
format_message() {
    local type="$1"
    local scope="$2"
    local description="$3"
    local tasks="$4"
    local body="$5"
    local breaking="$6"

    # Build subject line
    local subject=""
    if [ -n "$scope" ]; then
        subject="$type($scope): $description"
    else
        subject="$type: $description"
    fi

    # Add task reference to subject if single task
    if [ -n "$tasks" ] && ! [[ "$tasks" =~ , ]]; then
        subject="$subject - Task $tasks"
    fi

    # Build full message
    echo "$subject"

    # Add body if provided or if multiple tasks
    if [ -n "$body" ] || [[ "$tasks" =~ , ]]; then
        echo ""

        if [ -n "$body" ]; then
            echo "$body"
            echo ""
        fi

        # List tasks in body for multiple tasks
        if [[ "$tasks" =~ , ]]; then
            echo "Tasks completed:"
            IFS=',' read -ra task_array <<< "$tasks"
            for task in "${task_array[@]}"; do
                task=$(echo "$task" | tr -d ' ')
                echo "- Task $task"
            done
            echo ""
        fi
    fi

    # Add breaking change footer
    if [ -n "$breaking" ]; then
        echo ""
        echo "BREAKING CHANGE: $breaking"
    fi
}

# Main logic
main() {
    local type=""
    local scope=""
    local tasks=""
    local body=""
    local breaking=""
    local files=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --type|-t)
                type="$2"
                shift 2
                ;;
            --scope|-s)
                scope="$2"
                shift 2
                ;;
            --tasks)
                tasks="$2"
                shift 2
                ;;
            --body|-b)
                body="$2"
                shift 2
                ;;
            --breaking)
                breaking="$2"
                shift 2
                ;;
            --files|-f)
                files="$2"
                shift 2
                ;;
            --help|-h)
                echo "Usage: format-commit.sh [OPTIONS] description [files]"
                echo ""
                echo "Options:"
                echo "  --type, -t TYPE      Commit type (feat, fix, docs, etc.)"
                echo "  --scope, -s SCOPE    Commit scope (auth, api, ui, etc.)"
                echo "  --tasks TASKS        Task IDs (e.g., '1.1' or '1.1,1.2')"
                echo "  --body, -b BODY      Commit body text"
                echo "  --breaking TEXT      Breaking change description"
                echo "  --files, -f FILES    File list for scope detection"
                echo "  --help               Show this help"
                echo ""
                echo "Commit Types:"
                for t in "${!TYPE_DESCRIPTIONS[@]}"; do
                    printf "  %-10s %s\n" "$t" "${TYPE_DESCRIPTIONS[$t]}"
                done
                exit 0
                ;;
            -*)
                error "Unknown option: $1"
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done

    # Get description (first positional argument)
    if [ $# -lt 1 ]; then
        error "Missing description"
        echo "Usage: format-commit.sh [OPTIONS] description [files]" >&2
        exit 1
    fi

    local description="$1"
    shift

    # Get files (optional second positional argument)
    if [ $# -gt 0 ]; then
        files="$1"
    fi

    # Auto-detect type if not specified
    if [ -z "$type" ]; then
        type=$(detect_type "$description")
    fi

    # Auto-detect scope if not specified
    if [ -z "$scope" ] && [ -n "$files" ]; then
        scope=$(extract_scope "$files")
    fi

    # Extract tasks from description if not specified
    if [ -z "$tasks" ]; then
        tasks=$(extract_tasks "$description")
    fi

    # Clean description
    description=$(clean_description "$description")

    # Lowercase first letter of description (conventional commits style)
    if [ -n "$description" ]; then
        description="$(echo "${description:0:1}" | tr '[:upper:]' '[:lower:]')${description:1}"
    fi

    # Format and output the message
    format_message "$type" "$scope" "$description" "$tasks" "$body" "$breaking"
}

main "$@"
