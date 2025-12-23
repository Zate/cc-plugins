---
description: Save current plan state and prepare for fresh context restart
argument-hint: none
allowed-tools: ["Read", "Write", "Grep", "Bash", "AskUserQuestion"]
---

# Fresh Start

Save the current devloop plan state and prepare for a fresh context restart. This command allows you to clear your conversation context while preserving your work progress.

**Use this when:**
- Context feels heavy or slow
- You've completed many tasks in one session
- You want to start fresh while preserving state
- Conversation history is getting long

**References**:
- `Skill: plan-management` - Plan format and state
- `Skill: workflow-loop` - Context management patterns

---

## How It Works

1. **Gathers current state** from `.devloop/plan.md`
2. **Identifies progress** (last completed, next pending task)
3. **Saves state** to `.devloop/next-action.json`
4. **Displays instructions** for resuming with fresh context

The next time you run `/devloop:continue`, it will automatically detect the saved state and pick up where you left off.

---

## Step 1: Find and Read Plan

Search in standard locations:
1. `.devloop/plan.md` ← Primary
2. `docs/PLAN.md`
3. `PLAN.md`

**If no plan found:**

```yaml
AskUserQuestion:
  question: "No active plan found. Cannot save fresh start state without a plan."
  header: "No Plan"
  options:
    - label: "Start new feature"
      description: "Launch /devloop to begin new work"
    - label: "Create plan first"
      description: "Use plan mode to design tasks"
    - label: "Cancel"
      description: "Exit without saving state"
```

If user selects "Start new feature" → invoke `/devloop`
If user selects "Create plan first" → display guidance, exit
If user selects "Cancel" → exit

---

## Step 2: Parse Plan State

Extract key information:

```bash
# Read plan file
plan_content=$(cat .devloop/plan.md)

# Extract metadata
plan_name=$(grep -m1 "^# Devloop Plan:" .devloop/plan.md | sed 's/^# Devloop Plan: //')
current_phase=$(grep "^**Current Phase**:" .devloop/plan.md | head -1 | sed 's/^**Current Phase**: //')

# Count tasks
total_tasks=$(grep -E '^\s*-\s*\[.\]' .devloop/plan.md | wc -l)
completed_tasks=$(grep -E '^\s*-\s*\[x\]' .devloop/plan.md | wc -l)
pending_tasks=$(grep -E '^\s*-\s*\[\s\]' .devloop/plan.md | wc -l)

# Find last completed task (last line with [x])
last_completed=$(grep -E '^\s*-\s*\[x\].*Task [0-9]+\.[0-9]+' .devloop/plan.md | tail -1 | sed 's/.*\(Task [0-9]\+\.[0-9]\+[^-]*\).*/\1/')

# Find next pending task (first line with [ ])
next_pending=$(grep -E '^\s*-\s*\[\s\].*Task [0-9]+\.[0-9]+' .devloop/plan.md | head -1 | sed 's/.*\(Task [0-9]\+\.[0-9]\+[^-]*\).*/\1/')
```

**Task status markers:**
- `[x]` - Completed
- `[ ]` - Pending
- `[~]` - In progress / partial
- `[!]` - Blocked
- `[-]` - Skipped

---

## Step 3: Generate Summary

Create concise progress summary:

```bash
# Calculate completion percentage
if [ $total_tasks -gt 0 ]; then
  completion_pct=$((completed_tasks * 100 / total_tasks))
else
  completion_pct=0
fi

# Generate summary
summary="Completed $completed_tasks of $total_tasks tasks ($completion_pct%). Current phase: $current_phase."

# Add context if available
if [ -n "$last_completed" ]; then
  summary="$summary Last completed: $last_completed."
fi
```

**Summary format:**
- Keep under 200 characters
- Include completion stats
- Mention current phase
- Reference last completed task

---

## Step 4: Save State to File

Write to `.devloop/next-action.json`:

```json
{
  "timestamp": "2025-12-23T14:30:00Z",
  "plan": "Feature Name",
  "phase": "Phase 3: Implementation",
  "total_tasks": 15,
  "completed_tasks": 8,
  "pending_tasks": 7,
  "last_completed": "Task 3.2: Create user service",
  "next_pending": "Task 3.3: Add authentication middleware",
  "summary": "Completed 8 of 15 tasks (53%). Current phase: Phase 3: Implementation. Last completed: Task 3.2.",
  "reason": "fresh_start"
}
```

**State file fields:**
- `timestamp` - ISO 8601 format
- `plan` - Plan name from header
- `phase` - Current phase name
- `total_tasks` - Total task count
- `completed_tasks` - Count of `[x]` tasks
- `pending_tasks` - Count of `[ ]` tasks
- `last_completed` - Last `[x]` task identifier
- `next_pending` - First `[ ]` task identifier
- `summary` - Brief progress description
- `reason` - Always "fresh_start" for this command

**File location:**
- Save to `.devloop/next-action.json`
- This file is read by session-start hook (Task 8.2)
- This file is read and deleted by `/devloop:continue` (Task 8.3)

---

## Step 5: Present Continuation Instructions

Display clear instructions for resuming:

