# Devloop Plan: Agent Enforcement & Checkpoint Improvements

**Created**: 2025-12-27
**Updated**: 2025-12-28 10:00
**Status**: Complete
**Current Phase**: Phase 6

**Previous Plan**: Structured Plan Format & Script-First Workflow (Complete)

## Overview

Address two issues discovered during workflow observation:
1. **Engineer agent not being mandated** - continue.md documents agent routing but doesn't enforce it
2. **Fresh start not recommended** - checkpoints recommend "Continue" instead of "Fresh start"

**Source**: Spike investigation "Engineer Agent Usage and Fresh Start Recommendation"
- Spike report: `.devloop/spikes/engineer-agent-and-freshstart.md`

## Success Criteria

1. [x] continue.md Step 4 has **MANDATORY** agent enforcement language
2. [x] Checkpoint questions recommend "Fresh start" when context > 50% full
3. [x] Script exists to query context usage percentage
4. [x] ask-user-question-standards.md updated with new checkpoint pattern
5. [x] workflow-loop skill references updated
6. [x] Version bumped to 2.4.7

## Tasks

### Phase 6: Agent Enforcement & Checkpoint Improvements

- [x] Task 6.1: Update continue.md Step 4 with mandatory agent routing enforcement
  - Add **MANDATORY** language: "You MUST use the Task tool with devloop:engineer for ALL implementation tasks"
  - Add validation reminder: After spawning agent, verify agent was actually invoked
  - Add multiple Task invocation examples (not just one)
  - Files: `plugins/devloop/commands/continue.md`

- [x] Task 6.2: Update continue.md Step 5a.4 checkpoint to recommend Fresh Start based on context usage
  - Fresh start should be recommended when context is > 50% full
  - Call a script to get context percentage (statusline already calculates this)
  - Add "(Recommended)" to Fresh start option when context > 50%
  - Keep "Continue to next task" as first option but only recommend when context < 50%
  - Files: `plugins/devloop/commands/continue.md`, `plugins/devloop/scripts/get-context-usage.sh` (new)

- [x] Task 6.3: Update ask-user-question-standards.md Format 1 (Checkpoint) to match
  - Updated Format 1 (Standard Checkpoint) with context-aware pattern
  - Added context usage check instructions
  - Documented when to use "(Recommended)" qualifier (< 50% vs >= 50%)
  - Added two examples showing low context and high context scenarios
  - Files: `plugins/devloop/docs/ask-user-question-standards.md`

- [x] Task 6.4: Update workflow-loop skill checkpoint-patterns.md reference
  - Align checkpoint pattern with new recommendations
  - Files: `plugins/devloop/skills/workflow-loop/references/checkpoint-patterns.md`

- [x] Task 6.5: Bump version to 2.4.7
  - Files: `plugins/devloop/.claude-plugin/plugin.json`

## Progress Log
- 2025-12-28 10:00: Completed Task 6.5 - Bumped version to 2.4.7
- 2025-12-28 09:30: Completed Task 6.4 - Updated workflow-loop skill checkpoint-patterns.md with context-aware recommendations
- 2025-12-28 09:00: Completed Task 6.3 - Updated ask-user-question-standards.md Format 1 with context-aware checkpoint pattern
- 2025-12-28 08:30: Completed Task 6.2 - Added context-based Fresh Start recommendation to continue.md Step 5a.4
- 2025-12-28 08:15: Completed Task 6.1 - Updated continue.md Step 4 with mandatory agent routing enforcement
- 2025-12-27: Plan created from spike findings (engineer-agent-and-freshstart.md)

### Previous Plan Progress (Archived)
See `.devloop/archive/` for completed phases from "Structured Plan Format & Script-First Workflow" plan.

## Notes

**Key Changes**:
1. Agent enforcement: continue.md must mandate Task tool usage, not just document it
2. Fresh start recommendation: Checkpoints should recommend fresh start after 5+ tasks per CLAUDE.md workflow guidance
3. Consistency: All checkpoint-related docs must align with the new pattern
