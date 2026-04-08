---
name: promote
description: Promote the next epic phase to plan.md -- autonomous phase cycle
argument-hint: "[--skip] [--status]"
when_to_use: "Completing an epic phase and promoting the next one, checking epic progress"
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
  - TaskCreate
  - TaskUpdate
  - TaskList
---

# Devloop Promote

Autonomous epic phase cycle: verify, commit, promote, run. **Do the work directly.**

**Bash hygiene**: prefer quiet flags to minimize output.

## Step 1: Check State
Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-epic-state.sh`.

- **No epic**: "No epic found. Use `/devloop:epic` to create one." STOP.
- **`--status`**: Display phase tracker table and current progress. STOP.
- **All complete**: Go to Step 5 (Epic Complete).
- **Otherwise**: Go to Step 2.

## Step 2: Determine Action
Read `.devloop/plan.md` and `.devloop/epic.md`.

### Case A: Plan complete (all tasks `[x]`)
1. Run project tests (detect from package.json/Makefile/go.mod):
   - If tests fail: Report failures. **AskUserQuestion**: "Fix and retry" or "Skip tests".
   - If tests pass: Continue.
2. Commit the work with conventional message: `feat(epic-slug): complete phase N -- phase-name`.
3. Go to Step 3 (Update Epic).

### Case B: Plan in-progress (some tasks pending)
Report: "Phase N: X/Y tasks complete."
**AskUserQuestion**:
- **Continue**: Invoke Skill `devloop:run` to resume. When done, loop back to Case A.
- **Skip remaining**: Mark remaining tasks `[-]` (skipped). Go to Case A.
- **View status**: Show task breakdown.

### Case C: No active plan (plan.md missing/empty, epic has pending phases)
Go to Step 3 directly (promote next phase).

## Step 3: Update Epic Tracker
1. Mark completed phase as `complete` in the epic.md Phase Tracker table.
2. Update `**Updated**` timestamp.
3. Update `**Current Phase**` to next phase number.

## Step 4: Promote Next Phase
Run `${CLAUDE_PLUGIN_ROOT}/scripts/promote-phase.sh --force`.
- **Success**: Report "Phase N complete and committed. Phase M loaded."
  **AskUserQuestion**:
  - **Run now**: Invoke Skill `devloop:run`.
  - **Stop here**: "Ready for `/clear` then `/devloop:run`."
- **No pending phases**: Go to Step 5.

## Step 5: Epic Complete
Report: "Epic complete! All N phases done."
**AskUserQuestion**:
- **Ship it**: Invoke Skill `devloop:ship`.
- **Review**: Show summary of all completed phases.
- **Archive**: Move epic.md to `.devloop/archive/`.

---
**Now**: Check epic state and begin.
