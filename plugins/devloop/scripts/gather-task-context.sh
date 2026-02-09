#!/bin/bash
# gather-task-context.sh - Find relevant files for a task description
#
# Usage:
#   ./gather-task-context.sh "task description text"
#
# Output (JSON):
#   {"files": ["path1", "path2", ...], "keywords": ["kw1", "kw2", ...]}
#
# Extracts keywords from the task description and searches the codebase
# for relevant files. Returns max 20 files sorted by relevance.

set -euo pipefail

TASK_DESC="${1:-}"

if [ -z "$TASK_DESC" ]; then
  echo '{"files": [], "keywords": [], "error": "No task description provided"}'
  exit 1
fi

# Extract meaningful keywords from task description
# Remove common words, keep nouns/verbs that identify code
KEYWORDS=$(echo "$TASK_DESC" | tr '[:upper:]' '[:lower:]' | \
  sed 's/[^a-z0-9_ -]//g' | \
  tr ' ' '\n' | \
  grep -vE '^(the|a|an|to|in|for|of|and|or|is|it|this|that|with|from|as|on|at|by|be|do|if|no|not|but|all|can|has|may|new|one|our|out|own|say|she|too|use|her|was|add|create|update|replace|remove|fix|write|implement|task|step)$' | \
  grep -E '.{3,}' | \
  sort -u | \
  head -10)

if [ -z "$KEYWORDS" ]; then
  echo '{"files": [], "keywords": [], "error": "No keywords extracted"}'
  exit 0
fi

# Search for files matching keywords
FILES=""
for kw in $KEYWORDS; do
  # Search file contents
  MATCHES=$(grep -rl --include='*.md' --include='*.sh' --include='*.ts' \
    --include='*.js' --include='*.py' --include='*.go' --include='*.json' \
    --include='*.yaml' --include='*.yml' --include='*.toml' \
    -i "$kw" . 2>/dev/null | \
    grep -v node_modules | \
    grep -v '.git/' | \
    grep -v '.devloop/' | \
    head -5 || true)
  FILES="$FILES $MATCHES"

  # Search file names
  NAME_MATCHES=$(find . -type f \( -name "*${kw}*" \) \
    ! -path '*/node_modules/*' \
    ! -path '*/.git/*' \
    ! -path '*/.devloop/*' \
    2>/dev/null | head -3 || true)
  FILES="$FILES $NAME_MATCHES"
done

# Deduplicate, sort, limit to 20
UNIQUE_FILES=$(echo "$FILES" | tr ' ' '\n' | \
  sed 's|^\./||' | \
  grep -v '^$' | \
  sort -u | \
  head -20)

# Format as JSON
KEYWORDS_JSON=$(echo "$KEYWORDS" | tr '\n' ',' | sed 's/,$//' | sed 's/\([^,]*\)/"\1"/g')
FILES_JSON=$(echo "$UNIQUE_FILES" | tr '\n' ',' | sed 's/,$//' | sed 's/\([^,]*\)/"\1"/g')

echo "{\"files\": [${FILES_JSON}], \"keywords\": [${KEYWORDS_JSON}]}"
