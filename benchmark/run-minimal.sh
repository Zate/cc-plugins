#!/bin/bash
# Minimal benchmark - stripped down for debugging
set -x  # Show commands as they run

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASK_FILE="$SCRIPT_DIR/task-fastify-api.md"

PROJECT_DIR=$(mktemp -d -t bench-XXXXXX)
cd "$PROJECT_DIR"
git init --quiet

echo "=== Project dir: $PROJECT_DIR ==="
echo "=== Starting Claude ==="

#  Minimal flags - add back one at a time to find the problem
claude -p "$(cat "$TASK_FILE")" \
    --dangerously-skip-permissions \
    --output-format json

echo "=== Exit code: $? ==="
echo "=== Files created ==="
find . -type f ! -path "./.git/*" | head -20
