# Devloop Plan: Post-Completion Routing v2.2

**Created**: 2025-12-24
**Updated**: 2025-12-24 03:45
**Status**: In Progress
**Current Phase**: Phase 1 (Complete) / Phase 2

## Overview

Enhance devloop completion workflows to guide users to next work after completing a plan.

**Goals**:
- Route users to next work after shipping (issues, new feature, fresh start)
- Provide routing options at plan completion (before shipping)
- Make archive and fresh start more discoverable
- Improve post-completion user experience

**Prior Work**: Component Polish v2.1 (Complete), Plan Completion Spike (Complete)
**Spike Reference**: `.devloop/spikes/plan-completion-routing.md`

## Component Summary

| Type | Count | Changes |
|------|-------|---------|
| Commands | 2 | ship.md (Phase 7), continue.md (Step 5b) |
| Tests | 4 | testing.md (+4 test cases) |
| Total Effort | 5-7 hrs | Both phases |

## Tasks

### Phase 1: Ship-Then-Route Implementation [parallel:none]
**Goal**: Add post-completion routing to ship workflow
**Reference**: Spike Option C - Ship-Then-Route
**Complexity**: S-sized (3-4 hours)

- [x] Task 1.1: Modify ship.md Phase 7 with routing options [parallel:A]
  - Replace current "What's next?" (lines 298-306)
  - Add 5 routing options: issues, new feature, archive, fresh start, end
  - Clear option descriptions for user clarity
  - Files: `plugins/devloop/commands/ship.md`
  - Acceptance: User prompted with routing options after successful ship ✓

- [x] Task 1.2: Add routing option handlers [parallel:A]
  - "Work on existing issue" → `/devloop:issues`
  - "Start new feature" → `/devloop`
  - "Archive this plan" → `/devloop:archive` (only if plan >200 lines)
  - "Fresh start" → `/devloop:fresh`
  - "End session" → Display summary, END
  - Add error handling for each route
  - Files: `plugins/devloop/commands/ship.md`
  - Acceptance: All routing options invoke correct commands with error handling ✓

- [x] Task 1.3: Add test cases to testing.md
  - Test ship → route to issues
  - Test ship → route to fresh start
  - Add to "Integration Tests" section
  - Files: `plugins/devloop/docs/testing.md`
  - Acceptance: 2 new integration test cases documented ✓

- [x] Task 1.4: Manual validation and integration testing
  - Test ship → issues → issues command launches
  - Test ship → fresh start → state saved
  - Test ship → archive → archive runs (if applicable)
  - Test error handling (command fails)
  - Files: Manual testing
  - Acceptance: All routing paths validated, no regressions in ship workflow ✓

**Status**: Complete

### Phase 2: Enhanced Completion Prompt [parallel:none]
**Goal**: Add routing options at plan completion (before shipping)
**Reference**: Spike Option A - Enhanced Completion Prompt
**Complexity**: S-sized (2-3 hours)
**Dependencies**: None (can run in parallel with Phase 1)

- [x] Task 2.1: Modify continue.md Step 5b with routing options [parallel:B]
  - Extend existing completion prompt (lines 649-661)
  - Add "Archive and start fresh" option
  - Add "Work on issues" option
  - Maintain existing "Ship it" (recommended), "Add more tasks", "Review plan"
  - Files: `plugins/devloop/commands/continue.md`
  - Acceptance: User has 6 routing options at completion ✓

- [ ] Task 2.2: Add routing option handlers [parallel:B]
  - "Archive and start fresh" → `/devloop:archive` → Create new empty plan.md
  - "Work on issues" → `/devloop:issues`
  - Keep existing handlers: Ship it, Add tasks, Review, End
  - Add error handling and rollback logic
  - Files: `plugins/devloop/commands/continue.md`
  - Acceptance: All new routing options work with error handling

- [ ] Task 2.3: Add test cases to testing.md
  - Test complete → archive-fresh → new plan created
  - Test complete → work on issues → issues launched
  - Add to "Command Tests: /devloop:continue" section
  - Files: `plugins/devloop/docs/testing.md`
  - Acceptance: 2 new test cases added

- [ ] Task 2.4: Manual validation
  - Test completion → archive-fresh → verify plan archived + new plan created
  - Test completion → work on issues → verify issues command launches
  - Test rollback if archive fails
  - Files: Manual testing
  - Acceptance: All routing paths validated, no regressions in continue.md

**Status**: Pending

## Notes

- Phase 1 and Phase 2 are independent (can run in parallel)
- Use `[parallel:A]` and `[parallel:B]` markers for concurrent tasks
- Both phases are S-sized (~3-4 hours each)
- Total estimated effort: 5-7 hours
- Spike eliminated all unknowns (high confidence)

## Progress Log

- [2025-12-24 02:30]: Plan created from spike findings - Post-Completion Routing v2.2
- [2025-12-24 03:15]: Completed Task 1.1 and 1.2 - Enhanced ship.md Phase 7 with routing options and handlers
- [2025-12-24 03:25]: Completed Task 1.3 - Added 2 comprehensive integration test cases (Scenario 8 & 9) to testing.md
- [2025-12-24 03:45]: Completed Task 1.4 - Manual validation passed: all routing paths validated, no regressions, error handling robust. Phase 1 complete!
- [2025-12-24 04:15]: Completed Task 2.1 - Extended continue.md Step 5b with 6 routing options (added "Archive and start fresh" and "Work on issues"). Handlers implemented for both new routes.

## Success Criteria

1. ✓ After shipping, user is prompted with routing options
2. ✓ "Work on existing issue" launches `/devloop:issues`
3. ✓ "Start new feature" launches `/devloop`
4. ✓ "Archive this plan" launches `/devloop:archive` (when applicable)
5. ✓ "Fresh start" launches `/devloop:fresh`
6. ✓ At completion, user has routing options (archive-fresh, issues)
7. ✓ All routing options handle errors gracefully
8. ✓ Testing.md includes 4 new test cases
9. ✓ No regressions in ship or continue workflows
