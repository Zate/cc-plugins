# Devloop Agents

This document provides comprehensive information about the 16 specialized agents in the devloop plugin.

## Overview

Devloop agents are specialized sub-agents that handle specific aspects of the development workflow. Each agent is optimized with:
- **Specific expertise**: Deep knowledge of their domain
- **Strategic model selection**: Right model (opus/sonnet/haiku) for their task
- **Color coding**: Visual organization by category
- **Focused tools**: Only the tools they need

Agents are invoked automatically by the devloop workflow or can be spawned explicitly using the `Task` tool.

---

## Agent Color Scheme

Agents use color coding for easy visual identification:

| Color | Category | Purpose | Agents |
|-------|----------|---------|--------|
| 🟡 **yellow** | Exploration | Understanding existing code | code-explorer, workflow-detector |
| 🟣 **indigo** | Architecture | Design and planning | code-architect, task-planner |
| 🔴 **red** | Critical Review | Security and quality | code-reviewer, security-scanner |
| 🔵 **cyan** | Testing | Test generation and execution | test-generator, test-runner |
| 🟢 **green** | Validation | Quality gates | qa-agent, dod-validator |
| 🔵 **blue** | Requirements | Clarification and estimation | requirements-gatherer, complexity-estimator |
| 🟠 **orange** | Integration | Git and bug management | git-manager, bug-catcher |
| 🔷 **teal** | Documentation | Docs and summaries | doc-generator, summary-generator |

---

## Core Development Agents

### code-explorer 🟡
**Model**: sonnet | **Color**: yellow

Deep codebase analysis specialist that traces execution paths, maps architecture layers, and documents dependencies.

**When to Use**:
- Understanding how existing features work
- Before modifying unfamiliar code
- Identifying integration points
- Mapping feature boundaries

**When NOT to Use**:
- For implementation work (use code-architect)
- Simple file searches (use Grep/Glob directly)
- Making changes (this agent only analyzes)

**Capabilities**:
- Traces call chains from entry to output
- Maps abstraction layers
- Identifies design patterns
- Documents dependencies and side effects
- Highlights technical debt

**Example Invocation**:
```
User: "How does the payment processing work?"
Assistant: "I'll launch the code-explorer agent to trace the payment flow."
```

**Output**: Complete feature analysis with file references, data flows, and architectural insights.

---

### code-architect 🟣
**Model**: sonnet | **Color**: indigo

Senior software architect that designs feature implementations by analyzing existing patterns and providing actionable blueprints.

**When to Use**:
- Designing new features
- Making architectural decisions
- Deciding where components should live
- Integrating with existing systems

**When NOT to Use**:
- For understanding existing code (use code-explorer)
- After architecture is decided (move to task-planner)
- For implementation (architecture first, implement later)

**Capabilities**:
- Analyzes existing codebase patterns
- Designs complete architecture blueprints
- Specifies files to create/modify
- Provides component responsibilities
- Includes data flow diagrams

**Delegation**:
- Can spawn code-explorer for deeper context
- Invokes language-specific skills (go-patterns, react-patterns, etc.)

**Example Invocation**:
```
User: "I need to add user authentication"
Assistant: "I'll launch the code-architect agent to design the authentication architecture."
```

**Output**: Complete implementation blueprint with specific files, components, and build sequence.

---

### code-reviewer 🔴
**Model**: sonnet/opus | **Color**: red

Expert code reviewer using confidence-based filtering to report only high-priority issues that truly matter.

**When to Use**:
- After implementing features
- Before committing changes
- During PR review
- When quality validation needed

**When NOT to Use**:
- During active implementation (wait until complete)
- For design feedback (use code-architect earlier)
- For trivial changes (trust yourself)

**Capabilities**:
- Project guideline compliance (CLAUDE.md)
- Bug detection (logic errors, null handling, race conditions)
- Code quality assessment
- Language-specific idiom checks (Go, React, Java patterns)
- Only reports issues with ≥80% confidence

**Confidence Scoring**:
- **100%**: Confirmed bug, will happen frequently
- **75-99%**: Highly confident, impacts functionality
- **50-74%**: Moderate confidence (not reported)
- **<50%**: Low confidence (not reported)

**Example Invocation**:
```
Assistant: "I've completed the feature. I'll launch code-reviewer to validate it."
```

**Output**: Categorized issues (Critical/Important) with file references and concrete fixes.

---

### task-planner 🟣
**Model**: sonnet | **Color**: indigo

Technical project planner that breaks down architecture into ordered, actionable tasks with acceptance criteria.

