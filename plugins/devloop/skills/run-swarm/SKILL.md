---
name: run-swarm
description: Execute plan tasks via fresh-context subagents (swarm mode)
when_to_use: "Plan with 10+ tasks, large implementation efforts, avoiding context bloat"
argument-hint: "[--max-tasks N] [--dry-run] [--worktrees]"
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
- `--worktrees`: Run each worker with `isolation: "worktree"`. Each worker gets an isolated git worktree; the orchestrator merges results back after each batch. Off by default.

Also read the local config to detect `git.worktree_isolation`:
```
Bash: ${CLAUDE_PLUGIN_ROOT}/scripts/parse-local-config.sh
```
If `git.worktree_isolation` is `true` in the config, treat it as if `--worktrees` was passed.
The CLI flag always wins: `--worktrees` enables isolation regardless of config.

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
For a parallel batch, spawn all workers simultaneously (multiple Agent calls in a single message).

> **Prompt caching**: Static content (Instructions, Phase) goes FIRST -- it is identical across all workers in a batch and gets cached after the first spawn. Dynamic content (Task description, Context files) goes LAST -- it varies per worker and is not cached. This ordering maximizes cache hits when spawning multiple workers in a single batch.

**Without `--worktrees`** (default):
```yaml
Agent:
  subagent_type: "devloop:swarm-worker"  # or devloop:haiku-worker for [model:haiku]
  model: "haiku"  # or "sonnet" per annotation
  prompt: |
    Instructions: Implement the task below. Do NOT modify plan.md or commit.
    Phase: [phase name]
    [STATIC: shared project conventions from CLAUDE.md or plan Overview -- same for all workers]

    Task: [description]
    Context: [relevant files and conventions -- dynamic, task-specific]
```

**With `--worktrees`** (or `git.worktree_isolation: true` in local.md):
```yaml
Agent:
  subagent_type: "devloop:swarm-worker"  # or devloop:haiku-worker for [model:haiku]
  model: "haiku"  # or "sonnet" per annotation
  isolation: "worktree"
  prompt: |
    Instructions: Implement the task below. Do NOT modify plan.md or commit.
    Note: You are running inside an isolated git worktree. Use relative paths in your
    summary. Your changes will be merged back to the main branch by the orchestrator.
    Phase: [phase name]
    [STATIC: shared project conventions from CLAUDE.md or plan Overview -- same for all workers]

    Task: [description]
    Context: [relevant files and conventions -- dynamic, task-specific]
```

**After each batch completes in worktree mode**, perform merge-back (Step 4c).

### 4c. Merge-Back (Worktree Mode Only)

Skip this step if `--worktrees` was not used.

After all workers in a batch complete:
1. **Collect branch names**: Inspect each Agent result for a returned worktree branch name.
   - If the result contains a branch name → worker made changes, merge needed.
   - If no branch name in result → worker made no changes, worktree was auto-cleaned. Skip.
2. **Merge each branch** (sequentially, to minimize conflicts):
   ```bash
   git merge <worktree-branch> --no-commit --no-ff
   ```
   The `--no-commit` flag stages the merged changes without creating a commit,
   preserving the existing `auto_commit` flow.
3. **On conflict**: Do NOT auto-resolve. Run `git merge --abort` and surface to user:
   ```
   AskUserQuestion: "Merge conflict from worktree branch <branch>. Options:
   (a) Resolve manually and continue, (b) Skip this task's changes, (c) Stop swarm."
   ```
4. **After successful merge**: Delete the worktree branch:
   ```bash
   git branch -d <worktree-branch>
   ```
5. If no workers in the batch returned a branch (all made no changes), skip merge-back entirely.

### 4d. Record Progress
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
