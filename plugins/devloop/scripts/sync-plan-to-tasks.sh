#!/bin/bash
# sync-plan-to-tasks.sh - Parse plan.md and output task data for native TaskCreate
# Usage: sync-plan-to-tasks.sh [plan-file]
#
# Output: JSON array of tasks with subject, description, and status
# This is used by /devloop:run to create native tasks for progress tracking

set -euo pipefail

PLAN_FILE="${1:-.devloop/plan.md}"

if [[ ! -f "$PLAN_FILE" ]]; then
    echo "[]"
    exit 0
fi

# Parse tasks from plan file
# Task format: - [ ] Task N.N: Description
# Or: - [x] Task N.N: Description (completed)

# Filter out code blocks first
FILTERED=$(awk '/^```/ { in_code = !in_code; next } !in_code { print }' "$PLAN_FILE")

# Extract current phase
CURRENT_PHASE=""
TASKS="["
FIRST=true

while IFS= read -r line; do
    # Detect phase headers
    if [[ "$line" =~ ^##[[:space:]]+Phase[[:space:]]+([0-9]+):?[[:space:]]*(.*) ]]; then
        CURRENT_PHASE="${BASH_REMATCH[1]}"
        PHASE_NAME="${BASH_REMATCH[2]}"
        continue
    fi

    # Match task lines: - [ ] or - [x] or - [-]
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]\[([[:space:]x\-])\][[:space:]]+(Task[[:space:]]+[0-9]+\.[0-9]+:?)?[[:space:]]*(.*) ]]; then
        STATUS_CHAR="${BASH_REMATCH[1]}"
        TASK_ID="${BASH_REMATCH[2]}"
        DESCRIPTION="${BASH_REMATCH[3]}"

        # Determine status
        case "$STATUS_CHAR" in
            "x") STATUS="completed" ;;
            "-") STATUS="skipped" ;;
            *) STATUS="pending" ;;
        esac

        # Build subject from task ID and description
        if [[ -n "$TASK_ID" ]]; then
            SUBJECT="${TASK_ID} ${DESCRIPTION}"
        else
            SUBJECT="$DESCRIPTION"
        fi

        # Clean up subject (remove trailing colon if any)
        SUBJECT="${SUBJECT%:}"
        SUBJECT="${SUBJECT# }"

        # Escape for JSON
        SUBJECT_ESCAPED=$(printf '%s' "$SUBJECT" | jq -Rs '.' | sed 's/^"//;s/"$//')
        DESC_ESCAPED=$(printf '%s' "$DESCRIPTION" | jq -Rs '.' | sed 's/^"//;s/"$//')

        # Add comma if not first
        if [[ "$FIRST" == "true" ]]; then
            FIRST=false
        else
            TASKS="$TASKS,"
        fi

        # Build task object
        TASKS="$TASKS{\"subject\":\"$SUBJECT_ESCAPED\",\"description\":\"$DESC_ESCAPED\",\"status\":\"$STATUS\",\"phase\":\"$CURRENT_PHASE\"}"
    fi
done <<< "$FILTERED"

TASKS="$TASKS]"

echo "$TASKS"
