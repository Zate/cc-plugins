---
description: Resume work from an existing plan - finds the current plan and implements the next step
argument-hint: Optional specific step to work on
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill", "WebSearch", "WebFetch", "EnterPlanMode"]
---

# Continue from Plan

Resume work from an existing devloop plan. Finds the current plan, identifies progress, and routes to the appropriate devloop agent for execution.

**Core References**:
- `Skill: workflow-loop` - Checkpoint patterns, context management, fresh start workflows
- `Skill: task-checkpoint` - Task completion verification and validation
- `Skill: plan-management` - Plan file format, location, and update procedures
- `Skill: phase-templates` - Phase execution details

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

**Classification Keywords**: "implement/add/create" → Implementation, "explore/understand/investigate" → Exploration, "design/architect" → Architecture, "commit/push/PR" → Git, "plan/break down" → Planning, "test" → Test Generation/Execution, "review" → Code Review, "security/vulnerability" → Security, "document/README" → Documentation.

---

## Step 1: Detect Plan and State

**Purpose**: Find the active plan file and check for fresh start state using deterministic scripts.

### 1a: Run Plan Detection Script

Call `scripts/detect-plan.sh` to discover plan and state:

```bash
Bash: "${CLAUDE_PLUGIN_ROOT}/scripts/detect-plan.sh --check-fresh-start --json"
```

**Script output** (JSON):
```json
{
  "active_plan": "name=Plan Name,done=5,total=10,file=.devloop/plan.md",
  "fresh_start": "plan=Plan Name,phase=3,summary=...,next=Task 3.2",
  "fresh_start_valid": "valid|stale:N|no_plan|invalid",
  "migration_needed": "true|false",
  "bug_count": "3"
}
```

**Backward compatibility**: If scripts don't exist (older plugin version), fall back to manual plan search per `Skill: plan-management` section "Plan File Location".

---

### 1b: Parse Detection Results

Extract from script output:

1. **Fresh start state**: If `fresh_start` is non-empty and `fresh_start_valid` is "valid":
   - Parse state: plan name, phase, summary, next task
   - Set `FRESH_START_MODE=true` and `FRESH_START_NEXT_TASK` for Step 2
   - Display fresh start context: "Resuming from fresh start at [timestamp]"
   - **Delete state file**: `.devloop/next-action.json` (single-use)
   - **State file format details**: See `Skill: workflow-loop` section "State Persistence for Fresh Start"

2. **Active plan**: If `active_plan` is non-empty:
   - Parse: plan name, completion stats (done/total), file path
   - Read plan file from extracted path
   - Continue to Step 2

3. **No plan found**: If both `fresh_start` and `active_plan` are empty:
   - Present user options (see below)

**Stale state handling**: If `fresh_start_valid` is "stale:N", warn user and ask to delete or use anyway.

**Migration prompt**: If `migration_needed` is "true", suggest running `/devloop:onboard` to migrate legacy .claude/ files.

---

### 1c: Handle No Plan Scenario

**If no plan found**, present options:

```yaml
AskUserQuestion:
  question: "No plan found. What would you like to do?"
  header: "No Plan"
  options:
    - label: "Start feature workflow"
      description: "Launch /devloop (Recommended)"
    - label: "Quick implementation"
      description: "Launch /devloop:quick for single task"
    - label: "Explore/spike first"
      description: "Launch /devloop:spike to investigate"
    - label: "Create plan now"
      description: "Use plan mode, save to .devloop/plan.md"
```

---

## Step 2: Display Plan Status and Select Next Task

**Purpose**: Show plan progress and select next task(s) using scripts.

### 2a: Run Status Display Script

Call `scripts/show-plan-status.sh` to render plan status:

```bash
Bash: "${CLAUDE_PLUGIN_ROOT}/scripts/show-plan-status.sh --full"
```

**Script output**: Full formatted status (see Step 1 for details).

---

### 2b: Select Next Task

Call `scripts/select-next-task.sh` to get next task(s):

```bash
Bash: "${CLAUDE_PLUGIN_ROOT}/scripts/select-next-task.sh --json"
```

**Script output** (JSON):
```json
{
  "next_task": "4.1",
  "description": "Task description",
  "phase": 4,
  "parallel_group": "A",           // if applicable
  "dependencies_met": true,
  "acceptance": "Criteria text",   // if available
  "files": "file1.go, file2.go"    // if available
}
```

**Script handles**:
- Dependency checking (tasks with `[depends:N.M]`)
- Blocked task detection
- Task status filtering (only pending tasks)
- Fresh start override (if `FRESH_START_NEXT_TASK` set)

