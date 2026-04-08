#!/bin/bash
# check-epic-state.sh - Check epic state and current phase progress
#
# Usage:
#   ./check-epic-state.sh [epic-file]
#
# Output (JSON):
#   {"exists": true, "title": "...", "total_phases": N, "completed_phases": N,
#    "current_phase": N, "current_phase_name": "...", "current_phase_status": "...",
#    "plan_phase": N, "plan_complete": bool, "all_complete": bool}
#
# Exit codes:
#   0 - All phases complete
#   1 - Phases pending
#   2 - No epic file found

set -euo pipefail

EPIC_FILE="${1:-.devloop/epic.md}"

if [ ! -f "$EPIC_FILE" ]; then
    echo '{"exists": false, "error": "no_epic", "message": "Epic file not found"}'
    exit 2
fi

# Extract title from first H1
TITLE=$(grep -m1 "^# " "$EPIC_FILE" | sed 's/^# //' | sed 's/^Epic: //')

# Parse phase tracker table
# Format: | N | Name | Tasks | Status |
TOTAL_PHASES=0
COMPLETED_PHASES=0
CURRENT_PHASE=0
CURRENT_PHASE_NAME=""
CURRENT_PHASE_STATUS=""

while IFS='|' read -r _ phase_num name tasks status _; do
    # Skip header and separator rows
    phase_num=$(echo "$phase_num" | tr -d ' ')
    status=$(echo "$status" | tr -d ' ' | tr '[:upper:]' '[:lower:]')

    # Skip non-numeric phase numbers (header row)
    case "$phase_num" in
        ''|*[!0-9]*) continue ;;
    esac

    TOTAL_PHASES=$((TOTAL_PHASES + 1))

    # Normalize status - strip backticks
    status=$(echo "$status" | tr -d '`')

    if [ "$status" = "complete" ]; then
        COMPLETED_PHASES=$((COMPLETED_PHASES + 1))
    elif [ "$CURRENT_PHASE" -eq 0 ]; then
        # First non-complete phase is current
        CURRENT_PHASE=$phase_num
        CURRENT_PHASE_NAME=$(echo "$name" | sed 's/^ *//;s/ *$//')
        CURRENT_PHASE_STATUS="$status"
    fi
done < <(grep "^|" "$EPIC_FILE" | grep -v "^|[-]" | grep -v "^| Phase")

# If all complete, no current phase
if [ "$COMPLETED_PHASES" -eq "$TOTAL_PHASES" ] && [ "$TOTAL_PHASES" -gt 0 ]; then
    ALL_COMPLETE="true"
else
    ALL_COMPLETE="false"
fi

# Check plan.md for phase alignment
PLAN_PHASE=0
PLAN_COMPLETE="false"
if [ -f ".devloop/plan.md" ]; then
    # Extract phase number from plan frontmatter
    PLAN_PHASE=$(grep -m1 "^\*\*Phase\*\*:" .devloop/plan.md 2>/dev/null | grep -oE '[0-9]+' | head -1) || PLAN_PHASE=0
    PLAN_PHASE=${PLAN_PHASE:-0}

    # Check plan completion
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    if [ -x "$SCRIPT_DIR/check-plan-complete.sh" ]; then
        PLAN_JSON=$("$SCRIPT_DIR/check-plan-complete.sh" .devloop/plan.md 2>/dev/null) && PLAN_COMPLETE="true" || PLAN_COMPLETE="false"
    fi
fi

# Output JSON
cat <<EOF
{"exists": true, "title": "$TITLE", "total_phases": $TOTAL_PHASES, "completed_phases": $COMPLETED_PHASES, "current_phase": $CURRENT_PHASE, "current_phase_name": "$CURRENT_PHASE_NAME", "current_phase_status": "$CURRENT_PHASE_STATUS", "plan_phase": $PLAN_PHASE, "plan_complete": $PLAN_COMPLETE, "all_complete": $ALL_COMPLETE}
EOF

if [ "$ALL_COMPLETE" = "true" ]; then
    exit 0
else
    exit 1
fi
