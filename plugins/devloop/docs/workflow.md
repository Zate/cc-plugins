# Devloop Workflow Reference

Complete documentation for the 12-phase feature development workflow.

---

## Overview

The devloop workflow mirrors how senior engineers approach complex features. Each phase exists for a specific reason, and skipping phases often leads to rework.

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  0. Triage  │────▶│ 1. Discovery│────▶│ 2. Estimate │
└─────────────┘     └─────────────┘     └─────────────┘
                                              │
┌─────────────┐     ┌─────────────┐     ┌─────▼───────┐
│ 5. Architect│◀────│4. Clarify   │◀────│ 3. Explore  │
└──────┬──────┘     └─────────────┘     └─────────────┘
       │
┌──────▼──────┐     ┌─────────────┐     ┌─────────────┐
│  6. Plan    │────▶│ 7. Implement│────▶│  8. Test    │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                              │
┌─────────────┐     ┌─────────────┐     ┌─────▼───────┐
│ 11. Git     │◀────│10. Validate │◀────│  9. Review  │
└──────┬──────┘     └─────────────┘     └─────────────┘
       │
       ▼
┌─────────────┐
│ 12. Summary │
└─────────────┘
```

---

## Phase 0: Triage

**Goal**: Classify the task and determine optimal workflow

**Model**: haiku

**Actions**:
1. Analyze the initial request
2. Launch workflow-detector agent if task type unclear
3. Determine workflow path:

| Task Type | Workflow | Use Command |
|-----------|----------|-------------|
| Simple/clear fix | Quick | `/devloop:quick` |
| Unknown feasibility | Spike | `/devloop:spike` |
| Code review | Review | `/devloop:review` |
| Ready to commit | Ship | `/devloop:ship` |
| New feature | Full workflow | Continue below |

**Why This Matters**: Routing to the right workflow saves significant time. A simple bug fix doesn't need 12 phases.

---

## Phase 1: Discovery

**Goal**: Understand what needs to be built

**Model**: haiku/sonnet

**Actions**:
1. Create todo list with all workflow phases
2. If feature is vague or complex, launch `requirements-gatherer` agent:
   - Gather user stories with acceptance criteria
   - Define scope boundaries (in/out)
   - Identify edge cases and error scenarios
   - Document non-functional requirements
3. If requirements are clear, confirm understanding with user

**Outputs**:
- Clear feature requirements
- Scope boundaries defined
- Edge cases identified

**Why This Matters**: Vague requirements lead to wrong implementations. Taking time here prevents rework later.

---

## Phase 2: Complexity Assessment

**Goal**: Estimate effort and identify risks early

**Model**: haiku

**Actions**:
1. Launch `complexity-estimator` agent:
   - Analyze codebase impact
   - Score complexity factors (1-5 each)
   - Generate T-shirt size (XS/S/M/L/XL)
   - Identify risks and dependencies
2. If complexity is L or XL, recommend a spike

**Outputs**:
- T-shirt size estimate
- Risk assessment
- Dependency list
- Spike recommendation if needed

**Skill Used**: `complexity-estimation`

**Why This Matters**: Complex features benefit from exploration before commitment. Better to discover issues early.

---

## Phase 3: Exploration

**Goal**: Deep understanding of existing code and patterns

**Model**: sonnet

**Actions**:
1. Launch 2-3 `code-explorer` agents in parallel:
   - Agent 1: Find similar features, trace implementation patterns
   - Agent 2: Map architecture and abstractions for the feature area
   - Agent 3: Identify integration points, testing approaches
2. Each agent returns 5-10 key files to read
3. Read all identified files to build deep understanding
4. Present comprehensive summary of findings

**Outputs**:
- Similar feature implementations found
- Architecture patterns identified
- Integration points mapped
- Key files list

**Why This Matters**: Understanding existing patterns ensures new code fits naturally. Ignoring this leads to inconsistent implementations.

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
3. Ask clarifying questions using AskUserQuestion
4. Wait for all answers before proceeding

**Outputs**:
- All ambiguities resolved
- Design constraints clarified
- User preferences documented

**Why This Matters**: Assumptions made here ripple through the entire implementation. Questions now prevent confusion later.

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
3. Launch 2-3 `code-architect` agents in parallel:
   - **Minimal**: Smallest change, maximum reuse
   - **Clean**: Best architecture, maintainability
   - **Pragmatic**: Balance of speed and quality
4. Review approaches and form recommendation
5. Present comparison to user for decision

**Outputs**:
- Architecture blueprint
- Component design
- Data flow diagram
- File modification list

**Why This Matters**: Architecture decisions are hard to change. Getting this right enables smooth implementation.

---

## Phase 6: Planning

**Goal**: Break architecture into actionable tasks

**Model**: sonnet

**Actions**:
1. Launch `task-planner` agent:
   - Create ordered task list with dependencies
   - Define acceptance criteria per task
   - Specify test requirements per task
   - Group into phases/milestones
2. Write all tasks to TodoWrite
3. Save plan to `.claude/devloop-plan.md`
4. Present plan for approval

**Plan File Format**:
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

## Progress Log
- [Date]: Plan created
```

**Skill Used**: `testing-strategies`

