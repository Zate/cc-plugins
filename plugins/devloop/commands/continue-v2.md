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

## Step 1: Find and Read the Plan

### 1a: Check for Fresh Start State

**CRITICAL**: Check for saved state BEFORE searching for plan file.

If `.devloop/next-action.json` exists:
1. Read and parse state file (contains plan name, phase, summary, next task)
2. Validate state (require `plan` and `summary` fields)
3. Delete state file (single-use)
4. Display fresh start context
5. Set `FRESH_START_MODE=true` and `FRESH_START_NEXT_TASK` for Step 2
6. Continue to Step 1b to read actual plan file

**State file format and parsing details**: See `Skill: workflow-loop` section "State Persistence for Fresh Start"

**If state file missing or invalid**: Skip to Step 1b.

---

### 1b: Search for Plan File

Search in order:
1. **`.devloop/plan.md`** ← Primary (devloop standard)
2. `docs/PLAN.md`, `docs/plan.md`
3. `PLAN.md`, `plan.md`

Also read `.devloop/worklog.md` if it exists to understand completed work.

**Archive Awareness**: Check for `.devloop/archive/` directory. If archives exist, note them for context (may explain missing phases).

**Plan file format, location priority, and discovery rules**: See `Skill: plan-management` section "Plan File Location"

**If no plan found**:
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

## Step 2: Parse and Present Status

Extract from plan file:
- **Plan name**: From header
- **Current phase**: Where we are
- **Completed tasks**: Count of `[x]` items
- **Pending tasks**: Count of `[ ]` items
- **Next task(s)**: First pending item(s) OR from fresh start state
- **Archived phases**: Check Progress Log for archival notes

**Task status markers**: See `Skill: plan-management` section "Task Status Markers" for complete definitions (`[x]` = Completed, `[ ]` = Pending, `[~]` = Partial, `[!]` = Blocked, `[-]` = Skipped, etc.)

**Parallel markers**: See `Skill: plan-management` section "Parallelism Markers" for `[parallel:X]` and `[depends:N.M]` usage.

**Fresh Start Integration**:
- If `FRESH_START_MODE=true` from Step 1a, use `FRESH_START_NEXT_TASK` as the next task
- Display "Resuming from fresh start" indicator
- Skip normal "next task" detection since state provides it

Present status:

**If fresh start mode**:
```markdown
## Plan: [Name] (Fresh Start)

**Progress**: [N]/[Total] tasks complete
**Current Phase**: [Phase name]
**Resuming from**: Fresh start at [timestamp]

### Next Up (from saved state)
- [ ] **Task [N]**: [Description from FRESH_START_NEXT_TASK]

### Remaining
- [ ] Task [N+1]: [Description]
- [ ] Task [N+2]: [Description]
```

**If normal mode**:
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

## Step 3: Classify Next Task and Present Options

Analyze the next task description using classification keywords (see Agent Routing Table above) to determine task type.

Present targeted options:

```yaml
AskUserQuestion:
  question: "Next task: [Task description]. How proceed?"
  header: "Action"
  options:
    - label: "[Primary action based on task type]"
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

---

## Step 4: Execute with Agent

**CRITICAL**: Use the Task tool with explicit `subagent_type` from Agent Routing Table.

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

**Example - Implementation Task**:
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

**For other agent types**: Adapt the prompt mode instruction:
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

**Complete checkpoint workflow**: See `Skill: task-checkpoint` for:
- Verification checklist (success/partial/failure indicators)
- Plan marker updates (`[ ]` → `[x]`, `[~]`, or `[!]`)
- Automatic commit logic (for successful completion only)
- Checkpoint question presentation
- Action handling (continue/fresh/stop/retry)

**Integration for continue.md**:
1. After agent completes, invoke checkpoint verification
2. Based on verification, update plan markers
3. If successful, auto-commit changes BEFORE checkpoint question
4. Present checkpoint question with appropriate options
5. Handle user selection and route to next step

**Key checkpoint patterns**: See `Skill: workflow-loop` section "Checkpoint Phase" for standard loop integration.

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

If next tasks have `[parallel:X]` markers, group tasks by marker letter and present option:

```yaml
AskUserQuestion:
  question: "Tasks A, B, C can run in parallel. Run together?"
  header: "Parallel"
  options:
    - label: "Run all in parallel"
      description: "Execute all tasks together (Recommended)"
    - label: "Run sequentially"
      description: "Execute tasks one by one"
    - label: "Pick specific tasks"
      description: "Select which tasks to run"
```

If parallel, launch multiple Task tools simultaneously with `run_in_background: true`, then use TaskOutput to collect results.

**Parallel task detection and execution patterns**: See `Skill: plan-management` section "Smart Parallelism Guidelines"

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
