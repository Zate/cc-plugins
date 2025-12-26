---
name: atomic-commits
description: This skill should be used when the user asks about "commit size", "when to commit", "commit scope", "atomic commits", or needs guidance on creating reviewable commits that capture logical units of work.
whenToUse: |
  - Deciding whether to commit after completing a task
  - Determining if multiple tasks should be grouped
  - Planning how to structure commits for a feature
  - Reviewing commit size and scope before committing
  - Understanding commit atomicity principles
whenNotToUse: |
  - Commit message formatting - use git-workflows
  - Branch strategy decisions - use git-workflows
  - Exploratory/spike work where commits are less important
  - Trivial single-file changes
---

# Atomic Commits Skill

Guidance for creating reviewable, atomic commits that capture logical units of work.

## When to Use This Skill

- Deciding whether to commit after completing a task
- Determining if multiple tasks should be grouped
- Planning commit structure for a feature
- Reviewing commit size and scope

## When NOT to Use This Skill

- Commit message formatting (use `Skill: git-workflows`)
- Branch strategy decisions (use `Skill: git-workflows`)
- Exploratory/spike work (commits less important)

---

## Core Principle: Reviewable Commits

Every commit should be:
1. **Reviewable**: Someone can understand it in 5-15 minutes
2. **Atomic**: One logical change, not multiple unrelated changes
3. **Buildable**: Project compiles/builds after the commit
4. **Testable**: Tests pass (or are intentionally skipped with note)
5. **Revertable**: Can be reverted without breaking unrelated features

---

## Quick Reference

### Commit Decision Matrix

| Scenario | Decision | Rationale |
|----------|----------|-----------|
| Single file, < 50 lines | Commit | Trivially reviewable |
| Single feature implementation | Commit | Self-contained unit |
| Feature + its unit tests | **Group → 1 commit** | Logically coupled |
| Backend API endpoint | Commit separately | Self-contained |
| Frontend consuming that API | Separate commit | Different concern |
| Database migration | Commit alone | High-risk, isolated review |
| Refactoring across files | Commit alone | Isolate risk |
| Bug fix | Commit alone | Clear history for bisecting |
| Multiple bug fixes | Separate commits | Each independently revertable |

### Size Guidelines

```
50-200 lines  → Ideal (easy to review)
200-300 lines → Acceptable (clear structure needed)
300-500 lines → Warning (consider splitting)
> 500 lines   → Red flag (must split unless rare exception)
```

---

## References

For detailed guidance on specific topics, load these references:

| Reference | Content |
|-----------|---------|
| `references/commit-sizing.md` | Detailed sizing rules, grouping criteria, decision flow |
| `references/examples.md` | Commit examples, task references, anti-patterns |
| `references/parallel-tasks.md` | Parallel task handling, phase boundaries |

### Loading References

```
Read: plugins/devloop/skills/atomic-commits/references/commit-sizing.md
Read: plugins/devloop/skills/atomic-commits/references/examples.md
Read: plugins/devloop/skills/atomic-commits/references/parallel-tasks.md
```

---

## Integration

This skill is used by:
- `Skill: task-checkpoint` - Commit decision during task completion
- `/devloop:continue` - After task execution
- `/devloop:ship` - Before shipping a feature

Related:
- `Skill: git-workflows` - Commit message conventions
- `Skill: plan-management` - Task tracking in plan file
