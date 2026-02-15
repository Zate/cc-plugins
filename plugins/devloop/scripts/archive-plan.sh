#!/bin/bash
# archive-plan.sh - Archive a completed plan
#
# Usage:
#   ./archive-plan.sh [plan-file] [--force]
#
# Output (JSON):
#   {"archived": true, "path": "...", "tasks_completed": N}
#   {"archived": false, "reason": "not_complete|no_plan|error"}
#
# Exit codes:
#   0 - Plan archived successfully
#   1 - Plan not complete (use --force to override)
#   2 - No plan file found
#   3 - Archive failed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLAN_FILE="${1:-.devloop/plan.md}"
FORCE=false

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --force)
            FORCE=true
            ;;
    esac
done

# Check if plan exists
if [ ! -f "$PLAN_FILE" ]; then
    echo '{"archived": false, "reason": "no_plan", "message": "Plan file not found"}'
    exit 2
fi

# Get plan directory (parent of plan.md)
PLAN_DIR="$(dirname "$PLAN_FILE")"
ARCHIVE_DIR="$PLAN_DIR/archive"

# Check if plan is complete (unless --force)
if [ "$FORCE" = false ]; then
    COMPLETION_STATUS=$("$SCRIPT_DIR/check-plan-complete.sh" "$PLAN_FILE" 2>/dev/null) || true
    IS_COMPLETE=$(echo "$COMPLETION_STATUS" | grep -o '"complete": *[^,}]*' | grep -o 'true\|false')

    if [ "$IS_COMPLETE" != "true" ]; then
        PENDING=$(echo "$COMPLETION_STATUS" | grep -o '"pending": *[0-9]*' | grep -o '[0-9]*')
        echo "{\"archived\": false, \"reason\": \"not_complete\", \"pending_tasks\": $PENDING, \"message\": \"Plan has pending tasks. Use --force to archive anyway.\"}"
        exit 1
    fi
fi

# Extract plan title for filename
# Look for first H1 heading: # Plan Title or # Devloop Plan: Title
PLAN_TITLE=$(grep -m1 '^# ' "$PLAN_FILE" | sed 's/^# //' | sed 's/^Devloop Plan: //' || echo "untitled")

# Create slug from title (lowercase, replace spaces/special chars with dashes)
SLUG=$(echo "$PLAN_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-50)

# Generate archive filename with date
DATE=$(date +%Y-%m-%d)
ARCHIVE_FILENAME="${DATE}-${SLUG}.md"
ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_FILENAME"

# Create archive directory if needed
mkdir -p "$ARCHIVE_DIR"

# Check for existing archive with same name (avoid overwrite)
if [ -f "$ARCHIVE_PATH" ]; then
    TIMESTAMP=$(date +%H%M%S)
    ARCHIVE_FILENAME="${DATE}-${SLUG}-${TIMESTAMP}.md"
    ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_FILENAME"
fi

# Get task counts for output
DONE=$(grep -cE "^[[:space:]]*- \[x\]" "$PLAN_FILE" 2>/dev/null) || DONE=0
TOTAL=$(grep -cE "^[[:space:]]*- \[[ x~!]\]" "$PLAN_FILE" 2>/dev/null) || TOTAL=0

# Extract issue reference if present
# Look for: **Issue**: #123 (URL) or **Issue**: #123
ISSUE_LINE=$(grep -m1 '^\*\*Issue\*\*:' "$PLAN_FILE" 2>/dev/null) || ISSUE_LINE=""
ISSUE_NUMBER=""
ISSUE_URL=""

if [ -n "$ISSUE_LINE" ]; then
    # Extract issue number: #123
    ISSUE_NUMBER=$(echo "$ISSUE_LINE" | grep -oE '#[0-9]+' | head -1 | tr -d '#')
    # Extract URL if present: (https://...)
    ISSUE_URL=$(echo "$ISSUE_LINE" | grep -oE 'https://[^)]+' | head -1) || ISSUE_URL=""
fi

# Add archive metadata header
{
    echo "---"
    echo "archived_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "original_path: $PLAN_FILE"
    echo "tasks_completed: $DONE"
    echo "tasks_total: $TOTAL"
    if [ -n "$ISSUE_NUMBER" ]; then
        echo "issue_number: $ISSUE_NUMBER"
    fi
    if [ -n "$ISSUE_URL" ]; then
        echo "issue_url: $ISSUE_URL"
    fi
    echo "---"
    echo ""
    cat "$PLAN_FILE"
} > "$ARCHIVE_PATH"

# Clear the original plan file (create empty placeholder)
cat > "$PLAN_FILE" << 'EOF'
# Devloop Plan

**Status**: No active plan

Run `/devloop` or `/devloop:plan` to start a new plan.
EOF

# Build output JSON
OUTPUT="{\"archived\": true, \"path\": \"$ARCHIVE_PATH\", \"tasks_completed\": $DONE, \"tasks_total\": $TOTAL, \"title\": \"$PLAN_TITLE\""

if [ -n "$ISSUE_NUMBER" ]; then
    OUTPUT="$OUTPUT, \"issue_number\": $ISSUE_NUMBER"
fi

if [ -n "$ISSUE_URL" ]; then
    OUTPUT="$OUTPUT, \"issue_url\": \"$ISSUE_URL\""
fi

OUTPUT="$OUTPUT}"

echo "$OUTPUT"
exit 0
