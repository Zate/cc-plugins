---
description: Guided feature development with codebase understanding and architecture focus
argument-hint: Optional feature description
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill", "WebSearch", "WebFetch"]
---

# Devloop - Complete Feature Development Workflow

A comprehensive, token-conscious workflow for feature development from requirements through deployment.

## Core Principles

- **Ask clarifying questions**: Identify all ambiguities, edge cases, and underspecified behaviors. Use AskUserQuestion for structured decisions. Wait for answers before proceeding.
- **Understand before acting**: Read and comprehend existing code patterns first
- **Read files identified by agents**: After agents complete, read the key files they identify to build detailed context
- **Simple and elegant**: Prioritize readable, maintainable, architecturally sound code
- **Use TodoWrite**: Track all progress throughout every phase
- **Token conscious**: Use appropriate models for each task (haiku for simple, sonnet for balanced, opus for complex)

## Environment Context

The SessionStart hook sets these environment variables:
- `$FEATURE_DEV_PROJECT_LANGUAGE` - Detected language (go, typescript, java, python, etc.)
- `$FEATURE_DEV_FRAMEWORK` - Detected framework (react, vue, spring, etc.)
- `$FEATURE_DEV_TEST_FRAMEWORK` - Detected test framework (jest, go-test, junit, pytest, etc.)

---

## Phase 0: Triage

**Goal**: Classify the task and determine optimal workflow

**Model**: haiku

**Actions**:
1. Analyze the initial request: $ARGUMENTS
2. Launch workflow-detector agent (haiku) if task type unclear
3. Determine workflow path:

   | Task Type | Workflow | Use Command |
   |-----------|----------|-------------|
   | Simple/clear fix | Quick | `/devloop:quick` |
   | Unknown feasibility | Spike | `/devloop:spike` |
   | Code review | Review | `/devloop:review` |
   | Ready to commit | Ship | `/devloop:ship` |
   | New feature | Full workflow | Continue below |

4. For guidance: `Skill: workflow-selection`

---

## Phase 1: Discovery

**Goal**: Understand what needs to be built

**Model**: haiku/sonnet

**Actions**:
1. Create todo list with all workflow phases
2. If feature is vague or complex, launch requirements-gatherer agent (sonnet):
   - Gather user stories with acceptance criteria
   - Define scope boundaries (in/out)
   - Identify edge cases and error scenarios
   - Document non-functional requirements

3. If requirements are clear, summarize understanding:
   ```
   Use AskUserQuestion:
   - question: "Is this understanding correct? [summary of feature]"
   - header: "Confirm"
   - options:
     - Yes, proceed (Continue to exploration)
     - Adjust (Let me clarify some points)
     - More detail needed (Launch requirements-gatherer)
   ```

---

## Phase 2: Complexity Assessment

**Goal**: Estimate effort and identify risks early

**Model**: haiku

**Actions**:
1. Launch complexity-estimator agent (haiku, plan mode):
   - Analyze codebase impact
   - Score complexity factors (1-5 each)
   - Generate T-shirt size (XS/S/M/L/XL)
   - Identify risks and dependencies

2. If complexity is L or XL, or uncertainty is high:
   ```
   Use AskUserQuestion:
   - question: "This appears complex (size: [X]). Should we do a spike first?"
   - header: "Complexity"
   - options:
     - Do spike (Explore feasibility with /devloop:spike)
     - Proceed anyway (Accept complexity and continue)
     - Reduce scope (Let's simplify the requirements)
   ```

3. For guidance: `Skill: complexity-estimation`

---

## Phase 3: Exploration

**Goal**: Deep understanding of existing code and patterns

**Model**: sonnet

**Actions**:
1. Launch 2-3 code-explorer agents in parallel (sonnet):
   - Agent 1: Find similar features, trace implementation patterns
   - Agent 2: Map architecture and abstractions for the feature area
   - Agent 3: Identify integration points, testing approaches, extension patterns

2. Each agent should return 5-10 key files to read
3. **Read all identified files** to build deep understanding
4. Present comprehensive summary of findings

---

## Phase 4: Clarification

**Goal**: Resolve all ambiguities before designing

**CRITICAL**: Do not skip this phase

**Model**: sonnet

**Actions**:
1. Review codebase findings and requirements
2. Identify underspecified aspects:
   - Edge cases and error handling
   - Integration points and data flow
   - Scope boundaries and backward compatibility
   - Design preferences and performance needs

3. **Use AskUserQuestion** for all clarifying questions (up to 4 per call):
   ```
   Use AskUserQuestion:
   - question: "How should we handle [edge case]?"
   - header: "Edge Cases"
   - options: [Approach A, Approach B, ...]
   - multiSelect: false
   ```

4. **Wait for all answers before proceeding**

---

## Phase 5: Architecture

**Goal**: Design implementation approach with trade-offs

**Model**: sonnet (opus for complex/high-stakes)

**Actions**:
1. Invoke architecture skill: `Skill: architecture-patterns`
2. Invoke language-specific skill if applicable:
   - `Skill: go-patterns`
   - `Skill: react-patterns`
   - `Skill: java-patterns`
   - `Skill: python-patterns`

