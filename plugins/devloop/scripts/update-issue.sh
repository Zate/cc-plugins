#!/usr/bin/env bash
#
# update-issue.sh - Update issue status, metadata, and add comments
#
# Usage: update-issue.sh ISSUE_ID [options]
#
# Updates existing issues in .devloop/issues/ directory
#
# Arguments:
#   ISSUE_ID              Issue ID (e.g., BUG-001, FEAT-002)
#
# Options:
#   --status STATUS       Update status to: open, in-progress, done, blocked
#   --priority PRIORITY   Update priority to: low, medium, high
#   --assignee NAME       Set assignee name
#   --add-label LABEL     Add a label (can be used multiple times)
#   --remove-label LABEL  Remove a label (can be used multiple times)
#   --comment TEXT        Add a comment to the Notes section
#   --resolve TEXT        Mark as done and add resolution summary
#   --output-format FMT   Output format: md (default) or json
#   -h, --help            Show this help message
#
# Examples:
#   update-issue.sh BUG-001 --status done
#   update-issue.sh FEAT-002 --comment "Started implementation"
#   update-issue.sh BUG-001 --resolve "Fixed in commit abc123 by updating validation"
#   update-issue.sh TASK-001 --status in-progress --assignee "claude" --add-label "urgent"
#
# Dependencies: None (pure bash)
# Exit codes:
#   0 - Success
#   1 - Issue not found
#   2 - Invalid arguments
#

set -euo pipefail

