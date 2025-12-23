# Devloop Agents

This document provides comprehensive information about the 12 specialized agents in the devloop plugin.

## Overview

Devloop agents are specialized sub-agents that handle specific aspects of the development workflow. In v2.0, agents have been consolidated into "super-agents" that combine related capabilities:

- **engineer** - Combines exploration, architecture, refactoring, and git operations
- **qa-engineer** - Combines test generation, execution, bug tracking, and QA validation
- **task-planner** - Combines planning, requirements gathering, issue management, and DoD validation

Each agent is optimized with:
- **Mode-based operation**: Multiple capabilities within a single agent
- **Strategic model selection**: Right model (opus/sonnet/haiku) for their task
- **Color coding**: Visual organization by category
- **Focused tools**: Only the tools they need

Agents are invoked automatically by the devloop workflow or can be spawned explicitly using the `Task` tool.

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

## Agent Comparison Tables

### By Invocation Pattern

| Agent | User-Invoked | Auto-Invoked | Multi-Mode |
|-------|--------------|--------------|------------|
| engineer | ✅ | ✅ | ✅ (explore, architect, refactor, git) |
| qa-engineer | ✅ | ✅ | ✅ (generate, run, bug, validate) |
| task-planner | ✅ | ✅ | ✅ (plan, requirements, issues, DoD) |
| code-reviewer | ✅ | ✅ | ❌ |
| security-scanner | ✅ | ✅ | ❌ |
| complexity-estimator | ❌ | ✅ | ❌ |
| workflow-detector | ❌ | ✅ | ❌ |
| summary-generator | ❌ | ✅ | ❌ |
| doc-generator | ✅ | ✅ | ❌ |

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

tools: [List of available tools]
model: sonnet|haiku|opus      # Choose based on task complexity
color: [color-name]           # Visual identification
skills: [skill-1, skill-2]    # Auto-loaded skills
---
```

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
