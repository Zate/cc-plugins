#!/usr/bin/env bash
#
# validate-plan-state.sh - Validate plan-state.json against schema
#
# Usage: validate-plan-state.sh [state-file] [--fix] [--quiet]
#
# Validates .devloop/plan-state.json against the schema.
# Can detect sync drift between plan.md and plan-state.json.
#
# Dependencies: jq (required)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="${1:-.devloop/plan-state.json}"
FIX_MODE=false
QUIET=false
SCHEMA_FILE="$SCRIPT_DIR/../schemas/plan-state.schema.json"

# Colors for output
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
BLUE='\033[34m'
RESET='\033[0m'

# Track errors and warnings
ERRORS=()
WARNINGS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --fix) FIX_MODE=true; shift ;;
        --quiet|-q) QUIET=true; shift ;;
        -h|--help)
            echo "Usage: validate-plan-state.sh [state-file] [--fix] [--quiet]"
            echo ""
            echo "Validate plan-state.json structure and sync status"
            echo ""
            echo "Options:"
            echo "  --fix     Re-sync from plan.md if validation fails"
            echo "  --quiet   Only output errors, suppress info"
            echo ""
            echo "Default state file: .devloop/plan-state.json"
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [ -z "${STATE_FILE_SET:-}" ]; then
                STATE_FILE="$1"
                STATE_FILE_SET=true
            fi
            shift
            ;;
    esac
done

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required for JSON validation${RESET}" >&2
    echo "Install with: apt-get install jq (Debian/Ubuntu) or brew install jq (macOS)"
    exit 1
fi

# Helper functions
error() {
    ERRORS+=("$1")
}

warn() {
    WARNINGS+=("$1")
}

info() {
    [ "$QUIET" = false ] && echo -e "${BLUE}$1${RESET}"
}

# ============================================
# 1. File Existence Check
# ============================================
validate_file_exists() {
    if [ ! -f "$STATE_FILE" ]; then
        error "State file not found: $STATE_FILE"
        if [ "$FIX_MODE" = true ]; then
            info "Fix mode: Will create state file from plan.md"
            return 1  # Signal that fix is needed
        fi
        return 1
    fi
    return 0
}

# ============================================
# 2. JSON Syntax Validation
# ============================================
validate_json_syntax() {
    if ! jq . "$STATE_FILE" > /dev/null 2>&1; then
        error "Invalid JSON syntax in $STATE_FILE"
        return 1
    fi
    return 0
}

