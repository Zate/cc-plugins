#!/bin/bash
# check-epic-state.sh - Check epic state from epic.json (with epic.md fallback)
#
# Usage:
#   ./check-epic-state.sh [epic-dir]
#
# Output (JSON):
#   {"exists": true, "title": "...", "status": "...", "total_phases": N,
#    "completed_phases": N, "current_phase": N, "current_phase_name": "...",
#    "plan_complete": bool, "all_complete": bool, "test_command": "..."}
#
# Exit codes:
#   0 - All phases complete
#   1 - Phases pending
#   2 - No epic found

set -euo pipefail

EPIC_DIR="${1:-.devloop}"
EPIC_JSON="$EPIC_DIR/epic.json"
EPIC_MD="$EPIC_DIR/epic.md"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Try epic.json first (primary), fall back to epic.md
if [ -f "$EPIC_JSON" ]; then
    # Parse from JSON
    if command -v jq &>/dev/null; then
        TITLE=$(jq -r '.title' "$EPIC_JSON")
        STATUS=$(jq -r '.status' "$EPIC_JSON")
        TOTAL_PHASES=$(jq '.phases | length' "$EPIC_JSON")
        COMPLETED_PHASES=$(jq '[.phases[] | select(.status == "complete")] | length' "$EPIC_JSON")
        CURRENT_PHASE=$(jq -r '.current_phase' "$EPIC_JSON")
        CURRENT_PHASE_NAME=$(jq -r --argjson p "$CURRENT_PHASE" '.phases[] | select(.number == $p) | .name // "Unknown"' "$EPIC_JSON")
        CURRENT_PHASE_STATUS=$(jq -r --argjson p "$CURRENT_PHASE" '.phases[] | select(.number == $p) | .status // "pending"' "$EPIC_JSON")
        TEST_COMMAND=$(jq -r '.test_command // ""' "$EPIC_JSON")
    else
        # Fallback: grep-based parsing
        TITLE=$(grep -o '"title": *"[^"]*"' "$EPIC_JSON" | head -1 | sed 's/"title": *"//;s/"$//')
        STATUS=$(grep -o '"status": *"[^"]*"' "$EPIC_JSON" | head -1 | sed 's/"status": *"//;s/"$//')
        TOTAL_PHASES=$(grep -c '"number":' "$EPIC_JSON" 2>/dev/null) || TOTAL_PHASES=0
        COMPLETED_PHASES=$(grep -c '"status": *"complete"' "$EPIC_JSON" 2>/dev/null) || COMPLETED_PHASES=0
        # Subtract 1 if top-level status is also "complete"
        if [ "$STATUS" = "complete" ] && [ "$COMPLETED_PHASES" -gt "$TOTAL_PHASES" ]; then
            COMPLETED_PHASES=$TOTAL_PHASES
        fi
        CURRENT_PHASE=$(grep -o '"current_phase": *[0-9]*' "$EPIC_JSON" | grep -o '[0-9]*')
        CURRENT_PHASE_NAME="Unknown"
        CURRENT_PHASE_STATUS="pending"
        TEST_COMMAND=$(grep -o '"test_command": *"[^"]*"' "$EPIC_JSON" | head -1 | sed 's/"test_command": *"//;s/"$//')
    fi
elif [ -f "$EPIC_MD" ]; then
    # Fall back to epic.md parsing
    TITLE=$(grep -m1 "^# " "$EPIC_MD" | sed 's/^# //' | sed 's/^Epic: //')
    STATUS="unknown"
    TOTAL_PHASES=0
    COMPLETED_PHASES=0
    CURRENT_PHASE=0
    CURRENT_PHASE_NAME=""
    CURRENT_PHASE_STATUS=""
    TEST_COMMAND=""

    while IFS='|' read -r _ phase_num name tasks status _; do
        phase_num=$(echo "$phase_num" | tr -d ' ')
        status=$(echo "$status" | tr -d ' `' | tr '[:upper:]' '[:lower:]')
        case "$phase_num" in
            ''|*[!0-9]*) continue ;;
        esac
        TOTAL_PHASES=$((TOTAL_PHASES + 1))
        if [ "$status" = "complete" ]; then
            COMPLETED_PHASES=$((COMPLETED_PHASES + 1))
        elif [ "$CURRENT_PHASE" -eq 0 ]; then
            CURRENT_PHASE=$phase_num
            CURRENT_PHASE_NAME=$(echo "$name" | sed 's/^ *//;s/ *$//')
            CURRENT_PHASE_STATUS="$status"
        fi
    done < <(grep "^|" "$EPIC_MD" | grep -v "^|[-]" | grep -v "^| Phase")

    if [ "$COMPLETED_PHASES" -eq "$TOTAL_PHASES" ] && [ "$TOTAL_PHASES" -gt 0 ]; then
        STATUS="complete"
    elif [ "$COMPLETED_PHASES" -gt 0 ]; then
        STATUS="in_progress"
    else
        STATUS="planning"
    fi
else
    echo '{"exists": false, "error": "no_epic", "message": "No epic.json or epic.md found"}'
    exit 2
fi

# Check plan alignment
PLAN_PHASE=0
PLAN_COMPLETE="false"
if [ -f "$EPIC_DIR/plan.md" ]; then
    PLAN_PHASE=$(grep -m1 "^\*\*Phase\*\*:" "$EPIC_DIR/plan.md" 2>/dev/null | grep -oE '[0-9]+' | head -1) || PLAN_PHASE=0
    PLAN_PHASE=${PLAN_PHASE:-0}
    if "$SCRIPT_DIR/check-plan-complete.sh" "$EPIC_DIR/plan.md" >/dev/null 2>&1; then
        PLAN_COMPLETE="true"
    fi
fi

ALL_COMPLETE="false"
if [ "$COMPLETED_PHASES" -eq "$TOTAL_PHASES" ] && [ "$TOTAL_PHASES" -gt 0 ]; then
    ALL_COMPLETE="true"
fi

# Output JSON
cat <<EOF
{"exists": true, "title": "$TITLE", "status": "$STATUS", "total_phases": $TOTAL_PHASES, "completed_phases": $COMPLETED_PHASES, "current_phase": $CURRENT_PHASE, "current_phase_name": "$CURRENT_PHASE_NAME", "current_phase_status": "${CURRENT_PHASE_STATUS:-pending}", "plan_phase": $PLAN_PHASE, "plan_complete": $PLAN_COMPLETE, "all_complete": $ALL_COMPLETE, "test_command": "$TEST_COMMAND"}
EOF

if [ "$ALL_COMPLETE" = "true" ]; then
    exit 0
else
    exit 1
fi
