# Devloop Design Principles

This document captures the core design philosophies that guide devloop development. These principles inform every decision from architecture to user experience.

---

## Foundational Principles

### 1. Commands Orchestrate, Agents Assist

**The Principle**: Commands maintain control of workflows; agents are specialized helpers for subtasks.

**Why This Matters**:
- Users always see what's happening
- Opportunities to course-correct before wasted effort
- No "black box" feeling of lost control
- Clear separation between orchestration and execution

**In Practice**:
```
✓ Command shows phase progress
✓ Command asks checkpoints between phases
✓ Command spawns agents for specific subtasks
✓ Agent returns control to command when done

✗ Agent runs silently for minutes
✗ Agent makes major decisions without user input
✗ User wonders if the system is working
```

**Implementation Pattern**:
```yaml
# In a command (orchestrates)
## Phase 3: Implementation
1. Launch engineer agent for task
2. Wait for completion
3. Ask checkpoint question (MANDATORY)
4. Based on response: continue, commit, fresh, or stop

# Agent (assists)
Execute the specific task autonomously
Return results when complete
Do not ask questions mid-task
```

---

### 2. Work in Loops, Not Lines

**The Principle**: Complex features require multiple context-fresh sessions, not one long conversation.

**Why This Matters**:
- Long conversations degrade in quality
- Context windows fill up
- Responses slow down
- Reasoning becomes confused

**The Loop Pattern**:
```
┌──────────────────────────────────────────────────────┐
│                    THE DEVLOOP                        │
│                                                       │
│    Spike → Fresh → Continue → [Work] → Fresh → ...  │
│                                                       │
│    Each "Fresh" clears context while preserving      │
│    progress in the plan file.                        │
└──────────────────────────────────────────────────────┘
```

**Recommended Cadence**:
- Fresh start every **5-10 tasks**
- Or when context usage exceeds **50%**
- Or when responses feel slow
- Or when suggested at checkpoint

---

### 3. Token Consciousness

**The Principle**: Use the right model for each task. Not everything needs maximum intelligence.

**The 20/60/20 Strategy**:

| Category | Model | Usage % | Examples |
|----------|-------|---------|----------|
| High-stakes | opus | 20% | Architecture, complex decisions |
| Core work | sonnet | 60% | Implementation, exploration |
| Routine | haiku | 20% | Classification, checklists |

**Cost Awareness**:
```
Task: "Check if user model exists"
Wrong: opus (expensive, overkill)
Right: haiku (cheap, sufficient)

Task: "Design authentication architecture"
Wrong: haiku (insufficient reasoning)
Right: sonnet or opus (stakes justify cost)
```

**Automatic Selection**: Devloop selects models based on task type:
- `workflow-detector` → haiku
- `engineer` → sonnet
- Architecture decisions → sonnet (opus if critical)
- `summary-generator` → haiku

---

### 4. Plan-Driven Development

**The Principle**: All work flows through persistent plan files that survive session boundaries.

**Benefits**:
- Resume work after breaks
- Hand off to teammates
- Track progress visibly
- Git-tracked for history

**Plan as Source of Truth**:
```markdown
# .devloop/plan.md

## Tasks

### Phase 1: Foundation
- [x] Task 1.1: Create user model
- [~] Task 1.2: Add validation (partial)
- [ ] Task 1.3: Write unit tests
```

**Markers**:
- `[ ]` - Pending
- `[~]` - Partial/In Progress
- `[x]` - Complete

---

### 5. Mandatory Checkpoints

**The Principle**: Every task completion requires a checkpoint question. No exceptions.

**Why Mandatory**:
- Prevents silent runaway execution
- Gives user control over commit timing
- Allows context refresh when needed
- Ensures plan stays synchronized

**The Four Options**:

| Option | What Happens |
|--------|--------------|
| **Continue** | Move to next task in current context |
| **Commit** | Create atomic commit, then continue |
| **Fresh start** | Save state, suggest `/clear`, resume later |
| **Stop** | Generate summary, end session |

**Implementation**:
```yaml
AskUserQuestion:
  question: "Task 2.1 complete: [summary]. What's next?"
  header: "Checkpoint"
  options:
    - label: "Continue to next task"
      description: "Proceed with Task 2.2"
    - label: "Commit now"
      description: "Create atomic commit for this work"
    - label: "Fresh start"
      description: "Save state, clear context"
    - label: "Stop here"
      description: "Generate summary and end"
```

---

## User Experience Principles

### 6. Ask Early, Ask Once

**The Principle**: Batch related questions, avoid follow-ups in the same session.

**Good Pattern**:
```yaml
# One question covering all variants
AskUserQuestion:
  question: "Authentication approach for your API?"
  options:
    - label: "JWT with 24h tokens"
    - label: "JWT with 7d tokens"
    - label: "Session-based (Redis)"
```

**Bad Pattern**:
```yaml
# Sequential questions (avoid)
Q1: "Use JWT?"
Q2: "Token duration?"
Q3: "Include refresh tokens?"
```

**Decision Guide**:
- 2-3 related decisions → Batch in one question
- 4+ related decisions → Split into 2 focused questions
- Unrelated decisions → Ask first now, others when they arise

---

### 7. Minimize Cognitive Load

**The Principle**: Keep options clear, descriptions brief, recommendations obvious.

