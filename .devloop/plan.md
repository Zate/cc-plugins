# Devloop Plan: FEAT-005 Hook-Based Fresh Start Loop

**Created**: 2025-12-24
**Updated**: 2025-12-24 06:35
**Status**: In Progress
**Current Phase**: Phase 1
**Estimate**: M (5-7 hours)

## Overview

Implement automatic fresh start loop workflow using Stop hooks. When a user completes a task and stops, the Stop hook will:
1. Evaluate if plan.md has pending tasks
2. Auto-commit all changes (lint → test → commit)
3. Prompt user with routing options (next task, fresh start, stop)
4. If fresh start selected, save state to next-action.json
5. On next session start, auto-resume from next-action.json

This creates a seamless development loop without requiring changes to the continue.md command.

## Architecture Choice

**Stop Hook with Fresh Context Chaining**

Using the existing hook infrastructure:
- Stop hook (hooks.json line 109-120)
- Session start hook (hooks.json line 16-26)
- Fresh start state file (next-action.json)
- Plan detection and auto-resume

**Why this approach:**
- Non-invasive: No changes to continue.md command
- Leverages existing infrastructure: hooks, fresh start, session detection
- User-friendly: Clear prompts at natural stop points
- Configurable: Can be disabled via .devloop/local.md

## Key Files Identified

1. **plugins/devloop/hooks/hooks.json** (line 109-120)
   - Current Stop hook validation prompt
   - Need to replace with plan evaluation + routing

2. **plugins/devloop/hooks/session-start.sh** (lines 415-443)
   - Fresh start detection logic exists
   - Needs to auto-invoke /devloop:continue when next-action.json present

3. **plugins/devloop/docs/testing.md**
   - Add hook testing scenarios
   - Document Stop hook behavior

4. **.devloop/issues/FEAT-005.md**
   - Update with hook-based resolution

5. **CHANGELOG.md**
   - Document new feature

## Tasks

### Phase 1: Stop Hook Implementation [parallel:none]
**Goal**: Replace Stop hook validation with plan-aware routing
**Complexity**: S-sized (2-3 hours)

- [x] Task 1.1: Design Stop hook prompt
  - Read existing .devloop/plan.md (if exists)
  - Parse pending tasks ([ ] markers)
  - Evaluate if work is complete
  - Return routing options based on plan state
  - Acceptance: Prompt design complete with plan evaluation logic ✓
  - Files: Design document or pseudocode

- [x] Task 1.2: Implement Stop hook in hooks.json
  - Replace current Stop hook prompt (lines 113-117)
  - Add plan detection logic
  - Add routing options: "Continue next task", "Fresh start", "Stop"
  - Include auto-commit sequence (lint → test → commit)
  - Handle edge cases: no plan, plan complete, plan errors
  - Acceptance: Stop hook JSON configuration complete ✓
  - Files: `plugins/devloop/hooks/hooks.json`

- [ ] Task 1.3: Test basic hook behavior
  - Manual test: Stop with active plan → routing prompt appears
  - Manual test: Stop without plan → simple completion message
  - Manual test: Stop with complete plan → congratulatory message
  - Manual test: Auto-commit triggers (if changes present)
  - Acceptance: All basic scenarios work correctly
  - Files: Manual testing

### Phase 2: Fresh Start Auto-Resume [parallel:none]
**Goal**: Enable automatic resume when fresh start state exists
**Complexity**: S-sized (1-2 hours)
**Dependencies**: Phase 1 complete

- [ ] Task 2.1: Extend session-start.sh for auto-resume
  - Detect next-action.json (existing logic at lines 415-443)
  - Auto-invoke /devloop:continue (no user prompt)
  - Pass fresh start context to continue command
  - Handle errors gracefully (stale state, missing plan)
  - Acceptance: Session start auto-resumes when next-action.json present
  - Files: `plugins/devloop/hooks/session-start.sh`

- [ ] Task 2.2: Add safety validation
  - Check next-action.json timestamp (warn if >7 days old)
  - Validate plan.md still exists
  - Validate task reference is still valid
  - Offer escape hatch (skip auto-resume if something wrong)
  - Acceptance: Stale or invalid state handled gracefully
  - Files: `plugins/devloop/hooks/session-start.sh`

