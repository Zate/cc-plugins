---
name: run-swarm
description: Execute plan tasks via fresh-context subagents (swarm mode)
when_to_use: "Plan with 10+ tasks, large implementation efforts, avoiding context bloat"
argument-hint: "[--max-tasks N] [--dry-run]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - Monitor
  - Agent
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - TaskList
  - Skill
---

# Devloop Run Swarm

Execute plan tasks via fresh-context subagents. **You are the orchestrator.**

**Bash hygiene**: prefer quiet flags to minimize output (`npm install --silent`, `git status -sb`, pipe long output through `| tail -n 20`).

**Monitor for validation commands**: When the orchestrator runs test or build commands to validate phase completion, use Monitor for real-time streaming. Worker agents (swarm-worker, haiku-worker) also have Monitor available and should use it for long-running commands within their tasks.

Long-running commands that warrant Monitor: test suites (`npm test`, `pytest`, `go test ./...`, `cargo test`, `make test`), builds (`npm run build`, `make`, `cargo build`, `tsc`), and full-codebase linting (`eslint .`, `ruff check .`, `golangci-lint run`).

Orchestrator validation example:
```
Monitor({ description: "swarm validation tests", command: "npm test 2>&1 | grep --line-buffered -E 'PASS|FAIL|Error|passed|failed'", timeout_ms: 300000, persistent: false })
```
Fallback: if Monitor errors, use Bash directly.

## Step 1: Check Plan State
Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh .devloop/plan.md`.
- **No plan**: Show entry points (`/devloop:plan`) and STOP.
- **Complete**: **AskUserQuestion**: Ship it, Archive, or Review. STOP.
- **Pending**: Continue to Step 2.

## Step 2: Parse Arguments
- `--max-tasks N`: Max tasks before pausing.
- `--dry-run`: List pending tasks and STOP.

## Step 3: Gather Shared Context
Extract max 100 lines from `CLAUDE.md` (code style, patterns) and plan's Overview/Considerations. Store as shared context.

## Step 4: Task Execution Loop

### 4a. Build Execution Plan
Read all `- [ ]` tasks from plan.md. Group them:
1. **Parallel groups**: Tasks sharing `[parallel:X]` markers → batch together
2. **Dependent tasks**: Tasks with `[depends:N.M]` → schedule after dependency completes
3. **Sequential tasks**: Everything else → run in order

### 4b. For Each Batch (Parallel Group or Single Task)

#### Gather Context
Run `${CLAUDE_PLUGIN_ROOT}/scripts/gather-task-context.sh` or Grep/Glob for relevant files (max 20 per task).

#### Select Model by Hint
Parse `[model:X]` from the task line:
- **`[model:haiku]`**: Spawn with `model: "haiku"`
- **`[model:sonnet]`** or **no annotation**: Spawn with `model: "sonnet"` (default)

#### Spawn Workers
For a parallel batch, spawn all workers simultaneously (multiple Agent calls in a single message):
```yaml
Agent:
  subagent_type: "devloop:swarm-worker"  # or devloop:haiku-worker for [model:haiku]
  model: "haiku"  # or "sonnet" per annotation
  prompt: |
    Task: [description]
    Phase: [phase name]
    Context: [relevant files and conventions]
    Instructions: Implement this task. Do NOT modify plan.md or commit.
```

### 4c. Record Progress
1. Display `git diff --stat` and worker summary for each completed task.
2. Mark task `[x]` in `plan.md` and update native task.
3. If `auto_commit: true` and phase complete, commit changes.
4. Pause if `--max-tasks` reached.
5. Check `[depends:N.M]` — if a just-completed task unblocks dependent tasks, add them to the next batch.

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
