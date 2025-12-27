#!/usr/bin/env bash
#
# show-plan-status.sh - Display comprehensive plan status without LLM
#
# Usage: show-plan-status.sh [OPTIONS]
#
# Renders plan progress, phase breakdown, and task listing in various formats.
# Reads from plan-state.json (preferred) or plan.md (fallback).
#
# Dependencies: jq (recommended)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN_FILE=".devloop/plan.md"
STATE_FILE=""
FORMAT="full"  # full, brief, phase, json
SHOW_TASKS=true
SHOW_COMPLETED=false
PHASE_NUM=""

# Colors
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
BLUE='\033[34m'
CYAN='\033[36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Status indicators
STATUS_COMPLETE="${GREEN}[x]${RESET}"
STATUS_PENDING="${RESET}[ ]${RESET}"
STATUS_IN_PROGRESS="${YELLOW}[~]${RESET}"
STATUS_BLOCKED="${RED}[!]${RESET}"
STATUS_SKIPPED="${DIM}[-]${RESET}"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --brief) FORMAT="brief"; SHOW_TASKS=false; shift ;;
        --full) FORMAT="full"; shift ;;
        --phase) FORMAT="phase"; PHASE_NUM="$2"; shift 2 ;;
        --json) FORMAT="json"; shift ;;
        --show-completed) SHOW_COMPLETED=true; shift ;;
        --no-tasks) SHOW_TASKS=false; shift ;;
        --plan) PLAN_FILE="$2"; shift 2 ;;
        --state) STATE_FILE="$2"; shift 2 ;;
        -h|--help)
            cat <<EOF
Usage: show-plan-status.sh [OPTIONS]

Display comprehensive plan status without LLM involvement.

Options:
  --brief           One-line status only
  --full            Full status with phases and tasks (default)
  --phase N         Show specific phase details
  --json            Output as JSON
  --show-completed  Include completed tasks in listing
  --no-tasks        Hide individual task listing
  --plan FILE       Specify plan file (default: .devloop/plan.md)
  --state FILE      Specify state file (default: auto-detect)
  -h, --help        Show this help

Examples:
  show-plan-status.sh                    # Full status
  show-plan-status.sh --brief            # One-liner for statusline
  show-plan-status.sh --phase 4          # Details for Phase 4
  show-plan-status.sh --json             # JSON for scripts
EOF
            exit 0
            ;;
        *) shift ;;
    esac
done

# Auto-detect state file
if [ -z "$STATE_FILE" ]; then
    STATE_FILE="$(dirname "$PLAN_FILE")/plan-state.json"
fi

# Check for jq
HAS_JQ=false
if command -v jq &>/dev/null; then
    HAS_JQ=true
fi

# ============================================
# Progress Bar Helper
# ============================================
progress_bar() {
    local done="$1"
    local total="$2"
    local width="${3:-20}"

    if [ "$total" -eq 0 ]; then
        printf '[%*s]' "$width" ""
        return
    fi

    local percentage=$((done * 100 / total))
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))

    printf '['
    for ((i=0; i<filled; i++)); do printf '█'; done
    for ((i=0; i<empty; i++)); do printf '░'; done
    printf ']'
}

# ============================================
# Status Emoji
# ============================================
status_emoji() {
    local percentage="$1"
    local done="$2"
    local total="$3"

    if [ "$done" -eq "$total" ] && [ "$total" -gt 0 ]; then
        echo "✅"
    elif [ "$percentage" -ge 75 ]; then
        echo "🟢"
    elif [ "$percentage" -ge 50 ]; then
        echo "🟡"
    elif [ "$percentage" -ge 25 ]; then
        echo "🟠"
    else
        echo "🔴"
    fi
}