- [ ] Task 2.3: Test auto-resume workflow
  - End-to-end test: Stop → fresh start → /clear → auto-resume
  - Test stale state handling (old next-action.json)
  - Test missing plan.md scenario
  - Test invalid task reference
  - Acceptance: All auto-resume scenarios validated
  - Files: Manual testing

### Phase 3: Testing & Documentation [parallel:partial]
**Goal**: Document behavior and add comprehensive test cases
**Complexity**: XS-sized (1-2 hours)
**Dependencies**: Phase 1 and Phase 2 complete

**Parallel Groups**: Group A: Tasks 3.1, 3.2 (documentation updates)

- [ ] Task 3.1: Add test scenarios to testing.md [parallel:A]
  - Hook Test 1: Stop hook detects pending tasks → routing prompt
  - Hook Test 2: Stop hook with no plan → simple completion
  - Hook Test 3: Stop hook triggers auto-commit workflow
  - Hook Test 4: Fresh start saves next-action.json correctly
  - Hook Test 5: Session start auto-resumes from next-action.json
  - Hook Test 6: Stale state detection and handling
  - Hook Test 7: Invalid plan.md scenario
  - Acceptance: 7 test scenarios documented
  - Files: `plugins/devloop/docs/testing.md`

- [ ] Task 3.2: Update FEAT-005 issue with resolution [parallel:A]
  - Document hook-based architecture chosen
  - List files modified
  - Add "Resolved in" commit hash (after commit)
  - Mark status as "done"
  - Acceptance: FEAT-005 updated with complete resolution details
  - Files: `.devloop/issues/FEAT-005.md`

- [ ] Task 3.3: Update CHANGELOG.md [depends:3.1,3.2]
  - Add entry under "## [2.2.0] - 2025-12-24"
  - Feature: "Stop hook with automatic fresh start loop workflow"
  - List benefits: seamless dev loop, auto-commit, auto-resume
  - List modified files
  - Acceptance: CHANGELOG.md updated with feature details
  - Files: `CHANGELOG.md`

- [ ] Task 3.4: Bump version to 2.2.0 [depends:3.3]
  - Update `plugins/devloop/.claude-plugin/plugin.json` version field
  - Verify version consistency across files
  - Acceptance: Version bumped to 2.2.0
  - Files: `plugins/devloop/.claude-plugin/plugin.json`

### Phase 4: Validation & Ship [parallel:none]
**Goal**: End-to-end validation and deployment
**Complexity**: XS-sized (1 hour)
**Dependencies**: All previous phases complete

- [ ] Task 4.1: Manual end-to-end validation
  - Scenario 1: Complete task → Stop → routing prompt → next task
  - Scenario 2: Complete task → Stop → fresh start → /clear → auto-resume
  - Scenario 3: Stop without plan → verify graceful handling
  - Scenario 4: Stop with complete plan → verify congratulations
  - Scenario 5: Auto-commit workflow (lint → test → commit)
  - Scenario 6: Stale state detection (7+ day old next-action.json)
  - Scenario 7: Invalid plan reference handling
  - Acceptance: All 7 scenarios pass without issues
  - Files: Manual testing

- [ ] Task 4.2: Safety validation
  - Verify hooks don't interfere with non-devloop work
  - Test Stop hook when no .devloop/ directory exists
  - Test performance impact (hook timeout <5s)
  - Test infinite loop prevention (max 3 auto-resumes per hour)
  - Acceptance: No regressions, safe defaults, performance acceptable
  - Files: Manual testing

- [ ] Task 4.3: Create atomic commit
  - Stage all changes (hooks.json, session-start.sh, testing.md, FEAT-005.md, CHANGELOG.md, plugin.json)
  - Commit message: "feat(devloop): add Stop hook with fresh start loop workflow (FEAT-005)"
  - Include detailed commit body with changes
  - Acceptance: Single atomic commit capturing all changes
  - Files: Git commit

