# Feature Development Plugin

A comprehensive, token-conscious workflow for feature development with specialized agents, strategic model selection, and language-specific skills.

## Overview

The Feature Development Plugin provides a systematic 7-phase approach to building new features. It guides you through understanding the codebase, asking clarifying questions, designing architecture, and ensuring quality—while optimizing for token efficiency through strategic model selection.

## Philosophy

### Principal Engineer Approach

This plugin embodies how a senior/principal engineer approaches software development:

1. **Understand before acting** - Deep exploration before writing code
2. **Ask clarifying questions** - Resolve ambiguities upfront, not during implementation
3. **Design thoughtfully** - Consider multiple approaches, choose wisely
4. **Review rigorously** - Use the most capable model for quality review
5. **Optimize for efficiency** - Right model for the right task

### Token-Conscious Strategy

Target distribution: **20% Opus / 60% Sonnet / 20% Haiku**

| Task Type | Model | Rationale |
|-----------|-------|-----------|
| Task classification | haiku | Simple pattern matching |
| Code exploration | sonnet | Balanced understanding |
| Architecture (complex) | opus | High-stakes decisions |
| Implementation | sonnet | Balanced capability |
| Code review | opus | Must catch subtle bugs |
| Test generation | haiku | Formulaic patterns |
| Summary | haiku | Simple synthesis |

## Command: `/devloop`

Launches a guided feature development workflow with 7 distinct phases.

**Usage:**
```bash
/devloop Add user authentication with OAuth
```

Or simply:
```bash
/devloop
```

The command will guide you through the entire process interactively.

## The Enhanced 7-Phase Workflow

### Phase 0 (Optional): Workflow Detection

If the task type is ambiguous, the workflow-detector agent (haiku) classifies the task:
- **Feature**: Full 7-phase workflow
- **Bug Fix**: Streamlined 5-phase (skip architecture)
- **Refactor**: Focus on analysis and validation
- **QA**: Jump to qa-agent workflow

### Phase 1: Discovery

**Goal**: Understand what needs to be built

- Creates todo list with all phases
- Uses **AskUserQuestion** for structured requirement gathering
- Summarizes understanding and confirms with user

### Phase 2: Codebase Exploration

**Goal**: Understand relevant existing code and patterns

- Launches 2-3 **code-explorer** agents in parallel (sonnet)
- Each explores different aspects (similar features, architecture, patterns)
- Agents return key files to read
- Presents comprehensive summary of findings

### Phase 3: Clarifying Questions

**Goal**: Fill in gaps and resolve all ambiguities before designing

**CRITICAL PHASE** - Uses **AskUserQuestion** tool for structured questions:
- Edge cases and error handling
- Integration preferences
- Scope boundaries
- Feature priorities (with multiSelect)

### Phase 4: Architecture Design

**Goal**: Design multiple implementation approaches

- Invokes **architecture-patterns** skill for language-specific guidance
- Launches 2-3 **code-architect** agents with different focuses:
  - Minimal changes
  - Clean architecture
  - Pragmatic balance
- Uses **AskUserQuestion** for approach selection

### Phase 5: Implementation

**Goal**: Build the feature

- Waits for explicit user approval
- Uses sonnet for balanced capability
- Can invoke **frontend-design** skill for UI work
- Updates todos as progress is made

### Phase 6: Quality Review

**Goal**: Ensure code quality and correctness

- Launches **code-reviewer** agents (opus) for:
  - Simplicity/DRY/elegance
  - Bugs/functional correctness
  - Project conventions/abstractions
- Conditionally launches language-specific reviewers
- Uses **AskUserQuestion** for review decision:
  - Fix now / Fix critical only / Fix later / Proceed as-is
- Optional **qa-agent** for deployment readiness check

### Phase 7: Summary

**Goal**: Document what was accomplished

- Uses haiku for efficiency
- Summarizes what was built, key decisions, files modified
- Suggests next steps

## Agents

### Core Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| **code-explorer** | sonnet | Deep codebase analysis, traces execution paths |
| **code-architect** | sonnet | Architecture design and implementation blueprints |
| **code-reviewer** | opus | Quality review with confidence-based filtering (≥80) |

### New Specialized Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| **qa-agent** | sonnet | Deployment readiness validation (tests, build, docs) |
| **test-generator** | haiku | Generate tests following project patterns |
| **workflow-detector** | haiku | Classify task type (feature/bug/refactor/QA) |

## Skills

### Core Skills

| Skill | Auto-Trigger | Purpose |
|-------|--------------|---------|
| **model-selection-guide** | Explicit | When to use opus/sonnet/haiku |
| **workflow-selection** | When unclear | Workflow type guidance |
| **architecture-patterns** | Architecture phase | Design patterns by language |
| **testing-strategies** | QA/testing | Test design guidance |
| **deployment-readiness** | Pre-deploy | Deployment validation checklist |

