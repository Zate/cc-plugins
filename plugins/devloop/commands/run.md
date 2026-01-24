---
description: Execute plan tasks autonomously until completion
argument-hint: "[--max-iterations N] [--interactive]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - Task
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - TaskList
  - Skill
---

# Devloop Run - Autonomous Plan Execution

The unified command for executing plan tasks. Runs autonomously by default (ralph behavior).

**You do the work directly.**

## Step 1: Check Plan State

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md
```

Parse the JSON output:
- `complete`: boolean - all tasks done?
- `total`: number of total tasks
- `done`: number completed
- `pending`: number remaining

### If no plan exists (script errors or file missing):

```
No active plan found.

Start with:
  /devloop:spike "topic"    - Explore before implementing
  /devloop:from-issue 123   - Work from GitHub issue
  /devloop                   - Smart entry point
```

Then STOP - do not continue.

### If plan is complete (`complete: true`):

```
Plan complete! All [total] tasks finished.
```

```yaml
AskUserQuestion:
  questions:
    - question: "All tasks done. What next?"
      header: "Complete"
      multiSelect: false
      options:
        - label: "Ship it (Recommended)"
          description: "Commit and optionally create PR"
        - label: "Archive and start new"
          description: "Move completed plan to archive"
        - label: "Review first"
          description: "Review work before shipping"
```

**Routing:**
- "Ship it" → `/devloop:ship`
- "Archive and start new" → Run archive script, then `/devloop`
- "Review first" → `/devloop:review`

Then STOP - do not continue to autonomous execution.

### If plan has pending tasks:

Continue to Step 2.

## Step 2: Parse Arguments

Check for flags in `$ARGUMENTS`:

- `--max-iterations N`: Override default 50 iteration limit
- `--interactive`: Disable autonomous mode, prompt at each task

Default behavior is **autonomous** (no `--interactive` flag).

## Step 3: Check for Fresh Start State

```bash
if [ -f ".devloop/next-action.json" ]; then
  cat .devloop/next-action.json
  rm .devloop/next-action.json
fi
```

If `next-action.json` exists:
1. Read the saved state
2. Delete the file (single-use)
3. Display: "Resuming from checkpoint: [context]"

## Step 4: Setup Autonomous Mode

Unless `--interactive` was specified, set up ralph-loop state:

```bash
mkdir -p .claude

cat > .claude/ralph-loop.local.md <<'RALPH_STATE'
---
active: true
iteration: 1
max_iterations: ${MAX_ITERATIONS:-50}
completion_promise: "ALL PLAN TASKS COMPLETE"
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
devloop_integration: true
---

Continue working on tasks from .devloop/plan.md.

Work on the NEXT UNCHECKED task (marked `- [ ]`).
After completing it, mark it `- [x]` in the plan.

When ALL tasks are complete, output:
<promise>ALL PLAN TASKS COMPLETE</promise>
RALPH_STATE
```

Display status:

```
Autonomous mode active
Plan: .devloop/plan.md
Progress: [done]/[total] tasks ([pending] remaining)
Max iterations: [max_iterations]

Starting work...
```

## Step 4b: Sync Plan Tasks to Native Task System (Optional)

For real-time progress tracking in Claude Code UI, sync pending tasks:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/sync-plan-to-tasks.sh" .devloop/plan.md
```

For each pending task in the JSON output, use `TaskCreate`:
- `subject`: Task subject from plan
- `description`: Task description
- `activeForm`: Present continuous form (e.g., "Implementing X")

This creates native tasks that show progress in the UI. The plan.md remains the source of truth for persistence.

**Note**: This step is optional. Native tasks provide UI feedback but plan.md is authoritative.

## Step 5: Execute Tasks

Read the plan:

```bash
cat .devloop/plan.md
```

Find the next pending task (marked with `- [ ]`).

### Implement the Task Directly

**You do the work. Do NOT spawn agents for routine tasks.**