**If no task found**: Script returns exit code 1 with reason:
- `"all_complete"` - All tasks done → Skip to Step 5b (Loop Completion)
- `"all_blocked"` - All pending tasks blocked → Present unblock options

**Backward compatibility**: If script doesn't exist, fall back to grep for first `[ ]` task in plan.md.

---

### 2c: Apply Fresh Start Context

**If `FRESH_START_MODE=true`** from Step 1:
1. Override `select-next-task.sh` output with `FRESH_START_NEXT_TASK`
2. Display fresh start banner in status output

---

## Step 3: Present Task Options

**Purpose**: Present user options for the selected task using script output.

Parse task from Step 2b JSON output and classify using keywords (see Agent Routing Table).

Present options:

```yaml
AskUserQuestion:
  question: "Next task: {description}. How proceed?"
  header: "Task {next_task}"
  options:
    - label: "[Primary action based on classification]"
      description: "(Recommended)"
    - label: "Different approach"
      description: "Alternate implementation strategy"
    - label: "Skip this task"
      description: "Mark as blocked, move to next"
    - label: "Update plan first"
      description: "Revise plan before proceeding"
```

**Primary actions by type** (from Agent Routing Table):
- Implementation → "Implement with engineer agent" (devloop:engineer)
- Exploration → "Explore codebase" (devloop:engineer in explore mode)
- Architecture → "Design architecture" (devloop:engineer in architect mode)
- Git → "Handle git operations" (devloop:engineer in git mode)
- Planning → "Break into tasks" (devloop:task-planner)
- Test Generation → "Generate tests" (devloop:qa-engineer in generator mode)
- Test Execution → "Run and analyze tests" (devloop:qa-engineer in runner mode)
- Code Review → "Review changes" (devloop:code-reviewer)
- Security → "Security scan" (devloop:security-scanner)
- Documentation → "Generate documentation" (devloop:doc-generator)
- Estimation → "Estimate complexity" (devloop:complexity-estimator)
- Spike → "Run spike workflow" (suggest /devloop:spike)
- Validation → "Validate completion" (devloop:task-planner in DoD validator mode)

**Use script output**: Pass `acceptance` and `files` to agent prompt in Step 4

---

## Step 4: Execute with Agent

**MANDATORY**: You MUST use the Task tool with explicit `subagent_type` from Agent Routing Table for ALL implementation tasks. Do NOT execute work directly in the main conversation.

### 4a: Route to Agent (REQUIRED)

**Critical enforcement rules**:
1. **Always delegate**: ALL task execution MUST be delegated to specialized agents via the Task tool
2. **Verify invocation**: After spawning agent, confirm the Task tool was actually invoked (check response)
3. **No direct work**: Do NOT implement features, write code, or make file changes in this conversation
4. **Agent is the implementer**: This command orchestrates; agents do the work

**Single parameterized pattern**:

```
Task:
  subagent_type: [agent from routing table]
  description: "[Task description]"
  prompt: |
    [Mode instruction if applicable]: [Task description]

    **Task**: [Full task description from plan]
    **Acceptance criteria**: [From plan if available]
    **Context**: [Relevant files/context from plan]

    [Mode-specific instructions based on task type]
```

### 4b: Agent Invocation Examples

**Example 1 - Implementation Task**:
```
Task:
  subagent_type: devloop:engineer
  description: "Implement authentication middleware"
  prompt: |
    Implement the following task from the devloop plan:

    **Task**: Task 3.2 - Add authentication middleware
    **Acceptance criteria**: JWT validation, role-based access control
    **Context**: src/middleware/, existing auth patterns

    Follow the plan's architecture decisions. Update the plan when done.
```

**Example 2 - Multiple Parallel Tasks**:
```
# Launch both tasks in parallel
Task:
  subagent_type: devloop:engineer
  description: "Implement UserService"
  run_in_background: true
  prompt: |
    Implement the following task from the devloop plan:

    **Task**: Task 2.1 - Implement UserService
    **Acceptance criteria**: CRUD operations, 90% test coverage
    **Context**: services/, existing repository pattern

    This task can run in parallel with Task 2.2. Update the plan when done.

Task:
  subagent_type: devloop:engineer
  description: "Implement ProductService"
  run_in_background: true
  prompt: |
    Implement the following task from the devloop plan:

    **Task**: Task 2.2 - Implement ProductService
    **Acceptance criteria**: CRUD operations, 90% test coverage
    **Context**: services/, existing repository pattern

    This task can run in parallel with Task 2.1. Update the plan when done.

# Then collect results with TaskOutput
```