# ============================================
# JSON Mode Output
# ============================================
output_json_from_state() {
    local state_file="$1"

    if [ "$HAS_JQ" = true ]; then
        # Add computed fields
        jq '{
            plan_name: .plan_name,
            status: .status,
            current_phase: .current_phase,
            progress: {
                done: .stats.done,
                total: .stats.total,
                percentage: .stats.percentage,
                completed: .stats.completed,
                pending: .stats.pending,
                in_progress: .stats.in_progress,
                blocked: .stats.blocked,
                skipped: .stats.skipped
            },
            phases: [.phases[] | {
                number: .number,
                name: .name,
                goal: .goal,
                status: .status,
                stats: .stats
            }],
            next_task: .next_task,
            last_sync: .last_sync
        }' "$state_file"
    else
        cat "$state_file"
    fi
}

# ============================================
# Brief Output (for statusline)
# ============================================
output_brief() {
    local plan_name="$1"
    local done="$2"
    local total="$3"
    local percentage="$4"
    local next_task="$5"

    if [ "$total" -eq 0 ]; then
        echo "No tasks"
    elif [ "$done" -eq "$total" ]; then
        echo "Complete ($total tasks)"
    else
        echo "$done/$total ($percentage%) | Next: $next_task"
    fi
}

# ============================================
# Full Output with Phases
# ============================================
output_full_from_state() {
    local state_file="$1"

    if [ ! -f "$state_file" ] || [ "$HAS_JQ" = false ]; then
        output_full_from_markdown
        return
    fi

    # Extract key data
    local plan_name=$(jq -r '.plan_name // "Unknown Plan"' "$state_file")
    local status=$(jq -r '.status // "unknown"' "$state_file")
    local current_phase=$(jq -r '.current_phase // 1' "$state_file")
    local done=$(jq -r '.stats.done // 0' "$state_file")
    local total=$(jq -r '.stats.total // 0' "$state_file")
    local percentage=$(jq -r '.stats.percentage // 0' "$state_file")
    local next_task=$(jq -r '.next_task // ""' "$state_file")
    local completed=$(jq -r '.stats.completed // 0' "$state_file")
    local pending=$(jq -r '.stats.pending // 0' "$state_file")
    local in_progress=$(jq -r '.stats.in_progress // 0' "$state_file")
    local blocked=$(jq -r '.stats.blocked // 0' "$state_file")

    # Header
    local emoji=$(status_emoji "$percentage" "$done" "$total")
    echo -e "${BOLD}## Plan Status $emoji${RESET}"
    echo ""
    echo -e "${BOLD}Plan:${RESET} $plan_name"
    echo -e "${BOLD}Status:${RESET} $status"
    echo -e "${BOLD}Current Phase:${RESET} $current_phase"
    echo ""

    # Progress
    echo -e "${BOLD}Progress:${RESET} $done/$total tasks ($percentage%)"
    echo -n "  "
    progress_bar "$done" "$total" 30
    echo ""
    echo ""

    # Task breakdown
    echo -e "${BOLD}Tasks:${RESET}"
    echo -e "  ${GREEN}Completed:${RESET}   $completed"
    echo -e "  ${RESET}Pending:${RESET}     $pending"
    if [ "$in_progress" -gt 0 ]; then
        echo -e "  ${YELLOW}In Progress:${RESET} $in_progress"
    fi
    if [ "$blocked" -gt 0 ]; then
        echo -e "  ${RED}Blocked:${RESET}     $blocked"
    fi
    echo ""

    # Phase breakdown
    echo -e "${BOLD}Phases:${RESET}"
    jq -r '.phases[] | "\(.number)|\(.name)|\(.status)|\(.stats.completed)|\(.stats.total)"' "$state_file" 2>/dev/null | \
    while IFS='|' read -r num name p_status p_done p_total; do
        local p_pct=0
        [ "$p_total" -gt 0 ] && p_pct=$((p_done * 100 / p_total))

        local status_marker=""
        case "$p_status" in
            complete) status_marker="${GREEN}✓${RESET}" ;;
            in_progress) status_marker="${YELLOW}→${RESET}" ;;
            *) status_marker="${DIM}○${RESET}" ;;
        esac

        # Use echo -e instead of printf to properly interpret color codes
        echo -e "  $status_marker ${BOLD}Phase $num${RESET}: $(printf '%-30s' "$name") $p_done/$p_total ($p_pct%)"
    done
    echo ""

    # Next task
    if [ -n "$next_task" ] && [ "$next_task" != "null" ]; then
        local next_desc=$(jq -r ".tasks[\"$next_task\"].description // \"\"" "$state_file" 2>/dev/null)
        echo -e "${BOLD}Next Task:${RESET} $next_task"
        if [ -n "$next_desc" ]; then
            echo -e "  $next_desc"
        fi

        # Show acceptance criteria
        local acceptance=$(jq -r ".tasks[\"$next_task\"].acceptance // \"\"" "$state_file" 2>/dev/null)
        if [ -n "$acceptance" ]; then
            echo -e "  ${DIM}Acceptance:${RESET} $acceptance"
        fi
    else
        echo -e "${GREEN}${BOLD}All tasks complete!${RESET}"
    fi

    # Show pending tasks if requested
    if [ "$SHOW_TASKS" = true ]; then
        local has_pending=$(jq -r '.tasks | to_entries[] | select(.value.status == "pending") | .key' "$state_file" 2>/dev/null | head -1)
        if [ -n "$has_pending" ]; then
            echo ""
            echo -e "${BOLD}Pending Tasks:${RESET}"
            jq -r '.tasks | to_entries[] | select(.value.status == "pending") | "\(.key)|\(.value.description)|\(.value.parallel_group // "")"' "$state_file" 2>/dev/null | \
            head -10 | while IFS='|' read -r tid desc pgroup; do
                local marker="[ ]"
                [ -n "$pgroup" ] && marker="[ ] [parallel:$pgroup]"
                echo -e "  $marker Task $tid: $desc"
            done

            local pending_count=$(jq -r '[.tasks | to_entries[] | select(.value.status == "pending")] | length' "$state_file" 2>/dev/null)
            if [ "$pending_count" -gt 10 ]; then
                echo -e "  ${DIM}... and $((pending_count - 10)) more${RESET}"
            fi
        fi
    fi
}

