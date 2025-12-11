---
description: Resume work from an existing plan - finds the current plan and implements the next step
argument-hint: Optional specific step to work on
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill", "WebSearch", "WebFetch"]
---

# Continue from Plan

Resume work from an existing implementation plan. Finds the current plan, identifies progress, and continues with the next step.

**IMPORTANT**: Always invoke `Skill: plan-management` to understand plan format and update procedures.

## Plan Location

The canonical plan location is: **`.claude/devloop-plan.md`**

Search for plans in this order:
1. **`.claude/devloop-plan.md`** ← Primary (devloop standard)
2. `docs/PLAN.md`, `docs/plan.md`
3. `PLAN.md`, `plan.md`
4. `~/.claude/plans/*.md` (fallback - most recent)

## Workflow

### Step 1: Find the Plan

```bash
# Check for project-local plans first
for plan_file in .claude/devloop-plan.md docs/PLAN.md docs/plan.md PLAN.md plan.md; do
    if [ -f "$plan_file" ]; then
        echo "Found: $plan_file"
        break
    fi
done

# Fallback: most recent global plan
ls -t ~/.claude/plans/*.md 2>/dev/null | head -1
```

**Actions**:
1. Search for plan files in priority order
2. If no plan found:
   ```
   Use AskUserQuestion:
   - question: "No plan found. What would you like to do?"
   - header: "No Plan"
   - options:
     - Start new (Launch /devloop to create a new plan)
     - Specify path (I'll tell you where the plan is)
     - Use global (Check ~/.claude/plans/ for recent plans)
   ```

### Step 2: Parse the Plan

Read the plan file and extract:
- **Overview/Goal**: What is being built
- **Tasks/Steps**: The implementation breakdown
- **Progress markers**: Checkboxes, status indicators, or completion notes
- **Current phase**: Where we are in the workflow

**Identify task status by looking for**:
- `[x]` or `[X]` - Completed
- `[ ]` - Pending
- `~~strikethrough~~` - Completed or skipped
- `✓` or `✅` - Completed
- `Status: Complete/Done` - Completed
- `Status: In Progress` - Current
- `Status: Pending/TODO` - Not started

### Step 3: Determine Next Step

Analyze the plan to find:
1. First incomplete task/step
2. Any blocked tasks (dependencies not met)
3. Current phase if using phased approach

**If user provided $ARGUMENTS**:
- Look for a task matching the argument
- Could be task number, name, or keyword

### Step 4: Present Status

Show the user:

```markdown
## Plan Status: [Plan Name]

### Progress
- **Completed**: [N] tasks
- **Remaining**: [M] tasks
- **Current Phase**: [Phase name if applicable]

### Completed Tasks
1. ~~[Task 1]~~ ✓
2. ~~[Task 2]~~ ✓

### Next Up
**[Task N+1]**: [Task description]

### Remaining Tasks
- [ ] [Task N+2]
- [ ] [Task N+3]
```

Then ask:
```
Use AskUserQuestion:
- question: "Ready to continue with: [Next task]. Proceed?"
- header: "Continue"
- options:
  - Yes, continue (Start working on this task)
  - Different task (Let me pick a different task)
  - Review plan (Show me the full plan first)
  - Update plan (The plan needs changes)
```

### Step 5: Execute Next Task

Once user confirms:

1. **Load context**: Read files relevant to the task
2. **Check dependencies**: Ensure prerequisite tasks are done
3. **Execute**: Implement the task following devloop principles
4. **Update plan**: Mark task as complete in the plan file
5. **Report**: Summarize what was done

### Step 6: Update Plan File

**CRITICAL**: After completing a task, you MUST update `.claude/devloop-plan.md`:

1. **Mark task complete**: `- [ ]` → `- [x]`
2. **Add Progress Log entry**: `- [YYYY-MM-DD HH:MM]: Completed [task] - [summary]`
3. **Update timestamps**: Set `**Updated**:` to current date/time
4. **Update Current Phase** if moving to next phase

```markdown
# Before
- [ ] Implement user authentication

# After
- [x] Implement user authentication

## Progress Log
- 2024-12-11 14:30: Completed user authentication - added JWT middleware
```

### Step 7: Continue or Stop

After each task:
```
Use AskUserQuestion:
- question: "Task complete. Continue to next task?"
- header: "Next"
- options:
  - Continue (Proceed to next task)
  - Stop here (Save progress and stop)
  - Review (Show updated status)
```

---

## Plan File Format Support

The command understands various plan formats:

### Checkbox Format
```markdown
## Tasks
- [x] Task 1
- [ ] Task 2
- [ ] Task 3
```

### Numbered Steps
```markdown
## Implementation Steps

### Step 1: Setup (DONE)
...

### Step 2: Core Logic (IN PROGRESS)
...

### Step 3: Testing
...
```

### Phased Format
```markdown
## Phase 1: Foundation ✓
- [x] Task 1.1
- [x] Task 1.2

## Phase 2: Implementation
- [ ] Task 2.1
- [ ] Task 2.2
```

### Table Format
```markdown
| Task | Status | Notes |
|------|--------|-------|
| Task 1 | Done | Completed |
| Task 2 | In Progress | Current |
| Task 3 | Pending | Blocked by Task 2 |
```

---

## Integration with Devloop

When `/devloop` creates a plan in Phase 6 (Planning), it should save to `.claude/devloop-plan.md`:

```markdown
# Devloop Plan: [Feature Name]

**Created**: [Date]
**Status**: In Progress
**Current Phase**: Implementation

## Overview
[Feature description]

## Tasks

### Phase 1: Foundation
- [ ] Task 1.1: [Description]
- [ ] Task 1.2: [Description]

### Phase 2: Implementation
- [ ] Task 2.1: [Description]
...

## Progress Log
- [Date]: Plan created
```

---

## Model Usage

| Phase | Model | Rationale |
|-------|-------|-----------|
| Find plan | haiku | File search |
| Parse plan | haiku | Text parsing |
| Execute task | sonnet | Implementation |
| Update plan | haiku | Simple edit |

---

## Tips

- Run `/devloop:continue` at the start of a session to pick up where you left off
- The plan file is your source of truth - keep it updated
- Use `/devloop:continue step 3` to jump to a specific step
- If the plan is outdated, use "Update plan" to revise it

---

## Error Handling

**No plan found**: Offer to start fresh with `/devloop`
**Plan complete**: Congratulate and suggest `/devloop:ship`
**Unclear progress**: Ask user to clarify current state
**Outdated plan**: Offer to revise or create new plan
