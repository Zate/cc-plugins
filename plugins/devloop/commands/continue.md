---
description: Resume work from an existing plan - finds the current plan and implements the next step
argument-hint: Optional specific step to work on
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill", "WebSearch", "WebFetch"]
---

# Continue from Plan

Resume work from an existing implementation plan. Finds the current plan, identifies progress, and continues with the next step.

**IMPORTANT**: Always invoke `Skill: plan-management` to understand plan format and update procedures.

## Context Sources

When resuming work, read both:
1. **Plan** (`.devloop/plan.md`) - What's in progress
2. **Worklog** (`.devloop/worklog.md`) - What's already committed

The worklog shows completed tasks with commit hashes; the plan shows current progress.
For worklog format details, invoke: `Skill: worklog-management`

## Plan Location

The canonical plan location is: **`.devloop/plan.md`**

Search for plans in this order:
1. **`.devloop/plan.md`** ← Primary (devloop standard)
2. `docs/PLAN.md`, `docs/plan.md`
3. `PLAN.md`, `plan.md`
4. `~/.claude/plans/*.md` (fallback - most recent)

## Workflow

### Step 1: Find the Plan

```bash
# Check for project-local plans first
for plan_file in .devloop/plan.md docs/PLAN.md docs/plan.md PLAN.md plan.md; do
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

### Step 2.5: Detect Parallel Tasks

**Check for parallelism markers** in pending tasks:

1. **Find parallel groups**: Look for `[parallel:X]` markers on pending `[ ]` tasks
2. **Group by marker**: Tasks with same letter (e.g., `[parallel:A]`) can run together
3. **Check dependencies**: Tasks with `[depends:N.M]` must wait for dependencies to complete

**If parallel tasks found:**
```
Use AskUserQuestion:
- question: "I found [N] tasks that can run in parallel (Group [X]). Run them together?"
- header: "Parallel"
- options:
  - Run in parallel (Spawn agents for all Group X tasks) (Recommended)
  - Run sequentially (Execute one at a time)
  - Pick specific (Let me choose which to run)
```

**If running in parallel:**
1. Spawn agents for each task using `Task` tool with `run_in_background: true`
2. Each agent receives:
   - Task description and acceptance criteria
   - Relevant files from plan
   - Context: "This task is part of parallel group X"
3. Track progress with `TaskOutput` (poll with `block: false`)
4. Display status:
   ```
   ⏳ Task 2.1: Creating user model...
   ✓ Task 2.2: Auth service complete
   ⏳ Task 2.3: Waiting for 2.1...
   ```
5. When all group tasks complete, proceed to dependent tasks

**Token cost check** before spawning:
- If tasks would require multiple Opus agents, warn user about cost
- Recommend: "3 sonnet agents" or "1 opus + 2 haiku" patterns
- See `Skill: plan-management` for token cost guidelines

### Step 3: Determine Next Step

Analyze the plan to find:
1. First incomplete task/step (or parallel group)
2. Any blocked tasks (dependencies not met via `[depends:X]`)
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
- **Parallel Groups Available**: [List any parallel groups with pending tasks]

### Completed Tasks
1. ~~[Task 1]~~ ✓
2. ~~[Task 2]~~ ✓

### Next Up
**[Task N+1]**: [Task description]

### Parallel Opportunities (if any)
- **Group A** (can run together): Task 2.1, Task 2.2
- **Blocked until Group A**: Task 2.3 [depends:2.1,2.2]

### Remaining Tasks
- [ ] [Task N+2]  [parallel:A]
- [ ] [Task N+3]  [parallel:A]
- [ ] [Task N+4]  [depends:N+2,N+3]
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
4. **Report**: Summarize what was done

### Step 5.5: Task Checkpoint (REQUIRED)

**Before proceeding to the next task, complete this checkpoint:**

Invoke `Skill: task-checkpoint` for the complete checklist.

#### 1. Verify Implementation
- [ ] Code changes implement task requirements
- [ ] No placeholder code or TODOs left incomplete
- [ ] Tests pass (run test suite if applicable)
- [ ] Error handling is in place

#### 2. Update Plan File
**REQUIRED** - Update `.devloop/plan.md`:
- [ ] Mark task complete: `- [ ]` → `- [x]`
- [ ] Add Progress Log entry: `- YYYY-MM-DD HH:MM: Completed Task X.Y - [summary]`
- [ ] Update `**Updated**:` timestamp

#### 3. Commit Decision

Determine commit strategy using `Skill: atomic-commits`:

```
Use AskUserQuestion:
- question: "Task complete. How should we handle the commit?"
- header: "Commit"
- options:
  - Commit now (Create atomic commit for this task)
  - Group with next (Continue, commit after related tasks)
  - Review changes (Show diff before deciding)
