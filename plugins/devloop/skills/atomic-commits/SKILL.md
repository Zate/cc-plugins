---
name: atomic-commits
description: This skill should be used for guidance on commit size, scope, and creating reviewable commits, splitting large changes, commit hygiene
whenToUse: Deciding when to commit, commit scope, atomic changes, splitting large PRs, commit hygiene, reviewable changes
whenNotToUse: Simple single-file changes, trivial fixes
seeAlso:
  - skill: git-workflows
    when: branching and PR strategy
  - skill: plan-management
    when: mapping tasks to commits
---

# Atomic Commits

Creating reviewable commits that capture logical units of work.

## Principles

1. **One logical change per commit**
2. **Commit compiles and tests pass**
3. **Commit message explains "why"**

## Devloop Integration

**Plan tasks map to commits:**

When using `/devloop:ship`, you can choose:
- **Single commit**: Squash all completed tasks
- **Atomic commits**: One commit per task

Example plan:
```markdown
- [x] Task 1.1: Create config skill
- [x] Task 1.2: Add parsing script
- [x] Task 1.3: Update session hook
```

Atomic commits would create:
```
feat(devloop): create local-config skill
feat(devloop): add config parsing script
feat(devloop): update session-start hook
```

## Commit Size Guidelines

| Size | Lines | When to Commit |
|------|-------|----------------|
| XS | <50 | Single fix, config change |
| S | 50-200 | One feature, one refactor |
| M | 200-500 | Feature with tests |
| L | >500 | Consider splitting |

**Devloop tasks** typically align with S-M size commits.

## Split Strategy

Instead of one large commit:
1. Refactor/prep commit
2. Core implementation commit
3. Tests commit
4. Documentation commit

**Or with devloop**: One commit per phase.

## Anti-Patterns

- WIP commits with broken code
- Mixing refactoring with features
- "Fix everything" commits
- Unrelated changes bundled

## When to Commit in Devloop

- After completing a plan phase
- Before running `/devloop:fresh`
- At checkpoints
- Before switching context
