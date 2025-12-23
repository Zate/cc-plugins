---
name: task-checkpoint
description: Complete checklist and verification for task completion in devloop workflows with mandatory worklog sync. Use after completing implementation, before marking tasks complete, when /devloop:continue finishes a task, or before moving to the next task in a phase.
---

# Task Checkpoint Skill

Complete checklist and verification for task completion in devloop workflows with mandatory worklog synchronization.

## When to Use This Skill

Use this skill:
- After completing implementation of a task from the devloop plan
- Before marking a task as `[x]` complete
- When `/devloop:continue` finishes executing a task
- Before moving to the next task in a phase

## When NOT to Use This Skill

- Quick one-off fixes not tracked in a plan
- Exploratory work or spikes (use `/devloop:spike` instead)
- When explicitly told to skip checkpoints

---

## Worklog Sync Requirements

**CRITICAL**: Every task completion MUST update the worklog to maintain an accurate history of work.

### When Worklog Sync is Mandatory

| Trigger | Action |
|---------|--------|
| Task completed (marked `[x]`) | Add pending entry to worklog |
| Commit created | Update worklog entry with commit hash |
| Session ends | Reconcile all pending entries |
| Phase completes | Group phase commits in worklog |

### Worklog Entry States

**Pending (Uncommitted)**:
```markdown
- [ ] Task X.Y: [Description] (pending)
```

**Committed**:
```markdown
- [x] Task X.Y: [Description] (abc1234)
```

**Grouped Commit**:
```markdown
- [x] Task X.Y: [Description] (abc1234)
- [x] Task X.Z: [Description] (abc1234)
```

### Enforcement Modes

**Advisory Mode**:
- Warns if worklog not updated after task completion
- Allows override with user confirmation
- Prompts at session end to reconcile pending entries

**Strict Mode**:
- Blocks proceeding to next task if worklog not updated
- Requires reconciliation before session end
- Fails commits if worklog is out of sync

**See `Skill: worklog-management` for detailed format and update rules.**

---

## Task Completion Checklist

**Before marking a task complete, verify ALL applicable items:**

### 1. Implementation Verification
- [ ] Code changes implement the task requirements
- [ ] No placeholder code or TODOs left incomplete
- [ ] Error handling is in place
- [ ] Code follows project conventions (check CLAUDE.md)

### 2. Testing Verification
- [ ] Existing tests still pass
- [ ] New tests added for new functionality (if applicable)
- [ ] Manual verification performed if no automated tests
- [ ] Edge cases considered

### 3. Plan Update
**REQUIRED** - Update `.devloop/plan.md`:
- [ ] Mark task as complete: `- [ ]` → `- [x]`
- [ ] Add Progress Log entry with timestamp and summary
- [ ] Update the `**Updated**:` timestamp
- [ ] If last task in phase, update `**Current Phase**:`

**Progress Log Entry Format:**
```markdown
- YYYY-MM-DD HH:MM: Completed Task X.Y - [brief summary of what was done]
```

### 4. Worklog Checkpoint
**REQUIRED** - Update `.devloop/worklog.md`:
- [ ] Create or read worklog file (if first task)
- [ ] Add task entry in "pending" state
- [ ] Update "Last Updated" timestamp
- [ ] If task is part of a grouped commit, note sibling tasks

**Worklog Entry Format (Pending)**:
```markdown
- [ ] Task X.Y: [Description] (pending)
```

**Note**: Entry will be updated with commit hash after Step 6a.

### 5. Commit Decision
Determine whether to commit now or group with related tasks:

**Commit NOW if:**
- Task is self-contained and reviewable
- Single logical change
- Changes are < 300 lines
- Unrelated to the next task

**Group with next task if:**
- Next task is tightly coupled (e.g., API + its tests)
- Combined changes form a more coherent unit
- Both tasks together are still < 500 lines

**See `Skill: atomic-commits` for detailed guidance.**

---

## Checkpoint Workflow

### Step 1: Verify Implementation
```
Before proceeding:
1. Review the changes made
2. Confirm task requirements are met
3. Run any relevant tests
```

### Step 2: Update Plan File
```
Read .devloop/plan.md
Find the task that was just completed
Mark it [x] and add Progress Log entry
Write the updated plan
```

### Step 3: Mandatory Worklog Checkpoint
```
Read or create .devloop/worklog.md
Add task entry in pending state:
  - [ ] Task X.Y: [Description] (pending)
Update "Last Updated" timestamp
Write the updated worklog
```

**Enforcement Check**:
```
Read .devloop/local.md for enforcement mode

If enforcement: strict
  - Verify worklog entry exists
  - Block if not found

If enforcement: advisory (default)
  - Verify worklog entry exists
  - Warn if not found, offer to create
```

