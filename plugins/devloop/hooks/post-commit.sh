#!/bin/bash
# Devloop Post-Commit Hook
# Updates the worklog with committed tasks after a successful git commit
#
# This hook:
# 1. Detects successful git commits from tool output
# 2. Extracts commit hash and message
# 3. Parses task references from commit message
# 4. Updates the worklog file with the commit entry

set -euo pipefail

# Get tool input (git command) and output from arguments
TOOL_INPUT="${1:-}"
TOOL_OUTPUT="${2:-}"

# Only process git commit commands
if [[ ! "$TOOL_INPUT" =~ "git commit" ]]; then
    exit 0
fi

# Check if commit succeeded by looking for commit hash in output
# Successful commits show: [branch hash] message
if [[ ! "$TOOL_OUTPUT" =~ \[.*[[:space:]][a-f0-9]+\] ]]; then
    # Commit likely failed, don't update worklog
    exit 0
fi

# Extract commit hash from output (7-8 chars after branch name in brackets)
COMMIT_HASH=$(echo "$TOOL_OUTPUT" | grep -oE '\[[^]]+[[:space:]][a-f0-9]{7,8}\]' | head -1 | grep -oE '[a-f0-9]{7,8}' || true)

if [ -z "$COMMIT_HASH" ]; then
    # Fallback: get latest commit hash
    COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || true)
fi

if [ -z "$COMMIT_HASH" ]; then
    # Can't determine commit hash, skip worklog update
    exit 0
fi

# Get commit message
COMMIT_MSG=$(git log -1 --format=%s 2>/dev/null || true)

if [ -z "$COMMIT_MSG" ]; then
    exit 0
fi

# Parse task references from commit message (e.g., "Task 1.1" or "Tasks 2.1, 2.2")
TASK_REFS=$(echo "$COMMIT_MSG" | grep -oE 'Task[s]?[[:space:]]+[0-9]+\.[0-9]+(,[[:space:]]*[0-9]+\.[0-9]+)*' | sed 's/Tasks*//' | tr -d ' ' || echo "")

# Get current date/time
COMMIT_DATE=$(date "+%Y-%m-%d %H:%M")

# Check for worklog file (prefer .devloop/, fallback to .claude/)
if [ -f ".devloop/worklog.md" ]; then
    WORKLOG_FILE=".devloop/worklog.md"
    PLAN_FILE=".devloop/plan.md"
elif [ -f ".claude/devloop-worklog.md" ]; then
    # Legacy location fallback
    WORKLOG_FILE=".claude/devloop-worklog.md"
    PLAN_FILE=".claude/devloop-plan.md"
else
    # Worklog doesn't exist - could create it, but for now just skip
    # The worklog should be created by /devloop command
    exit 0
fi

# Read current worklog content
WORKLOG_CONTENT=$(cat "$WORKLOG_FILE")

# Find the commits table and add entry
# Table format: | Hash | Date | Message | Tasks |
NEW_ROW="| $COMMIT_HASH | $COMMIT_DATE | $COMMIT_MSG | $TASK_REFS |"

# Update the worklog file
# Insert the new row after the table header (after the |---| line)
if grep -q "^|.*Hash.*|.*Date.*|" "$WORKLOG_FILE"; then
    # Find the separator line and insert after it
    # Using a temp file approach for portability
    TEMP_FILE=$(mktemp)

    awk -v new_row="$NEW_ROW" '
        /^\|[-]+\|[-]+\|[-]+\|[-]+\|/ {
            print
            print new_row
            next
        }
        { print }
    ' "$WORKLOG_FILE" > "$TEMP_FILE"

    mv "$TEMP_FILE" "$WORKLOG_FILE"
fi

# Update the Last Updated timestamp
sed -i.bak "s/\*\*Last Updated\*\*:.*/\*\*Last Updated\*\*: $COMMIT_DATE/" "$WORKLOG_FILE" 2>/dev/null || \
    sed -i '' "s/\*\*Last Updated\*\*:.*/\*\*Last Updated\*\*: $COMMIT_DATE/" "$WORKLOG_FILE" 2>/dev/null || true

# Clean up backup file if created
rm -f "$WORKLOG_FILE.bak" 2>/dev/null || true

# If task refs were found, add them to the Tasks Completed section
if [ -n "$TASK_REFS" ]; then
    # Parse individual task numbers
    for TASK in $(echo "$TASK_REFS" | tr ',' '\n'); do
        # Check if task is already in the completed list
        if ! grep -q "\[x\].*Task $TASK" "$WORKLOG_FILE" 2>/dev/null; then
            # Get task description from plan file if available
            TASK_DESC=""
            if [ -f "$PLAN_FILE" ]; then
                # Find the task description (text after "Task X.Y:")
                TASK_DESC=$(grep -E "Task $TASK:" "$PLAN_FILE" 2>/dev/null | head -1 | sed "s/.*Task $TASK:[[:space:]]*//" | cut -c1-60 || echo "")
            fi

            # Add to Tasks Completed section
            # This is a simplified approach - just append before Notes section
            if grep -q "^### Tasks Completed" "$WORKLOG_FILE"; then
                if [ -n "$TASK_DESC" ]; then
                    # Insert the completed task
                    sed -i.bak "/^### Tasks Completed/a\\
- [x] Task $TASK: $TASK_DESC ($COMMIT_HASH)" "$WORKLOG_FILE" 2>/dev/null || \
                    sed -i '' "/^### Tasks Completed/a\\
- [x] Task $TASK: $TASK_DESC ($COMMIT_HASH)" "$WORKLOG_FILE" 2>/dev/null || true
                fi
            fi
        fi
    done
    rm -f "$WORKLOG_FILE.bak" 2>/dev/null || true
fi

# Output success message (will be added to hook context)
echo "Worklog updated with commit $COMMIT_HASH"

exit 0
