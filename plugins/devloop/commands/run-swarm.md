---
description: Execute plan tasks via fresh-context subagents (swarm mode)
argument-hint: "[--max-tasks N] [--dry-run]"
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

# Devloop Run Swarm - Fresh Context Task Execution

Execute plan tasks by delegating each to a fresh-context subagent. Each task gets a clean context window, eliminating the need for `/clear` + `/devloop:run` cycling.

**You are the orchestrator. Workers do the implementation.**

## When to Use

| Scenario | Use |
|----------|-----|
| Plan with 10+ tasks | `/devloop:run-swarm` (avoids context degradation) |
| Small plan (< 5 tasks) | `/devloop:run` (lower overhead) |
| Tasks need deep exploration | `/devloop:run` (workers can't nest agents) |
| Want to preview before executing | `/devloop:run-swarm --dry-run` |

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
  /devloop:plan --deep "topic"      - Explore before implementing
  /devloop:plan --from-issue 123   - Work from GitHub issue
  /devloop                          - Smart entry point
```

Then STOP.

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

Then STOP.

### If plan has pending tasks:

Continue to Step 2.

## Step 2: Parse Arguments

Check for flags in `$ARGUMENTS`:

- `--max-tasks N`: Maximum tasks to execute before stopping (default: all pending)
- `--dry-run`: Show what would be executed without running workers

Default behavior: execute all pending tasks sequentially.

### If `--dry-run`:

Read the plan, list each pending task with its phase, and display:

```
Dry run — tasks that would be executed:

Phase 1: [Phase Name]
  1. Task 1.1: [description]
  2. Task 1.2: [description]

Phase 2: [Phase Name]
  3. Task 2.1: [description]

Total: N tasks
Worker agent: devloop:swarm-worker
```

Then STOP.

## Step 3: Gather Project Context

Before the task loop, prepare shared context that all workers will need.

### Read project CLAUDE.md (if exists)

```bash
if [ -f "CLAUDE.md" ]; then head -100 CLAUDE.md; fi
```

Extract a concise conventions snippet (max 100 lines) focusing on:
- Code style and patterns
- Testing conventions
- File structure rules
- Key project-specific rules

Store this as `$PROJECT_CONTEXT` for injection into every worker prompt.

### Read plan overview

Read the plan's Overview and Considerations sections to provide workers with broader context about the work being done.

Store this as `$PLAN_CONTEXT`.

## Step 4: Task Execution Loop

Read the plan:

```bash
cat .devloop/plan.md
```

For each pending task (marked `- [ ]`), in order:

### 4a. Gather Task-Specific Context

Run the context gathering script to find relevant files:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/gather-task-context.sh" "[task description]"
```

If the script doesn't exist or returns empty, do a quick manual search:
- Grep for key terms from the task description
- Glob for likely file patterns mentioned in the task

Collect a focused list of relevant file paths (max 20 files).

### 4b. Build Worker Prompt

Construct the prompt for the swarm-worker agent:

```
You are executing a task from a devloop plan.

## Your Task
[Task description from plan.md, e.g., "Task 2.3: Add error handling to the API client"]

## Phase Context
Phase: [N] - [Phase Name]
Plan: [Plan title from plan.md header]
Previously completed in this phase:
- [x] Task N.1: [done task]
- [x] Task N.2: [done task]

## Project Conventions
[Concise excerpt from $PROJECT_CONTEXT — key rules and patterns only]

## Relevant Files
These files are likely involved (read them to understand context):
- path/to/file1.ts
- path/to/file2.ts
- path/to/test/file1.test.ts

## Plan Context
[Brief overview from $PLAN_CONTEXT — what this plan is about]

## Instructions
1. Read the relevant files to understand context
2. Implement the task as described
3. Run tests if applicable
4. Do NOT modify .devloop/plan.md
5. Do NOT run git commit
6. Return a summary of what you changed
```

### 4c. Spawn Worker

```
Task:
  description: "Execute task [N.M]: [brief]"
  subagent_type: "devloop:swarm-worker"
  prompt: [constructed prompt from 4b]
  max_turns: 25
```

Wait for the worker to return its summary.

### 4d. Verify and Record

After worker returns:

1. **Check what changed**:
   ```bash
   git diff --stat
   ```

2. **Display progress**:
   ```
   Task [N.M] complete ✓
   Worker summary: [brief from worker return]
   Files changed: [count]
   Progress: [done+1]/[total] ([pending-1] remaining)
   ```

3. **Mark task done in plan**:
   Update `.devloop/plan.md` — change `- [ ] Task N.M:` to `- [x] Task N.M:`

4. **Update native task status** (if synced):
   Mark current task completed, next task in-progress.

5. **Check if max-tasks reached**:
   If `--max-tasks N` was specified and we've completed N tasks, stop with:
   ```
   Reached max-tasks limit (N). Pausing.
   Progress: [done]/[total]
   Run /devloop:run-swarm to continue.
   ```

### 4e. Phase Boundary Check

Check local config for auto-commit:
```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/parse-local-config.sh" | grep -o '"auto_commit":[^,}]*' | cut -d: -f2
```

**If `auto_commit: true` and phase is complete** (next pending task is in a different phase):

```bash
git add -A
git commit -m "$(cat <<'EOF'
feat(devloop): complete Phase N - [phase description]
EOF
)"
```

Display: "Auto-committed Phase N completion"

## Step 5: Handle Completion

When all tasks are marked `[x]`:

```
All [total] tasks complete via swarm execution!

Workers spawned: [count]
Phases completed: [count]
```

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

**Routing:**
- "Ship it" → `/devloop:ship`
- "Archive" → Run archive script, then `/devloop`
- "Review first" → `/devloop:review`

## Step 6: Error Handling

If a worker reports failure or issues:

```yaml
AskUserQuestion:
  questions:
    - question: "Worker reported issues on Task [N.M]. How to proceed?"
      header: "Issue"
      multiSelect: false
      options:
        - label: "Retry task"
          description: "Spawn a new worker for the same task"
        - label: "Skip and continue"
          description: "Mark task as skipped, move to next"
        - label: "Stop"
          description: "Pause swarm for manual intervention"
        - label: "Fix inline"
          description: "You (orchestrator) fix it directly"
```

**Routing:**
- "Retry" → Rebuild prompt with worker's error context added, spawn new worker
- "Skip" → Mark task with `- [!]` in plan, continue
- "Stop" → Save progress, display status
- "Fix inline" → Orchestrator uses Read/Edit/Write directly to fix

## Comparison with /devloop:run

| Aspect | `/devloop:run` | `/devloop:run-swarm` |
|--------|---------------|---------------------|
| Context | Accumulates, degrades | Fresh per task |
| Need `/clear` | Every 5-10 tasks | Never |
| Explore agents | Available | Not available (no nesting) |
| CLAUDE.md | Auto-loaded | Injected per task |
| Per-task overhead | Low | Higher (agent spawn) |
| Best for | Small plans, exploration-heavy | Large plans, well-defined tasks |
| Error recovery | Inline | Worker retry or orchestrator fix |

## Example Usage

```bash
# Execute all pending tasks via swarm
/devloop:run-swarm

# Preview what would be executed
/devloop:run-swarm --dry-run

# Execute up to 5 tasks then pause
/devloop:run-swarm --max-tasks 5
```

---

**Now**: Check plan state and begin swarm execution.
