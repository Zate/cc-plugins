# View File Formats

Auto-generated view files that provide filtered lists of issues.

## index.md (Master Index)

```markdown
# Issue Tracker

**Last Updated**: 2024-12-18T10:30:00
**Open**: 5 | **In Progress**: 2 | **Done**: 12 | **Won't Do**: 1

## Quick Links

- [Bugs](bugs.md) (3 open)
- [Features](features.md) (2 open)
- [Backlog](backlog.md) (4 items)

## Open Issues by Priority

### Critical
(None)

### High
| ID | Type | Title | Created |
|----|------|-------|---------|
| [BUG-003](BUG-003.md) | bug | Auth token not refreshing | 2024-12-18 |

### Medium
| ID | Type | Title | Created |
|----|------|-------|---------|
| [FEAT-001](FEAT-001.md) | feature | User authentication flow | 2024-12-17 |
| [BUG-001](BUG-001.md) | bug | Button text truncated | 2024-12-16 |

### Low
| ID | Type | Title | Created |
|----|------|-------|---------|
| [TASK-002](TASK-002.md) | task | Refactor auth helpers | 2024-12-18 |
| [BUG-005](BUG-005.md) | bug | Typo in error message | 2024-12-18 |

## In Progress

| ID | Type | Title | Assignee |
|----|------|-------|----------|
| [FEAT-002](FEAT-002.md) | feature | Dark mode support | current-session |
| [BUG-002](BUG-002.md) | bug | Form validation race condition | current-session |

## Recently Resolved

| ID | Type | Title | Resolved |
|----|------|-------|----------|
| [BUG-004](BUG-004.md) | bug | Missing null check | 2024-12-18 |
| [FEAT-003](FEAT-003.md) | feature | Add logout button | 2024-12-17 |

---

*Commands: `/devloop:new` (create), `/devloop:issues` (manage), `/devloop:backlog` (view backlog)*
```

## bugs.md (Bug View)

```markdown
# Bugs

**Last Updated**: 2024-12-18T10:30:00
**Open**: 3 | **In Progress**: 1 | **Fixed**: 5

[← Back to Index](index.md)

## Open Bugs

| ID | Priority | Title | Created | Labels |
|----|----------|-------|---------|--------|
| [BUG-003](BUG-003.md) | high | Auth token not refreshing | 2024-12-18 | auth, api |
| [BUG-001](BUG-001.md) | medium | Button text truncated | 2024-12-16 | ui |
| [BUG-005](BUG-005.md) | low | Typo in error message | 2024-12-18 | formatting |

## In Progress

| ID | Priority | Title | Assignee |
|----|----------|-------|----------|
| [BUG-002](BUG-002.md) | medium | Form validation race condition | current-session |

## Recently Fixed

| ID | Title | Fixed |
|----|-------|-------|
| [BUG-004](BUG-004.md) | Missing null check | 2024-12-18 |

---

*Use `/devloop:bug` to report a new bug or `/devloop:bugs` to manage bugs.*
```

## features.md (Feature View)

```markdown
# Features

**Last Updated**: 2024-12-18T10:30:00
**Open**: 2 | **In Progress**: 1 | **Done**: 3

[← Back to Index](index.md)

## Open Features

| ID | Priority | Title | Estimate | Labels |
|----|----------|-------|----------|--------|
| [FEAT-001](FEAT-001.md) | high | User authentication flow | L | auth, mvp |
| [FEAT-004](FEAT-004.md) | medium | Export to CSV | M | export |

## In Progress

| ID | Title | Assignee |
|----|-------|----------|
| [FEAT-002](FEAT-002.md) | Dark mode support | current-session |

## Recently Completed

| ID | Title | Completed |
|----|-------|-----------|
| [FEAT-003](FEAT-003.md) | Add logout button | 2024-12-17 |

---

*Use `/devloop:new` to request a new feature.*
```

## backlog.md (Backlog View)

```markdown
# Backlog

**Last Updated**: 2024-12-18T10:30:00
**Total Items**: 4

[← Back to Index](index.md)

Open features and tasks, sorted by priority.

## High Priority

| ID | Type | Title | Estimate | Labels |
|----|------|-------|----------|--------|
| [FEAT-001](FEAT-001.md) | feature | User authentication flow | L | auth, mvp |

## Medium Priority

| ID | Type | Title | Estimate | Labels |
|----|------|-------|----------|--------|
| [FEAT-004](FEAT-004.md) | feature | Export to CSV | M | export |
| [TASK-001](TASK-001.md) | task | Add unit tests for auth | M | testing |

## Low Priority

| ID | Type | Title | Estimate | Labels |
|----|------|-------|----------|--------|
| [TASK-002](TASK-002.md) | task | Refactor auth helpers | S | tech-debt |

---

*Use `/devloop:new` to add items or `/devloop:issues backlog` to manage.*
```
