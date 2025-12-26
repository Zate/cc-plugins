# Checkpoint Workflow

Detailed step-by-step workflow for completing a task with proper plan and worklog updates.

## Step 1: Verify Implementation
```
Before proceeding:
1. Review the changes made
2. Confirm task requirements are met
3. Run any relevant tests
```

## Step 2: Update Plan File
```
Read .devloop/plan.md
Find the task that was just completed
Mark it [x] and add Progress Log entry
Write the updated plan
```

## Step 3: Mandatory Worklog Checkpoint
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

## Step 4: Check for Parallel Siblings

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

## Step 5: Commit Decision
```
Use AskUserQuestion:
- question: "Task complete. How should we handle the commit?"
- header: "Commit"
- options:
  - Commit now (Create atomic commit for this task)
  - Group with next (Continue, commit after related tasks)
  - Review changes first (Show diff before deciding)
```

## Step 6: Execute Commit (if committing now)
```
If committing:
1. Launch git-manager agent with task context
2. Generate conventional commit message
3. Include task reference: "feat(scope): description - Task X.Y"
4. After commit, update Progress Log with commit hash
5. Update worklog with committed tasks (see Step 6a)
```

## Step 6a: Update Worklog with Commit Hash
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

## Step 7: Enforcement Check
```
Read .devloop/local.md for enforcement setting

If enforcement: strict:
  - Verify plan was actually updated
  - Block if not updated

If enforcement: advisory (default):
  - Warn if plan not updated
  - Allow override with user confirmation
```