# ============================================
# 3. Required Fields Validation
# ============================================
validate_required_fields() {
    local required=("schema_version" "plan_file" "last_sync" "stats")

    for field in "${required[@]}"; do
        if [ "$(jq "has(\"$field\")" "$STATE_FILE")" != "true" ]; then
            error "Missing required field: $field"
        fi
    done

    # Validate stats subfields
    local stats_required=("total" "completed" "pending" "percentage")
    for field in "${stats_required[@]}"; do
        if [ "$(jq ".stats | has(\"$field\")" "$STATE_FILE")" != "true" ]; then
            error "Missing required stats field: stats.$field"
        fi
    done
}

# ============================================
# 4. Schema Version Check
# ============================================
validate_schema_version() {
    local version=$(jq -r '.schema_version // ""' "$STATE_FILE")

    if [ -z "$version" ]; then
        error "schema_version is empty"
        return
    fi

    if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "schema_version '$version' is not valid semver (expected: X.Y.Z)"
    fi

    # Check if version is supported
    local major=$(echo "$version" | cut -d. -f1)
    if [ "$major" != "1" ]; then
        warn "schema_version $version may not be compatible (expected: 1.x.x)"
    fi
}

# ============================================
# 5. Plan File Reference Check
# ============================================
validate_plan_file_ref() {
    local plan_file=$(jq -r '.plan_file // ""' "$STATE_FILE")

    if [ -z "$plan_file" ]; then
        error "plan_file reference is empty"
        return
    fi

    if [ ! -f "$plan_file" ]; then
        error "Referenced plan file does not exist: $plan_file"
    fi
}

# ============================================
# 6. Stats Consistency Check
# ============================================
validate_stats_consistency() {
    local total=$(jq -r '.stats.total // 0' "$STATE_FILE")
    local completed=$(jq -r '.stats.completed // 0' "$STATE_FILE")
    local pending=$(jq -r '.stats.pending // 0' "$STATE_FILE")
    local in_progress=$(jq -r '.stats.in_progress // 0' "$STATE_FILE")
    local blocked=$(jq -r '.stats.blocked // 0' "$STATE_FILE")
    local skipped=$(jq -r '.stats.skipped // 0' "$STATE_FILE")
    local done=$(jq -r '.stats.done // 0' "$STATE_FILE")
    local percentage=$(jq -r '.stats.percentage // 0' "$STATE_FILE")

    # Check that total = sum of status counts
    local sum=$((completed + pending + in_progress + blocked + skipped))
    if [ "$sum" -ne "$total" ]; then
        error "Stats total ($total) does not match sum of statuses ($sum)"
    fi

    # Check that done = completed + skipped
    local expected_done=$((completed + skipped))
    if [ "$done" -ne "$expected_done" ]; then
        error "Stats done ($done) should equal completed + skipped ($expected_done)"
    fi

    # Check percentage calculation
    if [ "$total" -gt 0 ]; then
        local expected_pct=$((done * 100 / total))
        if [ "$percentage" -ne "$expected_pct" ]; then
            warn "Stats percentage ($percentage) differs from calculated ($expected_pct)"
        fi
    fi
}

# ============================================
# 7. Task Status Validation
# ============================================
validate_task_statuses() {
    local valid_statuses=("pending" "in_progress" "complete" "blocked" "skipped")

    # Get all task statuses
    local statuses=$(jq -r '.tasks | to_entries[] | .value.status // "unknown"' "$STATE_FILE" 2>/dev/null)

    while IFS= read -r status; do
        [ -z "$status" ] && continue
        local found=false
        for valid in "${valid_statuses[@]}"; do
            if [ "$status" = "$valid" ]; then
                found=true
                break
            fi
        done
        if [ "$found" = false ]; then
            error "Invalid task status: '$status' (valid: ${valid_statuses[*]})"
        fi
    done <<< "$statuses"
}

# ============================================
# 8. Phase Consistency Check
# ============================================
validate_phases() {
    # Check that all task_ids in phases exist in tasks
    local phase_task_ids=$(jq -r '.phases[]?.task_ids[]?' "$STATE_FILE" 2>/dev/null)
    local task_ids=$(jq -r '.tasks | keys[]' "$STATE_FILE" 2>/dev/null)

    while IFS= read -r task_id; do
        [ -z "$task_id" ] && continue
        if ! echo "$task_ids" | grep -q "^${task_id}$"; then
            error "Phase references non-existent task: $task_id"
        fi
    done <<< "$phase_task_ids"

    # Check phase status consistency
    local phases_json=$(jq -c '.phases[]?' "$STATE_FILE" 2>/dev/null)
    while IFS= read -r phase; do
        [ -z "$phase" ] && continue
        local p_num=$(echo "$phase" | jq -r '.number')
        local p_status=$(echo "$phase" | jq -r '.status // "pending"')
        local p_total=$(echo "$phase" | jq -r '.stats.total // 0')
        local p_complete=$(echo "$phase" | jq -r '.stats.completed // 0')

        if [ "$p_status" = "complete" ] && [ "$p_complete" -lt "$p_total" ]; then
            warn "Phase $p_num marked complete but only $p_complete/$p_total tasks done"
        fi
    done <<< "$phases_json"
}

# ============================================
# 9. Dependency Validation
# ============================================
validate_dependencies() {
    local task_ids=$(jq -r '.tasks | keys[]' "$STATE_FILE" 2>/dev/null)

    # Check each dependency reference exists
    local deps=$(jq -r '.dependencies | to_entries[] | "\(.key):\(.value[])"' "$STATE_FILE" 2>/dev/null)
    while IFS= read -r dep_line; do
        [ -z "$dep_line" ] && continue
        local task_id=$(echo "$dep_line" | cut -d: -f1)
        local dep_id=$(echo "$dep_line" | cut -d: -f2)

        if ! echo "$task_ids" | grep -q "^${dep_id}$"; then
            error "Task $task_id depends on non-existent task: $dep_id"
        fi
    done <<< "$deps"
}

# ============================================
# 10. Sync Freshness Check
# ============================================
validate_sync_freshness() {
    local last_sync=$(jq -r '.last_sync // ""' "$STATE_FILE")
    local plan_file=$(jq -r '.plan_file // ""' "$STATE_FILE")

    if [ -z "$last_sync" ] || [ ! -f "$plan_file" ]; then
        return
    fi

    # Get plan.md modification time
    local plan_mtime=""
    if [[ "$(uname)" == "Darwin" ]]; then
        plan_mtime=$(stat -f "%m" "$plan_file" 2>/dev/null || echo "0")
    else
        plan_mtime=$(stat -c "%Y" "$plan_file" 2>/dev/null || echo "0")
    fi

    # Parse last_sync timestamp
    local sync_epoch=0
    if command -v date &> /dev/null; then
        # Try Linux date format
        sync_epoch=$(date -d "$last_sync" +%s 2>/dev/null || echo "0")
        # Try macOS date format if Linux failed
        if [ "$sync_epoch" -eq 0 ]; then
            sync_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_sync" +%s 2>/dev/null || echo "0")
        fi
    fi

    if [ "$plan_mtime" -gt "$sync_epoch" ]; then
        warn "plan.md modified after last sync - state may be stale"
        if [ "$FIX_MODE" = true ]; then
            info "Fix mode: Will re-sync state file"
            return 1
        fi
    fi

    return 0
}

# ============================================
# Run Sync Fix
# ============================================
run_sync_fix() {
    local plan_file=$(jq -r '.plan_file // ".devloop/plan.md"' "$STATE_FILE" 2>/dev/null || echo ".devloop/plan.md")

    if [ ! -f "$plan_file" ]; then
        # Try default location
        if [ -f ".devloop/plan.md" ]; then
            plan_file=".devloop/plan.md"
        else
            echo -e "${RED}Cannot fix: No plan.md found${RESET}" >&2
            return 1
        fi
    fi

    local sync_script="$SCRIPT_DIR/sync-plan-state.sh"
    if [ ! -x "$sync_script" ]; then
        echo -e "${RED}Cannot fix: sync-plan-state.sh not found or not executable${RESET}" >&2
        return 1
    fi

    echo -e "${BLUE}Running sync-plan-state.sh to fix...${RESET}"
    "$sync_script" "$plan_file" --output "$STATE_FILE"
    return $?
}

# ============================================
# Main Validation
# ============================================
main() {
    local need_fix=false

    # Check if file exists
    if ! validate_file_exists; then
        if [ "$FIX_MODE" = true ]; then
            run_sync_fix
            exit $?
        fi
        echo -e "${RED}Validation failed: State file not found${RESET}"
        exit 1
    fi

    # Validate JSON syntax
    if ! validate_json_syntax; then
        if [ "$FIX_MODE" = true ]; then
            run_sync_fix
            exit $?
        fi
        echo -e "${RED}Validation failed: Invalid JSON${RESET}"
        exit 1
    fi

    # Run all validations
    validate_required_fields
    validate_schema_version
    validate_plan_file_ref
    validate_stats_consistency
    validate_task_statuses
    validate_phases
    validate_dependencies

    # Check sync freshness (may trigger fix)
    if ! validate_sync_freshness; then
        need_fix=true
    fi

    # ============================================
    # Report Results
    # ============================================
    if [ "$QUIET" = false ]; then
        echo "Validating: $STATE_FILE"
        echo "--------------------------------------"
    fi

    if [ ${#WARNINGS[@]} -gt 0 ]; then
        echo -e "${YELLOW}Warnings (${#WARNINGS[@]}):${RESET}"
        for w in "${WARNINGS[@]}"; do
            echo -e "  ${YELLOW}!${RESET} $w"
        done
        [ "$QUIET" = false ] && echo ""
    fi

    if [ ${#ERRORS[@]} -gt 0 ]; then
        echo -e "${RED}Errors (${#ERRORS[@]}):${RESET}"
        for e in "${ERRORS[@]}"; do
            echo -e "  ${RED}x${RESET} $e"
        done
        echo ""

        if [ "$FIX_MODE" = true ]; then
            run_sync_fix
            exit $?
        fi

        echo -e "${RED}Validation failed${RESET}"
        exit 1
    fi

    # Handle fix for stale sync
    if [ "$need_fix" = true ] && [ "$FIX_MODE" = true ]; then
        run_sync_fix
        exit $?
    fi

    [ "$QUIET" = false ] && echo -e "${GREEN}Validation passed${RESET}"
    exit 0
}

main