**Example 3 - Test Generation**:
```
Task:
  subagent_type: devloop:qa-engineer
  description: "Generate tests for UserService"
  prompt: |
    Generator mode: Create tests for the following:

    **Task**: Task 4.1 - Add unit tests for UserService
    **Acceptance criteria**: 90%+ coverage, edge cases covered
    **Context**: services/user.go, existing test patterns in services/*_test.go

    Follow existing test table-driven patterns. Update the plan when done.
```

**Example 4 - Code Review**:
```
Task:
  subagent_type: devloop:code-reviewer
  description: "Review authentication implementation"
  prompt: |
    Review recent changes for the following:

    **Task**: Task 5.1 - Review authentication code
    **Acceptance criteria**: Security best practices, no critical issues
    **Context**: middleware/auth.go, handlers/login.go

    Use confidence-based filtering. Report high-priority issues only. Update the plan when done.
```

**Example 5 - Architecture Design**:
```
Task:
  subagent_type: devloop:engineer
  description: "Design payment integration architecture"
  prompt: |
    Architect mode: Design implementation approach for:

    **Task**: Task 1.2 - Design payment integration
    **Acceptance criteria**: Support Stripe and PayPal, extensible for future providers
    **Context**: Current architecture uses service layer pattern

    Propose 2-3 approaches with trade-offs. Present for user approval before implementation.
```

### 4c: Verification After Agent Spawn (MANDATORY)

After invoking the Task tool, verify the agent was actually spawned:

1. **Check response**: Confirm you see a task ID or agent execution confirmation
2. **If no agent spawned**: DO NOT proceed to implement work yourself - retry Task invocation
3. **If agent fails to route**: Report the routing issue and ask user how to proceed

**Anti-pattern (DO NOT DO THIS)**:
```
❌ Task tool failed, so I'll just implement it here...
❌ Let me write the code directly instead of using the agent...
❌ I'll handle this simple task without delegating...
```

**Correct pattern**:
```
✅ Task tool invoked successfully, waiting for agent result...
✅ Agent execution confirmed, monitoring progress...
✅ If Task fails: Report issue, retry, or ask user for guidance
```

### 4d: Mode-Specific Prompt Instructions

**For other agent types**, adapt the prompt mode instruction:
- Explore mode: "Explore mode: Investigate... Return key files and findings. Don't modify code."
- Architect mode: "Architect mode: Design implementation approach... Propose 2-3 approaches with trade-offs."
- Git mode: "Git mode: Handle version control for completed work... Stage, commit with conventional message."
- Planner mode: "Planner mode: Break down the following into actionable tasks... Save to .devloop/plan.md."
- Test generator: "Generator mode: Create tests for... Follow existing test patterns."
- Test runner: "Runner mode: Execute tests and analyze results... Report failures with context."
- Code review: "Review recent changes for... Use confidence-based filtering. Report high-priority issues only."
- DoD validator: "DoD Validator mode: Check completion criteria... Verify code, tests, review, docs."

---

## Step 5: Checkpoint and Continue Loop

### Step 5a: Post-Agent Checkpoint (MANDATORY)

**CRITICAL**: This step MUST run after every agent execution. Never skip.

#### 5a.1: Verify Agent Output

Determine completion state from agent result:
- **Success** (✓): Agent explicitly states task complete, acceptance criteria met
- **Partial** (~): Agent completed with limitations, some criteria pending
- **Failure** (✗): Agent encountered blocking error, task not addressed

#### 5a.2: Update Plan Markers

Based on verification result, update `.devloop/plan.md`:

```bash
# Success: Mark complete
- [ ] Task X.Y → - [x] Task X.Y

# Partial: Mark in progress
- [ ] Task X.Y → - [~] Task X.Y

# Failure: Mark blocked
- [ ] Task X.Y → - [!] Task X.Y
```

Add Progress Log entry:
```markdown
- YYYY-MM-DD HH:MM: Completed Task X.Y - [brief summary]
```

#### 5a.3: Sync Plan State (REQUIRED)

After updating plan.md, sync to plan-state.json:

```bash
Bash: "${CLAUDE_PLUGIN_ROOT}/scripts/sync-plan-state.sh"
```

#### 5a.4: Present Checkpoint Question (MANDATORY)

**ALWAYS present this question after EVERY task completion - never skip:**

**Get context usage** to determine recommendation:
```bash
Bash: "claude --json | ${CLAUDE_PLUGIN_ROOT}/scripts/get-context-usage.sh"
```

This returns a percentage (0-100). Use it to recommend the appropriate option:

