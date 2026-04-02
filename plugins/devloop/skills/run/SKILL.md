---
name: run
description: Execute plan tasks autonomously until completion
whenToUse: "Executing a prepared devloop plan autonomously"
whenNotToUse: "Initial planning, architectural exploration"
disable-model-invocation: true
argument-hint: "[--max-iterations N] [--interactive] [--next-issue]"
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

# Devloop Run

Execute plan tasks autonomously. **Do the work directly.**

## Step 1: Check Plan State
Run `check-plan-complete.sh .devloop/plan.md`.
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
**Optional**: Sync plan to native tasks with `sync-plan-to-tasks.sh`.

## Step 5: Execute Tasks
Read plan, find next `- [ ]` task. 
- Do work directly (Write/Edit/Bash). 
- Use agents ONLY for large exploration or security scans.
- Mark task `in_progress` via `TaskUpdate`.

## Step 6: Update Progress
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
