---
name: run-epic
description: Execute an epic plan phase-by-phase using fresh-context subagents
argument-hint: "[--status] [--skip-tests] [--phase N]"
when_to_use: "Running a multi-phase epic created by /devloop:epic"
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
  - Skill
---

# Devloop Run Epic

Execute an epic phase-by-phase. Each phase runs in a fresh-context subagent. **You are the orchestrator -- stay lean, delegate execution.**

## Step 1: Load State

Read `.devloop/epic.json`.

- **No file**: "No epic found. Use `/devloop:epic <topic>` to create one." STOP.
- **`--status`**: Display phase tracker and STOP.
- **`status: "complete"`**: "Epic already complete." STOP.
- **`--phase N`**: Override current phase and re-promote.

## Step 2: Validate Plan

Read `.devloop/plan.md`. Verify `**Phase**:` matches `epic.json.current_phase`.
- Mismatch or missing: run `${CLAUDE_PLUGIN_ROOT}/scripts/promote-phase.sh --force`.
- All tasks `[x]`: skip to Step 5 (already completed).

## Step 3: Execute Phase

Read `epic.json` for context (user_stories, invariants, negative_cases, test_command). Spawn a subagent:

```yaml
Agent:
  model: "sonnet"
  description: "Execute epic phase N"
  prompt: |
    Execute the devloop plan in .devloop/plan.md.
    Work through all tasks, respecting [depends:N.M] constraints.
    Mark tasks [x] as you complete them.
    Run tests after implementation tasks: {test_command}
    Do NOT commit or modify epic.json/epic.md.

    Context from the epic:
    - User stories: {user_stories}
    - Invariants: {invariants}
    - Negative cases: {negative_cases}
```

## Step 4: Validate Completion

1. Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh .devloop/plan.md`.
   - Incomplete: **AskUserQuestion**: "Retry" or "Skip remaining".

2. Run tests (unless `--skip-tests` or `test_command` is null).
   - Fail: **AskUserQuestion**: "Fix and retry" or "Skip tests".

## Step 5: Commit & Advance

1. Commit: `git add` changed files, commit with `feat: phase N -- phase-name`.
2. Update `epic.json`: mark phase `"complete"`, record commit hash, increment `current_phase`.
3. Update `epic.md` Phase Tracker table.
4. If all phases complete: Report done. **AskUserQuestion**: "Ship it" or "Review". STOP.
5. Promote next phase: run `${CLAUDE_PLUGIN_ROOT}/scripts/promote-phase.sh --force`.

Report:
```
Phase N complete and committed.
Phase M loaded: "Phase Name" (X tasks)
```

## Step 6: Pause Point

The next phase is already loaded in plan.md. **AskUserQuestion**:
- **Continue now**: Loop to Step 3 (fresh subagent, same session).
- **Clear and run**: "Run `/clear`, then `/devloop:run-epic` to execute Phase M." STOP.

## Recovery

`run-epic` is resumable. `epic.json` is the source of truth:
- Mid-phase: plan.md has partial progress, new agent picks up remaining tasks.
- Post-phase: detects plan complete, skips to validation.
- After `/clear`: reads epic.json, resumes from correct phase.

If the repo is in a broken state (e.g. orphaned changes, mismatched plan), run-epic will detect the mismatch in Step 2 and re-promote the correct phase. Tests in Step 4 catch implementation issues before committing.

---
**Now**: Load epic state and begin.