```yaml
AskUserQuestion:
  question: "Task {X.Y} complete. How should we proceed?"
  header: "Checkpoint"
  options:
    # If context < 50%: Recommend "Continue to next task"
    # If context >= 50%: Recommend "Fresh start"
    - label: "Continue to next task"
      description: "Move to next pending task {context < 50% ? '(Recommended)' : ''}"
    - label: "Commit now"
      description: "Create atomic commit for this work first"
    - label: "Fresh start"
      description: "Save state, clear context, resume in new session {context >= 50% ? '(Recommended)' : ''}"
    - label: "Stop here"
      description: "Generate summary and end session"
```

#### 5a.5: Handle Checkpoint Response

| User Choice | Action |
|-------------|--------|
| **Continue to next task** | Go to Step 5b (Loop Completion Detection) |
| **Commit now** | Create commit with conventional message, then go to Step 5b |
| **Fresh start** | Run `/devloop:fresh`, instruct user to `/clear`, END workflow |
| **Stop here** | Generate session summary, END workflow |

**Commit format** (if "Commit now"):
```
<type>(<scope>): <description> - Task X.Y

<body explaining changes>
```

**Reference skills**: `Skill: task-checkpoint` for detailed verification checklist, `Skill: workflow-loop` for state transitions.

---

### Step 5b: Loop Completion Detection

**Purpose**: Detect when all tasks are complete and route to appropriate completion workflow.

**Run after**: Step 5a checkpoint completes successfully (user chose "Continue to next task")

**Detection logic**:

1. Count remaining tasks:
   - Pending (`[ ]`) + Partial (`[~]`) + Blocked (`[!]`) = incomplete
   - Completed (`[x]`) + Skipped (`[-]`) = complete
   - Check dependencies: tasks with `[depends:X.Y]` only count if dependencies complete

2. Determine completion state:
   - `complete`: All tasks `[x]`, `[-]`, or all remaining are `[!]`
   - `partial_completion`: No pending, but some `[~]` remain
   - `in_progress`: Work remaining

**Task counting and completion rules**: See `Skill: plan-management` section "Task Status Markers" and "Plan Update Rules"

**State transition patterns**: See `Skill: workflow-loop` section "State Transitions"

**Completion options** (if `complete` state):
```yaml
AskUserQuestion:
  question: "All tasks complete! Plan finished. What's next?"
  header: "Complete"
  options:
    - label: "Ship it"
      description: "Run validation and deploy via /devloop:ship (Recommended)"
    - label: "Archive and start fresh"
      description: "Archive completed phases, then create new plan"
    - label: "Work on issues"
      description: "Switch to issue tracking via /devloop:issues"
    - label: "Review plan"
      description: "Show summary of completed work"
    - label: "Add more tasks"
      description: "Extend plan with additional work"
    - label: "End session"
      description: "Mark plan Complete and stop"
```

**Partial completion options** (if `partial_completion` state):
```yaml
AskUserQuestion:
  question: "All tasks attempted, but {N} remain partially complete. How proceed?"
  header: "Partial"
  options:
    - label: "Finish partials"
      description: "Work through {N} partial tasks to complete"
    - label: "Ship anyway"
      description: "Accept state and run /devloop:ship"
    - label: "Review partials"
      description: "Show partial tasks and what's missing"
    - label: "Mark as complete"
      description: "Accept as done, update plan to Complete"
```

**Action handling**:
- **Ship it**: Update plan status to "Review", launch `/devloop:ship`, END workflow
- **Archive and start fresh**: Launch `/devloop:archive`, offer to start new plan
- **Work on issues**: Update status to "Complete", launch `/devloop:issues`
- **Review plan**: Display summary, offer ship/add/end
- **Add more tasks**: Enter plan mode or quick add, then return to Step 2
- **End session**: Mark plan "Complete", display summary, END workflow
- **Finish partials**: Find first `[~]` task, return to Step 4 (Execute with Agent)
- **Ship anyway**: Confirm with user, then launch `/devloop:ship` with note about partials
- **Review partials**: List all `[~]` tasks with missing criteria, ask finish/ship/mark
- **Mark as complete**: Convert all `[~]` → `[x]`, update to "Complete", END workflow

**If in_progress**: Return to Step 6 (Handle Parallel Tasks) to continue loop.

**Edge cases**: Empty plan → ask add tasks or end; All blocked → present completion options; Plan already "Complete" → suggest /devloop:ship or add tasks.

---

### Step 5c: Context Management

**Purpose**: Detect context staleness and suggest fresh start to prevent degraded performance.

