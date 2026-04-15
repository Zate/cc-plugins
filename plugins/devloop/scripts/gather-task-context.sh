#!/bin/bash
# gather-task-context.sh - Find relevant files for a task description
#
# Usage:
#   ./gather-task-context.sh "task description text" [--token-budget N]
#
# Output (JSON):
#   {"files": ["path1", "path2", ...], "keywords": ["kw1", "kw2", ...]}
#
# Extracts keywords from the task description and searches the codebase
# for relevant files. Returns files prioritized by relevance, capped at
# the token budget (default 4000 tokens, ~4 chars per token).
#
# Priority order:
#   1. Files directly mentioned in the task description (by name)
#   2. Files matching keywords in content/filename
#
# --token-budget N: Estimate tokens per file (~4 chars/token) and stop
#   collecting when the budget is reached. Default: 4000 tokens.

set -euo pipefail

TASK_DESC="${1:-}"
TOKEN_BUDGET=4000

# Parse optional --token-budget argument
shift 2>/dev/null || true
while [ $# -gt 0 ]; do
  case "$1" in
    --token-budget)
      TOKEN_BUDGET="${2:-4000}"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

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

# Convert budget to approximate char limit (4 chars per token)
CHAR_BUDGET=$((TOKEN_BUDGET * 4))
BUDGET_USED=0

# Phase 1: Directly mentioned files (highest priority)
# Look for file-like patterns in the task description (with extension or slash)
DIRECT_FILES=""
for kw in $KEYWORDS; do
  DIRECT=$(find . -type f \( -name "${kw}" -o -name "${kw}.*" \) \
    ! -path '*/node_modules/*' \
    ! -path '*/.git/*' \
    ! -path '*/.devloop/*' \
    2>/dev/null | head -3 || true)
  DIRECT_FILES="$DIRECT_FILES $DIRECT"
done

# Phase 2: Keyword matches in content and filenames
KEYWORD_FILES=""
for kw in $KEYWORDS; do
  # Search file contents
  MATCHES=$(grep -rl --include='*.md' --include='*.sh' --include='*.ts' \
    --include='*.js' --include='*.py' --include='*.go' --include='*.json' \
    --include='*.yaml' --include='*.yml' --include='*.toml' --include='*.ps1' \
    -i "$kw" . 2>/dev/null | \
    grep -v node_modules | \
    grep -v '.git/' | \
    grep -v '.devloop/' | \
    head -5 || true)
  KEYWORD_FILES="$KEYWORD_FILES $MATCHES"

  # Search file names
  NAME_MATCHES=$(find . -type f \( -name "*${kw}*" \) \
    ! -path '*/node_modules/*' \
    ! -path '*/.git/*' \
    ! -path '*/.devloop/*' \
    2>/dev/null | head -3 || true)
  KEYWORD_FILES="$KEYWORD_FILES $NAME_MATCHES"
done

# Merge: direct files first (highest priority), then keyword matches
ALL_FILES="$DIRECT_FILES $KEYWORD_FILES"

# Deduplicate and normalize paths
UNIQUE_FILES=$(echo "$ALL_FILES" | tr ' ' '\n' | \
  sed 's|^\./||' | \
  grep -v '^$' | \
  awk '!seen[$0]++')

# Apply token budget: estimate file size and stop when budget exhausted
SELECTED_FILES=""
while IFS= read -r fpath; do
  [ -z "$fpath" ] && continue
  if [ -f "$fpath" ]; then
    FILE_SIZE=$(wc -c < "$fpath" 2>/dev/null || echo 0)
  else
    FILE_SIZE=0
  fi
  BUDGET_USED=$((BUDGET_USED + FILE_SIZE))
  SELECTED_FILES="$SELECTED_FILES
$fpath"
  if [ "$BUDGET_USED" -ge "$CHAR_BUDGET" ]; then
    break
  fi
done <<< "$UNIQUE_FILES"

# Final list: deduplicated, budget-limited
FINAL_FILES=$(echo "$SELECTED_FILES" | \
  grep -v '^$' | \
  head -20)

# Format as JSON
KEYWORDS_JSON=$(echo "$KEYWORDS" | tr '\n' ',' | sed 's/,$//' | sed 's/\([^,]*\)/"\1"/g')
FILES_JSON=$(echo "$FINAL_FILES" | tr '\n' ',' | sed 's/,$//' | sed 's/\([^,]*\)/"\1"/g')

echo "{\"files\": [${FILES_JSON}], \"keywords\": [${KEYWORDS_JSON}]}"
