---
description: This skill should be used when the user asks to 'implement checkpoints', 'workflow loop', 'task completion pattern', 'mandate checkpoints', or needs patterns for multi-task workflows with mandatory checkpoints, state management, and error recovery.
whenToUse: |
  - Implementing commands that control multi-phase workflows
  - Designing checkpoint logic between tasks
  - Planning context management strategy
  - Handling task failures and recovery
  - Managing state transitions in work loops
whenNotToUse: |
  - Simple single-task operations
  - Non-interactive background jobs
  - Exploratory work without checkpoints
---

# Workflow Loop Pattern

## When NOT to Use This Skill

- **Simple single-task operations**: One-off tasks don't need checkpoints
- **Non-interactive background jobs**: Jobs that run without user decisions
- **Exploratory work without checkpoints**: Spikes and investigation don't require the full loop
- **Read-only operations**: Analysis and exploration without state changes

## The Standard Loop

The workflow loop is the foundational pattern for all multi-task work in devloop. It enforces checkpoints after every task completion and provides clear decision points for continuation, commitment, or context refresh.

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

## Phases of the Loop

### 1. Plan (PLAN)

**What happens**: Identify the next task to execute from the plan.

**Inputs**:
- `.devloop/plan.md` with task list
- Progress tracking (which tasks are complete)
- Current phase context

**Outputs**:
- Identified task (Task X.Y)
- Task description and acceptance criteria
- Files that will be modified

**Actions**:
```bash
# Find next pending task
grep "^- \[ \]" .devloop/plan.md | head -1

# Extract task ID and description
# Present to user if multiple options exist
```

### 2. Work (WORK)

**What happens**: Execute the task using agents or direct operations.

**Inputs**:
- Task ID and description
- Acceptance criteria
- Related files and context

**Outputs**:
- Completed task or partial completion
- Modified files
- Agent logs/output

**Agent Selection**:
- Complex code features → `devloop:engineer`
- Code review → `code-reviewer`
- Refactoring → `refactor-analyzer`
- Exploration → `code-explorer`
- Tests → `test-generator`

**Key Principle**: Agents execute autonomously during this phase. Do NOT interrupt with questions mid-task.

### 3. Checkpoint (CHECKPOINT)

**What happens**: Verify work completion and decide next action.

**CRITICAL**: This phase MUST ALWAYS run after every work phase. Never skip.

#### Checkpoint Sequence

##### Step 1: Verify Agent Output

```
Success Indicators:
✓ Agent explicitly states task is complete
✓ Acceptance criteria are met
✓ No errors reported in agent output
✓ Required files were created/modified

Partial Indicators:
~ Agent completed but with limitations
~ Some acceptance criteria met, others pending
~ Errors occurred but recovered

Failure Indicators:
✗ Agent encountered blocking error
✗ Task not addressed at all
✗ Critical requirements missing
```

##### Step 2: Update Plan

If `.devloop/plan.md` exists:

```bash
# Update task marker
# - [ ] → - [x] if complete
# - [ ] → - [~] if partial
# - [ ] → - [!] if blocked

# Add Progress Log entry
- [YYYY-MM-DD HH:MM]: Completed Task X.Y - [Description]

# Update file timestamp
**Updated**: [Current ISO timestamp]
```

##### Step 3: Commit Decision

Present mandatory decision:

```yaml
AskUserQuestion:
  question: "Task [X.Y] complete. How should we proceed?"
  header: "Checkpoint"
  options:
    - label: "Commit now"
      description: "Create atomic commit for this work"
    - label: "Continue working"
      description: "Group with related tasks before committing"
    - label: "Fresh start"
      description: "Save state, clear context, resume in new session"
    - label: "Stop here"
      description: "Generate summary and end session"
```

##### Step 4: Execute Selected Action

**If "Commit now"**:
```
1. Prepare commit message:
   - Type: feat/fix/refactor/docs/test/chore
   - Scope: [component or file]
   - Message: Task X.Y - [description]

2. Run git commit (or invoke devloop:engineer in git mode)
3. Verify commit succeeded
4. Update worklog with commit hash
5. Return to Step 5b (continuation decision)
```

**If "Continue working"**:
```
1. No commit yet - changes remain staged
2. Return to Step 5b immediately
3. Proceed to next task in same phase
```

**If "Fresh start"**:
```
1. Generate brief session summary
2. Write state to .devloop/next-action.json
3. Instruct user to run /clear
4. END workflow
5. SessionStart hook will detect state on new session
```

**If "Stop here"**:
```
1. Invoke devloop:summary-generator
2. Present summary of work completed
3. Show suggested next steps
4. END workflow
```

### 4. Decide (DECIDE)

**What happens**: Choose whether to continue or stop.

