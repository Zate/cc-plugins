# Plan Management Skill

Working with `.devloop/plan.md` files for structured development workflows.

## Plan Format

Plans use markdown with checkbox tasks:

```markdown
# [Feature Name]

**Created**: YYYY-MM-DD
**Status**: In Progress | Complete | Blocked
**Branch**: feat/feature-name (if applicable)

## Overview

Brief description of the work.

## Tasks

### Phase 1: Foundation
- [ ] Task 1.1: Description
  - Acceptance: Testable criteria
  - Files: Expected files to modify/create
  
- [x] Task 1.2: Completed task

### Phase 2: Implementation
- [ ] Task 2.1: Next task [depends:1.2]
- [ ] Task 2.2: Parallel task [parallel:A]
- [ ] Task 2.3: Another parallel task [parallel:A]

## Progress Log
- YYYY-MM-DD HH:MM: Event description
- YYYY-MM-DD HH:MM: Task 1.2 completed
```

## Task States

- `- [ ]` - Pending (not started)
- `- [x]` - Complete
- `- [~]` - Partial (started but not done)
- `- [!]` - Blocked (cannot proceed)

## Task Markers

### Dependencies
```markdown
- [ ] Task 2.1: Implement feature [depends:1.2]
```
This task depends on Task 1.2 being complete first.

### Parallel Execution
```markdown
- [ ] Task 2.1: Write unit tests [parallel:A]
- [ ] Task 2.2: Write integration tests [parallel:A]
- [ ] Task 2.3: Update documentation [parallel:A]
```
Tasks with the same parallel group (e.g., `[parallel:A]`) can be done simultaneously.

## Operations

### Create Plan

```bash
mkdir -p .devloop
cat > .devloop/plan.md << 'EOF'
# Feature Name

**Created**: $(date +%Y-%m-%d)
**Status**: In Progress

## Tasks
- [ ] Task 1: Description
- [ ] Task 2: Description

## Progress Log
- $(date +%Y-%m-%d): Plan created
EOF
```

### Mark Task Complete

Using sed:
```bash
# Mark specific task complete
sed -i 's/- \[ \] Task 1.1:/- [x] Task 1.1:/' .devloop/plan.md
```

Or manually edit the file to change `[ ]` to `[x]`.

### Add Progress Entry

```bash
echo "- $(date +%Y-%m-%d\ %H:%M): Task completed" >> .devloop/plan.md
```

### Check Completion Status

```bash
bash plugins/rovodev/scripts/check-plan-complete.sh
```

Output:
```json
{"complete": false, "total": 10, "done": 7, "pending": 3, "partial": 0, "blocked": 0}
```

### Find Next Task

```bash
# Find first pending task
grep -m 1 "^- \[ \]" .devloop/plan.md
```

### Update Status

```bash
# Update plan status to Complete
sed -i 's/\*\*Status\*\*: In Progress/\*\*Status\*\*: Complete/' .devloop/plan.md
```

## Best Practices

### Task Granularity

**Too large** ❌:
```markdown
- [ ] Implement authentication system
```

**Good** ✅:
```markdown
- [ ] Task 1.1: Add JWT token generation
- [ ] Task 1.2: Add JWT validation middleware
- [ ] Task 1.3: Add token refresh endpoint
- [ ] Task 1.4: Add authentication tests
```

### Acceptance Criteria

**Vague** ❌:
```markdown
- [ ] Task 1.1: Add validation
  - Acceptance: It works
```

**Specific** ✅:
```markdown
- [ ] Task 1.1: Add input validation
  - Acceptance: Rejects invalid emails, validates required fields, returns 400 with error details
  - Files: packages/cli/validation.py, tests/test_validation.py
```

### Progress Logging

Keep progress log concise but informative:

```markdown
## Progress Log
- 2026-01-09 10:00: Plan created
- 2026-01-09 11:30: Phase 1 complete (3/3 tasks)
- 2026-01-09 14:00: Started Phase 2
- 2026-01-09 15:30: Blocked on API rate limit issue (logged as ISSUE-001)
- 2026-01-10 09:00: Unblocked, API limit increased
- 2026-01-10 12:00: Phase 2 complete, ready for review
```

## Plan Lifecycle

1. **Create** - Start with @rovodev or @task-planner
2. **Execute** - Work through tasks, mark complete
3. **Update** - Add progress log entries
4. **Checkpoint** - Save state with @fresh if needed
5. **Resume** - Continue with @continue
6. **Complete** - All tasks done, run @ship
7. **Archive** - Move to `.devloop/archive/` for history

## Integration with Workflow

### Fresh Start
When running `@fresh`, the plan stays intact. Only the current task pointer is saved to `.devloop/next-action.json`.

### Continue
When running `@continue`, it reads the plan and finds the next pending task.

### Ship
When running `@ship`, it checks if all tasks are complete before committing.

## Common Patterns

### Bug Fix Plan
```markdown
# Fix: [Bug Description]

**Created**: YYYY-MM-DD
**Status**: In Progress

## Tasks
- [ ] Task 1: Reproduce bug with test
- [ ] Task 2: Fix root cause
- [ ] Task 3: Verify fix with existing tests
- [ ] Task 4: Add regression test
```

### Feature Plan
```markdown
# Feature: [Feature Name]

**Created**: YYYY-MM-DD
**Status**: In Progress

## Tasks

### Phase 1: Design
- [ ] Task 1.1: Review requirements
- [ ] Task 1.2: Design API/interface
- [ ] Task 1.3: Get approval

### Phase 2: Implementation
- [ ] Task 2.1: Implement core logic
- [ ] Task 2.2: Add error handling
- [ ] Task 2.3: Add validation

### Phase 3: Testing
- [ ] Task 3.1: Unit tests
- [ ] Task 3.2: Integration tests
- [ ] Task 3.3: Manual testing

### Phase 4: Documentation
- [ ] Task 4.1: Update README
- [ ] Task 4.2: Add docstrings
- [ ] Task 4.3: Update CHANGELOG
```

### Refactoring Plan
```markdown
# Refactor: [Area]

**Created**: YYYY-MM-DD
**Status**: In Progress

## Tasks

### Phase 1: Preparation
- [ ] Task 1.1: Add tests for existing behavior
- [ ] Task 1.2: Document current architecture

### Phase 2: Refactor
- [ ] Task 2.1: Extract common code
- [ ] Task 2.2: Simplify complex functions
- [ ] Task 2.3: Improve naming

### Phase 3: Validation
- [ ] Task 3.1: All tests still pass
- [ ] Task 3.2: Performance unchanged
- [ ] Task 3.3: Code review
```

## Tips

- **Keep it updated**: Mark tasks complete as you go
- **Be specific**: Clear acceptance criteria save time
- **Log blockers**: Note issues in progress log
- **Archive completed plans**: Keep history organized
- **Reference issues**: Link to `.devloop/issues/` when needed
