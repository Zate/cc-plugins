#!/usr/bin/env bash
#
# workflow-state.sh - Workflow state management
#
# Usage: workflow-state.sh <operation> [args...]
#
# Operations:
#   --init [plan_file]                 Initialize new workflow.json
#   --read [--json]                    Read and output current workflow state
#   --update-position <task>           Update current position (task, phase)
#   --update-metrics                   Update session metrics
#   --add-transition <from> <to>       Record a state transition
#   --health                           Calculate and output health score
#
# This script manages .devloop/workflow.json per the schema at
# plugins/devloop/schemas/workflow.schema.json

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

WORKFLOW_FILE=".devloop/workflow.json"

# Ensure .devloop directory exists
ensure_devloop_dir() {
    mkdir -p .devloop
}

# Generate workflow ID (timestamp-based)
generate_workflow_id() {
    echo "$(date +%s)000"
}

# Get current ISO 8601 timestamp
now_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Initialize a new workflow.json
cmd_init() {
    local plan_file="${1:-.devloop/plan.md}"

    ensure_devloop_dir

    # Generate workflow ID
    local workflow_id
    workflow_id=$(generate_workflow_id)

    # Get plan info if exists
    local plan_name=""
    local total_tasks=0
    local current_phase_name=""

    if [ -f "$plan_file" ]; then
        plan_name=$(grep -m1 "^# " "$plan_file" 2>/dev/null | sed 's/^# //' | head -c 200 || echo "")
        total_tasks=$({ grep -cE '^\s*-\s*\[' "$plan_file" 2>/dev/null || true; } | tr -d '\n')
        total_tasks=${total_tasks:-0}
        current_phase_name=$(grep -m1 "^### Phase" "$plan_file" 2>/dev/null | sed 's/^### //' | head -c 100 || echo "")
    fi

    # Detect origin type
    local origin_type="manual"
    local origin_source=""

    # Check for recent spike
    if [ -d ".devloop/spikes" ]; then
        local newest_spike=$(ls -t .devloop/spikes/*.md 2>/dev/null | head -1)
        if [ -n "$newest_spike" ]; then
            # Check if spike is less than 1 hour old
            local mod_time
            if stat --version 2>/dev/null | grep -q GNU; then
                mod_time=$(stat -c %Y "$newest_spike")
            else
                mod_time=$(stat -f %m "$newest_spike")
            fi

            local now=$(date +%s)
            local age_hours=$(( (now - mod_time) / 3600 ))

            if [ "$age_hours" -lt 1 ]; then
                origin_type="spike"
                origin_source=$(basename "$newest_spike")
            fi
        fi
    fi

    # Check for fresh start state
    if [ -f ".devloop/next-action.json" ] && command -v jq &> /dev/null; then
        local fresh_start_plan
        fresh_start_plan=$(jq -r '.plan // ""' .devloop/next-action.json 2>/dev/null || echo "")
        if [ -n "$fresh_start_plan" ]; then
            origin_type="manual"
            origin_source="resume_from_fresh_start"
        fi
    fi

    # Determine initial phase based on plan state
    local initial_phase="planning"
    if [ -f "$plan_file" ]; then
        if [ "$total_tasks" -eq 0 ]; then
            initial_phase="planning"
        else
            local completed=$({ grep -cE '^\s*-\s*\[[xX]\]' "$plan_file" 2>/dev/null || true; } | tr -d '\n')
            completed=${completed:-0}

            if [ "$completed" -eq 0 ]; then
                initial_phase="execution"
            elif [ "$completed" -eq "$total_tasks" ]; then
                initial_phase="validation"
            else
                initial_phase="execution"
            fi
        fi
    fi

    # Build JSON
    if command -v jq &> /dev/null; then
        jq -n \
            --arg schema_version "1.0.0" \
            --arg workflow_id "$workflow_id" \
            --arg started "$(now_timestamp)" \
            --arg last_active "$(now_timestamp)" \
            --arg phase "$initial_phase" \
            --arg origin_type "$origin_type" \
            --arg origin_source "$origin_source" \
            --arg origin_ts "$(now_timestamp)" \
            --arg plan_file "$plan_file" \
            --arg plan_name "$plan_name" \
            --argjson total_tasks "$total_tasks" \
            --arg current_phase_name "$current_phase_name" \
            '{
                schema_version: $schema_version,
                workflow_id: $workflow_id,
                started: $started,
                last_active: $last_active,
                position: {
                    phase: $phase,
                    subphase: null,
                    current_task: null,
                    current_command: null
                },
                origin: {
                    type: $origin_type,
                    source: $origin_source,
                    timestamp: $origin_ts
                },
                plan: (if $plan_file != "" and $plan_name != "" then {
                    file: $plan_file,
                    name: $plan_name,
                    total_tasks: $total_tasks,
                    completed_tasks: 0,
                    current_phase_name: $current_phase_name
                } else null end),
                sessions: [],
                metrics: {
                    total_tasks_completed: 0,
                    total_commits: 0,
                    total_sessions: 0,
                    avg_tasks_per_session: 0,
                    avg_context_peak: 0,
                    velocity: {
                        tasks_per_hour: 0,
                        trend: "unknown"
                    },
                    health: {
                        score: 100,
                        factors: {
                            plan_freshness: 100,
                            worklog_sync: 100,
                            commit_frequency: 100,
                            context_management: 100
                        }
                    }
                },
                transitions: [],
                next_action: {
                    recommended: "continue",
                    reason: "Workflow just started",
                    alternatives: ["status"],
                    freshness_warning: false
                }
            }' > "$WORKFLOW_FILE"

        echo "Initialized workflow: $workflow_id (phase: $initial_phase)"
    else
        echo "Error: jq is required for workflow state management"
        exit 1
    fi
}

# Read and output current workflow state
cmd_read() {
    local output_json=false

    if [[ "${1:-}" == "--json" ]]; then
        output_json=true
    fi

    if [ ! -f "$WORKFLOW_FILE" ]; then
        if [ "$output_json" = true ]; then
            echo '{"error": "no_workflow"}'
        else
            echo "No active workflow"
        fi
        exit 1
    fi

    if [ "$output_json" = true ]; then
        cat "$WORKFLOW_FILE"
    else
        # Human-readable output
        if command -v jq &> /dev/null; then
            local workflow_id phase current_task plan_name completed total
            workflow_id=$(jq -r '.workflow_id' "$WORKFLOW_FILE")
            phase=$(jq -r '.position.phase' "$WORKFLOW_FILE")
            current_task=$(jq -r '.position.current_task // "none"' "$WORKFLOW_FILE")
            plan_name=$(jq -r '.plan.name // "No plan"' "$WORKFLOW_FILE")
            completed=$(jq -r '.plan.completed_tasks // 0' "$WORKFLOW_FILE")
            total=$(jq -r '.plan.total_tasks // 0' "$WORKFLOW_FILE")

            echo "Workflow: $workflow_id"
            echo "Phase: $phase"
            echo "Current task: $current_task"
            echo "Plan: $plan_name ($completed/$total tasks)"
        else
            cat "$WORKFLOW_FILE"
        fi
    fi
}

# Update position (task and derived phase/subphase)
cmd_update_position() {
    local task_id="${1:-}"

    if [ -z "$task_id" ]; then
        echo "Error: task ID required"
        exit 1
    fi

    if [ ! -f "$WORKFLOW_FILE" ]; then
        echo "Error: No workflow file. Run --init first."
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required"
        exit 1
    fi

    # Update current_task and last_active
    jq --arg task "$task_id" --arg now "$(now_timestamp)" '
        .position.current_task = $task |
        .position.subphase = "implementing" |
        .last_active = $now
    ' "$WORKFLOW_FILE" > "$WORKFLOW_FILE.tmp" && mv "$WORKFLOW_FILE.tmp" "$WORKFLOW_FILE"

    echo "Updated position to task $task_id"
}

# Update session metrics
cmd_update_metrics() {
    if [ ! -f "$WORKFLOW_FILE" ]; then
        echo "Error: No workflow file. Run --init first."
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required"
        exit 1
    fi

    # Read plan state if exists
    local completed_tasks=0
    local plan_file
    plan_file=$(jq -r '.plan.file // ""' "$WORKFLOW_FILE")

    if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
        completed_tasks=$({ grep -cE '^\s*-\s*\[[xX]\]' "$plan_file" 2>/dev/null || true; } | tr -d '\n')
        completed_tasks=${completed_tasks:-0}
    fi

    # Count recent commits (last 7 days)
    local recent_commits=0
    if [ -d ".git" ]; then
        recent_commits=$(git log --since="7 days ago" --oneline 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    fi

    # Update metrics
    jq --argjson completed "$completed_tasks" \
       --argjson commits "$recent_commits" \
       --arg now "$(now_timestamp)" '
        .plan.completed_tasks = $completed |
        .metrics.total_tasks_completed = $completed |
        .metrics.total_commits = $commits |
        .last_active = $now
    ' "$WORKFLOW_FILE" > "$WORKFLOW_FILE.tmp" && mv "$WORKFLOW_FILE.tmp" "$WORKFLOW_FILE"

    echo "Updated metrics: $completed_tasks tasks, $recent_commits commits"
}

# Add state transition
cmd_add_transition() {
    local from="${1:-}"
    local to="${2:-}"
    local trigger="${3:-manual}"

    if [ -z "$from" ] || [ -z "$to" ]; then
        echo "Error: from and to phases required"
        echo "Usage: --add-transition <from> <to> [trigger]"
        exit 1
    fi

    if [ ! -f "$WORKFLOW_FILE" ]; then
        echo "Error: No workflow file. Run --init first."
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required"
        exit 1
    fi

    # Add transition and update current phase
    jq --arg from "$from" \
       --arg to "$to" \
       --arg trigger "$trigger" \
       --arg now "$(now_timestamp)" '
        .transitions += [{
            from: $from,
            to: $to,
            timestamp: $now,
            trigger: $trigger
        }] |
        .position.phase = $to |
        .last_active = $now
    ' "$WORKFLOW_FILE" > "$WORKFLOW_FILE.tmp" && mv "$WORKFLOW_FILE.tmp" "$WORKFLOW_FILE"

    echo "Recorded transition: $from → $to"
}

# Calculate and output health score
cmd_health() {
    if [ ! -f "$WORKFLOW_FILE" ]; then
        echo "Error: No workflow file. Run --init first."
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required"
        exit 1
    fi

    # Get plan file
    local plan_file
    plan_file=$(jq -r '.plan.file // ""' "$WORKFLOW_FILE")

    # Calculate plan_freshness (0-100)
    local plan_freshness=25
    if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
        local mod_time now age_hours

        if stat --version 2>/dev/null | grep -q GNU; then
            mod_time=$(stat -c %Y "$plan_file")
        else
            mod_time=$(stat -f %m "$plan_file")
        fi

        now=$(date +%s)
        age_hours=$(( (now - mod_time) / 3600 ))

        if [ "$age_hours" -lt 24 ]; then
            plan_freshness=100
        elif [ "$age_hours" -lt 48 ]; then
            plan_freshness=75
        elif [ "$age_hours" -lt 168 ]; then  # 7 days
            plan_freshness=50
        fi
    fi

    # Calculate worklog_sync (0-100)
    # Check if worklog is up to date with completed tasks
    local worklog_sync=100
    local worklog_file=".devloop/worklog.md"

    if [ -n "$plan_file" ] && [ -f "$plan_file" ] && [ -f "$worklog_file" ]; then
        local completed_tasks
        completed_tasks=$({ grep -cE '^\s*-\s*\[[xX]\]' "$plan_file" 2>/dev/null || true; } | tr -d '\n')
        completed_tasks=${completed_tasks:-0}

        # Count worklog entries (simplified - assumes one entry per task)
        local worklog_entries
        worklog_entries=$({ grep -cE '^- \[' "$worklog_file" 2>/dev/null || true; } | tr -d '\n')
        worklog_entries=${worklog_entries:-0}

        if [ "$completed_tasks" -gt 0 ]; then
            # Calculate sync percentage
            local sync_ratio=$(( worklog_entries * 100 / completed_tasks ))
            if [ "$sync_ratio" -gt 100 ]; then
                sync_ratio=100
            fi
            worklog_sync=$sync_ratio
        fi
    fi

    # Calculate commit_frequency (0-100)
    # Based on commits in last session relative to tasks completed
    local commit_frequency=100

    if [ -d ".git" ] && [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
        local completed_tasks
        completed_tasks=$({ grep -cE '^\s*-\s*\[[xX]\]' "$plan_file" 2>/dev/null || true; } | tr -d '\n')
        completed_tasks=${completed_tasks:-0}

        if [ "$completed_tasks" -gt 0 ]; then
            local recent_commits
            recent_commits=$(git log --since="7 days ago" --oneline 2>/dev/null | wc -l | tr -d ' ' || echo "0")

            # Ideal: 1 commit per 2-3 tasks
            local ideal_commits=$(( completed_tasks / 2 ))
            if [ "$ideal_commits" -lt 1 ]; then
                ideal_commits=1
            fi

            if [ "$recent_commits" -ge "$ideal_commits" ]; then
                commit_frequency=100
            else
                commit_frequency=$(( recent_commits * 100 / ideal_commits ))
            fi
        fi
    fi

    # Calculate context_management (0-100)
    # Based on whether fresh starts are being used appropriately
    local context_management=85  # Default good score

    # Check if session tracker has context info
    if [ -f ".devloop/sessions.json" ] && command -v jq &> /dev/null; then
        local last_context
        last_context=$(jq '.sessions[-1].end_context_pct // 0' .devloop/sessions.json 2>/dev/null || echo "0")

        if [ "$last_context" -gt 80 ]; then
            context_management=50  # Should have used fresh start
        elif [ "$last_context" -gt 60 ]; then
            context_management=75  # Getting high
        fi
    fi

    # Calculate overall score (average of all factors)
    local overall_score=$(( (plan_freshness + worklog_sync + commit_frequency + context_management) / 4 ))

    # Update workflow.json with health scores
    jq --argjson score "$overall_score" \
       --argjson plan_freshness "$plan_freshness" \
       --argjson worklog_sync "$worklog_sync" \
       --argjson commit_frequency "$commit_frequency" \
       --argjson context_management "$context_management" \
       --arg now "$(now_timestamp)" '
        .metrics.health = {
            score: $score,
            factors: {
                plan_freshness: $plan_freshness,
                worklog_sync: $worklog_sync,
                commit_frequency: $commit_frequency,
                context_management: $context_management
            }
        } |
        .last_active = $now
    ' "$WORKFLOW_FILE" > "$WORKFLOW_FILE.tmp" && mv "$WORKFLOW_FILE.tmp" "$WORKFLOW_FILE"

    # Output
    echo "Health Score: $overall_score/100"
    echo ""
    echo "Factors:"
    echo "  Plan Freshness: $plan_freshness/100"
    echo "  Worklog Sync: $worklog_sync/100"
    echo "  Commit Frequency: $commit_frequency/100"
    echo "  Context Management: $context_management/100"

    # Health assessment
    if [ "$overall_score" -ge 85 ]; then
        echo ""
        echo "✓ Workflow health is excellent"
    elif [ "$overall_score" -ge 70 ]; then
        echo ""
        echo "⚠ Workflow health is good, minor improvements possible"
    elif [ "$overall_score" -ge 50 ]; then
        echo ""
        echo "⚠ Workflow health needs attention"
    else
        echo ""
        echo "❌ Workflow health is poor, immediate action recommended"
    fi
}

# Main command routing
case "${1:-}" in
    --init)
        cmd_init "${2:-}"
        ;;
    --read)
        cmd_read "${2:-}"
        ;;
    --update-position)
        cmd_update_position "${2:-}"
        ;;
    --update-metrics)
        cmd_update_metrics
        ;;
    --add-transition)
        cmd_add_transition "${2:-}" "${3:-}" "${4:-manual}"
        ;;
    --health)
        cmd_health
        ;;
    -h|--help)
        cat <<EOF
Usage: workflow-state.sh <operation> [args...]

Operations:
  --init [plan_file]                 Initialize new workflow.json
  --read [--json]                    Read and output current workflow state
  --update-position <task>           Update current position (task, phase)
  --update-metrics                   Update session metrics
  --add-transition <from> <to>       Record a state transition
  --health                           Calculate and output health score

Examples:
  # Initialize new workflow
  workflow-state.sh --init

  # Read current state as JSON
  workflow-state.sh --read --json

  # Update to task 2.1
  workflow-state.sh --update-position 2.1

  # Update metrics from plan
  workflow-state.sh --update-metrics

  # Record phase transition
  workflow-state.sh --add-transition execution validation auto

  # Calculate health score
  workflow-state.sh --health
EOF
        ;;
    *)
        echo "Error: Unknown operation '${1:-}'"
        echo "Run --help for usage"
        exit 1
        ;;
esac
