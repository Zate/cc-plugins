#!/usr/bin/env bash
#
# create-issue.sh - Create structured issue files
#
# Usage: create-issue.sh --type TYPE --title TITLE [OPTIONS]
#
# Creates BUG-NNN.md, FEAT-NNN.md, TASK-NNN.md, CHORE-NNN.md, or SPIKE-NNN.md
# in .devloop/issues/ with the correct structure.
#
# Dependencies: None (pure bash)
# Outputs: .devloop/issues/<TYPE>-NNN.md
# Exit codes: 0=success, 1=validation error, 2=file creation error

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

# Show usage
show_usage() {
    cat <<EOF
Usage: create-issue.sh --type TYPE --title TITLE [OPTIONS]

Create a structured issue file in .devloop/issues/

Required:
  --type TYPE           Issue type: bug, feature, task, chore, spike
  --title TITLE         Issue title (brief description)

Optional:
  --priority PRIORITY   Priority: low, medium, high (default: medium)
  --labels LABELS       Comma-separated labels
  --estimate ESTIMATE   Estimate (features only): XS, S, M, L, XL
  --description DESC    Issue description
  --output-format FMT   Output format: md (default) or json

Options:
  -h, --help           Show this help message

Examples:
  create-issue.sh --type bug --title "Login fails on Safari"
  create-issue.sh --type feature --title "Add OAuth login" --priority high --estimate M
  create-issue.sh --type task --title "Update docs" --labels documentation,cleanup

Exit codes:
  0 - Success (issue created)
  1 - Validation error (invalid type, priority, etc.)
  2 - File creation error
EOF
}

# Validate type
validate_type() {
    local type="$1"
    case "$type" in
        bug|feature|task|chore|spike)
            return 0
            ;;
        *)
            log_error "Invalid type: $type"
            echo "Valid types: bug, feature, task, chore, spike"
            return 1
            ;;
    esac
}

# Validate priority
validate_priority() {
    local priority="$1"
    case "$priority" in
        low|medium|high)
            return 0
            ;;
        *)
            log_error "Invalid priority: $priority"
            echo "Valid priorities: low, medium, high"
            return 1
            ;;
    esac
}

# Validate estimate (for features)
validate_estimate() {
    local estimate="$1"
    case "$estimate" in
        XS|S|M|L|XL)
            return 0
            ;;
        *)
            log_error "Invalid estimate: $estimate"
            echo "Valid estimates: XS, S, M, L, XL"
            return 1
            ;;
    esac
}

# Get type prefix (BUG, FEAT, TASK, CHORE, SPIKE)
get_type_prefix() {
    local type="$1"
    case "$type" in
        bug) echo "BUG" ;;
        feature) echo "FEAT" ;;
        task) echo "TASK" ;;
        chore) echo "CHORE" ;;
        spike) echo "SPIKE" ;;
    esac
}

