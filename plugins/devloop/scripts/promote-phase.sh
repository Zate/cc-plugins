#!/bin/bash
# promote-phase.sh - Promote next epic phase to plan.md
#
# Usage:
#   ./promote-phase.sh [epic-file] [--phase N] [--force]
#
# Reads epic.json for state, epic.md for task content.
# Output (JSON):
#   {"promoted": true, "phase": N, "phase_name": "...", "tasks": N, "plan_path": "..."}
#
# Exit codes:
#   0 - Phase promoted successfully
#   1 - No pending phases
#   2 - No epic file found
#   3 - Plan has incomplete tasks (use --force)

set -euo pipefail

EPIC_DIR=".devloop"
EPIC_JSON="$EPIC_DIR/epic.json"
EPIC_MD="$EPIC_DIR/epic.md"
TARGET_PHASE=""
FORCE=false

# Parse args
while [ $# -gt 0 ]; do
    case "$1" in
        --phase) TARGET_PHASE="$2"; shift 2 ;;
        --force) FORCE=true; shift ;;
        *) EPIC_MD="$1"; shift ;;
    esac
done

# Check epic.json first (primary state), fall back to epic.md
if [ ! -f "$EPIC_JSON" ] && [ ! -f "$EPIC_MD" ]; then
    echo '{"error": "no_epic", "message": "No epic.json or epic.md found"}'
    exit 2
fi

# Check if plan.md has incomplete tasks
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$EPIC_DIR/plan.md" ] && [ "$FORCE" != "true" ]; then
    if ! "$SCRIPT_DIR/check-plan-complete.sh" "$EPIC_DIR/plan.md" >/dev/null 2>&1; then
        echo '{"error": "plan_incomplete", "message": "Plan has incomplete tasks. Use --force to override."}'
        exit 3
    fi
fi

# Determine target phase
if [ -z "$TARGET_PHASE" ]; then
    if [ -f "$EPIC_JSON" ] && command -v jq &>/dev/null; then
        TARGET_PHASE=$(jq -r '.current_phase' "$EPIC_JSON")
    elif [ -f "$EPIC_JSON" ]; then
        TARGET_PHASE=$(grep -o '"current_phase": *[0-9]*' "$EPIC_JSON" | grep -o '[0-9]*')
    else
        # Fall back to epic.md tracker table
        TARGET_PHASE=$(grep -E "^\|[[:space:]]*[0-9]+" "$EPIC_MD" | while IFS='|' read -r _ num _ _ status _; do
            num=$(echo "$num" | tr -d ' ')
            status=$(echo "$status" | tr -d ' `' | tr '[:upper:]' '[:lower:]')
            if [ "$status" = "pending" ] || [ "$status" = "in_progress" ]; then
                echo "$num"
                break
            fi
        done)
    fi
fi

if [ -z "$TARGET_PHASE" ]; then
    echo '{"error": "no_pending", "message": "No pending phases found"}'
    exit 1
fi

# Extract epic title
EPIC_TITLE=$(grep -m1 "^# " "$EPIC_MD" | sed 's/^# //' | sed 's/^Epic: //')

# Extract phase content from epic.md
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
        if echo "$line" | grep -qE "^### Phase [0-9]+:|^## "; then
            break
        fi
        PHASE_CONTENT="$PHASE_CONTENT$line
"
    fi
done < "$EPIC_MD"

if [ -z "$PHASE_NAME" ]; then
    echo "{\"error\": \"phase_not_found\", \"message\": \"Phase $TARGET_PHASE not found in epic.md\"}"
    exit 1
fi

# Count tasks in the phase
TASK_COUNT=$(echo "$PHASE_CONTENT" | grep -cE "^\s*- \[[ x~!-]\]" 2>/dev/null) || TASK_COUNT=0

# Generate plan.md
TODAY=$(date +%Y-%m-%d)
cat > "$EPIC_DIR/plan.md" <<PLAN
# Devloop Plan: Phase $TARGET_PHASE -- $PHASE_NAME

**Created**: $TODAY
**Updated**: $TODAY
**Status**: In Progress
**Epic**: .devloop/epic.json (Phase $TARGET_PHASE of $EPIC_TITLE)
**Phase**: $TARGET_PHASE

## Overview

Phase $TARGET_PHASE of Epic: $EPIC_TITLE -- $PHASE_NAME

## Phase $TARGET_PHASE: $PHASE_NAME

$PHASE_CONTENT
## Progress Log

PLAN

# Update epic.md tracker: mark phase as in_progress
sed -i "s/^\(|[[:space:]]*$TARGET_PHASE[[:space:]]*|.*|\)[[:space:]]*\`*pending\`*[[:space:]]*|/\1 \`in_progress\` |/" "$EPIC_MD"

# Update epic.json if it exists
if [ -f "$EPIC_JSON" ]; then
    if command -v jq &>/dev/null; then
        # Use jq for reliable JSON updates
        jq --argjson phase "$TARGET_PHASE" '
            .current_phase = $phase |
            .status = "in_progress" |
            (.phases[] | select(.number == $phase)).status = "in_progress"
        ' "$EPIC_JSON" > "$EPIC_JSON.tmp" && mv "$EPIC_JSON.tmp" "$EPIC_JSON"
    else
        # Fallback: simple sed replacements
        sed -i "s/\"current_phase\": *[0-9]*/\"current_phase\": $TARGET_PHASE/" "$EPIC_JSON"
        sed -i "s/\"status\": *\"planning\"/\"status\": \"in_progress\"/" "$EPIC_JSON"
    fi
fi

# Output JSON
cat <<EOF
{"promoted": true, "phase": $TARGET_PHASE, "phase_name": "$PHASE_NAME", "tasks": $TASK_COUNT, "plan_path": "$EPIC_DIR/plan.md", "epic": "$EPIC_JSON"}
EOF

exit 0
