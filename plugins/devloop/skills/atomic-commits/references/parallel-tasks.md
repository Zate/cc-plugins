# Parallel Tasks and Phase Boundaries

## Parallel Task Groups

When tasks are marked with `[parallel:X]` markers, they may complete around the same time.

### Committing Parallel Tasks Together

**Group these into one commit:**
- All tasks in the same parallel group that complete successfully
- Creates a cohesive unit of related work
- Easier to review and understand as a whole

**Commit format for parallel groups:**
```
feat(scope): implement [feature area] - Tasks X.1, X.2, X.3

- Task X.1: [What it did]
- Task X.2: [What it did]
- Task X.3: [What it did]

All tasks in parallel group A for Phase X.
```

### Committing Parallel Tasks Separately

**Commit separately when:**
- Tasks modify completely different areas (e.g., API vs UI)
- One task is significantly larger than others
- Different reviewers would look at different tasks
- A task fails and others succeed

**Separate commit example:**
```
# Task 2.1 commits first
feat(api): add user endpoint - Task 2.1

# Task 2.2 commits separately
feat(ui): add user form - Task 2.2

# Task 2.3 (failed) requires fix before commit
```

### Waiting for Parallel Completion

**Before committing a task from a parallel group:**
1. Check if sibling tasks are close to completion
2. If so, consider waiting to commit together
3. If one is blocked, commit the completed tasks

**Use task-checkpoint** (Step 3) to detect parallel siblings automatically.

---

## Phase Boundaries

Phase boundaries in the devloop plan are natural commit points.

**At phase completion:**
1. All grouped changes MUST be committed
2. No pending uncommitted work should carry to next phase
3. This ensures clean phase transitions
4. Makes it easy to identify what each phase delivered

```
Phase 2: Authentication ✓
  - [x] Task 2.1: JWT tokens       → Committed: abc1234
  - [x] Task 2.2: Token tests      → Committed: abc1234 (grouped)
  - [x] Task 2.3: Password hashing → Committed: def5678
  - [x] Task 2.4: Login endpoint   → Committed: ghi9012

[All Phase 2 work committed before starting Phase 3]

Phase 3: User Profiles
  - [ ] Task 3.1: Profile model
  ...
```
