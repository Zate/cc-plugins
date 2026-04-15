---
name: run
description: Execute plan tasks autonomously until completion
when_to_use: "Executing a prepared devloop plan autonomously"
argument-hint: "[--max-iterations N] [--interactive] [--next-issue]"
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

# Devloop Run

Execute plan tasks autonomously. **Do the work directly.**

**Bash hygiene**: prefer quiet flags to minimize output (`npm install --silent`, `git status -sb`, pipe long output through `| tail -n 20`).

**Monitor for long commands**: Use Monitor (not Bash) for test suites, builds, and full-codebase linting to stream output in real-time. Use Bash for all short commands (git ops, ls, devloop scripts).

Long-running commands that warrant Monitor:
- Test suites: `npm test`, `pytest`, `go test ./...`, `cargo test`, `make test`, `jest`, `vitest`, `mocha`
- Builds: `npm run build`, `make`, `cargo build`, `go build`, `tsc`, `webpack`, `vite build`, `gradle`, `mvn`
- Full-codebase linting: `eslint .`, `ruff check .`, `pylint src/`, `golangci-lint run`

Monitor pattern (always include failure patterns in the filter):
```
Monitor({ description: "test run", command: "npm test 2>&1 | grep --line-buffered -E 'PASS|FAIL|Error|passed|failed'", timeout_ms: 300000, persistent: false })
```
Fallback: if Monitor errors or is unavailable, use Bash directly.

## Step 1: Check Plan State
Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh .devloop/plan.md`.
- **No plan**: Show entry points (`/devloop:plan`) and STOP.
- **Complete**: **AskUserQuestion**: Ship it, Archive, or Review. STOP.
- **Pending**: Continue to Step 2.

## Step 2: Parse Arguments
- `--max-iterations N`: Default 50.
- `--interactive`: Prompt at each task.
- `--next-issue`: Jump to Step 2b (Issue-to-ship workflow).

## Step 2b: Next Issue Workflow
1. Check for incomplete plan (prompt to replace).
2. Fetch with `gh issue list`.
3. Prioritize: bug/critical > security > feat > oldest.
4. Select issue, create `.devloop/plan.md` with required frontmatter (title, issue, url, status).
5. Post-completion: Validate (tests/lint) and commit with `Closes #N`.

## Step 3: Resume State
If `.devloop/next-action.json` exists, load and resume.

## Step 4: Setup Execution
Unless `--interactive`, create `.claude/ralph-loop.local.md` with iteration limits and completion promise: `<promise>ALL PLAN TASKS COMPLETE</promise>`.
**Optional**: Sync plan to native tasks with `${CLAUDE_PLUGIN_ROOT}/scripts/sync-plan-to-tasks.sh`.

## Step 5: Execute Tasks
Read plan, find all `- [ ]` tasks.

### 5a. Detect Parallel Groups
Scan pending tasks for `[parallel:X]` markers. If multiple pending tasks share the same group letter, they can run concurrently.

### 5b. Model Selection Per Task
Parse the `[model:X]` annotation from each task line:
- **`[model:haiku]`**: Spawn Agent with `model: "haiku"` — use for simple/mechanical tasks
- **`[model:sonnet]`**: Spawn Agent with `model: "sonnet"` — use for complex reasoning tasks
- **No annotation**: Do the work inline — no agent spawn needed

### 5c. Execute (Parallel or Sequential)
**For parallel groups**: Spawn one Agent per task in the group simultaneously (multiple Agent calls in a single message). Each agent receives the task description, phase context, and relevant files.

**For sequential tasks** (no parallel marker, or all group members not yet pending): Process one at a time.

Agent spawn pattern:
```yaml
Agent:
  model: "haiku"  # or "sonnet" per [model:X] annotation
  prompt: |
    Task: [description]
    Phase: [phase name]
    Context: [relevant files and conventions]
    Instructions: Implement this task. Do NOT modify plan.md or commit.
```

### 5d. Update Progress
1. Mark task `[x]` in `plan.md`.
2. Update native task to `completed`.
3. Check overall completion.
- **All complete**: Output `<promise>ALL PLAN TASKS COMPLETE</promise>`.
- **Tasks remain**: Continue (Autonomous) or Prompt (Interactive).
- **Checkpoints**: If `auto_commit: true`, commit at phase boundaries.

## Step 7: Finalize
**AskUserQuestion**: Ship it, Archive, or Review.

---
**Now**: Check plan state and begin.
