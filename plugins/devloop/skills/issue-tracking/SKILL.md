---
name: issue-tracking
description: Unified issue tracking for bugs, features, tasks, and other work items. Extends bug-tracking with type-based IDs, smart routing, and auto-generated view files.
---

# Issue Tracking Skill

A unified, file-based issue tracking system that supports multiple issue types with intelligent routing and focused views.

## When to Use

- Track bugs, features, tasks, chores, or spikes in a single system
- You need type-prefixed IDs for quick identification (BUG-001, FEAT-001)
- Managing a backlog of work items for a project
- Any agent discovers something worth tracking for later
- User mentions work items that should be captured

## When NOT to Use This Skill

- **Blocking issues**: Fix critical problems immediately, don't track them
- **External issues**: Bugs in third-party dependencies - file upstream
- **Already tracked**: Check existing issues before creating duplicates
- **Trivial fixes**: If it takes <2 minutes to fix, just fix it
- **Plan tasks**: Use `.devloop/plan.md` for active implementation tasks

## Issue Types

| Type | ID Prefix | When to Use |
|------|-----------|-------------|
| `bug` | BUG- | Something is broken, incorrect behavior, errors |
| `feature` | FEAT- | New functionality, enhancements, user-facing additions |
| `task` | TASK- | Refactoring, improvements, technical work |
| `chore` | CHORE- | Maintenance, dependencies, build system, cleanup |
| `spike` | SPIKE- | Research, investigation, proof-of-concept |

## Issue Storage Location

```
.devloop/issues/
├── index.md           # Master index (all issues)
├── bugs.md            # View: type:bug only
├── features.md        # View: type:feature only
├── backlog.md         # View: open features + tasks
├── BUG-001.md         # Bug issues
├── FEAT-001.md        # Feature issues
├── TASK-001.md        # Task issues
├── CHORE-001.md       # Chore issues
├── SPIKE-001.md       # Spike issues
└── ...
```

### Migration from .devloop/issues/

If a project has existing `.devloop/issues/`:
1. Issues can be migrated to `.devloop/issues/` preserving BUG- prefixes
2. Both locations can coexist during transition
3. See Migration section below for details

## Issue File Format

Each issue is stored as `.devloop/issues/{PREFIX}-{NNN}.md`:

```markdown
---
id: FEAT-001
type: feature
title: Brief description of the issue
status: open
priority: medium
created: 2024-12-18T10:30:00
updated: 2024-12-18T10:30:00
reporter: user
assignee: null
labels: [auth, mvp]
related-files:
  - src/components/Auth.tsx
  - src/services/auth.ts
related-plan-task: Task 2.3
estimate: M
---

# FEAT-001: Brief description of the issue

## Description

Detailed description of the issue.

## Context

- Discovered during: [how it was found]
- Related feature: [feature area if applicable]
- Blocking: no

## Acceptance Criteria

<!-- For features/tasks -->
- [ ] Criterion 1
- [ ] Criterion 2

## Steps to Reproduce

<!-- For bugs -->
1. Step one
2. Step two
3. Observe the issue

## Expected Behavior

<!-- For bugs -->
What should happen instead.

## Notes

Any additional context or thoughts.

## Resolution

<!-- Filled in when done -->
- **Resolved in**: [commit hash or PR]
- **Resolved by**: [agent or user]
- **Resolution summary**: [brief description]
```

## Frontmatter Schema

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Type-prefixed ID (e.g., BUG-001, FEAT-042) |
| `type` | enum | `bug`, `feature`, `task`, `chore`, `spike` |
| `title` | string | Brief one-line description |
| `status` | enum | `open`, `in-progress`, `done`, `wont-do` |
| `priority` | enum | `low`, `medium`, `high`, `critical` |
| `created` | ISO datetime | When issue was created |
| `updated` | ISO datetime | When issue was last modified |
| `reporter` | string | Who reported (user, agent:{name}) |

### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `assignee` | string | Who is working on it |
| `labels` | array | Tags for categorization |
| `related-files` | array | File paths related to issue |
| `related-plan-task` | string | Link to devloop plan task |
| `estimate` | enum | T-shirt size: `XS`, `S`, `M`, `L`, `XL` |
| `due-date` | ISO date | Optional deadline |
| `parent` | string | Parent issue ID for hierarchies |
| `blocks` | array | Issues this blocks |
| `blocked-by` | array | Issues blocking this |

