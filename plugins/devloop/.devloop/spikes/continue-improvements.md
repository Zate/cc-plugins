## Spike Report: Continue Command & Workflow Loop Improvements

**Date**: 2024-12-23
**Status**: Analysis Complete
**Scope**: `/devloop:continue`, workflow loop, context management, and related commands/agents

---

## Executive Summary

Analysis of the `/devloop:continue` command and the broader workflow loop (spike → plan → continue → work → validate → update → continue) identified several gaps in checkpoint enforcement, context management, AskUserQuestion consistency, and inter-command integration. The core issue is that the loop doesn't enforce mandatory checkpoints and has no mechanism for "fresh start" continuation.

---

## Questions Investigated

1. Why does AskUserQuestion behave inconsistently? → **No standardized patterns exist**
2. Can we programmatically clear context? → **No, but workarounds exist**
3. Is the workflow loop properly enforced? → **No, checkpoints are advisory only**
4. How do spike findings flow into plans? → **Weakly, requires manual intervention**

---

## Findings

### 1. SubagentStop Hook Doesn't Actually Route

**Location**: `hooks/hooks.json` - SubagentStop hook

**Problem**: The hook outputs a JSON suggestion but doesn't invoke AskUserQuestion or actually route to the next agent.

```json
"SubagentStop": [{
  "type": "prompt",
  "prompt": "...suggest the next logical step..."
}]
```

This just *suggests* - it doesn't *act*. The orchestrator (Claude) must still decide what to do.

**Options**:
1. Remove the hook entirely (it adds noise without value)
2. Change to actually present an AskUserQuestion with routing options
3. Have it output a structured recommendation that the continue command interprets

**Recommendation**: Option 1 (remove) or Option 3 (structured output that continue.md interprets)

---

### 2. Missing Mandatory Post-Task Checkpoint Loop

**Location**: `commands/continue.md` - Step 5 → Step 6 transition

**Problem**: After agent execution, the command describes a checkpoint but doesn't enforce it as a strict loop.

**Current Flow**:
```
Step 5: Execute agent → Step 6: Post-task checkpoint (described but optional)
```

**Recommended Flow**:
```
Step 5: Execute agent
Step 5a: MANDATORY checkpoint (always runs):
  - Verify agent output
  - Update plan markers
  - Decide on commit
Step 5b: MANDATORY continuation decision:
  - Continue to next task?
  - Stop and summarize?
  - Handle error/partial completion?
```

**Recommended Addition to continue.md**:

```markdown
---

## Step 5a: MANDATORY Post-Agent Checkpoint

**CRITICAL**: This step MUST run after EVERY agent invocation. Do not skip.

### Checkpoint Sequence

1. **Verify Agent Output**
   - Did the agent complete successfully?
   - Was the task fully addressed?
   - Are there any errors or warnings in output?

2. **Update Plan** (if `.devloop/plan.md` exists)
   - Mark task `[x]` if complete, `[~]` if partial
   - Add Progress Log entry with timestamp
   - Update `**Updated**:` timestamp

3. **Commit Decision**
   ```
   AskUserQuestion:
   - question: "Task [X.Y] complete. How should we proceed?"
   - header: "Checkpoint"
   - options:
     - Commit now (Create atomic commit for this work)
     - Continue working (Group with related tasks)
     - Fresh start (Save state, clear context, then continue)
     - Stop here (Save progress and end session)
   ```

4. **If "Commit now" selected**:
   - Launch `devloop:engineer` in git mode
   - After commit, update worklog
   - Return to step 6 (continuation decision)

5. **If "Fresh start" selected**:
   - Generate quick summary
   - Write state to `.devloop/next-action.json`
   - Instruct user to run `/clear`
   - END workflow (will resume on next session)

6. **If "Stop here" selected**:
   - Launch `devloop:summary-generator`
   - Present summary and next steps
   - END workflow

### Error Handling

If agent failed or task is incomplete:
```
AskUserQuestion:
- question: "Agent completed but task appears incomplete. What now?"
- header: "Recovery"
- options:
  - Retry task (Launch agent again with more context)
  - Mark partial (Continue to next task, note incompleteness)
  - Investigate (Show agent output for manual review)
  - Abandon (Remove task from plan)
