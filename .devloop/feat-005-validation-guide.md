# Manual End-to-End Validation Guide
**Task 4.1: FEAT-005 Hook-Based Fresh Start Loop**

**Created**: 2025-12-24
**Purpose**: Manual validation of hook-based fresh start loop workflow
**Status**: Ready for testing

---

## Overview

This guide provides step-by-step validation instructions for the 7 scenarios in Task 4.1. All scenarios test the **Stop hook with plan-aware routing** and **auto-resume on session start** features implemented in Phases 1-2.

**Files tested**:
- `plugins/devloop/hooks/hooks.json` (Stop hook, lines 113-177)
- `plugins/devloop/hooks/session-start.sh` (auto-resume, lines 498-775)

**Reference documentation**:
- `plugins/devloop/docs/testing.md` (Hook Tests 1-9)

---

## Scenario 1: Complete Task → Stop → Routing Prompt → Next Task

**Feature**: Stop hook detects pending tasks and presents routing options
**Reference**: Hook Test 1 (testing.md lines 674-740)

### Setup

1. Ensure `.devloop/plan.md` exists with at least one completed task `[x]` and one pending task `[ ]`
2. Example plan state:
   ```markdown
   - [x] Task 1.1: Setup database
   - [ ] Task 1.2: Create user model  ← Pending
   - [ ] Task 1.3: Add authentication
   ```

### Execution Steps

1. **Complete a task** (mark Task 1.1 as `[x]` if not already)
2. **End Claude Code session** (this triggers the Stop hook)
3. **Observe Stop hook execution**

### Expected Outcome

The Stop hook should:
- ✅ Detect `.devloop/plan.md` exists
- ✅ Parse task markers and find pending tasks (e.g., 2 pending)
- ✅ Identify next task ("Task 1.2: Create user model")
- ✅ Display routing prompt with 3 options:
  - **Continue next task** - Resume work immediately
  - **Fresh start** - Save state and prepare for /clear
  - **Stop** - End session (default)
- ✅ Execute within 20s timeout
- ✅ Show pending task count: "2 pending tasks"

### Validation Checklist

- [ ] Hook detects plan file correctly
- [ ] Hook counts pending tasks accurately (matches manual count)
- [ ] Hook identifies correct next task
- [ ] Routing prompt displays before session ends
- [ ] Three routing options present (continue/fresh/stop)
- [ ] User can select an option
- [ ] Hook completes within 20s (no timeout)

### Edge Cases to Note

- If you have in-progress tasks `[~]`, they should count as pending
- If you have blocked tasks `[!]`, they should count as pending
- If uncommitted changes exist, you may see an additional note about auto-commit

---

## Scenario 2: Complete Task → Stop → Fresh Start → /clear → Auto-Resume

**Feature**: End-to-end fresh start loop workflow
**Reference**: Hook Test 9 (testing.md lines 1098-1200)

### Setup

1. Same as Scenario 1 - active plan with pending tasks
2. Ensure you have uncommitted changes (optional, for full test)
3. Example:
   ```bash
   echo "// test change" >> some-file.js
   git status  # Shows modified files
   ```

### Execution Steps (Multi-Phase)

**Phase 1: Stop with Routing**
1. End Claude Code session
2. Stop hook executes (same as Scenario 1)
3. **Select "Fresh start"** option from routing prompt

**Phase 2: Run Fresh Start Command**
1. User runs `/devloop:fresh` command
2. Fresh command creates `.devloop/next-action.json`
3. Display message: "Run /clear then /devloop:continue to resume"

**Phase 3: Clear Context**
1. User runs `/clear` to reset conversation
2. New session starts with empty context

**Phase 4: Auto-Resume Detection**
1. Session start hook (`session-start.sh`) runs automatically
2. Hook detects `.devloop/next-action.json` exists
3. Hook validates state (timestamp <7 days, plan.md exists)

**Phase 5: Auto-Invoke Continue**
1. Hook sets `FRESH_START_DETECTED=true`
2. Hook adds CRITICAL instruction to Claude's context
3. Display: "🔄 Fresh start detected - auto-resuming work..."
4. Claude automatically invokes `/devloop:continue` (no user prompt)
5. Continue reads state file, displays plan status, deletes state file

