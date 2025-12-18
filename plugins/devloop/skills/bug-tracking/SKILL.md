---
name: bug-tracking
description: Lightweight bug tracking for capturing, storing, and managing bugs discovered during development. Use when you or any agent discovers a non-critical bug that should be tracked for later fixing.
---

# Bug Tracking Skill

A lightweight, file-based bug tracking system integrated into the devloop workflow.

## When to Use

- You discover a bug that isn't blocking current work
- An agent finds an issue during review/testing that should be tracked
- User mentions "we should fix this later" or similar
- Formatting issues, minor logic errors, tech debt items
- Any issue worth remembering but not worth stopping for

## When NOT to Use This Skill

- **Blocking bugs**: Fix critical issues immediately, don't track them
- **Feature requests**: These belong in a backlog, not bug tracker
- **External issues**: Bugs in third-party dependencies - file upstream
- **Already tracked**: Check existing bugs before creating duplicates
- **Trivial fixes**: If it takes <2 minutes to fix, just fix it

## Bug Storage Location

```
.devloop/issues/
├── index.md           # Overview of all bugs with status
├── BUG-001.md         # Individual bug files
├── BUG-002.md
└── ...
```

## Bug File Format

Each bug is stored as `.devloop/issues/BUG-{NNN}.md`:

```markdown
---
id: BUG-001
title: Brief description of the bug
status: open
priority: medium
created: 2024-12-11T10:30:00
updated: 2024-12-11T10:30:00
reporter: agent:code-reviewer
tags: [formatting, ui]
related-files:
  - src/components/Button.tsx
  - src/styles/button.css
related-plan-task: Task 2.3
---

# BUG-001: Brief description of the bug

## Description

Detailed description of what's wrong.

## Steps to Reproduce

1. Step one
2. Step two
3. Observe the issue

## Expected Behavior

What should happen instead.

## Actual Behavior

What currently happens.

## Context

- Discovered during: code review of auth feature
- Related feature: user authentication
- Blocking: no

## Notes

Any additional context, screenshots references, or thoughts on how to fix.

## Resolution

<!-- Filled in when fixed -->
- **Fixed in**: [commit hash or PR]
- **Fixed by**: [agent or user]
- **Fix summary**: [brief description]
```

## Index File Format

`.devloop/issues/index.md`:

```markdown
# Bug Tracker

**Last Updated**: 2024-12-11T10:30:00
**Open**: 3 | **In Progress**: 1 | **Fixed**: 5 | **Won't Fix**: 1

## Open Bugs

| ID | Priority | Title | Created | Tags |
|----|----------|-------|---------|------|
| [BUG-003](BUG-003.md) | high | Auth token not refreshing | 2024-12-11 | auth, api |
| [BUG-001](BUG-001.md) | medium | Button text truncated | 2024-12-10 | ui |
| [BUG-005](BUG-005.md) | low | Typo in error message | 2024-12-11 | formatting |

## In Progress

| ID | Priority | Title | Assigned |
|----|----------|-------|----------|
| [BUG-002](BUG-002.md) | medium | Form validation race condition | current-session |

## Recently Fixed

| ID | Title | Fixed |
|----|-------|-------|
| [BUG-004](BUG-004.md) | Missing null check | 2024-12-11 |

---

*Use `/devloop:bugs` to manage bugs or `/devloop:bug` to report a new one.*
```

## Creating a Bug (For Agents)

When an agent discovers a bug, it should:

1. **Check if bugs directory exists**:
   ```bash
   mkdir -p .devloop/issues
   ```

2. **Get next bug ID**:
   ```bash
   # Find highest existing bug number
   ls .devloop/issues/BUG-*.md 2>/dev/null | sed 's/.*BUG-0*//' | sed 's/.md//' | sort -n | tail -1
   # Add 1 for next ID, pad to 3 digits
   ```

3. **Create bug file** with frontmatter and description

4. **Update index.md** to include the new bug

### Quick Bug Creation Template

For agents to quickly log a bug:

```markdown
---
id: BUG-{NNN}
title: {one-line summary}
status: open
priority: {low|medium|high}
created: {ISO timestamp}
updated: {ISO timestamp}
reporter: agent:{agent-name}
tags: [{relevant, tags}]
related-files:
  - {file paths discovered in}
---

# BUG-{NNN}: {one-line summary}

## Description

{What's wrong - 1-3 sentences}

## Context

- Discovered during: {what agent was doing}
- Severity: {cosmetic|functional|data-integrity}
- Blocking: no

## Suggested Fix

{If obvious, note the fix approach}
```

## Bug Priorities

| Priority | When to Use | Examples |
|----------|-------------|----------|
| **critical** | Data loss, security, crashes | Never use for "track later" bugs |
| **high** | Broken functionality, bad UX | Feature doesn't work in edge case |
| **medium** | Annoying but workaround exists | UI glitch, slow performance |
| **low** | Cosmetic, nice-to-have | Typos, formatting, minor polish |

## Status Transitions

```
open → in-progress → fixed
                  ↘ wont-fix
```

- **open**: Bug reported, not being worked on
- **in-progress**: Someone is actively fixing it
- **fixed**: Resolution complete
- **wont-fix**: Decided not to fix (document reason)

## Integration Points

### With Code Review
When code-reviewer finds issues that aren't critical:
- Log as bug instead of blocking the review
- Reference bug ID in review comments

### With DoD Validation
dod-validator should:
- Check `.devloop/issues/` for open bugs related to current feature
- Warn if high-priority bugs exist
- Not block on low/medium bugs

### With Plan Management
- Bugs can reference plan tasks they relate to
- `/devloop:continue` can show bug count for context

## Commands

- `/devloop:bug` - Report a new bug interactively
- `/devloop:bugs` - View and manage bugs

## Best Practices

1. **Be specific**: Include file paths, line numbers, steps to reproduce
2. **Don't over-report**: Not every observation needs a bug
3. **Use appropriate priority**: Most "track for later" bugs are low/medium
4. **Link context**: Reference related files, plan tasks, or other bugs
5. **Update status**: Mark bugs in-progress when working, fixed when done
