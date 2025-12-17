---
description: Quick implementation for small, well-defined tasks (skip exploration/architecture)
argument-hint: Task description
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill"]
---

# Quick Implementation

Streamlined workflow for small, well-defined tasks that don't need full exploration or architecture design.

## Plan Integration

**CRITICAL**: Quick tasks should integrate with any existing plan.

### Before Starting a Quick Task

1. **Check for existing plan**: Read `.claude/devloop-plan.md` if it exists
2. **Check if task matches a planned task**:
   - Search plan for keywords from $ARGUMENTS
   - If match found, warn user:
   ```
   Use AskUserQuestion:
   - question: "This appears to match Task X.Y in the existing plan. Use the plan workflow instead?"
   - header: "Plan Found"
   - options:
     - Use plan (Switch to /devloop:continue Task X.Y) (Recommended)
     - Quick anyway (Proceed with quick workflow, update plan when done)
     - Ignore plan (This is unrelated work)
   ```
3. **If task is related but not in plan**: Offer to add it
   ```
   Use AskUserQuestion:
   - question: "There's an active plan but this task isn't in it. Add to plan?"
   - header: "Add to Plan"
   - options:
     - Add to plan (Insert as new task, then implement)
     - Skip adding (Just do the quick task)
   ```

### After Completing a Quick Task

If a plan exists:
1. If task was in the plan, mark it `[x]` complete
2. Add Progress Log entry: `- YYYY-MM-DD HH:MM: Quick-completed Task X.Y - [summary]`
3. Update timestamps

See `Skill: plan-management` for plan format.

## When to Use

- Bug fixes with known cause
- Small feature additions to existing patterns
- Configuration changes
- Documentation updates
- Test additions for existing code

## When NOT to Use

- New features with unclear requirements
- Changes touching multiple systems
- Performance-sensitive changes
- Security-related changes
- Anything that needs architecture decisions

## Workflow

### Phase 1: Understand & Plan

**Goal**: Quick context gathering and planning

Initial request: $ARGUMENTS

**Actions**:
1. Create brief todo list
2. If the task is unclear, ask ONE clarifying question:
   ```
   Use AskUserQuestion:
   - question: "Quick clarification: [specific question]?"
   - header: "Clarify"
   - options: [Option A, Option B, Option C]
   ```
3. If task seems too complex for quick workflow:
   ```
   Use AskUserQuestion:
   - question: "This seems complex. Should I use the full devloop workflow?"
   - header: "Workflow"
   - options:
     - Yes, full workflow (Switch to comprehensive approach)
     - No, keep it quick (Proceed with streamlined approach)
   ```

### Phase 2: Implement

**Goal**: Direct implementation

**Actions**:
1. Read relevant files (limit to 3-5 files maximum)
2. Implement the change
3. Follow existing patterns exactly
4. Update todos as you go

### Phase 3: Verify

**Goal**: Quick validation

**Actions**:
1. Run relevant tests:
   ```bash
   # Based on project type
   npm test -- --related  # or
   go test ./...          # or
   pytest -x              # etc
   ```

2. If tests fail, fix immediately
3. Quick self-review - check for obvious issues

### Phase 4: Done

**Goal**: Wrap up

**Actions**:
1. Mark todos complete
2. Brief summary:
   - What was changed
   - Files modified
   - Any follow-up needed

---

## Speed Guidelines

| Phase | Target Time |
|-------|-------------|
| Understand | 2-3 minutes |
| Implement | 5-15 minutes |
| Verify | 2-3 minutes |
| Done | 1 minute |

Total: 10-20 minutes for typical quick task

## Model Usage

All phases use **haiku** for speed, except:
- Complex logic: Use sonnet
- If promoted to full workflow: Follow standard model selection

## Escalation

If during implementation you discover:
- The change is more complex than expected
- Multiple systems are affected
- Architecture decisions are needed
- Security implications exist

**Stop and ask**:
```
Use AskUserQuestion:
- question: "I've discovered this is more complex. How should I proceed?"
- header: "Escalate"
- options:
  - Full workflow (Switch to /devloop for comprehensive approach)
  - Continue quick (I'll accept the limitations)
  - Stop here (Let me reconsider the task)
```