**When to Use**:
- After architecture is approved
- Need ordered implementation tasks
- Want clear acceptance criteria
- Creating project roadmap

**When NOT to Use**:
- Before architecture design
- For quick tasks (use /devloop:quick)
- When continuing existing plan (use /devloop:continue)

**Capabilities**:
- Creates ordered task lists with dependencies
- Defines acceptance criteria per task
- Specifies test requirements
- Groups into phases/milestones
- Saves to `.devloop/plan.md`

**Plan File Management**:
- **MUST** save plans to `.devloop/plan.md`
- Writes to TodoWrite for session tracking
- Includes complexity estimates per task

**Example Invocation**:
```
User: "Ok, let's implement approach 2"
Assistant: "I'll launch task-planner to break this into implementable tasks."
```

**Output**: Complete implementation plan with tasks, phases, and dependency graph.

---

## Testing & Quality Agents

### test-generator 🔵
**Model**: sonnet | **Color**: cyan

Test generation specialist that creates tests following project patterns and frameworks.

**When to Use**:
- New code needs test coverage
- Expanding test suites
- Adding missing tests
- Coverage is insufficient

**When NOT to Use**:
- Tests already exist and pass
- For running tests (use test-runner)
- No code to test yet

**Capabilities**:
- Generates unit, integration, and E2E tests
- Follows project test patterns
- Supports Jest, Go Test, Pytest, JUnit
- Creates test fixtures and mocks
- Follows detected test framework conventions

**User Preferences**:
- Asks about test types (unit/integration/E2E)
- Determines coverage level (essential/comprehensive/exhaustive)
- Decides mocking strategy

**Example Invocation**:
```
User: "Write tests for the UserService"
Assistant: "I'll launch test-generator to create tests following your project patterns."
```

**Output**: Test files matching project conventions with meaningful coverage.

---

### test-runner 🔵
**Model**: sonnet | **Color**: cyan

Test execution specialist that runs tests, analyzes failures, and suggests fixes.

**When to Use**:
- After generating tests
- Validating changes
- Investigating test failures
- Pre-commit validation

**When NOT to Use**:
- No tests exist yet (use test-generator first)
- Tests are known to be broken

**Capabilities**:
- Executes appropriate test framework
- Parses Jest, Go, Pytest, JUnit output
- Analyzes failure root causes
- Provides specific fix suggestions
- Reports coverage metrics

**Bug Tracking Integration**:
- Logs flaky tests as bugs
- Tracks test improvements needed
- Non-blocking issues go to bug tracker

**Example Invocation**:
```
Assistant: "I'll launch test-runner to execute tests and analyze results."
```

**Output**: Test results summary with failure analysis and actionable fixes.

---

### qa-agent 🟢
**Model**: sonnet | **Color**: green

Senior QA engineer ensuring deployment readiness by validating tests, builds, docs, and runtime concerns.

**When to Use**:
- "Is it safe to deploy?"
- Pre-deployment validation
- Production readiness check
- "Will it work in production?"

**When NOT to Use**:
- For checklist compliance (use dod-validator)
- Pre-commit validation (use dod-validator)
- During active implementation

**Capabilities**:
- Understands project architecture (frontend/backend/CLI/library)
- Runs and validates tests
- Verifies builds succeed
- Checks documentation currency
- Identifies deployment blockers

**Project Type Awareness**:
- **Frontend**: Bundle validity, assets, accessibility
- **Backend**: API tests, migrations, health checks
- **Fullstack**: Both frontend + backend validation
- **CLI**: Command help, exit codes, error messages
- **Library**: Public API docs, examples, breaking changes

**Example Invocation**:
```
User: "Is this feature ready to deploy?"
Assistant: "I'll launch qa-agent to validate deployment readiness."
```

**Output**: Deployment readiness report with blockers and recommendations.

---

### dod-validator 🟢
**Model**: haiku | **Color**: green

Quality gate validator ensuring all Definition of Done criteria are met.

**When to Use**:
- "Is the work complete?"
- Pre-commit validation
- "Did we meet all requirements?"
- Before moving to git phase

**When NOT to Use**:
- For deployment checks (use qa-agent)
- During active implementation
- For runtime concerns

**Capabilities**:
- Validates code criteria (no TODOs, conventions followed)
- Checks test criteria (tests exist and pass)
- Verifies quality (review passed, build succeeds)
- Confirms documentation updated
- Checks plan task completion

