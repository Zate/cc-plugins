---
name: task-checkpoint
description: This skill should be used when the user asks about "task completion", "checkpoint verification", "worklog sync", "mark task complete", or after implementing a task from the devloop plan.
whenToUse: |
  - After completing implementation of a task from the devloop plan
  - Before marking a task as [x] complete in the plan
  - When /devloop:continue finishes executing a task
  - Before moving to the next task in a phase
  - Verifying acceptance criteria are met
whenNotToUse: |
  - Quick one-off fixes not tracked in a plan
  - Exploratory work or spikes - use /devloop:spike instead
  - When explicitly told to skip checkpoints
  - Partial work that will be continued immediately
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
- [ ] Add pending entry: `- [ ] Task X.Y: [Description] (pending)`
- [ ] Update "Last Updated" timestamp

**After commit** (if committing):
- [ ] Update pending entry with commit hash: `- [x] Task X.Y: [Description] (abc1234)`
- [ ] Add commit to Commits table

### 5. Commit Decision
**Consider these options:**
- **Commit now**: Create atomic commit for this task
- **Group with next**: Continue, commit after related tasks
- **Review changes**: Show diff before deciding

---

## Checkpoint Workflow

**See `references/checkpoint-workflow.md` for complete step-by-step workflow.**

Quick summary:
1. **Verify Implementation** - Code complete, tests pass
2. **Update Plan File** - Mark [x], add Progress Log entry
3. **Mandatory Worklog Checkpoint** - Add pending task entry
4. **Check Parallel Siblings** - Wait for group or commit independently
5. **Commit Decision** - Commit now, group, or review
6. **Execute Commit** - If committing, generate conventional message
7. **Update Worklog with Hash** - After commit, update pending → committed
8. **Enforcement Check** - Advisory warning or strict blocking

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

**See `references/session-reconciliation.md` for complete reconciliation workflow.**

At the end of a development session, reconcile pending worklog entries to ensure accurate history.

Quick checklist:
- Check for pending entries in worklog
- Decide: Commit now, keep pending, or discard
- Update worklog accordingly
- Generate session summary with reconciliation notes

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

## Reference Files

For detailed workflows, see:
- **`references/checkpoint-workflow.md`** - Complete 7-step checkpoint workflow with examples
- **`references/session-reconciliation.md`** - Session end reconciliation and enforcement behavior
