---
name: git-hygiene
description: This skill should be used for commit strategy, branch naming, conventional commits, PR workflow, and merge decisions in devloop
when_to_use: Preparing to commit, splitting a large change, naming a branch, deciding a merge strategy, integrating PR feedback
---

# Git Hygiene

Branching, commit, and merge practices wired to the devloop workflow.

## Devloop Integration

Configure git behavior in `.devloop/local.md`:

```yaml
---
git:
  auto-branch: true           # Create branch when plan starts
  branch-pattern: "feat/{slug}"
  pr-on-complete: ask         # ask | always | never

commits:
  style: conventional         # conventional | simple
---
```

**Related commands:**
- `/devloop:ship` — commit with plan context, create PR
- `/devloop:pr-feedback` — integrate PR review comments into plan.md

**Plan tasks map to commits.** `/devloop:ship` offers:
- **Single commit** — squash all completed tasks into one.
- **Atomic commits** — one commit per task, using the task description as the message subject.

Plan task example:
```markdown
- [x] Task 1.1: Create config skill
- [x] Task 1.2: Add parsing script
- [x] Task 1.3: Update session hook
```

Atomic equivalent:
```
feat(devloop): create local-config skill
feat(devloop): add config parsing script
feat(devloop): update session-start hook
```

## Commit Principles

1. **One logical change per commit** — a reviewer should understand the diff in isolation.
2. **Commit compiles and tests pass** — never check in broken WIP on a shared branch.
3. **Message explains "why"**, not "what" — the diff already shows what.

### Size guidelines

| Size | Lines | When |
|------|-------|------|
| XS   | <50   | Single fix, config change |
| S    | 50–200  | One feature, one refactor |
| M    | 200–500 | Feature with tests |
| L    | >500  | Consider splitting |

Devloop tasks typically land in the S–M range.

### Split strategy for large changes

Rather than one mega-commit:
1. Refactor / preparation commit
2. Core implementation commit
3. Tests commit
4. Docs commit

Or, inside devloop: one commit per phase.

### Anti-patterns

- WIP commits with broken code on shared branches
- Mixing refactor + feature + fix in one commit
- "fix everything" catch-all commits
- Unrelated changes bundled

## Conventional Commits

```
<type>(<scope>): <subject>

feat(auth): add OAuth2 login
fix(api): handle null response body
refactor(utils): extract date formatting
```

| Type     | Description         | Version bump |
|----------|---------------------|--------------|
| feat     | New feature        | MINOR |
| fix      | Bug fix            | PATCH |
| refactor | Internal change    | PATCH |
| docs     | Documentation only | PATCH |
| test     | Tests              | PATCH |
| chore    | Maintenance        | PATCH |

`/devloop:ship` auto-generates conventional-format messages from plan tasks.

## Branch Naming

```
<type>/<ticket>-<description>
feat/AUTH-123-add-oauth
fix/BUG-456-null-pointer
feat/add-authentication          # devloop default when no ticket
```

## Trunk-Based Development

Favoured default for fast-shipping teams:

1. Short-lived feature branches (hours to days).
2. Frequent merges to `main` via PRs.
3. Strong CI/CD pipeline catches regressions.
4. Feature flags hide incomplete work.

Devloop fit: plan → branch → implement → `/devloop:ship` → PR.

## PR Workflow

1. Create a branch when the plan starts.
2. Commit as you complete tasks (atomic or phase-squashed).
3. `/devloop:ship` when ready to open the PR.
4. Address feedback via `/devloop:pr-feedback` — it pulls the review comments into plan.md as new tasks.
5. Push fixes, re-request review, merge.

## Merge Strategies

| Strategy       | When                                             |
|----------------|--------------------------------------------------|
| Merge commit   | Preserve full history, multi-contributor branches |
| Squash merge   | Clean linear history (recommended for feature PRs) |
| Rebase merge   | Linear history but preserve individual commits     |

## Safety Rules

Never on shared / remote branches:
- `git push --force` (use `--force-with-lease` if you must, and confirm first)
- Rebase after push
- Reset after push

Never on `main` / `master`:
- Force push, period.

## When to Commit in a Devloop Session

- After completing a plan phase
- Before running `/devloop:fresh` (preserves progress across a `/clear`)
- At any checkpoint before switching context
- Before context-heavy operations (large refactors, multi-file edits)

## Parallel Development (run-swarm)

`run-swarm` can isolate workers in git worktrees to prevent conflicts. That behavior is documented inline in `run-swarm/SKILL.md` — see Step 4b-4c there. Key rule: design `[parallel:X]` task groups so each task owns distinct files; this eliminates merge conflicts entirely.