```markdown
## Fresh Start State Saved ✓

Your devloop progress has been saved to `.devloop/next-action.json`.

### Current Progress
**Plan**: {plan_name}
**Phase**: {current_phase}
**Completed**: {completed_tasks}/{total_tasks} tasks ({completion_pct}%)

**Last completed**: {last_completed}
**Next up**: {next_pending}

### To Resume with Fresh Context

1. **Clear context**: Run `/clear` to reset conversation
2. **Resume work**: Run `/devloop:continue` to pick up where you left off

The saved state will be automatically detected on your next session.

### Alternative: Dismiss State

If you change your mind, delete the state file:
```bash
rm .devloop/next-action.json
```

---

**Tip**: Fresh starts are useful after completing 5-10 tasks or when context feels heavy. The session-start hook will remind you about saved state.
```

---

## Step 6: Update Plan Progress Log

Add entry to plan's Progress Log:

```bash
# Add fresh start entry
timestamp=$(date +"%Y-%m-%d %H:%M")
entry="- $timestamp: Fresh start initiated - state saved to next-action.json"

# Append to Progress Log section
# (Use Edit tool to insert before last entry or append to section)
```

**Progress Log format:**
```markdown
## Progress Log
- 2025-12-23 14:30: Fresh start initiated - state saved to next-action.json
- 2025-12-23 14:15: Completed Task 3.2 - Create user service
- 2025-12-23 13:45: Completed Task 3.1 - Create user model
```

---

## Edge Cases

| Scenario | Detection | Action |
|----------|-----------|--------|
| **No plan found** | `.devloop/plan.md` missing | Present "No Plan" question, exit |
| **Plan complete** | All tasks `[x]` | Inform user, suggest `/devloop:ship` instead |
| **No tasks in plan** | `total_tasks == 0` | Inform user, no state to save |
| **State file exists** | `.devloop/next-action.json` present | Confirm overwrite |
| **No completed tasks** | `completed_tasks == 0` | Still save state (user may want fresh start) |
| **Large plan** | Plan > 500 lines | Suggest `/devloop:archive` in addition |

### Handling Existing State File

If `.devloop/next-action.json` already exists:

```yaml
AskUserQuestion:
  question: "Fresh start state already exists. Overwrite with current progress?"
  header: "Overwrite"
  options:
    - label: "Yes, update state"
      description: "Save current progress (Recommended)"
    - label: "No, keep existing"
      description: "Exit without changing state"
    - label: "Show existing state"
      description: "Display saved state first"
```

If "Show existing state":
- Read and display `.devloop/next-action.json`
- Then re-ask the overwrite question

---

## Integration with Other Commands

### Session Start Hook (Task 8.2)

The session-start hook will:
1. Detect `.devloop/next-action.json` on startup
2. Parse state and display message:
   ```
   📋 Fresh Start Detected

   You have a saved devloop state from [timestamp].

   Last completed: [task]
   Next up: [task]

   Run /devloop:continue to resume or /devloop:fresh --dismiss to clear.
   ```

### Continue Command (Task 8.3)

The `/devloop:continue` command will:
1. Check for `.devloop/next-action.json` at startup
2. Read saved state if exists
3. Use state to identify next task
4. Delete state file after reading
5. Continue with normal workflow

### Dismiss Saved State

Add `--dismiss` flag support:

```bash
# If called with --dismiss argument
if [ "$ARGUMENTS" = "--dismiss" ]; then
  if [ -f .devloop/next-action.json ]; then
    rm .devloop/next-action.json
    echo "✓ Fresh start state dismissed."
  else
    echo "No fresh start state found."
  fi
  exit 0
fi
```

---

## Example Output

```markdown
## Fresh Start State Saved ✓

Your devloop progress has been saved to `.devloop/next-action.json`.

### Current Progress
**Plan**: Component Polish v2.1
**Phase**: Phase 8 - Fresh Start Mechanism
**Completed**: 0/4 tasks (0%)

**Last completed**: Task 7.4 - Standardize checkpoint questions
**Next up**: Task 8.1 - Create /devloop:fresh command

### To Resume with Fresh Context

1. **Clear context**: Run `/clear` to reset conversation
2. **Resume work**: Run `/devloop:continue` to pick up where you left off

The saved state will be automatically detected on your next session.

### Alternative: Dismiss State

If you change your mind, delete the state file:
```bash
rm .devloop/next-action.json
```

---

**Tip**: Fresh starts are useful after completing 5-10 tasks or when context feels heavy. The session-start hook will remind you about saved state.
```

---

## Model Usage

| Step | Model | Rationale |
|------|-------|-----------|
| Parse plan | haiku | Simple text parsing |
| Generate summary | haiku | String formatting |
| Write state file | haiku | JSON serialization |
| Display instructions | haiku | Static text output |

---

## Success Criteria

- [ ] Reads plan from standard locations
- [ ] Correctly identifies last completed and next pending tasks
- [ ] Writes valid JSON to `.devloop/next-action.json`
- [ ] Displays clear continuation instructions
- [ ] Updates plan Progress Log
- [ ] Handles edge cases (no plan, existing state, plan complete)
- [ ] Supports `--dismiss` flag to remove state
