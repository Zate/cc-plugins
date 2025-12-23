---
description: Resume work from an existing plan - finds the current plan and implements the next step
argument-hint: Optional specific step to work on
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill", "WebSearch", "WebFetch", "EnterPlanMode"]
---

# Continue from Plan

Resume work from an existing devloop plan. Finds the current plan, identifies progress, and routes to the appropriate devloop agent for execution.

**References**:
- `Skill: plan-management` - Plan format and update procedures
- `Skill: phase-templates` - Phase execution details
- `Skill: worklog-management` - Completed work history

---

## Agent Routing Table

**CRITICAL**: This command orchestrates devloop agents. Always use the Task tool with the correct `subagent_type`.

| Task Type | Agent | Mode/Focus |
|-----------|-------|------------|
| Implement feature/code | `devloop:engineer` | Default mode |
| Explore/understand code | `devloop:engineer` | Explore mode |
| Design architecture | `devloop:engineer` | Architect mode |
| Refactor code | `devloop:engineer` | Refactor mode |
| Git commit/branch/PR | `devloop:engineer` | Git mode |
| Plan tasks/breakdown | `devloop:task-planner` | Planner mode |
| Gather requirements | `devloop:task-planner` | Requirements mode |
| Validate completion | `devloop:task-planner` | DoD validator mode |
| Write tests | `devloop:qa-engineer` | Generator mode |
| Run tests | `devloop:qa-engineer` | Runner mode |
| Track bugs/issues | `devloop:qa-engineer` | Bug tracker mode |
| Code review | `devloop:code-reviewer` | - |
| Security scan | `devloop:security-scanner` | - |
| Generate docs | `devloop:doc-generator` | - |
| Estimate complexity | `devloop:complexity-estimator` | - |
| Spike/exploration | Suggest `/devloop:spike` | - |

---

## Step 1: Find and Read the Plan

Search in order:
1. **`.devloop/plan.md`** ← Primary (devloop standard)
2. `docs/PLAN.md`, `docs/plan.md`
3. `PLAN.md`, `plan.md`

Also read `.devloop/worklog.md` if it exists to understand completed work.

**Archive Awareness**:
- Check for `.devloop/archive/` directory
- If archives exist, note them for context (may explain missing phases)
- Archives contain complete historical phase details if referenced

**If no plan found:**
```
AskUserQuestion:
- question: "No plan found. What would you like to do?"
- header: "No Plan"
- options:
  - Start feature workflow (Recommended) → Launch /devloop
  - Quick implementation → Launch /devloop:quick
  - Explore/spike first → Launch /devloop:spike
  - Create plan now → Use EnterPlanMode, save to .devloop/plan.md
```

---

## Step 2: Parse and Present Status

Extract from plan file:
- **Plan name**: From header
- **Current phase**: Where we are
- **Completed tasks**: Count of `[x]` items
- **Pending tasks**: Count of `[ ]` items
- **Next task(s)**: First pending item(s)
- **Archived phases**: Check Progress Log for archival notes

**Task status markers:**
- `[x]` / `[X]` - Completed
- `[ ]` - Pending
- `[parallel:X]` - Can run in parallel with same marker
- `[depends:N.M]` - Depends on another task

**Archived Phase Detection**:
- If Progress Log mentions "Archived Phase N" → phase in `.devloop/archive/`
- If task references archived phase → add "see archive" note

Present status:
```markdown
## Plan: [Name]

**Progress**: [N]/[Total] tasks complete
**Current Phase**: [Phase name]

### Next Up
- [ ] **Task [N]**: [Description]

### Remaining
- [ ] Task [N+1]: [Description]
- [ ] Task [N+2]: [Description]

### Archive Status
*Phases 1-2 archived to .devloop/archive/ (see worklog for details)*
```

Include archive status only if archives exist.

---

## Step 3: Classify Next Task

Analyze the next task description to determine its type:

