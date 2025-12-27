#!/usr/bin/env bash
#
# list-issues.sh - List and filter devloop issues
#
# Usage: list-issues.sh [OPTIONS]
#
# Lists issues from .devloop/issues/ with filtering, sorting, and multiple output formats.
#
# Dependencies: None (pure bash)
# Inputs: .devloop/issues/*.md
# Exit codes: 0=success, 1=error (invalid args or directory not found)

set -euo pipefail

# Color output helpers
if [ -t 1 ]; then
    BOLD='\033[1m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    RESET='\033[0m'
else
    BOLD=''
    GREEN=''
    YELLOW=''
    RED=''
    BLUE=''
    RESET=''
fi

# Helper functions
log_info() {
    echo -e "${GREEN}✓${RESET} $*"
}

log_warn() {
    echo -e "${YELLOW}⚠${RESET} $*"
}

log_error() {
    echo -e "${RED}✗${RESET} $*" >&2
}

# Parse YAML frontmatter from issue file
parse_issue_frontmatter() {
    local file="$1"
    local field="$2"

    # Extract content between first two --- markers
    local in_frontmatter=0
    local value=""

    while IFS= read -r line; do
        if [[ "$line" == "---" ]]; then
            if [ $in_frontmatter -eq 0 ]; then
                in_frontmatter=1
                continue
            else
                break
            fi
        fi

        if [ $in_frontmatter -eq 1 ]; then
            # Check if this line has the field we want
            if [[ "$line" =~ ^${field}:[[:space:]]*(.*) ]]; then
                value="${BASH_REMATCH[1]}"
                # Strip quotes if present
                value="${value#\"}"
                value="${value%\"}"
                # Handle arrays [a, b, c] - just keep as-is for now
                break
            fi
        fi
    done < "$file"

    echo "$value"
}

# Get priority sort value (for sorting)
get_priority_value() {
    local priority="$1"
    case "$priority" in
        high) echo "1" ;;
        medium) echo "2" ;;
        low) echo "3" ;;
        *) echo "4" ;;
    esac
}

# Display help
show_help() {
    cat <<EOF
Usage: list-issues.sh [OPTIONS]

List and filter devloop issues from .devloop/issues/ directory.

OPTIONS:
  --type TYPE          Filter by type (bug, feature, task, chore, spike)
  --status STATUS      Filter by status (open, in-progress, done, blocked)
  --priority PRIORITY  Filter by priority (low, medium, high)
  --format FORMAT      Output format: table (default), json, markdown
  --sort FIELD         Sort by: priority (default), created, updated, id
  --limit N            Limit results to N issues
  -h, --help           Show this help message

EXAMPLES:
  # List all open bugs
  list-issues.sh --type bug --status open

  # High priority issues in JSON format
  list-issues.sh --priority high --format json

  # Top 5 most recently updated issues
  list-issues.sh --sort updated --limit 5

  # All features as markdown
  list-issues.sh --type feature --format markdown

EXIT CODES:
  0 - Success (even if no results)
  1 - Error (invalid arguments, directory not found)
EOF
}

# Parse command line arguments
FILTER_TYPE=""
FILTER_STATUS=""
FILTER_PRIORITY=""
OUTPUT_FORMAT="table"
SORT_FIELD="priority"
LIMIT=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --type)
            FILTER_TYPE="$2"
            shift 2
            ;;
        --status)
            FILTER_STATUS="$2"
            shift 2
            ;;
        --priority)
            FILTER_PRIORITY="$2"
            shift 2
            ;;
        --format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        --sort)
            SORT_FIELD="$2"
            shift 2
            ;;
        --limit)
            LIMIT="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo ""
            echo "Run with -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Validate arguments
if [ -n "$FILTER_TYPE" ] && [[ ! "$FILTER_TYPE" =~ ^(bug|feature|task|chore|spike)$ ]]; then
    log_error "Invalid type: $FILTER_TYPE (must be: bug, feature, task, chore, spike)"
    exit 1
fi

