---
id: TASK-001
type: task
title: Consolidate devloop files into .claude/devloop/ directory
status: open
priority: medium
created: 2025-12-18T12:10:00
updated: 2025-12-18T12:10:00
reporter: user
assignee: null
labels: [devloop, refactor, migration]
estimate: M
related-files:
  - plugins/devloop/skills/file-locations/SKILL.md
  - plugins/devloop/skills/plan-management/SKILL.md
  - .claude/devloop-plan.md
  - .claude/devloop-worklog.md
  - .claude/devloop.local.md
  - .claude/issues/
---

# TASK-001: Consolidate devloop files into .claude/devloop/ directory

## Description

Reorganize all devloop-related files from scattered locations in `.claude/` into a unified `.claude/devloop/` directory. This improves organization and makes the devloop namespace clearer.

## Current Structure

```
.claude/
├── devloop-plan.md           # Plan file
├── devloop-worklog.md        # Work history
├── devloop.local.md          # Local settings
├── issues/                   # Issue tracking
│   ├── index.md
│   ├── bugs.md
│   ├── features.md
│   ├── backlog.md
│   └── {TYPE}-{NNN}.md
├── project-context.json      # Project context cache
└── *-spike-report.md         # Spike reports
```

## Proposed Structure

```
.claude/
└── devloop/
    ├── plan.md               # Was: devloop-plan.md
    ├── worklog.md            # Was: devloop-worklog.md
    ├── local.md              # Was: devloop.local.md (NOT git-tracked)
    ├── context.json          # Was: project-context.json
    ├── issues/               # Moved from .claude/issues/
    │   ├── index.md
    │   ├── bugs.md
    │   ├── features.md
    │   ├── backlog.md
    │   └── {TYPE}-{NNN}.md
    └── spikes/               # Spike reports
        └── *-spike-report.md
```

## Scope

### Files/Skills to Update

1. **Skills**:
   - `file-locations/SKILL.md` - Update all path references
   - `plan-management/SKILL.md` - Update plan file path
   - `issue-tracking/SKILL.md` - Update issues directory path
   - `worklog-management/SKILL.md` - Update worklog path
   - `project-context/SKILL.md` - Update context.json path

2. **Commands**:
   - All commands referencing `.claude/devloop-*` files
   - `continue.md`, `ship.md`, `spike.md`, etc.

3. **Agents**:
   - Any agents with hardcoded paths

4. **Hooks**:
   - Pre-commit and post-commit hooks referencing plan/worklog

### Migration Script

Need to create a migration utility that:
- Detects existing `.claude/devloop-*` files
- Creates `.claude/devloop/` directory
- Moves files to new locations
- Updates any internal references (e.g., links in plan.md)
- Optionally cleans up old files after verification

## Acceptance Criteria

- [ ] All devloop files consolidated under `.claude/devloop/`
- [ ] All skills updated with new paths
- [ ] All commands updated with new paths
- [ ] All agents updated with new paths
- [ ] All hooks updated with new paths
- [ ] Migration script/command created
- [ ] Migration handles partial migrations gracefully
- [ ] .gitignore patterns updated for new structure
- [ ] README/documentation updated

## Notes

- This is a breaking change for existing users
- Migration must be backwards-compatible (detect old vs new structure)
- Consider a deprecation period where both paths are checked

## Related Issues

- SPIKE-001: May inform migration approach for existing codebases
- FEAT-001: Form-like creation will need new paths

## Resolution

<!-- Filled in when done -->
- **Resolved in**:
- **Resolved by**:
- **Resolution summary**:
