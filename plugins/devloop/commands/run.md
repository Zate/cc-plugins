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
- `--next-issue`: Fetch next GitHub issue, create plan, then run autonomously
- `--next-issue=auto`: Same as above but skip issue selection confirmation

Default behavior is **autonomous** (no `--interactive` flag).

### If `--next-issue` flag detected:

Jump to **Step 2b: Next Issue Workflow** instead of continuing to Step 3.

## Step 2b: Next Issue Workflow

When `--next-issue` is specified, orchestrate a complete issue-to-ship workflow:

### 1. Check for existing incomplete plan

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md
```

If plan exists and is incomplete, prompt:
```yaml
AskUserQuestion:
  questions:
    - question: "Existing plan has N pending tasks. Replace with next issue?"
      header: "Conflict"
      multiSelect: false
      options:
        - label: "Replace"
          description: "Overwrite and start from next issue"
        - label: "Cancel"
          description: "Keep existing plan, exit --next-issue mode"
```

### 2. Fetch open issues

```bash
gh issue list --state open --limit 20 --json number,title,labels,createdAt
```

**If no open issues:**
```
No open issues found.

Create issues at: gh issue create
Or start work with: /devloop:plan "your feature"
```
Then STOP.

### 3. Prioritize issues

Apply prioritization logic:

| Priority | Criteria |
|----------|----------|
| 1 (highest) | Label contains "bug", "critical", "urgent" |
| 2 | Label contains "security" |
| 3 | Label contains "feat", "feature", "enhancement" |
| 4 | Oldest issues (by createdAt) |
| 5 (lowest) | Everything else |

Select the highest priority issue.

### 4. Confirm or auto-select

**If `--next-issue` (no =auto):**
```yaml
AskUserQuestion:
  questions:
    - question: "Selected Issue #N: [title]. Work on this?"
      header: "Issue"
      multiSelect: false
      options:
        - label: "Yes, start work"
          description: "Create plan and begin"
        - label: "Pick different"
          description: "Show all issues"
        - label: "Cancel"
          description: "Exit"
```

**If `--next-issue=auto`:**
Display: "Auto-selected Issue #N: [title]"
Proceed without confirmation.

### 5. Create plan from issue

Fetch issue details and create plan:
```bash
gh issue view $ISSUE_NUMBER --json number,title,body,labels,url
```

Generate plan at `.devloop/plan.md` with this **required frontmatter**:

```yaml
---
title: [Issue title]
issue: [ISSUE_NUMBER]           # REQUIRED - used for auto-close
issue_url: [Full GitHub URL]    # For reference
status: In Progress
created: [ISO date]
---
```

**CRITICAL**: The `issue:` field is MANDATORY when creating from `--next-issue`. Without it, the auto-close workflow in Step 2b.7 will fail.

Then generate:
- Tasks derived from issue description
- Standard plan structure (phases, tasks, progress log)

Display: "Plan created from Issue #N"

### 6. Continue to normal execution

After plan is created, continue to Step 3 (Fresh Start State check) and proceed with normal autonomous execution.

### 7. Post-completion: Validate and ship

When all tasks complete (before Step 7's AskUserQuestion):

**Run validation:**
```bash
# Detect and run tests
if [ -f "package.json" ]; then npm test; fi
if [ -f "go.mod" ]; then go test ./...; fi
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then pytest; fi

# Detect and run lint
if [ -f "package.json" ] && grep -q '"lint"' package.json; then npm run lint; fi
if [ -f "go.mod" ]; then golangci-lint run 2>/dev/null || go vet ./...; fi
if [ -f "pyproject.toml" ]; then ruff check . 2>/dev/null || flake8 . 2>/dev/null; fi

# Detect and run build
if [ -f "package.json" ] && grep -q '"build"' package.json; then npm run build; fi
if [ -f "go.mod" ]; then go build ./...; fi
```

**If validation fails:**
```yaml
AskUserQuestion:
  questions:
    - question: "Validation failed. How to proceed?"
      header: "Validation"
      multiSelect: false
      options:
        - label: "Fix issues"
          description: "Attempt to fix failing tests"
        - label: "Ship anyway"
          description: "Commit despite failures"
        - label: "Stop"
          description: "Pause for manual intervention"
```

**If validation passes (or skipped):**

**IMPORTANT: In `--next-issue` mode, the commit MUST close the issue.**

1. Read the issue number from `.devloop/plan.md` frontmatter (`issue: N`)
2. Stage and commit with closing keyword:

```bash
git add -A
git commit -m "$(cat <<'EOF'
feat(scope): summary of changes

Closes #${ISSUE_NUMBER}
EOF
)"
```

**The `Closes #N` line is MANDATORY in `--next-issue` mode** - do not ask, do not check config. The purpose of `--next-issue` is to work on an issue and close it. If the commit doesn't include the closing keyword, the issue won't close and the workflow fails.

After successful commit, display:
```
Committed with: Closes #N
Issue #N will be closed when pushed/merged.
```

Then offer next actions (push, create PR, etc.).

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

**Large Plans (50+ tasks)**: For plans with many tasks, consider creating native tasks only for the current phase to avoid cluttering the `/tasks` view. Recreate tasks for the next phase when a phase completes.

**Session Resume**: When resuming after `/clear` or a new session, run the sync script again to recreate native tasks from plan.md pending items. Already-completed tasks in plan.md are not recreated.

**Task Marker Mapping**:

| plan.md | Native Task Status |
|---------|-------------------|
| `- [ ]` | pending |
| `- [~]` | in_progress |
| `- [x]` | completed |
| `- [!]` | blocked (use blockedBy) |

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

### Before Starting Each Task

If native tasks were created in Step 4b, mark the current task as in-progress:

```
TaskUpdate: taskId=[task-id], status="in_progress"
```

This shows a progress spinner in the UI while you work on the task.

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

# Auto-select next issue, plan, run, validate, and ship
/devloop:run --next-issue

# Fully autonomous: no confirmation prompts
/devloop:run --next-issue=auto

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
