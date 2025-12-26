---
name: file-locations
description: This skill should be used when the user asks about ".devloop/ structure", "where to put files", "git-tracked vs local", "devloop artifacts", or needs guidance on file locations and directory structure.
whenToUse: |
  - Creating new devloop files (plans, reports, issues)
  - Understanding what files to commit vs gitignore
  - Setting up a new project with devloop
  - Troubleshooting file location issues
  - Migrating from old .claude/ paths to .devloop/
whenNotToUse: |
  - Working with application code (not .devloop/ files)
  - General git operations - use git-workflows
  - Claude Code configuration (.claude/ is separate)
  - Non-devloop plugins with their own conventions
---

# File Locations

**Purpose**: Define where devloop artifacts belong and whether they should be committed to git.

## When to Use This Skill

- Creating new devloop files (plans, reports, issues)
- Understanding what files to commit vs ignore
- Setting up a new project with devloop
- Migrating from old `.claude/` paths to `.devloop/`

## When NOT to Use This Skill

- Working with application code (not `.devloop/` files)
- General git operations (use `Skill: git-workflows`)
- Claude Code configuration (`.claude/` is separate)

---

## Quick Reference

### Directory Structure

```
.devloop/                     # Devloop's dedicated directory
├── plan.md                   # Active plan (git-tracked)
├── worklog.md                # Work history (git-tracked)
├── local.md                  # Local settings (NOT tracked)
├── context.json              # Tech stack cache (git-tracked)
│
├── issues/                   # Issue tracking (git-tracked)
│   ├── index.md, bugs.md, features.md, backlog.md
│   ├── BUG-001.md, FEAT-001.md, TASK-001.md, ...
│
└── spikes/                   # Spike reports (NOT tracked)
    └── {topic}.md
```

### Git Tracking Summary

| Category | Files | Git Status |
|----------|-------|------------|
| **Shared State** | `plan.md`, `worklog.md`, `context.json`, `issues/` | Tracked |
| **Local Config** | `local.md` | NOT tracked |
| **Working Notes** | `spikes/` | NOT tracked |

### File Naming Conventions

| Pattern | Example | Purpose |
|---------|---------|---------|
| `plan.md` | Fixed | Active implementation plan |
| `worklog.md` | Fixed | Completed work history |
| `local.md` | Fixed | Local settings/preferences |
| `BUG-NNN.md` | `BUG-001.md` | Bug reports |
| `FEAT-NNN.md` | `FEAT-001.md` | Feature requests |
| `TASK-NNN.md` | `TASK-001.md` | General tasks |
| `spikes/{topic}.md` | `spikes/auth.md` | Spike investigation results |

---

## .gitignore Template

```gitignore
# Devloop local files (do not commit)
.devloop/local.md
.devloop/spikes/
```

See also: `plugins/devloop/templates/gitignore-devloop`

---

## References

For detailed guidance on specific topics, load these references:

| Reference | Content |
|-----------|---------|
| `references/file-specs.md` | Detailed format for each file type, lifecycle, settings |
| `references/migration.md` | Migration from .claude/ to .devloop/, new project setup |
| `references/rationale.md` | Why files are tracked or not tracked |

### Loading References

```
Read: plugins/devloop/skills/file-locations/references/file-specs.md
Read: plugins/devloop/skills/file-locations/references/migration.md
Read: plugins/devloop/skills/file-locations/references/rationale.md
```

---

## See Also

- `Skill: plan-management` - Plan file format and update rules
- `Skill: issue-tracking` - Issue file format and workflows
- `Skill: worklog-management` - Worklog format and update rules
- `Skill: atomic-commits` - When and how to commit
- `/devloop:continue` - Resuming from a plan
