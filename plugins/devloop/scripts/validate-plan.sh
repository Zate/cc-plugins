#!/bin/bash
# validate-plan.sh - Centralized plan validation for devloop
#
# Validates .devloop/plan.md against format rules:
# - YAML frontmatter structure
# - Section headers
# - Task markers ([ ], [x], [~], [-], [!])
# - Dependency references ([depends:X.Y])
# - Parallelism markers ([parallel:A])
#
# Usage: validate-plan.sh [plan-file]
# Returns: 0 on success, 1 on validation failure
#
# Examples:
#   validate-plan.sh                    # Validates .devloop/plan.md
#   validate-plan.sh path/to/plan.md    # Validates specific file

set -uo pipefail
# Note: Not using -e because validation functions need to continue on errors

# Colors for output
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
RESET='\033[0m'

# Default plan file
PLAN_FILE="${1:-.devloop/plan.md}"

# Track errors and warnings
ERRORS=()
WARNINGS=()

# Helper functions
error() {
    ERRORS+=("$1")
}

warn() {
    WARNINGS+=("$1")
}

# Check if plan file exists
if [ ! -f "$PLAN_FILE" ]; then
    echo -e "${RED}Error: Plan file not found: $PLAN_FILE${RESET}" >&2
    exit 1
fi

# Read plan content
PLAN_CONTENT=$(cat "$PLAN_FILE")
LINE_COUNT=$(wc -l < "$PLAN_FILE" | tr -d ' ')