- [ ] Task 4.4: Update worklog
  - Add entry to .devloop/worklog.md
  - Document completed tasks and commit hash
  - Note feature benefits and architecture choice
  - Acceptance: Worklog updated with FEAT-005 completion
  - Files: `.devloop/worklog.md`

## Progress Log

- 2025-12-24 06:35: Completed Task 1.2 - Stop hook implemented in hooks.json with plan detection, routing options (continue/fresh/stop), auto-commit logic, and comprehensive edge case handling
- 2025-12-24 07:45: Fresh start initiated - state saved to next-action.json
- 2025-12-24 11:10: Completed Task 1.1 - Stop hook prompt design complete with plan evaluation logic, auto-commit sequence, routing options, and edge cases
- 2025-12-24 06:00: Plan created - Hook-based architecture for FEAT-005

## Notes

### Implementation Details

**Stop Hook Prompt Structure:**
```json
{
  "type": "prompt",
  "prompt": "Before stopping, evaluate the current work state and plan:\n\n1. Check if .devloop/plan.md exists\n2. If plan exists, parse for pending tasks ([ ] markers)\n3. Evaluate completion state:\n   - All tasks done: Congratulate and suggest /devloop:ship\n   - Pending tasks: Offer routing options\n   - No plan: Simple completion message\n4. If changes uncommitted: Auto-commit sequence (lint → test → commit)\n5. Present routing options based on state\n\nRouting options when pending tasks exist:\n- \"Continue next task\": Resume work immediately\n- \"Fresh start\": Save state to next-action.json, prepare for /clear\n- \"Stop\": End session (default)\n\nRespond with:\n{\"decision\": \"route\", \"options\": [...]}\nor\n{\"decision\": \"complete\", \"message\": \"...\"}"
}
```

**Auto-Resume Logic (session-start.sh):**
```bash
# Existing fresh start detection (lines 415-443)
if [ -f "next-action.json" ]; then
  # NEW: Auto-invoke continue instead of prompting
  echo "Fresh start detected - resuming work..."
  /devloop:continue
  # Cleanup handled by continue command
fi
```

### Safety Features

1. **Infinite Loop Prevention**: Track auto-resumes in temp file, max 3/hour
2. **Stale State Detection**: Warn on next-action.json >7 days old
3. **Graceful Degradation**: If plan.md missing/invalid, skip routing
4. **Timeout Protection**: Hook timeout 20s max
5. **User Override**: Can disable via `.devloop/local.md` (enforcement: none)

### Edge Cases Handled

| Scenario | Behavior |
|----------|----------|
| No .devloop/ directory | Skip hook, normal Stop |
| Plan.md missing | Skip routing, normal Stop |
| Plan.md corrupted | Log error, skip routing |
| All tasks complete | Congratulate, suggest /devloop:ship |
| No pending tasks | Same as complete |
| Uncommitted changes | Auto-commit (lint → test → commit) |
| Lint/test fails | Warn user, don't commit |
| next-action.json stale | Warn, ask to confirm resume |
| Invalid task reference | Skip auto-resume, show error |

### Configuration (.devloop/local.md)

```yaml
---
stop_hook_routing: true     # Enable routing at Stop hook
auto_commit: true            # Auto-commit on task completion
auto_resume: true            # Auto-resume from fresh start
max_resumes_per_hour: 3      # Infinite loop prevention
stale_state_days: 7          # Age threshold for warning
---
```

## Success Criteria

1. ✓ Stop hook evaluates plan state and presents routing options
2. ✓ Auto-commit workflow triggers when uncommitted changes exist
3. ✓ Fresh start saves state to next-action.json correctly
4. ✓ Session start auto-resumes from next-action.json
5. ✓ Stale state detection warns user (>7 days)
6. ✓ Invalid plan scenarios handled gracefully
7. ✓ All 7 test scenarios documented in testing.md
8. ✓ FEAT-005 marked done with resolution details
9. ✓ CHANGELOG.md updated with feature description
10. ✓ Version bumped to 2.2.0
11. ✓ No regressions in existing workflows
12. ✓ Performance impact minimal (<5s hook execution)