**Inputs**:
- Checkpoint verification result
- Commit status
- Remaining tasks

**Decision Tree**:

```
Checkpoint done?
├─ Yes: Continue to next task?
│  ├─ Yes: All tasks complete?
│  │  ├─ Yes: → COMPLETE (all done, ask about shipping)
│  │  └─ No:  → Plan (next task)
│  └─ No:  → STOP (summary and end)
└─ No: Error recovery
   ├─ Retry? → WORK (same task again)
   ├─ Skip?  → Plan (next task, mark blocked)
   └─ Investigate? → Manual review
```

### 5. Continue or Stop (CONTINUATION)

**What happens**: Return to plan for next task or end session.

**LOOP path** (continue to next task):
- Mark current task `[x]` in plan
- Increment task counter
- Return to PLAN phase

**FRESH path** (context refresh):
- Save state
- Prepare for next session
- END with instructions

**STOP path** (end session):
- Generate summary
- List next recommended actions
- END

## Checkpoint Requirements

Every checkpoint MUST verify:

| Requirement | Check | How |
|-------------|-------|-----|
| **Work Output** | Success/Failure/Partial | Agent output + human verification |
| **Plan Markers** | Tasks marked `[x]` or `[~]` | Read plan, verify entries |
| **Decision Made** | User selected option | AskUserQuestion response |
| **Worklog Updated** | Entry added if committed | Read worklog, verify entry |
| **Loop Completion** | Check remaining tasks | Count `- [ ]` entries |

## State Transitions

```
PLAN ─────────────▶ WORK ────────────▶ CHECKPOINT
 ▲                                         │
 │                                         ▼
 │                                      DECIDE
 │                                         │
 │        ┌────────────────────────────────┼────────────────┐
 │        │                                │                │
 │        ▼                                ▼                ▼
 │     CONTINUE                        COMMIT            STOP
 │        │                              │                 │
 │        │                              ▼                 │
 │        │                          [Commit]              │
 │        │                              │                 │
 │        └──────────────┬────────────────┘                │
 │                       │                                  │
 │        ┌──────────────┴──────────────┐                  │
 │        │                             │                  │
 │        ▼                             ▼                  │
 │     [Next Task]               [All Complete?]          │
 │        │                             │                  │
 │        │                             ├─ Yes ─▶ SHIP    │
 │        │                             │                  │
 │        └─────────────────┬───────────┘                  │
 │                          │                              │
 │                          ▼                              │
 │                     [Back to PLAN]                      │
 │                          │                              │
 └──────────────────────────┘                              │
                                                            │
                            ┌───────────────────────────────┘
                            │
                            ▼
                         [END]
                       SUMMARY LOG
```

| From | To | Trigger | Action |
|------|-----|---------|--------|
| PLAN | WORK | Task identified | Launch agent |
| WORK | CHECKPOINT | Agent completes | Verify output |
| CHECKPOINT | COMMIT | User selects "Commit" | Create commit |
| CHECKPOINT | CONTINUE | User selects "Continue" | Next task |
| CHECKPOINT | FRESH | User selects "Fresh" | Save state |
| CHECKPOINT | STOP | User selects "Stop" | Generate summary |
| COMMIT | CONTINUE | Commit succeeds | Next task |
| CONTINUE | PLAN | Loop back | Increment counter |
| FRESH | [End] | State saved | User runs /clear |
| STOP | [End] | Summary generated | Session ends |
| [New Session] | PLAN | State file detected | Resume |

## Error Recovery Patterns

### Pattern 1: Task Fails (Agent Error)

```
Agent fails → Checkpoint detects failure

AskUserQuestion:
  question: "Agent failed on Task X.Y. How to proceed?"
  header: "Recovery"
  options:
    - Retry (launch agent again with more context)
    - Skip (move to next task, mark blocked)
    - Investigate (show agent output for review)
    - Abort (end workflow entirely)
```

**If Retry**:
- Update plan marker to `[~]`
- Relaunch same agent with additional context
- Add note to Progress Log: "Retrying Task X.Y"

**If Skip**:
- Mark task `[!]` (blocked)
- Add note to Progress Log: "Task X.Y blocked - [reason]"
- Continue to next task

**If Investigate**:
- Show complete agent output
- Ask user to suggest fix or approach
- Then Retry, Skip, or Abort

### Pattern 2: Partial Completion

```
Agent completes but task not fully done

Checkpoint detects: Not all acceptance criteria met

AskUserQuestion:
  question: "Task X.Y partially complete. Acceptance: [criteria not met]. What now?"
  header: "Partial"
  options:
    - Mark done anyway (continue to next task)
    - Continue work (stay in WORK phase, maybe different agent)
    - Note as tech debt (mark blocked, document issue)
```

### Pattern 3: Commit Fails