```
```

---

### 3. No Explicit Context Clearing Mechanism

**Problem**: User wants "clear context and continue" but `/clear` cannot be invoked programmatically.

**Investigation Results**:
- Hooks cannot invoke slash commands
- No `clearContext` or `newSession` fields in hook response format
- The `/clear` command is handled at CLI/UI level, outside plugin system

**Workaround: State File + SessionStart Pattern**

#### A. Create `/devloop:fresh` Command

```markdown
---
description: Prepare for fresh context continuation (two-step process)
argument-hint: none
allowed-tools: ["Read", "Write", "Bash", "AskUserQuestion"]
---

# Fresh Start

Prepares for a context-cleared continuation.

## Process

1. Read current plan state from `.devloop/plan.md`
2. Identify next pending task
3. Generate quick summary of current state
4. Write state to `.devloop/next-action.json`:
   ```json
   {
     "action": "continue",
     "from_task": "[last completed task]",
     "next_task": "[next task ID]",
     "summary": "[brief context summary]",
     "timestamp": "[ISO timestamp]"
   }
   ```

5. Present instructions:
   ```markdown
   ## Ready for Fresh Start
   
   ✅ Progress saved to plan
   ✅ State saved for continuation
   
   **Next task**: [Task X.Y description]
   
   ### To continue with fresh context:
   1. Type `/clear` (or start a new chat)
   2. Send any message - I'll detect the pending action
   
   Or run `/devloop:continue` now to stay in current context.
   ```
```

#### B. Modify `session-start.sh` to Detect State File

Add to `hooks/session-start.sh`:

```bash
# === FRESH START DETECTION ===
# Check for pending devloop continuation action
FRESH_START_MSG=""
if [ -f ".devloop/next-action.json" ]; then
    if command -v jq &> /dev/null; then
        ACTION=$(jq -r '.action // empty' .devloop/next-action.json 2>/dev/null)
        NEXT_TASK=$(jq -r '.next_task // empty' .devloop/next-action.json 2>/dev/null)
        SUMMARY=$(jq -r '.summary // empty' .devloop/next-action.json 2>/dev/null)
        FROM_TASK=$(jq -r '.from_task // empty' .devloop/next-action.json 2>/dev/null)
    else
        ACTION=$(grep -o '"action"[[:space:]]*:[[:space:]]*"[^"]*"' .devloop/next-action.json | sed 's/.*"\([^"]*\)"$/\1/')
        NEXT_TASK=$(grep -o '"next_task"[[:space:]]*:[[:space:]]*"[^"]*"' .devloop/next-action.json | sed 's/.*"\([^"]*\)"$/\1/')
    fi
    
    if [ "$ACTION" = "continue" ]; then
        FRESH_START_MSG="

**⚡ Fresh Start Detected**
A previous session prepared for continuation.
- Last completed: $FROM_TASK
- Next task: $NEXT_TASK
- Run \`/devloop:continue\` to resume automatically
- Or type \`dismiss\` to clear this state and start fresh"
    fi
fi

# Add to CONTEXT_MSG before final output
if [ -n "$FRESH_START_MSG" ]; then
    CONTEXT_MSG="$CONTEXT_MSG$FRESH_START_MSG"
fi
```

#### C. Add State Cleanup to continue.md

When `/devloop:continue` runs after fresh start:

```markdown
### Fresh Start Cleanup

If `.devloop/next-action.json` exists at start:
1. Read the saved state
2. Use it to identify the next task
3. Delete the file after reading:
   ```bash
   rm .devloop/next-action.json
   ```
4. Proceed with normal continuation from the saved task
```

---

### 4. Spike → Plan Integration is Weak

**Location**: `commands/spike.md` - Phase 5

**Problem**: Spike generates "Plan Updates Required" section but there's no guided path to apply those updates.

**Current Flow**:
```
Spike completes → User reads recommendation → User manually triggers /devloop
```

**Recommended Addition - Phase 5b**:

