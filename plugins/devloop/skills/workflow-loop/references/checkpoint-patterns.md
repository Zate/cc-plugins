# Checkpoint Patterns

Detailed checkpoint sequence and verification procedures for the workflow loop.

## Checkpoint Sequence

### Step 1: Verify Agent Output

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

### Step 2: Update Plan

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

### Step 3: Commit Decision

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

### Step 4: Execute Selected Action

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

## Checkpoint Requirements

Every checkpoint MUST verify:

| Requirement | Check | How |
|-------------|-------|-----|
| **Work Output** | Success/Failure/Partial | Agent output + human verification |
| **Plan Markers** | Tasks marked `[x]` or `[~]` | Read plan, verify entries |
| **Decision Made** | User selected option | AskUserQuestion response |
| **Worklog Updated** | Entry added if committed | Read worklog, verify entry |
| **Loop Completion** | Check remaining tasks | Count `- [ ]` entries |

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
