---
name: phase-templates
description: Reusable phase definitions for devloop workflows. Provides standardized patterns for discovery, implementation, review, and handoff phases. Commands reference these templates instead of duplicating content.
---

# Phase Templates

Standardized phase definitions for devloop workflows. Commands invoke this skill to get phase details instead of duplicating content.

## When to Use This Skill

- **Commands**: Reference these templates in devloop commands to reduce duplication
- **Agents**: Use for consistent phase execution patterns
- **Plan execution**: When continuing from a plan that references standard phases

## When NOT to Use This Skill

- **Direct user queries**: Users should run `/devloop` or `/devloop:continue` instead
- **Non-devloop workflows**: For other plugin workflows, define custom phases

---

## Discovery Phase

**Goal**: Understand what needs to be built
**Model**: haiku/sonnet

### Actions

1. **Requirements gathering** (if feature is vague):
   - Launch devloop:task-planner agent in requirements mode (sonnet)
   - Gather user stories with acceptance criteria
   - Define scope boundaries (in/out)
   - Identify edge cases and error scenarios

2. **Requirements confirmation** (if requirements are clear):
   ```
   Use AskUserQuestion:
   - question: "Is this understanding correct? [summary]"
   - header: "Confirm"
   - options:
     - Yes, proceed (Continue to exploration)
     - Adjust (Let me clarify some points)
     - More detail needed (Launch task-planner in requirements mode)
   ```

### Outputs
- User stories with acceptance criteria
- Scope definition (in/out)
- Edge cases identified

---

## Exploration Phase

**Goal**: Deep understanding of existing code and patterns
**Model**: sonnet

### Actions

1. Launch 2-3 devloop:engineer agents in explore mode in parallel:
   - Agent 1: Find similar features, trace implementation patterns
   - Agent 2: Map architecture and abstractions
   - Agent 3: Identify integration points and testing approaches

2. Each agent returns 5-10 key files to read
3. **Read all identified files** to build deep understanding
4. Present comprehensive summary of findings

### Outputs
- Key files identified for the feature area
- Existing patterns documented
- Integration points mapped

---

## Architecture Phase

**Goal**: Design implementation approach with trade-offs
**Model**: sonnet (opus for complex/high-stakes)

### Actions

1. Invoke relevant skills:
   - `Skill: architecture-patterns`
   - Language-specific: `Skill: go-patterns`, `Skill: react-patterns`, etc.

2. Launch 2-3 devloop:engineer agents in architect mode in parallel:
   - **Minimal**: Smallest change, maximum reuse
   - **Clean**: Best architecture, maintainability
   - **Pragmatic**: Balance of speed and quality

3. Present comparison:
   ```
   Use AskUserQuestion:
   - question: "Which architecture approach?"
   - header: "Approach"
   - options:
     - Minimal (Recommended) (Fast, low risk, extends existing patterns)
     - Clean architecture (Better long-term, more work)
     - Pragmatic balance (Middle ground)
   ```

### Outputs
- Chosen architecture approach
- Files to create/modify
- Key design decisions documented

---

## Planning Phase

**Goal**: Break architecture into actionable tasks
**Model**: sonnet

### Actions

1. Launch devloop:task-planner agent:
   - Create ordered task list with dependencies
   - Define acceptance criteria per task
   - Specify test requirements
   - Group into phases/milestones

2. Write tasks to TodoWrite

3. Save plan to `.devloop/plan.md`:
   ```markdown
   # Devloop Plan: [Feature Name]

   **Created**: [Date]
   **Updated**: [Date]
   **Status**: Active
   **Current Phase**: Implementation

   ## Overview
   [Feature description]

   ## Architecture
   [Chosen approach]

   ## Tasks

   ### Phase 1: [Name]
   - [ ] Task 1.1: [Description]
     - Acceptance: [Criteria]
     - Files: [Expected files]
   ...

   ## Progress Log
   - [Date]: Plan created
   ```

4. Present plan for approval:
   ```
   Use AskUserQuestion:
   - question: "Implementation plan ready ([N] tasks). Proceed?"
   - header: "Plan"
   - options:
     - Start implementation
     - Review plan
     - Save and stop
   ```

### Outputs
- Plan file at `.devloop/plan.md`
- Tasks in TodoWrite
- Worklog initialized if needed

---

## Implementation Phase

**Goal**: Build the feature
**Model**: sonnet

### Prerequisites
- User approval required before starting
- Plan exists at `.devloop/plan.md`

### Actions

1. **Check for parallel tasks**:
   - Look for `[parallel:X]` markers in plan
   - Respect `[depends:N.M]` dependencies

2. If parallel tasks found:
   ```
   Use AskUserQuestion:
   - question: "Tasks [list] can run in parallel. Execute together?"
   - header: "Parallel"
   - options:
     - Run parallel (Recommended)
     - Run sequential
   ```

3. **Execute tasks**:
   - Follow chosen architecture
   - Match codebase conventions
   - Update todos as you progress
   - Mark plan tasks complete

4. Invoke domain skills as needed:
   - `Skill: frontend-design:frontend-design`
   - `Skill: api-design`
   - `Skill: database-patterns`

### Outputs
- Feature implemented
- Plan updated with progress
- Tests written (if included in tasks)

---

## Testing Phase

**Goal**: Ensure code works correctly
**Model**: haiku/sonnet

### Actions

