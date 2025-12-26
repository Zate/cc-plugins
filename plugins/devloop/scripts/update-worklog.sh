#!/bin/bash
# update-worklog.sh - Append entries to devloop worklog
#
# Central script for maintaining consistent worklog format.
# Handles appending entries, rotating when needed, and validating format.
#
# Usage:
#   update-worklog.sh "commit-hash" "description"
#   update-worklog.sh --task "1.1" "commit-hash" "description"
#   update-worklog.sh --check                    # Validate worklog format
#   update-worklog.sh --init                     # Create new worklog
#
# Examples:
#   update-worklog.sh "abc1234" "feat: add user auth"
#   update-worklog.sh --task "2.1,2.2" "def5678" "feat: implement login"

set -uo pipefail

# Configuration
WORKLOG_FILE=".devloop/worklog.md"
ROTATION_THRESHOLD=500
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# Helper functions
log() { echo -e "$1"; }
error() { echo -e "${RED}Error: $1${RESET}" >&2; }
success() { echo -e "${GREEN}$1${RESET}"; }
warn() { echo -e "${YELLOW}$1${RESET}"; }

# Get current timestamp in ISO format
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Get current date
get_date() {
    date +"%Y-%m-%d"
}

# Initialize a new worklog
init_worklog() {
    local project_name
    project_name=$(basename "$(pwd)")
    local current_date
    current_date=$(get_date)

    if [ -f "$WORKLOG_FILE" ]; then
        error "Worklog already exists at $WORKLOG_FILE"
        echo "Use --force to overwrite"
        return 1
    fi

    mkdir -p "$(dirname "$WORKLOG_FILE")"

    cat > "$WORKLOG_FILE" << EOF
# Devloop Worklog

**Project**: $project_name
**Started**: $current_date
**Last Updated**: $current_date

---

## Current Work

### Commits

| Hash | Date | Message | Tasks |
|------|------|---------|-------|

### Tasks Completed

EOF

    success "Created new worklog at $WORKLOG_FILE"
    return 0
}

# Check if worklog needs rotation
check_rotation() {
    if [ ! -f "$WORKLOG_FILE" ]; then
        return 1
    fi

    local line_count
    line_count=$(wc -l < "$WORKLOG_FILE" | tr -d ' ')

    if [ "$line_count" -ge "$ROTATION_THRESHOLD" ]; then
        warn "Worklog has $line_count lines (threshold: $ROTATION_THRESHOLD)"
        echo "Consider running: rotate-worklog.sh"
        return 0
    fi
    return 1
}

# Validate worklog format
validate_worklog() {
    if [ ! -f "$WORKLOG_FILE" ]; then
        error "No worklog found at $WORKLOG_FILE"
        return 1
    fi

    local errors=0

    # Check for title
    if ! grep -q "^# Devloop Worklog" "$WORKLOG_FILE"; then
        error "Missing worklog title (expected: # Devloop Worklog)"
        errors=$((errors + 1))
    fi

    # Check for Last Updated field
    if ! grep -q "^\*\*Last Updated\*\*:" "$WORKLOG_FILE"; then
        warn "Missing Last Updated field"
    fi

    # Check for Commits table header
    if ! grep -q "| Hash | Date | Message | Tasks |" "$WORKLOG_FILE"; then
        warn "Missing commits table header"
    fi

    if [ "$errors" -gt 0 ]; then
        return 1
    fi

    success "Worklog format valid"
    return 0
}

# Update the Last Updated timestamp
update_timestamp() {
    local current_date
    current_date=$(get_date)

    if grep -q "^\*\*Last Updated\*\*:" "$WORKLOG_FILE"; then
        # Use sed to update the timestamp in place
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^\*\*Last Updated\*\*:.*$/\*\*Last Updated\*\*: $current_date/" "$WORKLOG_FILE"
        else
            sed -i "s/^\*\*Last Updated\*\*:.*$/\*\*Last Updated\*\*: $current_date/" "$WORKLOG_FILE"
        fi
    fi
}