# Color output helpers
if [ -t 1 ]; then
    BOLD='\033[1m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    RED='\033[0;31m'
    RESET='\033[0m'
else
    BOLD=''
    GREEN=''
    YELLOW=''
    RED=''
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

# Show help message
show_help() {
    cat <<'EOF'
Usage: update-issue.sh ISSUE_ID [options]

Updates existing issues in .devloop/issues/ directory

Arguments:
  ISSUE_ID              Issue ID (e.g., BUG-001, FEAT-002)

Options:
  --status STATUS       Update status to: open, in-progress, done, blocked
  --priority PRIORITY   Update priority to: low, medium, high
  --assignee NAME       Set assignee name
  --add-label LABEL     Add a label (can be used multiple times)
  --remove-label LABEL  Remove a label (can be used multiple times)
  --comment TEXT        Add a comment to the Notes section
  --resolve TEXT        Mark as done and add resolution summary
  --output-format FMT   Output format: md (default) or json
  -h, --help            Show this help message

Examples:
  update-issue.sh BUG-001 --status done
  update-issue.sh FEAT-002 --comment "Started implementation"
  update-issue.sh BUG-001 --resolve "Fixed in commit abc123 by updating validation"
  update-issue.sh TASK-001 --status in-progress --assignee "claude" --add-label "urgent"

Exit codes:
  0 - Success
  1 - Issue not found
  2 - Invalid arguments
EOF
}

# Find issue file (case-insensitive)
find_issue_file() {
    local issue_id="$1"
    local issues_dir=".devloop/issues"

    if [ ! -d "$issues_dir" ]; then
        return 1
    fi

    # Try exact match first
    if [ -f "$issues_dir/${issue_id}.md" ]; then
        echo "$issues_dir/${issue_id}.md"
        return 0
    fi

    # Try case-insensitive match
    local found
    found=$(find "$issues_dir" -maxdepth 1 -iname "${issue_id}.md" -type f | head -1)

    if [ -n "$found" ]; then
        echo "$found"
        return 0
    fi

    return 1
}

# Parse YAML frontmatter field
parse_yaml_field() {
    local file="$1"
    local field="$2"

    # Extract value between --- delimiters
    sed -n '/^---$/,/^---$/p' "$file" | grep "^${field}:" | sed "s/^${field}:[[:space:]]*//" | head -1
}

# Parse YAML array (labels)
parse_yaml_array() {
    local file="$1"
    local field="$2"

    # Extract array value between [ and ]
    local array_line
    array_line=$(sed -n '/^---$/,/^---$/p' "$file" | grep "^${field}:" | sed "s/^${field}:[[:space:]]*//")

    if [[ "$array_line" =~ ^\[(.*)\]$ ]]; then
        local content="${BASH_REMATCH[1]}"
        # Remove quotes and spaces, output comma-separated
        echo "$content" | tr -d ' "' | tr ',' '\n' | grep -v '^$' || true
    fi
}

# Format array for YAML
format_yaml_array() {
    local -a items=("$@")

    if [ ${#items[@]} -eq 0 ]; then
        echo "[]"
        return
    fi

    # Build comma-separated quoted items
    local output="["
    local first=true
    for item in "${items[@]}"; do
        if [ "$first" = true ]; then
            output+="$item"
            first=false
        else
            output+=", $item"
        fi
    done
    output+="]"
    echo "$output"
}

# Extract body content (everything after frontmatter)
extract_body() {
    local file="$1"

    # Find the second --- and print everything after it
    sed -n '/^---$/,/^---$/d; /^---$/,$p' "$file"
}

# Update frontmatter field
update_frontmatter_field() {
    local frontmatter="$1"
    local field="$2"
    local value="$3"

    # Replace or add field
    if echo "$frontmatter" | grep -q "^${field}:"; then
        echo "$frontmatter" | sed "s/^${field}:.*/${field}: ${value}/"
    else
        # Add new field before closing ---
        echo "$frontmatter"$'\n'"${field}: ${value}"
    fi
}

# Main execution
main() {
    local issue_id=""
    local new_status=""
    local new_priority=""
    local new_assignee=""
    local -a add_labels=()
    local -a remove_labels=()
    local comment=""
    local resolution=""
    local output_format="md"

    # Parse arguments
    # Check for help flag first
    for arg in "$@"; do
        if [ "$arg" = "-h" ] || [ "$arg" = "--help" ]; then
            show_help
            exit 0
        fi
    done

    if [ $# -eq 0 ]; then
        log_error "Missing issue ID"
        echo ""
        show_help
        exit 2
    fi

    issue_id="$1"
    shift

    while [[ $# -gt 0 ]]; do
        case $1 in
            --status)
                new_status="$2"
                shift 2
                ;;
            --priority)
                new_priority="$2"
                shift 2
                ;;
            --assignee)
                new_assignee="$2"
                shift 2
                ;;
            --add-label)
                add_labels+=("$2")
                shift 2
                ;;
            --remove-label)
                remove_labels+=("$2")
                shift 2
                ;;
            --comment)
                comment="$2"
                shift 2
                ;;
            --resolve)
                resolution="$2"
                new_status="done"  # Auto-set status to done
                shift 2
                ;;
            --output-format)
                output_format="$2"
                shift 2
                ;;
            *)
                log_error "Unknown option: $1"
                echo ""
                show_help
                exit 2
                ;;
        esac
    done

    # Validate status values
    if [ -n "$new_status" ]; then
        case "$new_status" in
            open|in-progress|done|blocked)
                ;;
            *)
                log_error "Invalid status: $new_status (must be: open, in-progress, done, blocked)"
                exit 2
                ;;
        esac
    fi

    # Validate priority values
    if [ -n "$new_priority" ]; then
        case "$new_priority" in
            low|medium|high)
                ;;
            *)
                log_error "Invalid priority: $new_priority (must be: low, medium, high)"
                exit 2
                ;;
        esac
    fi

    # Find issue file
    local issue_file
    if ! issue_file=$(find_issue_file "$issue_id"); then
        log_error "Issue not found: $issue_id"
        echo ""
        echo "Searched in: .devloop/issues/"
        echo "Tip: Use 'ls .devloop/issues/' to see available issues"
        exit 1
    fi

    # Check if file has no changes to make
    if [ -z "$new_status" ] && [ -z "$new_priority" ] && [ -z "$new_assignee" ] && \
       [ ${#add_labels[@]} -eq 0 ] && [ ${#remove_labels[@]} -eq 0 ] && \
       [ -z "$comment" ] && [ -z "$resolution" ]; then
        log_warn "No changes specified"
        echo ""
        echo "Specify at least one option to update the issue."
        echo "Use --help to see available options."
        exit 2
    fi

    # Parse existing frontmatter
    local current_status
    current_status=$(parse_yaml_field "$issue_file" "status")

    local current_priority
    current_priority=$(parse_yaml_field "$issue_file" "priority")

    local current_assignee
    current_assignee=$(parse_yaml_field "$issue_file" "assignee")

    local current_resolved
    current_resolved=$(parse_yaml_field "$issue_file" "resolved" || echo "null")

    # Parse existing labels
    local -a current_labels=()
    while IFS= read -r label; do
        [ -n "$label" ] && current_labels+=("$label")
    done < <(parse_yaml_array "$issue_file" "labels")

    # Update labels
    local -a updated_labels=("${current_labels[@]}")

    # Add new labels
    for add_label in "${add_labels[@]}"; do
        # Check if already exists
        local exists=false
        for existing in "${updated_labels[@]}"; do
            if [ "$existing" = "$add_label" ]; then
                exists=true
                break
            fi
        done
        if [ "$exists" = false ]; then
            updated_labels+=("$add_label")
        fi
    done

    # Remove labels
    for remove_label in "${remove_labels[@]}"; do
        local -a temp_labels=()
        for existing in "${updated_labels[@]}"; do
            if [ "$existing" != "$remove_label" ]; then
                temp_labels+=("$existing")
            fi
        done
        updated_labels=("${temp_labels[@]}")
    done

    # Determine final values
    local final_status="${new_status:-$current_status}"
    local final_priority="${new_priority:-$current_priority}"
    local final_assignee="${new_assignee:-$current_assignee}"
    local final_resolved="$current_resolved"

    # Handle status transitions
    if [ "$final_status" = "done" ] && [ "$current_status" != "done" ]; then
        # Transitioning to done - set resolved timestamp
        final_resolved=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    elif [ "$final_status" != "done" ] && [ "$current_status" = "done" ]; then
        # Transitioning from done - clear resolved timestamp
        final_resolved="null"
    fi

    # Generate updated timestamp
    local updated_timestamp
    updated_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Build new frontmatter (extract content between first and second ---)
    local frontmatter
    frontmatter=$(awk '/^---$/ {count++; next} count == 1' "$issue_file")

    # Update fields
    frontmatter=$(update_frontmatter_field "$frontmatter" "status" "$final_status")
    frontmatter=$(update_frontmatter_field "$frontmatter" "priority" "$final_priority")
    frontmatter=$(update_frontmatter_field "$frontmatter" "assignee" "${final_assignee:-null}")
    frontmatter=$(update_frontmatter_field "$frontmatter" "updated" "$updated_timestamp")

    if [ "$final_resolved" != "$current_resolved" ]; then
        frontmatter=$(update_frontmatter_field "$frontmatter" "resolved" "$final_resolved")
    fi

    # Update labels if changed
    if [ ${#updated_labels[@]} -ne ${#current_labels[@]} ] || \
       [ "${updated_labels[*]}" != "${current_labels[*]}" ]; then
        local labels_str
        labels_str=$(format_yaml_array "${updated_labels[@]}")
        frontmatter=$(update_frontmatter_field "$frontmatter" "labels" "$labels_str")
    fi

    # Extract body (everything after the second ---)
    local body
    body=$(awk '/^---$/ {count++; next} count >= 2' "$issue_file")

    # Add comment to Notes section if provided
    if [ -n "$comment" ]; then
        local timestamp_display
        timestamp_display=$(date -u +"%Y-%m-%d %H:%M")

        # Check if Notes section exists
        if echo "$body" | grep -q "^## Notes"; then
            # Append to existing Notes section
            body=$(echo "$body" | sed "/^## Notes/a\\
\\
- **${timestamp_display}**: ${comment}")
        else
            # Add Notes section before Resolution
            if echo "$body" | grep -q "^## Resolution"; then
                body=$(echo "$body" | sed "/^## Resolution/i\\
## Notes\\
\\
- **${timestamp_display}**: ${comment}\\
")
            else
                # Add at end
                body="${body}"$'\n\n'"## Notes"$'\n\n'"- **${timestamp_display}**: ${comment}"
            fi
        fi
    fi

    # Add resolution if provided
    if [ -n "$resolution" ]; then
        # Check if Resolution section exists
        if echo "$body" | grep -q "^## Resolution"; then
            # Replace existing resolution content
            body=$(echo "$body" | sed "/^## Resolution/,\$d")
            body="${body}"$'\n\n'"## Resolution"$'\n\n'"${resolution}"
        else
            # Add Resolution section at end
            body="${body}"$'\n\n'"## Resolution"$'\n\n'"${resolution}"
        fi
    fi

    # Write updated file
    {
        echo "---"
        echo "$frontmatter"
        echo "---"
        echo ""
        echo "$body"
    } > "$issue_file"

    # Display summary based on output format
    if [ "$output_format" = "json" ]; then
        cat <<EOF
{
  "issue": "$issue_id",
  "file": "$issue_file",
  "status": "$final_status",
  "priority": "$final_priority",
  "assignee": "${final_assignee:-null}",
  "labels": $(format_yaml_array "${updated_labels[@]}"),
  "updated": "$updated_timestamp"
}
EOF
    else
        echo ""
        echo -e "${BOLD}## Issue Updated ✓${RESET}"
        echo ""
        echo -e "${BOLD}Issue${RESET}: $issue_id"
        echo -e "${BOLD}File${RESET}: $issue_file"
        echo ""

        # Show changes
        local -a changes=()
        [ -n "$new_status" ] && changes+=("Status: $current_status → $final_status")
        [ -n "$new_priority" ] && changes+=("Priority: $current_priority → $final_priority")
        [ -n "$new_assignee" ] && changes+=("Assignee: ${current_assignee:-none} → $final_assignee")
        [ ${#add_labels[@]} -gt 0 ] && changes+=("Added labels: ${add_labels[*]}")
        [ ${#remove_labels[@]} -gt 0 ] && changes+=("Removed labels: ${remove_labels[*]}")
        [ -n "$comment" ] && changes+=("Added comment")
        [ -n "$resolution" ] && changes+=("Added resolution")

        if [ ${#changes[@]} -gt 0 ]; then
            echo -e "${BOLD}Changes:${RESET}"
            for change in "${changes[@]}"; do
                echo "  - $change"
            done
            echo ""
        fi

        echo -e "${BOLD}Current State:${RESET}"
        echo "  Status: $final_status"
        echo "  Priority: $final_priority"
        echo "  Assignee: ${final_assignee:-none}"
        echo "  Labels: $(format_yaml_array "${updated_labels[@]}")"
        [ "$final_resolved" != "null" ] && echo "  Resolved: $final_resolved"
        echo ""
    fi

    log_info "Issue updated successfully"
    exit 0
}

main "$@"
