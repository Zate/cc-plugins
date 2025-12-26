# Error Recovery Patterns

Recovery patterns for common failure scenarios in the workflow loop.

## Pattern 1: Task Fails (Agent Error)

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

## Pattern 2: Partial Completion

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

## Pattern 3: Commit Fails

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

## Pattern 4: Task Blocked (Dependency)

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