```markdown
### Phase 5b: Apply Plan Updates (if proceeding)

If user selected "Proceed" and plan updates were recommended:

```
AskUserQuestion:
- question: "Spike recommends plan updates. Apply them now?"
- header: "Apply"
- options:
  - Apply and start (Update plan, then begin /devloop:continue)
  - Apply only (Update plan, stop here)
  - Start without applying (Begin work, keep plan as-is)
  - Review first (Show me the specific changes)
```

**If "Apply and start" or "Apply only":**

1. Read existing `.devloop/plan.md`:
   - If exists: Parse current structure
   - If not exists: Create new plan from spike findings

2. Apply recommended changes from spike report:
   - Add new tasks at specified positions
   - Modify existing task descriptions
   - Reorder tasks if recommended
   - Add parallelism markers if identified

3. Write updated plan to `.devloop/plan.md`

4. If "Apply and start":
   - Automatically invoke `/devloop:continue`
   - Begin with next pending task

**If "Review first":**

Show diff-style preview:
```markdown
## Proposed Plan Changes

### Additions
+ Task 2.3: [New task from spike]
+ Task 2.4: [Another new task]

### Modifications
~ Task 1.2: [Original] → [Modified description]

### Reordering
↑ Task 3.1 moved before Task 2.4 (dependency)

### Parallelism
‖ Tasks 2.3 and 2.4 marked as [parallel:A]
```

Then re-ask the apply question.
```

---

### 5. AskUserQuestion Patterns Are Inconsistent

**Problem**: Different commands/agents use different patterns for when and how to ask questions.

**Recommended Standard: AskUserQuestion Guidelines**

```markdown
## AskUserQuestion Standards

### When to ALWAYS Ask

1. **Before significant work** (>5 minutes expected):
   - Architecture decisions
   - Implementation approach choices
   - Destructive operations (delete, overwrite)

2. **After task completion** (mandatory checkpoint):
   - Commit decision
   - Continue/stop decision

3. **On error or ambiguity**:
   - Recovery options
   - Clarification needed

4. **At workflow boundaries**:
   - Phase transitions
   - Mode changes

### When to NEVER Ask

1. **Trivial decisions**:
   - Which file to read first
   - Order of non-dependent operations
   - Formatting choices

2. **Already decided**:
   - User explicitly stated preference earlier
   - Plan already specifies approach
   - Previous question in same session covered it

3. **During agent execution**:
   - Agents should complete their work autonomously
   - Ask at checkpoints, not mid-task

### Question Batching

**DO batch related questions:**
```
# GOOD: One call with multiple questions
AskUserQuestion:
  questions:
    - question: "Which approach for auth?"
      header: "Approach"
      options: [JWT, Session, OAuth]
    - question: "Include refresh tokens?"
      header: "Refresh"
      options: [Yes, No]
```

**DON'T ask separately:**
```
# BAD: Separate calls creating interruption
AskUserQuestion: "Which approach?"
... wait for response ...
AskUserQuestion: "Include refresh?"
... wait for response ...
```

### Standard Checkpoint Question

Use this pattern after ANY task completion:

```yaml
AskUserQuestion:
  question: "[Brief summary of completed work]. What's next?"
  header: "Next"
  options:
    - label: "Continue"
      description: "Proceed to next task in plan"
    - label: "Commit first"
      description: "Save this work, then continue"
    - label: "Fresh start"
      description: "Clear context, resume in new session"
    - label: "Stop here"
      description: "Generate summary, end session"
```

### Standard Error Question

Use this pattern when errors occur:

```yaml
AskUserQuestion:
  question: "[Error description]. How to proceed?"
  header: "Error"
  options:
    - label: "Retry"
      description: "Try again with adjusted approach"
    - label: "Skip"
      description: "Move to next task, note this as blocked"
    - label: "Investigate"
      description: "Show details for manual review"
    - label: "Abort"
      description: "Stop workflow entirely"
```
```

---

### 6. Worklog Updates Are Not Enforced

**Location**: `skills/task-checkpoint/SKILL.md`, `skills/worklog-management/SKILL.md`

