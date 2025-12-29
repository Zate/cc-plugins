#!/usr/bin/env bash
#
# detect-workflow-state.sh - Comprehensive workflow state detection
#
# Usage: detect-workflow-state.sh [--json] [--verbose]
#
# Detects all relevant workflow state and outputs a structured summary.
# Used by the workflow-router skill for intelligent routing decisions.
#
# Exit codes:
#   0 - Success (state detected)
#   1 - Error (detection failed)

set -euo pipefail

# Script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find project root
find_project_root() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.devloop" ] || [ -d "$dir/.git" ]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    echo "$PWD"
    return 1
}

PROJECT_ROOT=$(find_project_root)
cd "$PROJECT_ROOT" || exit 1

# Parse arguments
OUTPUT_JSON=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --json) OUTPUT_JSON=true; shift ;;
        --verbose) VERBOSE=true; shift ;;
        -h|--help)
            echo "Usage: detect-workflow-state.sh [--json] [--verbose]"
            echo ""
            echo "Detects workflow state for routing decisions."
            echo ""
            echo "Options:"
            echo "  --json     Output as JSON"
            echo "  --verbose  Include detailed info"
            exit 0
            ;;
        *) shift ;;
    esac
done

# Detection functions

detect_fresh_start() {
    local state_file=".devloop/next-action.json"

    if [ ! -f "$state_file" ]; then
        echo "none"
        return
    fi

    # Parse timestamp and validate
    local timestamp=""
    local plan=""
    local next_task=""

    if command -v jq &> /dev/null; then
        timestamp=$(jq -r '.timestamp // ""' "$state_file" 2>/dev/null || echo "")
        plan=$(jq -r '.plan // ""' "$state_file" 2>/dev/null || echo "")
        next_task=$(jq -r '.next_pending // ""' "$state_file" 2>/dev/null || echo "")
    else
        timestamp=$(grep -o '"timestamp"[[:space:]]*:[[:space:]]*"[^"]*"' "$state_file" 2>/dev/null | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
    fi

    if [ -z "$timestamp" ]; then
        echo "invalid"
        return
    fi

    # Calculate age in days
    local age_days=0
    local state_epoch=0
    local now_epoch=$(date +%s)

    # Try Linux date format
    state_epoch=$(date -d "$timestamp" +%s 2>/dev/null || echo "0")

    # Try macOS date format
    if [ "$state_epoch" -eq 0 ]; then
        state_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$timestamp" +%s 2>/dev/null || echo "0")
    fi

    if [ "$state_epoch" -gt 0 ]; then
        age_days=$(( (now_epoch - state_epoch) / 86400 ))
    fi

    if [ "$age_days" -gt 7 ]; then
        echo "stale:$age_days:$plan:$next_task"
    else
        echo "valid:$age_days:$plan:$next_task"
    fi
}

detect_active_plan() {
    local plan_file=""

    # Check standard locations
    if [ -f ".devloop/plan.md" ]; then
        plan_file=".devloop/plan.md"
    elif [ -f ".claude/devloop-plan.md" ]; then
        plan_file=".claude/devloop-plan.md"
    fi

    if [ -z "$plan_file" ]; then
        echo "none||||"
        return
    fi

    # Extract info - use awk to avoid word splitting issues
    local plan_name
    plan_name=$(grep -m1 "^# " "$plan_file" 2>/dev/null | sed 's/^# //' | tr -d '\n' | head -c 100 || echo "Unknown")
    # Remove colons from plan name to avoid field splitting issues
    plan_name=$(echo "$plan_name" | tr ':' '-')

    # Use { grep || true; } to prevent exit code 1 from triggering fallback
    # grep -c returns 0 count with exit 1 when no matches, which would cause || echo "0" to also run
    local total
    total=$({ grep -cE '^\s*-\s*\[' "$plan_file" 2>/dev/null || true; } | tr -d '\n')
    local completed
    completed=$({ grep -cE '^\s*-\s*\[[xX]\]' "$plan_file" 2>/dev/null || true; } | tr -d '\n')
    local pending
    pending=$({ grep -cE '^\s*-\s*\[\s\]' "$plan_file" 2>/dev/null || true; } | tr -d '\n')
    local blocked
    blocked=$({ grep -cE '^\s*-\s*\[!\]' "$plan_file" 2>/dev/null || true; } | tr -d '\n')

    # Ensure numeric
    total=${total:-0}
    completed=${completed:-0}
    pending=${pending:-0}
    blocked=${blocked:-0}

    # Determine status
    local status="active"
    if [ "$pending" -eq 0 ] && [ "$total" -gt 0 ]; then
        if [ "$blocked" -gt 0 ]; then
            status="blocked"
        else
            status="complete"
        fi
    fi

    echo "${status}|${completed}|${total}|${plan_name}|${plan_file}"
}

detect_open_issues() {
    local issues_dir=""
    local count=0
    local priority_high=0

    if [ -d ".devloop/issues" ]; then
        issues_dir=".devloop/issues"
    elif [ -d ".claude/issues" ]; then
        issues_dir=".claude/issues"
    fi

    if [ -n "$issues_dir" ]; then
        count=$(grep -l "status: open" "$issues_dir"/*.md 2>/dev/null | wc -l | tr -d ' ' || echo "0")
        priority_high=$(grep -l "priority: high" "$issues_dir"/*.md 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    fi

    echo "$count:$priority_high"
}

detect_uncommitted() {
    if [ ! -d ".git" ]; then
        echo "not_git"
        return
    fi

    local staged=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    local modified=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    local untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

    echo "$staged:$modified:$untracked"
}

detect_recent_spike() {
    local spikes_dir=".devloop/spikes"
    local recent_spike=""
    local spike_age=""

    if [ -d "$spikes_dir" ]; then
        # Find most recent spike
        local newest=$(ls -t "$spikes_dir"/*.md 2>/dev/null | head -1)

        if [ -n "$newest" ] && [ -f "$newest" ]; then
            # Get modification time
            local mod_time
            if stat --version 2>/dev/null | grep -q GNU; then
                mod_time=$(stat -c %Y "$newest")
            else
                mod_time=$(stat -f %m "$newest")
            fi

            local now=$(date +%s)
            local age_hours=$(( (now - mod_time) / 3600 ))

            if [ "$age_hours" -lt 24 ]; then
                local topic=$(basename "$newest" .md)
                recent_spike="$topic"
                spike_age="${age_hours}h"
            fi
        fi
    fi

    if [ -n "$recent_spike" ]; then
        echo "$recent_spike:$spike_age"
    else
        echo "none"
    fi
}

detect_context_usage() {
    # Check if session tracker has context info
    local session_file=".devloop/.current-session.json"
    local context_pct=0

    if [ -f "$session_file" ] && command -v jq &> /dev/null; then
        # This would come from statusline input, not session file
        # For now, return 0 (unknown)
        context_pct=0
    fi

    echo "$context_pct"
}

# Determine priority situation
determine_situation() {
    local fresh_start="$1"
    local active_plan="$2"
    local open_issues="$3"
    local uncommitted="$4"
    local recent_spike="$5"

    # Priority order based on urgency

    # 1. Valid fresh start = highest priority
    if [[ "$fresh_start" == valid:* ]]; then
        echo "fresh_start_resume"
        return
    fi

    # 2. Stale fresh start = need cleanup
    if [[ "$fresh_start" == stale:* ]]; then
        echo "stale_fresh_start"
        return
    fi

    # 3. Active plan with pending tasks (uses | delimiter)
    if [[ "$active_plan" == active\|* ]]; then
        echo "active_plan"
        return
    fi

    # 4. Complete plan
    if [[ "$active_plan" == complete\|* ]]; then
        echo "complete_plan"
        return
    fi

    # 5. Blocked plan
    if [[ "$active_plan" == blocked\|* ]]; then
        echo "blocked_plan"
        return
    fi

    # 6. Uncommitted work
    if [[ "$uncommitted" != "not_git" && "$uncommitted" != "0:0:0" ]]; then
        echo "uncommitted_work"
        return
    fi

    # 7. Open high-priority issues
    local issue_count=$(echo "$open_issues" | cut -d: -f1)
    local high_priority=$(echo "$open_issues" | cut -d: -f2)
    if [ "$high_priority" -gt 0 ]; then
        echo "high_priority_issues"
        return
    fi

    # 8. Any open issues
    if [ "$issue_count" -gt 0 ]; then
        echo "open_issues"
        return
    fi

    # 9. Recent spike
    if [[ "$recent_spike" != "none" ]]; then
        echo "recent_spike"
        return
    fi

    # 10. Clean slate
    echo "clean_slate"
}

# Main execution
FRESH_START=$(detect_fresh_start)
ACTIVE_PLAN=$(detect_active_plan)
OPEN_ISSUES=$(detect_open_issues)
UNCOMMITTED=$(detect_uncommitted)
RECENT_SPIKE=$(detect_recent_spike)
CONTEXT_PCT=$(detect_context_usage)

SITUATION=$(determine_situation "$FRESH_START" "$ACTIVE_PLAN" "$OPEN_ISSUES" "$UNCOMMITTED" "$RECENT_SPIKE")

# Output
if [ "$OUTPUT_JSON" = true ]; then
    # Parse components for JSON output - use tr to clean newlines

    # Fresh start (uses : delimiter)
    fs_status=$(echo "$FRESH_START" | cut -d: -f1 | tr -d '\n\r')
    fs_age=$(echo "$FRESH_START" | cut -d: -f2 | tr -d '\n\r')
    fs_plan=$(echo "$FRESH_START" | cut -d: -f3 | tr -d '\n\r')
    fs_next=$(echo "$FRESH_START" | cut -d: -f4 | tr -d '\n\r')

    # Active plan (uses | delimiter to avoid issues with colons in names)
    plan_status=$(echo "$ACTIVE_PLAN" | cut -d'|' -f1 | tr -d '\n\r')
    plan_completed=$(echo "$ACTIVE_PLAN" | cut -d'|' -f2 | tr -d '\n\r')
    plan_total=$(echo "$ACTIVE_PLAN" | cut -d'|' -f3 | tr -d '\n\r')
    plan_name=$(echo "$ACTIVE_PLAN" | cut -d'|' -f4 | tr -d '\n\r')
    plan_file=$(echo "$ACTIVE_PLAN" | cut -d'|' -f5 | tr -d '\n\r')

    # Issues
    issue_count=$(echo "$OPEN_ISSUES" | cut -d: -f1 | tr -d '\n\r')
    issue_high=$(echo "$OPEN_ISSUES" | cut -d: -f2 | tr -d '\n\r')

    # Uncommitted
    staged=$(echo "$UNCOMMITTED" | cut -d: -f1 | tr -d '\n\r')
    modified=$(echo "$UNCOMMITTED" | cut -d: -f2 | tr -d '\n\r')
    untracked=$(echo "$UNCOMMITTED" | cut -d: -f3 | tr -d '\n\r')

    # Spike
    spike_topic=$(echo "$RECENT_SPIKE" | cut -d: -f1 | tr -d '\n\r')
    spike_age=$(echo "$RECENT_SPIKE" | cut -d: -f2 | tr -d '\n\r')

    # Build recommended action
    rec_action=$(case $SITUATION in
        fresh_start_resume) echo "auto_resume" ;;
        stale_fresh_start) echo "cleanup" ;;
        active_plan) echo "continue" ;;
        complete_plan) echo "ship" ;;
        blocked_plan) echo "unblock" ;;
        uncommitted_work) echo "commit" ;;
        high_priority_issues) echo "fix_issue" ;;
        open_issues) echo "triage_issues" ;;
        recent_spike) echo "apply_spike" ;;
        clean_slate) echo "new_work" ;;
        *) echo "unknown" ;;
    esac)

    # Ensure numeric values are valid
    [ -z "$fs_age" ] || ! [[ "$fs_age" =~ ^[0-9]+$ ]] && fs_age=0
    [ -z "$plan_completed" ] || ! [[ "$plan_completed" =~ ^[0-9]+$ ]] && plan_completed=0
    [ -z "$plan_total" ] || ! [[ "$plan_total" =~ ^[0-9]+$ ]] && plan_total=0
    [ -z "$issue_count" ] || ! [[ "$issue_count" =~ ^[0-9]+$ ]] && issue_count=0
    [ -z "$issue_high" ] || ! [[ "$issue_high" =~ ^[0-9]+$ ]] && issue_high=0
    [ -z "$staged" ] || ! [[ "$staged" =~ ^[0-9]+$ ]] && staged=0
    [ -z "$modified" ] || ! [[ "$modified" =~ ^[0-9]+$ ]] && modified=0
    [ -z "$untracked" ] || ! [[ "$untracked" =~ ^[0-9]+$ ]] && untracked=0

    # Use jq if available for proper JSON, otherwise use manual construction
    if command -v jq &> /dev/null; then
        jq -n \
            --arg situation "$SITUATION" \
            --arg fs_status "$fs_status" \
            --argjson fs_age "$fs_age" \
            --arg fs_plan "$fs_plan" \
            --arg fs_next "$fs_next" \
            --arg plan_status "$plan_status" \
            --argjson plan_completed "$plan_completed" \
            --argjson plan_total "$plan_total" \
            --arg plan_name "$plan_name" \
            --arg plan_file "$plan_file" \
            --argjson issue_count "$issue_count" \
            --argjson issue_high "$issue_high" \
            --argjson staged "$staged" \
            --argjson modified "$modified" \
            --argjson untracked "$untracked" \
            --arg spike_topic "$spike_topic" \
            --arg spike_age "$spike_age" \
            --argjson context_pct "$CONTEXT_PCT" \
            --arg rec_action "$rec_action" \
            '{
                situation: $situation,
                fresh_start: {
                    status: $fs_status,
                    age_days: $fs_age,
                    plan: $fs_plan,
                    next_task: $fs_next
                },
                active_plan: {
                    status: $plan_status,
                    completed: $plan_completed,
                    total: $plan_total,
                    name: $plan_name,
                    file: $plan_file
                },
                open_issues: {
                    count: $issue_count,
                    high_priority: $issue_high
                },
                uncommitted: {
                    staged: $staged,
                    modified: $modified,
                    untracked: $untracked
                },
                recent_spike: {
                    topic: $spike_topic,
                    age: $spike_age
                },
                context_usage_pct: $context_pct,
                recommended_action: $rec_action
            }'
    else
        # Fallback to manual JSON construction - escape special chars
        plan_name_escaped=$(echo "$plan_name" | sed 's/"/\\"/g')
        cat <<JSONEOF
{
  "situation": "$SITUATION",
  "fresh_start": {"status": "$fs_status", "age_days": ${fs_age:-0}, "plan": "$fs_plan", "next_task": "$fs_next"},
  "active_plan": {"status": "$plan_status", "completed": ${plan_completed:-0}, "total": ${plan_total:-0}, "name": "$plan_name_escaped", "file": "$plan_file"},
  "open_issues": {"count": ${issue_count:-0}, "high_priority": ${issue_high:-0}},
  "uncommitted": {"staged": ${staged:-0}, "modified": ${modified:-0}, "untracked": ${untracked:-0}},
  "recent_spike": {"topic": "$spike_topic", "age": "$spike_age"},
  "context_usage_pct": $CONTEXT_PCT,
  "recommended_action": "$rec_action"
}
JSONEOF
    fi
else
    echo "=== Workflow State Detection ==="
    echo ""
    echo "Situation: $SITUATION"
    echo ""
    echo "Fresh Start: $FRESH_START"
    echo "Active Plan: $ACTIVE_PLAN"
    echo "Open Issues: $OPEN_ISSUES"
    echo "Uncommitted: $UNCOMMITTED"
    echo "Recent Spike: $RECENT_SPIKE"
    echo "Context Usage: ${CONTEXT_PCT}%"
    echo ""
    echo "Recommended: $(case $SITUATION in
        fresh_start_resume) echo "Auto-resume with /devloop:continue" ;;
        stale_fresh_start) echo "Clean up stale state" ;;
        active_plan) echo "Continue with /devloop:continue" ;;
        complete_plan) echo "Ship with /devloop:ship" ;;
        blocked_plan) echo "Unblock pending tasks" ;;
        uncommitted_work) echo "Commit changes first" ;;
        high_priority_issues) echo "Fix high-priority issues" ;;
        open_issues) echo "Triage open issues" ;;
        recent_spike) echo "Apply spike findings" ;;
        clean_slate) echo "Start new work" ;;
        *) echo "Unknown" ;;
    esac)"
fi
