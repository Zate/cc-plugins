---
name: plan-management
description: This skill should be used when creating, reading, or updating devloop plans in .devloop/plan.md, task tracking, progress logs, phase management, PR feedback
whenToUse: Creating or updating plans, reading plan state, understanding task status, marking tasks complete, adding progress entries, phase transitions, PR feedback tracking
whenNotToUse: Quick tasks without formal plans, exploratory spikes, simple TODOs
seeAlso:
  - skill: pr-feedback
    when: integrating PR review comments
  - skill: local-config
    when: project-specific settings
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

## Parallelism Markers

- `[parallel:A]` - Can run with other Group A tasks
- `[depends:N.M]` - Must wait for Task N.M

## Update Rules

1. Mark tasks in progress: `- [~]`
2. Mark tasks complete: `- [x]`
3. Add Progress Log entry
4. Update timestamps
5. Add PR link after PR creation
6. Add PR Feedback section after review
