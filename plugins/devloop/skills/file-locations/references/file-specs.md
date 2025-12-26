# Detailed File Specifications

## plan.md

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

## worklog.md

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

## local.md

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

## context.json

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

## issues/ Directory

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

## spikes/ Directory

**Location**: `.devloop/spikes/`
**Git Status**: NOT Tracked
**Created By**: `/devloop:spike` command

**Naming**: `{topic}.md` (e.g., `auth.md`, `caching.md`)

**Rationale for NOT tracking**:
- Exploratory/investigative work
- May contain dead ends or rejected approaches
- Conclusions flow into the plan; report is working notes