3. Launch 2-3 code-architect agents in parallel:
   - **Minimal**: Smallest change, maximum reuse
   - **Clean**: Best architecture, maintainability
   - **Pragmatic**: Balance of speed and quality

4. Review approaches and form recommendation
5. Present comparison with AskUserQuestion:
   ```
   Use AskUserQuestion:
   - question: "Which architecture approach?"
   - header: "Approach"
   - options:
     - Minimal (Recommended) (Fast, low risk, extends existing patterns)
     - Clean architecture (Better long-term, more work)
     - Pragmatic balance (Middle ground)
   ```

---

## Phase 6: Planning

**Goal**: Break architecture into actionable tasks

**Model**: sonnet

**Actions**:
1. Launch task-planner agent (sonnet):
   - Create ordered task list with dependencies
   - Define acceptance criteria per task
   - Specify test requirements per task
   - Estimate complexity per task
   - Group into phases/milestones

2. Write all tasks to TodoWrite

3. **Save plan to project** for later resumption with `/devloop:continue`:
   ```bash
   mkdir -p .claude
   ```
   Write plan to `.claude/devloop-plan.md` with format:
   ```markdown
   # Devloop Plan: [Feature Name]

   **Created**: [Date]
   **Status**: In Progress
   **Current Phase**: Planning

   ## Overview
   [Feature description from requirements]

   ## Architecture
   [Chosen approach summary]

   ## Tasks

   ### Phase 1: [Phase Name]
   - [ ] Task 1.1: [Description]
     - Acceptance: [Criteria]
     - Files: [Expected files]
   - [ ] Task 1.2: [Description]
     ...

   ### Phase 2: [Phase Name]
   ...

   ## Progress Log
   - [Date]: Plan created
   ```

4. **Initialize worklog** if it doesn't exist:
   Create `.claude/devloop-worklog.md`:
   ```markdown
   # Devloop Worklog

   **Project**: [project-name]
   **Last Updated**: [Date]

   ---

   ## [Feature Name] (In Progress)

   **Started**: [Date]
   **Plan**: .claude/devloop-plan.md

   ### Commits

   | Hash | Date | Message | Tasks |
   |------|------|---------|-------|

   ### Tasks Completed

   (None yet - entries added as tasks are committed)
   ```

   For worklog format details: `Skill: worklog-management`

5. Invoke: `Skill: testing-strategies` for test planning

6. Present plan for approval:
   ```
   Use AskUserQuestion:
   - question: "Implementation plan ready ([N] tasks). Proceed?"
   - header: "Plan"
   - options:
     - Start implementation (Begin Phase 7)
     - Review plan (Show detailed breakdown)
     - Adjust (Modify the plan)
     - Save and stop (Save plan for later with /devloop:continue)
   ```

---

## Phase 7: Implementation

**Goal**: Build the feature

**DO NOT START WITHOUT USER APPROVAL**

**Model**: sonnet

**Actions**:
1. Wait for explicit user approval

2. **Check for parallel task opportunities** in the plan:
   - Read `.claude/devloop-plan.md` to find tasks with `[parallel:X]` markers
   - Group tasks by their parallel marker letter
   - Check for `[depends:N.M]` markers to respect dependencies

   **If parallel tasks found:**
   ```
   Use AskUserQuestion:
   - question: "Tasks [list] can run in parallel (Group [X]). Execute together?"
   - header: "Parallel"
   - options:
     - Run parallel (Spawn agents for independent tasks) (Recommended)
     - Run sequential (Execute one at a time for more control)
     - Pick specific (Let me choose which tasks to parallelize)
   ```

   **If running in parallel:**
   - Spawn implementation agents for each task using `Task` tool with `run_in_background: true`
   - Track progress with `TaskOutput` (poll with `block: false`)
   - Display real-time status to user
   - Wait for all parallel tasks before proceeding to dependent tasks
   - See `Skill: plan-management` for token cost guidelines

3. Read all relevant files from exploration phase

4. Implement following chosen architecture:
   - Follow codebase conventions (check CLAUDE.md)
   - Write clean, well-documented code
   - Update todos as you progress
   - Update plan markers as tasks complete

5. For frontend work: `Skill: frontend-design:frontend-design`
6. For API work: `Skill: api-design`
7. For database work: `Skill: database-patterns`

---

## Phase 8: Testing

**Goal**: Ensure code works correctly

**Model**: haiku/sonnet

**Actions**:
1. Launch test-generator agent (haiku) if tests needed:
   - Generate unit tests following project patterns
   - Generate integration tests for key flows
   - Follow: `Skill: testing-strategies`

2. Launch test-runner agent (haiku):
   - Execute test suite
   - Parse and analyze results
   - Identify failing tests

3. If tests fail:
   ```
   Use AskUserQuestion:
   - question: "Tests found [N] failures. How to proceed?"
   - header: "Tests"
   - options:
     - Fix all (Apply suggested fixes)
     - Review each (Decide per failure)
     - Skip (Proceed without fixing)
   ```

---

## Phase 9: Review

**Goal**: Quality assurance and code review

