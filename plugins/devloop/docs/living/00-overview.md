# Devloop Overview

**A lightweight development workflow for AI-assisted software engineering.**

---

## What is Devloop?

Devloop is a Claude Code plugin that brings structure to AI-assisted development. Work in focused loops—explore, plan, implement, checkpoint—without complex orchestration.

**Core benefits:**
- **Simple Workflow**: Spike → Fresh → Continue pattern
- **Context Management**: Fresh starts prevent slowdown
- **Plan Files**: Persistent `.devloop/plan.md` survives sessions
- **Checkpoints**: Natural pause points to commit or break

---

## Philosophy

### Claude Does the Work

- **Claude implements directly** - Write code, run tests, commits
- **Skills load on-demand** - Only when specialized knowledge is needed
- **Subagents are rare** - Only for parallel or specialized work

### Work in Loops

```
Spike → Fresh → Continue → [Work] → Fresh → Continue → Ship
```

### Minimal Overhead

| Task Size | Approach |
|-----------|----------|
| Small fix | `/devloop:quick` |
| Feature | `/devloop` |
| Exploration | `/devloop:spike` |

---

## Commands

| Command | Purpose |
|---------|---------|
| `/devloop` | Start new work |
| `/devloop:continue` | Resume from plan |
| `/devloop:spike` | Time-boxed exploration |
| `/devloop:fresh` | Save state for context clear |
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

---

## Plans

Plans live at `.devloop/plan.md`:

```markdown
# User Authentication

## Tasks
- [x] Create user model
- [ ] Add validation
- [ ] Write unit tests
```

After 5-10 tasks, run `/devloop:fresh` + `/clear` + `/devloop:continue`.

---

## Next Steps

- [Architecture](01-architecture.md) - Plugin structure
- [Principles](02-principles.md) - Design philosophy
- [Development Loop](03-development-loop.md) - Master the workflow
