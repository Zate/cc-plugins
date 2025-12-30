# State Management

This document describes the files and data structures devloop uses to maintain state across sessions.

---

## Overview

Devloop maintains state in the `.devloop/` directory:

```
.devloop/
├── plan.md               # Active plan (git-tracked)
├── plan-state.json       # Machine-readable plan state
├── worklog.md            # Completed work history (git-tracked)
├── local.md              # Local settings (NOT git-tracked)
├── context.json          # Tech stack cache (git-tracked)
├── next-action.json      # Fresh start state (temporary)
├── sessions.json         # Session history
├── issues/               # Issue tracking (git-tracked)
│   ├── index.md
│   ├── bugs.md
│   ├── features.md
│   ├── backlog.md
│   └── {TYPE}-{NUM}.md
├── spikes/               # Spike reports (NOT git-tracked)
└── archive/              # Archived plans and worklogs
```

---

## Plan Files

### plan.md

The active plan file. This is the source of truth for current work.

**Format**:

```markdown
# Devloop Plan: {Feature Name}

**Created**: {Date}
**Status**: {Draft | In Progress | Review | Complete}
**Current Phase**: {Phase Name}
**Complexity**: {XS | S | M | L | XL}

## Overview
{Feature description}

## Architecture Decision
{Chosen approach and rationale}

## Tasks

### Phase 1: {Phase Name}
- [ ] Task 1.1: {Description}
  - Acceptance: {Criteria}
  - Files: {Expected files}
- [~] Task 1.2: {Description} (partial)
- [x] Task 1.3: {Description} (complete)

### Phase 2: {Phase Name}  [parallel:partial]
**Parallel Groups**:
- Group A: Tasks 2.1, 2.2

- [ ] Task 2.1: {Description}  [parallel:A]
- [ ] Task 2.2: {Description}  [parallel:A]
- [ ] Task 2.3: {Description}  [depends:2.1,2.2]

## Progress Log
- {Date}: Plan created
- {Date}: Phase 1 complete
```

**Task Markers**:

| Marker | Meaning |
|--------|---------|
| `[ ]` | Pending |
| `[~]` | In Progress / Partial |
| `[x]` | Complete |

**Parallelism Markers**:

| Marker | Meaning |
|--------|---------|
| `[parallel:X]` | Can run with other tasks in group X |
| `[depends:N.M]` | Must wait for task N.M |
| `[background]` | Low priority background task |
| `[sequential]` | Must run alone |

---

### plan-state.json

Machine-readable plan state for programmatic access.

**Format**:

```json
{
  "name": "User Authentication",
  "status": "in_progress",
  "currentPhase": "Implementation",
  "complexity": "M",
  "created": "2024-12-30T10:00:00Z",
  "updated": "2024-12-30T15:30:00Z",
  "phases": [
    {
      "name": "Foundation",
      "number": 1,
      "status": "complete",
      "tasks": [
        {
          "id": "1.1",
          "description": "Create user model",
          "status": "complete",
          "completedAt": "2024-12-30T11:00:00Z"
        }
      ]
    }
  ],
  "progress": {
    "total": 12,
    "complete": 4,
    "partial": 1,
    "pending": 7,
    "percentage": 33
  }
}
```

---

## Worklog

### worklog.md

History of completed work with commit references.

**Format**:

```markdown
# Devloop Worklog

## Active Session
- {Date} {Time}: Started Task 2.3 (Implement refresh tokens)

## Completed Work

### 2024-12-30

#### User Authentication - Phase 1
- [x] Task 1.1: Create user model
  - Commit: `abc1234` - feat(auth): add user model with password hashing
  - Files: models/user.go, models/user_test.go
  
- [x] Task 1.2: Set up JWT token service
  - Commit: `def5678` - feat(auth): implement JWT token generation
  - Files: services/auth.go, middleware/jwt.go

#### User Authentication - Phase 2
- [x] Task 2.1: Add login endpoint
  - Commit: `ghi9012` - feat(auth): add login endpoint with validation
  - Files: handlers/auth.go, routes/auth.go
```

**Rotation**:
When worklog exceeds 500 lines, it's archived to:
`archive/worklog-{date}.md`

---

## Session State

### next-action.json

Saved state for fresh start mechanism.

**Format**:

```json
{
  "version": "1.0",
  "savedAt": "2024-12-30T15:30:00Z",
  "plan": {
    "name": "User Authentication",
    "file": ".devloop/plan.md"
  },
  "lastCompletedTask": {
    "id": "2.1",
    "description": "Add login endpoint"
  },
  "nextTask": {
    "id": "2.2",
    "description": "Add registration endpoint"
  },
  "sessionMetrics": {
    "tasksCompleted": 4,
    "agentInvocations": 8,
    "durationMinutes": 45,
    "contextUsagePercent": 67
  },
  "uncommittedWork": [],
  "notes": "Login flow complete, registration next"
}
```

**Lifecycle**:
1. Created by `/devloop:fresh`
2. Read by `/devloop:continue`
3. Deleted after successful resume

---

### sessions.json

Session history for analytics.

**Format**:

