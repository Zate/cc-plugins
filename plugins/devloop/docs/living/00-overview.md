# Devloop Overview

**A complete, token-conscious feature development workflow for professional software engineering.**

---

## What is Devloop?

Devloop is a Claude Code plugin that brings structure, efficiency, and reliability to software development with AI assistants. It transforms the often chaotic process of AI-assisted coding into a methodical, repeatable workflow that mirrors how senior engineers approach complex features.

### The Problem It Solves

When working with AI coding assistants, developers often face:

1. **Context Loss**: Long conversations become slow and confused
2. **Workflow Chaos**: No clear structure for complex multi-file changes
3. **Incomplete Work**: Tasks left half-done, no clear handoff
4. **Token Waste**: Using expensive models for simple tasks
5. **State Management**: No way to pause and resume work

### The Devloop Solution

Devloop provides:

- **Structured Workflow**: 12-phase process from requirements to shipping
- **Context Management**: Fresh start mechanism to prevent slowdown
- **Plan-Driven Development**: Persistent plans that survive session boundaries
- **Intelligent Routing**: Right model (opus/sonnet/haiku) for each task
- **Checkpoints**: Mandatory verification after every task

---

## Core Philosophy

### 1. Commands Orchestrate, Agents Assist

Devloop inverts the typical AI assistant pattern. Instead of giving an AI full control:

- **Commands** control the workflow and stay visible to the user
- **Agents** are specialized helpers invoked for specific subtasks
- **Users** always see what's happening and can intervene

### 2. Work in Loops, Not Lines

Complex features aren't completed in a single conversation. Devloop embraces this:

```
Spike → Fresh → Continue → [Work] → Fresh → Continue → [Work] → Ship
```

Each cycle:
- **Spike**: Explore and plan
- **Fresh**: Save state, clear context
- **Continue**: Resume with fresh focus
- **Ship**: Validate and commit

### 3. Token Consciousness

Not all tasks need the same intelligence level:

| Task Type | Model | Token Cost |
|-----------|-------|------------|
| Classification, checklists | haiku | Low |
| Implementation, exploration | sonnet | Medium |
| Architecture, complex decisions | opus | High |

Devloop automates this selection using a **20/60/20 strategy**:
- 20% opus for high-stakes decisions
- 60% sonnet for core development
- 20% haiku for routine tasks

---

## Key Concepts

### Plans

Plans are the heart of devloop. They're markdown files (`.devloop/plan.md`) that:

- Define what needs to be built
- Break work into phases and tasks
- Track progress with checkboxes
- Survive session boundaries

```markdown
# Devloop Plan: User Authentication

**Status**: In Progress
**Current Phase**: Implementation

## Tasks

### Phase 1: Foundation
- [x] Task 1.1: Create user model
- [~] Task 1.2: Add validation (partial)
- [ ] Task 1.3: Write unit tests
```

### Checkpoints

After every task completion, devloop asks:

1. **Continue**: Move to next task
2. **Commit**: Save work with atomic commit
3. **Fresh start**: Clear context, resume later
4. **Stop**: End session with summary

This ensures nothing falls through the cracks.

### Fresh Starts

When context becomes heavy (5-10 tasks), devloop suggests a fresh start:

1. Current state is saved to `.devloop/next-action.json`
2. User runs `/clear` to reset conversation
3. Running `/devloop:continue` automatically resumes

This keeps responses fast and reasoning sharp.

---

## The Workflow

Devloop provides a 12-phase workflow for complex features:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  0. Triage  │────▶│ 1. Discovery│────▶│ 2. Estimate │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
┌─────────────┐     ┌─────────────┐     ┌──────▼──────┐
│ 5. Architect│◀────│4. Clarify   │◀────│ 3. Explore  │
└──────┬──────┘     └─────────────┘     └─────────────┘
       │
┌──────▼──────┐     ┌─────────────┐     ┌─────────────┐
│  6. Plan    │────▶│ 7. Implement│────▶│  8. Test    │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
┌─────────────┐     ┌─────────────┐     ┌──────▼──────┐
│ 11. Git     │◀────│10. Validate │◀────│  9. Review  │
└──────┬──────┘     └─────────────┘     └─────────────┘
       │
       ▼
┌─────────────┐
│ 12. Summary │
└─────────────┘
```

**You don't need all phases**. Use:
- `/devloop:quick` for small tasks
- `/devloop:spike` for exploration
- `/devloop:review` for code review

---

## Quick Start

```bash
# Install devloop
/plugin install devloop

# Best pattern: spike → fresh → continue
/devloop:spike How should we add user authentication?
/devloop:fresh
/clear
/devloop:continue
```

That's it. Devloop guides you through the rest.

---

## Next Steps

- [Architecture](01-architecture.md) - Understand how devloop is built
- [The Development Loop](03-development-loop.md) - Master the spike → fresh → continue pattern
- [Principles](02-principles.md) - Learn the design philosophies

---

## Related Files

- Plugin manifest: `.claude-plugin/plugin.json`
- Main README: `../README.md`
- Changelog: `../CHANGELOG.md`
