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

**Task status markers:**
- `[x]` / `[X]` - Completed
- `[ ]` - Pending
- `[parallel:X]` - Can run in parallel with same marker
- `[depends:N.M]` - Depends on another task

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
```

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

## Step 6: Post-Task Checkpoint

After agent completes:

1. **Update plan**: Mark task `[x]`, add Progress Log entry
2. **Present results**: Summarize what was done
3. **Decide on commit**:
   ```
   AskUserQuestion:
   - question: "Task complete. Commit now?"
   - header: "Commit"
   - options:
     - Commit now (Recommended) → Launch devloop:engineer (git mode)
     - Group with next task
     - Review changes first
   ```

4. **Continue or stop**:
   ```
   AskUserQuestion:
   - question: "Continue to next task?"
   - header: "Next"
   - options:
     - Continue (Recommended)
     - Stop here
     - Review plan status
   ```

---

## Step 7: Handle Parallel Tasks

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

## Plan Mode Integration

If user selects "Update the plan first" or needs to create a new plan:

1. Use `EnterPlanMode` to design the approach
2. **CRITICAL**: When exiting plan mode, save the plan to `.devloop/plan.md`
3. The plan MUST follow devloop format (see `Skill: plan-management`)
4. Resume with `/devloop:continue` after plan is saved

---

## Recovery Scenarios

| Scenario | Detection | Action |
|----------|-----------|--------|
| No plan | `.devloop/plan.md` missing | Offer /devloop or EnterPlanMode |
| Plan complete | All tasks `[x]` | Congratulate, suggest /devloop:ship |
| Stale plan | Updated > 24h ago | Offer to refresh |
| Uncommitted work | git status shows changes | Offer devloop:engineer (git) |
| Failed tests | Previous run failed | Offer devloop:qa-engineer (runner) |

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