**Plan Integration**:
- **MUST** read `.devloop/plan.md`
- Validates all tasks marked complete
- Updates plan Status to "Complete" when passing
- Adds Progress Log entries

**Example Invocation**:
```
Assistant: "I'll launch dod-validator to verify all completion criteria are met."
```

**Output**: Category-by-category validation results with blockers and warnings.

---

### security-scanner 🔴
**Model**: haiku | **Color**: red

Security analyst scanning for OWASP Top 10 vulnerabilities, secrets, and injection risks.

**When to Use**:
- Code handles user input
- Security-sensitive code areas
- Before deployment
- During code review

**When NOT to Use**:
- During active development (wait for review phase)
- On third-party code (out of scope)
- As primary bug detection (use code-reviewer)

**Capabilities**:
- OWASP Top 10 coverage
- Hardcoded secrets detection
- Injection vulnerability patterns
- Authentication/authorization checks
- Severity classification (Critical/High/Medium/Low)

**Security Categories**:
- Hardcoded secrets (API keys, passwords)
- Injection vulnerabilities (SQL, command, XSS)
- Dangerous patterns (eval, unsafe deserialization)
- Auth/authz issues (missing checks, weak crypto)
- Sensitive data exposure (logging credentials)

**Example Invocation**:
```
User: "Check if this auth code is secure"
Assistant: "I'll launch security-scanner to analyze the authentication implementation."
```

**Output**: Security scan report with categorized vulnerabilities and remediation guidance.

---

## Workflow Agents

### requirements-gatherer 🔵
**Model**: sonnet | **Color**: blue

Requirements analyst transforming vague ideas into structured specifications with acceptance criteria.

**When to Use**:
- Feature request is vague
- Need structured requirements
- Unclear acceptance criteria
- "What should this do?" questions

**When NOT to Use**:
- Requirements already clear
- During implementation (too late)
- For trivial features

**Capabilities**:
- Creates user stories with acceptance criteria
- Defines scope boundaries (in/out)
- Identifies edge cases
- Documents non-functional requirements
- Interactive questioning to extract details

**Questioning Structure**:
- Core functionality and goals
- Users and permissions
- Scope boundaries
- Success criteria
- Edge cases and error handling

**Example Invocation**:
```
User: "I want users to be able to share things"
Assistant: "I'll launch requirements-gatherer to understand what sharing means."
```

**Output**: Complete requirements specification with user stories, scope, and acceptance criteria.

---

### complexity-estimator 🔵
**Model**: haiku | **Color**: blue

Complexity analyst providing T-shirt size estimates, risk assessment, and spike recommendations.

**When to Use**:
- Start of new features
- Setting expectations
- "How hard is this?" questions
- Risk identification

**When NOT to Use**:
- After implementation started
- For trivial tasks (obviously XS)
- When complexity is known

**Capabilities**:
- T-shirt sizing (XS/S/M/L/XL)
- Risk identification by category
- Dependency analysis
- Spike/POC recommendations
- Confidence ratings

**Complexity Factors** (scored 1-5 each):
- Files touched
- New concepts needed
- Integration points
- Data changes
- Testing complexity
- Regression risk
- Uncertainty level

**Spike Recommendation**: When score ≥25 or any factor = 5.

**Example Invocation**:
```
User: "I want to add real-time notifications"
Assistant: "I'll launch complexity-estimator to assess scope and identify risks."
```

**Output**: Complexity breakdown with T-shirt size, risks, and recommendations.

---

### workflow-detector 🟡
**Model**: haiku | **Color**: yellow

Task classifier determining optimal workflow type (feature/bug/refactor/QA).

**When to Use**:
- Task type is ambiguous
- Routing to appropriate workflow
- "Is this a bug or feature?" questions

**When NOT to Use**:
- Task type is obvious
- User specified a command (/devloop:quick, etc.)
- During active work

**Capabilities**:
- Classifies into Feature/Bug/Refactor/QA
- Confidence scoring (High/Medium/Low)
- Mixed task handling
- Workflow adaptation recommendations

**Classification Indicators**:
- **Feature**: add, create, implement, new
- **Bug**: fix, broken, error, fails
- **Refactor**: refactor, clean up, improve
- **QA**: test, coverage, validate

**Example Invocation**:
```
User: "The login is broken"
Assistant: "I'll launch workflow-detector to classify this task."
```

**Output**: Task classification with confidence and recommended workflow.

---

### summary-generator 🔷
**Model**: haiku | **Color**: teal

Technical writer creating session summaries and handoff documentation.

**When to Use**:
- End of work session
- Complex multi-session work
- Need to pause work
- Team handoff needed