# Find next available ID for a type prefix
get_next_id() {
    local prefix="$1"
    local issues_dir=".devloop/issues"

    # Create directory if it doesn't exist
    mkdir -p "$issues_dir"

    # Find all existing issues matching this prefix
    local max_id=0
    shopt -s nullglob
    for file in "$issues_dir"/"$prefix"-*.md; do

        # Extract number from filename (e.g., BUG-001.md -> 001)
        if [[ $(basename "$file") =~ $prefix-([0-9]+)\.md ]]; then
            local id="${BASH_REMATCH[1]}"
            # Remove leading zeros for comparison
            id=$((10#$id))
            if [ "$id" -gt "$max_id" ]; then
                max_id=$id
            fi
        fi
    done

    # Next ID is max + 1
    local next_id=$((max_id + 1))

    # Zero-pad to 3 digits
    printf "%03d" "$next_id"
}

# Generate timestamp in ISO 8601 format
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%S"
}

# Format labels array for YAML frontmatter
format_labels() {
    local labels="$1"

    if [ -z "$labels" ]; then
        echo "[]"
        return
    fi

    # Split on comma and format as YAML array
    local formatted="["
    local first=true
    IFS=',' read -ra LABEL_ARRAY <<< "$labels"
    for label in "${LABEL_ARRAY[@]}"; do
        # Trim whitespace
        label=$(echo "$label" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [ -n "$label" ]; then
            if [ "$first" = false ]; then
                formatted+=", "
            fi
            formatted+="$label"
            first=false
        fi
    done
    formatted+="]"
    echo "$formatted"
}

# Generate bug issue content
generate_bug_content() {
    local id="$1"
    local title="$2"
    local priority="$3"
    local labels="$4"
    local description="$5"
    local timestamp="$6"

    cat <<EOF
---
id: $id
type: bug
title: $title
status: open
priority: $priority
created: $timestamp
updated: $timestamp
resolved: null
reporter: user
assignee: null
labels: $labels
related-files: []
---

# $id: $title

## Description

$description

## Steps to Reproduce

1. [Step 1]
2. [Step 2]

## Expected Behavior

[Expected behavior]

## Root Cause

[Leave empty for new bugs]

## Proposed Fix

[Optional]

## Notes

[Additional notes]

## Resolution

<!-- Filled in when done -->
- **Resolved in**:
- **Resolved by**:
- **Resolution summary**:
EOF
}

# Generate feature issue content
generate_feature_content() {
    local id="$1"
    local title="$2"
    local priority="$3"
    local labels="$4"
    local estimate="$5"
    local description="$6"
    local timestamp="$7"

    cat <<EOF
---
id: $id
type: feature
title: $title
status: open
priority: $priority
created: $timestamp
updated: $timestamp
reporter: user
assignee: null
labels: $labels
estimate: $estimate
related-files: []
---

# $id: $title

## Description

$description

## Current Behavior

[Optional - what exists now]

## Proposed Behavior

[What should change]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Technical Notes

[Optional technical details]

## Notes

[Additional notes]

## Resolution

<!-- Filled in when done -->
- **Resolved in**:
- **Resolved by**:
- **Resolution summary**:
EOF
}

# Generate task issue content
generate_task_content() {
    local id="$1"
    local title="$2"
    local priority="$3"
    local labels="$4"
    local description="$5"
    local timestamp="$6"

    cat <<EOF
---
id: $id
type: task
title: $title
status: open
priority: $priority
created: $timestamp
updated: $timestamp
reporter: user
assignee: null
labels: $labels
related-files: []
---

# $id: $title

## Description

$description

## Tasks

- [ ] [Task 1]
- [ ] [Task 2]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Notes

[Additional notes]

## Resolution

<!-- Filled in when done -->
- **Resolved in**:
- **Resolved by**:
- **Resolution summary**:
EOF
}

# Generate chore issue content
generate_chore_content() {
    local id="$1"
    local title="$2"
    local priority="$3"
    local labels="$4"
    local description="$5"
    local timestamp="$6"

    cat <<EOF
---
id: $id
type: chore
title: $title
status: open
priority: $priority
created: $timestamp
updated: $timestamp
reporter: user
assignee: null
labels: $labels
related-files: []
---

# $id: $title

## Description

$description

## Tasks

- [ ] [Task 1]
- [ ] [Task 2]

## Notes

[Additional notes]

## Resolution

<!-- Filled in when done -->
- **Resolved in**:
- **Resolved by**:
- **Resolution summary**:
EOF
}

# Generate spike issue content
generate_spike_content() {
    local id="$1"
    local title="$2"
    local priority="$3"
    local labels="$4"
    local description="$5"
    local timestamp="$6"

    cat <<EOF
---
id: $id
type: spike
title: $title
status: open
priority: $priority
created: $timestamp
updated: $timestamp
reporter: user
assignee: null
labels: $labels
related-files: []
---

# $id: $title

## Description

$description

## Questions to Answer

1. [Question 1]
2. [Question 2]

## Hypotheses

[Hypotheses to test]

## Findings

[Research findings - filled during spike]

## Recommendation

[Recommended approach - filled during spike]

## Notes

[Additional notes]

## Resolution

<!-- Filled in when done -->
- **Resolved in**:
- **Resolved by**:
- **Resolution summary**:
EOF
}

# Output JSON format
output_json() {
    local id="$1"
    local file_path="$2"
    local type="$3"
    local title="$4"

    cat <<EOF
{
  "id": "$id",
  "file": "$file_path",
  "type": "$type",
  "title": "$title"
}
EOF
}

# Main execution
main() {
    local type=""
    local title=""
    local priority="medium"
    local labels=""
    local estimate=""
    local description=""
    local output_format="md"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            --type)
                type="$2"
                shift 2
                ;;
            --title)
                title="$2"
                shift 2
                ;;
            --priority)
                priority="$2"
                shift 2
                ;;
            --labels)
                labels="$2"
                shift 2
                ;;
            --estimate)
                estimate="$2"
                shift 2
                ;;
            --description)
                description="$2"
                shift 2
                ;;
            --output-format)
                output_format="$2"
                shift 2
                ;;
            *)
                log_error "Unknown option: $1"
                echo ""
                show_usage
                exit 1
                ;;
        esac
    done

    # Validate required arguments
    if [ -z "$type" ]; then
        log_error "Missing required argument: --type"
        echo ""
        show_usage
        exit 1
    fi

    if [ -z "$title" ]; then
        log_error "Missing required argument: --title"
        echo ""
        show_usage
        exit 1
    fi

    # Validate inputs
    if ! validate_type "$type"; then
        exit 1
    fi

    if ! validate_priority "$priority"; then
        exit 1
    fi

    # Validate estimate for features
    if [ "$type" = "feature" ] && [ -n "$estimate" ]; then
        if ! validate_estimate "$estimate"; then
            exit 1
        fi
    fi

    # Set default description if not provided
    if [ -z "$description" ]; then
        description="[Add description]"
    fi

    # Set default estimate for features if not provided
    if [ "$type" = "feature" ] && [ -z "$estimate" ]; then
        estimate="M"
    fi

    # Get type prefix
    local prefix
    prefix=$(get_type_prefix "$type")

    # Get next ID
    local id_num
    id_num=$(get_next_id "$prefix")

    # Build full ID
    local id="$prefix-$id_num"

    # Get timestamp
    local timestamp
    timestamp=$(get_timestamp)

    # Format labels
    local formatted_labels
    formatted_labels=$(format_labels "$labels")

    # Generate content based on type
    local content=""
    case "$type" in
        bug)
            content=$(generate_bug_content "$id" "$title" "$priority" "$formatted_labels" "$description" "$timestamp")
            ;;
        feature)
            content=$(generate_feature_content "$id" "$title" "$priority" "$formatted_labels" "$estimate" "$description" "$timestamp")
            ;;
        task)
            content=$(generate_task_content "$id" "$title" "$priority" "$formatted_labels" "$description" "$timestamp")
            ;;
        chore)
            content=$(generate_chore_content "$id" "$title" "$priority" "$formatted_labels" "$description" "$timestamp")
            ;;
        spike)
            content=$(generate_spike_content "$id" "$title" "$priority" "$formatted_labels" "$description" "$timestamp")
            ;;
    esac

    # Create issues directory if it doesn't exist
    mkdir -p .devloop/issues

    # Write to file
    local file_path=".devloop/issues/$id.md"
    if ! echo "$content" > "$file_path"; then
        log_error "Failed to create issue file: $file_path"
        exit 2
    fi

    # Output based on format
    if [ "$output_format" = "json" ]; then
        output_json "$id" "$file_path" "$type" "$title"
    else
        # Markdown output (default)
        echo ""
        echo -e "${BOLD}## Issue Created ✓${RESET}"
        echo ""
        echo -e "${BOLD}ID${RESET}: $id"
        echo -e "${BOLD}Type${RESET}: $type"
        echo -e "${BOLD}Title${RESET}: $title"
        echo -e "${BOLD}Priority${RESET}: $priority"
        if [ "$type" = "feature" ]; then
            echo -e "${BOLD}Estimate${RESET}: $estimate"
        fi
        if [ -n "$labels" ]; then
            echo -e "${BOLD}Labels${RESET}: $labels"
        fi
        echo ""
        echo -e "${BOLD}File${RESET}: $file_path"
        echo ""
        log_info "Issue created successfully"
    fi

    exit 0
}

main "$@"