# ============================================
# Phase-specific Output
# ============================================
output_phase_from_state() {
    local state_file="$1"
    local phase_num="$2"

    if [ ! -f "$state_file" ] || [ "$HAS_JQ" = false ]; then
        echo "Phase details require JSON state file with jq" >&2
        exit 1
    fi

    # Get phase info
    local phase_info=$(jq -r ".phases[] | select(.number == $phase_num)" "$state_file" 2>/dev/null)
    if [ -z "$phase_info" ]; then
        echo "Phase $phase_num not found" >&2
        exit 1
    fi

    local name=$(echo "$phase_info" | jq -r '.name // ""')
    local goal=$(echo "$phase_info" | jq -r '.goal // ""')
    local p_status=$(echo "$phase_info" | jq -r '.status // "pending"')
    local p_done=$(echo "$phase_info" | jq -r '.stats.completed // 0')
    local p_total=$(echo "$phase_info" | jq -r '.stats.total // 0')
    local p_pct=0
    [ "$p_total" -gt 0 ] && p_pct=$((p_done * 100 / p_total))

    # Header
    local emoji=$(status_emoji "$p_pct" "$p_done" "$p_total")
    echo -e "${BOLD}### Phase $phase_num: $name $emoji${RESET}"
    echo ""

    if [ -n "$goal" ]; then
        echo -e "${BOLD}Goal:${RESET} $goal"
        echo ""
    fi

    echo -e "${BOLD}Status:${RESET} $p_status"
    echo -e "${BOLD}Progress:${RESET} $p_done/$p_total ($p_pct%)"
    echo -n "  "
    progress_bar "$p_done" "$p_total" 25
    echo ""
    echo ""

    # List tasks in this phase
    echo -e "${BOLD}Tasks:${RESET}"
    local task_ids=$(echo "$phase_info" | jq -r '.task_ids[]' 2>/dev/null)

    while IFS= read -r tid; do
        [ -z "$tid" ] && continue

        local t_status=$(jq -r ".tasks[\"$tid\"].status // \"pending\"" "$state_file" 2>/dev/null)
        local t_desc=$(jq -r ".tasks[\"$tid\"].description // \"\"" "$state_file" 2>/dev/null)
        local t_pgroup=$(jq -r ".tasks[\"$tid\"].parallel_group // \"\"" "$state_file" 2>/dev/null)

        local marker=""
        case "$t_status" in
            complete) marker="$STATUS_COMPLETE" ;;
            pending) marker="$STATUS_PENDING" ;;
            in_progress) marker="$STATUS_IN_PROGRESS" ;;
            blocked) marker="$STATUS_BLOCKED" ;;
            skipped) marker="$STATUS_SKIPPED" ;;
            *) marker="$STATUS_PENDING" ;;
        esac

        local extra=""
        [ -n "$t_pgroup" ] && [ "$t_pgroup" != "null" ] && extra=" ${DIM}[parallel:$t_pgroup]${RESET}"

        echo -e "  $marker Task $tid: $t_desc$extra"

        # Show acceptance for pending tasks
        if [ "$t_status" = "pending" ]; then
            local acceptance=$(jq -r ".tasks[\"$tid\"].acceptance // \"\"" "$state_file" 2>/dev/null)
            if [ -n "$acceptance" ] && [ "$acceptance" != "null" ]; then
                echo -e "     ${DIM}→ $acceptance${RESET}"
            fi
        fi
    done <<< "$task_ids"
}

