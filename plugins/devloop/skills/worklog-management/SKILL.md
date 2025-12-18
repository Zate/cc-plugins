---
name: worklog-management
description: Reference for managing the devloop worklog - a history of completed work with commit references. Documents format, update rules, and integration with the plan/commit workflow.
---

# Worklog Management

**Purpose**: The worklog (`devloop-worklog.md`) maintains a permanent history of completed work, separate from the active plan. While the plan shows what's in progress, the worklog shows what's done.

## When to Use This Skill

- After commits are made (to update worklog)
- When generating session summaries
- When onboarding to understand project history
- When creating release notes from completed work
- When reconstructing history for existing projects

## When NOT to Use This Skill

- During active task implementation (use plan instead)
- For tracking in-progress work (that's the plan's job)
- For uncommitted changes (wait for commit)

---

## File Location

```
.claude/devloop-worklog.md
```

**Git Status**: Tracked (committed to repository)

**Creation**: Created automatically on first commit after a plan exists, or manually via worklog reconstruction.

---

## Worklog Format

```markdown
# Devloop Worklog

**Project**: [project-name]
**Last Updated**: [YYYY-MM-DD HH:MM]

---

## [Feature/Epic Name] (vX.Y.Z)

**Period**: YYYY-MM-DD to YYYY-MM-DD
**Plan**: .claude/devloop-plan-[feature].md (archived)

### Commits

| Hash | Date | Message | Tasks |
|------|------|---------|-------|
| abc1234 | 2024-12-11 | feat: add user auth | 1.1, 1.2 |
| def5678 | 2024-12-11 | test: auth tests | 1.3 |
| ghi9012 | 2024-12-12 | feat: user profile | 2.1 |

### Tasks Completed

- [x] Task 1.1: Implement user authentication
- [x] Task 1.2: Add session management
- [x] Task 1.3: Write authentication tests
- [x] Task 2.1: Create user profile page

### Notes

[Optional: Notable decisions, learnings, or context for future reference]

---

## [Previous Feature] (vX.Y.Z)

...
```

---

## Relationship to Plan

```
Plan (devloop-plan.md)          Worklog (devloop-worklog.md)
┌─────────────────────┐         ┌──────────────────────────┐
│ Active Work         │         │ Completed Work           │
│                     │         │                          │
│ - [ ] Task pending  │         │ Feature A (v1.2.0)       │
│ - [~] Task active   │         │ - [x] Task 1.1 (abc123)  │
│ - [x] Task done     │───────▶│ - [x] Task 1.2 (abc123)  │
│                     │ commit  │                          │
│ Progress Log:       │         │ Feature B (v1.1.0)       │
│ - Completed task... │         │ - [x] Task 1.1 (def456)  │
└─────────────────────┘         └──────────────────────────┘
        ▲                                    │
        │                                    │
        └────── Reference for context ───────┘
```

**Key Principle**: The plan tracks what's happening now. The worklog tracks what happened.

---

## Update Triggers

### 1. Post-Commit Hook (Automatic)

When a commit succeeds, the post-commit hook should:
1. Read the plan's Progress Log entries
2. Find entries without commit hashes
3. Add them to worklog with the new commit hash
4. Mark entries in Progress Log as logged (add hash)

### 2. Phase Completion (Semi-Automatic)

When a phase completes:
1. Prompt to update worklog with phase summary
2. Group all phase commits together
3. Add to worklog under current feature section

### 3. Feature Completion (Manual Prompt)

When Status changes to "Complete":
1. Prompt to finalize worklog section
2. Archive the plan (optional)
3. Create section header with version number

---

## Worklog Entry Format

### Individual Task Entry

```markdown
- [x] Task X.Y: [Description] (commit-hash)
```

### Commit Table Entry

```markdown
| abc1234 | 2024-12-11 14:30 | feat(auth): add login - Task 1.1 | 1.1 |
```

### Section Header

```markdown
## User Authentication Feature (v1.2.0)

**Period**: 2024-12-10 to 2024-12-15
**Plan**: .claude/archived/devloop-plan-auth.md
```

---

## Workflow Integration

### After Each Commit

```
1. Get commit hash from `git rev-parse HEAD`
2. Get commit message from `git log -1 --format=%s`
3. Parse task reference from commit message (e.g., "- Task 1.1")
4. Add to worklog commit table:
   | {hash} | {date} | {message} | {tasks} |
5. Update "Last Updated" timestamp
```

### End of Session (Summary Generator)

```
1. Read worklog for completed work context
2. Read plan for in-progress context
3. Generate summary combining both
4. Worklog provides "what was accomplished"
```

### Session Start (Context Loading)

```
1. Read worklog to understand recent history
2. Read plan to understand current state
3. Display: "Last session: [recent worklog entries]"
4. Display: "Current: [active plan tasks]"
```

---

## Worklog Reconstruction

For projects adopting devloop with existing history:

### From Git Log

```bash
# Get recent commits with conventional format
git log --oneline --since="30 days ago" | \
  grep -E "^[a-f0-9]+ (feat|fix|docs|test|refactor):"
```

### Reconstruction Format

```markdown
## Historical Work (Pre-Devloop)

**Note**: Reconstructed from git history on YYYY-MM-DD

### Commits

| Hash | Date | Message |
|------|------|---------|
| abc1234 | 2024-11-15 | feat: initial API setup |
| def5678 | 2024-11-20 | fix: database connection |
...
```

### Via Command

```
/devloop:worklog reconstruct [--since="30 days ago"]
```

This will:
1. Parse git log for conventional commits
2. Group by date/feature (heuristic)
3. Create worklog with historical section
4. Mark as "reconstructed"

---

## Archive Workflow

When a feature is complete and you want to start fresh:

### 1. Finalize Worklog Section

```markdown
## User Authentication (v1.2.0) - COMPLETE

**Period**: 2024-12-10 to 2024-12-15
**Plan**: .claude/archived/devloop-plan-auth.md
**Release Notes**: See CHANGELOG.md for v1.2.0
```

### 2. Archive Plan (Optional)

```bash
mkdir -p .claude/archived
mv .claude/devloop-plan.md .claude/archived/devloop-plan-auth.md
```

### 3. Create New Plan

Start fresh with `/devloop` for the next feature.

---

## Integration Points

### Plan Management

- Worklog is updated when plan tasks are committed
- Plan's Progress Log entries flow to worklog with commit hashes

### Task Checkpoint

- After commit, task-checkpoint should trigger worklog update
- Checkpoint verifies worklog entry was created (in strict mode)

### Summary Generator

- Reads worklog as source of truth for "what was done"
- Reads plan for "what's in progress"

### Git Manager

- Provides commit hash for worklog entries
- Commit message format includes task references for parsing

---

## Quick Reference

| Action | Location | When |
|--------|----------|------|
| Create worklog | `.claude/devloop-worklog.md` | First commit with plan |
| Add commit entry | Commit table | Each commit |
| Add task entry | Tasks Completed list | Task committed |
| Update timestamp | Last Updated field | Any change |
| Start new section | New `## Feature` header | New plan started |
| Archive | Move to `.claude/archived/` | Feature complete |

---

## See Also

- `Skill: plan-management` - Active plan format and updates
- `Skill: task-checkpoint` - Task completion workflow
- `Skill: atomic-commits` - Commit timing and grouping
- `/devloop:worklog` - Command for worklog operations