if [ -n "$FILTER_STATUS" ] && [[ ! "$FILTER_STATUS" =~ ^(open|in-progress|done|blocked)$ ]]; then
    log_error "Invalid status: $FILTER_STATUS (must be: open, in-progress, done, blocked)"
    exit 1
fi

if [ -n "$FILTER_PRIORITY" ] && [[ ! "$FILTER_PRIORITY" =~ ^(low|medium|high)$ ]]; then
    log_error "Invalid priority: $FILTER_PRIORITY (must be: low, medium, high)"
    exit 1
fi

if [[ ! "$OUTPUT_FORMAT" =~ ^(table|json|markdown)$ ]]; then
    log_error "Invalid format: $OUTPUT_FORMAT (must be: table, json, markdown)"
    exit 1
fi

if [[ ! "$SORT_FIELD" =~ ^(priority|created|updated|id)$ ]]; then
    log_error "Invalid sort field: $SORT_FIELD (must be: priority, created, updated, id)"
    exit 1
fi

# Check if issues directory exists
ISSUES_DIR=".devloop/issues"
if [ ! -d "$ISSUES_DIR" ]; then
    log_error "Issues directory not found: $ISSUES_DIR"
    echo ""
    echo "Tip: Create issues with /devloop:new"
    exit 1
fi

# Find all issue files (exclude index and category files)
shopt -s nullglob
issue_files=("$ISSUES_DIR"/BUG-*.md "$ISSUES_DIR"/FEAT-*.md "$ISSUES_DIR"/TASK-*.md "$ISSUES_DIR"/CHORE-*.md "$ISSUES_DIR"/SPIKE-*.md)
shopt -u nullglob

if [ ${#issue_files[@]} -eq 0 ]; then
    log_warn "No issues found in $ISSUES_DIR"

    # Output empty result based on format
    case "$OUTPUT_FORMAT" in
        json)
            echo '{"issues":[],"total":0,"filters":{}}'
            ;;
        markdown)
            echo "## Issues (0 total)"
            echo ""
            echo "No issues found."
            ;;
        table)
            echo "No issues found."
            ;;
    esac

    exit 0
fi

# Parse all issues into arrays
declare -a issue_ids
declare -a issue_types
declare -a issue_statuses
declare -a issue_priorities
declare -a issue_titles
declare -a issue_created
declare -a issue_updated
declare -a issue_sort_keys

for file in "${issue_files[@]}"; do
    # Skip if not a regular file
    [ -f "$file" ] || continue

    # Parse frontmatter
    id=$(parse_issue_frontmatter "$file" "id")
    type=$(parse_issue_frontmatter "$file" "type")
    status=$(parse_issue_frontmatter "$file" "status")
    priority=$(parse_issue_frontmatter "$file" "priority")
    title=$(parse_issue_frontmatter "$file" "title")
    created=$(parse_issue_frontmatter "$file" "created")
    updated=$(parse_issue_frontmatter "$file" "updated")

    # Skip if missing required fields
    if [ -z "$id" ] || [ -z "$type" ]; then
        continue
    fi

    # Set defaults for optional fields
    [ -z "$status" ] && status="open"
    [ -z "$priority" ] && priority="medium"
    [ -z "$title" ] && title="Untitled"
    [ -z "$created" ] && created="1970-01-01T00:00:00"
    [ -z "$updated" ] && updated="$created"

    # Apply filters
    if [ -n "$FILTER_TYPE" ] && [ "$type" != "$FILTER_TYPE" ]; then
        continue
    fi

    if [ -n "$FILTER_STATUS" ] && [ "$status" != "$FILTER_STATUS" ]; then
        continue
    fi

    if [ -n "$FILTER_PRIORITY" ] && [ "$priority" != "$FILTER_PRIORITY" ]; then
        continue
    fi

    # Build sort key based on sort field
    case "$SORT_FIELD" in
        priority)
            sort_key="$(get_priority_value "$priority")-$created-$id"
            ;;
        created)
            sort_key="$created-$id"
            ;;
        updated)
            sort_key="$updated-$id"
            ;;
        id)
            sort_key="$id"
            ;;
    esac

    # Add to arrays
    issue_ids+=("$id")
    issue_types+=("$type")
    issue_statuses+=("$status")
    issue_priorities+=("$priority")
    issue_titles+=("$title")
    issue_created+=("$created")
    issue_updated+=("$updated")
    issue_sort_keys+=("$sort_key")
