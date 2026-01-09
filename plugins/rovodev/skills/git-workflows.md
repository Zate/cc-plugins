# Git Workflows for Rovo Dev CLI

Git operations, branching strategies, and commit conventions for the Rovo Dev CLI project.

## Conventional Commits

All commits should follow the conventional commit format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code formatting (no functional change)
- `refactor:` - Code restructuring (no functional change)
- `test:` - Adding or modifying tests
- `chore:` - Maintenance tasks (deps, build config, etc.)
- `perf:` - Performance improvements
- `ci:` - CI/CD changes

### Scopes (Common)

Project areas:
- `cli` - CLI commands and interface
- `auth` - Authentication/authorization
- `config` - Configuration handling
- `mcp` - MCP server functionality
- `api` - API endpoints
- `docs` - Documentation
- `deps` - Dependencies

### Examples

```bash
# Feature
git commit -m "feat(auth): implement JWT authentication

Add JWT token generation and validation with RS256 signing.
Includes middleware for protecting routes and refresh token support.

Closes: RDA-123"

# Bug fix
git commit -m "fix(cli): handle whitespace in directory paths

Use shlex.split() instead of str.split() to properly handle
paths containing spaces.

Fixes: RDA-456"

# Documentation
git commit -m "docs(readme): update installation instructions

Add uv version requirement and troubleshooting section."

# Refactoring
git commit -m "refactor(api): extract validation logic

Move validation functions to separate module for better
organization and testability."

# Tests
git commit -m "test(auth): add JWT validation edge cases

Cover expired tokens, malformed signatures, and missing claims."

# Chore
git commit -m "chore(deps): upgrade ruff to 0.2.0"
```

## Branch Naming

### Feature Branches
```bash
git checkout -b feat/jwt-authentication
git checkout -b feat/mcp-integration
```

### Bug Fix Branches
```bash
git checkout -b fix/whitespace-handling
git checkout -b fix/memory-leak
```

### Refactoring Branches
```bash
git checkout -b refactor/auth-module
git checkout -b refactor/test-structure
```

### Documentation Branches
```bash
git checkout -b docs/quickstart-guide
git checkout -b docs/api-reference
```

## Workflow Patterns

### Feature Development

```bash
# 1. Create feature branch
git checkout -b feat/new-feature

# 2. Make changes
# ... implement feature ...

# 3. Run tests
uv run pytest

# 4. Format code
uv run ruff format .

# 5. Stage changes
git add packages/cli/feature.py tests/test_feature.py

# 6. Commit
git commit -m "feat(cli): add new feature

Detailed description of the feature.

Closes: RDA-123"

# 7. Push
git push origin feat/new-feature

# 8. Create PR (via UI or CLI)
gh pr create --title "feat(cli): add new feature" --body "..."
```

### Bug Fix

```bash
# 1. Create fix branch
git checkout -b fix/bug-description

# 2. Write failing test first
# ... add test that reproduces bug ...

# 3. Fix bug
# ... implement fix ...

# 4. Verify fix
uv run pytest tests/test_specific.py -v

# 5. Commit
git commit -m "fix(component): fix bug description

Explanation of the bug and how it was fixed.

Fixes: RDA-456"

# 6. Push and PR
git push origin fix/bug-description
```

### Refactoring

```bash
# 1. Create refactor branch
git checkout -b refactor/area-name

# 2. Ensure tests exist
uv run pytest  # All should pass before refactoring

# 3. Refactor
# ... make changes ...

# 4. Verify tests still pass
uv run pytest  # All should still pass

# 5. Commit
git commit -m "refactor(area): improve code structure

Detailed explanation of refactoring changes.
No functional changes."

# 6. Push and PR
git push origin refactor/area-name
```

## Git Commands

### Checking Status

```bash
# View status
git status

# View diff
git diff

# View staged diff
git diff --cached

# View file history
git log --oneline -- path/to/file.py

# View recent commits
git log --oneline -n 10
```

### Staging Changes

```bash
# Stage specific files
git add path/to/file.py

# Stage all changes
git add -A

# Stage parts of a file (interactive)
git add -p path/to/file.py

# Unstage file
git restore --staged path/to/file.py
```

