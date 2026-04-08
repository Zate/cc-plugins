#!/bin/bash
# promote-phase.sh - Promote an epic phase to plan.md
#
# Usage:
#   ./promote-phase.sh [--phase N] [--force]
#
# Reads .devloop/epic.json for state, .devloop/epic.md for task content.
# Writes .devloop/plan.md and updates both epic files.
#
# Exit codes:
#   0 - Phase promoted
#   1 - No pending phases
#   2 - No epic found
#   3 - Plan has incomplete tasks (use --force)

set -euo pipefail

EPIC_DIR=".devloop"
EPIC_JSON="$EPIC_DIR/epic.json"
EPIC_MD="$EPIC_DIR/epic.md"
TARGET_PHASE=""
FORCE=false
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

while [ $# -gt 0 ]; do
    case "$1" in
        --phase) TARGET_PHASE="$2"; shift 2 ;;
        --force) FORCE=true; shift ;;
        *) shift ;;
    esac
done

if [ ! -f "$EPIC_JSON" ] || [ ! -f "$EPIC_MD" ]; then
    echo '{"error": "no_epic", "message": "epic.json and epic.md are both required"}'
    exit 2
fi

# Guard against overwriting incomplete plan
if [ -f "$EPIC_DIR/plan.md" ] && [ "$FORCE" != "true" ]; then
    if ! "$SCRIPT_DIR/check-plan-complete.sh" "$EPIC_DIR/plan.md" >/dev/null 2>&1; then
        echo '{"error": "plan_incomplete", "message": "Plan has incomplete tasks. Use --force to override."}'
        exit 3
    fi
fi

# Get target phase from epic.json
if [ -z "$TARGET_PHASE" ]; then
    if command -v jq &>/dev/null; then
        TARGET_PHASE=$(jq -r '.current_phase' "$EPIC_JSON")
    else
        TARGET_PHASE=$(grep -o '"current_phase": *[0-9]*' "$EPIC_JSON" | grep -o '[0-9]*')
    fi
fi

if [ -z "$TARGET_PHASE" ]; then
    echo '{"error": "no_pending", "message": "No pending phases found"}'
    exit 1
fi

# Extract epic title and phase content from epic.md
EPIC_TITLE=$(grep -m1 "^# " "$EPIC_MD" | sed 's/^# //' | sed 's/^Epic: //')
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

TASK_COUNT=$(echo "$PHASE_CONTENT" | grep -cE "^\s*- \[[ x~!-]\]" 2>/dev/null) || TASK_COUNT=0
TODAY=$(date +%Y-%m-%d)

# Write plan.md
cat > "$EPIC_DIR/plan.md" <<PLAN
# Devloop Plan: Phase $TARGET_PHASE -- $PHASE_NAME

**Created**: $TODAY
**Updated**: $TODAY
**Status**: In Progress
**Epic**: .devloop/epic.json
**Phase**: $TARGET_PHASE

## Overview

Phase $TARGET_PHASE of Epic: $EPIC_TITLE -- $PHASE_NAME

## Phase $TARGET_PHASE: $PHASE_NAME

$PHASE_CONTENT
## Progress Log

PLAN

# Update epic.json
if command -v jq &>/dev/null; then
    jq --argjson phase "$TARGET_PHASE" '
        .current_phase = $phase |
        .status = "in_progress" |
        (.phases[] | select(.number == $phase)).status = "in_progress"
    ' "$EPIC_JSON" > "$EPIC_JSON.tmp" && mv "$EPIC_JSON.tmp" "$EPIC_JSON"
fi

# Update epic.md tracker (best-effort sed, agent can fix if needed)
sed -i "s/^\(|[[:space:]]*$TARGET_PHASE[[:space:]]*|.*|\)[[:space:]]*\`*pending\`*[[:space:]]*|/\1 \`in_progress\` |/" "$EPIC_MD" 2>/dev/null || true

cat <<EOF
{"promoted": true, "phase": $TARGET_PHASE, "phase_name": "$PHASE_NAME", "tasks": $TASK_COUNT, "plan_path": "$EPIC_DIR/plan.md"}
EOF
