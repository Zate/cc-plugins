# CLAUDE.md Template for Bootstrap

Use this template when generating CLAUDE.md from documentation artifacts.

## Template

```markdown
# [Project Name]

[Brief description from PRD/docs - 2-3 sentences max]

## Tech Stack

- **Language**: [chosen language]
- **Framework**: [chosen framework]
- **Database**: [if applicable]
- **Testing**: [test framework for stack]

## Project Structure

```
[project-name]/
├── [appropriate directories for stack]
└── ...
```

## Common Commands

```bash
# Development
[relevant command]  # Start dev server / run locally

# Testing
[relevant command]  # Run tests

# Building
[relevant command]  # Build for production
```

## Coding Conventions

- [Key convention 1 for the language]
- [Key convention 2 for the framework]
- [Any convention mentioned in docs]

## Architecture Notes

[Key architectural decisions from specs, or sensible defaults]

## Development Workflow (Devloop)

This project uses devloop for structured development.

### Key Commands
- `/devloop` - Start new feature (full workflow)
- `/devloop:continue` - Resume from plan
- `/devloop:quick` - Quick implementation for small tasks
- `/devloop:ship` - Commit and/or PR

### Task Completion Requirements
Before marking a task complete:
1. Implementation working
2. Tests pass (if applicable)
3. Plan updated (`.devloop/plan.md`)
4. Changes committed (atomic, reviewable commits)

### Commit Conventions
Use conventional commits: `type(scope): description`
- `feat:` new feature → MINOR version bump
- `fix:` bug fix → PATCH version bump
- `BREAKING CHANGE:` → MAJOR version bump

Include task reference: `feat(auth): add login - Task 2.1`

### Versioning
- Semantic versioning: MAJOR.MINOR.PATCH
- Version auto-detected from commits at phase/feature completion
- CHANGELOG updated with each release (if present)

### Plan Location
Active plan: `.devloop/plan.md`

## Branch Strategy

- Feature branches off main
- Tests required for new features
- [Any process from docs]
```

## Placeholder Guide

| Placeholder | Source |
|-------------|--------|
| `[Project Name]` | Extract from PRD title or ask user |
| `[Brief description]` | PRD summary or project overview section |
| `[chosen language]` | Tech stack determination phase |
| `[chosen framework]` | Tech stack determination phase |
| `[appropriate directories]` | Based on framework conventions |
| `[relevant command]` | Standard commands for chosen stack |
| `[Key convention]` | Language/framework best practices |
| `[Architecture notes]` | From specs or sensible defaults |

## Stack-Specific Defaults

### TypeScript + React
```yaml
testing: jest + @testing-library/react
structure: src/components, src/pages, src/hooks, src/services
commands:
  dev: npm run dev
  test: npm test
  build: npm run build
```

### TypeScript + Node/Express
```yaml
testing: jest or vitest
structure: src/routes, src/controllers, src/services, src/models
commands:
  dev: npm run dev
  test: npm test
  build: npm run build
```

### Python + FastAPI
```yaml
testing: pytest
structure: app/, tests/, alembic/
commands:
  dev: uvicorn app.main:app --reload
  test: pytest
  build: docker build
```

### Go
```yaml
testing: go test
structure: cmd/, internal/, pkg/
commands:
  dev: go run ./cmd/main.go
  test: go test ./...
  build: go build ./cmd/main.go
```
