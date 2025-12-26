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

**See `references/view-formats.md` for complete view file examples.**

Quick summary:
- **index.md** - Master list with all issues, grouped by priority and status
- **bugs.md** - Bug-only view, open and recently fixed
- **features.md** - Feature-only view, open and recently completed
- **backlog.md** - Open features + tasks, sorted by priority

**See `references/view-generation.md` for regeneration algorithm and triggers.**

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

## Reference Files

For detailed implementation guidance, see:
- **`references/view-formats.md`** - Complete view file examples (index.md, bugs.md, features.md, backlog.md)
- **`references/view-generation.md`** - View regeneration algorithm and triggers
- **`references/issue-creation.md`** - Step-by-step agent workflow for creating issues with smart routing keywords

## Related Skills

- `bug-tracking` - Original bug-only tracking (deprecated, use this instead)
- `plan-management` - For active implementation plans
- `complexity-estimation` - For estimating issue size

## Related Agents

- `issue-manager` - Creates and manages issues
- `bug-catcher` - Legacy, routes to issue-manager
- `workflow-detector` - Routes to appropriate issue commands