1. Launch devloop:qa-engineer agent in generator mode (haiku) if tests needed:
   - Generate unit tests following project patterns
   - Generate integration tests for key flows
   - Follow: `Skill: testing-strategies`

2. Launch devloop:qa-engineer agent in runner mode (haiku):
   - Execute test suite
   - Parse and analyze results

3. If tests fail:
   ```
   Use AskUserQuestion:
   - question: "Tests found [N] failures. How to proceed?"
   - header: "Tests"
   - options:
     - Fix all
     - Review each
     - Skip
   ```

### Outputs
- Tests written and passing
- Coverage report (if available)

---

## Review Phase

**Goal**: Quality assurance and code review
**Model**: sonnet (opus for critical code)

### Actions

1. Launch devloop:code-reviewer agents in parallel:
   - Focus: Correctness, bugs, logic errors
   - Focus: Code quality, DRY, readability
   - Focus: Project conventions

2. Launch devloop:security-scanner agent (haiku):
   - OWASP Top 10 checks
   - Hardcoded secrets detection
   - Injection vulnerabilities

3. Consolidate findings by severity

4. Present results:
   ```
   Use AskUserQuestion:
   - question: "Review found [N] issues. How to proceed?"
   - header: "Review"
   - options:
     - Fix all
     - Critical only
     - Acknowledge
   ```

### Outputs
- Issues identified and categorized
- Fixes applied (if chosen)
- Security scan results

---

## Validation Phase (Definition of Done)

**Goal**: Verify all completion criteria are met
**Model**: haiku

### Actions

1. Launch devloop:task-planner agent in DoD validator mode:
   - Code criteria: Tasks done, conventions followed
   - Test criteria: Tests exist and pass
   - Quality criteria: Review passed
   - Documentation criteria: Docs updated
   - Integration criteria: Ready for commit

2. Check `.devloop/local.md` for project-specific DoD

3. If validation fails:
   ```
   Use AskUserQuestion:
   - question: "DoD validation: [status]. Proceed?"
   - header: "DoD"
   - options:
     - Fix blockers
     - Override (document exceptions)
     - Review details
   ```

### Outputs
- DoD checklist completed
- Blockers resolved or documented

---

## Integration Phase (Git)

**Goal**: Commit changes and create PR
**Model**: haiku

### Actions

1. Launch devloop:engineer agent in git mode:
   - Stage appropriate files
   - Generate conventional commit message
   - Create commit

2. If PR requested:
   - Generate PR description
   - Create PR via `gh pr create`
   - Return PR URL

3. Reference: `Skill: git-workflows`

### Outputs
- Commit(s) created
- PR created (if requested)

---

## Summary Phase

**Goal**: Document completion and handoff
**Model**: haiku

### Actions

1. Launch devloop:summary-generator agent:
   - Document what was built
   - Record key decisions
   - List files modified
   - Note follow-up items

2. Update plan status to Complete
3. Update worklog with completion entry
4. Mark all todos complete

### Outputs
- Summary documentation
- Plan marked complete
- Worklog updated

---

## Task Checkpoint Template

Use after completing any task. Reference: `Skill: task-checkpoint`

### Verification Checklist
- [ ] Code implements task requirements
- [ ] No placeholder code or TODOs incomplete
- [ ] Tests pass (if applicable)
- [ ] Error handling in place

### Plan Update (Required)
- [ ] Mark task complete: `- [ ]` → `- [x]`
- [ ] Add Progress Log entry
- [ ] Update timestamp

### Commit Decision
```
Use AskUserQuestion:
- question: "Task complete. How to handle commit?"
- header: "Commit"
- options:
  - Commit now (Task is self-contained)
  - Group with next (Tasks are related)
  - Review changes
```

---

## Phase Completion Checkpoint

Use when all tasks in a phase are complete.

### Verification
- [ ] All phase tasks marked complete
- [ ] Tests pass
- [ ] No uncommitted grouped changes

### Actions
1. Commit any pending grouped work
2. Update `**Current Phase**:` in plan
3. Add phase completion to Progress Log

---

## Recovery Templates

### Plan Out of Sync
```
Use AskUserQuestion:
- question: "Plan may be out of sync. How to proceed?"
- header: "Recovery"
- options:
  - Backfill entries
  - Continue anyway
  - Review tasks
```

### Uncommitted Changes
```
Use AskUserQuestion:
- question: "Uncommitted changes detected. How to proceed?"
- header: "Uncommitted"
- options:
  - Commit now
  - Discard changes
  - Continue
```

---

## Model Selection Reference

| Phase | Model | Rationale |
|-------|-------|-----------|
| Discovery | haiku/sonnet | Depends on complexity |
| Exploration | sonnet | Need deep understanding |
| Architecture | sonnet/opus | Depends on stakes |
| Planning | sonnet | Task breakdown needs context |
| Implementation | sonnet | Balanced capability |
| Testing | haiku | Formulaic patterns |
| Review | sonnet/opus | Must catch subtle bugs |
| Validation | haiku | Checklist verification |
| Integration | haiku | Git ops are formulaic |
| Summary | haiku | Simple documentation |

For detailed guidance: `Skill: model-selection-guide`

---

## See Also

- `Skill: plan-management` - Plan file format and procedures
- `Skill: task-checkpoint` - Task completion checklist
- `Skill: worklog-management` - Completed work history
- `Skill: model-selection-guide` - Model selection guidance
