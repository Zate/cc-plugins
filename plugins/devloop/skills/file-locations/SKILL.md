---
name: file-locations
description: Authoritative reference for .claude/ directory structure and file locations. Documents which files are git-tracked vs local-only, their purposes, and naming conventions. Use when creating devloop artifacts or understanding project structure.
---

# File Locations

**Purpose**: Define where devloop artifacts belong and whether they should be committed to git.

## When to Use This Skill

- Creating new devloop files (plans, reports, issues)
- Understanding what files to commit vs ignore
- Setting up a new project with devloop
- Troubleshooting file location issues
- Reviewing what artifacts exist in a project

## When NOT to Use This Skill

- Working with application code (not .claude/ files)
- General git operations (use `Skill: git-workflows`)
- Project configuration outside .claude/ directory

---

## Directory Structure

```
.claude/
├── devloop-plan.md           # Active implementation plan (git-tracked)
├── devloop-worklog.md        # Completed work history (git-tracked)
├── devloop.local.md          # Local settings/preferences (NOT git-tracked)
├── project-context.json      # Tech stack cache (git-tracked)
│
├── issues/                   # Issue tracking (git-tracked)
│   ├── index.md              # Issue index and counts
│   ├── BUG-001.md            # Individual bug reports
│   ├── FEAT-001.md           # Feature requests
│   ├── TASK-001.md           # General tasks
│   ├── CHORE-001.md          # Maintenance tasks
│   └── SPIKE-001.md          # Technical investigations
│
├── bugs/                     # Legacy bug directory (migrate to issues/)
│   └── ...
│
├── security/                 # Security audit outputs (NOT git-tracked)
│   ├── audit-report.md       # Full audit report
│   └── findings/             # Individual findings
│
├── settings.local.json       # Claude Code local settings (NOT git-tracked)
├── commands/                 # Project-specific commands (git-tracked)
└── *-spike-report.md         # Spike investigation reports (NOT git-tracked)
```

---

## File Categories

### Git-Tracked Files (Commit These)

| File/Directory | Purpose | Created By |
|----------------|---------|------------|
| `devloop-plan.md` | Active implementation plan with tasks | `/devloop`, task-planner |
| `devloop-worklog.md` | History of completed work with commits | post-commit hook |
| `project-context.json` | Cached tech stack detection | session-start hook |
| `issues/` | Issue tracking (bugs, features, tasks) | `/devloop:bug`, `/devloop:new` |
| `commands/` | Project-specific slash commands | User-created |

**Rationale**: These files represent shared project state that all team members need access to.

### Local-Only Files (Do NOT Commit)

| File/Directory | Purpose | Created By |
|----------------|---------|------------|
| `devloop.local.md` | Personal preferences, enforcement settings | User-created |
| `settings.local.json` | Claude Code local configuration | Claude Code |
| `security/` | Security audit findings (may contain sensitive info) | `/security:audit` |
| `*-spike-report.md` | Exploratory investigation reports | `/devloop:spike` |

**Rationale**: These files contain local preferences, sensitive information, or exploratory work that shouldn't be shared.

---

## File Naming Conventions

### Plans and Logs

| Pattern | Example | Purpose |
|---------|---------|---------|
| `devloop-plan.md` | Fixed name | Active plan (only one) |
| `devloop-worklog.md` | Fixed name | Work history |
| `devloop.local.md` | Fixed name | Local settings |

### Issues

| Pattern | Example | Purpose |
|---------|---------|---------|
| `BUG-NNN.md` | `BUG-001.md` | Bug reports |
| `FEAT-NNN.md` | `FEAT-001.md` | Feature requests |
| `TASK-NNN.md` | `TASK-001.md` | General tasks |
| `CHORE-NNN.md` | `CHORE-001.md` | Maintenance tasks |
| `SPIKE-NNN.md` | `SPIKE-001.md` | Technical investigations |

### Reports

| Pattern | Example | Purpose |
|---------|---------|---------|
| `*-spike-report.md` | `auth-spike-report.md` | Spike investigation results |
| `security/audit-report.md` | Fixed path | Security audit output |

---

## Detailed File Specifications

### devloop-plan.md

**Location**: `.claude/devloop-plan.md`
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

### devloop-worklog.md

**Location**: `.claude/devloop-worklog.md`
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

### devloop.local.md

**Location**: `.claude/devloop.local.md`
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

### project-context.json

**Location**: `.claude/project-context.json`
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

**Location**: `.claude/issues/`
**Git Status**: Tracked
**Created By**: `/devloop:bug`, `/devloop:new`, issue-manager agent

**Structure**:
```
issues/
├── index.md              # Issue index with counts
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

### security/ Directory

**Location**: `.claude/security/`
**Git Status**: NOT Tracked
**Created By**: `/security:audit` command

**Structure**:
```
security/
├── audit-report.md       # Full audit report
├── findings/
│   ├── finding-001.md
│   └── ...
└── remediation-plan.md   # Optional remediation plan
```

**Rationale for NOT tracking**:
- May contain sensitive vulnerability details
- Could reveal security weaknesses if repo is public
- Findings should be addressed, not preserved in history

---

### Spike Reports

**Location**: `.claude/*-spike-report.md`
**Git Status**: NOT Tracked
**Created By**: `/devloop:spike` command

**Naming**: `{topic}-spike-report.md` (e.g., `auth-spike-report.md`)

**Rationale for NOT tracking**:
- Exploratory/investigative work
- May contain dead ends or rejected approaches
- Conclusions flow into the plan; report is working notes

---

## .gitignore Template

Add these patterns to your project's `.gitignore`:

```gitignore
# Devloop local files (do not commit)
.claude/devloop.local.md
.claude/settings.local.json
.claude/security/
.claude/*-spike-report.md

# Keep these tracked
!.claude/devloop-plan.md
!.claude/devloop-worklog.md
!.claude/project-context.json
!.claude/issues/
!.claude/commands/
```

See also: `plugins/devloop/templates/gitignore-devloop` for a copy-paste template.

---

## Decision Rationale

### Why track the plan?

- **Team visibility**: Everyone sees what's being worked on
- **Context preservation**: New sessions can pick up where you left off
- **Audit trail**: History of what was planned (worklog shows what was done)

### Why NOT track local settings?

- **Personal preference**: Enforcement levels vary by person
- **Environment-specific**: May differ between machines
- **Avoid conflicts**: Prevents merge conflicts on preferences

### Why NOT track security reports?

- **Sensitivity**: Vulnerability details are sensitive
- **Ephemeral**: Should be addressed and closed, not preserved
- **Public repos**: Would expose attack vectors

### Why NOT track spike reports?

- **Working notes**: Not polished deliverables
- **Exploration**: May contain rejected ideas
- **Flow to plan**: Conclusions become plan tasks; report is transient

---

## Migration Guide

### From bugs/ to issues/

If you have existing `.claude/bugs/` files:

1. Move files to `.claude/issues/` with prefix: `BUG-001.md`
2. Update internal links and references
3. Create `index.md` with issue listing

### From no .claude/ to devloop

1. Create `.claude/` directory
2. Copy `.gitignore` template (Task 1.2 will create this)
3. Run `/devloop` to create initial plan
4. Context will be detected and cached automatically

---

## See Also

- `Skill: plan-management` - Plan file format and update rules
- `Skill: issue-tracking` - Issue file format and workflows
- `Skill: atomic-commits` - When and how to commit
- `/devloop:continue` - Resuming from a plan
