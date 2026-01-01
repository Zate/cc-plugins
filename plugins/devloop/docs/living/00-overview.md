# Devloop Overview

**A lightweight development workflow for AI-assisted software engineering.**

---

## What is Devloop?

Devloop is a Claude Code plugin that brings lightweight structure to AI-assisted development. It helps you work in focused loops—explore, plan, implement, checkpoint—without the overhead of complex orchestration.

### The Problem It Solves

When working with AI coding assistants, developers often face:

1. **Context Loss**: Long conversations become slow and confused
2. **No Structure**: Work happens ad-hoc without clear progress tracking
3. **Incomplete Work**: Tasks left half-done, no clear handoff
4. **Wasted Effort**: Over-engineering simple tasks

### The Devloop Solution

Devloop provides:

- **Simple Workflow**: Spike → Fresh → Continue pattern
- **Context Management**: Fresh start mechanism to prevent slowdown
- **Plan Files**: Persistent `.devloop/plan.md` that survives sessions
- **Checkpoints**: Natural pause points to commit or take breaks

---

## Core Philosophy

### 1. Claude Does the Work

Devloop v3.0 inverts the old pattern. Instead of spawning agents for everything:

- **Claude implements directly** - Write code, run tests, make commits
- **Skills load on-demand** - Only when specialized knowledge is needed
- **Subagents are rare** - Only for genuinely parallel or specialized work

### 2. Work in Loops, Not Lines

Complex features aren't completed in a single conversation. Devloop embraces this:

```
Spike → Fresh → Continue → [Work] → Fresh → Continue → [Work] → Ship
```

Each cycle:
- **Spike**: Explore and understand
- **Fresh**: Save state, clear context
- **Continue**: Resume with fresh focus
- **Ship**: Validate and commit

### 3. Minimal Overhead

Not everything needs complex orchestration:

| Task Size | Approach |
|-----------|----------|
| Small fix | `/devloop:quick` - Just do it |
| Feature | `/devloop` - Plan then implement |
| Exploration | `/devloop:spike` - Time-boxed discovery |

---

## Key Concepts

### Plans

Plans are markdown files (`.devloop/plan.md`) that:

- Define what needs to be built
- Track progress with checkboxes
- Survive session boundaries

```markdown
# User Authentication

## Tasks
- [x] Create user model
- [x] Add validation
- [ ] Write unit tests
- [ ] Add JWT tokens
```

### Fresh Starts

When context becomes heavy (5-10 tasks), take a fresh start:

1. Run `/devloop:fresh` - saves state to `.devloop/next-action.json`
2. Run `/clear` to reset conversation
3. Run `/devloop:continue` - automatically resumes

This keeps responses fast and reasoning sharp.

### Checkpoints

After significant progress, devloop asks:

1. **Continue**: Keep working
2. **Commit**: Save work with git commit
3. **Break**: Fresh start, resume later

---

## The Workflow

### Simple Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    Spike    │────▶│   Plan      │────▶│  Implement  │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                    ┌─────────────┐     ┌──────▼──────┐
                    │    Ship     │◀────│  Checkpoint │
                    └─────────────┘     └─────────────┘
```

### Commands

| Command | Purpose |
|---------|---------|
| `/devloop` | Start new work |
| `/devloop:continue` | Resume from plan |
| `/devloop:spike` | Time-boxed exploration |
| `/devloop:fresh` | Save state, prepare for context clear |
| `/devloop:quick` | Small, well-defined fixes |
| `/devloop:review` | Code review |
| `/devloop:ship` | Commit and/or PR |

---

## Quick Start

```bash
# Start with exploration
/devloop:spike How should we add user authentication?

# Save state and clear context
/devloop:fresh
/clear

# Resume work
/devloop:continue
```

That's it. No complex setup, no heavy orchestration.

---

## What's Different in v3.0

| Aspect | v2.x | v3.0 |
|--------|------|------|
| Who does work | Agents | Claude directly |
| Skills | Auto-loaded | On-demand |
| Hooks | Many prompt hooks | Minimal, command-only |
| Complexity | 12 phases | Simple loop |
| Cost | ~10x native | ~2-3x native |

---

## Next Steps

- [Principles](02-principles.md) - Design philosophy
- [Development Loop](03-development-loop.md) - Master the workflow
- [State Management](06-state-management.md) - How state persists
