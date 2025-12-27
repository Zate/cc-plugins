#!/usr/bin/env bash
#
# archive-interactive.sh - Automatically detect and archive completed phases
#
# Usage: archive-interactive.sh [plan-file]
#
# Description:
#   Detects complete phases in plan.md (all tasks [x], [~], [-], or [!]),
#   archives them to .devloop/archive/, removes from plan, updates worklog.
#   Requires NO LLM - pure bash/awk parsing.
#
# Exit codes:
#   0 - Success (phases archived or nothing to archive)
#   1 - Plan file not found
#   2 - Script dependencies missing
#   3 - Archive operation failed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN_FILE="${1:-.devloop/plan.md}"
ARCHIVE_DIR=".devloop/archive"
WORKLOG_FILE=".devloop/worklog.md"
VERBOSE=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check dependencies
check_dependencies() {
    if [ ! -f "$SCRIPT_DIR/archive-phase.sh" ]; then
        echo -e "${RED}Error: archive-phase.sh not found in $SCRIPT_DIR${NC}" >&2
        exit 2
    fi
}

# Verify plan file exists
if [ ! -f "$PLAN_FILE" ]; then
    echo -e "${RED}Error: Plan file not found: $PLAN_FILE${NC}" >&2
    echo "Tip: Run /devloop to create a plan first" >&2
    exit 1
fi

check_dependencies

# ============================================================================
# Detect all phases and their completion status
# ============================================================================
detect_phases() {
    awk '
    BEGIN {
        phase_num = ""
        phase_name = ""
        complete = 0
        pending = 0
        in_progress = 0
        blocked = 0
        skipped = 0
    }

    # Detect phase header
    /^### Phase [0-9]+/ {
        # Print previous phase if exists
        if (phase_num != "") {
            total = complete + pending + in_progress + blocked + skipped
            # Phase is complete if no pending tasks and at least one task exists
            status = (pending == 0 && total > 0) ? "complete" : "incomplete"
            print phase_num "|" phase_name "|" complete "|" pending "|" in_progress "|" blocked "|" skipped "|" total "|" status
        }

        # Start new phase
        match($0, /Phase ([0-9]+)/, arr)
        phase_num = arr[1]
        phase_name = $0
        gsub(/^### Phase [0-9]+: ?/, "", phase_name)
        complete = 0
        pending = 0
        in_progress = 0
        blocked = 0
        skipped = 0
    }

    # Count task markers
    /^\s*- \[x\]/ || /^\s*- \[X\]/ {
        if (phase_num != "") complete++
    }
    /^\s*- \[ \]/ {
        if (phase_num != "") pending++
    }
    /^\s*- \[~\]/ {
        if (phase_num != "") in_progress++
    }
    /^\s*- \[!\]/ {
        if (phase_num != "") blocked++
    }
    /^\s*- \[-\]/ {
        if (phase_num != "") skipped++
    }

    END {
        # Print final phase
        if (phase_num != "") {
            total = complete + pending + in_progress + blocked + skipped
            status = (pending == 0 && total > 0) ? "complete" : "incomplete"
            print phase_num "|" phase_name "|" complete "|" pending "|" in_progress "|" blocked "|" skipped "|" total "|" status
        }
    }
    ' "$PLAN_FILE"
}

# ============================================================================
# Get plan name for archive filename
# ============================================================================
get_plan_name() {
    grep -m1 "^# " "$PLAN_FILE" 2>/dev/null | sed 's/^# //' | sed 's/Devloop Plan: //' | sed 's/[^a-zA-Z0-9]/_/g' | tr '[:upper:]' '[:lower:]'
}

# ============================================================================
# Extract phase line range for removal
# ============================================================================
get_phase_line_range() {
    local phase_num="$1"

    awk -v phase="$phase_num" '
    BEGIN { start=0; end=0; found=0 }

    /^### Phase [0-9]+/ {
        if (match($0, /Phase ([0-9]+)/, arr)) {
            if (found && start > 0) {
                # Found next phase, end previous
                end = NR - 1
                print start "," end
                exit
            }
            if (arr[1] == phase) {
                start = NR
                found = 1
            }
        }
    }

    /^## / && found {
        # Hit next section
        end = NR - 1
        print start "," end
        exit
    }

    END {
        if (found && end == 0) {
            # Phase goes to end of file
            print start "," NR
        }
    }
    ' "$PLAN_FILE"
}

