# Devloop Agents

**Comprehensive reference for all 9 devloop agents, their capabilities, and collaboration patterns.**

---

## Table of Contents

1. [Overview](#overview)
2. [Quick Reference](#quick-reference)
3. [Agent Color Scheme](#agent-color-scheme)
4. [Super-Agents](#super-agents-consolidated) - engineer, qa-engineer, task-planner
5. [Standalone Agents](#standalone-agents) - code-reviewer, security-scanner, complexity-estimator, workflow-detector, summary-generator, doc-generator
6. [Invocation Patterns](#invocation-patterns) - How agents are invoked and routed
7. [Agent Comparison Tables](#agent-comparison-tables)
8. [Common Workflows](#common-workflows)
9. [Agent Collaboration Patterns](#agent-collaboration-patterns)
10. [Best Practices](#best-practices) - Decision trees, model selection, token efficiency, error handling
11. [Writing Agent Descriptions](#writing-agent-descriptions) - Guidelines for creating new agents
12. [Migration from v1.x](#migration-from-v1x)
13. [Related Documentation](#related-documentation)

---

## Overview

Devloop agents are specialized sub-agents that handle specific aspects of the development workflow. They represent the execution layer of devloop's methodology, transforming plans into code, tests, and documentation.

### Architecture: Super-Agents + Specialists

In v2.0+, devloop uses a hybrid agent architecture:

**3 Super-Agents** (multi-mode, high-flexibility):
- **engineer** - Exploration, architecture, refactoring, git operations (4 modes)
- **qa-engineer** - Test generation, execution, bug tracking, QA validation (4 modes)
- **task-planner** - Planning, requirements, issue management, DoD validation (4 modes)

**6 Specialist Agents** (single-purpose, high-efficiency):
- **code-reviewer** - Code quality and bug detection
- **security-scanner** - OWASP Top 10 vulnerability scanning
- **complexity-estimator** - T-shirt sizing and risk assessment
- **workflow-detector** - Task classification and routing
- **summary-generator** - Session summaries and handoff docs
- **doc-generator** - READMEs, API docs, changelogs

### Key Principles (v2.1)

**1. Strategic Model Selection**
- opus (5x cost): Critical code review, security-sensitive work
- sonnet (1x cost): Standard implementation, design, planning
- haiku (0.2x cost): Classification, estimation, summaries

**2. Mode-Based Operation**
- Super-agents detect operating mode from task context
- Single agent handles multiple related capabilities
- Reduces context switching, improves coherence

**3. Automatic Invocation**
- `/devloop:continue` routes to agents via routing table
- Agents auto-invoke skills based on file type and context
- Background execution for parallel independent tasks

**4. Checkpoint-Driven Workflow** (Phase 7)
- Mandatory checkpoints after every agent execution
- Plan synchronization with `[x]`/`[ ]`/`[~]` markers
- Session metrics tracking (tasks/agents/duration/tokens)
- Context management with staleness thresholds

**5. Fresh Start Support** (Phase 8)
- `/devloop:fresh` saves state and clears context
- Auto-detection on session startup
- State preservation in `.devloop/next-action.json`
- Single-use state file (auto-deleted after reading)

### What's New in v2.1 (Phases 5-9)

**Engineer Agent Enhancements** (Phase 6):
- 6 new skills: complexity-estimation, project-context, api-design, database-patterns, testing-strategies, refactoring-analysis
- Mode-specific skill workflows with invocation order
- Complexity-aware mode selection (simple/medium/complex)
- Output format standards (token budgets per mode)
- Model escalation guidance (when to suggest opus)
- Enhanced delegation to all 9 agents

**Workflow Loop** (Phase 7):
- Mandatory post-task checkpoint (Step 5a in continue.md)
- Loop completion detection with 8 option handlers
- Context management with 6 session metrics
- Standardized AskUserQuestion patterns (11 questions)

**Fresh Start Mechanism** (Phase 8):
- `/devloop:fresh` command for state preservation
- `session-start.sh` auto-detection with jq + fallback parsing
- Integration with `/devloop:continue` workflow
- Complete lifecycle documentation in Step 9

**Integration & Refinements** (Phase 9):
- Spike → plan application with diff previews
- Enhanced task-checkpoint skill with mandatory worklog sync
- Applied AskUserQuestion standards to review.md and ship.md
- Comprehensive integration testing (5/5 scenarios passed)

Each agent is optimized with:
- **Mode-based operation**: Multiple capabilities within a single agent (super-agents)
- **Strategic model selection**: Right model (opus/sonnet/haiku) for their task
- **Color coding**: Visual organization by category
- **Focused tools**: Only the tools they need
- **Auto-loaded skills**: Relevant domain knowledge based on context

Agents are invoked automatically by the devloop workflow (via `/devloop:continue`) or can be spawned explicitly using the `Task` tool.

---

## Quick Reference

**Most Common Agent Invocations:**

| I want to... | Use this agent | Mode/Notes |
|--------------|----------------|------------|
| Understand how code works | `engineer` | Explore mode, max 10 files |
| Design a new feature | `engineer` | Architect mode, consider 2-3 approaches |
| Implement approved design | `engineer` | Default mode |
| Improve code quality | `engineer` | Refactor mode OR `/devloop:analyze` |
| Make a commit/PR | `engineer` | Git mode |
| Break down a feature | `task-planner` | Planner mode |
| Clarify vague requirements | `task-planner` | Requirements mode |
| Generate tests | `qa-engineer` | Generator mode |
| Run tests | `qa-engineer` | Runner mode |
| Review code | `code-reviewer` | Standalone, use opus for critical |
| Check security | `security-scanner` | Standalone, always haiku |
| Estimate complexity | `complexity-estimator` | Auto-invoked, not manual |
| Resume work | `/devloop:continue` | Routes automatically |
| Clear context | `/devloop:fresh` | Command, not agent |

**Agent Routing**: See full routing table in [Invocation Patterns](#invocation-patterns) section.

---

## Agent Color Scheme

Agents use color coding for easy visual identification:

| Color | Category | Purpose | Agents |
|-------|----------|---------|--------|
| 🟣 **indigo** | Engineering | Design, exploration, git | engineer, task-planner |
| 🟢 **green** | Quality | Testing, validation | qa-engineer |
| 🔴 **red** | Critical Review | Security and quality | code-reviewer, security-scanner |
| 🟡 **yellow** | Classification | Task routing | workflow-detector |
| 🔵 **blue** | Estimation | Complexity analysis | complexity-estimator |
| 🔷 **teal** | Documentation | Docs and summaries | doc-generator, summary-generator |

---

## Super-Agents (Consolidated)

### engineer 🟣
**Model**: sonnet | **Color**: indigo

Senior software engineer combining four specialized roles:
1. **Explorer** - Trace execution paths, map architecture, understand patterns
2. **Architect** - Design features, make structural decisions, plan implementations
3. **Refactorer** - Identify code quality issues, technical debt, improvements
4. **Git Manager** - Commits, branches, PRs, history management

**Mode Detection**:
| User Intent | Mode | Focus |
|-------------|------|-------|
| "How does X work?" | Explorer | Tracing, mapping, understanding |
| "I need to add X" | Architect | Design, structure, planning |
| "What should I refactor?" | Refactorer | Analysis, quality, debt |
| "Commit this" / "Create PR" | Git | Version control operations |

**Complexity-Aware Mode Selection** (v2.1):
- **Simple**: Proceed directly with standard workflow
- **Medium**: Execute with checkpoints (2-5 files, some new patterns)
- **Complex**: Invoke complexity-estimation, present 2-3 approaches with trade-offs (5+ files, new architecture)

**Multi-Mode Task Patterns** (v2.1):
- **"Add [Feature] to [Component]"**: Explorer → Architect → (Checkpoint) → Return architecture
- **"Refactor and Commit"**: Refactorer → Git
- **"Trace [Feature] and Fix Issues"**: Explorer → Refactorer → (Checkpoint) → Return findings

**When to Use**:
- Understanding how existing features work
- Designing new features
- Analyzing refactoring opportunities
- Managing git operations (commits, PRs)

**Skills Auto-loaded** (v2.1 - Enhanced):
- **Core**: architecture-patterns, tool-usage-policy, plan-management, git-workflows, refactoring-analysis
- **Language**: go-patterns, react-patterns, java-patterns, python-patterns
- **Design**: api-design, database-patterns
- **Analysis**: complexity-estimation, project-context, testing-strategies

**Mode-Specific Skill Workflows** (v2.1):
- **Explorer**: tool-usage-policy → project-context → language patterns
- **Architect**: architecture-patterns → language patterns → api-design/database-patterns → testing-strategies → complexity-estimation (optional)
- **Refactorer**: built-in analysis → language patterns → complexity-estimation
- **Git**: git-workflows (for complex operations only)

**Output Format Standards** (v2.1):
- **Explorer**: Structured format with entry points table, execution flow, key components, architecture insights (max 500 tokens)
- **Architect**: Component design with responsibilities, data flow, implementation map, build sequence (max 800 tokens)
- **Refactorer**: Codebase health summary, findings by category, quick wins, implementation roadmap (max 1000 tokens)
- **Git**: Operation summary, commit message, changes summary, next steps (max 200 tokens)
- **File references**: Always use `file:line` or `file:start-end` format

**Model Escalation** (v2.1):
- Suggests opus model for: 5+ files affected, security-sensitive code, complex async/concurrency patterns
- Output format: "⚠️ This task has high complexity/stakes. Consider running with opus model for deeper analysis."

**Delegation** (v2.1):
- Code quality review → `code-reviewer`
- Security analysis → `security-scanner`
- Documentation → `doc-generator`
- Session summary → `summary-generator`
- Test generation → `qa-engineer`
- Task planning → `task-planner`
- Task classification → `workflow-detector`
- Complexity assessment → `complexity-estimator`

**Example Invocations**:
```
User: "How does the payment processing work?"
→ Engineer in explore mode
→ Output: Structured exploration with entry points, flow, components

User: "I need to add user authentication"
→ Engineer in architect mode
→ Complexity: High → Invokes complexity-estimation
→ Presents OAuth vs JWT vs session approaches
→ Output: Architecture blueprint with component design

User: "Create a PR for this feature"
→ Engineer in git mode
→ Output: PR created with summary and next steps
```

**Output**: Varies by mode - feature analysis, architecture blueprints, refactoring plans, or git operation summaries. All outputs follow token-conscious guidelines and offer to elaborate on specific areas.

---

### qa-engineer 🟢
**Model**: sonnet | **Color**: green

Senior QA engineer combining four specialized roles:
1. **Test Generator** - Write unit, integration, and E2E tests
2. **Test Runner** - Execute tests, analyze failures, suggest fixes
3. **Bug Tracker** - Create and manage bug reports
4. **QA Validator** - Validate deployment readiness

**Mode Detection**:
| User Intent | Mode | Focus |
|-------------|------|-------|
| "Write tests for X" | Generator | Creating tests |
| "Run the tests" | Runner | Execution, analysis |
| "Log this bug" | Bug Tracker | Issue creation |
| "Is it ready to deploy?" | Validator | Readiness check |

**When to Use**:
- Generating test coverage
- Running and analyzing tests
- Tracking non-blocking bugs
- Validating deployment readiness

**Skills Auto-loaded**:
- testing-strategies, deployment-readiness, issue-tracking, tool-usage-policy

**Supported Frameworks**:
- Jest (TypeScript/JavaScript)
- Go Test
- Pytest (Python)
- JUnit (Java)

**Example Invocations**:
```
User: "Write tests for the UserService"
→ QA-engineer in generator mode

User: "Run the tests to make sure I didn't break anything"
→ QA-engineer in runner mode

User: "Is this feature ready to deploy?"
→ QA-engineer in validator mode
```

**Output**: Tests, test results with fix suggestions, bug reports, or deployment readiness reports.

---

### task-planner 🟣
**Model**: sonnet | **Color**: indigo

Project manager combining four specialized roles:
1. **Planner** - Break architectures into ordered tasks with acceptance criteria
2. **Requirements Gatherer** - Transform vague ideas into structured specifications
3. **Issue Manager** - Create and manage issues (bugs, features, tasks)
4. **DoD Validator** - Verify all completion criteria are met

**Mode Detection**:
| User Intent | Mode | Focus |
|-------------|------|-------|
| "Break this into tasks" | Planner | Task breakdown, dependencies |
| "What exactly do you need?" | Requirements | Specification gathering |
| "Log this issue" | Issue Manager | Issue creation/tracking |
| "Is it ready to ship?" | DoD Validator | Completion verification |

**When to Use**:
- Creating implementation plans from architecture
- Gathering requirements for vague features
- Tracking issues discovered during development
- Validating Definition of Done criteria

**Plan File Management**:
- **MUST** save plans to `.devloop/plan.md`
- Writes to TodoWrite for session tracking
- Updates plan status during DoD validation

**Skills Auto-loaded**:
- testing-strategies, requirements-patterns, issue-tracking, plan-management, tool-usage-policy

**Example Invocations**:
```
User: "Ok, let's implement approach 2"
→ Task-planner in planner mode

User: "I want users to be able to share things"
→ Task-planner in requirements mode

User: "Is this feature ready to ship?"
→ Task-planner in DoD validator mode
```

**Output**: Implementation plans, requirements specifications, issues, or DoD validation reports.

---

## Standalone Agents

### code-reviewer 🔴
**Model**: sonnet/opus | **Color**: red

Expert code reviewer using confidence-based filtering to report only high-priority issues.

**When to Use**:
- After implementing features
- Before committing changes
- During PR review

**Capabilities**:
- Project guideline compliance (CLAUDE.md)
- Bug detection (logic errors, null handling, race conditions)
- Code quality assessment
- Language-specific idiom checks
- Only reports issues with ≥80% confidence

**Example**:
```
Assistant: "I've completed the feature. I'll launch code-reviewer to validate it."
```

---

### security-scanner 🔴
**Model**: haiku | **Color**: red

Security analyst scanning for OWASP Top 10 vulnerabilities, secrets, and injection risks.

**When to Use**:
- Code handles user input
- Security-sensitive areas
- Before deployment
- During code review

**Capabilities**:
- OWASP Top 10 coverage
- Hardcoded secrets detection
- Injection vulnerability patterns
- Severity classification (Critical/High/Medium/Low)

---

### complexity-estimator 🔵
**Model**: haiku | **Color**: blue

Complexity analyst providing T-shirt size estimates, risk assessment, and spike recommendations.

**When to Use**:
- Start of new features
- Setting expectations
- Risk identification

**Output**: T-shirt sizing (XS/S/M/L/XL) with risk factors and spike recommendations.

---

### workflow-detector 🟡
**Model**: haiku | **Color**: yellow

Task classifier determining optimal workflow type (feature/bug/refactor/QA).

**When to Use**:
- Task type is ambiguous
- Routing to appropriate workflow

---

### summary-generator 🔷
**Model**: haiku | **Color**: teal

Technical writer creating session summaries and handoff documentation.

**When to Use**:
- End of work session
- Complex multi-session work
- Team handoff needed

---

### doc-generator 🔷
**Model**: sonnet | **Color**: teal

Technical documentation specialist creating READMEs, API docs, inline comments, and changelogs.

**When to Use**:
- After implementing features
- API endpoints changed
- Documentation out of date

---

## Invocation Patterns

### How Agents Are Invoked

Agents can be invoked in three ways:

1. **Automatic Routing** - `/devloop:continue` determines the right agent based on task type
2. **Explicit Invocation** - Use Task tool directly: `Task(subagent_type="devloop:agent-name")`
3. **Background Execution** - Parallel execution with `run_in_background: true`

**Example: Automatic Routing**

When you run `/devloop:continue` with a task "Implement user authentication", the command:
1. Reads the plan and identifies the task
2. Consults the Agent Routing Table (see `continue.md` Step 4)
3. Determines task type = "implement feature"
4. Routes to `devloop:engineer` agent
5. Engineer detects mode = "architect" (new feature)
6. Engineer may invoke other skills/agents as needed

**Example: Background Execution**

```markdown
Task(
  subagent_type="devloop:engineer",
  prompt="Explore payment processing flow",
  run_in_background=true
)
Task(
  subagent_type="devloop:engineer",
  prompt="Explore authentication system",
  run_in_background=true
)
Task(
  subagent_type="devloop:engineer",
  prompt="Explore notification service",
  run_in_background=true
)

# Poll for results
TaskOutput to check completion status
```

**When to Use Background Execution:**
- 3+ exploration tasks in parallel
- Independent code reviews across modules
- Multi-component architecture analysis
- **NOT** for sequential dependencies

### Agent Routing Table Reference

See `/devloop:continue` (Step 4) for the authoritative routing table. Summary:

| Task Type | Routes To | Mode/Notes |
|-----------|-----------|------------|
| Implement feature/code | engineer | Default/architect mode |
| Explore/understand code | engineer | Explore mode |
| Design architecture | engineer | Architect mode |
| Refactor code | engineer | Refactor mode |
| Git operations | engineer | Git mode |
| Plan tasks/breakdown | task-planner | Planner mode |
| Gather requirements | task-planner | Requirements mode |
| Validate completion | task-planner | DoD validator mode |
| Write tests | qa-engineer | Generator mode |
| Run tests | qa-engineer | Runner mode |
| Track bugs/issues | qa-engineer | Bug tracker mode |
| Code review | code-reviewer | Standalone |
| Security scan | security-scanner | Standalone |
| Generate docs | doc-generator | Standalone |
| Estimate complexity | complexity-estimator | Auto-invoked only |
| Spike/exploration | Suggest `/devloop:spike` | Command, not agent |

---

## Agent Comparison Tables

### By Invocation Pattern

| Agent | User-Invoked | Auto-Invoked | Multi-Mode | Background Capable |
|-------|--------------|--------------|------------|--------------------|
| engineer | ✅ | ✅ | ✅ (explore, architect, refactor, git) | ✅ |
| qa-engineer | ✅ | ✅ | ✅ (generate, run, bug, validate) | ✅ |
| task-planner | ✅ | ✅ | ✅ (plan, requirements, issues, DoD) | ⚠️ Limited |
| code-reviewer | ✅ | ✅ | ❌ | ✅ |
| security-scanner | ✅ | ✅ | ❌ | ✅ |
| complexity-estimator | ❌ | ✅ | ❌ | ✅ |
| workflow-detector | ❌ | ✅ | ❌ | ✅ |
| summary-generator | ❌ | ✅ | ❌ | ✅ |
| doc-generator | ✅ | ✅ | ❌ | ⚠️ Limited |

### By Model Selection

| Model | Agents | Token Cost | Usage % |
|-------|--------|------------|---------|
| **opus** | code-reviewer (critical code) | 5x | 15% |
| **sonnet** | engineer, qa-engineer, task-planner, code-reviewer, doc-generator | 1x | 65% |
| **haiku** | security-scanner, complexity-estimator, workflow-detector, summary-generator | 0.2x | 20% |

---

## Common Workflows

### Feature Development
1. **workflow-detector**: Classify task
2. **task-planner** (requirements mode): Clarify requirements
3. **complexity-estimator**: Assess scope
4. **engineer** (explore mode): Understand existing code (x3 parallel)
5. **engineer** (architect mode): Design approach (x3 parallel)
6. **task-planner** (planner mode): Create implementation plan
7. *(Implementation by main workflow)*
8. **qa-engineer** (generator mode): Create tests
9. **qa-engineer** (runner mode): Validate tests
10. **code-reviewer**: Review quality (x3 parallel)
11. **security-scanner**: Security check
12. **qa-engineer** (validator mode): Deployment readiness
13. **task-planner** (DoD mode): Verify completion
14. **engineer** (git mode): Commit/PR
15. **summary-generator**: Document session

### Bug Fix
1. **workflow-detector**: Confirm bug
2. **engineer** (explore mode): Trace bug source
3. *(Fix implementation)*
4. **qa-engineer** (runner mode): Verify fix
5. **code-reviewer**: Check for regressions
6. **engineer** (git mode): Commit fix

### Code Review
1. **code-reviewer**: Primary review (x3 parallel focuses)
2. **security-scanner**: Security analysis
3. **qa-engineer** (runner mode): Validate tests still pass

---

## Agent Collaboration Patterns

Agents work together to accomplish complex workflows. Understanding these patterns helps you leverage devloop's full capabilities.

### Engineer → Code Reviewer Flow

**Scenario**: Feature implementation complete, needs validation

```markdown
1. Engineer (architect mode) designs feature
   Output: Architecture blueprint

2. Engineer (default mode) implements feature
   Output: Code changes

3. Code Reviewer validates implementation
   - Launched automatically or manually
   - Checks against CLAUDE.md guidelines
   - Identifies high-confidence issues (≥80%)
   Output: Review findings

4. Engineer addresses review findings
   - If issues found, iterate
   - If clean, proceed to testing
```

**Key Points**:
- Code reviewer runs with sonnet/opus based on complexity
- Only high-confidence issues reported (reduces noise)
- Engineer has context from previous steps

### QA Engineer → Bug Tracker Flow

**Scenario**: Tests reveal non-blocking issues

```markdown
1. QA Engineer (generator mode) creates tests
   Output: Test files

2. QA Engineer (runner mode) executes tests
   Output: Test results + failures

3. QA Engineer (bug tracker mode) logs issues
   - Auto-creates bug reports for failures
   - Links to failing test cases
   - Categorizes severity
   Output: Bug issues in .devloop/issues/

4. Continue workflow or address immediately
   - Critical bugs: Fix now
   - Non-blocking: Track for later
```

**Key Points**:
- QA engineer handles full testing lifecycle
- Bug tracking integrated with issue system
- User decides priority for fixes

### Task Planner → Engineer Handoff

**Scenario**: Complex feature needs structured planning

```markdown
1. Task Planner (requirements mode) gathers specs
   - Asks clarifying questions
   - Documents requirements
   Output: Requirements document

2. Complexity Estimator assesses scope
   Output: T-shirt size + risk factors

3. Engineer (architect mode) designs solution
   - References requirements
   - Considers complexity assessment
   Output: Architecture blueprint

4. Task Planner (planner mode) creates implementation plan
   - Breaks architecture into tasks
   - Adds acceptance criteria
   - Identifies dependencies
   Output: .devloop/plan.md

5. Engineer executes tasks from plan
   - Uses /devloop:continue for workflow
   - Updates plan markers as tasks complete
```

**Key Points**:
- Clear requirements → better architecture
- Complexity informs design decisions
- Plan provides structured execution path

### Multi-Agent Parallel Execution

**Scenario**: Large codebase exploration across multiple modules

```markdown
1. Launch 3x Engineer (explore mode) in parallel
   Task 1: Explore payment processing
   Task 2: Explore authentication system
   Task 3: Explore notification service
   All with run_in_background=true

2. Poll TaskOutput for completion
   - Check status every few seconds
   - Collect results as they complete

3. Engineer (architect mode) synthesizes findings
   - Reads all 3 exploration reports
   - Identifies integration points
   - Designs unified architecture

4. Code Reviewer validates design (3x parallel)
   Task 1: Review payment integration
   Task 2: Review auth integration
   Task 3: Review notification integration
```

**Key Points**:
- Background execution for independent tasks
- Max 3-5 parallel agents (token efficiency)
- Synthesis step combines findings
- See "Background Execution Best Practices" in continue.md Step 5c

### Engineer Mode Transitions

**Scenario**: Multi-phase task requiring different capabilities

**Example 1: "Add feature X to component Y"**
```markdown
1. Engineer (explore mode) understands existing component
   - Traces current implementation
   - Identifies extension points
   Output: Exploration report

2. User checkpoint: "Based on this analysis, design the feature"

3. Engineer (architect mode) designs feature integration
   - References exploration findings
   - Proposes architecture approach
   Output: Architecture blueprint

4. User approves design

5. Engineer (default mode) implements feature
   Output: Code changes
```

**Example 2: "Refactor and commit"**
```markdown
1. Engineer (refactor mode) analyzes codebase
   - Identifies tech debt
   - Proposes improvements
   Output: Refactoring plan

2. User selects improvements to implement

3. Engineer (default mode) executes refactoring
   Output: Code changes

4. Code Reviewer validates changes
   Output: Review findings

5. Engineer (git mode) creates commit/PR
   Output: Git operation summary
```

**Key Points**:
- Single agent, multiple modes within one workflow
- Checkpoints between mode transitions
- Context preserved across modes
- See `engineer.md` "Multi-Mode Task Patterns" section

---

## Best Practices

### When to Use Which Agent

**Decision Tree for Common Scenarios**

```
Need to understand existing code?
  └─> engineer (explore mode)
      - Use 3x parallel for large codebases
      - Max 10 files per exploration
      - Combine with project-context skill

Need to design a feature?
  └─> Is scope unclear?
      ├─> Yes: task-planner (requirements mode) first
      │          Then engineer (architect mode)
      └─> No: engineer (architect mode) directly
          - Invoke complexity-estimation for complex features
          - Consider 2-3 alternative approaches

Need to implement code?
  └─> Has design been approved?
      ├─> Yes: engineer (default mode)
      └─> No: Don't implement yet
          - Run architect mode first
          - Get user approval

Need to refactor?
  └─> Large codebase (10+ files)?
      ├─> Yes: /devloop:analyze command
      │         (comprehensive analysis)
      └─> No: engineer (refactor mode)
          - Focuses on specific module

Need to review code?
  └─> Is it security-sensitive?
      ├─> Yes: Run both code-reviewer + security-scanner
      │         (recommend opus model for code-reviewer)
      └─> No: code-reviewer only (sonnet)

Need to test?
  └─> qa-engineer (generator mode for new tests)
      Then qa-engineer (runner mode for execution)
      Log failures with qa-engineer (bug tracker mode)

Ready to ship?
  └─> Are all tasks complete?
      ├─> Yes: task-planner (DoD validator mode)
      │         Then engineer (git mode)
      └─> No: Use /devloop:continue to finish tasks
```

### Model Selection Per Agent

**Strategic Model Choice for Token Efficiency**

| Agent | Default Model | When to Escalate | Reasoning |
|-------|---------------|------------------|-----------|
| **engineer** | sonnet | 5+ files, security code, complex patterns | Most work is standard coding |
| **qa-engineer** | sonnet | Critical test coverage gaps | Test generation is formulaic |
| **task-planner** | sonnet | Never | Planning is straightforward |
| **code-reviewer** | sonnet | Security-sensitive, complex logic | Opus for catching subtle bugs |
| **security-scanner** | haiku | Never | Pattern matching, fast |
| **complexity-estimator** | haiku | Never | Quick assessment |
| **workflow-detector** | haiku | Never | Classification only |
| **summary-generator** | haiku | Never | Document synthesis |
| **doc-generator** | sonnet | Never | Documentation needs clarity |

**Token Cost Impact** (relative to sonnet = 1x):
- opus = 5x tokens
- sonnet = 1x tokens
- haiku = 0.2x tokens

**Example Session**:
```
1. workflow-detector (haiku) - 0.2x
2. complexity-estimator (haiku) - 0.2x
3. engineer explore x3 (sonnet) - 3x
4. engineer architect (sonnet) - 1x
5. task-planner (sonnet) - 1x
6. engineer implement (sonnet) - 1x
7. qa-engineer generate (sonnet) - 1x
8. qa-engineer run (sonnet) - 1x
9. code-reviewer (opus) - 5x ← Critical phase
10. security-scanner (haiku) - 0.2x
11. engineer git (sonnet) - 1x
12. summary-generator (haiku) - 0.2x

Total: 15.0x (vs 60x if all opus, or 12x if all sonnet)
```

### Token Efficiency Considerations

**Parallel Execution Trade-offs**

Running 3 agents in parallel = 3x tokens consumed simultaneously.

**When it's worth it:**
- Large exploration (saves sequential time)
- Independent code reviews (comprehensive coverage)
- Critical path bottleneck (user waiting)

**When to avoid:**
- Sequential dependencies (wasted context)
- Simple tasks (overhead > benefit)
- Near token budget limits (risk of failures)

**Best practices:**
1. Limit to 3-5 parallel agents maximum
2. Use haiku agents for parallel when possible
3. Poll TaskOutput every 10-15 seconds (not continuously)
4. Have synthesis step after parallel execution

### Error Handling and Recovery

**Common Agent Failures and Solutions**

| Error Type | Cause | Solution |
|------------|-------|----------|
| **Agent timeout** | Task too complex | Break into smaller tasks |
| **Context overflow** | Too much code read | Use /devloop:fresh to reset |
| **Mode detection failure** | Ambiguous task description | Be explicit: "explore the auth system" |
| **Skill not found** | Missing language support | Check skills/INDEX.md for available skills |
| **Plan out of sync** | Manual edits | Use plan-management skill to fix |
| **Background agent stuck** | Infinite loop | Check ~/.devloop-agent-invocations.log |

**Recovery Patterns**

**If engineer gets stuck exploring:**
```markdown
1. Check how many files it's reading
2. If > 10 files, it's too broad
3. Refine prompt: "Explore only the UserService class"
4. Or split: "Explore auth" + "Explore users" separately
```

**If checkpoint questions are confusing:**
```markdown
1. Check .devloop/plan.md for task status
2. Verify which tasks are complete [x] vs pending [ ]
3. Answer based on actual completion, not intent
4. Use "partial completion" option if uncertain
```

**If fresh start state is wrong:**
```markdown
1. Use /devloop:fresh --dismiss to clear
2. Manually check .devloop/plan.md
3. Use /devloop:continue normally
4. State file is single-use, auto-deletes
```

### Context Management

**When to Use /devloop:fresh**

Trigger fresh start when:
- Session has processed 5+ tasks
- Plan size > 500 lines
- Token count approaching limits
- Conversation feels "sluggish"
- Switching to different phase

**Fresh Start Workflow:**
```bash
# 1. Save current state
/devloop:fresh

# 2. Start new conversation
# (Or restart Claude Code)

# 3. State auto-detected on startup
# Displays: Plan, Phase, Progress, Next task

# 4. Continue normally
/devloop:continue

# State file auto-deleted after reading
```

**State Preservation:**
- Plan file: `.devloop/plan.md` (git-tracked)
- Worklog: `.devloop/worklog.md` (git-tracked)
- Issues: `.devloop/issues/` (git-tracked)
- Fresh start state: `.devloop/next-action.json` (temporary, auto-deleted)

See Step 9 in `continue.md` for complete fresh start documentation.

---

## Writing Agent Descriptions

Guidelines for creating effective agent definitions. Following these ensures reliable invocation and consistent behavior.

### YAML Frontmatter Requirements

Every agent file requires these frontmatter fields:

```yaml
---
name: agent-name              # kebab-case, unique identifier
description: |                # CRITICAL for invocation
  Clear description with trigger words.
  Use when [specific triggers].

Examples:                     # Show Claude when/how to invoke
<example>
Context: [User situation]
user: "[User message]"
assistant: "I'll launch the devloop:agent-name agent to [action]."
<commentary>
[Why this agent is appropriate]
</commentary>
</example>

tools: [List of available tools]        # Claude Code standard
model: sonnet|haiku|opus                 # Claude Code standard
color: [color-name]                      # Claude Code standard
skills: [skill-1, skill-2]               # DEVLOOP-SPECIFIC (see below)
permissionMode: plan                     # Optional, Claude Code standard
---
```

#### Skills Field (Devloop-Specific)

**IMPORTANT**: The `skills:` field is a **devloop plugin convention**, not a Claude Code standard agent frontmatter field.

**Purpose**: Auto-loads skill context when the agent is invoked, providing domain knowledge without manual skill invocation.

**Format**: Comma-separated list of skill names (without `devloop:` prefix)

**Example**:
```yaml
skills: architecture-patterns, go-patterns, react-patterns, tool-usage-policy
```

**How it works**:
1. When devloop invokes an agent (e.g., `devloop:engineer`), it reads the `skills:` field from frontmatter
2. Skills listed are automatically loaded into the agent's context before execution
3. Agent can reference skill content without using `Skill` tool invocations
4. Reduces token usage by frontloading relevant domain knowledge

**Best practices**:
- **Core skills first**: List universal skills (tool-usage-policy, plan-management) before language-specific ones
- **Limit to essentials**: Only include skills the agent will actually use (3-12 skills typical)
- **Group by category**: Core → Language → Domain → Workflow
- **Mode-specific loading**: Super-agents may conditionally load skills based on detected mode

**Example from `engineer.md`**:
```yaml
skills: architecture-patterns, go-patterns, react-patterns, java-patterns, python-patterns, git-workflows, refactoring-analysis, plan-management, tool-usage-policy, complexity-estimation, project-context, api-design, database-patterns, testing-strategies
```

**Standard Claude Code Frontmatter Fields**:
- `name`: Agent identifier (required)
- `description`: Invocation trigger description (required)
- `tools`: Available tools list
- `model`: Model to use (sonnet/haiku/opus)
- `color`: Visual identification color
- `permissionMode`: Access restrictions (e.g., `plan` for read-only)

The `skills:` field is parsed and used by devloop's agent invocation system to enhance agent capabilities with pre-loaded domain knowledge.

### Description Best Practices

**DO**:
- Start with what the agent does: "Reviews code for bugs..."
- Include trigger words: "Use when...", "Use for...", "Use during..."
- Be specific about capabilities: "combining test generation, execution, and bug tracking"
- Mention context triggers: "after implementing features", "before deployment"

**DON'T**:
- Use vague descriptions: "Helps with coding tasks"
- Omit trigger conditions
- Leave out key capabilities

### Example Format Requirements

Examples must show explicit agent invocation format:

**CORRECT** ✅:
```markdown
<example>
Context: User has just implemented a new feature.
user: "Can you check if everything looks good?"
assistant: "I'll use the Task tool to launch the devloop:code-reviewer agent to review your changes."
<commentary>
Use code-reviewer after writing new code to catch issues early.
</commentary>
</example>
```

**INCORRECT** ❌:
```markdown
<example>
assistant: "I'll launch the code-reviewer to check."
</example>
```

**Key Points**:
- Always use format: `devloop:agent-name agent`
- Include the Task tool reference when relevant
- Provide context about when this invocation is appropriate
- Include commentary explaining the reasoning

### XML Prompt Structure

Agent prompts (after the frontmatter) should use XML structure for reliable instruction following:

```xml
<system_role>
You are the [Role Name] for the DevLoop development workflow system.
Your primary goal is: [Primary Goal]

<identity>
    <role>[Role Title]</role>
    <expertise>[Areas of Expertise]</expertise>
    <personality>[Personality Traits]</personality>
</identity>
</system_role>

<capabilities>
<capability priority="core">
    <name>[Capability Name]</name>
    <description>[What it does]</description>
</capability>
<!-- Add 3-5 core capabilities -->
</capabilities>

<workflow_enforcement>
<phase order="1">
    <name>analysis</name>
    <instruction>
        Before taking action, analyze the request:
    </instruction>
    <output_format>
        <thinking>
            - [Analysis points]
        </thinking>
    </output_format>
</phase>
<!-- Add 3-4 phases -->
</workflow_enforcement>

<output_requirements>
<requirement>[Requirement 1]</requirement>
<requirement>[Requirement 2]</requirement>
</output_requirements>

<skill_integration>
<skill name="skill-name" when="[Trigger condition]">
    Invoke with: Skill: skill-name
</skill>
</skill_integration>

<constraints>
<constraint type="safety">[Safety constraint]</constraint>
<constraint type="quality">[Quality requirement]</constraint>
</constraints>

<delegation>
<delegate_to agent="devloop:other-agent" when="[Condition]">
    <reason>[Why delegate]</reason>
</delegate_to>
</delegation>
```

**Reference Template**: `docs/templates/agent_prompt_structure.xml`

### Optional Sections

| Section | Use When |
|---------|----------|
| `<mode_detection>` | Agent has multiple operating modes |
| `<plan_context>` | Agent reads from plan.md |
| `<parallel_execution>` | Agent can run concurrently |

### Model Selection Guidelines

| Model | Cost | Use For |
|-------|------|---------|
| **haiku** | 0.2x | Fast classification, simple analysis, estimation |
| **sonnet** | 1x | Standard implementation, code review, planning |
| **opus** | 5x | Critical security review, complex reasoning |

Default to **sonnet** unless:
- Task is simple/fast → haiku
- Task is critical/complex → opus

### Color Coding Convention

| Color | Category | Examples |
|-------|----------|----------|
| 🟣 indigo | Engineering | engineer, task-planner |
| 🟢 green | Quality | qa-engineer |
| 🔴 red | Critical Review | code-reviewer, security-scanner |
| 🟡 yellow | Classification | workflow-detector |
| 🔵 blue | Estimation | complexity-estimator |
| 🔷 teal | Documentation | doc-generator, summary-generator |

### Permission Modes

| Mode | Effect |
|------|--------|
| (default) | Full read/write access |
| `permissionMode: plan` | Read-only access to plan files |

Use `permissionMode: plan` for agents that should recommend plan changes but not make them directly.

---

## Migration from v1.x

If you have automation referencing old agent names, update as follows:

| Old Agent | New Agent + Mode |
|-----------|------------------|
| code-explorer | engineer (explore mode) |
| code-architect | engineer (architect mode) |
| refactor-analyzer | engineer (refactor mode) |
| git-manager | engineer (git mode) |
| test-generator | qa-engineer (generator mode) |
| test-runner | qa-engineer (runner mode) |
| bug-catcher | qa-engineer (bug mode) |
| qa-agent | qa-engineer (validator mode) |
| requirements-gatherer | task-planner (requirements mode) |
| issue-manager | task-planner (issue mode) |
| dod-validator | task-planner (DoD mode) |

---

## Related Documentation

- [Commands](commands.md) - Commands that invoke these agents
- [Skills](skills.md) - Domain knowledge agents can invoke
- [Workflow](workflow.md) - How agents fit into the 12-phase workflow
- [Configuration](configuration.md) - Environment variables agents use