| Keywords/Patterns | Task Type |
|-------------------|-----------|
| "implement", "add", "create", "build", "write code" | Implementation |
| "explore", "understand", "trace", "find", "investigate" | Exploration |
| "design", "architect", "structure", "approach" | Architecture |
| "refactor", "clean up", "improve", "restructure" | Refactoring |
| "commit", "push", "PR", "branch", "merge" | Git |
| "plan", "break down", "tasks", "roadmap" | Planning |
| "requirements", "specify", "define", "scope" | Requirements |
| "test", "write tests", "add tests" | Test Generation |
| "run tests", "verify", "check tests" | Test Execution |
| "review", "check code", "audit code" | Code Review |
| "security", "vulnerability", "OWASP" | Security |
| "document", "README", "docs" | Documentation |
| "estimate", "complexity", "sizing" | Estimation |
| "spike", "POC", "prototype", "feasibility" | Spike |
| "validate", "DoD", "ready to ship" | Validation |

---

## Step 4: Present Options

Based on task classification, present targeted options:

```
AskUserQuestion:
- question: "Next task: [Task description]. How would you like to proceed?"
- header: "Action"
- options:
  - [Primary action based on task type] (Recommended)
  - Different approach
  - Skip this task
  - Update the plan first
```

**Primary actions by type:**

| Task Type | Primary Option | Agent Invoked |
|-----------|----------------|---------------|
| Implementation | "Implement with engineer agent" | devloop:engineer |
| Exploration | "Explore codebase" | devloop:engineer (explore) |
| Architecture | "Design architecture" | devloop:engineer (architect) |
| Git | "Handle git operations" | devloop:engineer (git) |
| Planning | "Break into tasks" | devloop:task-planner |
| Test Generation | "Generate tests" | devloop:qa-engineer (generator) |
| Test Execution | "Run and analyze tests" | devloop:qa-engineer (runner) |
| Code Review | "Review changes" | devloop:code-reviewer |
| Security | "Security scan" | devloop:security-scanner |
| Documentation | "Generate documentation" | devloop:doc-generator |
| Estimation | "Estimate complexity" | devloop:complexity-estimator |
| Spike | "Run spike workflow" | Suggest /devloop:spike |
| Validation | "Validate completion" | devloop:task-planner (DoD) |

---

## Step 5: Execute with Agent

**CRITICAL**: Use the Task tool with explicit `subagent_type`.

### Implementation Task
```
Task:
  subagent_type: devloop:engineer
  description: "Implement [task description]"
  prompt: |
    Implement the following task from the devloop plan:

    **Task**: [Task description]
    **Acceptance criteria**: [From plan if available]
    **Context**: [Relevant files/context from plan]

    Follow the plan's architecture decisions. Update the plan when done.
```

### Exploration Task
```
Task:
  subagent_type: devloop:engineer
  description: "Explore [area] in codebase"
  prompt: |
    Explore mode: Investigate the following from the plan:

    **Task**: [Task description]
    **Goal**: Understand [specific area]

    Return key files and findings. Don't modify code.
```

### Architecture Task
```
Task:
  subagent_type: devloop:engineer
  description: "Design architecture for [feature]"
  prompt: |
    Architect mode: Design implementation approach for:

    **Task**: [Task description]
    **Constraints**: [From plan]

    Propose 2-3 approaches with trade-offs. Use AskUserQuestion to confirm choice.
```

### Git Task
```
Task:
  subagent_type: devloop:engineer
  description: "Git operations for [task]"
  prompt: |
    Git mode: Handle version control for completed work:

    **Task**: [Task description]
    **Changes**: [What was implemented]

    Stage, commit with conventional message, optionally create PR.
```

### Planning Task
```
Task:
  subagent_type: devloop:task-planner
  description: "Plan tasks for [feature]"
  prompt: |
    Planner mode: Break down the following into actionable tasks:

    **Task**: [Task description]

    Create ordered tasks with acceptance criteria. Save to .devloop/plan.md.
```

### Test Generation Task
```
Task:
  subagent_type: devloop:qa-engineer
  description: "Generate tests for [component]"
  prompt: |
    Generator mode: Create tests for:

    **Task**: [Task description]
    **Target**: [What to test]

    Follow existing test patterns in the codebase.
```

### Test Execution Task
```
Task:
  subagent_type: devloop:qa-engineer
  description: "Run and analyze tests"
  prompt: |
    Runner mode: Execute tests and analyze results:

    **Task**: [Task description]

    Run test suite, parse results, report failures with context.
```

### Code Review Task
```
Task:
  subagent_type: devloop:code-reviewer
  description: "Review code changes"
  prompt: |
    Review recent changes for:

    **Task**: [Task description]
    **Focus**: Correctness, quality, conventions

    Use confidence-based filtering. Report high-priority issues only.
```

