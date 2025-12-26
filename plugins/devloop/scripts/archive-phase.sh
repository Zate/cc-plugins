#!/usr/bin/env bash
#
# archive-phase.sh - Extract and archive completed phases from a plan
#
# Usage: archive-phase.sh <phase-number> [plan-file] [archive-dir]
#
# Arguments:
#   phase-number  Phase number to archive (e.g., 1, 2)
#   plan-file     Plan file path (default: .devloop/plan.md)
#   archive-dir   Archive directory (default: .devloop/archive)
#
# Output: JSON with archive results
#
# Exit codes:
#   0 - Success
#   1 - Phase not found
#   2 - Phase not complete
#   3 - File/IO error
#   10 - Invalid arguments

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults
PLAN_FILE=".devloop/plan.md"
ARCHIVE_DIR=".devloop/archive"
PHASE_NUM=""
DRY_RUN=false
JSON_OUTPUT=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --plan) PLAN_FILE="$2"; shift 2 ;;
        --archive-dir) ARCHIVE_DIR="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --json) JSON_OUTPUT=true; shift ;;
        -h|--help)
            echo "Usage: archive-phase.sh <phase-number> [options]"
            echo ""
            echo "Archive a completed phase from the plan."
            echo ""
            echo "Options:"
            echo "  --plan FILE       Plan file (default: .devloop/plan.md)"
            echo "  --archive-dir DIR Archive directory (default: .devloop/archive)"
            echo "  --dry-run         Preview without writing files"
            echo "  --json            Output results as JSON"
            exit 0
            ;;
        [0-9]*) PHASE_NUM="$1"; shift ;;
        *) shift ;;
    esac
done

if [ -z "$PHASE_NUM" ]; then
    echo "Error: Phase number required" >&2
    exit 10
fi

if [ ! -f "$PLAN_FILE" ]; then
    echo "Error: Plan file not found: $PLAN_FILE" >&2
    exit 3
fi

# ============================================================================
# Detect all phases and their status
# ============================================================================
detect_phases() {
    awk '/^### Phase [0-9]+/ {
        if (phase != "") {
            status = (pending == 0 && complete > 0) ? "complete" : "incomplete"
            print phase_num "|" phase_name "|" complete "|" pending "|" status
        }
        phase = $0
        match($0, /Phase ([0-9]+)/, arr)
        phase_num = arr[1]
        phase_name = $0
        gsub(/^### Phase [0-9]+: ?/, "", phase_name)
        complete = 0
        pending = 0
    }
    /^\s*- \[x\]/ || /^\s*- \[X\]/ {
        if (phase != "") complete++
    }
    /^\s*- \[ \]/ {
        if (phase != "") pending++
    }
    END {
        if (phase != "") {
            status = (pending == 0 && complete > 0) ? "complete" : "incomplete"
            print phase_num "|" phase_name "|" complete "|" pending "|" status
        }
    }' "$PLAN_FILE"
}

# ============================================================================
# Check if phase is complete
# ============================================================================
is_phase_complete() {
    local phase_num="$1"
    local status=$(detect_phases | grep "^${phase_num}|" | cut -d'|' -f5)
    [ "$status" = "complete" ]
}

# ============================================================================
# Extract phase content from plan
# ============================================================================
extract_phase_content() {
    local phase_num="$1"

    # Extract from "### Phase N" to next phase or section
    awk -v phase="$phase_num" '
        /^### Phase [0-9]+/ {
            if (match($0, /Phase ([0-9]+)/, arr)) {
                if (arr[1] == phase) {
                    printing = 1
                } else if (printing) {
                    printing = 0
                }
            }
        }
        /^## / && printing {
            printing = 0
        }
        printing { print }
    ' "$PLAN_FILE"
}