### Language-Specific Skills

| Skill | Trigger | Focus |
|-------|---------|-------|
| **go-patterns** | Go project | Interfaces, error handling, goroutines |
| **react-patterns** | React project | Hooks, components, state, a11y |
| **java-patterns** | Java project | Spring, streams, DI, exceptions |

## Hooks

The plugin includes automated hooks for workflow enhancement:

### SessionStart Hook
Automatically detects and sets environment variables:
- `$FEATURE_DEV_PROJECT_LANGUAGE` - Primary language (go, typescript, java, etc.)
- `$FEATURE_DEV_FRAMEWORK` - Framework (react, spring, etc.)
- `$FEATURE_DEV_TEST_FRAMEWORK` - Test framework (jest, go-test, junit, etc.)
- `$FEATURE_DEV_PROJECT_TYPE` - Project type (frontend, backend, fullstack, cli)

### PreToolUse Hook
Validates code changes:
- Project convention compliance
- Security best practices
- Phase-appropriate changes

### Stop Hook
Verifies work completion:
- All tasks addressed
- No obvious incomplete items
- Tests appear to pass

## Usage Examples

### Full Feature Development
```bash
/devloop Add rate limiting to API endpoints
```

### With Workflow Detection
```bash
/devloop "The login is broken"
# → Detects as Bug Fix, streamlines workflow
```

### Manual Agent Invocation

**Explore a feature:**
```
"Launch code-explorer to trace how authentication works"
```

**Generate tests:**
```
"Launch test-generator to add tests for UserService"
```

**QA validation:**
```
"Launch qa-agent to check deployment readiness"
```

### Skill Invocation

```
Skill: architecture-patterns
Skill: go-patterns
Skill: model-selection-guide
```

## Configuration

### Environment Variables

Set by SessionStart hook automatically. Can also be set manually:

```bash
export FEATURE_DEV_PROJECT_LANGUAGE=typescript
export FEATURE_DEV_FRAMEWORK=react
export FEATURE_DEV_TEST_FRAMEWORK=jest
```

## Best Practices

1. **Use the full workflow for complex features** - The 7 phases ensure thorough planning
2. **Answer clarifying questions thoughtfully** - Phase 3 prevents future confusion
3. **Trust the model recommendations** - Opus for review, haiku for simple tasks
4. **Use AskUserQuestion responses** - Structured decisions are clearer
5. **Read the suggested files** - Phase 2 identifies key files—read them
6. **Run QA check before PRs** - qa-agent catches deployment issues

## When to Use This Plugin

**Use for:**
- New features that touch multiple files
- Features requiring architectural decisions
- Complex integrations with existing code
- Features where requirements are somewhat unclear

**Consider alternatives for:**
- Single-line bug fixes (use Bug Fix workflow)
- Simple refactoring (use Refactor workflow)
- Test development (use QA workflow)

## Directory Structure

```
plugins/devloop/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   ├── code-explorer.md
│   ├── code-architect.md
│   ├── code-reviewer.md
│   ├── qa-agent.md
│   ├── test-generator.md
│   └── workflow-detector.md
├── commands/
│   └── devloop.md
├── hooks/
│   ├── hooks.json
│   └── session-start.sh
├── skills/
│   ├── architecture-patterns/
│   ├── deployment-readiness/
│   ├── go-patterns/
│   ├── java-patterns/
│   ├── model-selection-guide/
│   ├── react-patterns/
│   ├── testing-strategies/
│   └── workflow-selection/
└── README.md
```

## Troubleshooting

### Agents take too long
- This is normal for large codebases
- Agents run in parallel when possible
- Consider using haiku for exploration in simpler cases

### Too many clarifying questions
- Be more specific in your initial feature request
- Provide context about constraints upfront
- Say "whatever you think is best" if truly no preference

### Wrong workflow selected
- Use Phase 0 workflow detection
- Or specify explicitly: "This is a bug fix, not a feature"

### Skills not loading
- Check skill exists in skills/ directory
- Verify SKILL.md file is present
- Ensure description matches trigger words

## Author

Originally by Sid Bidasaria (sbidasaria@anthropic.com)
Enhanced as the devloop plugin

## Version

2.0.0

## Changelog

### 2.0.0
- Added AskUserQuestion integration throughout workflow
- Upgraded code-reviewer to opus model for better quality
- Added 3 new specialized agents (qa-agent, test-generator, workflow-detector)
- Added 8 new skills for guidance and patterns
- Added hooks system (SessionStart, PreToolUse, Stop)
- Added Phase 0 optional workflow detection
- Added model selection guidelines (20/60/20 strategy)
- Added language-specific patterns (Go, React, Java)
- Enhanced Phase 6 with QA validation option

### 1.0.0
- Initial release with 7-phase workflow
- Core agents (code-explorer, code-architect, code-reviewer)
