---
name: run-swarm
description: Execute plan tasks via fresh-context subagents (swarm mode)
when_to_use: "Plan with 10+ tasks, large implementation efforts, avoiding context bloat"
disable-model-invocation: true
argument-hint: "[--max-tasks N] [--dry-run]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - Agent
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - TaskList
  - Skill
---

# Devloop Run Swarm

Execute plan tasks via fresh-context subagents. **You are the orchestrator.**

## Step 1: Check Plan State
Run `check-plan-complete.sh .devloop/plan.md`.
- **No plan**: Show entry points (`/devloop:plan`) and STOP.
- **Complete**: **AskUserQuestion**: Ship it, Archive, or Review. STOP.
- **Pending**: Continue to Step 2.

## Step 2: Parse Arguments
- `--max-tasks N`: Max tasks before pausing.
- `--dry-run`: List pending tasks and STOP.

## Step 3: Gather Shared Context
Extract max 100 lines from `CLAUDE.md` (code style, patterns) and plan's Overview/Considerations. Store as shared context.

## Step 4: Task Execution Loop
For each `- [ ]` task in `plan.md`:

### 4a. Gather Task Context
Run `gather-task-context.sh` or search (Grep/Glob) for relevant files (max 20).

### 4b. Spawn Worker Agent
Construct worker prompt:
- **Task**: [Description]
- **Context**: Phase, Plan info, Shared Project Conventions.
- **Resources**: Relevant file list.
- **Instructions**: Read files, implement, test, summary return. NO plan edits or commits.

**Spawn**:
```yaml
Agent:
  subagent_type: "devloop:swarm-worker"
  prompt: [Constructed prompt]
```

### 4c. Record Progress
1. Display `git diff --stat` and worker summary.
2. Mark task `[x]` in `plan.md` and update native task.
3. If `auto_commit: true` and phase complete, commit changes.
4. Pause if `--max-tasks` reached.

## Step 5: Finalize
When all `[x]`, **AskUserQuestion**: Ship it, Archive, or Review.

## Step 6: Error Handling
If worker fails, **AskUserQuestion**:
- **Retry**: New worker with error context.
- **Skip**: Mark `[!]`, continue.
- **Stop**: Pause for intervention.
- **Fix inline**: You fix it directly.

---
**Now**: Check plan state and begin swarm.