## ID Prefix Rules

Each type has a unique 3-5 character prefix:

| Type | Prefix | ID Format | Examples |
|------|--------|-----------|----------|
| bug | BUG- | BUG-001, BUG-042 | BUG-001, BUG-999 |
| feature | FEAT- | FEAT-001, FEAT-042 | FEAT-001, FEAT-999 |
| task | TASK- | TASK-001, TASK-042 | TASK-001, TASK-999 |
| chore | CHORE- | CHORE-001, CHORE-042 | CHORE-001, CHORE-999 |
| spike | SPIKE- | SPIKE-001, SPIKE-042 | SPIKE-001, SPIKE-999 |

### Getting Next ID

Each type maintains its own counter. To get next ID:

```bash
# For a specific type (e.g., FEAT)
prefix="FEAT"
max_num=$(ls .devloop/issues/${prefix}-*.md 2>/dev/null | \
  sed "s/.*${prefix}-0*//" | sed 's/.md//' | \
  sort -n | tail -1)
next_num=$((${max_num:-0} + 1))
printf "${prefix}-%03d" $next_num
# Output: FEAT-001 (or FEAT-002 if FEAT-001 exists)
```

## Priority Levels

| Priority | When to Use | Response Time |
|----------|-------------|---------------|
| **critical** | Security, data loss, system down | Immediate - don't track, fix now |
| **high** | Core feature broken, major UX issue | Next work session |
| **medium** | Feature works but has issues | Within sprint/week |
| **low** | Cosmetic, nice-to-have, minor polish | Backlog |

**Note**: Critical issues should typically be fixed immediately, not tracked. Use critical sparingly for issues that are severe but require planning.

## Status Transitions

```
open ──────┬──► in-progress ──┬──► done
           │                  │
           └──► wont-do ◄─────┘
```

- **open**: Issue reported, not being worked on
- **in-progress**: Actively being addressed
- **done**: Resolution complete
- **wont-do**: Decided not to address (document reason)

## View Files (Auto-Generated)

View files provide filtered lists and are regenerated on any issue change.

### index.md (Master Index)

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

### bugs.md (Bug View)

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

### features.md (Feature View)

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

### backlog.md (Backlog View)

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

## View Generation Rules

Views are auto-generated whenever an issue is created, updated, or deleted.

### Regeneration Triggers

| Action | Regenerate Views |
|--------|------------------|
| Create issue | Yes - all views |
| Update issue status | Yes - all views |
| Update issue priority | Yes - all views |
| Update issue type | Yes - all views |
| Delete issue | Yes - all views |
| Update other fields | Yes - index.md only |

### View Generation Algorithm

```python
# Pseudocode for view generation

def regenerate_views():
    issues = parse_all_issues(".devloop/issues/*.md")

    # Generate index.md
    generate_index(issues)

    # Generate type-specific views
    generate_bugs_view(filter(issues, type="bug"))
    generate_features_view(filter(issues, type="feature"))

    # Generate backlog (open features + tasks)
    backlog = filter(issues,
        type in ["feature", "task"] AND status="open")
    generate_backlog_view(backlog)

def generate_index(issues):
    # Count by status
    counts = count_by_status(issues)

    # Group open by priority (critical, high, medium, low)
    open_by_priority = group_by(
        filter(issues, status="open"),
        "priority"
    )

    # Get in-progress issues
    in_progress = filter(issues, status="in-progress")

    # Get recent done (last 10)
    recent_done = sort_by_updated(
        filter(issues, status="done")
    )[:10]

    # Write index.md with template
```

### View Consistency

Agents MUST regenerate views after ANY issue modification:

1. After creating issue → regenerate all views
2. After updating issue → regenerate all views
3. After deleting issue → regenerate all views

**The issue files are the source of truth. Views are derived.**

## Smart Routing Keywords

For `/devloop:new` command to auto-detect issue type:

### Bug Keywords
- "bug", "broken", "doesn't work", "not working"
- "error", "crash", "exception", "fail"
- "fix", "wrong", "incorrect", "unexpected"

### Feature Keywords
- "add", "new", "implement", "create", "build"
- "feature", "enhancement", "request"
- "support", "enable", "allow"

### Task Keywords
- "refactor", "clean up", "improve", "optimize"
- "update", "upgrade", "migrate"
- "reorganize", "restructure"

### Chore Keywords
- "chore", "maintenance", "dependency"
- "bump", "upgrade dependency"
- "ci", "build system", "config"

