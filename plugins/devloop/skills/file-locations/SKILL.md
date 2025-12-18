---
name: file-locations
description: Authoritative reference for .devloop/ directory structure and file locations. Documents which files are git-tracked vs local-only, their purposes, and naming conventions. Use when creating devloop artifacts or understanding project structure.
---

# File Locations

**Purpose**: Define where devloop artifacts belong and whether they should be committed to git.

## When to Use This Skill

- Creating new devloop files (plans, reports, issues)
- Understanding what files to commit vs ignore
- Setting up a new project with devloop
- Troubleshooting file location issues
- Reviewing what artifacts exist in a project
- Migrating from old `.claude/` paths to `.devloop/`

## When NOT to Use This Skill

- Working with application code (not `.devloop/` files)
- General git operations (use `Skill: git-workflows`)
- Claude Code configuration (`.claude/` is separate)

---

## Directory Structure

```
.devloop/                     # Devloop's dedicated directory (v1.11.0+)
├── plan.md                   # Active implementation plan (git-tracked)
├── worklog.md                # Completed work history (git-tracked)
├── local.md                  # Local settings/preferences (NOT git-tracked)
├── context.json              # Tech stack cache (git-tracked)
│
├── issues/                   # Issue tracking (git-tracked)
│   ├── index.md              # Issue index and counts
│   ├── bugs.md               # Bug-only view
│   ├── features.md           # Feature-only view
│   ├── backlog.md            # Open features + tasks
│   ├── BUG-001.md            # Individual bug reports
│   ├── FEAT-001.md           # Feature requests
│   ├── TASK-001.md           # General tasks
│   ├── CHORE-001.md          # Maintenance tasks
│   └── SPIKE-001.md          # Technical investigations
│
└── spikes/                   # Spike investigation reports (NOT git-tracked)
    └── {topic}.md            # e.g., auth.md, caching.md
```

**Note**: Claude Code's `.claude/` directory remains separate and is not managed by devloop.

---

## File Categories

### Git-Tracked Files (Commit These)

| File/Directory | Purpose | Created By |
|----------------|---------|------------|
| `plan.md` | Active implementation plan with tasks | `/devloop`, task-planner |
| `worklog.md` | History of completed work with commits | post-commit hook |
| `context.json` | Cached tech stack detection | session-start hook |
| `issues/` | Issue tracking (bugs, features, tasks) | `/devloop:bug`, `/devloop:new` |

**Rationale**: These files represent shared project state that all team members need access to.

### Local-Only Files (Do NOT Commit)

| File/Directory | Purpose | Created By |
|----------------|---------|------------|
| `local.md` | Personal preferences, enforcement settings | User-created |
| `spikes/` | Exploratory investigation reports | `/devloop:spike` |

**Rationale**: These files contain local preferences or exploratory work that shouldn't be shared.

---

## File Naming Conventions

### Plans and Logs

| Pattern | Example | Purpose |
|---------|---------|---------|
| `plan.md` | Fixed name | Active plan (only one) |
| `worklog.md` | Fixed name | Work history |
| `local.md` | Fixed name | Local settings |
| `context.json` | Fixed name | Project context cache |

### Issues

| Pattern | Example | Purpose |
|---------|---------|---------|
| `BUG-NNN.md` | `BUG-001.md` | Bug reports |
| `FEAT-NNN.md` | `FEAT-001.md` | Feature requests |
| `TASK-NNN.md` | `TASK-001.md` | General tasks |
| `CHORE-NNN.md` | `CHORE-001.md` | Maintenance tasks |
| `SPIKE-NNN.md` | `SPIKE-001.md` | Technical investigations (issue tracker) |

### Spike Reports

| Pattern | Example | Purpose |
|---------|---------|---------|
| `spikes/{topic}.md` | `spikes/auth.md` | Spike investigation results |

---

## Detailed File Specifications

### plan.md

**Location**: `.devloop/plan.md`
**Git Status**: Tracked
**Created By**: `/devloop` command, task-planner agent
**Updated By**: `/devloop:continue`, task-checkpoint skill

**Format**:
```markdown
# Devloop Plan: [Feature Name]

**Created**: [YYYY-MM-DD]
**Updated**: [YYYY-MM-DD HH:MM]
**Status**: [Planning | In Progress | Review | Complete]
**Current Phase**: [Phase name]

## Overview
[Feature description]

## Tasks
### Phase 1: [Name]
- [ ] Task 1.1: [Description]
...

## Progress Log
- [YYYY-MM-DD HH:MM]: [Event]
```

**Lifecycle**:
1. Created when `/devloop` reaches Phase 6 (Planning)
2. Updated as tasks are started, completed, blocked
3. Progress Log entries added throughout
4. Status changes: Planning → In Progress → Review → Complete
5. On completion, final status written; plan may be archived

---

### worklog.md

**Location**: `.devloop/worklog.md`
**Git Status**: Tracked
**Created By**: Post-commit hook (first commit)
**Updated By**: Post-commit hook (automatic)

**Format**:
```markdown
# Devloop Worklog

## [Feature Name] (vX.Y.Z)

### Commits
- `abc1234` - 2024-12-11 14:30 - feat: add user authentication
- `def5678` - 2024-12-11 15:00 - test: add auth tests

### Tasks Completed
- [x] Task 1.1: Create user model
- [x] Task 1.2: Add authentication middleware
```

**Lifecycle**:
1. Created on first commit after plan exists
2. Updated automatically by post-commit hook
3. Entries move from plan's Progress Log to worklog
4. Provides historical record of all completed work

---

### local.md

**Location**: `.devloop/local.md`
**Git Status**: NOT Tracked (add to .gitignore)
**Created By**: User (manually or via template)
**Updated By**: User

