# Devloop Plan: Structured Plan Format & Script-First Workflow

**Created**: 2025-12-27
**Updated**: 2025-12-27T12:30:00Z
**Status**: In Progress
**Current Phase**: Phase 1

## Overview

Migrate devloop to use a JSON state file as the machine-readable source of truth, keeping plan.md for human readability. Convert high-token workflow operations to deterministic scripts, reducing workflow token usage by ~80%.

**Source**: Spike investigation "Structured Plan Format & Script-First Workflow"
- Spike report: `.devloop/spikes/structured-plan-format.md`

## Architecture

**Core Concept**: Dual-file state management
- `plan.md` - Human-readable markdown (primary authoring)
- `plan-state.json` - Machine-readable JSON (script consumption)
- Hooks trigger sync between the two

**Token Reduction Strategy**:
- Scripts handle all deterministic operations (parsing, counting, file operations)
- Agents only handle: routing decisions, user interaction, creative content generation
- Commands become thin wrappers that call scripts + present choices

## Success Criteria

1. [ ] `plan-state.json` automatically stays in sync with `plan.md`
2. [ ] `/devloop:fresh` uses 0 LLM tokens (pure script)
3. [ ] `/devloop:archive` uses <500 tokens (routing only)
4. [ ] Issue creation/listing uses <300 tokens per operation
5. [ ] Session startup shows plan status without LLM (script-based)
6. [ ] Backward compatible with existing plan.md files
7. [ ] 80%+ token reduction measured for typical workflow session

## Tasks

### Phase 1: Core Infrastructure
**Goal**: Create the sync mechanism and JSON state schema

- [x] Task 1.1: Define JSON schema for plan-state.json
  - Acceptance: Schema file with all fields documented
  - Files: `plugins/devloop/schemas/plan-state.schema.json`

- [x] Task 1.2: Create sync-plan-state.sh script [parallel:A]
  - Acceptance: Parses plan.md, outputs valid JSON to plan-state.json
  - Files: `plugins/devloop/scripts/sync-plan-state.sh`
  - Notes: Must handle all task markers: `[ ]`, `[x]`, `[~]`, `[!]`, `[-]`

- [x] Task 1.3: Create validate-plan-state.sh script [parallel:A]
  - Acceptance: Validates JSON against schema, reports errors
  - Files: `plugins/devloop/scripts/validate-plan-state.sh`

- [x] Task 1.4: Add sync trigger to session-start hook [depends:1.2]
  - Acceptance: plan-state.json created/updated on session start
  - Files: `plugins/devloop/hooks/session-start.sh`

- [x] Task 1.5: Add sync trigger to pre-commit hook [depends:1.2]
  - Acceptance: plan-state.json validated before commits
  - Files: `plugins/devloop/hooks/pre-commit.sh`

### Phase 2: Script Migration - High Value
**Goal**: Convert highest-token operations to scripts

- [ ] Task 2.1: Create fresh-start.sh to replace fresh.md logic [parallel:B]
  - Acceptance: Generates next-action.json without any LLM calls
  - Files: `plugins/devloop/scripts/fresh-start.sh`
  - Token savings: ~2,000 tokens per invocation

- [ ] Task 2.2: Update fresh.md to call fresh-start.sh [depends:2.1]
  - Acceptance: Command is < 50 lines, only handles edge cases
  - Files: `plugins/devloop/commands/fresh.md`

- [ ] Task 2.3: Create archive-interactive.sh [parallel:B]
  - Acceptance: Detects complete phases, performs archival, needs no LLM
  - Files: `plugins/devloop/scripts/archive-interactive.sh`
  - Token savings: ~2,500 tokens per invocation

- [ ] Task 2.4: Update archive.md to call archive-interactive.sh [depends:2.3]
  - Acceptance: Command only handles user confirmation and errors
  - Files: `plugins/devloop/commands/archive.md`

- [ ] Task 2.5: Update format-plan-status.sh to read from plan-state.json [depends:1.2]
  - Acceptance: No markdown parsing, reads JSON directly
  - Files: `plugins/devloop/scripts/format-plan-status.sh`

- [ ] Task 2.6: Update calculate-progress.sh to read from plan-state.json [depends:1.2]
  - Acceptance: Falls back to parsing if JSON missing (backward compat)
  - Files: `plugins/devloop/scripts/calculate-progress.sh`

### Phase 3: Script Migration - Issue Tracking
**Goal**: Make issue tracking mostly script-driven

- [ ] Task 3.1: Create create-issue.sh [parallel:C]
  - Acceptance: Creates BUG-NNN.md or FEAT-NNN.md with correct structure
  - Files: `plugins/devloop/scripts/create-issue.sh`
  - Token savings: ~2,000 tokens per invocation

