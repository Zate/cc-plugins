# devloop

**Claude does the work. You stay in control.**

[![Version](https://img.shields.io/badge/version-3.5.0-blue)](./CHANGELOG.md) [![Commands](https://img.shields.io/badge/commands-10-orange)](#commands) [![Agents](https://img.shields.io/badge/agents-6-green)](#agents) [![Skills](https://img.shields.io/badge/skills-14-purple)](#skills)

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
| `/devloop:ship` | Validation, commit, and PR creation |
| `/devloop:pr-feedback` | Integrate PR review comments into plan |
| `/devloop:ralph` | Automated execution with ralph-loop |
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

**Workflow**: plan-management, local-config, pr-feedback, git-workflows, atomic-commits

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
**Branch**: feat/add-authentication

## Phase 1: Core
- [x] Task 1: Set up OAuth provider
- [ ] Task 2: Implement login flow
- [ ] Task 3: Add session management
```

Resume anytime with `/devloop:continue`.

---

## Git Workflow (Optional)

Enable branch-aware workflow with `.devloop/local.md`:

```yaml
---
git:
  auto-branch: true           # Create branch when plan starts
  pr-on-complete: ask         # ask | always | never

commits:
  style: conventional         # conventional | simple

review:
  before-commit: ask          # ask | always | never
---
```

**Full workflow:**

1. `/devloop` - Creates plan + feature branch
2. Work on tasks, commit with `/devloop:ship`
3. Create PR when ready
4. Get feedback, integrate with `/devloop:pr-feedback`
5. Push fixes, merge

All git features are opt-in. Without `local.md`, devloop works without git integration.

---

## Ralph Loop Integration (Automated Execution)

Run plan tasks automatically until completion with the [ralph-loop plugin](https://github.com/anthropics/claude-plugins/tree/main/plugins/ralph-loop).

```bash
# Install ralph-loop if not already installed
/plugin install ralph-loop

# Start automated execution
/devloop:ralph

# With iteration limit
/devloop:ralph --max-iterations 100
```

**How it works:**
1. Creates ralph-loop state with completion promise "ALL PLAN TASKS COMPLETE"
2. Works through plan tasks, marking each `[x]` when done
3. When all tasks complete, outputs `<promise>ALL PLAN TASKS COMPLETE</promise>`
4. Ralph's Stop hook detects the promise and terminates the loop

**Context Guard (v3.5.0):**
The loop automatically exits when context usage exceeds 70%, preventing context degradation during long runs. Configure the threshold in `.devloop/local.md`:

```yaml
---
context_threshold: 80  # Exit at 80% instead of default 70%
---
```

**When to use:**
- Well-defined plans from `/devloop:spike`
- Overnight or background execution
- Clear, implementable tasks

**When NOT to use:**
- Tasks requiring human decisions
- Creative or design work
- Evolving requirements (use manual spike/fresh/continue instead)

See `/devloop:help` → "Automation" for detailed documentation.

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
