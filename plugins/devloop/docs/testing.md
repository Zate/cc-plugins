# DevLoop Testing Checklist

**Comprehensive testing documentation for manual validation, regression testing, and integration verification.**

**Version**: 2.1.0
**Last Updated**: 2025-12-23
**Status**: Production Ready

---

## Table of Contents

1. [Overview](#overview)
2. [Quick Checklist](#quick-checklist-smoke-tests)
3. [Command Testing](#command-testing)
4. [Agent Invocation Verification](#agent-invocation-verification)
5. [Hook Testing](#hook-testing)
6. [Integration Test Scenarios](#integration-test-scenarios)
7. [Regression Testing Checklist](#regression-testing-checklist)
8. [Performance Testing](#performance-testing)
9. [Edge Cases and Known Issues](#edge-cases-and-known-issues)
10. [Testing Tools and Utilities](#testing-tools-and-utilities)
11. [Success Criteria](#success-criteria)

---

## Overview

### Purpose of This Guide

This testing guide provides comprehensive validation procedures for the devloop plugin, covering:

- **Manual QA validation** - Pre-release testing of all features
- **Regression testing** - Verify existing functionality after changes
- **Developer testing** - Validate changes during development
- **Integration testing** - Ensure components work together correctly

### When to Use This Guide

**Pre-release Testing**:
- Before incrementing version number (especially minor/major)
- After completing a phase in the plan
- Before merging significant PRs

**Post-change Testing**:
- After modifying command implementations
- After changing agent routing logic
- After updating skills or hooks

**Regression Testing**:
- After dependency updates
- After plugin system changes
- After Claude Code version updates

### Testing Philosophy

DevLoop testing follows three principles:

1. **Manual Validation** - Human verification of workflows and outputs
2. **Agent Verification** - Confirm correct agent routing and invocations
3. **Integration Testing** - Validate component interactions and state management

---

## Quick Checklist (Smoke Tests)

### Critical Workflows (Must Work)

Run these 15 tests to verify core functionality:

- [ ] **1. SessionStart Hook Detection**
  - Start fresh Claude Code session
  - Verify devloop context message displays
  - Expected: Tech stack, plan status, or fresh start state

- [ ] **2. Continue Finds Plan**
  - Run `/devloop:continue`
  - Verify `.devloop/plan.md` detected and parsed
  - Expected: Plan summary with task counts

- [ ] **3. Engineer Agent Invoked**
  - Continue with implementation task
  - Verify `devloop:engineer` appears in status line
  - Expected: Correct mode detection (explore/architect/default/refactor/git)

- [ ] **4. Checkpoint After Task**
  - Complete a task via continue
  - Verify checkpoint question displays
  - Expected: 4 options (continue/commit/fresh/stop) with recommended marker

- [ ] **5. Plan Marker Update**
  - Complete task and choose "continue"
  - Verify `[ ]` → `[x]` in `.devloop/plan.md`
  - Expected: Progress Log entry with timestamp

- [ ] **6. Loop Completion Detection**
  - Complete all pending tasks
  - Verify completion question displays
  - Expected: "Ship it" option as recommended

- [ ] **7. Fresh Start Saves State**
  - Run `/devloop:fresh`
  - Verify `.devloop/next-action.json` created
  - Expected: Valid JSON with plan/phase/summary/next_pending

- [ ] **8. Fresh Start Detection**
  - With state file present, restart session
  - Verify SessionStart displays fresh start message
  - Expected: Plan name, progress, next task

- [ ] **9. Fresh Start Cleanup**
  - Run `/devloop:continue` after fresh start
  - Verify state file deleted after reading
  - Expected: `.devloop/next-action.json` removed

- [ ] **10. Context Management Warning**
  - Complete 10+ tasks in one session
  - Verify context warning displays
  - Expected: Advisory or critical warning with metrics

- [ ] **11. Archive Completed Phases**
  - Run `/devloop:archive` on plan with complete phases
  - Verify archive files created
  - Expected: `.devloop/archive/*.md` + compressed plan

- [ ] **12. Spike Plan Application**
  - Run `/devloop:spike` with existing plan
  - Complete spike and apply findings
  - Expected: Diff preview + 4 application options

- [ ] **13. QA Engineer Test Generation**
  - Task with "write tests" keywords
  - Verify `devloop:qa-engineer` (generator mode) invoked
  - Expected: Test files created

- [ ] **14. Code Reviewer Validation**
  - Feature complete, run review
  - Verify `devloop:code-reviewer` invoked
  - Expected: High-confidence issues reported (≥80%)

- [ ] **15. Ship Workflow**
  - Plan complete, run `/devloop:ship`
  - Verify DoD validation + version bump + tag creation
  - Expected: 8 checkpoint questions, plan archived

---

## Command Testing

### `/devloop:continue` (Most Complex)

**Expected Agent Invocations**: Varies by task type (see routing table)

**Success Criteria**:
- ✓ Finds plan in standard locations (`.devloop/plan.md`, `docs/PLAN.md`, `PLAN.md`)
- ✓ Parses fresh start state from `.devloop/next-action.json` if exists
- ✓ Displays plan summary with task counts
- ✓ Routes to correct agent based on task type
- ✓ Mandatory checkpoint after agent execution
- ✓ Plan markers update correctly (`[ ]` → `[x]`)
- ✓ Loop completion detection when all tasks done
- ✓ Context management warnings at thresholds
- ✓ Session metrics tracked (tasks/agents/duration)

**Test Steps**:

1. **Basic Continuation** (no fresh start)
   ```bash
   # Setup
   cd /path/to/project
   # Ensure .devloop/plan.md exists with pending tasks

   # Execute
   /devloop:continue

   # Verify
   - [ ] Plan summary displayed
   - [ ] Next task identified
   - [ ] Task classification shown
   - [ ] Agent routing options presented
   ```

2. **Fresh Start Integration**
   ```bash
   # Setup
   /devloop:fresh
   # Start new session

   # Execute
   /devloop:continue

   # Verify
   - [ ] State file detected (Step 1a)
   - [ ] Fresh start context displayed
   - [ ] State file deleted after reading
   - [ ] Next task from saved state used
   ```

3. **Checkpoint Flow**
   ```bash
   # Execute task to completion

   # Verify checkpoint (Step 5a)
   - [ ] Agent output verified (✓/~/✗)
   - [ ] Plan markers updated
   - [ ] Checkpoint question presented
   - [ ] 4 options: continue/commit/fresh/stop
   ```

4. **Loop Completion**
   ```bash
   # Complete all pending tasks

   # Verify completion (Step 5b)
   - [ ] Task counting correct
   - [ ] Completion state detected
   - [ ] Completion question presented
   - [ ] "Ship it" option recommended
   ```

5. **Context Management**
   ```bash
   # Complete 10+ tasks in session

   # Verify context check (Step 5c)
   - [ ] Session metrics tracked
   - [ ] Warning presented at thresholds
   - [ ] Fresh start offered
   ```

**Edge Cases to Verify**:

| Scenario | Expected Behavior |
|----------|-------------------|
| No plan found | Present "No Plan" question with 4 options |
| Plan already "Complete" | Inform user, suggest ship or add tasks |
| All tasks blocked (`[!]`) | Treat as complete, present completion options |
| Archived phases only | Check archives, offer restoration |
| State file corrupted | Ignore file, continue normal flow |
| Next task not in plan | Display warning, use first pending task |

---

### `/devloop:fresh` (Fresh Start)

**Expected Agent Invocations**: None (state saving only)

**Success Criteria**:
- ✓ Reads plan from standard locations
- ✓ Identifies last completed and next pending tasks
- ✓ Generates concise summary (<200 chars)
- ✓ Writes valid JSON to `.devloop/next-action.json`
- ✓ Updates plan Progress Log
- ✓ Displays continuation instructions

**Test Steps**:

1. **Normal Fresh Start**
   ```bash
   # Setup
   cd /path/to/project/with/active/plan

   # Execute
   /devloop:fresh

   # Verify
   - [ ] Plan state gathered (name/phase/tasks)
   - [ ] Progress summary generated
   - [ ] State file created (.devloop/next-action.json)
   - [ ] Continuation instructions displayed
   - [ ] Progress Log updated
   ```

2. **State File Format Validation**
   ```bash
   # After running fresh
   cat .devloop/next-action.json

   # Verify JSON structure
   - [ ] timestamp (ISO 8601)
   - [ ] plan (plan name)
   - [ ] phase (current phase)
   - [ ] total_tasks (number)
   - [ ] completed_tasks (number)
   - [ ] pending_tasks (number)
   - [ ] last_completed (task identifier)
   - [ ] next_pending (task identifier)
   - [ ] summary (string, <200 chars)
   - [ ] reason ("fresh_start")
   ```

3. **Overwrite Existing State**
   ```bash
   # Setup - state file already exists

   # Execute
   /devloop:fresh

   # Verify
   - [ ] Overwrite question presented
   - [ ] Options: update/keep/show
   - [ ] State updated if confirmed
   ```

4. **Dismiss State**
   ```bash
   # Execute
   /devloop:fresh --dismiss

   # Verify
   - [ ] State file deleted
   - [ ] Confirmation message displayed
   ```

**Edge Cases to Verify**:

| Scenario | Expected Behavior |
|----------|-------------------|
| No plan found | Present "No Plan" question, exit |
| Plan complete | Inform user, suggest `/devloop:ship` |
| No tasks in plan | Inform user, no state to save |
| No completed tasks | Still save state (user wants fresh start) |

---

### `/devloop:spike` (Technical Spike)

**Expected Agent Invocations**:
- `devloop:engineer` (explore mode) - Research phase
- `devloop:complexity-estimator` - Evaluate phase

**Success Criteria**:
- ✓ Defines spike goals with time box
- ✓ Launches engineer for codebase research
- ✓ Generates spike report in `.devloop/spikes/{topic}.md`
- ✓ Phase 5b: Applies findings to plan (if applicable)
- ✓ Shows diff preview before applying changes
- ✓ Auto-invokes `/devloop:continue` if "apply and start" chosen

**Test Steps**:

1. **Basic Spike Flow**
   ```bash
   # Execute
   /devloop:spike "authentication feasibility"

   # Verify Phase 1: Define Goals
   - [ ] Goal question presented
   - [ ] Time box question presented
   - [ ] Existing plan detected (if present)

   # Verify Phase 2: Research
   - [ ] Engineer (explore mode) launched
   - [ ] Findings documented

   # Verify Phase 4: Evaluate
   - [ ] Complexity estimator invoked
   - [ ] T-shirt size assigned

   # Verify Phase 5a: Report
   - [ ] Spike report created (.devloop/spikes/authentication-feasibility.md)
   - [ ] Report includes: findings/recommendation/complexity/risks
   ```

2. **Plan Application (Phase 5b)**
   ```bash
   # Setup - existing plan + spike with plan updates

   # Verify Phase 5b
   - [ ] Plan update section detected in report
   - [ ] Diff preview generated
   - [ ] Application question presented
   - [ ] Options: apply-and-start/apply-only/review/skip
   ```

3. **Apply and Start**
   ```bash
   # Select "Apply and start" option

   # Verify
   - [ ] Plan changes applied
   - [ ] Progress Log entry added
   - [ ] `/devloop:continue` invoked immediately
   - [ ] Spike command exits
   ```

**Edge Cases to Verify**:

| Scenario | Expected Behavior |
|----------|-------------------|
| No plan exists | Skip Phase 5b, proceed to Phase 5c |
| Plan file corrupted | Show error, offer backup/fresh |
| Conflicting tasks | Highlight conflicts in diff |
| Archived phases | Apply to active plan only, note conflicts |

---

### `/devloop:archive` (Plan Archival)

**Expected Agent Invocations**: None (pure plan management)

**Success Criteria**:
- ✓ Detects completed phases (all tasks `[x]`)
- ✓ Creates archive directory (`.devloop/archive/`)
- ✓ Archives phase content to timestamped files
- ✓ Extracts Progress Log to worklog.md
- ✓ Compresses active plan (removes archived phases, keeps last 10 log entries)

**Test Steps**:

1. **Archive Completed Phases**
   ```bash
   # Setup - plan with 2+ complete phases

   # Execute
   /devloop:archive

   # Verify Phase Detection
   - [ ] Completed phases identified
   - [ ] Active phases identified
   - [ ] Phase analysis displayed

   # Verify Confirmation
   - [ ] Multi-select question presented
   - [ ] Phases listed with task counts

   # Verify Archive Creation
   - [ ] .devloop/archive/ directory created
   - [ ] Archive files created (format: {plan}_{phase}_{timestamp}.md)
   - [ ] Archive contains: phase content + progress log entries

   # Verify Plan Compression
   - [ ] Archived phases removed from plan.md
   - [ ] Plan structure intact (header/overview/active phases)
   - [ ] Last 10 Progress Log entries kept
   - [ ] Line count reduced

   # Verify Worklog Update
   - [ ] .devloop/worklog.md updated
   - [ ] Phase summary added
   - [ ] Task list included
   - [ ] Archive file reference added
   ```

2. **Continue After Archive**
   ```bash
   # After archival
   /devloop:continue

   # Verify
   - [ ] Compressed plan works normally
   - [ ] Archive awareness in status display
   - [ ] No errors from missing phases
   ```

**Edge Cases to Verify**:

| Scenario | Expected Behavior |
|----------|-------------------|
| No completed phases | Exit with message, nothing to archive |
| All phases complete | Archive all but keep plan structure |
| No Progress Log | Skip worklog update, note in report |
| Archive file exists | Append timestamp with seconds |
| Plan < 100 lines | Warn "archival may not be needed" |

---

### `/devloop:ship` (Ship Workflow)

**Expected Agent Invocations**:
- `devloop:task-planner` (DoD validator mode) - Definition of Done check
- `devloop:qa-engineer` (runner mode) - Test execution
- `devloop:engineer` (git mode) - Commit/tag creation

**Success Criteria**:
- ✓ Validates Definition of Done
- ✓ Runs test suite
- ✓ Creates commit with conventional message
- ✓ Bumps version (major/minor/patch)
- ✓ Creates git tag
- ✓ Offers to archive plan

**Test Steps**:

1. **Full Ship Flow**
   ```bash
   # Setup - plan complete, tests passing

   # Execute
   /devloop:ship

   # Verify Questions (8 total)
   - [ ] Q1: Ship mode (full/quick/dry-run)
   - [ ] Q2: DoD status (continue/skip/fix)
   - [ ] Q3: Tests (continue/retry/skip)
   - [ ] Q4: Git operation (create/existing/later)
   - [ ] Q5: Commit confirmation (proceed/edit/cancel)
   - [ ] Q6: Version bump (auto/major/minor/patch)
   - [ ] Q7: Tag operation (create/skip/manual)
   - [ ] Q8: Follow-up (archive/keep/new)

   # Verify Outputs
   - [ ] Commit created
   - [ ] Version bumped
   - [ ] Git tag created
   - [ ] Plan archived (if selected)
   ```

**Edge Cases to Verify**:

| Scenario | Expected Behavior |
|----------|-------------------|
| Tests failing | Offer retry/skip/fix options |
| Uncommitted changes | Prompt for commit creation |
| No version file | Create with 1.0.0 |

---

### `/devloop:review` (Code Review)

**Expected Agent Invocations**:
- `devloop:code-reviewer` - Primary review

**Success Criteria**:
- ✓ Reviews uncommitted changes by default
- ✓ Supports staged/commits/files/PR scopes
- ✓ Uses confidence-based filtering
- ✓ Reports high-priority issues only

**Test Steps**:

```bash
# Execute
/devloop:review

# Verify
- [ ] Scope question presented (2 options total)
- [ ] Recommended: "Uncommitted changes"
- [ ] Code reviewer launched
- [ ] Review findings displayed
- [ ] Action question presented (approve/changes/comment/review-another)
```

---

### `/devloop:quick` (Quick Implementation)

**Expected Agent Invocations**:
- `devloop:engineer` (default mode) - Implementation

**Success Criteria**:
- ✓ Bypasses planning phases
- ✓ Direct implementation
- ✓ Auto-creates commit

**Test Steps**:

```bash
# Execute
/devloop:quick "add logging to UserService"

# Verify
- [ ] No plan created
- [ ] Engineer launched immediately
- [ ] Implementation complete
- [ ] Commit created
```

---

## Agent Invocation Verification

### How to Verify Correct Agent Routing

**Method 1: Status Line Indicators**

When an agent is invoked, the status line shows: `devloop:agent-name`

Examples:
- `devloop:engineer` - Engineer agent active
- `devloop:qa-engineer` - QA engineer active
- `devloop:code-reviewer` - Code reviewer active

**Method 2: Log File Checking**

Enable task logging hook (Task 4.1):
```bash
# Check invocation log
tail -f ~/.devloop-agent-invocations.log

# Expected format
[2025-12-23 14:30:00] Task Invoked:
  subagent_type: devloop:engineer
  description: Implement user authentication
  prompt: [First 200 chars of prompt...]
```

**Method 3: Agent Output Patterns**

Each agent has characteristic output:

| Agent | Output Pattern |
|-------|----------------|
| engineer (explore) | "Entry Points" table, "Execution Flow", "Key Components" |
| engineer (architect) | "Component Design", "Data Flow", "Implementation Map" |
| engineer (refactor) | "Codebase Health", "Findings by Category", "Quick Wins" |
| engineer (git) | "Operation Summary", commit message, changes summary |
| qa-engineer (generator) | Test files created, test count |
| qa-engineer (runner) | Test results, pass/fail counts |
| task-planner (planner) | `.devloop/plan.md` created/updated |
| code-reviewer | "Review Findings" with confidence scores |
| security-scanner | OWASP categories, severity classification |

### Mode Detection Testing

**Engineer Agent Modes**:

| User Intent | Expected Mode | Verification |
|-------------|---------------|--------------|
| "How does auth work?" | explore | Entry points table in output |
| "Design user management" | architect | Component design blueprint |
| "What should I refactor?" | refactor | Codebase health summary |
| "Create PR for feature X" | git | PR created confirmation |

**QA Engineer Modes**:

| User Intent | Expected Mode | Verification |
|-------------|---------------|--------------|
| "Write tests for UserService" | generator | Test files created |
| "Run the tests" | runner | Test results displayed |
| "Log this bug" | bug tracker | Issue file created |
| "Is it ready to ship?" | validator | Deployment checklist |

**Task Planner Modes**:

| User Intent | Expected Mode | Verification |
|-------------|---------------|--------------|
| "Break this into tasks" | planner | Plan file created |
| "What exactly do you need?" | requirements | Requirements doc |
| "Log this issue" | issue manager | Issue file in .devloop/issues/ |
| "Is it ready to ship?" | DoD validator | DoD checklist |

### Agent Routing Table Validation

Test routing for each task type from `continue.md` Step 4:

- [ ] **Implementation** → `devloop:engineer`
- [ ] **Exploration** → `devloop:engineer` (explore mode)
- [ ] **Architecture** → `devloop:engineer` (architect mode)
- [ ] **Refactoring** → `devloop:engineer` (refactor mode)
- [ ] **Git operations** → `devloop:engineer` (git mode)
- [ ] **Planning** → `devloop:task-planner`
- [ ] **Requirements** → `devloop:task-planner` (requirements mode)
- [ ] **Test generation** → `devloop:qa-engineer` (generator mode)
- [ ] **Test execution** → `devloop:qa-engineer` (runner mode)
- [ ] **Code review** → `devloop:code-reviewer`
- [ ] **Security scan** → `devloop:security-scanner`
- [ ] **Documentation** → `devloop:doc-generator`
- [ ] **Estimation** → `devloop:complexity-estimator`
- [ ] **Validation** → `devloop:task-planner` (DoD validator mode)

---

## Hook Testing

### Purpose

Validate devloop hook behavior for lifecycle events (Stop, session start, task logging, etc.).

**Note**: Hooks execute automatically based on events. Full testing requires triggering actual events (session stops, tool calls, etc.).

---

### Hook Test 1: Stop Hook with Pending Tasks

**Feature**: FEAT-005 Stop Hook with Plan-Aware Routing
**Component**: `plugins/devloop/hooks/hooks.json` (Stop hook, lines 113-177)

**Setup**:
1. Ensure `.devloop/plan.md` exists with pending tasks
2. Verify plan has at least one `[ ]` marker (pending task)
3. Example plan state:
   ```markdown
   - [x] Task 1.1: Complete task
   - [ ] Task 1.2: Pending task  ← At least one pending
   - [ ] Task 1.3: Another pending
   ```

**Execution**:
1. End Claude Code session (trigger Stop event)
2. Hook executes automatically

**Expected Behavior**:
The Stop hook should:
1. Detect `.devloop/plan.md` exists
2. Parse task markers and find pending tasks
3. Count pending tasks (example: 2)
4. Identify next task (example: "Task 1.2: Pending task")
5. Return structured JSON with routing options

**Expected Output** (JSON format):
```json
{
  "decision": "route",
  "pending_tasks": 2,
  "next_task": "Task 1.2: Pending task",
  "options": [
    {
      "label": "Continue next task",
      "action": "continue",
      "description": "Resume work immediately with /devloop:continue"
    },
    {
      "label": "Fresh start",
      "action": "fresh",
      "description": "Save state and prepare for /clear (hook-based resume)"
    },
    {
      "label": "Stop",
      "action": "stop",
      "description": "End session, resume manually later"
    }
  ],
  "uncommitted_changes": false
}
```

**Validation Criteria**:
- ✅ Hook detects plan file
- ✅ Hook parses pending tasks correctly
- ✅ Hook returns three routing options (continue, fresh, stop)
- ✅ Hook includes pending task count and next task description
- ✅ Hook executes within 20s timeout
- ✅ User sees routing prompt before session ends

**Edge Cases**:
- If uncommitted changes exist: `"uncommitted_changes": true` with auto-commit suggestion
- If only in-progress tasks `[~]`: Treat as pending
- If blocked tasks `[!]`: Count as pending

---

### Hook Test 2: Stop Hook without Plan

**Feature**: FEAT-005 Stop Hook Graceful Degradation
**Component**: `plugins/devloop/hooks/hooks.json` (Stop hook)

**Setup**:
1. Ensure `.devloop/plan.md` does NOT exist (rename or move temporarily)
2. OR: Create empty plan with no task markers

**Execution**:
1. End Claude Code session

**Expected Behavior**:
The Stop hook should:
1. Check for `.devloop/plan.md` → not found
2. Skip plan parsing
3. Return simple approval message

**Expected Output**:
```json
{
  "decision": "approve",
  "message": "No active plan detected. Session ending normally."
}
```

**Validation Criteria**:
- ✅ Hook gracefully handles missing plan file
- ✅ Hook approves stop without blocking
- ✅ No errors or exceptions thrown
- ✅ Message is clear and informative
- ✅ Session ends normally

---

### Hook Test 3: Stop Hook with Complete Plan

**Feature**: FEAT-005 Stop Hook Completion Detection
**Component**: `plugins/devloop/hooks/hooks.json` (Stop hook)

**Setup**:
1. Ensure `.devloop/plan.md` exists
2. Mark ALL tasks as complete `[x]`
3. No pending `[ ]` or in-progress `[~]` tasks remain
4. Example plan state:
   ```markdown
   - [x] Task 1.1: Complete
   - [x] Task 1.2: Complete
   - [x] Task 1.3: Complete
   ```

**Execution**:
1. End Claude Code session

**Expected Behavior**:
The Stop hook should:
1. Detect `.devloop/plan.md` exists
2. Parse all task markers
3. Find zero pending tasks
4. Recognize completion state
5. Suggest `/devloop:ship` workflow

**Expected Output**:
```json
{
  "decision": "complete",
  "message": "All tasks complete! Consider running /devloop:ship to validate and deploy.",
  "show_ship": true
}
```

**Validation Criteria**:
- ✅ Hook detects plan completion (all tasks `[x]`)
- ✅ Hook suggests ship workflow
- ✅ Message is congratulatory and actionable
- ✅ `show_ship: true` flag present
- ✅ Session ends normally after message

---

### Hook Test 4: Stop Hook with Uncommitted Changes

**Feature**: FEAT-005 Auto-Commit Detection
**Component**: `plugins/devloop/hooks/hooks.json` (Stop hook)

**Setup**:
1. Ensure `.devloop/plan.md` exists with pending tasks
2. Create uncommitted changes:
   ```bash
   echo "// test change" >> some-file.js
   git status  # Shows modified files
   ```
3. Do NOT stage or commit changes

**Execution**:
1. End Claude Code session

**Expected Behavior**:
The Stop hook should:
1. Detect pending tasks (routing mode)
2. Check git status
3. Find uncommitted changes
4. Include auto-commit suggestion in response

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

**Validation Criteria**:
- ✅ Hook detects uncommitted changes via git status
- ✅ `uncommitted_changes: true` in response
- ✅ Auto-commit suggestion appears in routing prompt
- ✅ User can choose to commit or skip
- ✅ If commit chosen: lint → test → commit sequence suggested

**Edge Cases**:
- If lint fails: Warn but don't block
- If tests fail: Warn but don't block
- If no .git directory: Skip uncommitted check

---

### Hook Test 5: Session Start with Fresh Start State

**Feature**: FEAT-005 Fresh Start Auto-Resume
**Component**: `plugins/devloop/hooks/session-start.sh` (lines 527-666)

**Status**: Phase 2 implementation complete (Tasks 2.1, 2.2)

**Setup**:
1. Create `.devloop/next-action.json` with fresh start state:
   ```json
   {
     "timestamp": "2025-12-24T10:00:00Z",
     "plan": "Feature Implementation",
     "phase": "Phase 2",
     "next_pending": "Task 2.3: Implement API",
     "summary": "Completed 5 of 10 tasks"
   }
   ```
2. Start new Claude Code session

**Execution**:
1. Session start hook runs automatically
2. Hook detects `next-action.json`

**Expected Behavior** (Implemented in Tasks 2.1, 2.2):
The session start hook should:
1. Detect `next-action.json` exists (line 530)
2. Validate state using `validate_fresh_start_state()` function (lines 498-557, 588-653):
   - Parse timestamp field (ISO 8601 format)
   - Calculate age in days
   - Check if timestamp <7 days old
   - Verify `.devloop/plan.md` exists
3. If validation passes:
   - Set FRESH_START_DETECTED=true
   - Add CRITICAL auto-resume instruction to Claude's context (lines 646-666)
   - Display "🔄 Fresh start detected - auto-resuming work..." to user
4. Claude automatically invokes `/devloop:continue` (no user prompt)
5. Continue command (Step 1a) reads and deletes state file

**Expected Output**:
- Hook output: "🔄 Fresh start detected - auto-resuming work..."
- CRITICAL instruction in additionalContext: "Execute /devloop:continue command NOW"
- Claude auto-runs: `/devloop:continue` command
- Continue displays: "Resuming from Fresh Start"
- Continue shows: Plan status with next task from state file
- Cleanup: State file deleted by continue command (single-use)

**Validation Criteria**:
- ✅ Hook detects fresh start state file
- ✅ Hook parses JSON correctly
- ✅ Hook auto-invokes continue command
- ✅ State file deleted after reading (single-use)
- ✅ User sees "resuming from fresh start" message
- ✅ Next task matches state file's `next_pending`

---

### Hook Test 6: Session Start with Stale State

**Feature**: FEAT-005 Stale State Detection
**Component**: `plugins/devloop/hooks/session-start.sh` (lines 498-775)

**Status**: Phase 2 implementation complete (Task 2.2)

**Setup**:
1. Create `.devloop/next-action.json` with old timestamp (>7 days):
   ```json
   {
     "timestamp": "2025-12-10T10:00:00Z",  ← 14 days old
     "plan": "Old Feature",
     "next_pending": "Task 3.1: Outdated task"
   }
   ```
2. Start new session

**Execution**:
1. Session start hook runs
2. Hook detects stale state (timestamp >7 days)

**Expected Behavior** (Implemented in Task 2.2):
1. `validate_fresh_start_state()` function (lines 498-557):
   - Parse `timestamp` field from JSON
   - Calculate age: `current_date - timestamp_date` (in days)
   - Detect stale if age >7 days
   - Return status: `stale:<age>` (e.g., "stale:14")
2. Validation logic (lines 588-653):
   - Case statement handles `stale:*` result
   - Extract age from validation status
   - Build warning message with age and creation date
   - Set FRESH_START_DETECTED=false (skip auto-resume)
3. Warning display (lines 768-775):
   - Inject validation warning into context message
   - Show stale state warning to user

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

**Note**: Unlike the original specification, the implemented version does NOT auto-resume stale state. It displays a warning and requires manual action. This is safer than prompting for confirmation.

**Validation Criteria**:
- ✅ Hook detects stale state (>7 day threshold via date arithmetic)
- ✅ Hook calculates age in days accurately
- ✅ Hook displays clear age warning with creation date
- ✅ Auto-resume is disabled (FRESH_START_DETECTED=false)
- ✅ User sees options: delete state, force resume, or review
- ✅ Normal session start proceeds (state file left for manual review)

---

### Hook Test 7: Stop Hook with Invalid Plan

**Feature**: FEAT-005 Error Handling
**Component**: `plugins/devloop/hooks/hooks.json` (Stop hook)

**Setup**:
1. Create corrupted `.devloop/plan.md`:
   ```markdown
   # Devloop Plan: Corrupted
   - [ ] Task 1.1: Valid task
   This is not valid markdown structure
   [[[ corrupted syntax
   ```
2. Ensure plan is readable but malformed

**Execution**:
1. End Claude Code session

**Expected Behavior**:
The Stop hook should:
1. Attempt to read plan.md
2. Encounter parsing error or malformed content
3. Handle gracefully without crashing
4. Log error but approve stop

**Expected Output**:
```json
{
  "decision": "approve",
  "message": "Plan file detected but appears corrupted. Session ending normally. Check .devloop/plan.md for issues."
}
```

**Validation Criteria**:
- ✅ Hook doesn't crash on malformed plan
- ✅ Hook logs error in message
- ✅ Hook approves stop (fail-safe behavior)
- ✅ User informed about corruption
- ✅ No exceptions thrown
- ✅ Session ends normally

---

### Hook Test 8: Session Start with Missing Plan

**Feature**: FEAT-005 Plan Validation
**Component**: `plugins/devloop/hooks/session-start.sh` (lines 498-775)

**Status**: Phase 2 implementation complete (Task 2.2)

**Setup**:
1. Create `.devloop/next-action.json` with valid fresh start state:
   ```json
   {
     "timestamp": "2025-12-24T10:00:00Z",
     "plan": "Missing Plan",
     "next_pending": "Task 2.1: Some task"
   }
   ```
2. Ensure `.devloop/plan.md` does NOT exist (rename or delete)
3. Start new session

**Execution**:
1. Session start hook runs
2. Hook detects next-action.json
3. Validation checks for plan.md

**Expected Behavior** (Implemented in Task 2.2):
1. `validate_fresh_start_state()` function:
   - Parse timestamp (valid, <7 days)
   - Check for `.devloop/plan.md` existence
   - File not found → Return status: `no_plan`
2. Validation logic:
   - Case statement handles `no_plan` result
   - Build warning message about missing plan
   - Set FRESH_START_DETECTED=false (skip auto-resume)
3. Warning display:
   - Inject validation warning into context
   - User sees missing plan warning

**Expected Output**:
```
⚠️ Fresh Start State Warning

A fresh start state file references plan "Missing Plan", but .devloop/plan.md does not exist.
The plan may have been deleted or moved.

Options:
- Delete the state file if plan is no longer needed
- Restore the plan file and run /devloop:continue manually
- Review the state file at .devloop/next-action.json
```

**Validation Criteria**:
- ✅ Hook detects missing plan file
- ✅ Hook displays clear warning about missing plan
- ✅ Auto-resume is disabled (FRESH_START_DETECTED=false)
- ✅ User sees options: delete state, restore plan, or review
- ✅ Normal session start proceeds
- ✅ No errors or exceptions thrown

---

### Hook Test 9: End-to-End Fresh Start Workflow

**Feature**: FEAT-005 Complete Fresh Start Loop
**Component**: Multiple (Stop hook, /devloop:fresh, session-start.sh, /devloop:continue)

**Status**: Phase 2 implementation complete (Tasks 2.1, 2.2)

**Setup**:
1. Have an active plan with pending tasks in `.devloop/plan.md`
2. Complete a task during work session
3. Have uncommitted changes (optional, for full test)

**Execution Steps**:

**Step 1: Stop with Pending Tasks**
1. User ends Claude Code session (Stop event)
2. Stop hook (hooks.json lines 113-177) executes:
   - Detects `.devloop/plan.md` with pending tasks
   - Returns routing options JSON with 3 choices

**Step 2: User Selects "Fresh Start"**
1. User chooses "Fresh start" option from routing prompt
2. User runs `/devloop:fresh` command
3. Fresh command:
   - Reads current plan state
   - Creates `.devloop/next-action.json` with state
   - Displays "Run /clear then /devloop:continue to resume" message

**Step 3: Clear Context**
1. User runs `/clear` to reset conversation context
2. New session starts with empty context
3. Session start hook (session-start.sh) runs

**Step 4: Auto-Resume Detection**
1. Hook detects `.devloop/next-action.json` exists
2. Validates state:
   - Timestamp <7 days old ✓
   - `.devloop/plan.md` exists ✓
   - Status: `valid`
3. Sets FRESH_START_DETECTED=true
4. Adds CRITICAL auto-resume instruction to context
5. Displays "🔄 Fresh start detected - auto-resuming work..."

**Step 5: Auto-Resume Execution**
1. Claude receives CRITICAL instruction
2. Claude automatically invokes `/devloop:continue` (no user prompt)
3. Continue command (Step 1a):
   - Reads `.devloop/next-action.json`
   - Parses state (plan, phase, next_pending)
   - Deletes state file (single-use)
   - Displays "Resuming from Fresh Start" message
4. Continue proceeds with next pending task from state

**Expected Output Timeline**:

```
[Session End - Stop Hook]
User: [Ends session]
Hook: {
  "decision": "route",
  "pending_tasks": 5,
  "next_task": "Task 3.1: Implement feature",
  "options": ["Continue next task", "Fresh start", "Stop"]
}

[User Chooses Fresh Start]
User: /devloop:fresh
Fresh: State saved to .devloop/next-action.json
       Run /clear to reset context, then /devloop:continue to resume

[User Clears Context]
User: /clear
System: Context cleared

[New Session - Auto-Resume]
SessionStart Hook: 🔄 Fresh start detected - auto-resuming work...
Claude: [Automatically invokes /devloop:continue]
Continue: Resuming from Fresh Start
          Plan: Feature Implementation
          Progress: 8 of 13 tasks (62%)
          Next: Task 3.1: Implement feature
```

**Validation Criteria**:
- ✅ Stop hook detects pending tasks and presents routing options
- ✅ Fresh command saves state to next-action.json
- ✅ State file contains correct fields (timestamp, plan, next_pending)
- ✅ Session start hook detects state file
- ✅ Validation passes (timestamp fresh, plan exists)
- ✅ CRITICAL auto-resume instruction sent to Claude
- ✅ Claude automatically invokes /devloop:continue without user prompt
- ✅ Continue reads, parses, and deletes state file
- ✅ User sees "Resuming from Fresh Start" message
- ✅ Next task matches state's next_pending field
- ✅ Work resumes seamlessly with fresh context

**Edge Cases to Test**:
- Uncommitted changes during Stop: Auto-commit suggestion appears
- Stale state (>7 days): Warning displayed, auto-resume skipped
- Missing plan during resume: Warning displayed, auto-resume skipped
- Corrupted state file: Warning displayed, auto-resume skipped
- Multiple fresh starts in succession: Each creates new state, old state deleted

---

### Hook Testing Summary

| Test | Status | Component | Validation |
|------|--------|-----------|------------|
| Hook Test 1: Pending tasks routing | ✅ Documented | Stop hook | Manual validation in Phase 4 |
| Hook Test 2: No plan → approve | ✅ Documented | Stop hook | Manual validation in Phase 4 |
| Hook Test 3: Complete plan → ship | ✅ Documented | Stop hook | Manual validation in Phase 4 |
| Hook Test 4: Uncommitted changes | ✅ Documented | Stop hook | Manual validation in Phase 4 |
| Hook Test 5: Fresh start resume | ✅ Implemented | Session start | Phase 2 complete (Tasks 2.1, 2.2) |
| Hook Test 6: Stale state warning | ✅ Implemented | Session start | Phase 2 complete (Task 2.2) |
| Hook Test 7: Invalid plan handling | ✅ Documented | Stop hook | Manual validation in Phase 4 |
| Hook Test 8: Missing plan warning | ✅ Implemented | Session start | Phase 2 complete (Task 2.2) |
| Hook Test 9: End-to-end workflow | ✅ Documented | Full loop | Manual validation in Phase 4 |

**Testing Notes**:
- Hook Tests 1-4, 7: Behavior defined, manual validation in Phase 4 (Task 4.1)
- Hook Tests 5-6, 8: Implementation complete in Phase 2 (Tasks 2.1, 2.2)
- Hook Test 9: End-to-end scenario documented, manual validation in Phase 4 (Task 4.1)
- All tests require actual event triggers (session stops, starts)
- Recommend end-to-end testing before version 2.2.0 release

**Implementation Status**:
- Phase 1 (Stop hook): Tasks 1.2-1.3 complete → Hook Tests 1-4, 7 specified
- Phase 2 (Auto-resume): Tasks 2.1-2.2 complete → Hook Tests 5-6, 8 implemented, Test 9 specified
- Phase 4 (Validation): Task 4.1 will execute all 9 test scenarios

---

## Integration Test Scenarios

### Scenario 1: Complete Workflow Loop

**Goal**: Validate plan → work → checkpoint → commit → continue cycle

**Reference**: Integration Test Report Phase 9, Scenario 1

**Test Steps**:

1. **Setup**
   ```bash
   # Create test plan with 3 tasks
   cat > .devloop/plan.md <<EOF
   # Devloop Plan: Test Feature

   ## Tasks
   - [ ] Task 1: Implement feature A
   - [ ] Task 2: Write tests for feature A
   - [ ] Task 3: Create documentation
   EOF
   ```

2. **Execute First Task**
   ```bash
   /devloop:continue

   # Verify
   - [ ] Task 1 identified as next
   - [ ] Engineer invoked
   - [ ] Implementation complete
   ```

3. **Checkpoint (Step 5a)**
   ```bash
   # After task completion

   # Verify
   - [ ] Agent output verified (✓ success indicator)
   - [ ] Plan marker update: Task 1 [ ] → [x]
   - [ ] Progress Log entry added
   - [ ] Checkpoint question presented
   - [ ] 4 options: continue/commit/fresh/stop
   - [ ] "Continue to next task" recommended
   ```

4. **Continue to Next Task**
   ```bash
   # Select "Continue to next task"

   # Verify
   - [ ] No commit created (changes uncommitted)
   - [ ] Loop continues to Task 2
   - [ ] QA engineer invoked (test generation)
   ```

5. **Commit After Second Task**
   ```bash
   # Complete Task 2, select "Commit this work"

   # Verify
   - [ ] Conventional commit message prepared
   - [ ] Changes staged (git add)
   - [ ] Commit created
   - [ ] Worklog updated with commit hash
   - [ ] Follow-up question: "Continue or stop?"
   ```

6. **Loop Completion Detection (Step 5b)**
   ```bash
   # Complete Task 3

   # Verify task counting
   - [ ] pending_tasks = 0
   - [ ] completed_tasks = 3
   - [ ] completion_state = "complete"

   # Verify completion question
   - [ ] "All tasks complete!" message
   - [ ] 4 options: ship/review/add-more/end
   - [ ] "Ship it" recommended
   ```

7. **Context Management (Step 5c)**
   ```bash
   # If session has 10+ tasks

   # Verify metrics
   - [ ] tasks_completed tracked
   - [ ] agents_spawned tracked
   - [ ] session_duration tracked

   # Verify warnings
   - [ ] Advisory warning at 10 tasks
   - [ ] Critical warning at 150k tokens (if reached)
   - [ ] Fresh start offered
   ```

**Success Criteria**:
- ✓ All checkpoints triggered
- ✓ Plan markers updated correctly
- ✓ Completion detection accurate
- ✓ Context warnings appropriate

---

### Scenario 2: Fresh Start Full Cycle

**Goal**: Validate `/devloop:fresh` → SessionStart detection → `/devloop:continue` resume

**Reference**: Integration Test Report Phase 9, Scenario 2

**Test Steps**:

1. **Setup - Active Plan**
   ```bash
   # Create plan with some completed tasks
   # Mark Task 1.1 and 1.2 as [x]
   # Leave Task 1.3 as [ ]
   ```

2. **Run Fresh Start**
   ```bash
   /devloop:fresh

   # Verify output
   - [ ] Plan state gathered
   - [ ] Progress: "2 of 3 tasks (67%)"
   - [ ] Last completed: "Task 1.2"
   - [ ] Next pending: "Task 1.3"
   - [ ] State file created (.devloop/next-action.json)
   - [ ] Continuation instructions displayed
   ```

3. **Validate State File**
   ```bash
   cat .devloop/next-action.json

   # Verify fields
   - [ ] timestamp (ISO 8601 format)
   - [ ] plan ("Test Feature")
   - [ ] phase (current phase name)
   - [ ] total_tasks (3)
   - [ ] completed_tasks (2)
   - [ ] pending_tasks (1)
   - [ ] last_completed ("Task 1.2: ...")
   - [ ] next_pending ("Task 1.3: ...")
   - [ ] summary (<200 chars)
   - [ ] reason ("fresh_start")
   ```

4. **Start New Session (Simulate /clear)**
   ```bash
   # Restart Claude Code OR start new conversation

   # Verify SessionStart hook (session-start.sh)
   - [ ] .devloop/next-action.json detected
   - [ ] State parsed (jq or grep/sed fallback)
   - [ ] Fresh start message displayed:
         "**Fresh Start Detected**: Resuming 'Test Feature' at Phase X"
         "→ Progress: Completed 2 of 3 tasks (67%)"
         "→ Next: Task 1.3"
         "→ Run `/devloop:continue` to resume"
   ```

5. **Resume with Continue**
   ```bash
   /devloop:continue

   # Verify Step 1a (state detection)
   - [ ] State file detected
   - [ ] State read and parsed
   - [ ] State file DELETED immediately
   - [ ] Fresh start context displayed
   - [ ] FRESH_START_MODE=true set

   # Verify Step 1b (normal plan reading)
   - [ ] Plan file read
   - [ ] Plan structure validated

   # Verify Step 2 (status display)
   - [ ] "Plan: Test Feature (Fresh Start)" header
   - [ ] Progress: "2/3 tasks complete"
   - [ ] "Resuming from: Fresh start at [timestamp]"
   - [ ] Next Up: "Task 1.3" (from saved state)
   ```

6. **Verify State File Cleanup**
   ```bash
   ls .devloop/next-action.json

   # Verify
   - [ ] File does not exist (deleted after reading)
   ```

**Success Criteria**:
- ✓ State saved correctly
- ✓ SessionStart detects and displays state
- ✓ Continue reads and deletes state
- ✓ Next task from saved state used
- ✓ Single-use consumption (file deleted)

---

### Scenario 3: Spike → Plan Application

**Goal**: Verify Phase 5b logic enables applying spike findings to plan with auto-continue

**Reference**: Integration Test Report Phase 9, Scenario 3

**Test Steps**:

1. **Setup - Existing Plan**
   ```bash
   # Create plan with authentication tasks
   cat > .devloop/plan.md <<EOF
   ### Phase 2: Implementation
   - [ ] Task 2.1: Create user model
   - [ ] Task 2.2: Add basic auth
   - [ ] Task 2.3: Wire up routes
   EOF
   ```

2. **Run Spike**
   ```bash
   /devloop:spike "JWT vs OAuth for authentication"

   # Complete spike phases 1-4
   # Ensure spike report recommends plan changes
   ```

3. **Verify Spike Report Plan Updates Section**
   ```bash
   cat .devloop/spikes/jwt-vs-oauth-for-authentication.md

   # Verify section exists
   - [ ] "### Plan Updates Required"
   - [ ] "**Existing Plan**: [Plan name]"
   - [ ] "**Relationship**: Replaces Task 2.2"
   - [ ] Recommended changes list with specific tasks
   ```

4. **Phase 5b: Plan Application**
   ```bash
   # After spike completion

   # Verify detection
   - [ ] Active plan detected (.devloop/plan.md)
   - [ ] Spike recommendations analyzed
   - [ ] Diff preview generated

   # Verify diff display
   - [ ] Shows unified diff format
   - [ ] Line numbers included
   - [ ] Highlights: additions (+), removals (-), modifications (~)
   - [ ] Conflicting tasks highlighted (if any)
   ```

5. **Application Question**
   ```bash
   # Verify AskUserQuestion
   - [ ] Question: "Spike recommends [N] plan changes. Apply to .devloop/plan.md?"
   - [ ] Header: "Apply"
   - [ ] 4 options:
         1. "Apply and start" (recommended)
         2. "Apply only"
         3. "Review changes"
         4. "Skip updates"
   ```

6. **Test "Apply and Start"**
   ```bash
   # Select option 1

   # Verify
   - [ ] All changes applied to plan
   - [ ] Task 2.2 updated (basic auth → JWT auth)
   - [ ] Progress Log entry: "Applied spike findings: [Topic]"
   - [ ] Plan timestamp updated
   - [ ] `/devloop:continue` IMMEDIATELY invoked
   - [ ] Spike command exits
   - [ ] Continue takes over with updated plan
   ```

7. **Test "Apply Only"**
   ```bash
   # Select option 2

   # Verify
   - [ ] Changes applied
   - [ ] Progress Log updated
   - [ ] Message: "Plan updated. Run `/devloop:continue` when ready."
   - [ ] Continues to Phase 5c (next steps)
   ```

**Success Criteria**:
- ✓ Spike recommendations detected
- ✓ Diff preview accurate
- ✓ "Apply and start" auto-invokes continue
- ✓ Plan changes applied correctly
- ✓ Edge cases handled (no plan, conflicts, archived phases)

---

### Scenario 4: Worklog Sync Enforcement

**Goal**: Verify mandatory worklog sync at checkpoints and session end

**Reference**: Integration Test Report Phase 9, Scenario 4

**Test Steps**:

1. **Setup - First Task**
   ```bash
   # Plan exists, no worklog yet
   rm -f .devloop/worklog.md
   ```

2. **Complete First Task**
   ```bash
   /devloop:continue
   # Complete Task 1.1

   # Verify Step 3: Mandatory Worklog Checkpoint
   - [ ] Worklog file created (.devloop/worklog.md)
   - [ ] Pending entry added:
         "- [ ] Task 1.1: [Description] (pending)"
   - [ ] "Last Updated" timestamp added
   - [ ] Enforcement check passed (advisory mode default)
   ```

3. **Create Commit**
   ```bash
   # At checkpoint, select "Commit this work"

   # Verify Step 6a: Commit Hash Update
   - [ ] Worklog read
   - [ ] Pending entry found
   - [ ] Entry updated:
         "- [ ] Task 1.1: ..." → "- [x] Task 1.1: ... (abc1234)"
   - [ ] Commit table entry added:
         "| abc1234 | 2025-12-23 14:30 | feat(scope): description - Task 1.1 | 1.1 |"
   - [ ] Timestamp updated
   ```

4. **Grouped Commit**
   ```bash
   # Complete Task 1.2 and 1.3 without committing
   # Then commit both together

   # Verify grouped entry
   - [ ] Both tasks in same commit:
         "- [x] Task 1.2: ... (def5678)"
         "- [x] Task 1.3: ... (def5678)"
   - [ ] Single commit table entry
   ```

5. **Session End Reconciliation**
   ```bash
   # Complete Task 1.4, choose "Stop here" (don't commit)

   # Verify reconciliation prompt
   - [ ] Pending entries detected (grep for "(pending)")
   - [ ] Reconciliation question presented
   - [ ] Options for each pending task:
         - Commit now
         - Keep pending
         - Discard
   ```

6. **Fresh Start with Pending Work**
   ```bash
   # Pending entries exist in worklog
   /devloop:fresh

   # Verify
   - [ ] Reconciliation runs BEFORE saving state
   - [ ] Offers to commit/keep/discard pending entries
   - [ ] Prevents state file creation with untracked work (strict mode)
   ```

**Success Criteria**:
- ✓ Worklog created on first task
- ✓ Pending entries added at checkpoints
- ✓ Commit hashes updated after git commit
- ✓ Grouped commits tracked correctly
- ✓ Session end reconciliation offered
- ✓ Fresh start integration working

---

### Scenario 5: Parallel Execution

**Goal**: Verify background agent execution and TaskOutput polling

**Test Steps**:

1. **Setup - Plan with Parallel Tasks**
   ```bash
   cat > .devloop/plan.md <<EOF
   ### Phase 1: Exploration
   - [ ] Task 1.1: Explore payment module [parallel:A]
   - [ ] Task 1.2: Explore auth module [parallel:A]
   - [ ] Task 1.3: Explore notification module [parallel:A]
   EOF
   ```

2. **Execute Parallel Tasks**
   ```bash
   /devloop:continue

   # Verify parallel detection (Step 6)
   - [ ] Parallel marker [parallel:A] detected
   - [ ] Tasks grouped by marker
   - [ ] Parallel execution question presented:
         "Tasks A, B, C can run in parallel. Run together?"
   - [ ] Options: all-parallel/sequential/pick-specific
   ```

3. **Run in Parallel**
   ```bash
   # Select "Run all in parallel"

   # Verify background execution
   - [ ] 3x Task tools launched with run_in_background=true
   - [ ] Background agent counter incremented (3)
   - [ ] TaskOutput polling started
   ```

4. **Verify Polling Pattern**
   ```bash
   # Observe TaskOutput calls

   # Verify
   - [ ] TaskOutput(block=false) called periodically
   - [ ] Results collected as agents complete
   - [ ] Background agent counter decremented on completion
   - [ ] Synthesis step after all complete
   ```

5. **Context Management with Parallel Agents**
   ```bash
   # If 5+ parallel agents running

   # Verify warning (Step 5c)
   - [ ] "5+ background agents" warning triggered
   - [ ] Recommendation: Wait for completion or reduce parallelism
   - [ ] Fresh start offered if context heavy
   ```

**Success Criteria**:
- ✓ Parallel tasks detected
- ✓ Background execution works
- ✓ TaskOutput polling collects results
- ✓ Context warnings triggered appropriately

---

### Scenario 6: Archive Workflow

**Goal**: Verify plan archival, compression, and worklog extraction

**Reference**: Task 6.5 results

**Test Steps**:

1. **Setup - Plan with Completed Phases**
   ```bash
   # Ensure Phase 1 and Phase 2 are 100% complete (all tasks [x])
   # Phase 3 has pending tasks
   ```

2. **Run Archive**
   ```bash
   /devloop:archive

   # Verify Phase Detection (Step 2)
   - [ ] Completed phases identified (Phase 1, Phase 2)
   - [ ] Active phases identified (Phase 3)
   - [ ] Analysis displayed with task counts
   ```

3. **Confirm Archival (Step 3)**
   ```bash
   # Verify question
   - [ ] Multi-select question presented
   - [ ] Completed phases listed
   - [ ] User confirms selection
   ```

4. **Verify Archive Files Created (Step 5)**
   ```bash
   ls .devloop/archive/

   # Verify
   - [ ] 2 archive files created
   - [ ] Filename format: {plan}_phase_{N}_{timestamp}.md
   - [ ] Archive contains: phase header + tasks + Progress Log entries
   ```

5. **Verify Plan Compression (Step 6)**
   ```bash
   wc -l .devloop/plan.md

   # Verify
   - [ ] Line count reduced (~50% for large plans)
   - [ ] Archived phases removed
   - [ ] Plan structure intact (header, overview, active phases)
   - [ ] Last 10 Progress Log entries kept
   - [ ] Archival note in Progress Log
   ```

6. **Verify Worklog Update (Step 5d)**
   ```bash
   cat .devloop/worklog.md

   # Verify
   - [ ] Phase summaries added
   - [ ] Task lists included
   - [ ] Commit hashes listed (if available)
   - [ ] Archive file references added
   ```

7. **Continue After Archive**
   ```bash
   /devloop:continue

   # Verify
   - [ ] Compressed plan works
   - [ ] Archive status displayed
   - [ ] No errors from missing phases
   ```

**Success Criteria**:
- ✓ Archive files created correctly
- ✓ Plan compressed (target ~50% reduction)
- ✓ Worklog updated with phase summaries
- ✓ Continue workflow works with archived plan

---

### Scenario 7: Error Recovery

**Goal**: Verify error handling and recovery workflows

**Test Steps**:

1. **Task Failure**
   ```bash
   # Engineer encounters blocking error

   # Verify error checkpoint (Step 5a)
   - [ ] Failure indicator (✗) displayed
   - [ ] Error description shown
   - [ ] Error recovery question presented
   - [ ] 4 options: retry/skip-and-block/investigate/abort
   ```

2. **Partial Completion**
   ```bash
   # Task partially complete (some criteria met)

   # Verify partial checkpoint
   - [ ] Partial indicator (~) displayed
   - [ ] What's missing explained
   - [ ] Partial completion question presented
   - [ ] Options: mark-done/continue-work/note-as-debt/fresh
   ```

3. **State File Corruption**
   ```bash
   # Setup - corrupt state file
   echo '{"invalid": json}' > .devloop/next-action.json

   /devloop:continue

   # Verify
   - [ ] Corruption detected
   - [ ] Warning logged
   - [ ] File ignored
   - [ ] Normal flow continues
   ```

4. **Missing Plan Recovery**
   ```bash
   # Setup - state file exists but plan missing
   rm .devloop/plan.md

   /devloop:continue

   # Verify
   - [ ] State info displayed
   - [ ] "No Plan" question presented
   - [ ] Options: create-plan/start-devloop
   ```

**Success Criteria**:
- ✓ Errors handled gracefully
- ✓ Recovery options presented
- ✓ Corrupted state ignored
- ✓ Workflows continue despite errors

---

### Scenario 8: Ship → Route to Issues

**Goal**: Verify post-completion routing from ship workflow to issue tracking

**Reference**: Spike Report - Plan Completion & Post-Completion Routing

**Test Steps**:

1. **Setup - Completed Plan with Open Issues**
   ```bash
   # Ensure plan is complete
   # Ensure .devloop/issues/ has open issues (BUG-001, FEAT-001, etc.)
   ls .devloop/issues/*.md
   ```

2. **Run Ship Workflow**
   ```bash
   /devloop:ship

   # Complete all ship phases (Pre-flight → DoD → Tests → Build → Git → Version)
   # Proceed through all validation steps
   ```

3. **Verify Phase 7: Post-Ship Routing**
   ```bash
   # After successful ship completion

   # Verify routing question (Phase 7)
   - [ ] "Feature shipped! What's next?" question displayed
   - [ ] Header: "Next"
   - [ ] 5 routing options presented:
         1. "Work on existing issue"
         2. "Start new feature"
         3. "Archive this plan"
         4. "Fresh start"
         5. "End session"
   - [ ] "Start new feature" marked as recommended
   ```

4. **Select "Work on existing issue"**
   ```bash
   # Choose option 1

   # Verify routing
   - [ ] `/devloop:issues` command invoked automatically
   - [ ] Ship command exits cleanly
   - [ ] Issues command takes over
   - [ ] Issue list displayed (open issues shown)
   ```

5. **Verify Error Handling**
   ```bash
   # Simulate issues command failure (e.g., no .devloop/issues/ directory)
   rm -rf .devloop/issues

   # Re-run ship and select "Work on existing issue"

   # Verify
   - [ ] Error displayed gracefully
   - [ ] Error message explains the problem
   - [ ] Recovery options offered (retry/end)
   - [ ] Ship command doesn't crash
   ```

6. **Verify Plan Update**
   ```bash
   # After successful ship (before routing)
   cat .devloop/plan.md

   # Verify plan updates (Phase 6)
   - [ ] Status updated to "Complete"
   - [ ] Progress Log entry added with timestamp
   - [ ] Entry includes: "Feature shipped - [commit hash or PR URL]"
   - [ ] Plan timestamps updated
   ```

**Success Criteria**:
- ✓ Routing question displays after ship completion
- ✓ "Work on existing issue" option invokes `/devloop:issues`
- ✓ Command handoff works cleanly (ship exits, issues starts)
- ✓ Error handling prevents crashes
- ✓ Plan file updated correctly before routing

---

### Scenario 9: Ship → Route to Fresh Start

**Goal**: Verify post-completion routing from ship workflow to fresh start

**Reference**: Spike Report - Plan Completion & Post-Completion Routing

**Test Steps**:

1. **Setup - Completed Plan, Long Session**
   ```bash
   # Ensure plan is complete (all tasks [x])
   # Simulate long session (10+ tasks completed)
   # Ensure uncommitted changes don't exist (ship creates commits)
   git status  # Should show clean state after ship
   ```

2. **Run Ship Workflow**
   ```bash
   /devloop:ship

   # Complete all ship phases
   # Proceed through validation and git integration
   ```

3. **Verify Phase 7: Post-Ship Routing**
   ```bash
   # After successful ship completion

   # Verify routing question
   - [ ] "Feature shipped! What's next?" question displayed
   - [ ] 5 routing options presented
   - [ ] Options include: "Fresh start (Save state and clear context)"
   ```

4. **Select "Fresh start"**
   ```bash
   # Choose option 4: "Fresh start"

   # Verify routing
   - [ ] `/devloop:fresh` command invoked automatically
   - [ ] Ship command exits cleanly
   - [ ] Fresh start command takes over
   ```

5. **Verify Fresh Start State Creation**
   ```bash
   # After fresh start invoked

   # Verify state file created (Phase 1-2 of fresh.md)
   - [ ] .devloop/next-action.json exists
   - [ ] State file contains valid JSON
   - [ ] State includes: plan, phase, summary, next_pending
   - [ ] Reason field = "fresh_start"
   - [ ] Plan status = "Complete" (from ship update)
   ```

6. **Verify State File Format**
   ```bash
   cat .devloop/next-action.json | jq .

   # Verify required fields
   - [ ] timestamp (ISO 8601 format)
   - [ ] plan (plan name from completed plan)
   - [ ] phase (last phase)
   - [ ] total_tasks (task count)
   - [ ] completed_tasks (should equal total_tasks)
   - [ ] pending_tasks (should be 0)
   - [ ] last_completed (last task from plan)
   - [ ] next_pending ("None" or similar, since plan complete)
   - [ ] summary (<200 chars, mentions completion)
   ```

7. **Verify Fresh Start Instructions**
   ```bash
   # After state file created

   # Verify fresh start output
   - [ ] Continuation instructions displayed
   - [ ] Instructions mention: "Run `/devloop:continue` to resume"
   - [ ] Instructions mention: "Or start new session with `/clear`"
   - [ ] Progress Log updated in plan
   ```

8. **Test Fresh Start Detection (New Session)**
   ```bash
   # Start new Claude Code session (or run /clear)

   # Verify SessionStart hook detection
   - [ ] State file detected by session-start.sh
   - [ ] Fresh start message displayed:
         "**Fresh Start Detected**: Resuming '[plan name]' at [phase]"
   - [ ] Progress summary shown: "Completed [N] of [N] tasks (100%)"
   - [ ] Next action: "Plan is complete - consider new feature"
   - [ ] Instructions: "Run `/devloop:continue` to resume"
   ```

9. **Verify Fresh Start Cleanup**
   ```bash
   # Run continue in new session
   /devloop:continue

   # Verify state file cleanup (Step 1a in continue.md)
   - [ ] State file read successfully
   - [ ] State info displayed in status
   - [ ] State file DELETED after reading
   - [ ] Fresh start context shown in plan summary
   ```

10. **Verify Error Handling**
    ```bash
    # Simulate fresh command failure (e.g., corrupted plan.md)
    echo "Invalid plan content" > .devloop/plan.md

    # Re-run ship and select "Fresh start"

    # Verify
    - [ ] Error displayed gracefully
    - [ ] Error message explains the problem
    - [ ] Recovery options offered
    - [ ] State file not created (safety check)
    ```

**Success Criteria**:
- ✓ Routing question displays after ship completion
- ✓ "Fresh start" option invokes `/devloop:fresh`
- ✓ Command handoff works cleanly (ship exits, fresh starts)
- ✓ State file created with correct format
- ✓ Plan updated to "Complete" before fresh start
- ✓ SessionStart detects fresh start in new session
- ✓ State file deleted after reading in continue
- ✓ Error handling prevents data corruption

---

### Scenario 10: Continue → Archive and Start Fresh

**Goal**: Verify completion routing from continue workflow to archive + new plan creation

**Reference**: Spike Report - Plan Completion & Post-Completion Routing (Phase 2)

**Test Steps**:

1. **Setup - Completed Plan (>200 lines)**
   ```bash
   # Ensure plan is complete (all tasks [x])
   # Ensure plan.md is large (>200 lines for archive recommendation)
   wc -l .devloop/plan.md  # Should show 200+ lines
   git status  # Should show clean state or pending commits
   ```

2. **Run Continue to Completion**
   ```bash
   /devloop:continue

   # Complete final task (if any pending)
   # Proceed through checkpoint (Step 5a)
   # Trigger completion detection (Step 5b)
   ```

3. **Verify Completion Routing Options (Step 5b)**
   ```bash
   # After all tasks complete

   # Verify completion question
   - [ ] "All tasks complete! Plan finished. What's next?" question displayed
   - [ ] Header: "Complete"
   - [ ] 6 routing options presented:
         1. "Ship it" (Recommended)
         2. "Review plan"
         3. "Add more tasks"
         4. "Archive and start fresh"
         5. "Work on issues"
         6. "End session"
   - [ ] "Ship it" marked as recommended
   ```

4. **Select "Archive and start fresh"**
   ```bash
   # Choose option 4: "Archive and start fresh"

   # Verify routing to archive command
   - [ ] `/devloop:archive` command invoked automatically
   - [ ] Continue command pauses, archive takes over
   - [ ] Archive workflow begins (compress plan, move to .devloop/archive/)
   ```

5. **Verify Archive Completion**
   ```bash
   # After archive completes

   # Verify archived plan
   - [ ] Plan moved to .devloop/archive/[plan-name]_[timestamp].md
   - [ ] Archive file contains complete plan with all tasks
   - [ ] Archive preserves Progress Log entries
   - [ ] Archive includes completion metadata
   ```

6. **Verify New Plan Creation**
   ```bash
   # After archive, verify follow-up workflow

   # Verify new plan question
   - [ ] "Plan archived. Create new plan?" question displayed
   - [ ] Header: "New Plan"
   - [ ] 3 options presented:
         1. "Create empty plan"
         2. "Start feature workflow (/devloop)"
         3. "Leave archived"
   ```

7. **Select "Create empty plan"**
   ```bash
   # Choose option 1

   # Verify new plan created
   - [ ] New .devloop/plan.md created with template
   - [ ] Plan includes: Name, Created, Status, Overview sections
   - [ ] Status = "Draft"
   - [ ] Progress Log initialized with "Plan created" entry
   - [ ] Old plan fully archived (not in active plan.md)
   ```

8. **Verify Error Handling**
   ```bash
   # Simulate archive failure (e.g., no write permissions)
   chmod -w .devloop/

   # Re-run continue and select "Archive and start fresh"

   # Verify
   - [ ] Error displayed gracefully
   - [ ] Error message explains the problem (e.g., "Failed to archive plan")
   - [ ] Recovery options offered (retry/skip)
   - [ ] Original plan.md NOT modified or deleted
   - [ ] No partial archives created
   ```

9. **Verify Worklog Integration**
   ```bash
   # After successful archive

   # Verify worklog updated
   cat .devloop/worklog.md

   - [ ] Worklog includes entry for archived plan
   - [ ] Entry format: "Archived [plan name] - [N] tasks completed"
   - [ ] Entry includes archive file path reference
   - [ ] Commit hashes from completed tasks preserved
   ```

**Success Criteria**:
- ✓ Completion routing question displays with 6 options
- ✓ "Archive and start fresh" option invokes `/devloop:archive`
- ✓ Command handoff works cleanly (continue pauses, archive starts)
- ✓ Plan archived to .devloop/archive/ with complete history
- ✓ New plan creation workflow offered after archive
- ✓ New empty plan.md created with template structure
- ✓ Error handling prevents plan corruption or data loss
- ✓ Worklog updated with archive reference

---

### Scenario 11: Continue → Work on Issues

**Goal**: Verify completion routing from continue workflow to issue tracking

**Reference**: Spike Report - Plan Completion & Post-Completion Routing (Phase 2)

**Test Steps**:

1. **Setup - Completed Plan with Open Issues**
   ```bash
   # Ensure plan is complete (all tasks [x])
   # Ensure .devloop/issues/ has open issues
   ls .devloop/issues/*.md
   # Should show: BUG-001.md, FEAT-001.md, TASK-001.md, etc.
   ```

2. **Run Continue to Completion**
   ```bash
   /devloop:continue

   # Complete final task (if any pending)
   # Proceed through checkpoint (Step 5a)
   # Trigger completion detection (Step 5b)
   ```

3. **Verify Completion Routing Options (Step 5b)**
   ```bash
   # After all tasks complete

   # Verify completion question
   - [ ] "All tasks complete! Plan finished. What's next?" question displayed
   - [ ] Header: "Complete"
   - [ ] 6 routing options presented (including "Work on issues")
   - [ ] "Ship it" marked as recommended
   ```

4. **Select "Work on issues"**
   ```bash
   # Choose option 5: "Work on issues"

   # Verify routing to issues command
   - [ ] `/devloop:issues` command invoked automatically
   - [ ] Continue command exits cleanly
   - [ ] Issues command takes over
   ```

5. **Verify Issues List Display**
   ```bash
   # After issues command invoked

   # Verify issue list displayed
   - [ ] All open issues shown (BUG, FEAT, TASK, etc.)
   - [ ] Issue list grouped by type (Bugs, Features, Tasks)
   - [ ] Issue IDs and descriptions visible
   - [ ] User prompted with action options:
         1. "View issue"
         2. "Fix bug"
         3. "Start feature"
         4. "Work on task"
         5. "Create new issue"
   ```

6. **Verify Error Handling - No Issues Directory**
   ```bash
   # Simulate no issues directory
   rm -rf .devloop/issues

   # Re-run continue and select "Work on issues"

   # Verify
   - [ ] Error displayed gracefully (not a crash)
   - [ ] Error message: "No issues directory found"
   - [ ] Recovery options offered:
         1. "Create issues directory"
         2. "Start new feature instead"
         3. "End session"
   - [ ] Continue command doesn't crash
   ```

7. **Verify Error Handling - No Open Issues**
   ```bash
   # Simulate no open issues (all closed)
   # Ensure .devloop/issues/index.md shows all issues closed

   # Re-run continue and select "Work on issues"

   # Verify
   - [ ] Message displayed: "No open issues found"
   - [ ] Follow-up options offered:
         1. "Create new issue"
         2. "Start new feature"
         3. "Review closed issues"
         4. "End session"
   ```

8. **Verify Plan Update**
   ```bash
   # Before routing to issues (during completion detection)
   cat .devloop/plan.md

   # Verify plan metadata updated
   - [ ] Status = "Complete"
   - [ ] Progress Log entry added: "All tasks complete - routing to issues"
   - [ ] Timestamp updated to completion time
   ```

9. **Verify Worklog Integration**
   ```bash
   # After completion
   cat .devloop/worklog.md

   # Verify worklog entry
   - [ ] Entry added for completed plan
   - [ ] Entry format: "[plan name] - Complete ([N] tasks)"
   - [ ] Commit hashes from tasks preserved
   - [ ] Entry includes timestamp of completion
   ```

**Success Criteria**:
- ✓ Completion routing question displays with 6 options
- ✓ "Work on issues" option invokes `/devloop:issues`
- ✓ Command handoff works cleanly (continue exits, issues starts)
- ✓ Issue list displayed with all open issues
- ✓ Error handling for missing directory/no issues
- ✓ Recovery options prevent dead ends
- ✓ Plan status updated to "Complete" before routing
- ✓ Worklog updated with completion entry

---

## Regression Testing Checklist

### Breaking Changes to Watch For

After any code changes, verify these critical paths:

**Agent Routing**:
- [ ] `/devloop:continue` still routes to correct agents
- [ ] Engineer mode detection still works
- [ ] QA engineer mode detection still works
- [ ] Task planner mode detection still works

**Checkpoint Enforcement**:
- [ ] Checkpoints still trigger after every task
- [ ] Plan markers still update correctly
- [ ] Loop completion still detects correctly
- [ ] Context warnings still display at thresholds

**Fresh Start Mechanism**:
- [ ] `/devloop:fresh` still creates state file
- [ ] SessionStart still detects state
- [ ] `/devloop:continue` still reads and deletes state
- [ ] State format still valid JSON

**Plan Management**:
- [ ] Plans still read from standard locations
- [ ] Plan markers still parse correctly (`[x]`, `[ ]`, `[~]`, `[!]`, `[-]`)
- [ ] Progress Log still updates
- [ ] Archive workflow still compresses plans

### Backward Compatibility Checks

**Plan Format**:
- [ ] Old plans (without fresh start support) still work
- [ ] Plans without Progress Log still work
- [ ] Plans without archived phases still work

**Skill Invocation**:
- [ ] Skills still auto-load based on context
- [ ] `Skill: skill-name` syntax still works
- [ ] Skills still referenced in agents

**Hook Integration**:
- [ ] SessionStart hook still runs
- [ ] Task invocation logging still works (if enabled)
- [ ] Pre-commit hook still validates plan

### Version Upgrade Testing

After updating devloop version:

1. **Fresh Install Test**
   ```bash
   # Remove and reinstall plugin
   /plugin uninstall devloop
   /plugin install ./plugins/devloop

   # Verify
   - [ ] Plugin loads without errors
   - [ ] All commands available
   - [ ] All agents available
   - [ ] All skills load
   ```

2. **Existing Project Test**
   ```bash
   # Use existing project with .devloop/ directory

   # Verify
   - [ ] Existing plans still work
   - [ ] Worklog still readable
   - [ ] Archives still accessible
   - [ ] Issues still tracked
   ```

3. **Migration Path Test**
   ```bash
   # Test upgrade from previous version

   # Verify
   - [ ] No breaking changes
   - [ ] New features work
   - [ ] Old features still work
   - [ ] No data loss
   ```

---

## Performance Testing

### Token Usage Monitoring

**Track token consumption across workflows**:

| Workflow | Expected Token Range | Model Mix |
|----------|----------------------|-----------|
| Simple implementation | 5k-15k | 1x engineer (sonnet) |
| Feature with tests | 20k-40k | engineer + qa-engineer + code-reviewer |
| Full feature workflow | 50k-100k | Full 12-phase workflow |
| Large exploration | 30k-60k | 3x engineer (explore, parallel) |

**How to Monitor**:
- Enable task logging hook
- Track agent invocations
- Estimate: sonnet task ≈ 5-10k tokens, haiku ≈ 1-2k tokens, opus ≈ 25-50k tokens

### Context Management Thresholds

**Verify warnings trigger at correct thresholds** (Step 5c):

| Metric | Threshold | Test Method |
|--------|-----------|-------------|
| Tasks completed | 10+ | Complete 10 tasks in session, verify warning |
| Agents spawned | 15+ | Spawn 15 agents, verify warning |
| Session duration | 2+ hours | Long session, verify warning |
| Plan size | 500+ lines | Large plan, verify info message |
| Estimated tokens | 150k+ | Heavy usage, verify critical warning |
| Background agents | 5+ | Spawn 5 parallel agents, verify warning |

### Background Agent Limits

**Test parallel execution limits**:

```bash
# Launch 5+ background agents
- [ ] Warning triggered at 5 agents
- [ ] Recommendation to wait or reduce
- [ ] TaskOutput polling works efficiently
- [ ] No performance degradation
```

### Model Escalation Verification

**Test model escalation recommendations** (engineer agent):

| Scenario | Expected Escalation |
|----------|---------------------|
| 5+ files affected | ⚠️ Suggest opus |
| Security-sensitive code | ⚠️ Suggest opus |
| Complex async patterns | ⚠️ Suggest opus |
| Simple 1-file change | No escalation |

---

## Edge Cases and Known Issues

### Archived Phase References

**Issue**: Task references archived phase

**Test**:
```bash
# Setup - task has [depends:1.1] but Phase 1 is archived

# Verify
- [ ] Dependency noted as archived
- [ ] "See archive" message displayed
- [ ] Task not blocked (archived phases treated as complete)
```

### Missing Plan Scenarios

**Issue**: Various missing plan scenarios

**Test Matrix**:

| Scenario | Command | Expected Behavior |
|----------|---------|-------------------|
| No plan at all | `/devloop:continue` | "No Plan" question with 4 options |
| State file but no plan | `/devloop:continue` | Display state, offer to create plan |
| Plan deleted mid-session | Continue workflow | Error, suggest recovery |

### Stale Context Handling

**Issue**: Session context becomes stale

**Test**:
```bash
# Complete 10+ tasks without fresh start

# Verify
- [ ] Advisory warning at 10 tasks
- [ ] Critical warning at 150k tokens
- [ ] Fresh start offered
- [ ] User can continue anyway
```

### Uncommitted Work Detection

**Issue**: Uncommitted changes at various points

**Test Matrix**:

| Point | Expected Behavior |
|-------|-------------------|
| Before `/devloop:fresh` | Offer to commit or save as pending |
| Before `/devloop:ship` | Prompt for commit creation |
| At session end | Worklog reconciliation offered |

### Failed Tests Recovery

**Issue**: Tests fail during `/devloop:ship`

**Test**:
```bash
# Setup - failing tests

/devloop:ship

# Verify
- [ ] Test failure detected
- [ ] Options: retry/skip/fix
- [ ] If "fix" selected, engineer invoked
- [ ] After fix, tests re-run
```

---

## Testing Tools and Utilities

### Using `.devloop/next-action.json` for Testing

**Manual state file creation for testing**:

```bash
# Create test state
cat > .devloop/next-action.json <<EOF
{
  "timestamp": "2025-12-23T14:30:00Z",
  "plan": "Test Feature",
  "phase": "Phase 2: Implementation",
  "total_tasks": 5,
  "completed_tasks": 2,
  "pending_tasks": 3,
  "last_completed": "Task 2.1: Create user model",
  "next_pending": "Task 2.2: Add authentication",
  "summary": "Completed 2 of 5 tasks (40%). Current phase: Phase 2.",
  "reason": "fresh_start"
}
EOF

# Test continue detection
/devloop:continue
```

### Log File Locations

**Agent invocation log** (if Task 4.1 logging enabled):
```bash
tail -f ~/.devloop-agent-invocations.log
```

**Format**:
```
[2025-12-23 14:30:00] Task Invoked:
  subagent_type: devloop:engineer
  description: Implement user authentication
  prompt: [First 200 chars...]
```

### Debug Mode Usage

**Enable debug output**:
```bash
# Run Claude Code with debug flag
claude --debug

# Shows:
- Plugin loading
- Manifest validation
- Component registration
- Hook execution
- Agent invocations
```

### State File Inspection

**Validate state file manually**:

```bash
# Check if state file exists
ls -la .devloop/next-action.json

# Validate JSON
cat .devloop/next-action.json | jq .

# Check required fields
cat .devloop/next-action.json | jq '{plan, phase, summary, next_pending}'
```

**Expected fields**:
- timestamp
- plan
- phase
- total_tasks
- completed_tasks
- pending_tasks
- last_completed
- next_pending
- summary
- reason

### Plan Validation

**Validate plan structure**:

```bash
# Check plan format
head -50 .devloop/plan.md

# Count task markers
grep -c '^\s*- \[x\]' .devloop/plan.md  # Completed
grep -c '^\s*- \[ \]' .devloop/plan.md  # Pending
grep -c '^\s*- \[~\]' .devloop/plan.md  # Partial
grep -c '^\s*- \[!\]' .devloop/plan.md  # Blocked

# Check for archived phases
grep -i 'archived phase' .devloop/plan.md
ls .devloop/archive/
```

### Worklog Validation

**Validate worklog structure**:

```bash
# Check worklog exists
cat .devloop/worklog.md

# Check for pending entries
grep '(pending)' .devloop/worklog.md

# Check for commit hashes
grep -E '\([a-f0-9]{7}\)' .devloop/worklog.md

# Verify commit table
grep -A 5 '| Hash | Date' .devloop/worklog.md
```

---

## Success Criteria

### Critical Functionality (Must Pass)

**100% of these must work for release**:

- [ ] `/devloop:continue` routes to correct agents
- [ ] Checkpoints trigger after every task
- [ ] Plan markers update correctly (`[ ]` → `[x]`)
- [ ] Loop completion detects when all tasks done
- [ ] `/devloop:fresh` creates valid state file
- [ ] SessionStart detects fresh start state
- [ ] State file deleted after reading
- [ ] Context warnings trigger at thresholds
- [ ] Archive workflow compresses plans
- [ ] Spike → plan application works

### Non-Critical Functionality (Should Pass)

**90%+ of these should work, documented issues acceptable**:

- [ ] All 15 smoke tests pass
- [ ] All 7 integration scenarios pass
- [ ] Parallel execution works efficiently
- [ ] Error recovery workflows complete
- [ ] Edge cases handled gracefully
- [ ] Performance within expected ranges

### When to Escalate Issues

**Critical Issues** (block release):
- Agent routing broken
- Checkpoints not triggering
- State file corruption causing data loss
- Plan markers not updating
- Fresh start cycle broken

**Major Issues** (fix before release):
- Edge cases failing
- Performance degradation
- Token usage excessive
- Recovery workflows broken

**Minor Issues** (document and defer):
- Cosmetic output issues
- Non-essential features
- Rare edge cases
- Performance optimizations

### Release Readiness Checklist

Before incrementing version to 2.1.0:

- [ ] All 15 smoke tests pass
- [ ] All 7 integration scenarios pass
- [ ] No critical issues
- [ ] Major issues resolved or documented
- [ ] Regression tests pass
- [ ] Performance acceptable
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Integration test report generated

---

## Appendix: Test Execution Log Template

**Use this template to track test execution**:

```markdown
# DevLoop Test Execution Log

**Date**: YYYY-MM-DD
**Tester**: [Name]
**Version**: [Version being tested]
**Environment**: [OS, Claude Code version]

## Smoke Tests

- [ ] 1. SessionStart Hook Detection - PASS/FAIL - Notes: ...
- [ ] 2. Continue Finds Plan - PASS/FAIL - Notes: ...
- [ ] 3. Engineer Agent Invoked - PASS/FAIL - Notes: ...
... (continue for all 15)

## Integration Scenarios

### Scenario 1: Complete Workflow Loop
- Status: PASS/FAIL
- Issues Found: ...
- Notes: ...

... (continue for all 7)

## Issues Found

| Issue # | Severity | Description | Status |
|---------|----------|-------------|--------|
| 1 | Critical | ... | Open/Fixed |

## Overall Assessment

- Critical Issues: [Count]
- Major Issues: [Count]
- Minor Issues: [Count]
- **Release Recommendation**: READY / NOT READY / CONDITIONAL

**Tester Sign-off**: [Name] - [Date]
```

---

**End of Testing Checklist**

For questions or issues with testing procedures, refer to:
- Integration Test Report: `.devloop/integration-test-report-phase9.md`
- Command implementations: `plugins/devloop/commands/*.md`
- Agent documentation: `plugins/devloop/docs/agents.md`
- Workflow loop skill: `plugins/devloop/skills/workflow-loop/SKILL.md`