```
After task, user selects "Commit now" → Commit fails

AskUserQuestion:
  question: "Commit failed. Reason: [error]. What now?"
  header: "Commit Error"
  options:
    - Fix and retry (show what needs fixing)
    - Skip commit (continue without committing)
    - Investigate (show git status, diff)
```

### Pattern 4: Task Blocked (Dependency)

```
Task X.Y depends on Task X.1, which is still pending

AskUserQuestion:
  question: "Task X.Y blocked on Task X.1. What now?"
  header: "Blocked"
  options:
    - Reorder (move blocking task up)
    - Skip (come back to this later)
    - Investigate (show why it's blocked)
```

## Context Management Thresholds

Context becomes stale when:

| Metric | Threshold | Action |
|--------|-----------|--------|
| Tasks completed | > 5 in session | Suggest fresh start |
| Agent invocations | > 10 in session | Suggest fresh start |
| Session duration | > 2 hours active | Suggest fresh start |
| Errors in session | > 3 distinct errors | Suggest fresh start |
| Last checkpoint | > 1 hour ago | Suggest fresh start |
| Plan file not updated | > 3 tasks | Suggest fresh start |

### When Context is Healthy

```yaml
AskUserQuestion:
  question: "Continue with current context?"
  header: "Context"
  options:
    - Continue (stay in current session)
    - Compact (use /compact to summarize)
    - Fresh start (clear context, new session)
```

### When Context is Stale

```yaml
AskUserQuestion:
  question: "We've completed significant work. Context may be getting heavy. Refresh?"
  header: "Context"
  options:
    - Yes, fresh start (save state, clear context)
    - No, continue (keep current session)
    - Compact only (summarize without clearing)
```

### Background Agent Pattern

For parallel tasks that benefit from isolation:

```yaml
Task:
  agent: devloop:engineer
  mode: background
  context: fresh  # Separate from main session
  prompt: |
    [Task details...]
```

Benefits:
- Fresh context = higher quality work
- Parallel execution = faster overall progress
- Isolation = no interference with main session

Costs:
- Higher token usage
- Can't ask questions mid-task
- Requires explicit status polling

## Loop Completion Detection

After every checkpoint, check if workflow is complete:

```bash
# Count remaining work
pending=$(grep -c "^- \[ \]" .devloop/plan.md 2>/dev/null || echo "0")
in_progress=$(grep -c "^- \[~\]" .devloop/plan.md 2>/dev/null || echo "0")

if [ "$pending" -eq 0 ] && [ "$in_progress" -eq 0 ]; then
  # All tasks complete!
  # → COMPLETE state
fi
```

When all tasks are complete:

```yaml
AskUserQuestion:
  question: "🎉 All plan tasks complete! What would you like to do?"
  header: "Complete"
  options:
    - label: "Ship it"
      description: "Run /devloop:ship for final validation"
    - label: "Add more tasks"
      description: "Extend the plan with additional work"
    - label: "Review"
      description: "Review all completed work"
    - label: "End session"
      description: "Generate summary and finish"
```

**Auto-updates**:
1. Change plan Status from "In Progress" to "Review"
2. Add Progress Log: "All tasks complete"
3. Update **Updated** timestamp

## Mandatory Checkpoint Enforcement

The checkpoint MUST run:

### When it runs:
- ✓ After every agent completes work
- ✓ After every manual operation
- ✓ At phase boundaries
- ✓ Before changing direction

### When it CANNOT skip:
- Agent output shows success: Still verify acceptance criteria
- User says "quick task": Still checkpoint for 30 seconds
- Multiple agents running in parallel: Each gets own checkpoint
- Error during work: Still checkpoint for recovery decision

### How to enforce programmatically:

```bash
# Anti-pattern: Skip checkpoint
if task_trivial; then
  mark_complete
  continue_to_next
fi

# Correct pattern: Always checkpoint
agent_result=$(launch_agent $task)
checkpoint "$agent_result"  # Always runs
case "$user_decision" in
  commit) ;;
  continue) ;;
  fresh) ;;
  stop) ;;
esac
```

## Examples: Good vs Bad Patterns

### Good Pattern: Full Loop

```markdown
## Task 1.1: Create user model

Agent launches → Completes in 5 minutes

**Checkpoint**: ✓ Output verified
- File `models/User.go` created ✓
- Acceptance criteria met ✓
- No errors ✓

**Decision**: User selects "Commit now"

**Commit**: feat(models): add User type
- Created User type with full struct fields
- Added validation methods

**Result**: Committed as abc1234

**Continuation**: User selects "Continue working"

→ **Next**: Task 1.2
```

### Good Pattern: Error Recovery