**Problem**: Worklog updates depend on:
1. Git commits actually happening
2. Post-commit hook running successfully
3. Task checkpoint being invoked

If any fail, worklog gets out of sync with actual progress.

**Recommended Enhancement to task-checkpoint**:

```markdown
### Worklog Sync (Mandatory)

After EVERY task completion, regardless of commit status:

1. **Read worklog** (`.devloop/worklog.md`)
   - Create if doesn't exist

2. **Add task entry**:
   - If committed: `- [x] Task X.Y: [Description] (abc1234)`
   - If not yet committed: `- [x] Task X.Y: [Description] (pending commit)`

3. **Update timestamp**: Set "Last Updated" to current time

4. **Verify entry**: Re-read worklog to confirm write succeeded

### Worklog Reconciliation (At Session End)

When summary-generator runs:

1. Compare plan Progress Log entries to worklog entries
2. Identify any missing entries (completed but not logged)
3. Backfill gaps with best-effort timestamps
4. Note any untracked work in summary
```

---

### 7. Missing Loop Completion Detection

**Location**: `commands/continue.md`

**Problem**: Workflow doesn't automatically detect when all tasks are complete.

**Recommended Addition**:

```markdown
### Loop Completion Detection

After each task checkpoint, check for workflow completion:

1. **Count remaining tasks**:
   ```bash
   pending=$(grep -c "^[[:space:]]*- \[ \]" .devloop/plan.md 2>/dev/null || echo "0")
   in_progress=$(grep -c "^[[:space:]]*- \[~\]" .devloop/plan.md 2>/dev/null || echo "0")
   ```

2. **If no pending AND no in-progress tasks**:
   ```yaml
   AskUserQuestion:
     question: "🎉 All plan tasks complete! What would you like to do?"
     header: "Complete"
     options:
       - label: "Ship it"
         description: "Run /devloop:ship for final validation and commit"
       - label: "Add more tasks"
         description: "Extend the plan with additional work"
       - label: "Review"
         description: "Review all completed work before shipping"
       - label: "End session"
         description: "Generate summary and finish"
   ```

3. **Auto-update plan status**:
   - Change Status from "In Progress" to "Review"
   - Add Progress Log entry: "All tasks complete, ready for review"
```

---

### 8. Context Management Guidance Missing

**Problem**: No guidance on when context becomes "stale" or benefits from refresh.

**Recommended Addition to continue.md**:

```markdown
## Context Management

### When to Suggest Fresh Context

Context refresh is beneficial when:
- More than 5 tasks completed in current session
- Agent invocations exceeded 10 in session
- User explicitly mentions confusion or "starting over"
- Errors suggest model is confused by old context
- Session duration exceeds 2 hours of active work

### How to Detect Context Staleness

Track in workflow state:
```json
{
  "session_tasks_completed": 0,
  "session_agent_calls": 0,
  "session_start": "ISO timestamp"
}
```

After each checkpoint, increment counters. When thresholds exceeded:

```yaml
AskUserQuestion:
  question: "We've done significant work. Want to refresh context?"
  header: "Context"
  options:
    - label: "Yes, fresh start"
      description: "Save state, clear context, continue in new session"
    - label: "No, continue"
      description: "Keep current context"
    - label: "Compact only"
      description: "Summarize context without full clear (/compact)"
```

### Background Agent Pattern

For parallel tasks requiring isolation, use background execution:

```yaml
Task:
  subagent_type: devloop:engineer
  run_in_background: true  # Fresh context, parallel execution
  prompt: |
    [Task details...]
```

This gives the agent fresh context without affecting the main session.
```

---

## New Command: `/devloop:fresh`

Create new file `commands/fresh.md`:

