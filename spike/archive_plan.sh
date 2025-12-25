#!/bin/bash
# Prototype: Plan Archival Script
# Purpose: Move completed phases from plan.md to archive, compact Progress Log to worklog.md

set -e

PLAN_FILE="${1:-.devloop/plan.md}"
ARCHIVE_DIR=".devloop/archive"
WORKLOG_FILE=".devloop/worklog.md"

# Validate plan file exists
if [[ ! -f "$PLAN_FILE" ]]; then
  echo "Error: Plan file not found: $PLAN_FILE"
  exit 1
fi

# Create archive directory if needed
mkdir -p "$ARCHIVE_DIR"

# Extract plan metadata
plan_name=$(grep -m1 "^# " "$PLAN_FILE" | sed 's/^# //' | sed 's/[^a-zA-Z0-9-]/_/g' | tr '[:upper:]' '[:lower:]')
timestamp=$(date +%Y%m%d_%H%M%S)

# Determine what to archive
# Strategy: Archive all phases that are 100% complete (all tasks [x])

echo "=== Plan Archival Prototype ==="
echo "Plan: $plan_name"
echo "Timestamp: $timestamp"
echo ""

# Count total tasks vs completed
total_tasks=$(grep -c "^\s*- \[" "$PLAN_FILE" || echo 0)
completed_tasks=$(grep -c "^\s*- \[x\]" "$PLAN_FILE" || echo 0)
pending_tasks=$((total_tasks - completed_tasks))

echo "Tasks: $completed_tasks/$total_tasks complete ($pending_tasks pending)"
echo ""

# Prototype Approach 1: Phase-Based Archival
# Archive phases where all tasks are [x]
echo "--- Approach 1: Phase-Based Archival ---"
echo "Detecting complete phases..."

# Extract phase headers and check if all tasks in that phase are complete
# This is a simplified prototype - production would need proper markdown parsing

# For this spike, let's just show the logic:
echo "Phase detection logic:"
echo "1. Find all ### Phase headers"
echo "2. For each phase, count [x] vs [ ] tasks"
echo "3. If phase is 100% complete, mark for archival"
echo ""

# Prototype Approach 2: Task-Count-Based Archival
# Keep last N tasks (e.g., 10) in plan, archive the rest
echo "--- Approach 2: Task-Count-Based Archival ---"
KEEP_RECENT_TASKS=10

if [[ $completed_tasks -gt $KEEP_RECENT_TASKS ]]; then
  archive_task_count=$((completed_tasks - KEEP_RECENT_TASKS))
  echo "Would archive $archive_task_count older completed tasks"
  echo "Keep most recent $KEEP_RECENT_TASKS tasks in plan.md"
else
  echo "Not enough completed tasks to archive (need >$KEEP_RECENT_TASKS)"
fi
echo ""

# Prototype Approach 3: Progress Log Rotation
# Move Progress Log entries to worklog.md
echo "--- Approach 3: Progress Log to Worklog ---"

# Count Progress Log entries
progress_log_lines=$(awk '/^## Progress Log$/,/^## / {print}' "$PLAN_FILE" | grep -c "^- " || echo 0)
echo "Progress Log entries: $progress_log_lines"

if [[ $progress_log_lines -gt 0 ]]; then
  echo "Would extract Progress Log and append to $WORKLOG_FILE"
  echo "Format: Convert to worklog format with plan name and date"
fi
echo ""

# Prototype Archive File Structure
echo "--- Archive File Structure ---"
archive_file="$ARCHIVE_DIR/${plan_name}_${timestamp}.md"
echo "Archive location: $archive_file"
echo ""
echo "Archive would contain:"
echo "  - Plan metadata (name, dates, status)"
echo "  - Overview and Architecture sections (reference)"
echo "  - Complete task list (historical record)"
echo "  - Full Progress Log (commit references)"
echo ""
echo "Compressed plan.md would contain:"
echo "  - Plan metadata (updated)"
echo "  - Overview (kept for context)"
echo "  - Recent N phases/tasks only"
echo "  - Compact Progress Log (last 5-10 entries)"
echo ""

# Simulate space savings
plan_size=$(wc -l < "$PLAN_FILE")
echo "Current plan.md: $plan_size lines"

# Estimate: Archive ~70% of completed phases
# Keep: Header (10 lines) + Overview (20 lines) + Recent tasks (50 lines) + Compact progress (20 lines)
estimated_compressed=$(( 10 + 20 + 50 + 20 ))
estimated_savings=$(( 100 - (estimated_compressed * 100 / plan_size) ))

echo "Estimated compressed: ~$estimated_compressed lines"
echo "Estimated savings: ~$estimated_savings%"
echo ""

# Prototype: What /devloop:continue would read after archival
echo "--- Post-Archival: /devloop:continue Behavior ---"
echo "1. Read plan.md (now ~$estimated_compressed lines instead of $plan_size)"
echo "2. See only recent context (last few phases)"
echo "3. If user asks about older tasks, suggest: 'See archive/$archive_file'"
echo "4. For commit validation, worklog.md has full history"
echo ""

echo "=== Prototype Complete ==="
echo ""
echo "Next Steps:"
echo "1. Choose archival strategy (phase-based vs task-count)"
echo "2. Implement markdown parsing for phase extraction"
echo "3. Create archive file format template"
echo "4. Update worklog.md with Progress Log entries"
echo "5. Add /devloop:archive command to automate"
echo "6. Update continue.md to handle archived references"