### Validation Task
```
Task:
  subagent_type: devloop:task-planner
  description: "Validate Definition of Done"
  prompt: |
    DoD Validator mode: Check completion criteria for:

    **Task**: [Task description]

    Verify code, tests, review, and documentation requirements are met.
```

---

## Step 5a: MANDATORY Post-Agent Checkpoint

**CRITICAL**: This step MUST run after every agent execution. Never skip.

**Reference**: `Skill: workflow-loop` - Checkpoint requirements

### Checkpoint Sequence

#### 1. Verify Agent Output

Analyze agent result to determine completion status:

**Success Indicators**:
- ✓ Agent explicitly states task is complete
- ✓ Acceptance criteria met (if defined in plan)
- ✓ No errors reported in agent output
- ✓ Required files created/modified as expected

**Partial Completion Indicators**:
- ~ Agent completed but with acknowledged limitations
- ~ Some acceptance criteria met, others pending
- ~ Non-blocking errors encountered but recovered
- ~ Core functionality works, refinements needed

**Failure Indicators**:
- ✗ Agent encountered blocking error
- ✗ Task not addressed or attempted
- ✗ Critical requirements missing
- ✗ Agent output indicates failure

#### 2. Update Plan Markers

If `.devloop/plan.md` exists, update task status:

```bash
# Based on verification:
# Success:  - [ ] → - [x]
# Partial:  - [ ] → - [~]
# Blocked:  - [ ] → - [!]

# Add Progress Log entry
- [YYYY-MM-DD HH:MM]: Completed Task X.Y - [Description]
# OR
- [YYYY-MM-DD HH:MM]: Partially completed Task X.Y - [What was done]
# OR
- [YYYY-MM-DD HH:MM]: Task X.Y blocked - [Reason]

# Update timestamp
**Updated**: [Current ISO timestamp]
```

#### 3. Present Checkpoint Question

**For Successful Completion**:

```yaml
AskUserQuestion:
  question: "Task [X.Y] complete: [Brief summary of work]. What's next?"
  header: "Checkpoint"
  options:
    - label: "Continue to next task"
      description: "Proceed to Task [X.Y+1] in current context"
    - label: "Commit this work"
      description: "Create atomic commit, then continue"
    - label: "Fresh start"
      description: "Save state, clear context, resume in new session"
    - label: "Stop here"
      description: "Generate summary and end session"
```

**For Partial Completion**:

```yaml
AskUserQuestion:
  question: "Task [X.Y] partially complete. [What's missing/incomplete]. How should we proceed?"
  header: "Partial Completion"
  options:
    - label: "Mark done and continue"
      description: "Accept current state, move to next task"
    - label: "Continue work on this task"
      description: "Keep working to complete remaining criteria"
    - label: "Note as tech debt"
      description: "Mark blocked with TODO, move on"
    - label: "Fresh start"
      description: "Save state, clear context for better focus"
```

**For Failure/Error**:

```yaml
AskUserQuestion:
  question: "Task [X.Y] failed: [Error description]. How should we recover?"
  header: "Error Recovery"
  options:
    - label: "Retry"
      description: "Attempt again with adjusted approach"
    - label: "Skip and mark blocked"
      description: "Move to next task, track as blocker"
    - label: "Investigate error"
      description: "Show full error output for review"
    - label: "Abort workflow"
      description: "Stop and save state"
```

#### 4. Handle Selected Action

**If "Continue to next task"**:
1. No commit - changes remain uncommitted
2. Return to Step 2 (Parse and Present Status) with next task
3. Loop continues

**If "Commit this work"**:
1. Prepare conventional commit message:
   - Type: feat/fix/refactor/docs/test/chore
   - Scope: [component]
   - Message: Task X.Y - [description]
2. Stage changes with `git add`
3. Execute `git commit` OR invoke `devloop:engineer` (git mode)
4. Verify commit succeeded
5. Update worklog with commit hash
6. Ask: "Continue to next task or stop?"

**If "Fresh start"**:
1. Generate brief session summary
2. Write state to `.devloop/next-action.json`:
   ```json
   {
     "last_completed": "Task X.Y",
     "next_pending": "Task X.Z",
     "summary": "Brief description",
     "timestamp": "ISO timestamp"
   }
   ```
3. Display message: "State saved. Run `/clear` to reset context, then `/devloop:continue` to resume."
4. END workflow

