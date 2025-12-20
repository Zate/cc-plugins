#!/bin/bash
# Devloop Worklog Rotation Script
# Archives worklog when it exceeds the threshold to maintain context hygiene
#
# Usage: rotate-worklog.sh [OPTIONS]
#   --check-only    Only check if rotation is needed, don't rotate
#   --force         Force rotation regardless of line count
#   --threshold N   Set custom line threshold (default: 500)
#   --quiet         Suppress informational output

set -euo pipefail

# Configuration
DEFAULT_THRESHOLD=500
WORKLOG_FILE=".devloop/worklog.md"
ARCHIVE_DIR=".devloop/archive"

# Parse arguments
CHECK_ONLY=false
FORCE=false
THRESHOLD=$DEFAULT_THRESHOLD
QUIET=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --check-only)
            CHECK_ONLY=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --threshold)
            THRESHOLD="$2"
            shift 2
            ;;
        --quiet)
            QUIET=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Helper: log message if not quiet
log() {
    if [ "$QUIET" = false ]; then
        echo "$1"
    fi
}

# Helper: log error
error() {
    echo "Error: $1" >&2
}

# Check if worklog exists
if [ ! -f "$WORKLOG_FILE" ]; then
    log "No worklog found at $WORKLOG_FILE"
    exit 0
fi

# Count lines in worklog
LINE_COUNT=$(wc -l < "$WORKLOG_FILE")

log "Worklog has $LINE_COUNT lines (threshold: $THRESHOLD)"

# Check if rotation is needed
if [ "$FORCE" = false ] && [ "$LINE_COUNT" -lt "$THRESHOLD" ]; then
    log "No rotation needed"

    # Output for hook integration
    if [ "$QUIET" = false ]; then
        cat <<EOF
{
  "rotated": false,
  "lineCount": $LINE_COUNT,
  "threshold": $THRESHOLD
}
EOF
    fi
    exit 0
fi

# If check-only mode, exit here
if [ "$CHECK_ONLY" = true ]; then
    log "Rotation needed (check-only mode)"
    cat <<EOF
{
  "rotated": false,
  "needsRotation": true,
  "lineCount": $LINE_COUNT,
  "threshold": $THRESHOLD
}
EOF
    exit 0
fi

# Create archive directory if it doesn't exist
if [ ! -d "$ARCHIVE_DIR" ]; then
    mkdir -p "$ARCHIVE_DIR"
    log "Created archive directory: $ARCHIVE_DIR"
fi

# Generate archive filename with timestamp
TIMESTAMP=$(date +%Y-%m-%d)
ARCHIVE_FILE="$ARCHIVE_DIR/worklog-$TIMESTAMP.md"

# Handle multiple rotations on same day
COUNTER=1
while [ -f "$ARCHIVE_FILE" ]; do
    ARCHIVE_FILE="$ARCHIVE_DIR/worklog-$TIMESTAMP-$COUNTER.md"
    COUNTER=$((COUNTER + 1))
done

# Extract header from current worklog (first 10 lines typically contain metadata)
HEADER=$(head -20 "$WORKLOG_FILE" | sed -n '/^# /,/^---$/p')
if [ -z "$HEADER" ]; then
    # Fallback: just get the title line
    HEADER=$(head -5 "$WORKLOG_FILE")
fi

# Move current worklog to archive
mv "$WORKLOG_FILE" "$ARCHIVE_FILE"
log "Archived worklog to: $ARCHIVE_FILE"

# Create new worklog with fresh header
cat > "$WORKLOG_FILE" << 'EOF'
# Devloop Worklog

**Project**: $(basename "$(pwd)")
**Started**: $(date +%Y-%m-%d)
**Last Updated**: $(date +%Y-%m-%d)

---

EOF

# Use proper variable substitution
PROJECT_NAME=$(basename "$(pwd)")
CURRENT_DATE=$(date +%Y-%m-%d)

cat > "$WORKLOG_FILE" << EOF
# Devloop Worklog

**Project**: $PROJECT_NAME
**Started**: $CURRENT_DATE
**Last Updated**: $CURRENT_DATE

---

## Archive Reference

Previous worklog archived to: \`$ARCHIVE_FILE\`

---

EOF

log "Created fresh worklog"

# Add archive reference note
log "Rotation complete: $LINE_COUNT lines archived"

# Output JSON for hook integration
cat <<EOF
{
  "rotated": true,
  "lineCount": $LINE_COUNT,
  "threshold": $THRESHOLD,
  "archiveFile": "$ARCHIVE_FILE",
  "newWorklog": "$WORKLOG_FILE"
}
EOF

exit 0