**Format**:
```markdown
---
enforcement: advisory    # advisory | strict
auto_commit: true        # Prompt for commits after tasks
auto_version: true       # Suggest version bumps
changelog: true          # Maintain CHANGELOG.md
auto_tag: false          # Create git tags
---

# Local Notes

Personal preferences and notes for this project.
```

**Settings**:
| Setting | Default | Description |
|---------|---------|-------------|
| `enforcement` | `advisory` | How strictly to enforce plan updates |
| `auto_commit` | `true` | Prompt for atomic commits |
| `auto_version` | `true` | Suggest version bumps at phase completion |
| `changelog` | `true` | Offer to update CHANGELOG.md |
| `auto_tag` | `false` | Create git tags automatically |

---

### context.json

**Location**: `.devloop/context.json`
**Git Status**: Tracked
**Created By**: Session-start hook
**Updated By**: Session-start hook (refreshed periodically)

**Format**:
```json
{
  "project": "my-project",
  "description": "Project description",
  "techStack": {
    "language": "typescript",
    "framework": "next",
    "testFramework": "jest",
    "projectType": "webapp",
    "size": "medium"
  },
  "keyDirectories": ["src", "tests", "docs"],
  "configFiles": ["package.json", "tsconfig.json"],
  "detectedAt": "2024-12-11T10:00:00Z"
}
```

**Purpose**: Caches expensive tech stack detection to speed up session start.

---

### issues/ Directory

**Location**: `.devloop/issues/`
**Git Status**: Tracked
**Created By**: `/devloop:bug`, `/devloop:new`, issue-manager agent

**Structure**:
```
issues/
├── index.md              # Master index with counts
├── bugs.md               # Bug-only filtered view
├── features.md           # Feature-only filtered view
├── backlog.md            # Open features + tasks
├── BUG-001.md
├── FEAT-001.md
└── ...
```

**index.md Format**:
```markdown
# Issue Index

**Total**: 5 | **Open**: 3 | **Closed**: 2

## Open Issues
- [BUG-001](BUG-001.md): Login fails on mobile - High
- [FEAT-002](FEAT-002.md): Add dark mode - Medium

## Closed Issues
- [BUG-002](BUG-002.md): Fixed typo in header
```

**Issue File Format**: See `Skill: issue-tracking` for full specification.

---

### spikes/ Directory

**Location**: `.devloop/spikes/`
**Git Status**: NOT Tracked
**Created By**: `/devloop:spike` command

**Naming**: `{topic}.md` (e.g., `auth.md`, `caching.md`)

**Rationale for NOT tracking**:
- Exploratory/investigative work
- May contain dead ends or rejected approaches
- Conclusions flow into the plan; report is working notes

---

## .gitignore Template

Add these patterns to your project's `.gitignore`:

```gitignore
# Devloop local files (do not commit)
.devloop/local.md
.devloop/spikes/
```

See also: `plugins/devloop/templates/gitignore-devloop` for a copy-paste template.

---

## Decision Rationale

### Why use .devloop/ instead of .claude/?

- **Clean separation**: Devloop files are separate from Claude Code's `.claude/` directory
- **Simple gitignore**: Just ignore `local.md` and `spikes/` - no complex patterns
- **Clear ownership**: `.devloop/` = devloop plugin, `.claude/` = Claude Code core
- **Easier maintenance**: No confusion with other Claude tools' files

### Why track the plan?

- **Team visibility**: Everyone sees what's being worked on
- **Context preservation**: New sessions can pick up where you left off
- **Audit trail**: History of what was planned (worklog shows what was done)

### Why NOT track local settings?

- **Personal preference**: Enforcement levels vary by person
- **Environment-specific**: May differ between machines
- **Avoid conflicts**: Prevents merge conflicts on preferences

### Why NOT track spike reports?

- **Working notes**: Not polished deliverables
- **Exploration**: May contain rejected ideas
- **Flow to plan**: Conclusions become plan tasks; report is transient

---

## Migration Guide

### From .claude/ to .devloop/ (v1.10.x → v1.11.x)

If you have existing devloop files in `.claude/`:

| Old Location | New Location |
|--------------|--------------|
| `.claude/devloop-plan.md` | `.devloop/plan.md` |
| `.claude/devloop-worklog.md` | `.devloop/worklog.md` |
| `.claude/devloop.local.md` | `.devloop/local.md` |
| `.claude/project-context.json` | `.devloop/context.json` |
| `.claude/issues/` | `.devloop/issues/` |
| `.claude/bugs/` | `.devloop/issues/` |
| `.claude/*-spike-report.md` | `.devloop/spikes/*.md` |

**Migration Process**:
1. Session-start hook detects old files and prompts for migration
2. User confirms via AskUserQuestion
3. Files are moved to new locations (content preserved)
4. Old files can be deleted after verification

**Backwards Compatibility**:
- v1.11.x reads from `.devloop/` first, falls back to `.claude/` paths
- v1.12.0+ will remove fallback (migrate before upgrading)

### From bugs/ to issues/

If you have existing `.claude/bugs/` files:

1. Files move to `.devloop/issues/` with prefix: `BUG-001.md`
2. `type: bug` added to frontmatter
3. View files (`index.md`, `bugs.md`) generated automatically

### New Project Setup

1. Run `/devloop` to create initial plan
2. `.devloop/` directory created automatically
3. Add `.devloop/local.md` and `.devloop/spikes/` to `.gitignore`
4. Context will be detected and cached automatically

---

## See Also

- `Skill: plan-management` - Plan file format and update rules
- `Skill: issue-tracking` - Issue file format and workflows
- `Skill: worklog-management` - Worklog format and update rules
- `Skill: atomic-commits` - When and how to commit
- `/devloop:continue` - Resuming from a plan