**If "Stop here"**:
1. Generate summary of session work
2. List completed tasks
3. Show next task recommendation
4. END workflow

**If "Mark done and continue"** (partial):
1. Mark task `[x]` in plan
2. Add note in Progress Log about limitations
3. Return to Step 2 with next task

**If "Continue work on this task"** (partial):
1. Keep task `[~]` in plan
2. Return to Step 5 (Execute with Agent) with same task
3. Provide agent with context about what's missing

**If "Note as tech debt"** (partial):
1. Mark task `[!]` in plan
2. Add TODO note to Progress Log
3. Return to Step 2 with next task

**If "Retry"** (error):
1. Keep task `[ ]` in plan
2. Add retry note to Progress Log
3. Return to Step 5 with same task and error context

**If "Skip and mark blocked"** (error):
1. Mark task `[!]` in plan
2. Add blocker note: "Task X.Y blocked - [reason]"
3. Return to Step 2 with next task

**If "Investigate error"** (error):
1. Display complete agent output
2. Show relevant error messages
3. Ask follow-up: Retry / Skip / Abort

**If "Abort workflow"** (error):
1. Save current state
2. Generate summary of what was attempted
3. END workflow

#### 5. Track Session Metrics

After every checkpoint, track context health:

```bash
tasks_completed=$((tasks_completed + 1))
agent_calls=$((agent_calls + 1))
session_duration=$((current_time - session_start))

# Check thresholds (see Skill: workflow-loop)
if [ $tasks_completed -gt 5 ] || [ $agent_calls -gt 10 ]; then
  # Proactively suggest fresh start in checkpoint options
fi
```

---

## Step 5b: Loop Completion Detection

**CRITICAL**: This step runs after Step 5a (checkpoint) to detect when all tasks are complete.

**Reference**: `Skill: plan-management` - Task markers and status

### Completion Detection Logic

After the checkpoint completes successfully (user chose "Continue to next task"), check for completion:

#### 1. Count Remaining Tasks

Parse `.devloop/plan.md` to count task status:

```bash
# Count task markers
pending_tasks=$(grep -E '^\s*-\s*\[\s\]' .devloop/plan.md | wc -l)
partial_tasks=$(grep -E '^\s*-\s*\[~\]' .devloop/plan.md | wc -l)
completed_tasks=$(grep -E '^\s*-\s*\[x\]' .devloop/plan.md | wc -l)

# Total incomplete = pending + partial
incomplete=$((pending_tasks + partial_tasks))
```

**Task markers reference**:
- `[ ]` - Pending (not started)
- `[~]` - In progress / partial
- `[x]` - Complete
- `[-]` - Skipped (counts as "done" for completion)
- `[!]` - Blocked (counts as incomplete)

**Dependency checking**:
- Tasks with `[depends:X.Y]` only count as eligible if dependencies are complete
- If task depends on incomplete task, it's not eligible yet

#### 2. Detect Completion State

```bash
if [ $incomplete -eq 0 ]; then
  # All tasks complete OR all remaining are blocked
  completion_state="complete"
elif [ $pending_tasks -eq 0 ] && [ $partial_tasks -gt 0 ]; then
  # No pending, but some partial remain
  completion_state="partial_completion"
else
  # Work remaining
  completion_state="in_progress"
fi
```

#### 3. Handle Completion States

**If `completion_state == "complete"`**:

All tasks are marked `[x]`, `[-]`, or all remaining are `[!]` (blocked).

Present completion options:

```yaml
AskUserQuestion:
  question: "All tasks complete! Plan finished. What's next?"
  header: "Plan Complete"
  options:
    - label: "Ship it (Recommended)"
      description: "Run validation and prepare for deployment via /devloop:ship"
    - label: "Review plan"
      description: "Show summary of completed work and tasks"
    - label: "Add more tasks"
      description: "Extend the plan with additional work"
    - label: "End session"
      description: "Update plan status to Complete and stop"
```

**If `completion_state == "partial_completion"`**:

No pending tasks, but some tasks marked `[~]` (partial).

```yaml
AskUserQuestion:
  question: "All tasks attempted, but {N} remain partially complete. How to proceed?"
  header: "Partial Completion"
  options:
    - label: "Finish partials"
      description: "Work through {N} partial tasks to complete them"
    - label: "Ship anyway"
      description: "Accept current state and run /devloop:ship"
    - label: "Review partials"
      description: "Show which tasks are partial and what's missing"
    - label: "Mark as complete"
      description: "Accept partials as done, update plan to Complete"
```