```markdown
## Task 2.3: Implement OAuth2 flow

Agent launches → Encounters error in step 3

**Checkpoint**: ✗ Work incomplete
- OAuth2 provider setup failed
- Token refresh not implemented
- Error: "Invalid client ID in config"

**Recovery**: User selects "Investigate"

Shows:
- Agent error log
- What was completed
- Why it failed

**User decides**: "Retry with AWS credentials"

→ Agent relaunches with new context
```

### Bad Pattern: Skipped Checkpoint

```markdown
## Task 3.2: Add caching layer

Agent completes quickly (2 minutes)

❌ WRONG: Command skips checkpoint
// "Trivial task, no need to verify"
// Directly marks complete and continues

Result:
- Agent actually only partially implemented feature
- Test failures appear later in review
- Wasted time tracking down issue

✓ CORRECT: Always checkpoint
Checkpoint verifies:
- Cache properly integrated
- All cache hits working
- Fallback on miss works
- Tests passing

→ Only then proceed
```

### Bad Pattern: Ignoring Fresh Context

```markdown
Session has now:
- 8 tasks completed
- 15 agent calls
- 90 minutes elapsed
- 2 errors encountered

❌ WRONG: Continue without refreshing
Command keeps going without offering context refresh
→ Quality degrades as model gets confused

✓ CORRECT: Offer fresh start
After task 8 checkpoint:
"We've done significant work. Context may be heavy.
- Continue (same session)
- Fresh start (clear, resume next task)
- Compact (summarize, stay)"

→ User decides fresh start
→ Quality improves for remaining tasks
```

## Worklog Integration

The checkpoint updates the worklog:

```markdown
## .devloop/worklog.md

### Completed Tasks

- [x] Task 1.1: Create user model (abc1234) - 2024-12-23 14:30
- [x] Task 1.2: Add validation (def5678) - 2024-12-23 15:00
- [x] Task 2.1: Create database schema (ghi9012) - 2024-12-23 16:15
```

Worklog entry created at checkpoint only if:
- Commit succeeds → Includes commit hash
- No commit → Mark as "pending commit"

## Common Pitfalls

### Pitfall 1: Checkpoint Fatigue

**Problem**: Asking too many questions at checkpoints

**Solution**: Batch related decisions:
```yaml
# WRONG: Three separate questions
AskUserQuestion: "Commit now?"
AskUserQuestion: "Continue to next task?"
AskUserQuestion: "Refresh context?"

# RIGHT: One question with all options
AskUserQuestion:
  question: "Task complete. What's next?"
  options:
    - Commit then continue
    - Continue without commit
    - Fresh start
    - Stop here
```

### Pitfall 2: Skipping Failed Agent Output

**Problem**: Agent fails, command just moves to next task

**Solution**: Always give user recovery options
```yaml
# WRONG: Just skip
if agent_failed:
  mark_blocked
  next_task()

# RIGHT: Offer recovery
if agent_failed:
  AskUserQuestion:
    options: [Retry, Skip, Investigate, Abort]
```

### Pitfall 3: Not Updating Plan

**Problem**: Checkpoint happens but plan doesn't reflect reality

**Solution**: Update plan immediately after verification
```bash
# Update before AskUserQuestion
if task_complete:
  sed -i "s/^- \[ \] $task_id/- [x] $task_id/" plan.md
  add_progress_log_entry "$task_id"
  update_timestamp
# Then ask user
AskUserQuestion: ...
```

### Pitfall 4: Ignoring Context Thresholds

**Problem**: Session degrades after 10+ agent calls

**Solution**: Proactively offer fresh start at thresholds
```bash
# After checkpoint, check metrics
tasks_done=$((tasks_done + 1))
agent_calls=$((agent_calls + 1))

if [ $tasks_done -gt 5 ] || [ $agent_calls -gt 10 ]; then
  AskUserQuestion: "Context refresh time?"
fi
```

## Integration Points

### Integrates with:

- **continue.md** - Implements full loop
- **spike.md** - Checkpoint before applying findings
- **fresh.md** - Saves state at FRESH transition
- **summary.md** - Generates output at STOP transition
- **ship.md** - Runs final checkpoint before shipping

### Used by:

- Orchestrator commands that manage multi-task workflows
- Agent completion handlers
- State management systems
- Error recovery handlers

## Summary

The workflow loop pattern ensures:

✓ **Reliability**: Every task is verified before moving on
✓ **Visibility**: User always knows what's happening
✓ **Recoverability**: Errors are handled gracefully
✓ **Flexibility**: Multiple paths (commit, continue, fresh, stop)
✓ **Sustainability**: Context refresh prevents degradation
✓ **Traceability**: Plan and worklog stay in sync

Use this pattern in any workflow that:
- Has multiple tasks to complete
- Requires decision points between tasks
- Benefits from checkpoints and verification
- Needs error recovery capability
- May run for extended sessions