# ============================================================================
# Update worklog with archived phase reference
# ============================================================================
update_worklog() {
    local phase_num="$1"
    local phase_name="$2"
    local task_count="$3"
    local archive_file="$4"

    local today=$(date +%Y-%m-%d)
    local timestamp=$(date +"%Y-%m-%d %H:%M")

    # Create worklog if it doesn't exist
    if [ ! -f "$WORKLOG_FILE" ]; then
        cat > "$WORKLOG_FILE" <<EOF
# Devloop Worklog

Completed work history for this project.

---

EOF
    fi

    # Extract task descriptions from archived phase
    local task_list=""
    if [ -f "$archive_file" ]; then
        task_list=$(grep -E '^\s*- \[x\].*Task [0-9]+\.[0-9]+:' "$archive_file" | sed 's/^\s*- \[x\] Task /- Task /' | head -10)
    fi

    # Append to worklog
    cat >> "$WORKLOG_FILE" <<EOF

## $timestamp

### Phase $phase_num Complete: $phase_name

**Tasks Completed**: $task_count

$task_list

**Archived**: \`$archive_file\`

---
EOF
}

# ============================================================================
# Remove archived phases from plan
# ============================================================================
compress_plan() {
    local -a phases_to_remove=("$@")

    if [ ${#phases_to_remove[@]} -eq 0 ]; then
        return
    fi

    # Create temp file
    local temp_plan=$(mktemp)

    # Track which lines to skip
    local -A skip_ranges
    for phase_num in "${phases_to_remove[@]}"; do
        local range=$(get_phase_line_range "$phase_num")
        if [ -n "$range" ]; then
            skip_ranges[$phase_num]="$range"
        fi
    done

    # Copy plan, skipping archived phases
    local line_num=0
    local skip_until=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Check if we should skip this line
        local should_skip=false
        for phase_num in "${phases_to_remove[@]}"; do
            local range="${skip_ranges[$phase_num]:-}"
            if [ -n "$range" ]; then
                IFS=',' read -r start end <<< "$range"
                if [ "$line_num" -ge "$start" ] && [ "$line_num" -le "$end" ]; then
                    should_skip=true
                    break
                fi
            fi
        done

        if [ "$should_skip" = false ]; then
            echo "$line" >> "$temp_plan"
        fi
    done < "$PLAN_FILE"

    # Add archival note to Progress Log
    local timestamp=$(date +"%Y-%m-%d %H:%M")
    local phase_list=$(IFS=, ; echo "${phases_to_remove[*]}")

    # Insert before end of file
    sed -i '/^## Progress Log/a\
- '"$timestamp"': Archived completed phases ('"$phase_list"') to .devloop/archive/' "$temp_plan"

    # Update timestamp
    sed -i "s/^\*\*Updated\*\*:.*/\*\*Updated\*\*: $timestamp/" "$temp_plan"

    # Replace original plan
    mv "$temp_plan" "$PLAN_FILE"
}

# ============================================================================
# Main execution
# ============================================================================
main() {
    echo -e "${BLUE}=== Devloop Plan Archive ===${NC}"
    echo ""
    echo "Analyzing: $PLAN_FILE"
    echo ""

    # Detect all phases
    local phase_data=$(detect_phases)

    if [ -z "$phase_data" ]; then
        echo -e "${YELLOW}No phases found in plan.${NC}"
        exit 0
    fi

    # Count phases
    local total_phases=$(echo "$phase_data" | wc -l)
    local complete_phases=0
    local -a complete_phase_nums=()

    echo -e "${BLUE}Phase Status:${NC}"
    echo ""

    while IFS='|' read -r num name complete pending in_prog blocked skipped total status; do
        if [ "$status" = "complete" ]; then
            echo -e "  ${GREEN}✓${NC} Phase $num: $name ($total tasks complete)"
            complete_phases=$((complete_phases + 1))
            complete_phase_nums+=("$num")
        else
            local done=$((complete + in_prog + blocked + skipped))
            echo -e "  ${YELLOW}○${NC} Phase $num: $name ($done/$total tasks done, $pending pending)"
        fi
    done <<< "$phase_data"

    echo ""
    echo -e "${BLUE}Summary:${NC}"
    echo "  Total phases: $total_phases"
    echo "  Complete phases: $complete_phases"
    echo ""

    # Check if any phases to archive
    if [ $complete_phases -eq 0 ]; then
        echo -e "${YELLOW}No completed phases found. Nothing to archive.${NC}"
        echo ""
        echo "Tip: Phases are considered complete when all tasks are marked [x], [~], [-], or [!]"
        exit 0
    fi

    # Check if plan is already minimal
    local plan_lines=$(wc -l < "$PLAN_FILE")
    if [ "$plan_lines" -lt 100 ]; then
        echo -e "${YELLOW}Plan is small ($plan_lines lines). Archival may not be needed.${NC}"
        echo ""
        read -p "Continue with archival? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Archival cancelled."
            exit 0
        fi
    fi

    # Archive each complete phase
    echo -e "${BLUE}Archiving complete phases...${NC}"
    echo ""

    local archived_count=0
    local -a archived_files=()
    local -a archived_phase_nums=()

    mkdir -p "$ARCHIVE_DIR"

    for phase_num in "${complete_phase_nums[@]}"; do
        echo -n "  Archiving Phase $phase_num... "

        # Call archive-phase.sh
        local result
        if result=$("$SCRIPT_DIR/archive-phase.sh" "$phase_num" --plan "$PLAN_FILE" --archive-dir "$ARCHIVE_DIR" --json 2>&1); then
            # Parse JSON result
            local archive_file=$(echo "$result" | grep -o '"archive_file": "[^"]*"' | cut -d'"' -f4)
            local phase_name=$(echo "$result" | grep -o '"phase_name": "[^"]*"' | cut -d'"' -f4)
            local task_count=$(echo "$result" | grep -o '"tasks": [0-9]*' | grep -o '[0-9]*')

            echo -e "${GREEN}✓${NC}"
            archived_count=$((archived_count + 1))
            archived_files+=("$archive_file")
            archived_phase_nums+=("$phase_num")

            # Update worklog
            update_worklog "$phase_num" "$phase_name" "$task_count" "$archive_file"
        else
            echo -e "${RED}✗${NC}"
            echo "  Error: $result"
        fi
    done

    echo ""

    if [ $archived_count -eq 0 ]; then
        echo -e "${RED}No phases were archived.${NC}"
        exit 3
    fi

    # Compress plan by removing archived phases
    echo -n "Compressing plan... "
    local original_lines=$plan_lines
    compress_plan "${archived_phase_nums[@]}"
    local new_lines=$(wc -l < "$PLAN_FILE")
    local reduction=$(( (original_lines - new_lines) * 100 / original_lines ))
    echo -e "${GREEN}✓${NC}"

    echo ""
    echo -e "${GREEN}=== Archival Complete ===${NC}"
    echo ""
    echo -e "${BLUE}Plan Compressed:${NC} $original_lines → $new_lines lines (${reduction}% reduction)"
    echo ""
    echo -e "${BLUE}Archived Phases:${NC}"
    for i in "${!archived_phase_nums[@]}"; do
        local num="${archived_phase_nums[$i]}"
        local file="${archived_files[$i]}"
        echo "  • Phase $num → $(basename "$file")"
    done
    echo ""
    echo -e "${BLUE}Worklog Updated:${NC} $archived_count entries added to $WORKLOG_FILE"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "  1. Review compressed plan: less $PLAN_FILE"
    echo "  2. Review archived phases: ls -lh $ARCHIVE_DIR/"
    echo "  3. Run faster: /devloop:continue"
    echo "  4. Commit changes: git add .devloop/ && git commit -m 'chore(devloop): archive completed phases'"
    echo ""
}

main "$@"
