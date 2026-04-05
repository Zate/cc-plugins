---
name: plan-management
description: This skill should be used when creating, reading, or updating devloop plans in .devloop/plan.md, task tracking, progress logs, phase management, PR feedback
when_to_use: Creating or updating .devloop/plan.md, task tracking, phase management
---

# Plan Management

Conventions for `.devloop/plan.md` file format and updates.

## Plan Location

Primary: `.devloop/plan.md`

## Plan Format

```markdown
# Devloop Plan: [Feature Name]

**Created**: YYYY-MM-DD
**Updated**: YYYY-MM-DD HH:MM
**Status**: Planning | In Progress | Complete
**Issue**: #123 (https://github.com/owner/repo/issues/123) (optional, if started from GH issue)
**Branch**: feat/feature-name (optional)
**PR**: https://github.com/.../pull/123 (after PR created)

## Overview

Brief description of the plan.

## Phase 1: [Phase Name]

- [ ] Task 1.1: Description
  - Acceptance: Criteria
  - Files: Expected files

## PR Feedback (after review)

PR #123 - @reviewer (CHANGES_REQUESTED)

### Blockers
- [ ] [PR-123-1] Fix issue (@reviewer)

### Suggestions
- [ ] [PR-123-2] Consider alternative (@reviewer)

## Progress Log
- [timestamp]: Event
```

## Task Markers

| Marker | Meaning |
|--------|---------|
| `- [ ]` | Pending |
| `- [x]` | Completed |
| `- [~]` | In progress |
| `- [!]` | Blocked |

## PR Feedback Task IDs

Format: `[PR-{number}-{item}]`

Example: `[PR-123-1]` = First feedback item from PR #123

## Model Hint Markers

Annotate tasks with model selection for optimized execution:

| Marker | When to Use | Examples |
|--------|------------|---------|
| `[model:haiku]` | Simple, mechanical, low-reasoning | Writing tests from patterns, docs, formatting, linting, config changes, file renames |
| `[model:sonnet]` | Complex reasoning, multi-file coordination | Architecture, debugging, multi-file refactoring, security analysis, performance |
| *(no annotation)* | Orchestrator does inline | Single-line edits, running a command, status checks |

Place at the end of the task line:
```markdown
- [ ] Task 1.1: Write unit tests for UserService [model:haiku]
- [ ] Task 1.2: Refactor authentication middleware [model:sonnet]
- [ ] Task 1.3: Update version in package.json
```

## Parallelism Markers

- `[parallel:A]` - Can run concurrently with other Group A tasks
- `[parallel:B]` - Can run concurrently with other Group B tasks (etc.)
- `[depends:N.M]` - Must wait for Task N.M to complete first

### Parallelism Guidelines

Tasks are parallel-safe when they:
- Modify different files (no write conflicts)
- Don't depend on each other's output
- Are in the same phase but independent

Example:
```markdown
## Phase 2: Implementation

- [ ] Task 2.1: Implement user model [model:sonnet] [parallel:A]
- [ ] Task 2.2: Write user model tests [model:haiku] [parallel:A]
- [ ] Task 2.3: Implement auth middleware [model:sonnet] [parallel:B]
- [ ] Task 2.4: Write auth middleware tests [model:haiku] [parallel:B]
- [ ] Task 2.5: Integration testing [model:sonnet] [depends:2.1] [depends:2.3]
```

Groups A and B run concurrently. Task 2.5 waits for both 2.1 and 2.3.

## Update Rules

1. Mark tasks in progress: `- [~]`
2. Mark tasks complete: `- [x]`
3. Add Progress Log entry
4. Update timestamps
5. Add PR link after PR creation
6. Add PR Feedback section after review
7. Add Issue link if started from GitHub Issue

## GitHub Issues Integration

When using issue-driven development (configured in `local.md`):

### Starting from Issue

Use `/devloop:plan --from-issue 123` to fetch issue details and create a plan with:
- `**Issue**: #123 (URL)` in the header
- Issue title becomes plan title
- Issue body provides context for planning

### On Plan Completion

When all tasks are `[x]` and Issue is linked:
1. Generate completion summary (tasks done, time elapsed)
2. Post summary as comment on the issue
3. Optionally close the issue (based on `github.auto-close` setting)

### Issue Reference Format

```markdown
**Issue**: #123 (https://github.com/owner/repo/issues/123)
```

The number after `#` is parsed by archive-plan.sh for GitHub integration.
