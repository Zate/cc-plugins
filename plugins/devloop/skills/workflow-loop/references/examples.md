# Workflow Loop Examples

Good and bad patterns for implementing the workflow loop.

## Good Pattern: Full Loop

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

## Good Pattern: Error Recovery

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

## Bad Pattern: Skipped Checkpoint

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

## Bad Pattern: Ignoring Fresh Context

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