**Model**: sonnet (opus for critical code)

**Actions**:
1. Launch code-reviewer agents in parallel:
   - Focus: Correctness, bugs, logic errors
   - Focus: Code quality, DRY, readability
   - Focus: Project conventions, abstractions

2. Launch security-scanner agent (haiku, plan mode):
   - OWASP Top 10 checks
   - Hardcoded secrets detection
   - Injection vulnerability patterns

3. Consolidate findings by severity
4. Present results:
   ```
   Use AskUserQuestion:
   - question: "Review found [N] issues. How to proceed?"
   - header: "Review"
   - options:
     - Fix all (Address all issues)
     - Critical only (Fix blockers only)
     - Acknowledge (Proceed with known issues)
   ```

---

## Phase 10: Validation (Definition of Done)

**Goal**: Verify all completion criteria are met

**Model**: haiku

**Actions**:
1. Launch dod-validator agent (haiku):
   - Code criteria: Tasks done, conventions followed, no TODOs
   - Test criteria: Tests exist and pass
   - Quality criteria: Review passed, no critical issues
   - Documentation criteria: Docs updated as needed
   - Integration criteria: Ready for commit

2. Check for project-specific DoD in `.claude/devloop.local.md`
3. If validation fails:
   ```
   Use AskUserQuestion:
   - question: "DoD validation: [status]. Proceed?"
   - header: "DoD"
   - options:
     - Fix blockers (Address failing criteria)
     - Override (Proceed with exceptions documented)
     - Review details (Show specific issues)
   ```

---

## Phase 11: Integration (Git)

**Goal**: Commit changes and create PR if needed

**Model**: haiku

**Actions**:
1. Launch git-manager agent (haiku):
   - Stage appropriate files
   - Generate conventional commit message
   - Create commit

2. If PR requested:
   - Generate PR description
   - Create PR via `gh pr create`
   - Return PR URL

3. For guidance: `Skill: git-workflows`

---

## Phase 12: Summary

**Goal**: Document completion and handoff

**Model**: haiku

**Actions**:
1. Launch summary-generator agent (haiku):
   - Document what was built
   - Record key decisions made
   - List files modified
   - Note any follow-up items

2. Mark all todos complete
3. Present summary to user
4. Suggest follow-up actions if needed

---

## Model Selection Reference

| Phase | Model | Rationale |
|-------|-------|-----------|
| 0. Triage | haiku | Simple classification |
| 1. Discovery | haiku/sonnet | Depends on complexity |
| 2. Complexity | haiku | Scoring is formulaic |
| 3. Exploration | sonnet | Need deep understanding |
| 4. Clarification | sonnet | Context-aware questions |
| 5. Architecture | sonnet/opus | Depends on stakes |
| 6. Planning | sonnet | Task breakdown needs context |
| 7. Implementation | sonnet | Balanced capability |
| 8. Testing | haiku | Formulaic patterns |
| 9. Review | sonnet/opus | Must catch subtle bugs |
| 10. Validation | haiku | Checklist verification |
| 11. Integration | haiku | Git ops are formulaic |
| 12. Summary | haiku | Simple documentation |

For detailed guidance: `Skill: model-selection-guide`

---

## Available Skills

Invoke as needed throughout workflow:

**Architecture & Design:**
- `Skill: architecture-patterns` - Design patterns by language
- `Skill: api-design` - API design best practices
- `Skill: database-patterns` - Database design and optimization

**Language-Specific:**
- `Skill: go-patterns` - Go best practices
- `Skill: react-patterns` - React/TypeScript patterns
- `Skill: java-patterns` - Java/Spring patterns
- `Skill: python-patterns` - Python patterns

**Quality & Testing:**
- `Skill: testing-strategies` - Test design guidance
- `Skill: security-checklist` - Security best practices
- `Skill: deployment-readiness` - Deployment validation

**Workflow:**
- `Skill: workflow-selection` - Choose workflow type
- `Skill: model-selection-guide` - Choose opus/sonnet/haiku
- `Skill: complexity-estimation` - Estimate effort
- `Skill: requirements-patterns` - Requirements gathering
- `Skill: git-workflows` - Git best practices

**UI/Frontend:**
- `Skill: frontend-design:frontend-design` - Frontend design patterns

---

## Quick Reference: Related Commands

| Command | Use When |
|---------|----------|
| `/devloop:quick` | Small, well-defined tasks |
| `/devloop:spike` | Need to explore feasibility first |
| `/devloop:review` | Review existing code/PR |
| `/devloop:ship` | Ready to commit/PR |
| `/devloop:continue` | Resume from an existing plan |
| `/devloop:bug` | Report a bug for later fixing |
| `/devloop:bugs` | View and manage tracked bugs |

---

## Plan Management

All devloop workflows save plans to `.claude/devloop-plan.md`. For plan format details and update procedures, invoke: `Skill: plan-management`

## Bug Tracking

Non-critical issues can be tracked in `.claude/bugs/` for later fixing. Agents can log bugs during review/testing, or use `/devloop:bug` to report manually. For details, invoke: `Skill: bug-tracking`

---
