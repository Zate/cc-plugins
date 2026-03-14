#!/bin/bash
set -euo pipefail

# get-changed-files.sh — Get list of changed files for diff-only scanning.
# Usage: get-changed-files.sh [base-ref]
# Default base: main (or master if main doesn't exist)
# Output: JSON array of changed file paths

BASE_REF="${1:-}"

# Auto-detect default branch if not specified
if [ -z "$BASE_REF" ]; then
    if git rev-parse --verify main &>/dev/null; then
        BASE_REF="main"
    elif git rev-parse --verify master &>/dev/null; then
        BASE_REF="master"
    else
        # Fallback to HEAD~1 if no main/master
        BASE_REF="HEAD~1"
    fi
fi

# Verify the ref exists
if ! git rev-parse --verify "$BASE_REF" &>/dev/null; then
    echo "Error: git ref '$BASE_REF' not found" >&2
    exit 1
fi

# Get changed files (both staged and unstaged, plus untracked)
changed_files=$(
    {
        # Files changed vs base ref
        git diff --name-only "$BASE_REF" 2>/dev/null || true
        # Staged files
        git diff --name-only --cached 2>/dev/null || true
        # Untracked files
        git ls-files --others --exclude-standard 2>/dev/null || true
    } | sort -u | while read -r f; do
        # Only include files that exist and are source code
        if [ -f "$f" ]; then
            case "$f" in
                *.py|*.js|*.ts|*.tsx|*.jsx|*.go|*.java|*.rb|*.php|*.rs|*.c|*.cpp|*.h|*.hpp|*.cs|*.swift|*.kt|*.scala|*.sh|*.yaml|*.yml|*.json|*.xml|*.toml|*.cfg|*.ini|*.env*|Dockerfile*|*.tf|*.hcl)
                    echo "$f"
                    ;;
            esac
        fi
    done
)

# Output as JSON array
if [ -z "$changed_files" ]; then
    echo '{"base_ref": "'"$BASE_REF"'", "files": [], "count": 0}'
else
    count=$(echo "$changed_files" | wc -l | tr -d ' ')
    files_json=$(echo "$changed_files" | jq -R . | jq -s .)
    echo '{"base_ref": "'"$BASE_REF"'", "files": '"$files_json"', "count": '"$count"'}'
fi