done

# Count filtered issues
# Temporarily disable nounset for array check
set +u
total_issues=${#issue_ids[@]}
set -u

if [ $total_issues -eq 0 ]; then
    log_warn "No issues match the specified filters"

    # Output empty result based on format
    case "$OUTPUT_FORMAT" in
        json)
            cat <<EOF
{
  "issues": [],
  "total": 0,
  "filters": {
    "type": $([ -n "$FILTER_TYPE" ] && echo "\"$FILTER_TYPE\"" || echo "null"),
    "status": $([ -n "$FILTER_STATUS" ] && echo "\"$FILTER_STATUS\"" || echo "null"),
    "priority": $([ -n "$FILTER_PRIORITY" ] && echo "\"$FILTER_PRIORITY\"" || echo "null")
  }
}
EOF
            ;;
        markdown)
            echo "## Issues (0 total)"
            echo ""
            echo "No issues match the specified filters."
            ;;
        table)
            echo "No issues match the specified filters."
            ;;
    esac

    exit 0
fi

# Sort issues (bubble sort is simple for small datasets)
for ((i=0; i<$total_issues; i++)); do
    for ((j=i+1; j<$total_issues; j++)); do
        # Compare sort keys
        if [[ "${issue_sort_keys[$i]}" > "${issue_sort_keys[$j]}" ]]; then
            # Swap all arrays
            tmp="${issue_ids[$i]}"; issue_ids[$i]="${issue_ids[$j]}"; issue_ids[$j]="$tmp"
            tmp="${issue_types[$i]}"; issue_types[$i]="${issue_types[$j]}"; issue_types[$j]="$tmp"
            tmp="${issue_statuses[$i]}"; issue_statuses[$i]="${issue_statuses[$j]}"; issue_statuses[$j]="$tmp"
            tmp="${issue_priorities[$i]}"; issue_priorities[$i]="${issue_priorities[$j]}"; issue_priorities[$j]="$tmp"
            tmp="${issue_titles[$i]}"; issue_titles[$i]="${issue_titles[$j]}"; issue_titles[$j]="$tmp"
            tmp="${issue_created[$i]}"; issue_created[$i]="${issue_created[$j]}"; issue_created[$j]="$tmp"
            tmp="${issue_updated[$i]}"; issue_updated[$i]="${issue_updated[$j]}"; issue_updated[$j]="$tmp"
            tmp="${issue_sort_keys[$i]}"; issue_sort_keys[$i]="${issue_sort_keys[$j]}"; issue_sort_keys[$j]="$tmp"
        fi
    done
done

# Apply limit
if [ $LIMIT -gt 0 ] && [ $LIMIT -lt $total_issues ]; then
    display_count=$LIMIT
else
    display_count=$total_issues
fi

