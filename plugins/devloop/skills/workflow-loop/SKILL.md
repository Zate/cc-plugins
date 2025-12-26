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

For detailed checkpoint sequence, see [checkpoint-patterns.md](references/checkpoint-patterns.md).

**Quick Reference**:
1. Verify agent output (success/partial/failure)
2. Update plan markers and Progress Log
3. Present commit decision to user
4. Execute selected action (commit/continue/fresh/stop)

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

## Quick Reference Tables

### State Transitions

For complete state transition diagram and table, see [state-transitions.md](references/state-transitions.md).

| From | To | Trigger | Action |
|------|-----|---------|--------|
| PLAN | WORK | Task identified | Launch agent |
| WORK | CHECKPOINT | Agent completes | Verify output |
| CHECKPOINT | COMMIT | User selects "Commit" | Create commit |
| CHECKPOINT | CONTINUE | User selects "Continue" | Next task |
| CHECKPOINT | FRESH | User selects "Fresh" | Save state |
| CHECKPOINT | STOP | User selects "Stop" | Generate summary |

### Error Recovery

For detailed error recovery patterns, see [error-recovery.md](references/error-recovery.md).

| Scenario | Recovery Options |
|----------|-----------------|
| Agent fails | Retry / Skip / Investigate / Abort |
| Partial completion | Mark done / Continue work / Tech debt |
| Commit fails | Fix and retry / Skip commit / Investigate |
| Task blocked | Reorder / Skip / Investigate |

### Context Management

Context becomes stale when:

| Metric | Threshold | Action |
|--------|-----------|--------|
| Tasks completed | > 5 in session | Suggest fresh start |
| Agent invocations | > 10 in session | Suggest fresh start |
| Session duration | > 2 hours active | Suggest fresh start |
| Errors in session | > 3 distinct errors | Suggest fresh start |

## Examples

For good vs bad patterns, see [examples.md](references/examples.md).

**Good Pattern**: Full checkpoint with verification → User decision → Execute action → Continue
**Bad Pattern**: Skip checkpoint → Missing issues → Debug later

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

## Reference Files

- [checkpoint-patterns.md](references/checkpoint-patterns.md) - Detailed checkpoint sequence and verification
- [state-transitions.md](references/state-transitions.md) - State transition diagram and table
- [error-recovery.md](references/error-recovery.md) - Recovery patterns for failures
- [examples.md](references/examples.md) - Good vs bad implementation examples