**If `completion_state == "in_progress"`**:

Work remains - return to Step 6 (Handle Parallel Tasks) to continue the loop.

#### 4. Handle Completion Options

**If "Ship it" (Recommended)**:

1. Update plan status to "Review"
2. Add Progress Log entry: "All tasks complete - launching ship workflow"
3. Display message: "Launching /devloop:ship for validation and deployment prep"
4. **Launch ship workflow**: Invoke `/devloop:ship` command
5. END continue workflow (ship takes over)

**If "Review plan"**:

1. Display plan summary:
   ```markdown
   ## Plan Summary: [Plan Name]

   **Status**: Complete
   **Total Tasks**: {total}
   **Completed**: {completed_count}
   **Skipped**: {skipped_count}

   ### Completed Work
   - [x] Task 1.1: [Description]
   - [x] Task 1.2: [Description]
   ...

   ### Commits (from worklog)
   - abc1234: feat: Task 1.1 - [description]
   - def5678: feat: Task 1.2 - [description]
   ```

2. Ask follow-up:
   ```yaml
   AskUserQuestion:
     question: "Plan review complete. Next action?"
     header: "Next"
     options:
       - label: "Ship it"
         description: "Run /devloop:ship workflow"
       - label: "Add tasks"
         description: "Extend with additional work"
       - label: "End session"
         description: "Stop here, update plan to Complete"
   ```

**If "Add more tasks"**:

1. Ask user what to add (free-form or structured):
   ```yaml
   AskUserQuestion:
     question: "What additional work should be added to the plan?"
     header: "Add Tasks"
     options:
       - label: "Enter plan mode"
         description: "Use EnterPlanMode to design additional tasks"
       - label: "Quick add"
         description: "Describe tasks in text, I'll add to plan"
       - label: "New phase"
         description: "Start a new phase with structured tasks"
   ```

2. Based on selection:
   - **Enter plan mode**: Use `EnterPlanMode`, then update `.devloop/plan.md`
   - **Quick add**: Parse user input, append to current phase or create new phase
   - **New phase**: Create "Phase N+1" section with tasks

3. After adding tasks:
   - Update Progress Log: "Extended plan with {N} new tasks"
   - Return to Step 2 (Parse and Present Status) with updated plan

**If "End session"**:

1. Update plan status from "In Progress" → "Complete"
2. Add final Progress Log entry:
   ```markdown
   - [YYYY-MM-DD HH:MM]: Plan marked complete - all tasks done
   ```
3. Update timestamp
4. Display completion message:
   ```markdown
   ## Plan Complete! 🎉

   **Work completed**: {completed_count} tasks
   **Duration**: [From plan Created to now]

   ### Next Steps
   - Run `/devloop:ship` when ready to deploy
   - Review commits in worklog
   - Archive plan if needed: `/devloop:archive`
   ```
5. END workflow

**If "Finish partials"** (partial_completion state):

1. Find first task marked `[~]`
2. Return to Step 5 (Execute with Agent) with that task
3. Agent should focus on completing remaining acceptance criteria
4. Continue loop

**If "Ship anyway"** (partial_completion state):

1. Confirm with user:
   ```yaml
   AskUserQuestion:
     question: "{N} tasks are partial. Ship with incomplete work?"
     header: "Confirm"
     options:
       - label: "Yes, ship"
         description: "Accept partial state, run validation"
       - label: "No, go back"
         description: "Return to finish partials"
   ```

2. If confirmed:
   - Update plan status to "Review"
   - Add note: "Shipped with {N} partial tasks - see Progress Log for details"
   - Launch `/devloop:ship`

**If "Review partials"** (partial_completion state):

1. List all `[~]` tasks with their acceptance criteria
2. Show what's complete vs. what's missing
3. Ask follow-up: "Finish partials" / "Ship anyway" / "Mark complete"

**If "Mark as complete"** (partial_completion state):

1. Convert all `[~]` → `[x]` in plan
2. Add Progress Log note: "Marked {N} partial tasks as complete"
3. Update plan status to "Complete"
4. Display completion message (same as "End session")
5. END workflow

#### 5. Update Plan Metadata

When marking plan complete (any completion path):