- [ ] Task 3.2: Create list-issues.sh [parallel:C]
  - Acceptance: Lists issues with filtering (type, status), outputs markdown or JSON
  - Files: `plugins/devloop/scripts/list-issues.sh`

- [ ] Task 3.3: Create update-issue.sh [parallel:C]
  - Acceptance: Updates issue status, adds comments
  - Files: `plugins/devloop/scripts/update-issue.sh`

- [ ] Task 3.4: Update issues.md to use issue scripts [depends:3.1,3.2,3.3]
  - Acceptance: Command reduced to routing + user questions
  - Files: `plugins/devloop/commands/issues.md`

- [ ] Task 3.5: Update new.md to use create-issue.sh [depends:3.1]
  - Acceptance: Only uses LLM for type detection when ambiguous
  - Files: `plugins/devloop/commands/new.md`

- [ ] Task 3.6: Update bugs.md to use list-issues.sh [depends:3.2]
  - Acceptance: Pure script invocation + display
  - Files: `plugins/devloop/commands/bugs.md`

### Phase 4: Command Simplification
**Goal**: Reduce continue.md and other commands to thin wrappers

- [ ] Task 4.1: Extract task routing logic to select-next-task.sh
  - Acceptance: Determines next task, respects dependencies/parallelism
  - Files: `plugins/devloop/scripts/select-next-task.sh`

- [ ] Task 4.2: Extract plan display to show-plan-status.sh
  - Acceptance: Renders plan progress without LLM
  - Files: `plugins/devloop/scripts/show-plan-status.sh`

- [ ] Task 4.3: Simplify continue.md Step 1 (Find Plan) [depends:4.2]
  - Acceptance: Uses detect-plan.sh and show-plan-status.sh
  - Files: `plugins/devloop/commands/continue.md`

- [ ] Task 4.4: Simplify continue.md Step 2 (Parse Status) [depends:4.1]
  - Acceptance: Uses select-next-task.sh for task selection
  - Files: `plugins/devloop/commands/continue.md`

- [ ] Task 4.5: Update statusline to use plan-state.json [depends:1.2]
  - Acceptance: Faster statusline rendering (no markdown parsing)
  - Files: `plugins/devloop/statusline/devloop-statusline.sh`

### Phase 5: Documentation & Validation
**Goal**: Document the new system and validate token savings

- [ ] Task 5.1: Update plan-management skill with JSON state info
  - Acceptance: Explains dual-file model, sync triggers
  - Files: `plugins/devloop/skills/plan-management/SKILL.md`

- [ ] Task 5.2: Create migration guide for existing plans
  - Acceptance: Step-by-step instructions for users
  - Files: `plugins/devloop/docs/migration-to-json-state.md`

- [ ] Task 5.3: Add unit tests for sync-plan-state.sh
  - Acceptance: Tests for all task markers, edge cases
  - Files: `plugins/devloop/tests/sync-plan-state.bats`

- [ ] Task 5.4: Measure token usage before/after
  - Acceptance: Document actual savings vs projected
  - Files: `.devloop/spikes/structured-plan-format.md` (update with results)

- [ ] Task 5.5: Update CHANGELOG.md with new features
  - Acceptance: Entry for structured state support
  - Files: `plugins/devloop/CHANGELOG.md`

- [ ] Task 5.6: Bump version to reflect improvements
  - Acceptance: Update plugin.json version
  - Files: `plugins/devloop/.claude-plugin/plugin.json`

## Progress Log

- 2025-12-27 12:30: Completed Task 1.5 - Added sync trigger to pre-commit hook (syncs and validates plan-state.json)
- 2025-12-27 12:15: Completed Task 1.4 - Added sync trigger to session-start hook
- 2025-12-27 01:05: Fresh start initiated - state saved to next-action.json
- 2025-12-27 01:00: Completed Tasks 1.1-1.3 (schema + sync/validate scripts) - committed
- 2025-12-27 12:00: Plan created from spike findings

## Notes

**Backward Compatibility**:
- plan-state.json is optional; scripts fall back to markdown parsing
- No changes required to existing plan.md files
- Sync script creates JSON on first run

**Git Tracking**:
- plan-state.json should be git-tracked (team visibility)
- Add to .gitignore only if teams prefer per-developer state

**Dependencies**:
- `jq` for JSON manipulation (available on most systems)
- Existing scripts (calculate-progress.sh, etc.) as reference

**Parallelism Guide**:
- [parallel:A] - Core infrastructure scripts (can develop together)
- [parallel:B] - High-value script migrations (independent)
- [parallel:C] - Issue tracking scripts (independent)