### Committing

```bash
# Commit staged changes
git commit -m "type(scope): description"

# Commit with body
git commit -m "type(scope): description

Detailed explanation of changes.

Closes: RDA-123"

# Amend last commit
git commit --amend

# Amend without changing message
git commit --amend --no-edit
```

### Branch Operations

```bash
# List branches
git branch

# Create branch
git checkout -b branch-name

# Switch branch
git checkout branch-name

# Delete branch
git branch -d branch-name

# Force delete
git branch -D branch-name

# Show current branch
git branch --show-current
```

### Remote Operations

```bash
# Push branch
git push origin branch-name

# Push with tracking
git push -u origin branch-name

# Pull changes
git pull

# Fetch without merge
git fetch

# Show remotes
git remote -v
```

### Undoing Changes

```bash
# Discard unstaged changes
git restore path/to/file.py

# Discard all unstaged changes
git restore .

# Unstage file
git restore --staged path/to/file.py

# Reset to last commit (dangerous!)
git reset --hard HEAD

# Reset last commit but keep changes
git reset --soft HEAD~1
```

## PR Workflow

### Creating a PR

```bash
# Using GitHub CLI
gh pr create \
  --title "feat(auth): JWT authentication" \
  --body "$(cat .devloop/plan.md)" \
  --base main

# Using Bitbucket API (in CI)
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "feat(auth): JWT authentication",
    "source": {"branch": {"name": "feat/jwt-auth"}},
    "destination": {"branch": {"name": "main"}},
    "description": "..."
  }' \
  "https://api.bitbucket.org/2.0/repositories/$WORKSPACE/$REPO/pullrequests"
```

### PR Description Template

```markdown
## Summary
Brief description of changes

## Changes
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Related
- Closes: RDA-123
- Related: RDA-456
```

## Commit Message Tips

### Good Commit Messages

```
✅ feat(auth): add JWT token validation

Implement JWT validation with RS256 signature verification.
Includes support for token expiration checking and claims validation.

Closes: RDA-123
```

### Bad Commit Messages

```
❌ fixed stuff
❌ WIP
❌ updates
❌ more changes
```

### Writing Good Messages

1. **Use imperative mood**: "add feature" not "added feature"
2. **Be specific**: What changed and why
3. **Keep subject < 72 chars**: Brief summary
4. **Add body for complex changes**: Explain context
5. **Reference issues**: Link to Jira tickets

## Branch Protection

### Main Branch

The `main` branch should be protected:
- Require PR reviews
- Require status checks to pass
- No force pushes
- No direct commits

### Working Branches

Feature/fix branches are temporary:
- Create from main
- Keep focused on single change
- Delete after merge

## Merge Strategy

### Squash and Merge (Recommended)

Combines all commits into one:
- Cleaner history
- Easier to revert
- Single conventional commit

### Merge Commit

Preserves all commits:
- Full history retained
- Can be noisy

## Local Configuration

Optional `.devloop/local.md` settings:

```yaml
git:
  auto-branch: true      # Auto-create feature branches
  branch-prefix: feat/   # Default branch prefix
  default-base: main     # Default base branch
```

## Tips

### Keep Commits Atomic

Each commit should:
- Represent one logical change
- Pass all tests
- Be revertable independently

### Write Commits for Reviewers

Good commits help reviewers:
- Understand what changed
- See why it changed
- Review in logical chunks

### Use Git Hooks

Optional hooks for quality:
- Pre-commit: Run formatters
- Pre-push: Run tests
- Commit-msg: Validate format

## Integration with Devloop

### Auto-branching

If `.devloop/local.md` has `git.auto-branch: true`, the `@rovodev` prompt will offer to create a feature branch automatically.

### Commit with @ship

The `@ship` prompt handles:
- Checking for uncommitted changes
- Running quality checks
- Generating conventional commits
- Pushing to remote
- Creating PRs

### Plan in Commits

Reference plan tasks in commits:
```
feat(auth): implement JWT validation

Completes Task 2.1 from .devloop/plan.md

Closes: RDA-123
```
