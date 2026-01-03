# devloop

**Claude does the work. You stay in control.**

[![Version](https://img.shields.io/badge/version-3.2.0-blue)](./CHANGELOG.md) [![Commands](https://img.shields.io/badge/commands-8-orange)](#commands) [![Agents](https://img.shields.io/badge/agents-6-green)](#agents) [![Skills](https://img.shields.io/badge/skills-12-purple)](#skills)

---

## Philosophy

devloop v3 is simple: **Claude does the work directly.**

No routine agent spawning. No model selection. No token optimization. Just you, Claude, and the code.

Agents exist only for:
- **Parallel work**: Multiple independent tasks running simultaneously
- **Security scans**: Full codebase security audits
- **Large exploration**: Understanding 50+ files in unfamiliar codebases

For everything else, Claude reads files, writes code, runs tests, and commits - directly.

---

## Quick Start

```bash
# Install
/plugin install devloop

# Start with a spike to understand and plan
/devloop:spike How should we add user authentication?

# Save state and clear context
/devloop:fresh
/clear

# Resume and work
/devloop:continue

# Repeat fresh → continue every 5-10 tasks
```

---

## Commands

| Command | Purpose |
|---------|---------|
| `/devloop` | Start development workflow |
| `/devloop:continue` | Resume work from plan |
| `/devloop:spike` | Technical exploration/POC |
| `/devloop:fresh` | Save state for context restart |
| `/devloop:quick` | Fast implementation for small tasks |
| `/devloop:review` | Code review for changes or PR |
| `/devloop:ship` | Validation and git integration |
| `/devloop:help` | Interactive guide to using devloop |

---

## Agents

Six specialized agents for complex parallel work:

| Agent | Purpose |
|-------|---------|
| `devloop:engineer` | Code exploration, architecture, refactoring, git |
| `devloop:qa-engineer` | Test generation, execution, bug tracking |
| `devloop:task-planner` | Planning, requirements, issue management |
| `devloop:code-reviewer` | Quality review with confidence filtering |
| `devloop:security-scanner` | OWASP Top 10, secrets, injection risks |
| `devloop:doc-generator` | READMEs, API docs, changelogs |

---

## Skills

Load domain knowledge on demand with `Skill: skill-name`:

**Workflow**: plan-management, git-workflows, atomic-commits

**Patterns**: go-patterns, python-patterns, react-patterns, java-patterns

**Design**: api-design, architecture-patterns, database-patterns

**Quality**: testing-strategies, security-checklist

See `skills/INDEX.md` for full documentation.

---

## The Loop

devloop works best with an iterative cycle:

```
Spike → Fresh → /clear → Continue → [5-10 tasks] → Fresh → ...
```

1. **Spike first** - Understand the problem, create a solid plan
2. **Fresh regularly** - Clear context every 5-10 tasks
3. **Continue seamlessly** - Pick up exactly where you left off

---

## Plan Management

Plans live in `.devloop/plan.md`:

```markdown
# Devloop Plan: User Authentication

**Status**: In Progress

## Phase 1: Core
- [x] Task 1: Set up OAuth provider
- [ ] Task 2: Implement login flow
- [ ] Task 3: Add session management
```

Resume anytime with `/devloop:continue`.

---

## Troubleshooting

### Plan file corrupted
Delete `.devloop/plan.md` and run `/devloop` to start fresh.

### Session ended unexpectedly
Run `/devloop:continue` - it will pick up from the last checkpoint in your plan.

### Want to abandon current plan
Delete `.devloop/plan.md` or rename it, then run `/devloop`.

### Context feels heavy/slow
Run `/devloop:fresh`, then `/clear`, then `/devloop:continue`.

### Skill not loading
Check `skills/INDEX.md` for the exact skill name. Use `Skill: exact-name`.

---

## Author

**Zate** - [@Zate](https://github.com/Zate)

## License

MIT License

---

<p align="center">
  <strong>Ship features, not excuses.</strong>
</p>
