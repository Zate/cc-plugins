#!/bin/bash
# sync-plan-to-tasks.sh - Parse plan.md and output pending tasks as JSON for TaskCreate
#
# Usage:
#   ./sync-plan-to-tasks.sh [plan-file]
#
# Output (JSON array):
#   [
#     {
#       "id": "1.1",
#       "subject": "Task description",
#       "phase": "Phase 1: Setup",
#       "activeForm": "Creating task description..."
#     },
#     ...
#   ]
#
# Only outputs PENDING tasks (- [ ]) for creation in native Task system.
# Completed tasks (- [x]) are not included.

set -euo pipefail

PLAN_FILE="${1:-.devloop/plan.md}"

if [ ! -f "$PLAN_FILE" ]; then
    echo '{"error": "no_plan", "message": "Plan file not found"}'
    exit 2
fi

# Parse plan and extract pending tasks with their phase context
awk '
BEGIN {
    phase = ""
    task_num = 0
    first = 1
    print "["
}

# Track current phase
/^## Phase/ {
    phase = $0
    gsub(/^## /, "", phase)
}

# Match pending tasks: - [ ] Task X.X: Description
/^[[:space:]]*- \[ \]/ {
    # Skip if inside code block
    if (in_code) next

    task_num++

    # Extract task line
    line = $0
    gsub(/^[[:space:]]*- \[ \] /, "", line)

    # Try to extract task ID (e.g., "Task 1.1:")
    task_id = ""
    if (match(line, /^Task [0-9]+\.[0-9]+:/)) {
        task_id = substr(line, RSTART + 5, RLENGTH - 6)
        line = substr(line, RSTART + RLENGTH)
        gsub(/^[[:space:]]*/, "", line)
    } else {
        task_id = task_num
    }

    # Clean up subject - escape for JSON
    subject = line
    gsub(/\\/, "\\\\", subject)  # Escape backslashes first
    gsub(/"/, "\\\"", subject)   # Escape quotes

    # Generate activeForm (present continuous)
    active = subject
    # Simple transformation: add "ing" pattern
    if (match(active, /^[A-Z][a-z]+/)) {
        verb = substr(active, RSTART, RLENGTH)
        rest = substr(active, RLENGTH + 1)
        # Common verb transformations
        if (verb == "Create") active = "Creating" rest
        else if (verb == "Add") active = "Adding" rest
        else if (verb == "Update") active = "Updating" rest
        else if (verb == "Test") active = "Testing" rest
        else if (verb == "Document") active = "Documenting" rest
        else if (verb == "Implement") active = "Implementing" rest
        else if (verb == "Fix") active = "Fixing" rest
        else if (verb == "Remove") active = "Removing" rest
        else if (verb == "Ensure") active = "Ensuring" rest
        else if (verb == "Verify") active = "Verifying" rest
        else active = "Working on " subject
    } else {
        active = "Working on " subject
    }
    gsub(/\\/, "\\\\", active)  # Escape backslashes first
    gsub(/"/, "\\\"", active)   # Escape quotes

    # Clean phase for JSON
    phase_clean = phase
    gsub(/\\/, "\\\\", phase_clean)
    gsub(/"/, "\\\"", phase_clean)

    # Output JSON object
    if (!first) print ","
    first = 0

    printf "  {\"id\": \"%s\", \"subject\": \"%s\", \"phase\": \"%s\", \"activeForm\": \"%s\"}", task_id, subject, phase_clean, active
}

# Track code blocks
/^```/ {
    in_code = !in_code
}

END {
    print ""
    print "]"
}
' "$PLAN_FILE"