**Why This Matters**: Clear tasks with acceptance criteria keep implementation focused. The plan file enables resumption via `/devloop:continue`.

---

## Phase 7: Implementation

**Goal**: Build the feature

**DO NOT START WITHOUT USER APPROVAL**

**Model**: sonnet

**Actions**:
1. Wait for explicit user approval
2. Read all relevant files from exploration phase
3. Implement following chosen architecture:
   - Follow codebase conventions (check CLAUDE.md)
   - Write clean, well-documented code
   - Update todos as you progress
4. Apply language/domain skills as needed

**Skills Available**:
- `frontend-design:frontend-design` - Frontend work
- `api-design` - API design
- `database-patterns` - Database work

**Why This Matters**: Implementation with clear architecture and tasks is dramatically more efficient than ad-hoc coding.

---

## Phase 8: Testing

**Goal**: Ensure code works correctly

**Model**: sonnet

**Actions**:
1. Launch `test-generator` agent if tests needed:
   - Generate unit tests following project patterns
   - Generate integration tests for key flows
2. Launch `test-runner` agent:
   - Execute test suite
   - Parse and analyze results
   - Identify failing tests
3. If tests fail, present options to user

**Skill Used**: `testing-strategies`

**Why This Matters**: Tests catch bugs before users do. Testing here prevents production issues.

---

## Phase 9: Review

**Goal**: Quality assurance and code review

**Model**: sonnet (opus for critical code)

**Actions**:
1. Launch `code-reviewer` agents in parallel:
   - Focus: Correctness, bugs, logic errors
   - Focus: Code quality, DRY, readability
   - Focus: Project conventions, abstractions
2. Launch `security-scanner` agent:
   - OWASP Top 10 checks
   - Hardcoded secrets detection
   - Injection vulnerability patterns
3. Consolidate findings by severity
4. Present results to user

**Agents Used**:
- `code-reviewer` (sonnet)
- `security-scanner` (haiku)

**Why This Matters**: Fresh eyes catch issues the implementer missed. Review prevents technical debt.

---

## Phase 10: Validation (Definition of Done)

**Goal**: Verify all completion criteria are met

**Model**: haiku

**Actions**:
1. Launch `dod-validator` agent:
   - Code criteria: Tasks done, conventions followed, no TODOs
   - Test criteria: Tests exist and pass
   - Quality criteria: Review passed, no critical issues
   - Documentation criteria: Docs updated as needed
   - Integration criteria: Ready for commit
2. Check for project-specific DoD in `.claude/devloop.local.md`
3. Present validation results

**Agent Used**: `dod-validator` (haiku)

**Why This Matters**: Definition of Done ensures consistent quality. This prevents shipping incomplete work.

---

## Phase 11: Integration (Git)

**Goal**: Commit changes and create PR if needed

**Model**: haiku

**Actions**:
1. Launch `git-manager` agent:
   - Stage appropriate files
   - Generate conventional commit message
   - Create commit
2. If PR requested:
   - Generate PR description
   - Create PR via `gh pr create`
   - Return PR URL

**Agent Used**: `git-manager` (haiku)

**Skill Used**: `git-workflows`

**Why This Matters**: Clean commits with conventional messages make history readable. PRs enable team review.

---

## Phase 12: Summary

**Goal**: Document completion and handoff

**Model**: haiku

**Actions**:
1. Launch `summary-generator` agent:
   - Document what was built
   - Record key decisions made
   - List files modified
   - Note any follow-up items
2. Mark all todos complete
3. Present summary to user
4. Suggest follow-up actions if needed

**Agent Used**: `summary-generator` (haiku)

**Why This Matters**: Summaries enable handoff to teammates and provide context for future work.

---

## Model Selection Summary

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
| 8. Testing | sonnet | Pattern recognition |
| 9. Review | sonnet/opus | Must catch subtle bugs |
| 10. Validation | haiku | Checklist verification |
| 11. Integration | haiku | Git ops are formulaic |
| 12. Summary | haiku | Simple documentation |

**Overall Strategy**: 20% opus, 60% sonnet, 20% haiku

---

## Phase Shortcuts

Not every task needs all 12 phases:

| Scenario | Skip To |
|----------|---------|
| Requirements clear, small scope | Phase 3 (Exploration) |
| Architecture obvious | Phase 6 (Planning) |
| Single file change | Phase 7 (Implementation) |
| Code already written | Phase 8 (Testing) |
| Tests passing | Phase 9 (Review) |
| Review complete | Phase 10 (Validation) |

Use `/devloop:quick` for small, well-defined tasks that can skip most phases.

---

## Workflow Alternatives

| Command | When to Use |
|---------|-------------|
| `/devloop` | New features, complex changes |
| `/devloop:quick` | Small, well-defined tasks |
| `/devloop:spike` | Unknown feasibility |
| `/devloop:review` | Review existing code/PR |
| `/devloop:ship` | Ready to commit/PR |
| `/devloop:continue` | Resume from existing plan |

---

## See Also

- [Commands Documentation](commands.md) - All 9 slash commands
- [Agents Documentation](agents.md) - All 16 agents
- [Skills Documentation](skills.md) - All 17 skills
- [Configuration Documentation](configuration.md) - Setup and environment