**Option Count**:
- 2-4 options: Ideal
- 5-6 options: Acceptable if comprehensive
- 7+ options: Reconsider structure

**Description Brevity**:
```yaml
# Too verbose (avoid)
description: "JSON Web Tokens are a method for representing claims 
              to be transferred between two parties..."

# Just right
description: "Stateless tokens, good for APIs and distributed systems"
```

**Always Recommend**:
```yaml
options:
  - label: "JWT tokens (Recommended)"
    description: "Best for your use case: scalable, stateless"
  - label: "Session-based"
    description: "Also viable: simpler revocation"
```

---

### 8. Respect Prior Decisions

**The Principle**: Don't re-ask what's already decided in the session.

**Bad**:
```
User: "I want to build this in TypeScript with React"
[5 tasks later]
Claude: "Should we use TypeScript?" ← WRONG
```

**Good**:
```
User: "I want to build this in TypeScript with React"
[5 tasks later]
Claude: "Continuing the TypeScript/React implementation..." ← RIGHT
```

**What to Track**:
- Language/framework choices
- Architecture decisions
- User preferences stated earlier
- Scope boundaries defined

---

## Technical Principles

### 9. Skills Load On-Demand

**The Principle**: Skills are catalogs of knowledge loaded when needed, not all at startup.

**v1.x Approach** (Deprecated):
```
SessionStart: Load all 26 skill files
Result: ~50% context consumed before any work
```

**v2.x Approach** (Current):
```
SessionStart: Reference skills/INDEX.md (lightweight catalog)
When needed: Load specific skill
Result: ~10% initial context, skills loaded as needed
```

**Skill Catalog** (INDEX.md):
```markdown
## Language Patterns
| Skill | Description |
|-------|-------------|
| `go-patterns` | Go-specific best practices... |
| `react-patterns` | React and TypeScript... |
```

---

### 10. State Survives Sessions

**The Principle**: Critical state persists in files, not just conversation memory.

**Session-Volatile** (Lost on `/clear`):
- Conversation history
- In-memory decisions
- Partial work

**Session-Persistent** (Survives `/clear`):
- `.devloop/plan.md` - Task progress
- `.devloop/worklog.md` - Completed work
- `.devloop/next-action.json` - Fresh start state
- `.devloop/issues/` - Issue tracking

**The Fresh Start Flow**:
```
1. User runs /devloop:fresh
2. State saved to next-action.json
3. User runs /clear
4. User runs /devloop:continue
5. Continue detects next-action.json
6. Work resumes from saved state
```

---

### 11. Git Integration is Natural

**The Principle**: Commits happen at logical points, not artificial boundaries.

**Atomic Commits**:
- One logical change per commit
- May span multiple files
- Self-contained and reviewable

**Commit Timing**:
- Offered at each checkpoint
- User decides when to group vs. separate
- Related tasks can be committed together

**Conventional Commits**:
```
feat(auth): implement JWT token generation

- Add token service with RS256 signing
- Create validation middleware
- Add refresh token support

Tasks: 2.1, 2.2, 2.3
```

---

### 12. Errors Are Recoverable

**The Principle**: Failures offer clear recovery paths, not dead ends.

**Recovery Pattern**:
```yaml
AskUserQuestion:
  question: "Task failed: [error summary]. How proceed?"
  header: "Error Recovery"
  options:
    - label: "Retry"
      description: "Attempt with adjusted approach"
    - label: "Skip"
      description: "Mark blocked, move to next task"
    - label: "Investigate"
      description: "Show full error for manual review"
    - label: "Abort"
      description: "Stop workflow, save state"
```

**Error Categories**:

| Type | Recovery |
|------|----------|
| Transient | Retry |
| Missing dependency | Skip + track issue |
| Fundamental | Investigate + manual fix |
| Unrecoverable | Abort with state save |

---

## Anti-Patterns

Things to explicitly avoid:

### Don't: Silent Execution

```
✗ Agent runs for 5 minutes with no feedback
✗ User wonders if system is frozen
✗ No opportunity to course-correct
```

### Don't: Over-Ask

```
✗ Ask about trivial choices (file naming)
✗ Re-ask decided questions
✗ Ask during agent execution
```

### Don't: Skip Checkpoints

```
✗ Complete task, immediately start next
✗ Forget to update plan markers
✗ Miss commit opportunities
```

### Don't: Ignore Context Health

```
✗ Work through 20+ tasks in one session
✗ Ignore slow response warnings
✗ Never suggest fresh starts
```

---

## Principle Application Checklist

When adding new features, verify:

- [ ] Commands orchestrate, agents assist?
- [ ] Encourages looping workflow?
- [ ] Uses appropriate model tier?
- [ ] Works with plan files?
- [ ] Has mandatory checkpoints?
- [ ] Asks early, asks once?
- [ ] Minimizes cognitive load?
- [ ] Respects prior decisions?
- [ ] Loads skills on-demand?
- [ ] State survives sessions?
- [ ] Git integration natural?
- [ ] Errors recoverable?

---

## Next Steps

- [The Development Loop](03-development-loop.md) - See principles in action
- [Architecture](01-architecture.md) - How principles shape structure
- [Contributing](07-contributing.md) - Apply principles in your contributions
