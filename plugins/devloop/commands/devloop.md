---
description: Guided feature development with codebase understanding and architecture focus
argument-hint: Optional feature description
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill", "WebSearch", "WebFetch"]
---

# Devloop - Complete Feature Development Workflow

A comprehensive, token-conscious workflow for feature development from requirements through deployment.

**Phase Details**: Invoke `Skill: phase-templates` for detailed phase guidance.

## Core Principles

- **Ask clarifying questions**: Identify ambiguities and edge cases. Use AskUserQuestion. Wait for answers.
- **Understand before acting**: Read existing code patterns first
- **Read files agents identify**: Build detailed context from agent findings
- **Simple and elegant**: Prioritize readable, maintainable code
- **Use TodoWrite**: Track progress throughout every phase
- **Token conscious**: Use appropriate models (haiku for simple, sonnet for balanced, opus for complex)

---

## Workflow Overview

| Phase | Goal | Model |
|-------|------|-------|
| 0. Triage | Classify task, determine workflow | haiku |
| 1. Discovery | Understand what to build | haiku/sonnet |
| 2. Complexity | Estimate effort, identify risks | haiku |
| 3. Exploration | Deep code understanding | sonnet |
| 4. Clarification | Resolve ambiguities | sonnet |
| 5. Architecture | Design approach | sonnet/opus |
| 6. Planning | Break into tasks | sonnet |
| 7. Implementation | Build the feature | sonnet |
| 8. Testing | Ensure correctness | haiku/sonnet |
| 9. Review | Quality assurance | sonnet/opus |
| 10. Validation | Definition of Done | haiku |
| 11. Integration | Git commit/PR | haiku |
| 12. Summary | Document completion | haiku |

---

## Phase 0: Triage

**Goal**: Classify task and route to optimal workflow

1. Analyze request: $ARGUMENTS
2. Launch workflow-detector agent (haiku) if unclear
3. Route:

| Task Type | Command |
|-----------|---------|
| Simple/clear fix | `/devloop:quick` |
| Unknown feasibility | `/devloop:spike` |
| Code review | `/devloop:review` |
| Ready to commit | `/devloop:ship` |
| New feature | Continue below |

---

## Phase 1: Discovery

**Goal**: Understand what needs to be built

1. Create todo list with all workflow phases
2. If vague/complex: Launch requirements-gatherer agent (sonnet)
3. If clear: Confirm understanding with AskUserQuestion

See `Skill: phase-templates` → Discovery Phase for details.

---

## Phase 2: Complexity Assessment

**Goal**: Estimate effort and identify risks

1. Launch complexity-estimator agent (haiku, plan mode)
2. If L/XL complexity or high uncertainty:
   - Offer spike option: `/devloop:spike`
   - Or reduce scope

Reference: `Skill: complexity-estimation`

---

## Phase 3: Exploration

**Goal**: Deep understanding of existing code

1. Launch 2-3 code-explorer agents in parallel (sonnet)
2. Each returns 5-10 key files
3. **Read all identified files**
4. Present summary of findings

See `Skill: phase-templates` → Exploration Phase for details.

---

## Phase 4: Clarification

**Goal**: Resolve all ambiguities before designing

**CRITICAL**: Do not skip this phase

1. Review findings and requirements
2. Identify underspecified aspects
3. **Use AskUserQuestion** for all clarifications (up to 4 per call)
4. **Wait for all answers before proceeding**

---

## Phase 5: Architecture

**Goal**: Design implementation with trade-offs

1. Invoke: `Skill: architecture-patterns`
2. Invoke language skill: `Skill: go-patterns`, `Skill: react-patterns`, etc.
3. Launch 2-3 code-architect agents:
   - **Minimal**: Smallest change, max reuse
   - **Clean**: Best architecture
   - **Pragmatic**: Speed/quality balance
4. Present comparison with AskUserQuestion

See `Skill: phase-templates` → Architecture Phase for details.

---

## Phase 6: Planning

**Goal**: Break architecture into actionable tasks

1. Launch task-planner agent (sonnet)
2. Write tasks to TodoWrite
3. **Save plan** to `.devloop/plan.md`
4. **Initialize worklog** at `.devloop/worklog.md` if needed
5. Present plan for approval

References:
- `Skill: phase-templates` → Planning Phase
- `Skill: plan-management` for plan format
- `Skill: worklog-management` for worklog format

---

## Phase 7: Implementation

**Goal**: Build the feature

**DO NOT START WITHOUT USER APPROVAL**

1. Check for parallel tasks (`[parallel:X]` markers)
2. Read relevant files from exploration
3. Implement following chosen architecture
4. Update todos and plan markers as you progress

Domain skills:
- `Skill: frontend-design:frontend-design`
- `Skill: api-design`
- `Skill: database-patterns`

See `Skill: phase-templates` → Implementation Phase for parallel execution details.

---

## Phase 8: Testing

**Goal**: Ensure code works correctly

1. Launch test-generator agent (haiku) if needed
2. Launch test-runner agent (haiku)
3. Handle failures with AskUserQuestion

Reference: `Skill: testing-strategies`

---

## Phase 9: Review

**Goal**: Quality assurance and code review

1. Launch code-reviewer agents in parallel (correctness, quality, conventions)
2. Launch security-scanner agent (haiku)
3. Consolidate findings by severity
4. Present results for action

---

## Phase 10: Validation (DoD)

**Goal**: Verify all completion criteria met

1. Launch dod-validator agent (haiku)
2. Check `.devloop/local.md` for project-specific DoD
3. Handle failures with AskUserQuestion

See `Skill: phase-templates` → Validation Phase for checklist.

---

## Phase 11: Integration (Git)

**Goal**: Commit changes, create PR if needed

1. Launch git-manager agent (haiku)
2. If PR requested: Generate description, create via `gh pr create`

Reference: `Skill: git-workflows`

---

## Phase 12: Summary

**Goal**: Document completion and handoff

1. Launch summary-generator agent (haiku)
2. Mark all todos complete
3. Present summary
4. Suggest follow-up actions

---

## Available Skills

**Architecture & Design:**
- `Skill: architecture-patterns`, `Skill: api-design`, `Skill: database-patterns`

**Language-Specific:**
- `Skill: go-patterns`, `Skill: react-patterns`, `Skill: java-patterns`, `Skill: python-patterns`

**Quality & Testing:**
- `Skill: testing-strategies`, `Skill: security-checklist`, `Skill: deployment-readiness`

**Workflow:**
- `Skill: phase-templates` - Detailed phase guidance
- `Skill: workflow-selection`, `Skill: model-selection-guide`, `Skill: complexity-estimation`
- `Skill: requirements-patterns`, `Skill: git-workflows`

**UI/Frontend:**
- `Skill: frontend-design:frontend-design`

---

## Related Commands

| Command | Use When |
|---------|----------|
| `/devloop:quick` | Small, well-defined tasks |
| `/devloop:spike` | Need to explore feasibility first |
| `/devloop:review` | Review existing code/PR |
| `/devloop:ship` | Ready to commit/PR |
| `/devloop:continue` | Resume from existing plan |
| `/devloop:bug` | Report a bug |
| `/devloop:issues` | Manage all issues |

---

## Plan & Issue Management

- Plans: `.devloop/plan.md` → `Skill: plan-management`
- Worklog: `.devloop/worklog.md` → `Skill: worklog-management`
- Issues: `.devloop/issues/` → `Skill: issue-tracking`