### Step 4: Check for Parallel Siblings

**Before committing, check if there are parallel tasks that should complete together:**

```
Read .devloop/plan.md
Find tasks with same [parallel:X] marker as completed task
Check if any are still pending or in-progress
```

**If parallel siblings exist:**
```
Use AskUserQuestion:
- question: "Task X.Y is complete. There are [N] other tasks in parallel group [X]. How proceed?"
- header: "Parallel"
- options:
  - Wait for group (Continue working on parallel tasks before commit)
  - Commit now (Commit this task independently)
  - Spawn parallel (Launch agents for remaining group tasks)
```

**If all parallel tasks complete:**
- Consider committing them together as a logical unit
- Use format: `feat(scope): implement [feature] - Tasks X.Y, X.Z`

### Step 5: Commit Decision
```
Use AskUserQuestion:
- question: "Task complete. How should we handle the commit?"
- header: "Commit"
- options:
  - Commit now (Create atomic commit for this task)
  - Group with next (Continue, commit after related tasks)
  - Review changes first (Show diff before deciding)
```

### Step 6: Execute Commit (if committing now)
```
If committing:
1. Launch git-manager agent with task context
2. Generate conventional commit message
3. Include task reference: "feat(scope): description - Task X.Y"
4. After commit, update Progress Log with commit hash
5. Update worklog with committed tasks (see Step 6a)
```

### Step 6a: Update Worklog with Commit Hash
```
After successful commit:
1. Read .devloop/worklog.md
2. Find pending task entry: - [ ] Task X.Y: [Description] (pending)
3. Update to committed state:
   - [ ] Task X.Y: [Description] (pending)
   → - [x] Task X.Y: [Description] (abc1234)
4. Add entry to commit table:
   | abc1234 | 2024-12-23 14:30 | feat(scope): description - Task X.Y | X.Y |
5. Update "Last Updated" timestamp
```

**Worklog Entry Format Examples**:

**Single Task Commit**:
```markdown
### Commits
| Hash | Date | Message | Tasks |
|------|------|---------|-------|
| abc1234 | 2024-12-23 14:30 | feat(auth): add JWT tokens - Task 2.1 | 2.1 |

### Tasks Completed
- [x] Task 2.1: Implement JWT token generation (abc1234)
```

**Grouped Task Commit**:
```markdown
### Commits
| Hash | Date | Message | Tasks |
|------|------|---------|-------|
| def5678 | 2024-12-23 16:00 | feat(auth): complete auth flow - Tasks 2.1, 2.2 | 2.1, 2.2 |

### Tasks Completed
- [x] Task 2.1: Implement JWT token generation (def5678)
- [x] Task 2.2: Add token validation (def5678)
```

**Pending Tasks (Not Yet Committed)**:
```markdown
### Tasks Completed
- [x] Task 3.1: Create user model (ghi9012)
- [ ] Task 3.2: Add validation (pending)  ← Not committed yet
```

**See `Skill: worklog-management` for detailed format and update rules.**

### Step 7: Enforcement Check
```
Read .devloop/local.md for enforcement setting

If enforcement: strict:
  - Verify plan was actually updated
  - Block if not updated

If enforcement: advisory (default):
  - Warn if plan not updated
  - Allow override with user confirmation
```

---

## Commit Message Format

When committing a task, include the task reference:

```
<type>(<scope>): <description> - Task X.Y

<body explaining what was implemented>

<footer with refs if applicable>
```

**Examples:**
```
feat(auth): implement JWT token generation - Task 2.1

Added JWT token generation with RS256 signing.
Includes token refresh and expiration handling.

Refs: #42
```

```
test(auth): add unit tests for token service - Task 2.2

Tests cover token generation, validation, and refresh flows.
```

---

## Progress Log Update Format

After task completion (and optionally after commit), update the Progress Log:

```markdown
## Progress Log
- 2024-12-13 10:30: Completed Task 2.1 - Implemented JWT token generation
- 2024-12-13 10:35: Committed Task 2.1 - abc1234
- 2024-12-13 11:00: Completed Task 2.2 - Added auth unit tests
- 2024-12-13 11:05: Committed Tasks 2.1-2.2 - def5678 (grouped)
```

---

## Grouped Commits

When grouping tasks into a single commit:

1. **Track pending tasks**: Note which tasks are awaiting commit
2. **Commit at natural boundaries**: Phase end, related tasks complete, or user request
3. **List all tasks in commit message**:
   ```
   feat(auth): implement authentication flow - Tasks 2.1, 2.2

   - Task 2.1: JWT token generation
   - Task 2.2: Token service unit tests
   ```
