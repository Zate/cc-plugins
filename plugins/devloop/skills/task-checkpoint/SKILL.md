# Task Checkpoint Skill

Complete checklist and verification for task completion in devloop workflows.

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

### 4. Commit Decision
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

### Step 3: Check for Parallel Siblings

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

### Step 4: Commit Decision
```
Use AskUserQuestion:
- question: "Task complete. How should we handle the commit?"
- header: "Commit"
- options:
  - Commit now (Create atomic commit for this task)
  - Group with next (Continue, commit after related tasks)
  - Review changes first (Show diff before deciding)
```

### Step 5: Execute Commit (if committing now)
```
If committing:
1. Launch git-manager agent with task context
2. Generate conventional commit message
3. Include task reference: "feat(scope): description - Task X.Y"
4. After commit, update Progress Log with commit hash
5. Update worklog with committed tasks (see Step 5a)
```

### Step 5a: Update Worklog
```
After successful commit:
1. Read .devloop/worklog.md (create if doesn't exist)
2. Add entry to commit table:
   | {hash} | {date} | {commit message} | {task refs} |
3. Add task to "Tasks Completed" section with commit hash:
   - [x] Task X.Y: [Description] ({hash})
4. Update "Last Updated" timestamp

See Skill: worklog-management for detailed format.
```

### Step 6: Enforcement Check
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
| Commit created | Depends | Commit or group |
| Worklog updated | After commit | Add entry with hash |
| Enforcement check | Auto | Based on project config |