```markdown
**Status**: Complete
**Updated**: [Current ISO timestamp]
**Completed**: [Current date]

## Progress Log
- [YYYY-MM-DD HH:MM]: All tasks complete - plan marked Complete
- [YYYY-MM-DD HH:MM]: {Previous entries...}
```

### Edge Cases

| Scenario | Detection | Action |
|----------|-----------|--------|
| Empty plan (no tasks) | `pending_tasks == 0 && completed_tasks == 0` | Ask: "No tasks in plan. Add tasks or end?" |
| All blocked (no eligible tasks) | `pending_tasks > 0 && all have unmet deps` | Present completion options (treat as done) |
| Archived phases only | Plan has archive notes but no active tasks | Check archives, offer restoration |
| Plan already "Complete" | Status field == "Complete" | Inform user, suggest /devloop:ship or add tasks |

### Integration with Step 5a Checkpoint

**Flow**:

```
Step 5: Execute with Agent
  ↓
Step 5a: Post-Agent Checkpoint
  ↓
[User selects "Continue to next task"]
  ↓
Step 5b: Check Completion ← YOU ARE HERE
  ↓
[If incomplete] → Step 6: Handle Parallel Tasks → Loop continues
[If complete] → Present completion options → Launch ship OR extend plan OR end
```

**Critical**: Step 5b ONLY runs if user chose "Continue to next task" at checkpoint. Other checkpoint options (commit/fresh/stop) bypass completion detection.

---

## Step 5c: Context Management

**CRITICAL**: This step runs after Step 5b to detect context staleness and prevent running with overloaded context.

**Reference**: `Skill: workflow-loop` - Context health and recovery patterns

### When to Check

Check context health after:
- Each task completion (Step 5a checkpoint)
- Before spawning parallel agents (Step 6)
- After any agent spawns background tasks
- At session start (if resuming from previous session)

### Session Metrics to Track

Track these throughout the session (in-memory counters, not persisted):

```bash
# Initialize at session start
session_start_time=$(date +%s)
tasks_completed=0
agents_spawned=0
background_agents=0

# Update after each checkpoint
tasks_completed=$((tasks_completed + 1))
agents_spawned=$((agents_spawned + 1))
session_duration=$((current_time - session_start_time))

# Calculate plan size
plan_lines=$(wc -l < .devloop/plan.md)

# Estimate token usage (rough)
# ~500 tokens per task completed (prompts + responses)
# ~2000 tokens per agent spawn (context + output)
# Plan file contributes ~1 token per 4 characters
estimated_tokens=$((tasks_completed * 500 + agents_spawned * 2000))
```

### Staleness Thresholds

| Metric | Threshold | Action | Severity |
|--------|-----------|--------|----------|
| **Tasks completed** | 10+ tasks | Suggest fresh start | Warning |
| **Agents spawned** | 15+ agents | Context getting heavy | Warning |
| **Session duration** | 2+ hours | Conversation likely stale | Warning |
| **Plan size** | 500+ lines | Suggest `/devloop:archive` | Info |
| **Estimated tokens** | 150k+ tokens | Context nearly full | Critical |
| **Background agents** | 5+ active | Too many parallel tasks | Warning |

**Severity levels**:
- **Info**: Informational, optional action
- **Warning**: Recommended action, workflow continues
- **Critical**: Strongly recommended action, risk of degraded performance

### Detection Logic

After each checkpoint, check thresholds:

```bash
# Check thresholds
warnings=()
critical=false

if [ $tasks_completed -ge 10 ]; then
  warnings+=("10+ tasks completed - context may be stale")
fi

if [ $agents_spawned -ge 15 ]; then
  warnings+=("15+ agents spawned - context heavy")
fi

if [ $session_duration -ge 7200 ]; then  # 2 hours in seconds
  warnings+=("Session running 2+ hours - conversation stale")
fi

if [ $plan_lines -ge 500 ]; then
  warnings+=("Plan exceeds 500 lines - consider archiving")
fi

if [ $estimated_tokens -ge 150000 ]; then
  warnings+=("Estimated 150k+ tokens - context nearly full")
  critical=true
fi

if [ $background_agents -ge 5 ]; then
  warnings+=("5+ background agents - too many parallel tasks")
fi
```

### Warning Presentation

**If warnings exist BUT not critical**:

Present advisory warning in checkpoint response:

