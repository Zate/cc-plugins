---
name: git-workflows
description: Git workflow patterns including branching strategies, commit conventions, code review, and release management. Use when managing git operations or establishing team workflows.
---

# Git Workflows

Best practices for git workflows, branching, and collaboration.

## Branching Strategies

### Git Flow
```
main ─────────────────────────────────────────►
       │                              ▲
       ▼                              │
develop ──┬─────────────┬─────────────┴──────►
          │             │
          ▼             ▼
    feature/a      feature/b
```
- **main**: Production code only
- **develop**: Integration branch
- **feature/***: New features
- **release/***: Release preparation
- **hotfix/***: Production fixes

**Best for**: Scheduled releases, multiple versions

### GitHub Flow
```
main ──────────────────────────────────────────►
       │         ▲          │         ▲
       ▼         │          ▼         │
    feature/a ───┘      feature/b ────┘
```
- **main**: Always deployable
- **feature/***: All changes via PR

**Best for**: Continuous deployment, small teams

### Trunk-Based Development
```
main ──────────────────────────────────────────►
       │    ▲    │    ▲    │    ▲
       └────┘    └────┘    └────┘
     (short-lived feature branches)
```
- **main**: Single source of truth
- Short-lived branches (< 1 day)
- Feature flags for incomplete work

**Best for**: Experienced teams, CI/CD mature

## Branch Naming

### Convention
```
<type>/<ticket>-<description>

feature/AUTH-123-add-oauth
fix/BUG-456-null-pointer
hotfix/critical-security-patch
docs/update-readme
chore/update-dependencies
refactor/simplify-auth-logic
```

### Types
| Type | Purpose |
|------|---------|
| feature/ | New functionality |
| fix/ | Bug fixes |
| hotfix/ | Critical production fixes |
| docs/ | Documentation only |
| chore/ | Maintenance tasks |
| refactor/ | Code improvement |
| test/ | Test additions |
| ci/ | CI/CD changes |

## Commit Conventions

### Conventional Commits
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Examples
```
feat(auth): add OAuth2 login support

Implement Google and GitHub OAuth providers.
Users can now sign in with existing accounts.

Closes #123

---

fix(api): handle null response from payment gateway

The gateway occasionally returns null instead of error.
Added defensive check and appropriate error handling.

Fixes #456

---

refactor(utils): extract date formatting to shared module

BREAKING CHANGE: DateUtils.format() signature changed.
Migration: Use DateUtils.formatDate() instead.
```

### Type Reference
| Type | Description | Semver |
|------|-------------|--------|
| feat | New feature | MINOR |
| fix | Bug fix | PATCH |
| docs | Documentation | - |
| style | Formatting | - |
| refactor | Code restructure | - |
| perf | Performance | PATCH |
| test | Tests | - |
| chore | Maintenance | - |
| ci | CI/CD | - |
| revert | Revert previous | varies |

### Commit Message Rules
- Subject line ≤ 72 characters
- Use imperative mood ("add" not "added")
- No period at end of subject
- Blank line before body
- Body explains "what" and "why"
- Reference issues in footer

## Pull Request Process

### PR Checklist
- [ ] Self-reviewed the code
- [ ] Added/updated tests
- [ ] Updated documentation
- [ ] No merge conflicts
- [ ] CI passing
- [ ] Meaningful title and description
- [ ] Linked related issues
- [ ] Requested appropriate reviewers

### PR Description Template
```markdown
## Summary
Brief description of changes

## Changes
- Change 1
- Change 2

## Testing
How to test these changes

## Screenshots
(if applicable)

## Related Issues
Closes #123
```

### PR Size Guidelines
| Lines Changed | Size | Review Time |
|---------------|------|-------------|
| < 50 | XS | Minutes |
| 50-200 | Small | < 1 hour |
| 200-500 | Medium | 1-2 hours |
| 500-1000 | Large | Half day |
| > 1000 | Too big | Split it |

## Code Review

### Reviewer Responsibilities
- [ ] Understand the context
- [ ] Check for correctness
- [ ] Look for edge cases
- [ ] Verify test coverage
- [ ] Check for security issues
- [ ] Assess maintainability
- [ ] Provide constructive feedback

### Review Comment Prefixes
| Prefix | Meaning |
|--------|---------|
| **nit:** | Minor style/preference |
| **suggestion:** | Non-blocking improvement |
| **question:** | Seeking understanding |
| **issue:** | Must be addressed |
| **praise:** | Good work callout |

### Good Review Comments
```
❌ "This is wrong"
✅ "This could cause a null pointer if user.address is undefined.
    Consider adding a check: user?.address?.city"

❌ "Use a different approach"
✅ "Consider using Array.find() here instead of filter()[0]
    for better readability and early exit"
```

## Merge Strategies

### Merge Commit
```
git merge --no-ff feature-branch
```
- Preserves full history
- Clear branch structure
- More cluttered history

### Squash Merge
```
git merge --squash feature-branch
```
- Clean linear history
- Loses individual commits
- Good for small features

### Rebase Merge
```
git rebase main
git merge --ff-only feature-branch
```
- Linear history
- Preserves commits
- Rewrites history (don't use on shared branches)

### When to Use What
| Strategy | Use When |
|----------|----------|
| Merge | Default, preserve history |
| Squash | Many WIP commits, clean history |
| Rebase | Linear history required |

## Release Management

### Semantic Versioning
```
MAJOR.MINOR.PATCH

1.0.0 → 1.0.1  # Patch: bug fixes
1.0.1 → 1.1.0  # Minor: new features (backwards compatible)
1.1.0 → 2.0.0  # Major: breaking changes
```

### Release Checklist
- [ ] All tests passing
- [ ] Version bumped
- [ ] CHANGELOG updated
- [ ] Documentation updated
- [ ] Release notes written
- [ ] Tagged release
- [ ] Deployed to staging
- [ ] Smoke tests passed
- [ ] Deployed to production

### Tag Naming
```
v1.0.0
v1.0.0-beta.1
v1.0.0-rc.1
```

## Common Operations

### Undo Last Commit (not pushed)
```bash
git reset --soft HEAD~1  # Keep changes staged
git reset --mixed HEAD~1 # Keep changes unstaged
git reset --hard HEAD~1  # Discard changes
```

### Fix Last Commit Message
```bash
git commit --amend -m "New message"
```

### Interactive Rebase
```bash
git rebase -i HEAD~3
# pick, squash, reword, edit, drop
```

### Cherry Pick
```bash
git cherry-pick <commit-hash>
```

### Stash
```bash
git stash
git stash pop
git stash list
git stash apply stash@{1}
```

## Safety Rules

### Never Do on Shared Branches
- Force push (`git push -f`)
- Rebase after push
- Reset after push
- Amend after push

### Before Destructive Operations
- Create backup branch
- Confirm with team
- Document what you're doing
- Know how to recover

## See Also

- `Skill: security-checklist` - Secure git practices
- `Skill: testing-strategies` - CI/CD testing
- `Skill: api-design` - Versioning APIs
