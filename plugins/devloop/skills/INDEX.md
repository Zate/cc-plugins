# Devloop Skills Index v4.0

Load skills on demand with `Skill: skill-name`. Don't preload.

## Workflow Commands

These are user-invocable slash commands (`/devloop:<name>`):

| Skill | Purpose | User-only? |
|-------|---------|------------|
| `devloop` | Smart entry point - detects state, suggests actions | No |
| `plan` | Create actionable plan with autonomous exploration | No |
| `run` | Execute plan tasks autonomously | Yes |
| `run-swarm` | Execute plan tasks via fresh-context subagents | Yes |
| `fresh` | Save plan state for fresh context restart | Yes |
| `ship` | Validate and commit/PR completed work | Yes |
| `review` | Comprehensive code review | No |
| `pr-feedback` | Fetch and integrate PR review comments | No |
| `new` | Create GitHub issue (or local with --local) | No |
| `issues` | List GitHub issues | No |
| `archive` | Archive completed plan | Yes |
| `help` | Interactive guide to devloop | No |
| `statusline` | Configure devloop statusline | Yes |

"User-only" = `disable-model-invocation: true` (won't auto-trigger, only via `/devloop:<name>`)

## Core Reference Skills

| Skill | Purpose |
|-------|---------|
| `plan-management` | Working with .devloop/plan.md |
| `local-config` | Project settings via .devloop/local.md |

## Maintenance

| Skill | Purpose |
|-------|---------|
| `devloop-audit` | Audit devloop against Claude Code updates |

## Language Patterns

| Skill | Purpose | Also Triggers On |
|-------|---------|------------------|
| `go-patterns` | Go idioms, error handling, testing | golang, .go files |
| `python-patterns` | Python best practices, pytest | Django, Flask, FastAPI, pandas |
| `react-patterns` | React/TypeScript, hooks, components | Next.js, frontend TS, JSX/TSX |
| `java-patterns` | Java/Spring patterns | Kotlin, Spring Boot, Maven, Gradle |

## Development

| Skill | Purpose | Also Triggers On |
|-------|---------|------------------|
| `git-workflows` | Git operations, branching | git flow, trunk-based, merge strategies |
| `atomic-commits` | Commit best practices | splitting PRs, commit hygiene |
| `testing-strategies` | Test design patterns | TDD, BDD, mocking, test doubles |
| `architecture-patterns` | System design patterns | SOLID, clean code, refactoring |
| `api-design` | REST/GraphQL API design | backend routes, HTTP endpoints |
| `database-patterns` | Database design | SQL, PostgreSQL, MySQL, ORM |

## Quality

| Skill | Purpose |
|-------|---------|
| `security-checklist` | Security review, OWASP, vulnerability prevention |

---

**Total**: 27 skills (13 workflow commands + 14 reference skills)

## Superpowers Integration

When the `superpowers` plugin is installed, devloop skills link to complementary superpowers skills:

| Devloop Skill | Superpowers Skill | When to Use |
|---------------|-------------------|-------------|
| `testing-strategies` | `superpowers:test-driven-development` | Writing tests first, rigorous TDD |
| `git-workflows` | `superpowers:using-git-worktrees` | Parallel feature development |
| `git-workflows` | `superpowers:finishing-a-development-branch` | Completing work, merge decisions |
| `architecture-patterns` | `superpowers:systematic-debugging` | Debugging complex issues |

**Note**: Superpowers skills are NOT required. Devloop works standalone. These are optional enhancements.

## Quick Reference

```
# Workflow commands
/devloop             # Smart entry point
/devloop:plan        # Create plan
/devloop:run         # Execute plan
/devloop:ship        # Commit/PR

# Reference skills (load on demand)
Skill: plan-management       # Plans
Skill: local-config          # Project config
Skill: go-patterns           # Go
Skill: react-patterns        # React/TS
Skill: git-workflows         # Git
```