```json
{
  "sessions": [
    {
      "id": "sess_abc123",
      "startedAt": "2024-12-30T10:00:00Z",
      "endedAt": "2024-12-30T11:30:00Z",
      "plan": "User Authentication",
      "tasksCompleted": 4,
      "commits": ["abc1234", "def5678"],
      "freshStartTriggered": true
    }
  ]
}
```

---

## Configuration

### local.md

Local settings (NOT git-tracked).

**Format**:

```markdown
---
enforcement: advisory
commitStyle: conventional
defaultBranch: main
---

# Local Devloop Settings

## Preferences
- Auto-commit after each task: false
- Fresh start threshold: 50% context
- Show statusline: true

## Custom DoD
Additional definition of done criteria for this project:
- [ ] Documentation updated
- [ ] Performance tested

## Notes
Any personal notes about the project setup.
```

**Enforcement Modes**:

| Mode | Behavior |
|------|----------|
| `advisory` | Warns when plan out of sync |
| `strict` | Blocks commits until plan updated |

---

### context.json

Cached project context (git-tracked for team sharing).

**Format**:

```json
{
  "detected": "2024-12-30T10:00:00Z",
  "language": "go",
  "version": "1.21",
  "framework": null,
  "testFramework": "testing",
  "buildTool": "go build",
  "packageManager": "go mod",
  "features": {
    "hasTests": true,
    "hasDocker": true,
    "hasCI": true,
    "hasMakefile": true
  },
  "paths": {
    "source": "./",
    "tests": "./**/*_test.go",
    "docs": "./docs"
  }
}
```

---

## Issue Tracking

### issues/index.md

Master index of all issues.

**Format**:

```markdown
# Issues Index

| ID | Type | Priority | Status | Title |
|----|------|----------|--------|-------|
| BUG-001 | bug | high | open | Login fails on mobile |
| FEAT-001 | feature | medium | planned | Add dark mode |
| TASK-001 | task | low | open | Refactor auth module |
```

### Individual Issue Files

Each issue has its own file: `{TYPE}-{NUM}.md`

**Format**:

```markdown
---
id: BUG-001
type: bug
priority: high
status: open
created: 2024-12-30
labels: [auth, mobile]
---

# Login fails on mobile

## Description
Users report that login button doesn't respond on iOS Safari.

## Steps to Reproduce
1. Open app on iOS Safari
2. Navigate to login
3. Tap login button
4. Nothing happens

## Expected Behavior
Login form should submit.

## Investigation Notes
- Possibly touch event not registered
- May be CSS issue with button area

## Related
- FEAT-002: Mobile optimization
```

### View Files

Pre-generated views for common queries:

| File | Contents |
|------|----------|
| `bugs.md` | All bugs |
| `features.md` | All features |
| `backlog.md` | Open features + tasks |

---

## Archive

### archive/

Archived plans and worklogs.

**Naming Convention**:
- Plans: `{plan-slug}_phase_{N}_{date}.md`
- Worklogs: `worklog-{date}.md`

**Example**:
```
archive/
├── user-auth_phase_1_20241228.md
├── user-auth_phase_2_20241229.md
├── worklog-2024-12-25.md
└── worklog-2024-12-28.md
```

---

## Git Tracking Summary

| File/Directory | Git Status | Rationale |
|----------------|------------|-----------|
| `plan.md` | Tracked | Team visibility, history |
| `plan-state.json` | Tracked | Machine-readable state |
| `worklog.md` | Tracked | Work history |
| `context.json` | Tracked | Team config sharing |
| `issues/` | Tracked | Team issue tracking |
| `archive/` | Tracked | Historical reference |
| `local.md` | **NOT** tracked | Personal preferences |
| `next-action.json` | **NOT** tracked | Session-specific |
| `sessions.json` | **NOT** tracked | Personal analytics |
| `spikes/` | **NOT** tracked | Working notes |

### Recommended .gitignore

```gitignore
# Devloop local files
.devloop/local.md
.devloop/next-action.json
.devloop/sessions.json
.devloop/spikes/
.devloop/.current-session.json
```

---

## State Transitions

### Plan Status Flow

```
Draft → In Progress → Review → Complete
         ↑                ↓
         └── (revisions) ─┘
```

### Task Status Flow

```
[ ] Pending
 │
 ├── Start work ──→ [~] Partial
 │                    │
 │                    ├── Complete ──→ [x] Complete
 │                    │
 │                    └── Block ──→ [ ] Pending (with note)
 │
 └── Complete directly ──→ [x] Complete
```

---

## Synchronization

### Plan ↔ JSON Sync

The `sync-plan-state.sh` script keeps `plan.md` and `plan-state.json` in sync:

```bash
# Sync from markdown to JSON
./scripts/sync-plan-state.sh md2json

# Sync from JSON to markdown
./scripts/sync-plan-state.sh json2md
```

### Worklog Updates

After commits, the post-commit hook updates worklog:

```
Commit created: abc1234
  ↓
post-commit.sh runs
  ↓
Extracts: commit hash, message, files
  ↓
Updates worklog.md with entry
  ↓
Marks corresponding task [x] in plan
```

---

## Next Steps

- [Architecture](01-architecture.md) - How state fits in the system
- [Component Guide](05-component-guide.md) - Components that use state
- [Contributing](07-contributing.md) - Working with state files