```

**Commit now if:**
- Task is self-contained and reviewable
- Changes are < 300 lines
- Unrelated to the next task

**Group with next if:**
- Next task is tightly coupled (e.g., feature + its tests)
- Combined changes form a more coherent unit
- Both tasks together are still < 500 lines

#### 4. Execute Commit (if committing now)

1. Launch git-manager agent with task context
2. Include task reference in commit: `feat(scope): description - Task X.Y`
3. After commit, update Progress Log with commit hash:
   ```markdown
   - YYYY-MM-DD HH:MM: Committed Task X.Y - abc1234
   ```

#### 5. Enforcement Check

Read `.devloop/local.md` for enforcement setting:

**If `enforcement: strict`:**
- Verify plan was actually updated
- Block if not updated - do not proceed to next task

**If `enforcement: advisory` (default):**
- Warn if plan not updated
- Allow override with user confirmation

### Step 6: Update Plan File

**CRITICAL**: After completing a task, you MUST update `.devloop/plan.md`:

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

### Step 7.5: Phase Completion Checkpoint

**When all tasks in the current phase are marked `[x]`:**

#### 1. Verify Phase Completion
- [ ] All tasks in phase are marked complete
- [ ] All tests pass
- [ ] No uncommitted changes from grouped commits

#### 2. Commit Any Pending Work
If commits were grouped during the phase:
- Phase boundary = natural commit point
- Commit all grouped work now
- Use format: `feat(scope): complete [phase name] - Tasks X.1-X.N`

#### 3. Documentation Check

Check for project documentation:
```bash
ls CHANGELOG.md README.md docs/
```

**If CHANGELOG.md exists:**
```
Use AskUserQuestion:
- question: "Phase complete. Update CHANGELOG?"
- header: "Changelog"
- options:
  - Update now (Generate entry from commits)
  - Skip (No changelog update needed)
  - Review commits (Show what would be added)
```

If updating, use `Skill: version-management` for CHANGELOG format.

#### 4. Version Check

Use `Skill: version-management` to determine if a version bump is warranted:

1. Parse commits since last tag:
   ```bash
   git log $(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~50")..HEAD --oneline
   ```

2. Determine bump from conventional commits:
   - `BREAKING CHANGE:` or `!:` → MAJOR
   - `feat:` → MINOR
   - `fix:`, `perf:` → PATCH
   - Other → No bump

3. If bump warranted:
   ```
   Use AskUserQuestion:
   - question: "Based on commits, suggest [MINOR] bump (v1.2.0 → v1.3.0). Proceed?"
   - header: "Version"
   - options:
     - Accept suggested (Bump to suggested version)
     - Different bump (Let me choose)
     - Skip versioning (No version change now)
   ```

#### 5. Update Plan for Phase Transition

Update `.devloop/plan.md`:
- [ ] Update `**Current Phase**:` to next phase
- [ ] Add Progress Log entry: `- YYYY-MM-DD HH:MM: Completed Phase X - [summary]`
- [ ] If versioned: `- YYYY-MM-DD HH:MM: Released vX.Y.Z`

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

When `/devloop` creates a plan in Phase 6 (Planning), it should save to `.devloop/plan.md`:

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

## Recovery Flows

When resuming work, check for out-of-sync scenarios and offer recovery.

### Scenario 1: Plan Not Updated

**Detection**: Completed tasks marked `[x]` but no recent Progress Log entries.

```
Use AskUserQuestion:
- question: "Plan may be out of sync: [N] completed tasks without Progress Log entries. How to proceed?"
- header: "Recovery"
- options:
  - Backfill entries (Add Progress Log entries for completed tasks)
  - Continue anyway (Resume from next pending task)
  - Review tasks (Show which tasks appear complete)
```

**Recovery action** (if backfill selected):
```markdown
For each completed task without Progress Log:
- YYYY-MM-DD HH:MM: [Backfill] Task X.Y completed
```

### Scenario 2: Uncommitted Changes

**Detection**: `git status` shows modified files, but plan shows tasks complete.

```
Use AskUserQuestion:
- question: "Uncommitted changes detected with [N] completed tasks. How to proceed?"
- header: "Uncommitted"
- options:
  - Commit now (Create commit for pending changes)
  - Discard changes (Reset to last commit)
  - Continue (Keep changes uncommitted)
```

### Scenario 3: Worklog Drift

**Detection**: Plan's Progress Log has entries not in worklog.

```
Use AskUserQuestion:
- question: "Worklog is behind plan. Some completed tasks may not be in the worklog."
- header: "Worklog"
- options:
  - Sync worklog (Copy missing entries to worklog)
  - Ignore (Continue without syncing)
  - Rebuild worklog (Reconstruct from git history)
```

**Sync action**: Copy Progress Log entries with commit hashes to worklog.

### Scenario 4: Commits Without Tasks

**Detection**: Recent commits don't reference tasks from the plan.

```
Use AskUserQuestion:
- question: "Found [N] recent commits not linked to plan tasks. What happened?"
- header: "Commits"
- options:
  - Ad-hoc work (These were outside the plan)
  - Missing tasks (Add tasks to plan retroactively)
  - Review commits (Show commit details)
```

### Scenario 5: Plan Status Stale

**Detection**: `**Updated**:` timestamp is more than 24 hours old.

```
Use AskUserQuestion:
- question: "Plan was last updated [time ago]. Is it still current?"
- header: "Stale"
- options:
  - Still current (Continue as-is)
  - Review plan (Show current plan status)
  - Refresh (Check for any sync issues)
```

---

## Error Handling

**No plan found**: Offer to start fresh with `/devloop`
**Plan complete**: Congratulate and suggest `/devloop:ship`
**Unclear progress**: Ask user to clarify current state
**Outdated plan**: Offer to revise or create new plan
