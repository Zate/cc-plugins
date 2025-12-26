# Git Mode Reference

**Purpose**: Commits, branches, PRs, history management
**Token impact**: Loaded on-demand when Git mode is active

## Operations Overview

| Operation | Description |
|-----------|-------------|
| Commits | Create conventional commit messages |
| Branches | Proper naming and management |
| Pull Requests | Comprehensive descriptions |
| History | Rebase, squash when appropriate |

## Conventional Commits

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(auth): add JWT validation` |
| `fix` | Bug fix | `fix(api): handle null response` |
| `docs` | Documentation | `docs(readme): update installation` |
| `style` | Formatting only | `style: fix indentation` |
| `refactor` | Code restructure | `refactor(user): extract service` |
| `perf` | Performance | `perf(query): add index` |
| `test` | Tests only | `test(auth): add unit tests` |
| `chore` | Maintenance | `chore(deps): update packages` |
| `ci` | CI/CD changes | `ci: add GitHub Actions` |

### Scope

Optional, indicates affected component:
- Feature name: `auth`, `payment`, `user`
- Module: `api`, `cli`, `web`
- Layer: `handler`, `service`, `repo`

### Description

- Imperative mood: "add" not "added" or "adds"
- Lowercase, no period at end
- Max 50 characters

### Body (Optional)

- Explain **why**, not what (code shows what)
- Wrap at 72 characters
- Blank line between subject and body

### Footer (Optional)

- Breaking changes: `BREAKING CHANGE: description`
- Issue references: `Refs: #42`
- Co-authors: `Co-authored-by: Name <email>`

## Task-Linked Commits

When invoked with task context from devloop:

```
feat(auth): implement JWT tokens - Task 2.1

Added JWT token generation with RS256 signing.
Integrated with existing middleware chain.

Refs: #42
```

Format: `<type>(<scope>): <description> - Task X.Y`

## Branch Naming

### Patterns

| Pattern | Example | When |
|---------|---------|------|
| `feature/<name>` | `feature/add-authentication` | New features |
| `fix/<issue>` | `fix/null-pointer-123` | Bug fixes |
| `refactor/<area>` | `refactor/user-service` | Refactoring |
| `docs/<topic>` | `docs/api-reference` | Documentation |
| `chore/<task>` | `chore/update-deps` | Maintenance |

### Rules

- Use kebab-case
- Keep descriptive but concise
- Include issue number when applicable: `fix/123-null-pointer`

## Pull Request Format

```markdown
## Summary
<1-3 bullet points describing what this PR does>

## Changes
- [x] Added authentication middleware
- [x] Updated user routes
- [x] Added integration tests

## Test Plan
- [ ] Unit tests pass locally
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)
<Before/after screenshots for UI changes>

## Notes
<Any additional context, decisions made, or future work>
```

## Git Safety Constraints

**CRITICAL**: These rules must always be followed.

| Constraint | Rule |
|------------|------|
| Force Push | Never force push to main/master |
| History | Confirm before any history modification |
| Uncommitted | Check for uncommitted changes before branch operations |
| Branch Exists | Verify branch exists before checkout |
| Amend | Only amend if commit not pushed to remote |

## Output Format

```markdown
## Git Operation Complete

**Operation**: Commit
**Branch**: feature/add-authentication
**Commit**: `a3f5b2c`

### Commit Message
```
feat(auth): implement JWT authentication middleware - Task 3.2

Added JWT token validation middleware with RS256 signing.
Integrated with existing error handling patterns.

Files changed:
- middleware/auth.go (new)
- routes/routes.go (modified)
- config/jwt.go (new)
```

### Changes Summary
- 3 files changed: 2 new, 1 modified
- +187 lines added
- Tests: All passing

### Next Steps
1. Run integration tests
2. Update API documentation
3. Create PR to main branch
```

## Token Budget

**Max 200 tokens** for git summaries.

Keep concise:
- List key files changed (max 5)
- Summarize changes in 1-2 sentences
- Provide clear next steps

## Common Git Workflows

### Feature Branch Flow

```bash
# Create feature branch
git checkout -b feature/my-feature main

# Work and commit
git add .
git commit -m "feat(scope): description"

# Push and create PR
git push -u origin feature/my-feature
gh pr create --title "feat: description" --body "..."
```

### Fix and Squash

```bash
# Create fix branch
git checkout -b fix/issue-123 main

# Make multiple commits during development
git commit -m "wip: initial fix"
git commit -m "wip: add tests"
git commit -m "wip: cleanup"

# Squash before PR
git rebase -i HEAD~3
# Change "pick" to "squash" for commits to combine

# Push
git push -u origin fix/issue-123
```

### Sync with Main

```bash
# Update main
git checkout main
git pull

# Rebase feature branch
git checkout feature/my-feature
git rebase main

# Force push if needed (feature branch only!)
git push --force-with-lease
```

## When Not to Use Git Mode

- **Uncommitted changes need review**: Use code-reviewer first
- **Need to verify tests pass**: Use qa-engineer first
- **Complex history rewrite**: Escalate to user for confirmation