### Spike Keywords
- "investigate", "explore", "research"
- "spike", "poc", "prototype"
- "evaluate", "assess"

### Routing Priority

If multiple types match, use this priority:
1. Explicit type mention ("this is a bug")
2. Bug keywords (issues are often bugs)
3. Feature keywords
4. Task keywords
5. Default to `task` if unclear

Always confirm detected type with user before creating.

## Creating an Issue (For Agents)

When an agent needs to create an issue:

### 1. Initialize Directory

```bash
mkdir -p .devloop/issues
```

### 2. Determine Type

Analyze the input using smart routing keywords (see above).

### 3. Get Next ID

```bash
prefix="FEAT"  # Based on detected type
max_num=$(ls .devloop/issues/${prefix}-*.md 2>/dev/null | \
  sed "s/.*${prefix}-0*//" | sed 's/.md//' | \
  sort -n | tail -1)
next_num=$((${max_num:-0} + 1))
id=$(printf "${prefix}-%03d" $next_num)
```

### 4. Create Issue File

Use the frontmatter schema and file format above.

### 5. Regenerate Views

After creating the issue file, regenerate all view files.

### Quick Issue Template

For agents to quickly log an issue:

```markdown
---
id: {PREFIX}-{NNN}
type: {bug|feature|task|chore|spike}
title: {one-line summary}
status: open
priority: {low|medium|high}
created: {ISO timestamp}
updated: {ISO timestamp}
reporter: agent:{agent-name}
labels: [{relevant, labels}]
related-files:
  - {file paths if known}
---

# {PREFIX}-{NNN}: {one-line summary}

## Description

{What this is about - 1-3 sentences}

## Context

- Discovered during: {what agent was doing}
- Related to: {feature area if applicable}
```

## Integration Points

### With Code Review

When code-reviewer finds issues:
- Non-blocking issues → create issue, reference ID in comments
- Type based on nature (bugs vs improvements vs features)

### With DoD Validation

dod-validator should:
- Check `.devloop/issues/` for open issues related to current feature
- Warn if high-priority bugs exist
- Not block on low/medium issues

### With Plan Management

- Issues can reference plan tasks via `related-plan-task`
- `/devloop:continue` can show open issue count for context
- Features from issues can become plan tasks

### With Workflow Detection

workflow-detector should:
- Route issue-related requests to `/devloop:new` or `/devloop:issues`
- Recognize "report a bug", "add to backlog", "create feature request"

## Migration from .devloop/issues/

### Automatic Detection

If `.devloop/issues/` exists but `.devloop/issues/` doesn't:
- Prompt user about migration
- Offer to migrate automatically

### Migration Steps

1. Create `.devloop/issues/` directory
2. Copy `BUG-*.md` files, updating frontmatter:
   - Add `type: bug` field
   - Rename `tags` to `labels` if present
3. Regenerate all view files
4. Optionally remove `.devloop/issues/` after verification

### Coexistence Mode

During transition, both can coexist:
- `.devloop/issues/` for legacy bug tracking
- `.devloop/issues/` for unified issue tracking
- Commands should prefer `.devloop/issues/` if it exists

## Commands

| Command | Purpose |
|---------|---------|
| `/devloop:new` | Smart issue creation with type detection |
| `/devloop:issues` | View and manage all issues |
| `/devloop:bug` | Quick bug creation (alias) |
| `/devloop:bugs` | View bugs (alias for `/devloop:issues bugs`) |
| `/devloop:backlog` | View backlog (alias for `/devloop:issues backlog`) |

## Best Practices

1. **Use appropriate types**: Bugs for broken things, features for new things
2. **Be specific**: Include file paths, context, reproduction steps
3. **Use labels**: Consistent labeling helps filtering (e.g., `auth`, `ui`, `api`)
4. **Link context**: Reference related files, plan tasks, or other issues
5. **Update status**: Keep status current as work progresses
6. **Review regularly**: Periodically review and close stale issues
7. **Prefer issues over comments**: Track work items here, not in code comments

## Related Skills

- `bug-tracking` - Original bug-only tracking (deprecated, use this instead)
- `plan-management` - For active implementation plans
- `complexity-estimation` - For estimating issue size

## Related Agents

- `issue-manager` - Creates and manages issues
- `bug-catcher` - Legacy, routes to issue-manager
- `workflow-detector` - Routes to appropriate issue commands