### Expected Outcome

**Stop Hook Output**:
```json
{
  "decision": "route",
  "pending_tasks": 5,
  "next_task": "Task 3.1: Implement feature",
  "options": ["Continue next task", "Fresh start", "Stop"]
}
```

**Fresh Command Output**:
```
State saved to .devloop/next-action.json
Run /clear to reset context, then /devloop:continue to resume
```

**Session Start Hook Output**:
```
🔄 Fresh start detected - auto-resuming work...
```

**Continue Command Output**:
```
Resuming from Fresh Start
Plan: Feature Implementation
Progress: 8 of 13 tasks (62%)
Next: Task 3.1: Implement feature
```

### Validation Checklist

- [ ] Stop hook routing options display
- [ ] Fresh command creates `.devloop/next-action.json`
- [ ] State file contains valid JSON with required fields
- [ ] Session start hook detects state file
- [ ] Validation passes (timestamp fresh, plan exists)
- [ ] "🔄 Fresh start detected" message appears
- [ ] Claude auto-invokes `/devloop:continue` without user prompt
- [ ] Continue displays "Resuming from Fresh Start" header
- [ ] Continue shows correct next task from state file
- [ ] State file deleted after continue reads it (single-use)

### Validation of State File Format

After Phase 2 (before /clear), inspect the state file:

```bash
cat .devloop/next-action.json | jq .
```

**Required fields**:
- [ ] `timestamp` (ISO 8601 format, e.g., "2025-12-24T12:00:00Z")
- [ ] `plan` (plan name string)
- [ ] `phase` (current phase name)
- [ ] `total_tasks` (number)
- [ ] `completed_tasks` (number)
- [ ] `pending_tasks` (number)
- [ ] `last_completed` (task identifier string)
- [ ] `next_pending` (task identifier string)
- [ ] `summary` (string, <200 chars)
- [ ] `reason` ("fresh_start")

### Edge Cases to Test

- **Uncommitted changes during Stop**: Auto-commit suggestion should appear
- **Multiple fresh starts**: Each creates new state, old state deleted
- **Manual /devloop:continue before /clear**: State file should be consumed immediately

---

## Scenario 3: Stop without Plan → Graceful Handling

**Feature**: Stop hook graceful degradation when no plan exists
**Reference**: Hook Test 2 (testing.md lines 742-775)

### Setup

1. **Remove or rename** `.devloop/plan.md`:
   ```bash
   mv .devloop/plan.md .devloop/plan.md.backup
   ```
2. OR create an empty plan with no task markers

### Execution Steps

1. End Claude Code session (trigger Stop hook)
2. Observe Stop hook behavior

### Expected Outcome

The Stop hook should:
- ✅ Check for `.devloop/plan.md` → not found
- ✅ Skip plan parsing logic
- ✅ Return simple approval message (no routing prompt)
- ✅ Session ends normally without errors

**Expected Output**:
```json
{
  "decision": "approve",
  "message": "No active plan detected. Session ending normally."
}
```

### Validation Checklist

- [ ] Hook handles missing plan file gracefully
- [ ] Hook approves stop without blocking
- [ ] No errors or exceptions thrown
- [ ] Message is clear: "No active plan detected"
- [ ] Session ends normally (no crash)
- [ ] No routing prompt appears (correct behavior)

### Cleanup

Restore the plan file:
```bash
mv .devloop/plan.md.backup .devloop/plan.md
```

---

## Scenario 4: Stop with Complete Plan → Congratulations Message

**Feature**: Stop hook completion detection and ship suggestion
**Reference**: Hook Test 3 (testing.md lines 777-820)

### Setup

1. Ensure `.devloop/plan.md` exists
2. **Mark ALL tasks as complete** `[x]`:
   ```markdown
   - [x] Task 1.1: Setup database
   - [x] Task 1.2: Create user model
   - [x] Task 1.3: Add authentication
   ```