# Add a commit entry to the worklog
add_commit_entry() {
    local commit_hash="$1"
    local message="$2"
    local tasks="${3:-}"
    local current_date
    current_date=$(get_date)

    # Truncate commit hash to 7 chars if longer
    if [ ${#commit_hash} -gt 7 ]; then
        commit_hash="${commit_hash:0:7}"
    fi

    # Escape pipe characters in message
    message=$(echo "$message" | sed 's/|/\\|/g')

    # Format the table row
    local entry="| $commit_hash | $current_date | $message | $tasks |"

    # Find the commit table and append after the header row
    # Look for the line with "| Hash | Date |" and insert after the separator line
    local table_line
    table_line=$(grep -n "| Hash | Date | Message | Tasks |" "$WORKLOG_FILE" | head -1 | cut -d: -f1)

    if [ -z "$table_line" ]; then
        error "Could not find commits table in worklog"
        return 1
    fi

    # Insert entry after the table header (header + separator = +2 lines)
    local insert_line=$((table_line + 2))

    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "${insert_line}i\\
$entry
" "$WORKLOG_FILE"
    else
        sed -i "${insert_line}i\\$entry" "$WORKLOG_FILE"
    fi

    update_timestamp
    success "Added commit entry: $commit_hash"
    return 0
}

# Add a completed task entry
add_task_entry() {
    local task_id="$1"
    local description="$2"
    local commit_hash="${3:-}"

    local entry="- [x] Task $task_id: $description"
    if [ -n "$commit_hash" ]; then
        entry="$entry ($commit_hash)"
    fi

    # Find "Tasks Completed" section and append
    local section_line
    section_line=$(grep -n "^### Tasks Completed" "$WORKLOG_FILE" | head -1 | cut -d: -f1)

    if [ -z "$section_line" ]; then
        error "Could not find 'Tasks Completed' section in worklog"
        return 1
    fi

    # Insert after section header
    local insert_line=$((section_line + 1))

    # Find next section or end of file
    local next_section
    next_section=$(tail -n +$((section_line + 1)) "$WORKLOG_FILE" | grep -n "^##" | head -1 | cut -d: -f1)

    if [ -n "$next_section" ]; then
        insert_line=$((section_line + next_section - 1))
    else
        # Append at end
        echo "$entry" >> "$WORKLOG_FILE"
        update_timestamp
        success "Added task entry: Task $task_id"
        return 0
    fi

    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "${insert_line}i\\
$entry
" "$WORKLOG_FILE"
    else
        sed -i "${insert_line}i\\$entry" "$WORKLOG_FILE"
    fi

    update_timestamp
    success "Added task entry: Task $task_id"
    return 0
}

# Main logic
main() {
    local tasks=""
    local mode="append"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --init)
                mode="init"
                shift
                ;;
            --check)
                mode="check"
                shift
                ;;
            --task)
                tasks="$2"
                shift 2
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --help|-h)
                echo "Usage: update-worklog.sh [OPTIONS] [commit-hash] [description]"
                echo ""
                echo "Options:"
                echo "  --init          Create new worklog"
                echo "  --check         Validate worklog format"
                echo "  --task TASKS    Task ID(s) for this commit (e.g., '1.1' or '1.1,1.2')"
                echo "  --force         Force operation"
                echo "  --help          Show this help"
                exit 0
                ;;
            -*)
                error "Unknown option: $1"
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done

    case $mode in
        init)
            init_worklog
            exit $?
            ;;
        check)
            validate_worklog
            check_rotation
            exit $?
            ;;
        append)
            if [ $# -lt 2 ]; then
                error "Missing arguments: commit-hash and description required"
                echo "Usage: update-worklog.sh [--task TASKS] commit-hash description"
                exit 1
            fi

            local commit_hash="$1"
            local description="$2"

            # Ensure worklog exists
            if [ ! -f "$WORKLOG_FILE" ]; then
                warn "No worklog found, creating new one..."
                init_worklog
            fi

            # Check rotation
            check_rotation || true

            # Add commit entry
            add_commit_entry "$commit_hash" "$description" "$tasks"

            # If tasks specified, also add task entries
            if [ -n "$tasks" ]; then
                IFS=',' read -ra task_array <<< "$tasks"
                for task in "${task_array[@]}"; do
                    task=$(echo "$task" | tr -d ' ')
                    add_task_entry "$task" "$(echo "$description" | sed 's/^[a-z]*: //')" "${commit_hash:0:7}"
                done
            fi
            ;;
    esac
}

main "$@"
