# devloop

> **A development workflow where Claude does the work and you stay in control.**

[![Version](https://img.shields.io/badge/version-3.9.2-blue)](./CHANGELOG.md) [![Commands](https://img.shields.io/badge/commands-15-orange)](#commands) [![Agents](https://img.shields.io/badge/agents-7-green)](#agents) [![Skills](https://img.shields.io/badge/skills-14-purple)](#skills)

**What devloop gives you:**
- **Structured plans** that persist across sessions (`.devloop/plan.md`)
- **Context management** so Claude stays sharp (spike → fresh → run loop)
- **GitHub integration** for issue-driven development
- **Automation** with ralph-loop for hands-off execution

---

## Philosophy

devloop v3 is simple: **Claude does the work directly.**

No routine agent spawning. No model selection. No token optimization. Just you, Claude, and the code.

**Why this matters:**
- 10x less overhead than agent-heavy approaches
- Fresh context = better reasoning
- Plans survive sessions - pick up where you left off

Agents exist only for parallel work, security scans, and large codebase exploration.

---

## Quick Start

```bash
# Install
/plugin install devloop

# Initialize devloop in a new project (optional, auto-detects tech stack)
claude --init

# Create a plan with autonomous exploration
/devloop:plan "add user authentication"

# Execute plan autonomously (runs until complete)
/devloop:run

# Or for detailed exploration without immediate action
/devloop:plan --deep "should we use OAuth or JWT?"
```

### Project Initialization

For new projects, run `claude --init` to set up devloop:

```bash
claude --init
# Creates .devloop/ directory with:
#   - context.json (detected tech stack)
#   - local.md (local settings, not git-tracked)
#   - archive/ and spikes/ directories
```

This is optional - devloop will work without initialization, but `--init` provides better project context detection.

---

## Two Ways to Work

Choose the workflow that fits your task:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  AUTONOMOUS (default - recommended)                                     │
│                                                                         │
│  /devloop:plan "topic" → /devloop:run                                   │
│       ↓                      ↓                                          │
│  Explore & create plan   Execute until all tasks [x]                    │
│  (1-2 prompts max)       (auto-commits at phase boundaries)             │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  ISSUE-DRIVEN (GitHub-native teams)                                     │
│                                                                         │
│  /devloop:plan --from-issue 42 → /devloop:run                           │
│       ↓                              │                                  │
│  Fetch issue, explore, plan      Execute tasks autonomously             │
└─────────────────────────────────────────────────────────────────────────┘
```

| Workflow | Best For | Human Checkpoints |
|----------|----------|-------------------|
| /devloop:plan | Most work (quick to actionable) | 1-2 prompts |
| /devloop:plan --deep | Deep exploration (detailed reports) | 4-5 prompts |
| /devloop:plan --quick | Small, well-defined fixes | 0-1 prompts |
| /devloop:run --interactive | Complex decisions needed | Per task |

---

## Commands

| Command | Purpose |
|---------|---------|
| `/devloop` | Start development workflow (smart entry point) |
| `/devloop:plan` | **Autonomous exploration → actionable plan** (recommended) |
| `/devloop:plan --deep` | Deep exploration with spike report (replaces /devloop:spike) |
| `/devloop:plan --quick` | Fast implementation for small tasks (replaces /devloop:quick) |
| `/devloop:plan --from-issue N` | Start from GitHub issue (replaces /devloop:from-issue) |
| `/devloop:run` | **Execute plan autonomously** |
| `/devloop:fresh` | Save state for context restart |
| `/devloop:review` | Code review for changes or PR |
| `/devloop:ship` | Validation, commit, and PR creation |
| `/devloop:pr-feedback` | Integrate PR review comments into plan |
| `/devloop:archive` | Archive completed plan to .devloop/archive/ |
| `/devloop:issues` | List GitHub issues for the current repo |
| `/devloop:statusline` | Configure the devloop statusline |
| `/devloop:new` | Create a new issue (bug, feature, task) |
| `/devloop:help` | Interactive guide to using devloop |


---

## Agents

Seven specialized agents for complex parallel work:

| Agent | Purpose |
|-------|---------|
| `devloop:engineer` | Code exploration, architecture, refactoring, git, code review |
| `devloop:qa-engineer` | Test generation, execution, bug tracking |
| `devloop:task-planner` | Planning, requirements, issue management |
| `devloop:security-scanner` | OWASP Top 10, secrets, injection risks |
| `devloop:doc-generator` | READMEs, API docs, changelogs |
| `devloop:swarm-worker` | Autonomous task execution for swarm mode |
| `devloop:statusline-setup` | Configure statusline settings |

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

devloop works best with a simple cycle:

```
Plan → Run → [auto until done or context heavy] → Fresh → Run → ...
```

1. **Plan first** - Explore and create actionable plan (1-2 prompts)
2. **Run autonomously** - Tasks execute without manual intervention
3. **Fresh when needed** - Clear context if responses slow down

---

## Quick Reference

```bash
# Start new work (recommended)
/devloop:plan "add feature X"        # Autonomous explore → plan (1-2 prompts)
/devloop:plan --from-issue 42        # From GitHub issue with exploration
/devloop:plan --quick "fix small bug" # Skip planning for tiny tasks
/devloop:plan --deep "should we use X?" # Deep exploration with report

# Execute plan
/devloop:run                      # Autonomous execution (default)
/devloop:run --interactive        # With checkpoint prompts
/devloop:run --max-iterations 100 # Override iteration limit

# Manage context
/devloop:fresh && /clear          # Clear context, then...
/devloop:run                      # ...resume autonomously

# Finish work
/devloop:review                   # Review changes
/devloop:ship                     # Commit and create PR
/devloop:archive                  # Archive completed plan

# GitHub integration
/devloop:issues                   # Browse GitHub issues
```

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

Resume anytime with `/devloop:run`.

### Hybrid Task Tracking (Claude Code 2.1+)

devloop uses a hybrid approach for task tracking:

- **plan.md** - Persistent source of truth (survives sessions)
- **Native TaskCreate/TaskUpdate** - Real-time progress in Claude Code UI (session-scoped)

When `/devloop:run` starts, it can sync plan tasks to native tasks for live progress display. The plan.md remains authoritative - native tasks are for UI feedback only.

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

## GitHub Issues Integration (Optional)

Enable issue-driven development with `.devloop/local.md`:

```yaml
---
github:
  link-issues: true           # Enable issue linking
  auto-close: ask             # ask | always | never
  comment-on-complete: true   # Post summary to issue on completion
---
```

**Issue-driven workflow:**

1. `/devloop:plan --from-issue 123` - Fetch issue, create plan with link
2. Work on tasks, mark complete
3. On plan completion, post summary to issue
4. Optionally close the issue automatically

**Plan format with issue:**
```markdown
# Devloop Plan: Add dark mode

**Issue**: #123 (https://github.com/owner/repo/issues/123)
**Status**: In Progress
```

Completed plans are archived to `.devloop/archive/` with issue metadata preserved.

---

## Completed Plan Management

When all plan tasks are done, archive for team visibility:

```bash
# Manually archive completed plan
/devloop:archive

# Or it's offered automatically in /devloop:run and /devloop:ship
```

**Archive location:** `.devloop/archive/YYYY-MM-DD-{slug}.md`

Archives are git-tracked (shared with team) and include:
- Original plan content
- Completion metadata (date, task counts)
- Issue reference (if linked)

---

## Autonomous Execution

Run plan tasks automatically until completion with `/devloop:run`. Requires the [ralph-loop plugin](https://github.com/anthropics/claude-plugins/tree/main/plugins/ralph-loop).

```bash
# Install ralph-loop if not already installed
/plugin install ralph-loop

# Execute plan autonomously (default behavior)
/devloop:run

# With iteration limit
/devloop:run --max-iterations 100

# With checkpoint prompts
/devloop:run --interactive
```

**How it works:**
1. Creates ralph-loop state with completion promise "ALL PLAN TASKS COMPLETE"
2. Works through plan tasks, marking each `[x]` when done
3. Auto-commits at phase boundaries (if `auto_commit: true` in local.md)
4. When all tasks complete, outputs `<promise>ALL PLAN TASKS COMPLETE</promise>`
5. Ralph's Stop hook detects the promise and terminates the loop

**When to use `/devloop:run`:**
- Most development work (autonomous is the default)
- Well-defined plans from `/devloop:plan --deep`
- Overnight or background execution

**When to use `--interactive`:**
- Tasks requiring human decisions
- Creative or design work
- Evolving requirements

See `/devloop:help` → "Automation" for detailed documentation.

---

## Troubleshooting

### Plan file corrupted
Delete `.devloop/plan.md` and run `/devloop` to start fresh.

### Session ended unexpectedly
Run `/devloop:run` - it will pick up from the last checkpoint in your plan.

### Want to abandon current plan
Run `/devloop:archive` to archive a completed plan, then run `/devloop`.
Or delete `.devloop/plan.md` and run `/devloop`.

### Context feels heavy/slow
Run `/devloop:fresh`, then `/clear`, then `/devloop:run` to resume.

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