```markdown
⚠️ **Context Health Warning**

The following metrics suggest a fresh start may improve performance:
- {warning 1}
- {warning 2}

**Recommendations**:
- Consider `/devloop:fresh` to preserve state and start clean session (Task 8.1 - future)
- Use `/devloop:archive` to compress plan if large
- Continue anyway if close to completion

Would you like to continue or take action?
```

**If CRITICAL threshold exceeded**:

Present critical warning with stronger recommendation:

```markdown
🛑 **Context Critical**

Context is nearly exhausted:
- Estimated 150k+ tokens in conversation
- Risk of degraded performance or incomplete responses

**Recommended Actions** (choose one):
1. **Fresh start (Recommended)**: Run `/devloop:fresh` to save state and clear context (Task 8.1 - future)
2. **Archive large plan**: Use `/devloop:archive` to compress if plan > 500 lines
3. **Continue anyway**: Acknowledge risk, proceed with current context

What would you like to do?
```

### Refresh Decision Tree

```
Context check triggered
    ↓
Are any thresholds exceeded?
    ↓
  NO → Continue normally
    ↓
  YES → Check severity
        ↓
      Info/Warning → Present advisory, offer actions
        ↓
      Critical → Present strong recommendation
            ↓
          User chooses:
            ↓
          Fresh start → Save state, recommend /clear + /devloop:continue
            ↓
          Archive → Launch /devloop:archive
            ↓
          Continue → Acknowledge risk, proceed
```

### Refresh Suggestions by Threshold

| Threshold Exceeded | Primary Suggestion | Alternative |
|-------------------|-------------------|-------------|
| Tasks completed (10+) | Fresh start | Archive + continue |
| Agents spawned (15+) | Fresh start | Review parallel tasks |
| Session duration (2h+) | Fresh start | Take break, resume |
| Plan size (500+ lines) | Archive plan | Continue (if close) |
| Estimated tokens (150k+) | **Fresh start (required)** | None - critical |
| Background agents (5+) | Wait for completion | Kill background tasks |

### Background Agent Best Practices

**When spawning background agents**:

1. **Use sparingly**: Max 3-4 background agents at once
2. **Track count**: Increment `background_agents` counter on spawn
3. **Poll periodically**: Use `TaskOutput(block=false)` to check status
4. **Block when idle**: Use `TaskOutput(block=true)` only when out of other work
5. **Decrement on completion**: When agent finishes, reduce counter

**Pattern for background execution**:

```bash
# Before spawning
if [ $background_agents -ge 5 ]; then
  # Too many - wait for some to complete
  echo "Waiting for background tasks to complete..."
  TaskOutput(block=true)  # Block until one finishes
  background_agents=$((background_agents - 1))
fi

# Spawn background agent
Task:
  subagent_type: devloop:engineer
  description: "Implement feature A"
  run_in_background: true

background_agents=$((background_agents + 1))

# Later: Poll for results
while [ $background_agents -gt 0 ]; do
  result=$(TaskOutput(block=false))
  if [ -n "$result" ]; then
    # Agent completed
    background_agents=$((background_agents - 1))
    # Process result
  fi
  # Continue with other work
done
```

**When to use background agents**:
- Parallel tasks with `[parallel:X]` markers
- Independent explorers analyzing different areas
- Test generators running while implementing
- Read-only operations that don't need immediate results

