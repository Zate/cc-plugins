# Devloop Plan: Unified Issue Tracking System

**Created**: 2025-12-18
**Updated**: 2025-12-18 12:00
**Status**: In Progress
**Current Phase**: Phase 3 (complete)

## Overview

Extend the existing bugs tracking system into a unified "issues" system that supports bugs, features, tasks, and other work items. Introduces smart `/devloop:new` command for intelligent routing, type-prefixed IDs (BUG-001, FEAT-001, TASK-001), and auto-generated view files for focused workflows.

## Requirements

1. Support multiple issue types: bug, feature, task, chore, spike
2. Type-prefixed IDs for immediate context (BUG-xxx, FEAT-xxx, TASK-xxx)
3. Smart `/devloop:new` command that analyzes input and routes to correct type
4. Auto-generated view files (bugs.md, features.md, backlog.md)
5. Backwards compatibility with existing `/devloop:bug` and `/devloop:bugs` commands
6. Single `.claude/issues/` directory as source of truth
7. Committable to git for project persistence

## Architecture

**Directory Structure:**
```
.claude/issues/
├── index.md          # Master index (all issues)
├── bugs.md           # View: type:bug only
├── features.md       # View: type:feature only
├── backlog.md        # View: open features + tasks
├── BUG-001.md        # Bug issues
├── FEAT-001.md       # Feature issues
├── TASK-001.md       # Task issues
└── ...
```

**Smart Routing Keywords:**
- bug: "bug", "broken", "doesn't work", "error", "crash", "fix"
- feature: "add", "new", "implement", "create", "build", "feature"
- task: "refactor", "clean up", "improve", "optimize", "update"
- chore: "chore", "maintenance", "upgrade", "dependency"

## Tasks

### Phase 1: Core Skill and Schema [parallel:partial]
**Parallelizable**: partial
**Parallel Groups**:
- Group A: Tasks 1.1, 1.2 (independent skill creation)

- [x] Task 1.1: Create `issue-tracking` skill extending bug-tracking  [parallel:A]
  - Acceptance: SKILL.md with full schema, type definitions, ID prefix rules
  - Files: `plugins/devloop/skills/issue-tracking/SKILL.md`
  - Notes: Include migration guidance from bug-tracking

- [x] Task 1.2: Define view file generation rules  [parallel:A]
  - Acceptance: Document how views are generated/maintained in skill
  - Files: Part of SKILL.md above
  - Notes: Views regenerated on any issue create/update/delete

### Phase 2: Commands [parallel:partial]
**Parallelizable**: partial
**Parallel Groups**:
- Group A: Tasks 2.1, 2.2 (independent command creation)
- Group B: Task 2.3 (depends on both commands existing)

- [x] Task 2.1: Create `/devloop:new` command with smart routing  [parallel:A]
  - Acceptance: Command analyzes input, detects type, asks confirmation, creates issue
  - Files: `plugins/devloop/commands/new.md`
  - Notes: Support both single and multiple item creation

- [x] Task 2.2: Create `/devloop:issues` command (extends bugs)  [parallel:A]
  - Acceptance: View/filter/manage all issue types, backwards compat with bugs
  - Files: `plugins/devloop/commands/issues.md`
  - Notes: Support filters: all, bugs, features, backlog, by-label

- [x] Task 2.3: Update existing bug commands as aliases  [depends:2.1,2.2]
  - Acceptance: `/devloop:bug` → creates type:bug, `/devloop:bugs` → filters to bugs
  - Files: `plugins/devloop/commands/bug.md`, `plugins/devloop/commands/bugs.md`
  - Notes: Add deprecation notice, redirect to new commands

### Phase 3: Agent Updates [parallel:partial]
**Parallelizable**: partial
**Parallel Groups**:
- Group A: Tasks 3.1, 3.2 (independent agent updates)

- [x] Task 3.1: Create `issue-manager` agent (extends bug-catcher)  [parallel:A]
  - Acceptance: Agent can create any issue type, update views
  - Files: `plugins/devloop/agents/issue-manager.md`
  - Notes: Should be invokable by other agents to log issues

- [x] Task 3.2: Update workflow-detector to route to issues  [parallel:A]
  - Acceptance: Detector recognizes issue-related requests, routes appropriately
  - Files: `plugins/devloop/agents/workflow-detector.md`
  - Notes: Add issue patterns to detection logic

### Phase 4: Integration and Testing [sequential]
**Parallelizable**: none

- [ ] Task 4.1: Update devloop README with issue tracking docs  [sequential]
  - Acceptance: README documents new issue system, commands, migration
  - Files: `plugins/devloop/README.md`

- [ ] Task 4.2: Create migration guide for existing .claude/bugs/  [depends:4.1]
  - Acceptance: Clear steps to migrate bugs → issues
  - Files: `plugins/devloop/docs/MIGRATION.md` or in README

- [ ] Task 4.3: Version bump and changelog  [depends:4.1,4.2]
  - Acceptance: Bump to 1.9.0, document new feature
  - Files: `plugins/devloop/.claude-plugin/plugin.json`

## Progress Log
- 2025-12-18 10:30: Plan created from spike findings (.claude/unified-issues-spike-report.md)
- 2025-12-18 11:15: Completed Tasks 1.1 & 1.2 - Created issue-tracking skill with full schema, type definitions, ID prefix rules, and view generation rules
- 2025-12-18 11:45: Completed Phase 2 (Tasks 2.1, 2.2, 2.3) - Created /devloop:new and /devloop:issues commands, updated bug/bugs as aliases
- 2025-12-18 12:00: Completed Phase 3 (Tasks 3.1, 3.2) - Created issue-manager agent, updated workflow-detector with issue tracking routing
