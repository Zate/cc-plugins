---
name: git-workflows
description: This skill should be used for branching strategies, conventional commits, PR workflows, and release management, git flow, trunk-based development, merge strategies
when_to_use: Branching strategy, PR workflows, release management, merge decisions
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

## Worktree Patterns for Parallel Development

Git worktrees let you check out multiple branches simultaneously in separate directories.
devloop's `run-swarm` can leverage this natively for parallel task isolation.

### When devloop uses worktrees automatically

If you enable `git.worktree_isolation: true` in `.devloop/local.md` (or pass `--worktrees`
to `/devloop:run-swarm`), each swarm worker runs in its own temporary worktree:

```
main-working-tree/      ← your normal session
  .devloop/plan.md      ← orchestrator reads this
  src/...               ← main state

/tmp/claude-wt-abc123/  ← worker 1's isolated copy
  src/feature-a.ts      ← only worker 1 touches this

/tmp/claude-wt-def456/  ← worker 2's isolated copy
  src/feature-b.ts      ← only worker 2 touches this
```

After workers complete, the orchestrator merges each worktree branch back to your current branch.

### Configuration

```yaml
# .devloop/local.md
---
git:
  worktree_isolation: true   # Isolate run-swarm workers (default: false)
---
```

Or use the flag directly:
```bash
/devloop:run-swarm --worktrees
```

### Safe parallel development rules

1. **Assign non-overlapping file scopes to parallel tasks** — even with worktrees,
   overlapping edits to the same file require conflict resolution on merge-back.
2. **Orchestrator owns merging** — never commit or merge from inside a worker.
   Workers make changes; the orchestrator merges them.
3. **Worktrees share the git object store** — large binary files or LFS are shared
   efficiently; no duplication overhead.
4. **Auto-cleanup** — Claude Code removes worktrees with no changes automatically.
   Worktrees with changes persist until the orchestrator merges and deletes them.

### Conflict handling

When two parallel workers edit the same file, git detects the conflict during merge-back.
devloop's orchestrator will:
1. Abort the conflicting merge.
2. Ask you how to proceed via `AskUserQuestion`.
3. Options: resolve manually, skip the conflicting task's changes, or stop the swarm.

**Best practice**: Design parallel task groups (`[parallel:X]`) so each task owns
distinct files. This eliminates merge conflicts entirely.

### Manual worktree inspection (advanced)

If you need to inspect a worker's changes before merge-back:
```bash
git worktree list           # List all active worktrees
git diff main..<wt-branch>  # Diff between main and a worktree branch
git log <wt-branch>         # View worker's commits (if any)
```

## Safety Rules

Never on shared branches:
- Force push
- Rebase after push
- Reset after push
