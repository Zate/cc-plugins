# The Development Loop

This document describes the iterative development cycle that devloop encourages: **spike → fresh → continue**. This pattern is the heart of effective AI-assisted development.

---

## Why a Loop?

Traditional AI assistant usage often follows a linear pattern:

```
Ask → Work → Work → Work → Work → ... → Context exhausted → Start over
```

**Problems with Linear Usage**:
- Context window fills up
- Responses become slow
- Reasoning quality degrades
- No clear handoff points
- Work may be lost if session ends

**The Devloop Pattern**:

```
┌─────────────────────────────────────────────────────────────────────┐
│                        THE DEVELOPMENT LOOP                          │
│                                                                       │
│   ┌────────┐    ┌─────────┐    ┌──────────┐    ┌──────────────────┐ │
│   │ SPIKE  │───▶│  FRESH  │───▶│ CONTINUE │───▶│  WORK (5-10     │ │
│   │        │    │         │    │          │    │  tasks)          │ │
│   └────────┘    └─────────┘    └──────────┘    └────────┬─────────┘ │
│       │                                                  │           │
│       │                                                  ▼           │
│       │                                            ┌──────────┐      │
│       │                                            │ Context  │      │
│       │                                            │ Heavy?   │      │
│       │                                            └────┬─────┘      │
│       │                                                 │            │
│       │                           ┌─────────────────────┴───────┐    │
│       │                           │                             │    │
│       │                     Yes ──┘                       No ───┘    │
│       │                       │                             │        │
│       │                       ▼                             ▼        │
│       │                 ┌──────────┐               Continue working  │
│       │                 │  FRESH   │                     │           │
│       │                 │          │                     │           │
│       │                 └────┬─────┘                     │           │
│       │                      │                           │           │
│       │                      ▼                           │           │
│       │                 ┌──────────┐                     │           │
│       │                 │ CONTINUE │◀────────────────────┘           │
│       │                 └────┬─────┘                                 │
│       │                      │                                       │
│       │                      ▼                                       │
│       │              (Repeat until complete)                         │
│       │                      │                                       │
│       │                      ▼                                       │
│       │                 ┌──────────┐                                 │
│       └────────────────▶│   SHIP   │                                 │
│                         └──────────┘                                 │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## The Three Core Commands

### 1. Spike (`/devloop:spike`)

**Purpose**: Explore the problem space and create a solid plan.

**When to Use**:
- Starting any non-trivial feature
- Unknown feasibility
- Complex requirements
- Need to understand existing code first

**What Happens**:
1. **Exploration**: Investigate codebase, patterns, constraints
2. **Analysis**: Assess complexity, identify risks
3. **Planning**: Create detailed task breakdown
4. **Output**: Plan saved to `.devloop/plan.md`

**Example**:
```bash
/devloop:spike How should we add user authentication?
```

**Spike creates**:
```markdown
# Devloop Plan: User Authentication

**Status**: In Progress
**Complexity**: Medium (M)
**Estimated Tasks**: 12

## Architecture Decision
Recommendation: JWT with RS256 signing
- Stateless for API scalability
- Refresh tokens for extended sessions
- Redis for token revocation list

## Tasks

### Phase 1: Foundation
- [ ] Task 1.1: Create user model with password hashing
- [ ] Task 1.2: Set up JWT token service
- [ ] Task 1.3: Implement token validation middleware

### Phase 2: Core Features
- [ ] Task 2.1: Add login endpoint
- [ ] Task 2.2: Add registration endpoint
- [ ] Task 2.3: Implement refresh token flow
...
```

---

### 2. Fresh (`/devloop:fresh`)

**Purpose**: Save current state and prepare for context refresh.

**When to Use**:
- After 5-10 tasks completed
- Context feels heavy/slow
- Suggested at checkpoint
- Before a break

**What Happens**:
1. **Save State**: Current task, progress, next action to `.devloop/next-action.json`
2. **Update Plan**: Ensure markers reflect actual progress
3. **Instruction**: Tell user to run `/clear`

**Example**:
```bash
/devloop:fresh
```

**Output**:
```
✓ State saved to .devloop/next-action.json

Session Summary:
- Completed: Tasks 1.1, 1.2, 1.3, 2.1
- Next up: Task 2.2 (Add registration endpoint)
- Session duration: 45 minutes
- Context usage: 67%

To resume with fresh context:
1. Run /clear to reset conversation
2. Run /devloop:continue to resume
```

---

### 3. Continue (`/devloop:continue`)

**Purpose**: Resume work from saved state or existing plan.

**When to Use**:
- After `/clear` following a fresh start
- Returning to unfinished work
- New session with existing plan

**What Happens**:
1. **Detect State**: Check for `next-action.json` (fresh start) or `plan.md`
2. **Load Context**: Understand where we left off
3. **Find Next Task**: Identify pending work
4. **Execute Loop**: Work through tasks with checkpoints

**Example**:
```bash
# After /clear
/devloop:continue
```

**Output**:
```
Resuming from saved state...

Plan: User Authentication
Progress: 4/12 tasks complete (33%)
Last completed: Task 2.1 (Add login endpoint)
Next task: Task 2.2 (Add registration endpoint)