```markdown
---
description: Prepare for fresh context continuation
argument-hint: Optional summary note
allowed-tools: ["Read", "Write", "Bash", "AskUserQuestion", "TodoWrite"]
---

# Fresh Start Preparation

Saves current workflow state for continuation after context clear.

## When to Use

- Context has become heavy/stale
- Want to continue work in a clean session
- Switching focus temporarily but want to resume later

## Process

### Step 1: Gather Current State

1. Read `.devloop/plan.md` for task status
2. Identify:
   - Last completed task
   - Next pending task
   - Current phase
   - Any blockers or notes

### Step 2: Generate Quick Summary

Create brief summary (max 200 words) of:
- What was accomplished
- Current state
- What's next

### Step 3: Save State

Write to `.devloop/next-action.json`:

```json
{
  "action": "continue",
  "from_task": "Task X.Y",
  "next_task": "Task X.Z",
  "phase": "Phase N: Name",
  "summary": "Brief summary...",
  "timestamp": "ISO timestamp",
  "user_note": "$ARGUMENTS"
}
```

### Step 4: Update Plan

Add Progress Log entry:
```
- [timestamp]: Session paused for context refresh. Next: Task X.Z
```

### Step 5: Present Instructions

```markdown
## ✅ Ready for Fresh Start

**Progress saved** to `.devloop/plan.md`
**State saved** to `.devloop/next-action.json`

### Next Task
**Task X.Z**: [Description]

### To Continue

1. Run `/clear` to reset context
2. Send any message (or run `/devloop:continue`)
3. I'll detect the saved state and resume

### Alternative

Run `/devloop:continue` now to stay in current context.
```

## State File Cleanup

The state file is automatically removed when:
- `/devloop:continue` reads and processes it
- User types "dismiss" after SessionStart detection
- User runs `/devloop:fresh --clear`
```

---

## New Skill: `workflow-loop`

Create new file `skills/workflow-loop/SKILL.md`:

```markdown
---
name: workflow-loop
description: Standard patterns for the devloop workflow loop including checkpoints, context management, and error recovery. Use when orchestrating multi-task workflows.
---

# Workflow Loop Patterns

## The Standard Loop

```
┌─────────────────────────────────────────────────────────┐
│                    WORKFLOW LOOP                         │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────┐     ┌──────────┐     ┌──────────────────┐ │
│  │  PLAN    │────▶│  WORK    │────▶│   CHECKPOINT     │ │
│  │(continue)│     │ (agent)  │     │  (mandatory)     │ │
│  └──────────┘     └──────────┘     └────────┬─────────┘ │
│       ▲                                      │           │
│       │           ┌──────────────────────────┼───────┐   │
│       │           │                          ▼       │   │
│       │           │  ┌─────────┐       ┌─────────┐   │   │
│       │           │  │ COMMIT  │◀──────│ DECIDE  │   │   │
│       │           │  │(if yes) │       │         │   │   │
│       │           │  └────┬────┘       └────┬────┘   │   │
│       │           │       │                 │        │   │
│       │           │       ▼                 ▼        │   │
│       │           │  ┌─────────┐       ┌─────────┐   │   │
│       └───────────┼──│CONTINUE │       │  STOP   │───┼───┘
│                   │  │ (next)  │       │(summary)│   │
│                   │  └─────────┘       └─────────┘   │
│                   │       │                          │
│                   │       ▼                          │
│                   │  ┌─────────┐                     │
│                   │  │  FRESH  │ (optional)          │
│                   │  │ (clear) │                     │
│                   │  └────┬────┘                     │
│                   │       │                          │
│                   │       ▼                          │
│                   │  [New Session]                   │
│                   │       │                          │
│                   └───────┼──────────────────────────┘
│                           │
│                           ▼
│                    [SessionStart detects state]
│                           │
│                           ▼
│                    [Back to PLAN]
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Checkpoint Requirements

Every checkpoint MUST:
1. ✓ Verify work output (success/failure/partial)
2. ✓ Update plan markers (`[ ]` → `[x]` or `[~]`)
3. ✓ Present decision (commit/continue/fresh/stop)
4. ✓ Update worklog if committing
5. ✓ Check for loop completion

## State Transitions

