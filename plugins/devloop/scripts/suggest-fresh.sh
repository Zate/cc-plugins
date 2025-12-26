#!/usr/bin/env bash
#
# suggest-fresh.sh - Detect when context is heavy and suggest fresh start
#
# Usage: suggest-fresh.sh [--json] [--plan FILE] [--threshold LEVEL]
#
# Analyzes current session context and recommends fresh start based on:
# - Tasks completed in session
# - Plan file size
# - Errors encountered
# - Time since last fresh start
#
# Thresholds:
#   --threshold low     - Suggest after 3 tasks (conservative)
#   --threshold normal  - Suggest after 5 tasks (default)
#   --threshold high    - Suggest after 10 tasks (aggressive)
#
# Exit codes:
#   0 - Fresh start recommended
#   1 - Continue working (no fresh start needed)
#   2 - Error (could not analyze)

set -euo pipefail

# Defaults
PLAN_FILE=".devloop/plan.md"
STATE_FILE=".devloop/next-action.json"
OUTPUT_FORMAT="text"
THRESHOLD="normal"

# Threshold values
declare -A TASK_THRESHOLDS=(
    ["low"]=3
    ["normal"]=5
    ["high"]=10
)

declare -A PLAN_SIZE_THRESHOLDS=(
    ["low"]=300
    ["normal"]=500
    ["high"]=800
)

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --json)
            OUTPUT_FORMAT="json"
            shift
            ;;
        --plan)
            PLAN_FILE="$2"
            shift 2
            ;;
        --threshold)
            THRESHOLD="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Validate threshold
if [[ -z "${TASK_THRESHOLDS[$THRESHOLD]:-}" ]]; then
    echo "Error: Invalid threshold '$THRESHOLD'. Use: low, normal, high" >&2
    exit 2
fi

# Initialize metrics
tasks_completed=0
plan_size=0
has_in_progress=false
last_fresh_timestamp=""
recommend_fresh=false
reasons=()
confidence="low"

# Check plan file exists
if [[ ! -f "$PLAN_FILE" ]]; then
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        echo '{"recommend":false,"reason":"No plan file found","confidence":"none"}'
    fi
    exit 1
fi

# Count completed tasks (simple heuristic - actual tracking would be in session state)
tasks_completed=$(grep -c '^\s*-\s*\[x\]' "$PLAN_FILE" 2>/dev/null || echo "0")
in_progress=$(grep -c '^\s*-\s*\[~\]' "$PLAN_FILE" 2>/dev/null || echo "0")
blocked=$(grep -c '^\s*-\s*\[!\]' "$PLAN_FILE" 2>/dev/null || echo "0")

# Get plan file size in lines
plan_size=$(wc -l < "$PLAN_FILE" 2>/dev/null || echo "0")

# Check for existing fresh start state
if [[ -f "$STATE_FILE" ]]; then
    last_fresh_timestamp=$(jq -r '.timestamp // empty' "$STATE_FILE" 2>/dev/null || echo "")
fi

# Check if any tasks are in progress
if [[ "$in_progress" -gt 0 ]]; then
    has_in_progress=true
fi

# Apply threshold logic
task_threshold="${TASK_THRESHOLDS[$THRESHOLD]}"
size_threshold="${PLAN_SIZE_THRESHOLDS[$THRESHOLD]}"

# Reason 1: Many tasks completed
if [[ "$tasks_completed" -ge "$task_threshold" ]]; then
    recommend_fresh=true
    reasons+=("Completed $tasks_completed tasks (threshold: $task_threshold)")
    confidence="medium"
fi

# Reason 2: Large plan file
if [[ "$plan_size" -ge "$size_threshold" ]]; then
    recommend_fresh=true
    reasons+=("Plan file is $plan_size lines (threshold: $size_threshold)")
    if [[ "$confidence" == "medium" ]]; then
        confidence="high"
    else
        confidence="medium"
    fi
fi

# Reason 3: Multiple blocked tasks (suggests complexity)
if [[ "$blocked" -ge 2 ]]; then
    recommend_fresh=true
    reasons+=("$blocked blocked tasks detected")
    confidence="medium"
fi

# Reason 4: Stale fresh start state exists
if [[ -n "$last_fresh_timestamp" ]]; then
    # Calculate age in hours (if jq/date available)
    if command -v date &>/dev/null; then
        now_epoch=$(date +%s)
        fresh_epoch=$(date -d "$last_fresh_timestamp" +%s 2>/dev/null || echo "0")
        if [[ "$fresh_epoch" -gt 0 ]]; then
            age_hours=$(( (now_epoch - fresh_epoch) / 3600 ))
            if [[ "$age_hours" -gt 2 ]]; then
                recommend_fresh=true
                reasons+=("Fresh start state is ${age_hours}h old - may be stale")
            fi
        fi
    fi
fi

# Generate recommendation message
if [[ "$recommend_fresh" == true ]]; then
    recommendation="Consider running /devloop:fresh followed by /clear"
else
    recommendation="Context appears healthy - continue working"
fi

# Output
if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    reasons_json=$(printf '%s\n' "${reasons[@]:-}" | jq -R . | jq -s .)
    cat <<EOF
{
  "recommend": $recommend_fresh,
  "confidence": "$confidence",
  "reasons": $reasons_json,
  "metrics": {
    "tasks_completed": $tasks_completed,
    "plan_size_lines": $plan_size,
    "blocked_tasks": $blocked,
    "in_progress": $has_in_progress
  },
  "threshold": "$THRESHOLD",
  "recommendation": "$recommendation"
}
EOF
else
    echo "=== Context Health Check ==="
    echo ""
    echo "Metrics:"
    echo "  Tasks completed: $tasks_completed"
    echo "  Plan size: $plan_size lines"
    echo "  Blocked tasks: $blocked"
    echo "  In progress: $has_in_progress"
    echo ""

    if [[ "$recommend_fresh" == true ]]; then
        echo "Recommendation: FRESH START SUGGESTED"
        echo "Confidence: $confidence"
        echo ""
        echo "Reasons:"
        for reason in "${reasons[@]:-}"; do
            echo "  - $reason"
        done
        echo ""
        echo "Next steps:"
        echo "  1. Run /devloop:fresh to save state"
        echo "  2. Run /clear to reset context"
        echo "  3. Run /devloop:continue to resume"
    else
        echo "Recommendation: Continue working"
        echo "Context appears healthy."
    fi
fi

# Exit code
if [[ "$recommend_fresh" == true ]]; then
    exit 0
else
    exit 1
fi