# ============================================
# Markdown Fallback
# ============================================
output_full_from_markdown() {
    if [ ! -f "$PLAN_FILE" ]; then
        echo "Error: Plan file not found: $PLAN_FILE" >&2
        exit 2
    fi

    # Use calculate-progress.sh for basic stats
    if [ -x "$SCRIPT_DIR/calculate-progress.sh" ]; then
        "$SCRIPT_DIR/calculate-progress.sh" "$PLAN_FILE"
    else
        echo "Error: calculate-progress.sh not found" >&2
        exit 1
    fi
}

# ============================================
# Main Execution
# ============================================
main() {
    case "$FORMAT" in
        brief)
            if [ -f "$STATE_FILE" ] && [ "$HAS_JQ" = true ]; then
                local plan_name=$(jq -r '.plan_name // "Plan"' "$STATE_FILE")
                local done=$(jq -r '.stats.done // 0' "$STATE_FILE")
                local total=$(jq -r '.stats.total // 0' "$STATE_FILE")
                local pct=$(jq -r '.stats.percentage // 0' "$STATE_FILE")
                local next=$(jq -r '.next_task // ""' "$STATE_FILE")
                output_brief "$plan_name" "$done" "$total" "$pct" "$next"
            elif [ -x "$SCRIPT_DIR/format-plan-status.sh" ]; then
                "$SCRIPT_DIR/format-plan-status.sh" --brief --plan "$PLAN_FILE"
            else
                echo "Plan status unavailable"
            fi
            ;;
        json)
            if [ -f "$STATE_FILE" ]; then
                output_json_from_state "$STATE_FILE"
            else
                echo '{"error": "State file not found", "file": "'"$STATE_FILE"'"}'
                exit 1
            fi
            ;;
        phase)
            if [ -z "$PHASE_NUM" ]; then
                echo "Error: --phase requires a phase number" >&2
                exit 1
            fi
            output_phase_from_state "$STATE_FILE" "$PHASE_NUM"
            ;;
        full|*)
            output_full_from_state "$STATE_FILE"
            ;;
    esac
}

main
