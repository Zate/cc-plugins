---
name: plan-management
description: This skill should be used when creating, reading, or updating devloop plans in .devloop/plan.md, task tracking, progress logs, phase management
whenToUse: Creating or updating plans, reading plan state, understanding task status, marking tasks complete, adding progress entries, phase transitions
whenNotToUse: Quick tasks without formal plans, exploratory spikes, simple TODOs
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

## Tasks

### Phase 1: [Phase Name]
- [ ] Task 1.1: Description
  - Acceptance: Criteria
  - Files: Expected files

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

## Parallelism Markers

- `[parallel:A]` - Can run with other Group A tasks
- `[depends:N.M]` - Must wait for Task N.M

## Update Rules

1. Mark tasks in progress: `- [~]`
2. Mark tasks complete: `- [x]`
3. Add Progress Log entry
4. Update timestamps
