---
name: git-workflows
description: This skill should be used for branching strategies, conventional commits, PR workflows, and release management, git flow, trunk-based development, merge strategies
whenToUse: Branching strategy, commit formatting, PR descriptions, releases, git flow, trunk-based development, merge vs rebase, release tagging
whenNotToUse: Simple add/commit/push, established team conventions
seeAlso:
  - skill: atomic-commits
    when: commit scope decisions
---

# Git Workflows

Best practices for git branching and collaboration.

## Branch Naming

```
<type>/<ticket>-<description>
feature/AUTH-123-add-oauth
fix/BUG-456-null-pointer
```

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

## Merge Strategies

- **Merge commit**: Preserve full history
- **Squash merge**: Clean linear history
- **Rebase merge**: Linear, preserves commits

## Safety Rules

Never on shared branches:
- Force push
- Rebase after push
- Reset after push
