# Devloop Plan: Unified Workflow Conductor

**Created**: 2025-12-29
**Updated**: 2025-12-29 19:50
**Status**: In Progress
**Current Phase**: Phase 7

**Previous Plan**: Agent Enforcement & Checkpoint Improvements (Complete)

## Overview

Implement a unified workflow conductor system that:
1. **Tracks loop state holistically** - Not just plan state, but full workflow position
2. **Auto-recommends next actions** - Smart routing based on context
3. **Measures loop health** - Aggregated metrics across sessions
4. **Reduces manual transitions** - Automatic handoffs where possible

**Source**: Two related spike investigations
- `workflow-chaining-improvements.md` - Main design for unified conductor
- `hook-driven-workflow-routing.md` - Hook-based routing approach

## Success Criteria

1. [ ] `workflow.json` schema defined and documented
2. [ ] `/devloop:start` command auto-detects context and routes appropriately
3. [ ] `workflow-router` skill interprets session state and presents options
4. [ ] Session start hook provides structured workflow state to agents
5. [ ] Workflow state integrates with existing continue/fresh/ship commands
6. [ ] Version bumped to 2.5.0

## Tasks

### Phase 7: Foundation - Unified Workflow State

- [x] Task 7.1: Create workflow.json schema
  - Define schema with: position, origin, plan, sessions, metrics, transitions, next_action
  - Create JSON schema file for validation
  - Document schema in skill or doc file
  - Files: `plugins/devloop/schemas/workflow.schema.json` (new), `plugins/devloop/docs/workflow-state.md` (new)

- [x] Task 7.2: Create workflow-state.sh script
  - Initialize workflow.json when starting new workflow
  - Update workflow state (position, metrics, transitions)
  - Read current state for routing decisions
  - Calculate health score
  - Files: `plugins/devloop/scripts/workflow-state.sh` (new)

- [ ] Task 7.3: Create workflow-router skill
  - Interprets session hook output
  - Presents guided choices via AskUserQuestion
  - Routes to appropriate commands (continue, fresh, start new, etc.)
  - Files: `plugins/devloop/skills/workflow-router/SKILL.md` (new)

### Phase 8: Smart Entry Point

- [ ] Task 8.1: Create /devloop:start command
  - Check workflow.json for active workflow
  - Check for existing plan.md state
  - Check for recent spikes
  - Check for open issues
  - Route to appropriate workflow based on detection
  - Files: `plugins/devloop/commands/start.md` (new)

- [ ] Task 8.2: Update session-start.sh to output structured workflow state
  - Output workflow_state JSON with: has_active_plan, has_fresh_start, plan_progress, recommended_action, alternatives
  - Integrate with workflow-state.sh for reading state
  - Files: `plugins/devloop/hooks/session-start.sh`

- [ ] Task 8.3: Create detect-workflow-state.sh script
  - Detect active plan, fresh start state, open issues
  - Calculate recommended action and alternatives
  - Return structured JSON for routing
  - Files: `plugins/devloop/scripts/detect-workflow-state.sh` (new)

### Phase 9: Integration with Existing Commands

- [ ] Task 9.1: Update /devloop:continue to update workflow.json on each checkpoint
  - Write session metrics after task completion
  - Update position (current_task, subphase)
  - Track transitions
  - Files: `plugins/devloop/commands/continue.md`

- [ ] Task 9.2: Update /devloop:fresh to update workflow state
  - Record transition to "fresh" state
  - Update session end metrics
  - Set next_action for resume
  - Files: `plugins/devloop/commands/fresh.md`

- [ ] Task 9.3: Update /devloop and /devloop:spike to initialize workflow
  - Create workflow.json when starting new work
  - Set origin (manual, spike, issue, quick)
  - Initialize metrics
  - Files: `plugins/devloop/commands/devloop.md`, `plugins/devloop/commands/spike.md`

### Phase 10: Metrics & Status Display

- [ ] Task 10.1: Enhance /devloop:status (or create new) with workflow metrics
  - Show current workflow position
  - Display velocity metrics (tasks/hour, trend)
  - Show health score with factor breakdown
  - Present recommended next action with alternatives
  - Files: `plugins/devloop/commands/status.md` (new or enhance existing)

- [ ] Task 10.2: Update session-tracker.sh to integrate with workflow metrics
  - Record session data into workflow.json
  - Calculate aggregate metrics across sessions
  - Files: `plugins/devloop/scripts/session-tracker.sh`

### Phase 11: Finalization

- [ ] Task 11.1: Test all scenarios
  - Clean session (no state)
  - Active plan mid-execution
  - Fresh start state
  - Plan complete
  - Stale state
  - Files: Manual testing

- [ ] Task 11.2: Update CLAUDE.md with new workflow guidance
  - Document /devloop:start as primary entry point
  - Update workflow diagram with new flow
  - Files: `CLAUDE.md`

- [ ] Task 11.3: Bump version to 2.5.0
  - Files: `plugins/devloop/.claude-plugin/plugin.json`

## Progress Log
- 2025-12-29 19:50: Task 7.2 complete - Created workflow-state.sh script with all operations
- 2025-12-29 17:00: Task 7.1 complete - Created workflow.json schema and documentation
- 2025-12-29: Plan created from spikes (workflow-chaining-improvements.md, hook-driven-workflow-routing.md)

## Notes

**Key Design Decisions**:
1. **workflow.json is the source of truth** for workflow position, not just plan.md
2. **Backward compatible** - create workflow.json on first use, existing plans continue to work
3. **User stays in control** - auto-suggest but never force transitions
4. **Phased rollout** - each phase is independently useful

**Risks**:
- Migration complexity (mitigated by lazy initialization)
- Over-automation concerns (mitigated by always offering alternatives)
- State corruption with concurrent sessions (mitigated by session locking)

**Estimated Size**: Large overall, but S-M per phase
