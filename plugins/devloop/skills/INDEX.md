# Devloop Skills Index v3.2

Load skills on demand with `Skill: skill-name`. Don't preload.

## Core Workflow

| Skill | Purpose |
|-------|---------|
| `plan-management` | Working with .devloop/plan.md |
| `local-config` | Project settings via .devloop/local.md |
| `pr-feedback` | Integrating PR review comments into plan |

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

**Total**: 14 skills

## Cross-References

Skills now include `seeAlso` frontmatter pointing to related skills:
- `react-patterns` → `testing-strategies`, `architecture-patterns`, **frontend-design plugin**
- `api-design` → `security-checklist`, `architecture-patterns`, `database-patterns`
- `testing-strategies` → language-specific patterns

## External Plugin References

Some skills reference external plugins when installed:
- **`frontend-design`** (claude-plugins-official) - Referenced from `react-patterns` for UI design work

## Quick Reference

```
Skill: plan-management       # Plans
Skill: local-config          # Project config
Skill: pr-feedback           # PR review comments
Skill: go-patterns           # Go
Skill: react-patterns        # React/TS (→ see frontend-design plugin)
Skill: git-workflows         # Git
Skill: atomic-commits        # Commits
```
