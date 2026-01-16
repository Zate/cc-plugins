---
description: Start automated task loop with ralph-loop integration
argument-hint: "[--max-iterations N]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - AskUserQuestion
  - TodoWrite
  - Skill
---

# Ralph Loop - Automated Devloop Execution

Start an automated ralph loop that works through plan tasks until completion.

**Prerequisites**:
- A plan must exist at `.devloop/plan.md`
- The `ralph-loop` plugin must be installed

## How It Works

1. Sets up ralph-loop with completion promise "ALL PLAN TASKS COMPLETE"
2. Runs the continue workflow to complete tasks
3. When all tasks are marked `[x]`, outputs the promise tag
4. Ralph's Stop hook detects the promise and terminates the loop

## Step 1: Verify Prerequisites

**FIRST: Check ralph-loop plugin is installed:**

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-plugin.sh" ralph-loop
```

If `installed: false`, STOP and tell user:
```
The ralph-loop plugin is required but not installed.

Install it with:
  /plugin install ralph-loop

Then try again with /devloop:ralph
```

**THEN: Check for existing plan:**

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md
```

If no plan exists, tell user:
```
No plan found. Create one first:
  /devloop:spike "your feature"  - For exploration
  /devloop                       - For direct work
```

If plan already complete, tell user:
```
Plan already complete! Start a new plan with /devloop or /devloop:spike.
```

## Step 2: Parse Arguments

Default options:
- `--max-iterations 50` (safety limit)
- `--completion-promise "ALL PLAN TASKS COMPLETE"`

User can override with: `/devloop:ralph --max-iterations 100`

## Step 3: Setup Ralph Loop

Create ralph-loop state file:

```bash
mkdir -p .claude

cat > .claude/ralph-loop.local.md <<'RALPH_STATE'
---
active: true
iteration: 1
max_iterations: ${MAX_ITERATIONS}
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

## Step 4: Display Status

```
Ralph loop activated for devloop!

Plan: .devloop/plan.md
Tasks: X pending, Y completed
Max iterations: 50
Completion promise: ALL PLAN TASKS COMPLETE

The loop will continue until all tasks are marked [x].
Ralph's stop hook will feed this prompt back after each iteration.

Starting work on the next task...
```

## Step 5: Begin Continue Workflow

Now execute the continue workflow - work on the next pending task.

Read the plan:
```bash
cat .devloop/plan.md
```

Find the next `- [ ]` task and implement it directly.

After completing each task:
1. Mark it `[x]` in the plan
2. Check if all tasks complete with `check-plan-complete.sh`
3. If complete, output the promise tag

## When to Stop

The loop terminates when:
- All tasks marked `[x]` AND promise tag output
- Max iterations reached (safety)
- User runs `/cancel-ralph` (manual stop)

## Example Usage

```bash
# Basic usage - runs up to 50 iterations
/devloop:ralph

# Extended run for large plans
/devloop:ralph --max-iterations 100

# After running, you can check progress:
head -10 .claude/ralph-loop.local.md
```

## Notes

- Each iteration works on ONE task
- Context accumulates (no /clear between iterations)
- For very large plans, consider using `/devloop:fresh` pattern manually
- The promise tag MUST match exactly: `<promise>ALL PLAN TASKS COMPLETE</promise>`

---

**Now**: Verify prerequisites and start the automated loop.
