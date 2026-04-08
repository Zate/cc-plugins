#!/bin/bash
# promote-phase.sh - Promote next epic phase to plan.md
#
# Usage:
#   ./promote-phase.sh [epic-file] [--phase N] [--force]
#
# Output (JSON):
#   {"promoted": true, "phase": N, "phase_name": "...", "tasks": N, "plan_path": "..."}
#
# Exit codes:
#   0 - Phase promoted successfully
#   1 - No pending phases
#   2 - No epic file found
#   3 - Plan has incomplete tasks (use --force)

set -euo pipefail

EPIC_FILE=".devloop/epic.md"
TARGET_PHASE=""
FORCE=false

# Parse args
while [ $# -gt 0 ]; do
    case "$1" in
        --phase) TARGET_PHASE="$2"; shift 2 ;;
        --force) FORCE=true; shift ;;
        *) EPIC_FILE="$1"; shift ;;
    esac
done

if [ ! -f "$EPIC_FILE" ]; then
    echo '{"error": "no_epic", "message": "Epic file not found"}'
    exit 2
fi

# Check if plan.md has incomplete tasks
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f ".devloop/plan.md" ] && [ "$FORCE" != "true" ]; then
    if ! "$SCRIPT_DIR/check-plan-complete.sh" .devloop/plan.md >/dev/null 2>&1; then
        echo '{"error": "plan_incomplete", "message": "Plan has incomplete tasks. Use --force to override."}'
        exit 3
    fi
fi

# Extract epic title
EPIC_TITLE=$(grep -m1 "^# " "$EPIC_FILE" | sed 's/^# //' | sed 's/^Epic: //')

# Find target phase
if [ -z "$TARGET_PHASE" ]; then
    # Find first pending/in_progress phase from tracker table
    TARGET_PHASE=$(grep -E "^\|[[:space:]]*[0-9]+" "$EPIC_FILE" | while IFS='|' read -r _ num _ _ status _; do
        num=$(echo "$num" | tr -d ' ')
        status=$(echo "$status" | tr -d ' `' | tr '[:upper:]' '[:lower:]')
        if [ "$status" = "pending" ] || [ "$status" = "in_progress" ]; then
            echo "$num"
            break
        fi
    done)
fi

if [ -z "$TARGET_PHASE" ]; then
    echo '{"error": "no_pending", "message": "No pending phases found"}'
    exit 1
fi

# Extract phase content from epic.md
# Find the phase header and capture everything until the next phase header or ---
PHASE_NAME=""
PHASE_CONTENT=""
IN_PHASE=false

while IFS= read -r line; do
    if echo "$line" | grep -qE "^### Phase $TARGET_PHASE:"; then
        IN_PHASE=true
        PHASE_NAME=$(echo "$line" | sed "s/^### Phase $TARGET_PHASE: //")
        continue
    fi
    if [ "$IN_PHASE" = true ]; then
        # Stop at next phase header or end marker
        if echo "$line" | grep -qE "^### Phase [0-9]+:|^---$|^## "; then
            break
        fi
        PHASE_CONTENT="$PHASE_CONTENT$line
"
    fi
done < "$EPIC_FILE"

if [ -z "$PHASE_NAME" ]; then
    echo "{\"error\": \"phase_not_found\", \"message\": \"Phase $TARGET_PHASE not found in epic\"}"
    exit 1
fi

# Count tasks in the phase
TASK_COUNT=$(echo "$PHASE_CONTENT" | grep -cE "^\s*- \[[ x~!-]\]" 2>/dev/null) || TASK_COUNT=0

# Generate plan.md
TODAY=$(date +%Y-%m-%d)
cat > .devloop/plan.md <<PLAN
# Devloop Plan: Phase $TARGET_PHASE -- $PHASE_NAME

**Created**: $TODAY
**Updated**: $TODAY
**Status**: In Progress
**Epic**: $EPIC_FILE (Phase $TARGET_PHASE of $EPIC_TITLE)
**Phase**: $TARGET_PHASE

## Overview

Phase $TARGET_PHASE of Epic: $EPIC_TITLE -- $PHASE_NAME

## Phase $TARGET_PHASE: $PHASE_NAME

$PHASE_CONTENT
## Progress Log

PLAN

# Update epic tracker: mark phase as in_progress
sed -i "s/^\(|[[:space:]]*$TARGET_PHASE[[:space:]]*|.*|\)[[:space:]]*\`*pending\`*[[:space:]]*|/\1 \`in_progress\` |/" "$EPIC_FILE"

# Update epic timestamp
sed -i "s/^\*\*Updated\*\*:.*/\*\*Updated\*\*: $TODAY/" "$EPIC_FILE"
sed -i "s/^\*\*Status\*\*:.*/\*\*Status\*\*: In Progress/" "$EPIC_FILE"
sed -i "s/^\*\*Current Phase\*\*:.*/\*\*Current Phase\*\*: $TARGET_PHASE/" "$EPIC_FILE"

# Output JSON
cat <<EOF
{"promoted": true, "phase": $TARGET_PHASE, "phase_name": "$PHASE_NAME", "tasks": $TASK_COUNT, "plan_path": ".devloop/plan.md", "epic": "$EPIC_FILE"}
EOF

exit 0