**When NOT to Use**:
- During active implementation
- For trivial changes
- After every single task

**Capabilities**:
- Documents work completed
- Records key decisions
- Lists files modified
- Identifies next steps
- Updates plan Progress Log

**Plan File Updates**:
- **MUST** update `.devloop/plan.md`
- Marks tasks complete `[ ]` → `[x]`
- Marks in-progress `[ ]` → `[~]`
- Adds Progress Log entries
- Updates Status and timestamps

**Example Invocation**:
```
User: "I need to stop for today"
Assistant: "I'll launch summary-generator to capture where we left off."
```

**Output**: Comprehensive session summary with context for resuming work.

---

### doc-generator 🔷
**Model**: sonnet | **Color**: teal

Technical documentation specialist creating READMEs, API docs, inline comments, and changelogs.

**When to Use**:
- After implementing features
- API endpoints changed
- Documentation out of date
- New features need docs

**When NOT to Use**:
- During active implementation (wait until stable)
- Docs already current
- Trivial changes

**Capabilities**:
- README updates (features, usage, examples)
- API documentation (endpoints, requests, responses)
- CHANGELOG entries (Keep a Changelog format)
- Code comments (complex logic)
- Architecture documentation

**Documentation Types**:
- **README**: Feature docs, configuration, examples
- **API Docs**: Endpoints with request/response formats
- **CHANGELOG**: Version history with semantic versioning
- **Code Comments**: Inline docs for complex logic

**Example Invocation**:
```
Assistant: "I'll launch doc-generator to update documentation for this feature."
```

**Output**: Updated documentation with validation checklist.

---

## Integration Agents

### git-manager 🟠
**Model**: haiku | **Color**: orange

Git workflow specialist handling commits, branches, PRs with conventional messages.

**When to Use**:
- Ready to commit changes
- Creating pull requests
- Branch management
- After DoD validation

**When NOT to Use**:
- During active implementation
- Before DoD validation
- For git queries (use Bash directly)

**Capabilities**:
- Conventional commit messages
- Branch management (proper naming)
- Pull request creation with descriptions
- History management (rebase, squash)
- Conflict resolution guidance

**Conventional Commit Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code restructure
- `test`: Adding tests
- `chore`: Maintenance

**Branch Naming**:
- Feature: `feature/<id>-<description>`
- Fix: `fix/<id>-<description>`
- Hotfix: `hotfix/<description>`

**Example Invocation**:
```
Assistant: "I'll launch git-manager to create a well-structured commit."
```

**Output**: Git operation summary with commit message and next steps.

---

### bug-catcher 🟠
**Model**: haiku | **Color**: orange

Bug tracking assistant creating structured bug reports for non-critical issues.

**When to Use**:
- Non-critical issues discovered
- Issues worth tracking for later
- Minor problems during development
- "Fix this later" moments

**When NOT to Use**:
- Critical bugs (fix immediately)
- During active bug fixing
- User-facing bug reports (use /devloop:bug)

**Capabilities**:
- Creates bug files in `.devloop/issues/`
- Assigns bug IDs (BUG-001, BUG-002, etc.)
- Tracks priority, status, tags
- Updates bug index
- Quick logging for agents

**Bug File Format**:
```markdown
---
id: BUG-NNN
title: Brief description
status: open
priority: low|medium|high
created: ISO timestamp
---

# BUG-NNN: Title

## Description
[What's wrong]

## Context
[How discovered]
```

**Example Invocation**:
```
Assistant: "I found a formatting issue - I'll log it with bug-catcher for later."
```

**Output**: Bug created with ID and file location.

---

## Agent Comparison Tables

### By Invocation Pattern

| Agent | User-Invoked | Auto-Invoked | Spawned by Other Agents |
|-------|--------------|--------------|-------------------------|
| code-explorer | ✅ | ✅ | ✅ (by code-architect) |
| code-architect | ✅ | ✅ | ❌ |
| code-reviewer | ✅ | ✅ | ❌ |
| task-planner | ❌ | ✅ | ❌ |
| test-generator | ✅ | ✅ | ✅ (by qa-agent) |
| test-runner | ✅ | ✅ | ❌ |
| qa-agent | ✅ | ✅ | ❌ |
| dod-validator | ❌ | ✅ | ❌ |
| security-scanner | ✅ | ✅ | ❌ |
| requirements-gatherer | ❌ | ✅ | ❌ |
| complexity-estimator | ❌ | ✅ | ❌ |
| workflow-detector | ❌ | ✅ | ❌ |
| summary-generator | ❌ | ✅ | ❌ |
| doc-generator | ✅ | ✅ | ❌ |
| git-manager | ❌ | ✅ | ❌ |
| bug-catcher | ✅ | ✅ | ✅ (by any agent) |

