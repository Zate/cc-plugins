#!/bin/sh
# analyze-sync.sh — Dump both memory systems for comparison analysis
# Usage: analyze-sync.sh [project-name]
# Outputs JSON with ctx nodes and MEMORY.md contents for the detected project

set -e

PROJECT="${1:-}"

# Detect project from git if not provided
if [ -z "$PROJECT" ]; then
  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    PROJECT="$(basename "$(git rev-parse --show-toplevel)" 2>/dev/null || echo "")"
  fi
fi

# Find MEMORY.md for this project
CLAUDE_DIR="$HOME/.claude/projects"
MEMORY_DIR=""
MEMORY_CONTENT=""

if [ -d "$CLAUDE_DIR" ]; then
  # Search for project directory matching the project name
  for d in "$CLAUDE_DIR"/*/memory; do
    if [ -d "$d" ] && echo "$d" | grep -qi "$PROJECT"; then
      MEMORY_DIR="$d"
      break
    fi
  done

  if [ -n "$MEMORY_DIR" ] && [ -f "$MEMORY_DIR/MEMORY.md" ]; then
    MEMORY_CONTENT="$(cat "$MEMORY_DIR/MEMORY.md")"
  fi

  # Also collect supplemental memory files
  MEMORY_FILES=""
  if [ -n "$MEMORY_DIR" ]; then
    for f in "$MEMORY_DIR"/*.md; do
      [ -f "$f" ] || continue
      fname="$(basename "$f")"
      [ "$fname" = "MEMORY.md" ] && continue
      MEMORY_FILES="$MEMORY_FILES $fname"
    done
  fi
fi

echo "=== SYNC ANALYSIS REPORT ==="
echo ""
echo "Project: ${PROJECT:-unknown}"
echo "Memory dir: ${MEMORY_DIR:-not found}"
echo "Supplemental files:${MEMORY_FILES:- none}"
echo ""

echo "--- MEMORY.md CONTENTS ---"
if [ -n "$MEMORY_CONTENT" ]; then
  echo "$MEMORY_CONTENT"
else
  echo "(empty or not found)"
fi
echo ""

echo "--- CTX STATUS ---"
if command -v ctx >/dev/null 2>&1; then
  ctx status 2>&1
else
  echo "ctx binary not found"
  exit 1
fi

echo ""
echo "--- CTX PINNED NODES ---"
ctx list --tag tier:pinned --format json 2>/dev/null || ctx list --tag tier:pinned 2>&1

echo ""
echo "--- CTX WORKING NODES ---"
ctx list --tag tier:working --format json 2>/dev/null || ctx list --tag tier:working 2>&1

echo ""
echo "--- CTX REFERENCE NODES (project only) ---"
if [ -n "$PROJECT" ]; then
  ctx list --tag "tier:reference" --tag "project:$PROJECT" --format json 2>/dev/null || \
  ctx list --tag "tier:reference" --tag "project:$PROJECT" 2>&1
else
  echo "(no project detected, skipping project-scoped reference nodes)"
fi

echo ""
echo "--- CTX TAGS ---"
ctx tags 2>&1

echo ""
echo "--- CTX ALL NODES (full dump) ---"
ctx export 2>&1