4. **Update Progress Log for all tasks** with the shared commit hash

---

## Enforcement Modes

### Advisory Mode (Default)

If plan update is missing:
```
⚠️ Warning: Plan file not updated for completed task.

The task appears complete but .devloop/plan.md
was not updated. This may cause sync issues.

Would you like to:
- Update now (Update the plan file)
- Continue anyway (Skip plan update)
- Review task (Verify completion status)
```

### Strict Mode

If plan update is missing:
```
🛑 Blocked: Plan update required.

Strict enforcement is enabled. Cannot proceed to next task
until .devloop/plan.md is updated.

Required actions:
1. Mark Task X.Y as [x] complete
2. Add Progress Log entry

Run the plan update now.
```

---

## Session End Reconciliation

At the end of a development session, reconcile pending worklog entries to ensure accurate history.

### Reconciliation Checklist

**Before ending session** (via `/devloop:continue` stop, `/devloop:fresh`, or manual exit):

1. **Check for pending entries**:
```bash
# Count pending tasks in worklog
grep "^- \[ \].*pending" .devloop/worklog.md
```

2. **Decide on pending tasks**:
   - **Commit now**: Create commit for uncommitted work
   - **Keep pending**: Leave marked as pending for next session
   - **Discard**: Remove from worklog if work was reverted

3. **Update worklog**:
   - If committing: Follow Step 6a (update with commit hash)
   - If keeping pending: Add note to Progress Log
   - If discarding: Remove entry and note in Progress Log

### Reconciliation Triggers

| Trigger | Action |
|---------|--------|
| User runs `/devloop:fresh` | Prompt to reconcile before saving state |
| User runs `/devloop:continue` with "Stop here" | Prompt to reconcile before summary |
| Session timeout detected | Auto-prompt on next session start |
| Enforcement: strict enabled | Block session end until reconciled |

### Reconciliation Workflow

```
1. Detect pending tasks in worklog
2. Show list to user with AskUserQuestion
3. For each pending task:
   - User selects: Commit / Keep / Discard
4. Update worklog based on decisions
5. Generate session summary with reconciliation notes
```

**Example Reconciliation Question**:
```yaml
AskUserQuestion:
  question: "3 tasks pending in worklog. Reconcile before ending?"
  header: "Worklog"
  options:
    - Commit all (Create grouped commit for pending tasks)
    - Review individually (Decide per task)
    - Keep pending (Leave for next session)
    - Discard (Remove from worklog)
```

### Enforcement Behavior

**Advisory Mode**:
```
⚠️ Warning: 3 pending tasks in worklog.

These tasks are marked complete in the plan but not committed:
- Task 3.2: Add validation
- Task 3.3: Write tests
- Task 3.4: Update docs

Would you like to:
- Commit now (Create grouped commit)
- Keep pending (Continue in next session)
- Review (Decide per task)
```

**Strict Mode**:
```
🛑 Blocked: Worklog reconciliation required.

Strict enforcement is enabled. Cannot end session
until all pending tasks are committed or discarded.

Pending tasks: 3
- Task 3.2: Add validation
- Task 3.3: Write tests
- Task 3.4: Update docs

Action: Create commit or discard pending work.
```

### Integration with Fresh Start

When using `/devloop:fresh`, reconciliation happens BEFORE saving state:

```
1. User runs /devloop:fresh
2. Detect pending worklog entries
3. Prompt reconciliation (if any pending)
4. After reconciliation, save state to next-action.json
5. User runs /clear
6. Next session: worklog is clean, no pending entries
```

This ensures the worklog is always in a consistent state across sessions.

---

## Integration Points

This skill is invoked by:
- `/devloop:continue` - After each task execution
- `/devloop` - After implementation phase tasks
- Agents implementing plan tasks

This skill references:
- `Skill: plan-management` - Plan file format and location
- `Skill: worklog-management` - Worklog format and updates
- `Skill: atomic-commits` - Commit decision guidance
- `Skill: git-workflows` - Commit message conventions

---

## Quick Reference

| Checkpoint | Required? | Action |
|------------|-----------|--------|
| Implementation done | Yes | Verify code complete |
| Tests pass | Yes (if applicable) | Run test suite |
| Plan updated | Yes | Mark [x], add log entry |
| **Worklog pending entry** | **Yes** | **Add pending task (Step 3)** |
| Commit decision | Depends | Commit or group |
| **Worklog commit update** | **After commit** | **Update with hash (Step 6a)** |
| **Session end reconciliation** | **Before exit** | **Commit/keep/discard pending** |
| Enforcement check | Auto | Based on project config |