**Run after**: Each checkpoint (Step 5a) and before parallel agents (Step 6)

**Threshold detection and warning patterns**: See `Skill: workflow-loop` section "Context Management" for:
- Session metrics to track (tasks completed, agents spawned, duration, tokens)
- Staleness thresholds (10+ tasks, 15+ agents, 2+ hours, 150k+ tokens)
- Warning severity levels (Info, Warning, Critical)
- Refresh decision tree
- Background agent best practices

**Integration for continue.md**:
1. Track session metrics in-memory (initialize at session start)
2. After each checkpoint, check thresholds
3. If warnings exist, present advisory or critical warning
4. If user chooses fresh start, save state to `.devloop/next-action.json` and END workflow
5. User must manually run `/clear` and `/devloop:continue` to resume

**State persistence format**: See `Skill: workflow-loop` section "State Persistence for Fresh Start"

---

## Step 6: Handle Parallel Tasks

**Purpose**: Execute multiple tasks in parallel if they share a parallel group.

### 6a: Detect Parallel Tasks

Use `select-next-task.sh --all-parallel` to get all tasks in same group:

```bash
Bash: "${CLAUDE_PLUGIN_ROOT}/scripts/select-next-task.sh --json --all-parallel"
```

**Script output** (if parallel tasks exist):
```json
{
  "next_task": "4.1",
  "description": "...",
  "parallel_group": "A",
  "parallel_tasks": ["4.1", "4.2", "4.3"]  // all tasks in group A with deps met
}
```

**Script handles**:
- Filtering to only pending tasks
- Checking dependencies for each parallel task
- Grouping by `[parallel:X]` marker

---

### 6b: Present Parallel Options

If `parallel_tasks` array has >1 task, present option:

```yaml
AskUserQuestion:
  question: "Tasks {parallel_tasks} can run in parallel. Run together?"
  header: "Parallel"
  options:
    - label: "Run all in parallel"
      description: "Execute {count} tasks together (Recommended)"
    - label: "Run sequentially"
      description: "Execute tasks one by one"
    - label: "Pick specific tasks"
      description: "Select which tasks to run"
```

If parallel, launch multiple Task tools simultaneously with `run_in_background: true`, then use TaskOutput to collect results.

**Parallel execution patterns**: See `Skill: plan-management` section "Smart Parallelism Guidelines"

---

### 6c: Loop Back

After Step 6 (whether running parallel or single task), return to the workflow loop:

**If parallel tasks executed**: Run Step 5a checkpoint for EACH parallel task (can batch the checkpoint question)

**If single task executed**: Already went through Step 5a

**Continue the loop**: Return to **Step 2** (Display Plan Status and Select Next Task) to get the next pending task.

```
Loop: Step 2 → Step 3 → Step 4 → Step 5a → Step 5b → Step 6 → Step 2...
```

**Exit conditions**:
- Step 5a: User chooses "Fresh start" or "Stop here"
- Step 5b: All tasks complete (presents completion options)

---

## Step 7: Plan Mode Integration

If user selects "Update the plan first" or needs to create a new plan:

1. Use `EnterPlanMode` to design the approach
2. **CRITICAL**: When exiting plan mode, save the plan to `.devloop/plan.md`
3. The plan MUST follow devloop format (see `Skill: plan-management`)
4. Resume with `/devloop:continue` after plan is saved

---

## Step 8: Recovery Scenarios

**Continue-specific recovery scenarios**:

| Scenario | Detection | Action |
|----------|-----------|--------|
| No plan | `.devloop/plan.md` missing | Offer /devloop or EnterPlanMode |
| Plan complete | All tasks `[x]` (Step 5b) | Present completion options |
| Stale plan | Updated > 24h ago | Offer to refresh |
| Large plan | Plan > 200 lines | Suggest /devloop:archive |
| Missing phase | Task references missing phase | Check archives, suggest restoration |

**Error recovery patterns for workflow issues**: See `Skill: workflow-loop` section "Error Recovery"

---

## Tips

- Run `/devloop:continue` at session start to resume work
- Plan file is source of truth - agents update it automatically
- Use `/devloop:continue step 3` to jump to specific step
- If stuck, use "Update the plan first" to revise approach
- For unknowns, suggest `/devloop:spike` before implementation
- If plan > 200 lines, use `/devloop:archive` to compress
- Archived phases available in `.devloop/archive/` if needed for reference
- **Fresh start**: When context feels heavy (see Step 5c), save state and restart with fresh context
- **Model selection**: See `Skill: model-selection-guide` for choosing haiku/sonnet/opus based on task complexity
