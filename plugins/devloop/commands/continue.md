---
description: Resume work from an existing plan - finds the current plan and implements the next step
argument-hint: Optional specific step to work on
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill", "WebSearch", "WebFetch"]
---

# Continue from Plan

Resume work from an existing implementation plan. Finds the current plan, identifies progress, and continues with the next step.

**References**:
- `Skill: plan-management` - Plan format and update procedures
- `Skill: phase-templates` - Phase execution details
- `Skill: worklog-management` - Completed work history

---

## Context Sources

When resuming work, read both:
1. **Plan** (`.devloop/plan.md`) - What's in progress
2. **Worklog** (`.devloop/worklog.md`) - What's already committed

---

## Step 1: Find the Plan

Search in order:
1. **`.devloop/plan.md`** ← Primary (devloop standard)
2. `docs/PLAN.md`, `docs/plan.md`
3. `PLAN.md`, `plan.md`
4. `~/.claude/plans/*.md` (fallback)

**If no plan found:**
```
AskUserQuestion:
- question: "No plan found. What would you like to do?"
- header: "No Plan"
- options:
  - Start new (Launch /devloop)
  - Specify path
  - Use global
```

---

## Step 2: Parse the Plan

Extract from plan file:
- **Overview/Goal**: What is being built
- **Tasks**: Implementation breakdown
- **Progress markers**: `[x]` = done, `[ ]` = pending
- **Current phase**: Where we are in workflow

**Task status markers:**
- `[x]` / `[X]` - Completed
- `[ ]` - Pending
- `~~strikethrough~~` - Completed/skipped
- `✓` / `✅` - Completed

---

## Step 3: Detect Parallel Tasks

Check for parallelism:
1. Find `[parallel:X]` markers on pending tasks
2. Group by marker letter
3. Check `[depends:N.M]` for dependencies

**If parallel tasks found:**
```
AskUserQuestion:
- question: "Tasks [list] can run in parallel. Run together?"
- header: "Parallel"
- options:
  - Run in parallel (Recommended)
  - Run sequentially
  - Pick specific
```

**Parallel execution**: See `Skill: phase-templates` → Implementation Phase

---

## Step 4: Present Status

Show current state:

```markdown
## Plan Status: [Name]

### Progress
- **Completed**: [N] tasks
- **Remaining**: [M] tasks
- **Current Phase**: [Phase name]

### Next Up
**[Task N+1]**: [Description]

### Remaining Tasks
- [ ] Task N+2
- [ ] Task N+3
```

Then ask:
```
AskUserQuestion:
- question: "Ready to continue with: [Next task]?"
- header: "Continue"
- options:
  - Yes, continue
  - Different task
  - Review plan
  - Update plan
```

---

## Step 5: Execute Next Task

1. **Load context**: Read relevant files
2. **Check dependencies**: Ensure prerequisites done
3. **Execute**: Implement following devloop principles
4. **Report**: Summarize what was done

---

## Step 6: Task Checkpoint

**REQUIRED** after completing each task.

See `Skill: phase-templates` → Task Checkpoint Template for full checklist.

### Quick Reference

1. **Verify**: Code implements requirements, tests pass
2. **Update plan**: `- [ ]` → `- [x]`, add Progress Log entry
3. **Commit decision**:
   ```
   AskUserQuestion:
   - question: "Task complete. How to handle commit?"
   - header: "Commit"
   - options:
     - Commit now (self-contained)
     - Group with next (related tasks)
     - Review changes
   ```

---

## Step 7: Continue or Stop

```
AskUserQuestion:
- question: "Task complete. Continue to next?"
- header: "Next"
- options:
  - Continue
  - Stop here
  - Review status
```

---

## Step 8: Phase Completion

When all tasks in current phase are `[x]`:

1. Verify all phase tasks complete
2. Commit any grouped work
3. Update `**Current Phase**:` in plan
4. Add phase completion to Progress Log

See `Skill: phase-templates` → Phase Completion Checkpoint

---

## Recovery Flows

Check for out-of-sync scenarios when resuming.

### Plan Not Updated
**Detection**: Completed tasks without Progress Log entries

### Uncommitted Changes
**Detection**: `git status` shows changes with completed tasks

### Worklog Drift
**Detection**: Progress Log entries not in worklog

### Commits Without Tasks
**Detection**: Recent commits not linked to plan tasks

### Stale Plan
**Detection**: `**Updated**:` timestamp > 24 hours old

See `Skill: phase-templates` → Recovery Templates for AskUserQuestion patterns.

---

## Error Handling

| Scenario | Action |
|----------|--------|
| No plan found | Offer `/devloop` |
| Plan complete | Congratulate, suggest `/devloop:ship` |
| Unclear progress | Ask user to clarify |
| Outdated plan | Offer revision |

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

- Run `/devloop:continue` at session start to resume
- Plan file is source of truth - keep updated
- Use `/devloop:continue step 3` to jump to specific step
- If plan outdated, use "Update plan" option