### By Plan Permissions

| Agent | Permission | Can Read Plan | Can Update Plan |
|-------|------------|---------------|-----------------|
| task-planner | full | ✅ | ✅ Creates plan |
| summary-generator | full | ✅ | ✅ Updates status |
| dod-validator | full | ✅ | ✅ Updates status |
| code-explorer | plan | ✅ | ❌ Recommends only |
| code-architect | full | ✅ | ❌ |
| code-reviewer | plan | ✅ | ❌ Recommends only |
| complexity-estimator | plan | ✅ | ❌ Recommends only |
| workflow-detector | plan | ✅ | ❌ |
| security-scanner | plan | ✅ | ❌ Recommends only |
| Others | none | ❌ | ❌ |

### By Model Selection

| Model | Agents | Token Cost | Usage % |
|-------|--------|------------|---------|
| **opus** | code-reviewer (critical code) | 5x | 20% |
| **sonnet** | code-explorer, code-architect, code-reviewer, task-planner, test-generator, test-runner, qa-agent, requirements-gatherer, doc-generator | 1x | 60% |
| **haiku** | dod-validator, security-scanner, complexity-estimator, workflow-detector, summary-generator, git-manager, bug-catcher | 0.2x | 20% |

---

## Best Practices

### Spawning Agents

```typescript
// From a command or parent agent
Task: Launch code-explorer to analyze payment flow
```

### Parallel Agent Execution

```typescript
// Launch multiple agents simultaneously
- Launch code-explorer agent 1: Find similar features
- Launch code-explorer agent 2: Map architecture
- Launch code-explorer agent 3: Identify integration points
```

### Reading Agent Recommendations

Agents with `permissionMode: plan` return recommendations:
```markdown
### Plan Update Recommendations
- Task X.Y complexity should be updated to L
- New task recommended: Security review for auth module
```

### Agent Output Format

All agents follow this structure:
```markdown
## [Agent Name] Report

### Summary
[Brief overview]

### [Section 1]
[Detailed findings]

### [Section 2]
[Detailed findings]

### Recommendations
[Actionable next steps]
```

---

## Common Workflows

### Feature Development
1. **workflow-detector**: Classify task
2. **requirements-gatherer**: Clarify requirements
3. **complexity-estimator**: Assess scope
4. **code-explorer**: Understand existing code (x3 parallel)
5. **code-architect**: Design approach (x3 parallel)
6. **task-planner**: Create implementation plan
7. *(Implementation by main workflow)*
8. **test-generator**: Create tests
9. **test-runner**: Validate tests
10. **code-reviewer**: Review quality (x3 parallel)
11. **security-scanner**: Security check
12. **qa-agent**: Deployment readiness
13. **dod-validator**: Verify completion
14. **git-manager**: Commit/PR
15. **summary-generator**: Document session

### Bug Fix
1. **workflow-detector**: Confirm bug
2. **code-explorer**: Trace bug source
3. *(Fix implementation)*
4. **test-runner**: Verify fix
5. **code-reviewer**: Check for regressions
6. **git-manager**: Commit fix

### Code Review
1. **code-reviewer**: Primary review (x3 parallel focuses)
2. **security-scanner**: Security analysis
3. **test-runner**: Validate tests still pass

---

## Troubleshooting

### Agent Not Responding
- Check that agent exists in `plugins/devloop/agents/`
- Verify agent.md has proper frontmatter
- Ensure model specified (opus/sonnet/haiku)

### Agent Producing Wrong Results
- Check if agent has appropriate model (may need upgrade)
- Verify agent has necessary skills in frontmatter
- Consider enabling extended thinking for complex tasks

### Agent Missing Context
- Ensure agent has necessary tools in frontmatter
- Check if agent should read plan file first
- Consider spawning code-explorer for deeper context

### Agent Taking Too Long
- Consider downgrading model (sonnet → haiku if appropriate)
- Check if parallel execution could help
- Reduce scope by spawning focused sub-agents

---

## Related Documentation

- [Commands](commands.md) - Commands that invoke these agents
- [Skills](skills.md) - Domain knowledge agents can invoke
- [Workflow](workflow.md) - How agents fit into the 12-phase workflow
- [Configuration](configuration.md) - Environment variables agents use