| From | To | Trigger |
|------|-----|---------|
| PLAN | WORK | Task identified |
| WORK | CHECKPOINT | Agent completes |
| CHECKPOINT | COMMIT | User selects "Commit" |
| CHECKPOINT | CONTINUE | User selects "Continue" |
| CHECKPOINT | FRESH | User selects "Fresh start" |
| CHECKPOINT | STOP | User selects "Stop" |
| COMMIT | CONTINUE | Commit succeeds |
| CONTINUE | PLAN | Loop back |
| FRESH | [End] | State saved, user clears |
| STOP | [End] | Summary generated |
| [New Session] | PLAN | State file detected |

## Error Recovery

| Error Type | Recovery Action |
|------------|-----------------|
| Agent failed | Retry / Skip / Investigate |
| Commit failed | Fix issues / Force / Abort |
| Plan missing | Create from context / Ask user |
| Task blocked | Note blocker / Skip / Unblock |

## Context Thresholds

| Metric | Threshold | Action |
|--------|-----------|--------|
| Tasks completed | > 5 | Suggest fresh start |
| Agent calls | > 10 | Suggest fresh start |
| Session duration | > 2 hours | Suggest fresh start |
| Errors in session | > 3 | Suggest fresh start |
```

---

## Recommended Changes Summary

| File | Change | Priority | Effort |
|------|--------|----------|--------|
| `commands/continue.md` | Add Step 5a mandatory checkpoint | High | Medium |
| `commands/continue.md` | Add "Fresh start" option to checkpoint | High | Low |
| `commands/continue.md` | Add loop completion detection | Medium | Low |
| `commands/continue.md` | Add context management section | Medium | Medium |
| `commands/fresh.md` | Create new command | High | Medium |
| `commands/spike.md` | Add Phase 5b for applying plan updates | High | Medium |
| `hooks/session-start.sh` | Add fresh start detection | High | Low |
| `hooks/hooks.json` | Remove or enhance SubagentStop hook | Low | Low |
| `skills/task-checkpoint/SKILL.md` | Add mandatory worklog sync | Medium | Low |
| `skills/workflow-loop/SKILL.md` | Create new skill | Medium | Medium |
| All commands | Standardize AskUserQuestion patterns | Medium | Medium |

---

## Quick Wins (Highest Impact, Lowest Effort)

1. **Add "Fresh start" option** to checkpoint AskUserQuestion
2. **Create `.devloop/next-action.json`** state file pattern
3. **Modify `session-start.sh`** to detect and display saved state
4. **Add loop completion detection** to continue.md
5. **Standardize checkpoint AskUserQuestion** across all commands

---

## Implementation Order

### Phase 1: Core Loop Fixes
1. [ ] Add mandatory checkpoint to continue.md (Step 5a)
2. [ ] Add "Fresh start" option to checkpoint question
3. [ ] Add loop completion detection

### Phase 2: Fresh Start Mechanism
4. [ ] Create `/devloop:fresh` command
5. [ ] Modify `session-start.sh` for state detection
6. [ ] Add state file cleanup to continue.md

### Phase 3: Integration Improvements
7. [ ] Add Phase 5b to spike.md for plan application
8. [ ] Create `workflow-loop` skill
9. [ ] Standardize AskUserQuestion patterns

### Phase 4: Cleanup
10. [ ] Remove or enhance SubagentStop hook
11. [ ] Add worklog sync to task-checkpoint
12. [ ] Add context management guidance

---

## Files to Create

- `commands/fresh.md` - New command for fresh start preparation
- `skills/workflow-loop/SKILL.md` - New skill for loop patterns

## Files to Modify

- `commands/continue.md` - Major updates (checkpoint, completion, context)
- `commands/spike.md` - Add Phase 5b
- `hooks/session-start.sh` - Add state detection
- `hooks/hooks.json` - Remove/modify SubagentStop
- `skills/task-checkpoint/SKILL.md` - Add worklog sync requirement

---

## Testing Checklist

After implementation, verify:

- [ ] Fresh start saves state correctly
- [ ] SessionStart detects saved state
- [ ] `/devloop:continue` reads and clears state file
- [ ] Checkpoint always runs after agent completion
- [ ] Loop completion is detected when all tasks done
- [ ] AskUserQuestion patterns are consistent
- [ ] Worklog stays in sync with plan
- [ ] Spike findings can be applied to plan automatically