# ============================================
# 1. YAML Frontmatter Validation
# ============================================
validate_frontmatter() {
    # Check for opening ---
    FIRST_LINE=$(head -1 "$PLAN_FILE")
    if [ "$FIRST_LINE" != "---" ]; then
        # Frontmatter is optional, but if present must be valid
        # Check if file starts with # (markdown heading) - that's fine
        if [[ "$FIRST_LINE" =~ ^# ]]; then
            return 0
        fi
        warn "Line 1: No YAML frontmatter found (optional but recommended)"
        return 0
    fi

    # Find closing ---
    CLOSING_LINE=$(grep -n "^---$" "$PLAN_FILE" | sed -n '2p' | cut -d: -f1)
    if [ -z "$CLOSING_LINE" ]; then
        error "YAML frontmatter opened but never closed (missing ---)"
        return 1
    fi

    # Validate frontmatter content between lines
    FRONTMATTER=$(sed -n "2,$((CLOSING_LINE - 1))p" "$PLAN_FILE")

    # Check for required fields in frontmatter (if present)
    if ! echo "$FRONTMATTER" | grep -qE "^(name|title|description|status):"; then
        warn "Frontmatter exists but lacks common fields (name, title, description, status)"
    fi
}

# ============================================
# 2. Section Header Validation
# ============================================
validate_sections() {
    # Check for essential sections
    local required_sections=("Tasks" "Progress Log")
    local recommended_sections=("Overview" "Architecture")

    for section in "${required_sections[@]}"; do
        if ! grep -qE "^##?\s+${section}" "$PLAN_FILE"; then
            error "Missing required section: ## $section"
        fi
    done

    for section in "${recommended_sections[@]}"; do
        if ! grep -qE "^##?\s+${section}" "$PLAN_FILE"; then
            warn "Missing recommended section: ## $section"
        fi
    done

    # Check for plan title (# Devloop Plan: ...)
    if ! grep -qE "^#\s+(Devloop Plan:|Plan:)" "$PLAN_FILE"; then
        warn "Missing plan title (expected: # Devloop Plan: [Name])"
    fi
}

# ============================================
# 3. Task Marker Validation
# ============================================
validate_task_markers() {
    # Valid markers: [ ], [x], [~], [-], [!]
    local line_num=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Check for task lines (start with - [ or * [)
        if [[ "$line" =~ ^[[:space:]]*[-*][[:space:]]*\[ ]]; then
            # Extract the marker content
            marker=$(echo "$line" | grep -oE '\[[^]]*\]' | head -1) || marker=""

            # Valid markers
            case "$marker" in
                "[ ]"|"[x]"|"[~]"|"[-]"|"[!]"|"")
                    # Valid marker or empty (grep failed)
                    ;;
                *)
                    # Check if it's a checkbox-like pattern
                    if [[ "$marker" =~ ^\[.\]$ ]]; then
                        error "Line $line_num: Invalid task marker '$marker' (valid: [ ], [x], [~], [-], [!])"
                    fi
                    ;;
            esac
        fi
    done < "$PLAN_FILE"
}

# ============================================
# 4. Dependency Reference Validation
# ============================================
validate_dependencies() {
    # Extract all task IDs (Task X.Y patterns)
    local task_ids=()
    while IFS= read -r line; do
        if [[ "$line" =~ Task[[:space:]]+([0-9]+\.[0-9]+) ]]; then
            task_ids+=("${BASH_REMATCH[1]}")
        fi
    done < "$PLAN_FILE"

    # Check dependency references - only on actual task lines (start with - [ ])
    local line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Only check task lines for real dependency markers
        # Task lines start with: - [ ] Task or - [x] Task etc
        if ! [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\[.\][[:space:]]*Task ]]; then
            continue
        fi

        # Look for [depends:X.Y] or [depends:X.Y,X.Z] on task lines
        if [[ "$line" =~ \[depends:([^\]]+)\] ]]; then
            deps="${BASH_REMATCH[1]}"

            # Skip example/placeholder patterns like X.Y
            if [[ "$deps" =~ ^[A-Z]\.[A-Z] ]]; then
                continue
            fi

            # Split by comma and validate each
            IFS=',' read -ra dep_array <<< "$deps"
            for dep in "${dep_array[@]}"; do
                dep=$(echo "$dep" | tr -d ' ')

                # Check if this task ID exists
                local found=false
                for tid in "${task_ids[@]}"; do
                    if [ "$tid" = "$dep" ]; then
                        found=true
                        break
                    fi
                done

                if [ "$found" = false ]; then
                    error "Line $line_num: Dependency reference '$dep' not found in plan"
                fi
            done
        fi
    done < "$PLAN_FILE"
}

# ============================================
# 5. Parallelism Marker Validation
# ============================================
validate_parallelism() {
    # Extract all parallel group markers
    local groups=()
    local line_num=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Look for [parallel:X]
        if [[ "$line" =~ \[parallel:([A-Za-z0-9]+)\] ]]; then
            group="${BASH_REMATCH[1]}"
            groups+=("$group")
        fi

        # Check for conflicting markers
        if [[ "$line" =~ \[parallel: ]] && [[ "$line" =~ \[sequential\] ]]; then
            error "Line $line_num: Task has both [parallel:] and [sequential] markers"
        fi
    done < "$PLAN_FILE"

    # Check for lonely parallel groups (only one task in group)
    declare -A group_counts
    for g in "${groups[@]}"; do
        if [ -z "${group_counts[$g]:-}" ]; then
            group_counts[$g]=1
        else
            group_counts[$g]=$((group_counts[$g] + 1))
        fi
    done

    for g in "${!group_counts[@]}"; do
        if [ "${group_counts[$g]}" -eq 1 ]; then
            warn "Parallel group '$g' has only 1 task (parallelism requires 2+ tasks)"
        fi
    done
}

# ============================================
# 6. Progress Log Format Validation
# ============================================
validate_progress_log() {
    # Find Progress Log section
    local in_progress_log=false
    local line_num=0
    local log_entries=0

    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Detect Progress Log section
        if [[ "$line" =~ ^##[[:space:]]+Progress[[:space:]]+Log ]]; then
            in_progress_log=true
            continue
        fi

        # Detect next section (exit Progress Log)
        if [ "$in_progress_log" = true ] && [[ "$line" =~ ^## ]]; then
            in_progress_log=false
            continue
        fi

        # Validate log entries
        if [ "$in_progress_log" = true ] && [[ "$line" =~ ^- ]]; then
            log_entries=$((log_entries + 1))

            # Check for date format (YYYY-MM-DD)
            if ! [[ "$line" =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
                warn "Line $line_num: Progress Log entry missing date (expected YYYY-MM-DD format)"
            fi
        fi
    done < "$PLAN_FILE"

    if [ "$log_entries" -eq 0 ]; then
        warn "Progress Log section has no entries"
    fi
}

# ============================================
# Run All Validations
# ============================================
validate_frontmatter
validate_sections
validate_task_markers
validate_dependencies
validate_parallelism
validate_progress_log

# ============================================
# Report Results
# ============================================
echo "Validating: $PLAN_FILE"
echo "─────────────────────────────────────"

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo -e "${YELLOW}Warnings (${#WARNINGS[@]}):${RESET}"
    for w in "${WARNINGS[@]}"; do
        echo -e "  ${YELLOW}⚠${RESET} $w"
    done
    echo ""
fi

if [ ${#ERRORS[@]} -gt 0 ]; then
    echo -e "${RED}Errors (${#ERRORS[@]}):${RESET}"
    for e in "${ERRORS[@]}"; do
        echo -e "  ${RED}✗${RESET} $e"
    done
    echo ""
    echo -e "${RED}Validation failed${RESET}"
    exit 1
fi

echo -e "${GREEN}✓ Plan validation passed${RESET}"
exit 0