3. No `[ ]`, `[~]`, or `[!]` markers should remain

### Execution Steps

1. End Claude Code session (trigger Stop hook)
2. Observe Stop hook behavior

### Expected Outcome

The Stop hook should:
- ✅ Detect `.devloop/plan.md` exists
- ✅ Parse all task markers
- ✅ Find **zero** pending tasks
- ✅ Recognize completion state
- ✅ Suggest `/devloop:ship` workflow
- ✅ Display congratulatory message

**Expected Output**:
```json
{
  "decision": "complete",
  "message": "All tasks complete! Consider running /devloop:ship to validate and deploy.",
  "show_ship": true
}
```

### Validation Checklist

- [ ] Hook detects plan completion (all tasks `[x]`)
- [ ] Hook correctly counts 0 pending tasks
- [ ] Hook suggests ship workflow explicitly
- [ ] Message is congratulatory and actionable
- [ ] `show_ship: true` flag present in output
- [ ] Session ends normally after displaying message
- [ ] No routing prompt appears (correct for complete state)

### Edge Cases to Test

- If you have skipped tasks `[-]`, they should NOT count as pending (plan is still complete)
- If Progress Log says "Complete" but tasks aren't marked, hook should rely on task markers

---

## Scenario 5: Auto-Commit Workflow (Lint → Test → Commit)

**Feature**: Stop hook detects uncommitted changes and suggests auto-commit
**Reference**: Hook Test 4 (testing.md lines 822-873)

### Setup

1. Ensure `.devloop/plan.md` exists with pending tasks
2. **Create uncommitted changes**:
   ```bash
   echo "// test change for auto-commit" >> some-file.js
   git status  # Should show modified files
   ```
3. Do NOT stage or commit the changes

### Execution Steps

1. End Claude Code session (trigger Stop hook)
2. Observe Stop hook behavior

### Expected Outcome

The Stop hook should:
- ✅ Detect pending tasks (routing mode)
- ✅ Run `git status` to check for changes
- ✅ Find uncommitted changes
- ✅ Include `uncommitted_changes: true` in response
- ✅ Suggest auto-commit sequence in routing options

**Expected Output**:
```json
{
  "decision": "route",
  "pending_tasks": 3,
  "next_task": "Task 2.1: ...",
  "options": [
    {"label": "Continue next task", "action": "continue", ...},
    {"label": "Fresh start", "action": "fresh", ...},
    {"label": "Stop", "action": "stop", ...}
  ],
  "uncommitted_changes": true  ← Key field
}
```

### Validation Checklist

- [ ] Hook detects uncommitted changes via git status
- [ ] `uncommitted_changes: true` in JSON response
- [ ] Auto-commit suggestion appears (may be in routing prompt message)
- [ ] User can choose to commit or skip
- [ ] Hook mentions lint → test → commit sequence (in prompt or options)

### Auto-Commit Sequence (If User Chooses to Commit)

**Note**: The hook itself doesn't execute commits, but it should suggest the sequence:

1. **Lint**: Run linter (if configured)
2. **Test**: Run test suite
3. **Commit**: Create conventional commit

**Expected behavior if lint/test fails**:
- Warn user but don't block
- User can choose to commit anyway or fix issues first

### Edge Cases to Test

- **No .git directory**: Hook should skip uncommitted check, no errors
- **Lint fails**: Should warn but not block stop
- **Tests fail**: Should warn but not block stop

### Cleanup

Discard test changes:
```bash
git checkout some-file.js
```

---

## Scenario 6: Stale State Detection (7+ Day Old next-action.json)

**Feature**: Session start hook detects and warns about stale fresh start state
**Reference**: Hook Test 6 (testing.md lines 932-992)

### Setup

1. Create `.devloop/next-action.json` with **old timestamp** (>7 days):
   ```json
   {
     "timestamp": "2025-12-10T10:00:00Z",
     "plan": "Old Feature",
     "phase": "Phase 2",
     "next_pending": "Task 3.1: Outdated task",
     "summary": "Old state from 14 days ago"
   }
   ```
