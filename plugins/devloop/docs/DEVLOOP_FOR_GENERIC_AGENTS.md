# Devloop Workflow for Generic AI Agents

**Version**: 1.0.0  
**Compatibility**: Cursor, Aider, Gemini, and other AI coding agents  
**Purpose**: Structured, token-conscious feature development workflow

---

## Quick Start

This guide enables any AI coding agent to follow the devloop methodology without requiring the Claude Code plugin.

### What You Need
- Access to the codebase
- Ability to read/write files
- Bash command execution capability

### Entry Points by Task Type

| Task Type | Workflow | Where to Start |
|-----------|----------|----------------|
| **New feature or complex change** | Full Workflow | See [Full Workflow](#full-workflow) |
| **Small, well-defined task** | Quick Workflow | See [Quick Workflow](#quick-workflow) |
| **Technical exploration/POC** | Spike Workflow | See [Spike Workflow](#spike-workflow) |
| **Resume existing work** | Continue Workflow | See [Continue Workflow](#continue-workflow) |
| **Code review before commit** | Review Workflow | See [Review Workflow](#review-workflow) |

---

## Core Principles

All devloop workflows follow these principles:

1. **Ask clarifying questions** - Identify ambiguities before coding
2. **Understand before acting** - Read existing code patterns first
3. **Simple and elegant** - Prioritize readable, maintainable code
4. **Track progress** - Maintain a visible todo list throughout
5. **Plan first, implement second** - Create plan file before writing code

---

## Plan File Format

**CRITICAL**: All devloop work MUST create and maintain a plan file.

**Location**: `.claude/devloop-plan.md`

### Standard Plan Structure

```markdown
# Devloop Plan: [Feature Name]

**Created**: YYYY-MM-DD
**Updated**: YYYY-MM-DD HH:MM
**Status**: Planning | In Progress | Review | Complete
**Current Phase**: [Phase name]

## Overview
[2-3 sentence description of the feature]

## Requirements
[Key requirements or link to requirements doc]

## Architecture
[Chosen approach summary]

## Tasks

### Phase 1: [Phase Name]  [parallel:none]
**Goal**: [What this phase accomplishes]

- [ ] Task 1.1: [Description]
  - Acceptance: [Criteria]
  - Files: [Expected files to create/modify]
  - Testing: [Test requirements]

- [ ] Task 1.2: [Description]  [parallel:A]
  - Acceptance: [Criteria]
  - Files: [Expected files]

### Phase 2: [Phase Name]
- [ ] Task 2.1: [Description]
...

## Progress Log
- YYYY-MM-DD HH:MM: [Event description]
```

### Task Status Markers

| Marker | Meaning |
|--------|---------|
| `- [ ]` | Pending / Not started |
| `- [x]` | Completed |
| `- [~]` | In progress |
| `- [-]` | Skipped |
| `- [!]` | Blocked |

### Parallelism Markers

| Marker | Meaning | Example |
|--------|---------|---------|
| `[parallel:X]` | Can run with other tasks in group X | `[parallel:A]` |
| `[depends:N.M,...]` | Must wait for listed tasks | `[depends:1.1,1.2]` |
| `[background]` | Low priority, can defer | |
| `[sequential]` | Must run alone | |

### For More Details

For complete plan management guidelines including update procedures, conflict resolution, and advanced parallelism patterns, see: `../skills/plan-management/SKILL.md`

---

## Full Workflow {#full-workflow}

**Use for**: New features or complex changes requiring exploration and architecture.

The full devloop workflow consists of 12 phases from requirements through deployment. This is the comprehensive approach when you need to explore the codebase, design an architecture, and implement with full quality gates.

### When to Use Full Workflow

- New features with unclear requirements
- Changes requiring architectural decisions
- Work touching multiple systems
- Medium to high complexity tasks
- When user explicitly requests thorough approach

### Complete 12-Phase Process

For the complete workflow including all phases, detailed actions, and phase-specific guidance, read:

**→ `../commands/devloop.md`**

Key phases include:
- **Phase 0**: Triage - Classify task and pick workflow
- **Phase 1**: Discovery - Gather requirements
- **Phase 2**: Complexity Assessment - Estimate effort
- **Phase 3**: Exploration - Understand existing code
- **Phase 4**: Clarification - Resolve ambiguities
- **Phase 5**: Architecture - Design the solution
- **Phase 6**: Planning - Break into tasks
- **Phase 7**: Implementation - Write the code
- **Phase 8**: Testing - Verify it works
- **Phase 9**: Review - Quality check
- **Phase 10**: Definition of Done - Validate criteria
- **Phase 11**: Git Integration - Commit changes
- **Phase 12**: Summary - Document completion

---

## Quick Workflow {#quick-workflow}

**Use for**: Small, well-defined tasks (< 3 files, < 30 minutes).

The quick workflow is a streamlined 4-phase process for tasks with clear scope and no architectural decisions needed.

### When to Use Quick Workflow

- Bug fixes with known cause
- Small feature additions following existing patterns
- Configuration changes
- Documentation updates
- Test additions for existing code

### When NOT to Use Quick

- Multiple architectural approaches possible
- More than 3 files affected
- Unclear requirements
- High risk or complexity
- User wants full process

### Complete Quick Process

For the complete quick workflow including plan integration, escalation criteria, and speed guidelines, read:

**→ `../commands/quick.md`**

Quick phases:
1. **Understand & Plan** - Quick context and todo list
2. **Implement** - Direct implementation
3. **Verify** - Quick validation
4. **Done** - Wrap up

---

## Spike Workflow {#spike-workflow}

**Use for**: Technical exploration and proof of concepts before committing to implementation.

The spike workflow is a time-boxed investigation to answer specific technical questions and assess feasibility.

### When to Use Spike

- New technology or pattern not in codebase
- Uncertain feasibility or complexity
- Multiple approaches to evaluate
- Performance concerns to benchmark
- Integration with unknown systems
- High-risk changes needing proof of concept

### Spike Outcomes

A spike should produce:
- Clear answer to feasibility questions
- Complexity estimate (XS/S/M/L/XL)
- Recommended approach with rationale
- Risk assessment
- Plan update recommendations

### Complete Spike Process

For the complete spike workflow including research guidelines, prototype approach, evaluation criteria, and report format, read:

**→ `../commands/spike.md`**

Spike phases:
1. **Define Goals** - What questions to answer
2. **Research** - Gather information
3. **Prototype** - Build minimal POC
4. **Evaluate** - Assess findings
5. **Report** - Document at `.claude/[topic]-spike-report.md`

---

## Continue Workflow {#continue-workflow}

**Use for**: Resuming work from an existing plan.

The continue workflow finds your current plan, identifies what's done, and implements the next task.

### Plan Location Priority

Continue searches for plans in this order:
1. `.claude/devloop-plan.md` ← Primary location
2. `docs/PLAN.md`, `docs/plan.md`
3. `PLAN.md`, `plan.md`

### What Continue Does

1. **Finds the plan** - Locates your implementation plan
2. **Parses current state** - Identifies completed, current, and remaining tasks
3. **Detects parallel opportunities** - Finds tasks that can run together
4. **Presents status** - Shows progress summary
5. **Executes next task** - Implements the next step
6. **Updates plan** - Marks completion and logs progress
7. **Continues or stops** - Asks whether to proceed

### Complete Continue Process

For the complete continue workflow including parallel task handling, checkpoint procedures, phase completion steps, and plan format support, read:

**→ `../commands/continue.md`**

---

## Review Workflow {#review-workflow}

**Use for**: Code review before commits or PRs.

The review workflow performs systematic quality checks across multiple categories.

### Review Scope Options

- Uncommitted changes: `git diff`
- Staged changes: `git diff --staged`
- Branch changes: `git diff main...HEAD`
- Specific files: User-specified paths

### Review Categories

The review checks for:

1. **Logic Errors** - Algorithms, edge cases, race conditions
2. **Security Issues** - Injection, XSS, hardcoded secrets, OWASP Top 10
3. **Code Quality** - Naming, duplication, complexity, magic numbers
4. **Project Conventions** - Style guide, patterns, test coverage

### Complete Review Process

For the complete review workflow including detailed review criteria, output format, and remediation guidance, read:

**→ `../commands/review.md`**

---

## Best Practices for Generic Agents

### Context Management

1. **Read before editing** - Always read files before modifying
2. **Incremental loading** - Load only needed sections
3. **Use search efficiently** - `grep`, `find`, `git grep`
4. **Cache insights** - Document findings as you go

### Task Management

1. **Create todo lists** - Track progress visibly
2. **Update frequently** - Mark completion after each task
3. **One task at a time** - Unless explicitly parallel
4. **Show progress** - Update user regularly

### Plan Updates

**MUST** update `.claude/devloop-plan.md`:
- After completing each task
- When blocking issues arise
- When scope changes
- When adding discovered work

Update format:
```markdown
- [x] Task N.M: [Description]

## Progress Log
- YYYY-MM-DD HH:MM: Completed Task N.M - [brief note]
```

### Quality Standards

1. **Follow existing patterns** - Read similar code first
2. **Simple solutions** - Avoid over-engineering
3. **Test coverage** - Match project standards
4. **Security conscious** - Validate inputs, avoid injection
5. **Error handling** - Handle at boundaries, not internally

### Communication

1. **Ask questions early** - Don't guess on ambiguity
2. **Structured questions** - Provide clear options
3. **Confirm understanding** - Before major changes
4. **Show your work** - Explain reasoning

---

## Integration with AI Coding Tools

### Cursor

Add to `.cursorrules` in your project root:

```
# Devloop Methodology
When working on features, follow the devloop methodology:
1. Check for existing plan at .claude/devloop-plan.md
2. If no plan exists, create one before coding (see plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md)
3. Update plan after each task completion
4. Use plan format from devloop guide

Reference: plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md
```

### Aider

Add to `.aider.conf.yml` in your project root:

```yaml
# Devloop methodology integration
# See: plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md
# 
# Before implementing features:
# 1. Read existing plan at .claude/devloop-plan.md
# 2. Create plan if none exists
# 3. Update plan after each task
```

### Generic Agent Integration

For any AI coding agent:

1. **Load this guide** into your agent's context at session start
2. **Reference specific sections** using anchor links (e.g., `#quick-workflow`)
3. **Follow plan format** consistently across sessions
4. **Use absolute file paths** when referencing command files

---

## Reference Tables

### Command Quick Reference

| Task Type | Workflow | Command File | Time Estimate |
|-----------|----------|--------------|---------------|
| New feature | Full | `../commands/devloop.md` | 1-8 hours |
| Small fix | Quick | `../commands/quick.md` | 10-30 minutes |
| Exploration | Spike | `../commands/spike.md` | 30 min - 4 hours |
| Resume work | Continue | `../commands/continue.md` | Varies |
| Code review | Review | `../commands/review.md` | 15-45 minutes |

### File Locations

| Purpose | Primary Location | Fallbacks |
|---------|------------------|-----------|
| Plan file | `.claude/devloop-plan.md` | `docs/PLAN.md`, `PLAN.md` |
| Spike reports | `.claude/[topic]-spike-report.md` | Same directory |
| Project context | `.claude/project-context.json` | Root directory |
| Bug tracking | `.claude/bugs/*.md` | Same directory |

### Skills Reference

For specialized guidance on specific topics, the devloop plugin includes skills you can reference:

| Skill | Location | Purpose |
|-------|----------|---------|
| Plan Management | `../skills/plan-management/SKILL.md` | Plan format, updates, parallelism |
| Complexity Estimation | `../skills/complexity-estimation/SKILL.md` | T-shirt sizing, risk assessment |
| Git Workflows | `../skills/git-workflows/SKILL.md` | Branching, commits, PRs |
| Testing Strategies | `../skills/testing-strategies/SKILL.md` | Test patterns by language |
| Security Checklist | `../skills/security-checklist/SKILL.md` | OWASP, common vulnerabilities |
| Bug Tracking | `../skills/bug-tracking/SKILL.md` | Bug file format, workflow |

---

## Troubleshooting

### No Plan Found

1. Check `.claude/devloop-plan.md`
2. Search: `find . -name "*plan*.md" -o -name "PLAN.md"`
3. Ask user for plan location
4. Create new plan if starting fresh

### Plan Out of Sync

1. Read current plan file
2. Review `git status` and `git log`
3. Update plan with actual state
4. Mark completed tasks `[x]`
5. Update progress log with catch-up entry

### Unclear Requirements

1. **Don't guess** - ask questions
2. Use structured question format with clear options
3. Provide context for each option
4. Wait for answers before proceeding

### Task Too Complex

1. Suggest spike first to explore
2. Break into smaller phases
3. Mark tasks as `[parallel:X]` where possible
4. Focus on MVP first, enhancements later

### Tests Failing

1. Read test output carefully
2. Identify root cause
3. Fix issue following existing patterns
4. Re-run tests
5. Update plan with any discovered work

---

## Version History

- **1.0.0** (2025-12-17): Initial release
  - Full workflow documentation
  - Quick/Spike/Continue/Review workflow references
  - Plan management guidelines
  - Generic agent integration examples
  - Best practices and troubleshooting

---

## Additional Resources

### For Claude Code Users

If you have access to the Claude Code plugin, you can use these commands instead:
- `/devloop` - Guided full workflow
- `/devloop:quick` - Fast task implementation
- `/devloop:spike` - Technical exploration
- `/devloop:continue` - Resume from plan
- `/devloop:review` - Code review

This guide provides the same methodology for agents without plugin support.

### Related Documentation

- **Plugin Overview**: `../README.md`
- **All Commands**: `../commands/`
- **All Skills**: `../skills/`
- **Agent Details**: `../agents/`
- **Configuration**: `configuration.md`

---

## Summary

This guide enables any AI coding agent to follow structured devloop methodology:

1. **Choose the right workflow** for your task type
2. **Create and maintain a plan file** at `.claude/devloop-plan.md`
3. **Follow the command file** for detailed workflow steps
4. **Update the plan** after each task completion
5. **Reference skills** for specialized guidance

The key to success is maintaining the plan file as your source of truth and following existing codebase patterns consistently.
