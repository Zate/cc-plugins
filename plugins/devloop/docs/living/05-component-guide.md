# Component Guide

What's in devloop v3.23.

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

## Agents (6)

For parallel work, cost optimization, and specialized scans.

| Agent | Model | Purpose |
|-------|-------|---------|
| `devloop:engineer` | sonnet | Code exploration, architecture, git, code review |
| `devloop:qa-engineer` | sonnet | Test generation, execution, bugs |
| `devloop:security-scanner` | haiku | OWASP Top 10, secrets |
| `devloop:doc-generator` | haiku | READMEs, API docs, changelogs |
| `devloop:swarm-worker` | sonnet | Autonomous task execution for swarm mode |
| `devloop:haiku-worker` | haiku | Lightweight executor for simple/mechanical tasks |

**Remember**: Claude does work directly. Agents for parallel tasks and cost optimization.

---

## Reference Skills (14)

Load on-demand with `Skill: skill-name`.

### Core
- `plan-management` - Plan file conventions
- `local-config` - Project settings via .devloop/local.md
- `git-hygiene` - Commit strategy, branch naming, PR workflow, merge decisions
- `devloop-audit` - Audit against Claude Code updates
- `pr-feedback` - Integrate PR review comments

See `skills/INDEX.md` for full catalog.

**Note**: As of v3.25.1, language-pattern / design / quality reference skills (go-patterns, python-patterns, api-design, testing-strategies, security-checklist, etc.) were removed. `atomic-commits` and `git-workflows` were merged into `git-hygiene`. Generic language/design material is covered by Claude's training directly.

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
