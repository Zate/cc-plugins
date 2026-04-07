# Devloop Skills Index v5.0

Load skills on demand with `Skill: skill-name`. Don't preload.

## Workflow Commands

These are user-invocable slash commands (`/devloop:<name>`):

| Skill | Purpose |
|-------|---------|
| `devloop` | Smart entry point - detects state, suggests actions |
| `plan` | Create actionable plan with autonomous exploration |
| `run` | Execute plan tasks autonomously |
| `run-swarm` | Execute plan tasks via fresh-context subagents |
| `fresh` | Save plan state for fresh context restart |
| `ship` | Validate and commit/PR completed work |
| `review` | Comprehensive code review |
| `pr-feedback` | Fetch and integrate PR review comments |
| `new` | Create GitHub issue (or local with --local) |
| `issues` | List GitHub issues |
| `archive` | Archive completed plan |
| `help` | Interactive guide to devloop |
| `statusline` | Configure devloop statusline |

## Core Reference Skills

| Skill | Purpose |
|-------|---------|
| `plan-management` | Working with .devloop/plan.md |
| `local-config` | Project settings via .devloop/local.md |

## Maintenance

| Skill | Purpose |
|-------|---------|
| `devloop-audit` | Audit devloop against Claude Code updates |

## Explicit-Load Skills

These skills provide domain knowledge but don't auto-trigger. Load explicitly with `Skill: skill-name` when needed.

### Language Patterns

| Skill | Purpose |
|-------|---------|
| `go-patterns` | Go idioms, error handling, testing |
| `python-patterns` | Python best practices, pytest, Django/Flask/FastAPI |
| `react-patterns` | React/TypeScript, hooks, components, Next.js |
| `java-patterns` | Java/Spring patterns, Kotlin, Maven/Gradle |

### Development

| Skill | Purpose |
|-------|---------|
| `git-workflows` | Git operations, branching, merge strategies |
| `atomic-commits` | Commit best practices, splitting PRs |
| `testing-strategies` | Test design patterns, TDD, mocking |
| `architecture-patterns` | System design, SOLID, refactoring |
| `api-design` | REST/GraphQL API design, versioning |
| `database-patterns` | Database design, SQL, ORM patterns |

### Quality

| Skill | Purpose |
|-------|---------|
| `security-checklist` | Security review, OWASP, vulnerability prevention |

---

**Total**: 27 skills (13 workflow commands + 14 reference skills)

## Superpowers Integration

Devloop and superpowers are complementary plugins with distinct lanes:

| Lane | Plugin | Focus |
|------|--------|-------|
| **Workflow orchestration** | devloop | Plan, run, fresh, ship cycle |
| **Quality practices** | superpowers | TDD, debugging, verification, code review |

### When to use which

| Task | Use |
|------|-----|
| "Plan and implement feature X" | `/devloop:plan` -> `/devloop:run` |
| "Write tests first, then implement" | `superpowers:test-driven-development` |
| "Debug this failing test" | `superpowers:systematic-debugging` |
| "Review my changes" | `/devloop:review` (quick) or `superpowers:requesting-code-review` (thorough) |
| "Commit and create PR" | `/devloop:ship` |

### Cross-references

| Devloop Skill | Superpowers Skill | When to Use |
|---------------|-------------------|-------------|
| `testing-strategies` | `superpowers:test-driven-development` | Writing tests first, rigorous TDD |
| `git-workflows` | `superpowers:using-git-worktrees` | Parallel feature development |
| `git-workflows` | `superpowers:finishing-a-development-branch` | Completing work, merge decisions |
| `architecture-patterns` | `superpowers:systematic-debugging` | Debugging complex issues |

**Note**: Superpowers is NOT required. Devloop works fully standalone.

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
