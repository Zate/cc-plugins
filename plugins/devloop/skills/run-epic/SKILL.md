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
  - TaskCreate
  - TaskUpdate
  - TaskList
  - Skill
---

# Devloop Run Epic

Execute an epic phase-by-phase. Each phase runs in a fresh-context subagent to avoid context bloat. **You are the orchestrator -- stay lean, delegate execution.**

## Step 1: Load State

Read `.devloop/epic.json`.

- **No file**: "No epic found. Use `/devloop:epic <topic>` to create one." STOP.
- **`--status`**: Display phase tracker from epic.json and STOP.
- **`status: "complete"`**: "Epic already complete. All N phases done." STOP.
- **`--phase N`**: Override current phase (set `current_phase` to N, promote that phase).

Continue with the current phase from `epic.json`.

## Step 2: Validate Plan

Read `.devloop/plan.md`. Verify it matches the current phase:
- Check `**Phase**:` frontmatter matches `epic.json.current_phase`.
- If mismatch or no plan.md: run `${CLAUDE_PLUGIN_ROOT}/scripts/promote-phase.sh` to load the correct phase.
- If plan.md shows all tasks `[x]`: this phase was already completed -- skip to Step 5.

## Step 3: Execute Phase

Spawn a subagent to execute the current phase plan:

```yaml
Agent:
  model: "sonnet"
  description: "Execute epic phase N"
  prompt: |
    You are executing a devloop plan. Read .devloop/plan.md and execute all tasks.

    Rules:
    - Work through tasks in order, respecting [depends:N.M] constraints
    - For [parallel:A] groups, process them efficiently
    - Mark each task [x] in plan.md as you complete it
    - Run tests after implementation tasks to verify they pass
    - Do NOT commit -- the orchestrator handles commits
    - Do NOT modify .devloop/epic.json or .devloop/epic.md
    - If stuck on a task, mark it [!] with a note and continue

    Test command: {test_command from epic.json}

    When all tasks are done, report a summary of what was implemented.
```

Wait for the agent to complete. Read its result.

## Step 4: Validate Phase Completion

1. **Check plan.md**: Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh .devloop/plan.md`.
   - If incomplete: Report which tasks remain. **AskUserQuestion**: "Retry phase" (spawn new agent with error context) or "Skip remaining" (mark `[-]`).

2. **Run tests** (unless `--skip-tests`):
   - Read `test_command` from `epic.json`.
   - If set: Run it via Bash. If tests fail: Report failures. **AskUserQuestion**: "Fix and retry" or "Skip tests".
   - If null: Skip test validation.

3. **Commit the phase**:
   ```bash
   git add -A
   git commit -m "feat(epic-slug): phase N -- phase-name"
   ```
   Record the commit hash.

## Step 5: Update Epic State

1. Update `epic.json`:
   - Current phase: set `status` to `"complete"`, record `committed` hash.
   - Increment `current_phase`.
   - If all phases complete: set top-level `status` to `"complete"`.

2. Update `epic.md`:
   - Mark completed phase as `complete` in the Phase Tracker table.

3. **If all phases complete**: Report "Epic complete! All N phases done." **AskUserQuestion**: "Ship it" (invoke `/devloop:ship`) or "Review". STOP.

## Step 6: Promote Next Phase

Run `${CLAUDE_PLUGIN_ROOT}/scripts/promote-phase.sh --force` to load the next phase into plan.md.

Report:
```
Phase N complete (committed: abc1234)
Phase M loaded: "Phase Name" (X tasks)

Ready for next phase.
```

## Step 7: Pause Point

**AskUserQuestion**:
- **Continue**: Loop back to Step 3 (fresh subagent, same orchestrator context).
- **Clear and continue**: "Run /clear, then /devloop:run-epic to resume." STOP.

This is the natural pause point. The orchestrator context is still lean (only state tracking), but if the user has been reviewing output or context feels heavy, clearing is safe -- epic.json preserves all state.

---

## Error Recovery

`run-epic` is resumable at any point:
- **Mid-phase crash**: plan.md has partial progress. Re-running spawns a new agent that picks up from remaining `[ ]` tasks.
- **Post-phase, pre-commit**: Changes are on disk but not committed. Re-running detects plan complete, goes straight to Step 4.
- **Post-commit, pre-promote**: epic.json shows phase complete but current_phase not incremented. Re-running detects and promotes.
- **After /clear**: epic.json is the source of truth. Re-running reads it and resumes from the correct phase.

---
**Now**: Load epic state and begin.
