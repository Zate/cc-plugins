---
name: atomic-commits
description: This skill should be used for guidance on commit size, scope, and creating reviewable commits, splitting large changes, commit hygiene
whenToUse: Deciding when to commit, commit scope, atomic changes, splitting large PRs, commit hygiene, reviewable changes
whenNotToUse: Simple single-file changes, trivial fixes
seeAlso:
  - skill: git-workflows
    when: branching and PR strategy
---

# Atomic Commits

Creating reviewable commits that capture logical units of work.

## Principles

1. **One logical change per commit**
2. **Commit compiles and tests pass**
3. **Commit message explains "why"**

## Commit Size Guidelines

| Size | Lines | When to Commit |
|------|-------|----------------|
| XS | <50 | Single fix, config change |
| S | 50-200 | One feature, one refactor |
| M | 200-500 | Feature with tests |
| L | >500 | Consider splitting |

## Split Strategy

Instead of one large commit:
1. Refactor/prep commit
2. Core implementation commit
3. Tests commit
4. Documentation commit

## Anti-Patterns

- WIP commits with broken code
- Mixing refactoring with features
- "Fix everything" commits
- Unrelated changes bundled