2. Calculate timestamp to be exactly 14+ days old from today's date
3. Ensure `.devloop/plan.md` exists (can be different from state file's plan name)

### Execution Steps

1. **Start new Claude Code session** (or run `/clear` to trigger session start)
2. Session start hook (`session-start.sh`) runs automatically
3. Observe hook behavior

### Expected Outcome

The session start hook should:
- ✅ Detect `.devloop/next-action.json` exists
- ✅ Run `validate_fresh_start_state()` function (lines 498-557)
- ✅ Parse `timestamp` field from JSON
- ✅ Calculate age: `current_date - timestamp_date` (in days)
- ✅ Detect stale if age >7 days (example: 14 days)
- ✅ Return validation status: `stale:14`
- ✅ Set `FRESH_START_DETECTED=false` (skip auto-resume)
- ✅ Display warning message with age and creation date

**Expected Output**:
```
⚠️ Fresh Start State Warning

A fresh start state file was detected but it is 14 days old (created 2025-12-10).
The plan or tasks may have changed significantly since then.

Options:
- Delete the stale state file and start fresh
- Force resume anyway (run /devloop:continue manually)
- Review the state file at .devloop/next-action.json
```

### Validation Checklist

- [ ] Hook detects stale state (>7 day threshold)
- [ ] Hook calculates age in days accurately (e.g., 14 days)
- [ ] Hook displays clear age warning with creation date
- [ ] Auto-resume is **disabled** (`FRESH_START_DETECTED=false`)
- [ ] User sees 3 options: delete state, force resume, or review
- [ ] Normal session start proceeds (state file left for manual review)
- [ ] No auto-invocation of `/devloop:continue` (correct behavior)

### Implementation Note

The **implemented version** (Task 2.2) does NOT auto-resume stale state. It displays a warning and requires manual action. This is safer than prompting for confirmation, as it prevents accidental resumption of very old state.

### Edge Cases to Test

- **Exactly 7 days old**: Should NOT trigger stale warning (threshold is >7, not ≥7)
- **6 days old**: Should auto-resume normally (valid state)
- **30+ days old**: Should show warning with higher age number

### Cleanup

Delete stale state file:
```bash
rm .devloop/next-action.json
```

---

## Scenario 7: Invalid Plan Reference Handling

**Feature**: Session start hook detects missing plan.md referenced by state file
**Reference**: Hook Test 8 (testing.md lines 1037-1095)

### Setup

1. Create `.devloop/next-action.json` with **valid fresh start state**:
   ```json
   {
     "timestamp": "2025-12-24T10:00:00Z",
     "plan": "Missing Plan Feature",
     "phase": "Phase 2",
     "next_pending": "Task 2.1: Some task",
     "summary": "Completed 5 of 10 tasks"
   }
   ```
2. **Remove** `.devloop/plan.md` (or rename it):
   ```bash
   mv .devloop/plan.md .devloop/plan.md.backup
   ```

### Execution Steps

1. Start new Claude Code session (trigger session start hook)
2. Hook detects `next-action.json`
3. Hook validates state

### Expected Outcome

The session start hook should:
- ✅ Detect `.devloop/next-action.json` exists
- ✅ Run `validate_fresh_start_state()` function
- ✅ Parse timestamp (valid, <7 days)
- ✅ Check for `.devloop/plan.md` existence → **not found**
- ✅ Return validation status: `no_plan`
- ✅ Set `FRESH_START_DETECTED=false` (skip auto-resume)
- ✅ Display warning message about missing plan

**Expected Output**:
```
⚠️ Fresh Start State Warning

A fresh start state file references plan "Missing Plan Feature", but .devloop/plan.md does not exist.
The plan may have been deleted or moved.

Options:
- Delete the state file if plan is no longer needed
- Restore the plan file and run /devloop:continue manually
- Review the state file at .devloop/next-action.json
```

### Validation Checklist

- [ ] Hook detects missing plan file
- [ ] Hook displays clear warning about missing plan
- [ ] Warning includes plan name from state file
- [ ] Auto-resume is **disabled** (`FRESH_START_DETECTED=false`)
- [ ] User sees 3 options: delete state, restore plan, or review
- [ ] Normal session start proceeds (no crash)
- [ ] No errors or exceptions thrown
- [ ] No auto-invocation of `/devloop:continue` (correct behavior)

### Edge Cases to Test

- **Plan exists at alternate location** (e.g., `docs/PLAN.md`): Hook currently only checks `.devloop/plan.md`, may not detect alternate locations (acceptable limitation, documented)
- **Plan corrupted but file exists**: Should pass this validation check (corruption detected later if user manually runs `/devloop:continue`)

### Cleanup

Restore plan file:
```bash
mv .devloop/plan.md.backup .devloop/plan.md
```

Delete state file:
```bash
rm .devloop/next-action.json
```

---

## Additional Validation Notes

### Hook Performance

All hooks should execute within timeout limits:
- **Stop hook**: 20s timeout (lines 116)
- **Session start validation**: <5s for validation logic

**How to measure**:
1. Note timestamp when hook starts
2. Note timestamp when hook completes
3. Calculate duration
4. Verify < timeout threshold

### Error Handling

Test that hooks handle errors gracefully:

**Corrupted state file**:
```bash
echo '{"invalid": json}' > .devloop/next-action.json
# Start session → should ignore file, continue normally
```

**Permissions issue**:
```bash
chmod 000 .devloop/plan.md
# End session → hook should fail gracefully, approve stop
```

### Logging and Debugging

If hooks don't behave as expected:

1. **Enable debug mode**:
   ```bash
   claude --debug
   ```

2. **Check hook output in terminal**: Look for hook execution messages

3. **Inspect state files manually**:
   ```bash
   cat .devloop/next-action.json | jq .
   ```

4. **Verify plan markers**:
   ```bash
   grep -E '^\s*- \[[ x~!\-]\]' .devloop/plan.md
   ```

---

## Summary of Validation Criteria

### Overall Success Criteria

**Task 4.1 passes if**:
- ✅ All 7 scenarios execute without critical errors
- ✅ Stop hook routing prompt appears in Scenarios 1, 2, 5
- ✅ Stop hook completion message appears in Scenario 4
- ✅ Stop hook approval message appears in Scenario 3
- ✅ Auto-resume works end-to-end in Scenario 2
- ✅ Stale state warning appears in Scenario 6
- ✅ Missing plan warning appears in Scenario 7
- ✅ All hooks execute within timeout limits
- ✅ No data corruption or loss
- ✅ User always has clear next steps

### Known Limitations

**Documented as acceptable**:
- Stop hook cannot execute auto-commit itself (only suggests it)
- Session start hook doesn't check alternate plan locations beyond `.devloop/plan.md`
- Hook Test 7 behavior is defined but not fully tested (invalid plan syntax) - marked as optional in plan

### What to Report

After completing all scenarios, report:

1. **Pass/Fail status** for each scenario
2. **Any unexpected behavior** (even if minor)
3. **Performance metrics** (hook execution time)
4. **Edge cases encountered** not covered in this guide
5. **Recommendations** for improvement or additional testing

---

## Execution Checklist

Use this checklist to track validation progress:

- [ ] **Scenario 1**: Complete task → Stop → routing prompt → next task
- [ ] **Scenario 2**: Complete task → Stop → fresh start → /clear → auto-resume
- [ ] **Scenario 3**: Stop without plan → graceful handling
- [ ] **Scenario 4**: Stop with complete plan → congratulations message
- [ ] **Scenario 5**: Auto-commit workflow (lint → test → commit)
- [ ] **Scenario 6**: Stale state detection (7+ day old next-action.json)
- [ ] **Scenario 7**: Invalid plan reference handling

**Validation complete**: All scenarios passed ✓
**Issues found**: [Document any issues]
**Recommendations**: [Next steps or improvements]

---

**Ready to begin validation**. You can execute these scenarios in any order, but **Scenario 2** (end-to-end fresh start loop) is the most comprehensive and covers multiple hook interactions.
