# devloop

> **A development workflow where Claude does the work and you stay in control.**

[![Version](https://img.shields.io/badge/version-3.25.1-blue)](./CHANGELOG.md) [![Skills](https://img.shields.io/badge/skills-19-purple)](#skills) [![Agents](https://img.shields.io/badge/agents-6-green)](#agents)

**What devloop gives you:**
- **Structured plans** that persist across sessions (`.devloop/plan.md`)
- **Context management** so Claude stays sharp (plan → run → fresh loop)
- **GitHub integration** for issue-driven development
- **Automation** with ralph-loop for hands-off execution

---

## Philosophy

devloop v3.23 is simple: **Claude does the work directly, optimized by model selection.**

**What's new in v3.23:**
- **Model-aware planning** — tasks annotated `[model:haiku]` for cheap work, `[model:sonnet]` for complex reasoning
- **Parallel execution** — independent tasks grouped with `[parallel:X]` run concurrently
- **Cost efficiency** — 3-5x savings on mechanical tasks (tests, docs, formatting)

**Why this matters:**
- Fresh context = better reasoning
- Plans survive sessions — pick up where you left off
- Right model for the right task, automatically

Agents exist for parallel work, cost optimization, security scans, and large codebase exploration.

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

Six specialized agents for parallel and cost-optimized work:

| Agent | Model | Purpose |
|-------|-------|---------|
| `devloop:engineer` | sonnet | Code exploration, architecture, refactoring, git, code review |
| `devloop:qa-engineer` | sonnet | Test generation, execution, bug tracking |
| `devloop:security-scanner` | haiku | OWASP Top 10, secrets, injection risks |
| `devloop:doc-generator` | haiku | READMEs, API docs, changelogs |
| `devloop:swarm-worker` | sonnet | Autonomous task execution for swarm mode |
| `devloop:haiku-worker` | haiku | Lightweight executor for simple/mechanical tasks |

---

## Skills

Load on demand with `Skill: skill-name`:

**Reference**: plan-management, local-config, git-hygiene, pr-feedback, devloop-audit

Workflow commands (`/devloop:*`) are also implemented as skills — see `skills/INDEX.md` for the full list.

**Note**: As of v3.25.1, the language-pattern / design / quality skills (go-patterns, python-patterns, api-design, testing-strategies, security-checklist, etc.) have been removed. `atomic-commits` and `git-workflows` merged into `git-hygiene`. Generic language/design material is covered by Claude's training directly; task-specific guidance comes from `/devloop:plan`.

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

## Claude Code Native Integration

devloop v3.25 integrates directly with Claude Code's native capabilities for better code navigation, real-time output, and parallel safety.

### LSP (Language Server Protocol)

The `engineer`, `qa-engineer`, and `security-scanner` agents use LSP tools for precise symbol navigation:

```bash
# These work automatically when an LSP server is configured for your language:
# - LSP.goToDefinition / LSP.findReferences  (engineer, qa-engineer, security-scanner)
# - LSP.documentSymbol  (map module structure before refactoring or writing tests)
# - LSP.workspaceSymbol  (search symbols during planning)
```

Graceful fallback: if no LSP server is configured, agents silently fall back to `Grep`/`Glob`/`Read` — zero behavior change for users without LSP.

### Monitor (Real-time Output Streaming)

`run`, `run-epic`, and `run-swarm` use Monitor instead of Bash for long-running commands:

```bash
# These commands automatically use Monitor for real-time streaming:
npm test, pytest, go test ./..., cargo test  # Test suites
npm run build, tsc, make, cargo build        # Builds
eslint ., ruff check ., golangci-lint run   # Full-codebase linting
```

All other commands (git ops, devloop scripts, quick checks) still use Bash. Fallback: if Monitor errors, Bash is used directly.

### Worktree Isolation (run-swarm)

For large parallel tasks, each swarm worker can run in its own git worktree to prevent conflicts:

```bash
# Enable via CLI flag (one-time):
/devloop:run-swarm --worktrees

# Or enable permanently in .devloop/local.md:
git:
  worktree_isolation: true
```

After each batch, the orchestrator merges worktree branches back and handles any conflicts interactively. Off by default — standard swarm behavior is unchanged.

### Token Efficiency

Configure context gathering in `.devloop/local.md`:

```yaml
tokens:
  token_budget: 4000           # Max tokens per task context (default: 4000)
  cache_friendly_context: true # Order prompts for cache hits (default: true)
```

- **`token_budget`**: Controls how much context `gather-task-context.sh` collects per task. Lower (1000-2000) for lean runs; higher (8000-20000) for large codebases where more context helps.
- **`cache_friendly_context`**: Puts static prompt content first so repeated agent spawns get cache hits, reducing API costs.

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

## Migration from v3.17

v3.18 consolidated commands into flag-based modes:

| Old Command | New Command |
|-------------|-------------|
| `/devloop:spike` | `/devloop:plan --deep` |
| `/devloop:quick` | `/devloop:plan --quick` |
| `/devloop:from-issue N` | `/devloop:plan --from-issue N` |
| `/devloop:continue` | `/devloop:run --interactive` |
| `/devloop:ralph` | `/devloop:run` |

The old commands still work as aliases but are deprecated.

---

## Author

**Zate** - [@Zate](https://github.com/Zate)

## License

MIT License

---

<p align="center">
  <strong>Ship features, not excuses.</strong>
</p>
