# Component Guide

What's in devloop v3.1.0.

---

## Commands

| Command | Purpose |
|---------|---------|
| `/devloop` | Start development workflow |
| `/devloop:plan` | Unified planning (default mode) |
| `/devloop:plan --deep` | Deep exploration with spike report |
| `/devloop:plan --quick` | Fast implementation for small tasks |
| `/devloop:plan --from-issue N` | Start from GitHub issue |
| `/devloop:run` | Autonomous plan execution |
| `/devloop:fresh` | Save state for context restart |
| `/devloop:review` | Code review for changes or PR |
| `/devloop:ship` | Validation and git integration |

---

## Agents (6)

For parallel work and specialized scans.

| Agent | Purpose |
|-------|---------|
| `devloop:engineer` | Code exploration, architecture, git, code review |
| `devloop:qa-engineer` | Test generation, execution, bugs |
| `devloop:task-planner` | Planning, requirements, issues |
| `devloop:security-scanner` | OWASP Top 10, secrets |
| `devloop:doc-generator` | READMEs, API docs, changelogs |

**Remember**: Claude does work directly. Agents only for parallel tasks.

---

## Skills (12)

Load on-demand with `Skill: skill-name`.

### Workflow
- `plan-management` - Plan file conventions
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

Detects project context and shows plan status.

### Files

- `hooks/hooks.json` - Hook configuration
- `hooks/session-start.sh` - Session initialization

---

## State Files

| File | Purpose |
|------|---------|
| `.devloop/plan.md` | Active plan |
| `.devloop/next-action.json` | Fresh start state |

---

## Next Steps

- [State Management](06-state-management.md)
- [Contributing](07-contributing.md)
