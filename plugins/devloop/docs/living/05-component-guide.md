# Component Guide

What's in devloop v3.21.

---

## Skills (Slash Commands)

| Command | Purpose |
|---------|---------|
| `/devloop` | Start development workflow |
| `/devloop:plan` | Unified planning (default mode) |
| `/devloop:plan --deep` | Deep exploration with spike report |
| `/devloop:plan --quick` | Fast implementation for small tasks |
| `/devloop:plan --from-issue N` | Start from GitHub issue |
| `/devloop:run` | Autonomous plan execution |
| `/devloop:run-swarm` | Swarm execution for 10+ tasks |
| `/devloop:fresh` | Save state for context restart |
| `/devloop:review` | Code review for changes or PR |
| `/devloop:ship` | Validation and git integration |
| `/devloop:pr-feedback` | Integrate PR review comments |
| `/devloop:archive` | Archive completed plan |
| `/devloop:issues` | List GitHub issues |
| `/devloop:new` | Create GitHub issue |
| `/devloop:statusline` | Configure statusline |
| `/devloop:help` | Interactive guide |

---

## Agents (5)

For parallel work and specialized scans.

| Agent | Purpose |
|-------|---------|
| `devloop:engineer` | Code exploration, architecture, git, code review |
| `devloop:qa-engineer` | Test generation, execution, bugs |
| `devloop:security-scanner` | OWASP Top 10, secrets |
| `devloop:doc-generator` | READMEs, API docs, changelogs |
| `devloop:swarm-worker` | Autonomous task execution for swarm mode |

**Remember**: Claude does work directly. Agents only for parallel tasks.

---

## Reference Skills (14)

Load on-demand with `Skill: skill-name`.

### Core
- `plan-management` - Plan file conventions
- `local-config` - Project settings via .devloop/local.md
- `devloop-audit` - Audit against Claude Code updates

### Workflow
- `git-workflows` - Branching, commits, releases
- `atomic-commits` - Commit strategy

### Patterns
- `go-patterns` - Go idioms
- `python-patterns` - Python best practices
- `react-patterns` - React/TypeScript patterns
- `java-patterns` - Spring, streams, DI

### Design
- `api-design` - REST, GraphQL, versioning
- `architecture-patterns` - System design
- `database-patterns` - Schema, queries, migrations

### Quality
- `testing-strategies` - Test pyramid, coverage
- `security-checklist` - OWASP, auth, secrets

See `skills/INDEX.md` for full catalog.

---

## Hooks

### SessionStart
Detects project context, plan status, git branch, PR status.

### Context Guard (Stop)
Auto-exits ralph loop when context exceeds threshold.

### Files
- `hooks/hooks.json` - Hook configuration
- `hooks/session-start.sh` / `.ps1` - Session initialization
- `hooks/context-guard.sh` / `.ps1` - Context guard

---

## Statusline

Real-time display: Model | Context % | Tokens | Path | Branch | Plan progress | Bugs

- `statusline/devloop-statusline.sh` / `.ps1`

---

## State Files

| File | Purpose | Git tracked? |
|------|---------|--------------|
| `.devloop/plan.md` | Active plan | No (ephemeral) |
| `.devloop/next-action.json` | Fresh start state | No |
| `.devloop/worklog.md` | Completed work history | Yes |
| `.devloop/local.md` | Local settings | No |
| `.devloop/context.json` | Tech stack cache | Yes |
| `.claude/context-usage.json` | Context % for guard | No |

---

## Next Steps

- [State Management](06-state-management.md)
- [Contributing](07-contributing.md)