# Output based on format
case "$OUTPUT_FORMAT" in
    json)
        echo "{"
        echo "  \"issues\": ["

        for ((i=0; i<$display_count; i++)); do
            # Escape title for JSON
            json_title="${issue_titles[$i]//\\/\\\\}"
            json_title="${json_title//\"/\\\"}"
            json_title="${json_title//$'\n'/\\n}"

            echo "    {"
            echo "      \"id\": \"${issue_ids[$i]}\","
            echo "      \"type\": \"${issue_types[$i]}\","
            echo "      \"status\": \"${issue_statuses[$i]}\","
            echo "      \"priority\": \"${issue_priorities[$i]}\","
            echo "      \"title\": \"$json_title\","
            echo "      \"created\": \"${issue_created[$i]}\","
            echo "      \"updated\": \"${issue_updated[$i]}\""

            if [ $i -lt $((display_count - 1)) ]; then
                echo "    },"
            else
                echo "    }"
            fi
        done

        echo "  ],"
        echo "  \"total\": $total_issues,"
        echo "  \"displayed\": $display_count,"
        echo "  \"filters\": {"
        echo "    \"type\": $([ -n "$FILTER_TYPE" ] && echo "\"$FILTER_TYPE\"" || echo "null"),"
        echo "    \"status\": $([ -n "$FILTER_STATUS" ] && echo "\"$FILTER_STATUS\"" || echo "null"),"
        echo "    \"priority\": $([ -n "$FILTER_PRIORITY" ] && echo "\"$FILTER_PRIORITY\"" || echo "null")"
        echo "  }"
        echo "}"
        ;;

    markdown)
        echo "## Issues ($total_issues total)"
        echo ""

        if [ -n "$FILTER_TYPE" ] || [ -n "$FILTER_STATUS" ] || [ -n "$FILTER_PRIORITY" ]; then
            echo "**Filters**: "
            [ -n "$FILTER_TYPE" ] && echo "Type=$FILTER_TYPE "
            [ -n "$FILTER_STATUS" ] && echo "Status=$FILTER_STATUS "
            [ -n "$FILTER_PRIORITY" ] && echo "Priority=$FILTER_PRIORITY "
            echo ""
            echo ""
        fi

        # Group by status
        declare -A status_groups
        for ((i=0; i<$display_count; i++)); do
            status="${issue_statuses[$i]}"
            # Initialize if not set
            if [ -z "${status_groups[$status]+x}" ]; then
                status_groups[$status]=""
            fi
            status_groups[$status]="${status_groups[$status]}$i "
        done

        for status in open in-progress blocked done; do
            # Check if key exists and has value
            if [ -n "${status_groups[$status]:-}" ] && [ "${status_groups[$status]:-}" != "" ]; then
                # Count items in this status
                count=$(echo "${status_groups[$status]}" | wc -w)

                # Capitalize status for header
                status_display="$(echo "${status:0:1}" | tr '[:lower:]' '[:upper:]')${status:1}"

                echo "### $status_display ($count)"
                echo ""

                for idx in ${status_groups[$status]}; do
                    id="${issue_ids[$idx]}"
                    type="${issue_types[$idx]}"
                    priority="${issue_priorities[$idx]}"
                    title="${issue_titles[$idx]}"

                    echo "- [${id}](${id}.md) - **${priority}** - ${title}"
                done

                echo ""
            fi
        done
        ;;

    table)
        # Calculate column widths
        max_id_len=2
        max_type_len=4
        max_status_len=6
        max_priority_len=8

        for ((i=0; i<$display_count; i++)); do
            [ ${#issue_ids[$i]} -gt $max_id_len ] && max_id_len=${#issue_ids[$i]}
            [ ${#issue_types[$i]} -gt $max_type_len ] && max_type_len=${#issue_types[$i]}
            [ ${#issue_statuses[$i]} -gt $max_status_len ] && max_status_len=${#issue_statuses[$i]}
            [ ${#issue_priorities[$i]} -gt $max_priority_len ] && max_priority_len=${#issue_priorities[$i]}
        done

        # Print header
        printf "%-${max_id_len}s | %-${max_type_len}s | %-${max_status_len}s | %-${max_priority_len}s | %s\n" \
            "ID" "Type" "Status" "Priority" "Title"

        # Print separator
        printf "%${max_id_len}s-|-%${max_type_len}s-|-%${max_status_len}s-|-%${max_priority_len}s-|-%s\n" \
            "" "" "" "" "" | tr ' ' '-'

        # Print rows
        for ((i=0; i<$display_count; i++)); do
            # Truncate title if too long
            title="${issue_titles[$i]}"
            if [ ${#title} -gt 50 ]; then
                title="${title:0:47}..."
            fi

            printf "%-${max_id_len}s | %-${max_type_len}s | %-${max_status_len}s | %-${max_priority_len}s | %s\n" \
                "${issue_ids[$i]}" "${issue_types[$i]}" "${issue_statuses[$i]}" "${issue_priorities[$i]}" "$title"
        done

        # Print summary
        echo ""
        echo "Total: $total_issues issue(s)"
        if [ $display_count -lt $total_issues ]; then
            echo "Showing first $display_count"
        fi
        ;;
esac

exit 0
