---
name: git-workflows
description: This skill should be used for branching strategies, conventional commits, PR workflows, and release management, git flow, trunk-based development, merge strategies
---

# Git Workflows

Best practices for git branching and collaboration.

## Devloop Integration

Configure git workflow in `.devloop/local.md`:

```yaml
---
git:
  auto-branch: true           # Create branch when plan starts
  branch-pattern: "feat/{slug}"
  pr-on-complete: ask         # ask | always | never
---
```

**Related commands:**
- `/devloop:ship` - Commit with plan context, create PR
- `/devloop:pr-feedback` - Integrate review comments

## Branch Naming

```
<type>/<ticket>-<description>
feat/AUTH-123-add-oauth
fix/BUG-456-null-pointer
feat/add-authentication    (devloop default)
```

## Trunk-Based Development (Recommended)

Modern approach favored by high-performing teams:

1. Short-lived feature branches (hours to days)
2. Frequent merges to main via PRs
3. Strong CI/CD pipeline
4. Feature flags for incomplete work

**Devloop fit**: Plan → Branch → Implement → Ship → PR

## Conventional Commits

```
<type>(<scope>): <description>

feat(auth): add OAuth2 login support
fix(api): handle null response
refactor(utils): extract date formatting
```

| Type | Description |
|------|-------------|
| feat | New feature (MINOR) |
| fix | Bug fix (PATCH) |
| docs | Documentation |
| refactor | Code restructure |
| test | Tests |
| chore | Maintenance |

**Devloop auto-generates** commit messages from plan tasks using conventional format.

## PR Workflow

1. Create branch when starting plan
2. Commit as you complete tasks
3. Run `/devloop:ship` when ready
4. Address feedback with `/devloop:pr-feedback`
5. Push fixes and re-request review

## Merge Strategies

- **Merge commit**: Preserve full history
- **Squash merge**: Clean linear history (recommended for feature PRs)
- **Rebase merge**: Linear, preserves commits

## Safety Rules

Never on shared branches:
- Force push
- Rebase after push
- Reset after push
