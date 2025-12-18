# Devloop Plan: Consistency & Enforcement System

**Created**: 2025-12-18
**Updated**: 2025-12-18 15:35
**Status**: In Progress
**Current Phase**: Phase 1

## Overview

Implement a unified consistency and enforcement system for devloop that ensures:
1. Clear documentation of where files belong (git-tracked vs local-only)
2. Separation of active plan from completed work history (worklog)
3. Mandatory plan updates and commits after task completion
4. Happy path with clear checkpoints and recovery flows

**Spike Reference**: `.claude/devloop-consistency-spike-report.md`

## Requirements

1. All devloop artifacts have documented, consistent file locations
2. Completed work moves from plan to worklog on commit
3. Plan updates are enforced (strict by default, configurable)
4. Commits only succeed when plan is in sync
5. Recovery flows handle out-of-sync scenarios gracefully
6. Existing workflows continue to work (backwards compatible)

## Architecture

**File Structure**:
```
.claude/
├── devloop-plan.md         # Active plan (git-tracked)
├── devloop-worklog.md      # Completed work history (git-tracked)
├── devloop.local.md        # Local settings/overrides (NOT git-tracked)
├── project-context.json    # Tech detection cache (git-tracked)
├── issues/                 # Issue tracking (git-tracked)
│   ├── index.md
│   ├── BUG-001.md
│   └── ...
├── security/               # Security audit reports (NOT git-tracked)
└── *-spike-report.md       # Spike reports (NOT git-tracked)
```

**Enforcement Flow**:
```
Task Complete → Plan Update (REQUIRED) → Commit Decision
                                              ↓
                        PreCommit Hook (verifies plan sync)
                                              ↓
                              Git Commit (proceeds)
                                              ↓
                        PostCommit Hook (updates worklog)
```

## Tasks

### Phase 1: Foundation [parallel:none]
**Goal**: Document file locations and provide clear guidance

- [x] Task 1.1: Create `file-locations` skill
  - Acceptance: SKILL.md documenting all .claude/ files, what they're for, and git tracking status
  - Files: `plugins/devloop/skills/file-locations/SKILL.md`
  - Notes: Include rationale for each decision

- [x] Task 1.2: Create `.gitignore` template for devloop
  - Acceptance: Template file users can copy, excludes local-only files
  - Files: `plugins/devloop/templates/gitignore-devloop`
  - Notes: Include comments explaining each entry

- [ ] Task 1.3: Update CLAUDE.md with file location guidance
  - Acceptance: CLAUDE.md section on .claude/ directory structure
  - Files: `CLAUDE.md`
  - Notes: Reference file-locations skill for details

### Phase 2: Worklog System [parallel:partial]
**Goal**: Separate completed work from active plan
**Parallel Groups**:
- Group A: Tasks 2.1, 2.2 (independent skill creation)

- [ ] Task 2.1: Create `worklog-management` skill [parallel:A]
  - Acceptance: SKILL.md with worklog format, update rules, integration points
  - Files: `plugins/devloop/skills/worklog-management/SKILL.md`
  - Notes: Document when entries move from plan to worklog

- [ ] Task 2.2: Update `task-checkpoint` skill for worklog [parallel:A]
  - Acceptance: Skill mentions worklog update as part of commit flow
  - Files: `plugins/devloop/skills/task-checkpoint/SKILL.md`
  - Notes: Add worklog section to checkpoint checklist

- [ ] Task 2.3: Initialize worklog in devloop command [depends:2.1]
  - Acceptance: /devloop creates worklog file alongside plan
  - Files: `plugins/devloop/commands/devloop.md`
  - Notes: Also update /devloop:continue to read worklog

- [ ] Task 2.4: Update summary-generator to use worklog [depends:2.1]
  - Acceptance: Agent reads worklog for session summaries
  - Files: `plugins/devloop/agents/summary-generator.md`
  - Notes: Worklog is source of truth for what was done

### Phase 3: Enforcement Hooks [parallel:partial]
**Goal**: Make plan updates and commits mandatory
**Parallel Groups**:
- Group A: Tasks 3.1, 3.2 (independent hook implementation)

- [ ] Task 3.1: Add PreCommit hook to hooks.json [parallel:A]
  - Acceptance: Hook runs before git commit, blocks if plan not updated
  - Files: `plugins/devloop/hooks/hooks.json`
  - Notes: Matcher should catch "Bash" with "git commit" in command

- [ ] Task 3.2: Implement pre-commit.sh verification [parallel:A]
  - Acceptance: Script checks plan status, returns approve/block
  - Files: `plugins/devloop/hooks/pre-commit.sh`
  - Notes: Check for [x] tasks without Progress Log entries

- [ ] Task 3.3: Add PostCommit hook to hooks.json [depends:3.1]
  - Acceptance: Hook runs after successful git commit
  - Files: `plugins/devloop/hooks/hooks.json`
  - Notes: Matcher catches successful git commit output

- [ ] Task 3.4: Implement post-commit.sh worklog updater [depends:3.2,3.3]
  - Acceptance: Script moves Progress Log entries to worklog with commit hash
  - Files: `plugins/devloop/hooks/post-commit.sh`
  - Notes: Get commit hash from git rev-parse HEAD

- [ ] Task 3.5: Update devloop.local.md template with enforcement settings
  - Acceptance: Template includes enforcement config with strict defaults
  - Files: `plugins/devloop/templates/devloop.local.md`
  - Notes: Document all enforcement options

- [ ] Task 3.6: Update plan-management skill with enforcement docs [depends:3.5]
  - Acceptance: Skill documents enforcement modes and configuration
  - Files: `plugins/devloop/skills/plan-management/SKILL.md`
  - Notes: Add Enforcement section with examples

### Phase 4: Recovery & Polish [parallel:partial]
**Goal**: Handle edge cases and improve UX
**Parallel Groups**:
- Group A: Tasks 4.1, 4.2 (independent recovery flows)

- [ ] Task 4.1: Implement recovery prompts in continue.md [parallel:A]
  - Acceptance: Command detects out-of-sync states and offers recovery
  - Files: `plugins/devloop/commands/continue.md`
  - Notes: Handle: plan not updated, commit without task, worklog drift

- [ ] Task 4.2: Add worklog reconstruction command [parallel:A]
  - Acceptance: Command rebuilds worklog from git history
  - Files: `plugins/devloop/commands/worklog.md` (new)
  - Notes: Useful for existing projects adopting devloop

- [ ] Task 4.3: Update devloop README with workflow diagrams [depends:4.1,4.2]
  - Acceptance: README shows happy path and recovery flows
  - Files: `plugins/devloop/README.md`
  - Notes: Use ASCII or mermaid diagrams

- [ ] Task 4.4: Version bump and release notes [depends:4.3]
  - Acceptance: Bump to 1.10.0, document new enforcement system
  - Files: `plugins/devloop/.claude-plugin/plugin.json`
  - Notes: Major feature addition

## Progress Log
- 2025-12-18 14:00: Plan created from spike report findings
- 2025-12-18 15:30: Completed Task 1.1 - Created file-locations skill with comprehensive documentation of .claude/ structure, git tracking status, and rationale
- 2025-12-18 15:35: Completed Task 1.2 - Created gitignore-devloop template with commented sections and troubleshooting guide

## Notes

- Start with strict enforcement for new projects, advisory for existing
- Worklog is optional initially - can reconstruct from git log
- Focus on happy path first, recovery in Phase 4
- All hooks should timeout quickly (<10s) to avoid blocking