**When NOT to use background agents**:
- User interaction required (AskUserQuestion doesn't work in background)
- Tasks with dependencies on each other
- Critical path work that blocks other tasks
- When context is already heavy (see thresholds above)

### Integration with Workflow Loop

**Step 5a (Checkpoint)** → Update session metrics → **Step 5c (Context Management)** → Check thresholds → Present warnings if needed → **Step 5b (Completion Detection)** → **Step 6 (Parallel Tasks)**

**Flow**:

```
Task completes
  ↓
Step 5a: Checkpoint (verify, update plan, ask user)
  ↓
Update metrics: tasks_completed++, agents_spawned++
  ↓
Step 5c: Context Management (check thresholds)
  ↓
[If warnings] → Present advisory/critical warning
  ↓
[User chooses action or continues]
  ↓
Step 5b: Completion Detection (check if plan done)
  ↓
[If work remains] → Step 6: Parallel Tasks
  ↓
[Loop continues]
```

### State Persistence for Fresh Start

When user chooses "Fresh start" from context warning:

1. **Save session state** to `.devloop/session-state.json`:
   ```json
   {
     "last_completed": "Task X.Y",
     "next_pending": "Task X.Z",
     "tasks_completed": 12,
     "agents_spawned": 18,
     "session_duration": 7890,
     "reason": "Context heavy - fresh start recommended",
     "timestamp": "2025-12-23T14:30:00Z"
   }
   ```

2. **Display restart instructions**:
   ```markdown
   ## Session State Saved

   Your progress has been saved to `.devloop/session-state.json`.

   **To resume with fresh context**:
   1. Run `/clear` to reset conversation context
   2. Run `/devloop:continue` to resume from saved state

   **Metrics at pause**:
   - Tasks completed: {tasks_completed}
   - Agents spawned: {agents_spawned}
   - Session duration: {formatted_duration}

   **Next task**: Task {next_pending}
   ```

3. **END workflow** (user must manually restart)

### Edge Cases

| Scenario | Detection | Action |
|----------|-----------|--------|
| **Session just started** | `tasks_completed == 0` | Skip context check |
| **Plan already archived** | Plan < 200 lines | Skip plan size warning |
| **Single task remaining** | `pending_tasks == 1` | Skip fresh start suggestion (finish it) |
| **Background agents stuck** | Agent running > 10 min | Offer to kill/wait |
| **Token estimate wrong** | Manual override needed | Use actual conversation length if available |

### Testing Context Management

**Simulate thresholds** (for testing):

```bash
# Force warnings
tasks_completed=12
agents_spawned=20
session_duration=10000

# Check logic
# Should trigger: tasks, agents, duration warnings
```

**Expected behavior**:
- Warning presented after checkpoint
- User offered clear actions
- Workflow continues or saves state
- No blocking unless critical threshold

---

## Step 6: Handle Parallel Tasks

If next tasks have `[parallel:X]` markers:

1. Group tasks by marker letter
2. Present grouped option:
   ```
   AskUserQuestion:
   - question: "Tasks A, B, C can run in parallel. Run together?"
   - header: "Parallel"
   - options:
     - Run all in parallel (Recommended)
     - Run sequentially
     - Pick specific tasks
   ```

3. If parallel, launch multiple Task tools simultaneously:
   ```
   Task: subagent_type: devloop:engineer, description: "Task A", run_in_background: true
   Task: subagent_type: devloop:engineer, description: "Task B", run_in_background: true
   Task: subagent_type: devloop:engineer, description: "Task C", run_in_background: true
   ```

4. Use TaskOutput to collect results

---

## Step 7: Plan Mode Integration

If user selects "Update the plan first" or needs to create a new plan:

1. Use `EnterPlanMode` to design the approach
2. **CRITICAL**: When exiting plan mode, save the plan to `.devloop/plan.md`
3. The plan MUST follow devloop format (see `Skill: plan-management`)
4. Resume with `/devloop:continue` after plan is saved

---

## Step 8: Recovery Scenarios

| Scenario | Detection | Action |
|----------|-----------|--------|
| No plan | `.devloop/plan.md` missing | Offer /devloop or EnterPlanMode |
| Plan complete | All tasks `[x]` (detected in Step 5b) | Present completion options: ship/review/add/end |
| Partial completion | No `[ ]`, but `[~]` remain | Offer finish/ship/review/mark-complete |
| Stale plan | Updated > 24h ago | Offer to refresh |
| Uncommitted work | git status shows changes | Offer devloop:engineer (git) |
| Failed tests | Previous run failed | Offer devloop:qa-engineer (runner) |
| Large plan | Plan > 200 lines | Suggest /devloop:archive to compress |
| Missing phase | Task references missing phase | Check archives, suggest restoration if needed |

---

## Model Usage

| Step | Model | Rationale |
|------|-------|-----------|
| Parse plan | haiku | Simple text parsing |
| Classify task | haiku | Pattern matching |
| Agent execution | Per agent config | Varies by complexity |
| Update plan | haiku | Simple edit |

---

## Tips

- Run `/devloop:continue` at session start to resume work
- Plan file is source of truth - agents update it automatically
- Use `/devloop:continue step 3` to jump to specific step
- If stuck, use "Update the plan first" to revise approach
- For unknowns, suggest `/devloop:spike` before implementation
- If plan > 200 lines, use `/devloop:archive` to compress
- Archived phases available in `.devloop/archive/` if needed for reference
