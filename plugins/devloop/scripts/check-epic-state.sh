#!/bin/bash
# check-epic-state.sh - Check epic state from epic.json
#
# Usage:
#   ./check-epic-state.sh [epic-dir]
#
# Output (JSON):
#   {"exists": true, "title": "...", "status": "...", "total_phases": N,
#    "completed_phases": N, "current_phase": N, "all_complete": bool, "test_command": "..."}
#
# Exit codes:
#   0 - All phases complete
#   1 - Phases pending
#   2 - No epic found

set -euo pipefail

EPIC_DIR="${1:-.devloop}"
EPIC_JSON="$EPIC_DIR/epic.json"

if [ ! -f "$EPIC_JSON" ]; then
    echo '{"exists": false, "error": "no_epic", "message": "No epic.json found"}'
    exit 2
fi

if command -v jq &>/dev/null; then
    TITLE=$(jq -r '.title' "$EPIC_JSON")
    STATUS=$(jq -r '.status' "$EPIC_JSON")
    TOTAL_PHASES=$(jq '.phases | length' "$EPIC_JSON")
    COMPLETED_PHASES=$(jq '[.phases[] | select(.status == "complete")] | length' "$EPIC_JSON")
    CURRENT_PHASE=$(jq -r '.current_phase' "$EPIC_JSON")
    CURRENT_PHASE_NAME=$(jq -r --argjson p "$CURRENT_PHASE" '(.phases[] | select(.number == $p) | .name) // "Unknown"' "$EPIC_JSON")
    TEST_COMMAND=$(jq -r '.test_command // ""' "$EPIC_JSON")
else
    # Minimal fallback -- agent can read epic.json directly if needed
    TITLE=$(grep -o '"title": *"[^"]*"' "$EPIC_JSON" | head -1 | sed 's/"title": *"//;s/"$//')
    STATUS=$(grep -o '"status": *"[^"]*"' "$EPIC_JSON" | head -1 | sed 's/"status": *"//;s/"$//')
    TOTAL_PHASES=$(grep -c '"number":' "$EPIC_JSON" 2>/dev/null) || TOTAL_PHASES=0
    CURRENT_PHASE=$(grep -o '"current_phase": *[0-9]*' "$EPIC_JSON" | grep -o '[0-9]*')
    CURRENT_PHASE_NAME="Unknown"
    TEST_COMMAND=""
    # Count completed phases by looking for "complete" after "number" lines
    COMPLETED_PHASES=0
    IN_PHASES=false
    while IFS= read -r line; do
        if echo "$line" | grep -q '"phases"'; then IN_PHASES=true; fi
        if [ "$IN_PHASES" = true ] && echo "$line" | grep -q '"status": *"complete"'; then
            COMPLETED_PHASES=$((COMPLETED_PHASES + 1))
        fi
    done < "$EPIC_JSON"
fi

ALL_COMPLETE="false"
if [ "$COMPLETED_PHASES" -eq "$TOTAL_PHASES" ] && [ "$TOTAL_PHASES" -gt 0 ]; then
    ALL_COMPLETE="true"
fi

cat <<EOF
{"exists": true, "title": "$TITLE", "status": "$STATUS", "total_phases": $TOTAL_PHASES, "completed_phases": $COMPLETED_PHASES, "current_phase": $CURRENT_PHASE, "current_phase_name": "$CURRENT_PHASE_NAME", "all_complete": $ALL_COMPLETE, "test_command": "$TEST_COMMAND"}
EOF

if [ "$ALL_COMPLETE" = "true" ]; then exit 0; else exit 1; fi