# ============================================================================
# Extract progress log entries for phase
# ============================================================================
extract_progress_entries() {
    local phase_num="$1"

    # Extract entries mentioning Phase N or Task N.x
    awk -v phase="$phase_num" '
        /^## Progress Log$/ { in_log = 1; next }
        /^## / && in_log { in_log = 0 }
        in_log && (/Phase " phase/ || /Task " phase "\\./) { print }
    ' "$PLAN_FILE" 2>/dev/null || true
}

# ============================================================================
# Get plan name from file
# ============================================================================
get_plan_name() {
    grep -m1 "^# " "$PLAN_FILE" 2>/dev/null | sed 's/^# //' | sed 's/[^a-zA-Z0-9]/_/g' | tr '[:upper:]' '[:lower:]'
}

# ============================================================================
# Main archival logic
# ============================================================================
main() {
    # Check if phase exists
    local phase_info=$(detect_phases | grep "^${PHASE_NUM}|")
    if [ -z "$phase_info" ]; then
        if [ "$JSON_OUTPUT" = true ]; then
            echo '{"error": "Phase not found", "phase": '"$PHASE_NUM"'}'
        else
            echo "Error: Phase $PHASE_NUM not found in plan" >&2
        fi
        exit 1
    fi

    # Parse phase info
    local phase_name=$(echo "$phase_info" | cut -d'|' -f2)
    local complete_count=$(echo "$phase_info" | cut -d'|' -f3)
    local pending_count=$(echo "$phase_info" | cut -d'|' -f4)
    local status=$(echo "$phase_info" | cut -d'|' -f5)

    if [ "$status" != "complete" ]; then
        if [ "$JSON_OUTPUT" = true ]; then
            echo '{"error": "Phase not complete", "phase": '"$PHASE_NUM"', "complete": '"$complete_count"', "pending": '"$pending_count"'}'
        else
            echo "Error: Phase $PHASE_NUM is not complete ($complete_count complete, $pending_count pending)" >&2
        fi
        exit 2
    fi

    # Generate archive filename
    local plan_name=$(get_plan_name)
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local archive_file="${ARCHIVE_DIR}/${plan_name}_phase_${PHASE_NUM}_${timestamp}.md"

    # Extract content
    local phase_content=$(extract_phase_content "$PHASE_NUM")
    local progress_entries=$(extract_progress_entries "$PHASE_NUM")

    if [ "$DRY_RUN" = true ]; then
        if [ "$JSON_OUTPUT" = true ]; then
            cat <<EOF
{
  "dry_run": true,
  "phase": $PHASE_NUM,
  "phase_name": "$phase_name",
  "tasks": $complete_count,
  "archive_file": "$archive_file",
  "content_lines": $(echo "$phase_content" | wc -l | tr -d ' '),
  "progress_entries": $(echo "$progress_entries" | wc -l | tr -d ' ')
}
EOF
        else
            echo "Dry run - would archive Phase $PHASE_NUM to $archive_file"
            echo "  Tasks: $complete_count"
            echo "  Content lines: $(echo "$phase_content" | wc -l | tr -d ' ')"
            echo "  Progress entries: $(echo "$progress_entries" | wc -l | tr -d ' ')"
        fi
        exit 0
    fi

    # Create archive directory
    mkdir -p "$ARCHIVE_DIR"

    # Write archive file
    cat > "$archive_file" <<EOF
# Archived Plan: $(grep -m1 "^# " "$PLAN_FILE" | sed 's/^# //') - Phase $PHASE_NUM

**Archived**: $(date +%Y-%m-%d)
**Original Plan**: $(grep -m1 "^# " "$PLAN_FILE" | sed 's/^# //')
**Phase**: $PHASE_NUM - $phase_name
**Phase Status**: Complete
**Tasks**: ${complete_count}/${complete_count} complete

---

$phase_content

---

## Progress Log (Phase $PHASE_NUM)

$progress_entries

---

**Note**: This phase was archived to compress the active plan. The active plan focuses on current and upcoming work.
EOF

    if [ "$JSON_OUTPUT" = true ]; then
        cat <<EOF
{
  "success": true,
  "phase": $PHASE_NUM,
  "phase_name": "$phase_name",
  "tasks": $complete_count,
  "archive_file": "$archive_file",
  "content_lines": $(echo "$phase_content" | wc -l | tr -d ' ')
}
EOF
    else
        echo "Archived Phase $PHASE_NUM to $archive_file"
        echo "  Phase: $phase_name"
        echo "  Tasks: $complete_count"
    fi
}

main "$@"