Starting Task 2.2...
```

---

## The Checkpoint Pattern

Every task completion triggers a **mandatory checkpoint**:

```yaml
AskUserQuestion:
  question: "Task 2.2 complete: Registration endpoint with email validation. What's next?"
  header: "Checkpoint"
  options:
    - label: "Continue to next task"
      description: "Proceed to Task 2.3 (refresh tokens)"
    - label: "Commit now"
      description: "Create atomic commit for login+registration"
    - label: "Fresh start"
      description: "Save state, clear context (recommended at 67% usage)"
    - label: "Stop here"
      description: "Generate summary and end session"
```

### Checkpoint Decision Guide

| Scenario | Recommended Option |
|----------|-------------------|
| Just started, plenty of context | Continue |
| 3-4 related tasks done, logical unit | Commit |
| 5-10 tasks done, context heavy | Fresh start |
| Need to stop for the day | Stop |
| Hit a blocker | Stop + investigate |

---

## Session Cadence

### Recommended Flow

```
Session 1: Spike
├── /devloop:spike [feature]
├── Review generated plan
├── Adjust if needed
├── /devloop:fresh
└── /clear

Session 2: First Work Block
├── /devloop:continue
├── Complete Tasks 1.1 → 1.4
├── Commit at logical points
├── /devloop:fresh (at ~50% context)
└── /clear

Session 3: Second Work Block
├── /devloop:continue
├── Complete Tasks 2.1 → 2.4
├── Commit
├── /devloop:fresh
└── /clear

... (repeat until complete)

Final Session: Ship
├── /devloop:continue
├── Complete remaining tasks
├── /devloop:ship
└── PR created ✓
```

### Context Health Metrics

| Metric | Threshold | Action |
|--------|-----------|--------|
| Tasks completed | > 5 | Consider fresh start |
| Context usage | > 50% | Suggest fresh start |
| Context usage | > 75% | Strongly recommend fresh |
| Session duration | > 2 hours | Check for staleness |
| Agent invocations | > 10 | Context likely heavy |

---

## Why This Pattern Works

### 1. Context Stays Fresh

Each `/clear` resets the conversation, giving Claude:
- Full context window for reasoning
- Fast response times
- Sharp, focused thinking

### 2. Progress Is Preserved

The plan file survives session boundaries:
- Work is never lost
- Handoff is automatic
- Team can see progress

### 3. Commits Are Logical

Checkpoints encourage commits at natural points:
- Atomic, reviewable changes
- Clear history
- Easy to revert if needed

### 4. Users Stay in Control

Mandatory checkpoints mean:
- Always know what's happening
- Can adjust direction
- Decide commit timing

---

## Common Patterns

### Pattern 1: Exploration → Implementation

When you're not sure how to approach something:

```bash
# Day 1: Understand the problem
/devloop:spike How should we refactor the payment system?
# Review spike findings, adjust plan
/devloop:fresh
/clear

# Day 2: Start implementation
/devloop:continue
# Work through tasks
```

### Pattern 2: Quick Fix

For small, well-defined tasks:

```bash
/devloop:quick Fix the null pointer in UserService line 42
```

No spike needed—goes straight to implementation.

### Pattern 3: Long Feature

For multi-day features:

```bash
# Monday
/devloop:spike Add GraphQL API layer
/devloop:fresh && /clear

/devloop:continue
# Complete Phase 1 (schema design)
/devloop:fresh && /clear

# Tuesday
/devloop:continue
# Complete Phase 2 (resolvers)
/devloop:fresh && /clear

# ... continue daily until complete

# Friday
/devloop:ship
```

### Pattern 4: Team Handoff

When passing work to a teammate:

```bash
# Your session
/devloop:continue
# Complete several tasks
/devloop:fresh
# Share: "Plan is in .devloop/plan.md, left off at Task 3.2"

# Teammate's session
/devloop:continue
# Automatically picks up from Task 3.2
```

---

## Troubleshooting

### "Continue doesn't find my plan"

Check:
1. Is `.devloop/plan.md` present?
2. Are there pending tasks marked `[ ]`?
3. Is `next-action.json` present (if post-fresh)?

### "Context feels slow"

Run:
```bash
/devloop:fresh
/clear
/devloop:continue
```

### "Lost track of where I am"

Run:
```bash
cat .devloop/plan.md | grep -E "^\- \[(x|~| )\]"
```

Shows all tasks with their status.

### "Commits not being created"

Check:
- Did you select "Commit now" at checkpoint?
- Are there uncommitted changes? (`git status`)
- Is the git repository initialized?

---

## Best Practices Summary

1. **Start with Spike** for any non-trivial feature
2. **Fresh every 5-10 tasks** or when context > 50%
3. **Commit at logical points** (not every task)
4. **Trust the checkpoints** - they're there for a reason
5. **Review the plan** before continuing in new sessions
6. **Use `/devloop:quick`** for small, clear tasks

---

## Next Steps

- [Principles](02-principles.md) - Philosophy behind the loop
- [Architecture](01-architecture.md) - Technical implementation
- [Component Guide](05-component-guide.md) - Commands in detail