- Write code → Use Write/Edit tools
- Run tests → Use Bash
- Git operations → Use Bash
- Read files → Use Read/Grep/Glob tools

### Only Use Agents For:
- **Parallel work**: Multiple independent tasks running simultaneously
- **Security scan**: Full codebase audit (`devloop:security-scanner`)
- **Large exploration**: Use `Explore` agent for codebase understanding

## Step 6: Update Plan After Each Task

After completing a task:

1. Mark it done in the plan:
   ```markdown
   - [x] Completed task description
   ```

2. **Update native task status** (if tasks were created in Step 4b):
   - Use `TaskUpdate` with `status: "completed"` for the finished task
   - Use `TaskUpdate` with `status: "in_progress"` for the next task

3. Check completion status:
   ```bash
   "${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md
   ```

4. **If all tasks complete** (`complete: true`):

   Output the promise tag to terminate the loop:
   ```
   All plan tasks complete!

   <promise>ALL PLAN TASKS COMPLETE</promise>
   ```

5. **If tasks remain** (`complete: false`):

   In autonomous mode: Continue to next task (no prompt)

   In interactive mode (`--interactive`):
   ```yaml
   AskUserQuestion:
     questions:
       - question: "Completed [task]. What next?"
         header: "Checkpoint"
         multiSelect: false
         options:
           - label: "Continue"
             description: "Move to next task"
           - label: "Commit"
             description: "Git commit this work"
           - label: "Break"
             description: "Save state, take a break"
   ```

## Step 6b: Auto-Commit at Phase Checkpoints

Check local config for auto-commit setting:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/parse-local-config.sh" | grep -o '"auto_commit":[^,}]*' | cut -d: -f2
```

**If `auto_commit: true` and a phase is complete** (all tasks in current phase marked `[x]`):

1. Detect phase completion by checking if the next pending task is in a different phase
2. Auto-commit the phase work:
   ```bash
   git add -A
   git commit -m "feat(devloop): complete Phase N - [phase description]"
   ```
3. Display: "Auto-committed Phase N completion"
4. Continue to next phase

**Phase detection**: A phase is complete when the next `- [ ]` task appears under a different `## Phase` heading than the current completed task.

In autonomous mode with `auto_commit: true`, commits happen automatically at phase boundaries without prompting.

## Step 7: Handle Completion

When all tasks are marked `[x]`:

1. Output the promise tag (terminates ralph loop)
2. Offer next steps:

```yaml
AskUserQuestion:
  questions:
    - question: "All tasks complete! What next?"
      header: "Done"
      multiSelect: false
      options:
        - label: "Ship it (Recommended)"
          description: "Commit and optionally create PR"
        - label: "Archive"
          description: "Move to archive, start fresh"
        - label: "Review first"
          description: "Review before shipping"
```

## When the Loop Stops

The autonomous loop terminates when:
- All tasks marked `[x]` AND promise tag output
- Max iterations reached (safety limit)
- User runs `/cancel-ralph` (manual stop)
- Error or ambiguous situation requiring user input

## Available Skills (Load On Demand)

If you need specialized knowledge:

```
Skill: plan-management      # Plan file conventions
Skill: git-workflows        # Complex git operations
Skill: testing-strategies   # Test design patterns
Skill: [language]-patterns  # Language-specific idioms
```

Load skills when the task requires domain expertise, not preemptively.

## Example Usage

```bash
# Default: autonomous execution
/devloop:run

# Extended iterations for large plans
/devloop:run --max-iterations 100

# Interactive mode (prompt at each task)
/devloop:run --interactive

# Check progress mid-run
head -10 .claude/ralph-loop.local.md
```

## Migration Notes

This command replaces:
- `/devloop:continue` - Use `/devloop:run --interactive` for similar behavior
- `/devloop:ralph` - `/devloop:run` is autonomous by default

Both old commands now alias to this one.

---

**Now**: Check plan state and begin execution.
