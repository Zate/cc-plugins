# Plan Enforcement Modes

Complete guide to configuring and using enforcement modes in devloop.

## Enforcement Configuration

Configure enforcement behavior in `.devloop/local.md`:

```yaml
---
enforcement: advisory    # advisory (default) | strict
auto_commit: true        # Prompt for commits after tasks
auto_version: true       # Suggest version bumps at phase completion
changelog: true          # Maintain CHANGELOG.md
auto_tag: false          # Create git tags (or prompt)
---
```

## Enforcement Modes

### Advisory Mode (default)

When plan is not updated after task completion:
```
⚠️ Warning: Plan file not updated for completed task.

The task appears complete but .devloop/plan.md
was not updated. This may cause sync issues.

Would you like to:
- Update now (Update the plan file)
- Continue anyway (Skip plan update)
- Review task (Verify completion status)
```

When changes are uncommitted:
```
⚠️ Warning: Uncommitted changes detected.

You have changes that may need to be committed.
Consider creating an atomic commit before proceeding.

Would you like to:
- Commit now (Create atomic commit)
- Continue (Keep changes uncommitted)
- Review changes (Show diff)
```

### Strict Mode

When plan is not updated:
```
🛑 Blocked: Plan update required.

Strict enforcement is enabled. Cannot proceed to next task
until .devloop/plan.md is updated.

Required actions:
1. Mark Task X.Y as [x] complete
2. Add Progress Log entry

Run the plan update now.
```

When changes are uncommitted at phase boundary:
```
🛑 Blocked: Commit required before phase transition.

Strict enforcement requires all work to be committed
before completing a phase.

Pending changes:
- [list of modified files]

Create a commit to proceed.
```

## Per-Project Settings

The `.devloop/local.md` file:
- Is project-specific (not committed to git)
- Has YAML frontmatter for settings
- Can include markdown notes/preferences
- Is read at session start and during enforcement checks

## Default Behavior

If no `.devloop/local.md` exists:
- `enforcement: advisory`
- `auto_commit: true` (prompts, doesn't auto-commit)
- `auto_version: true` (suggests, doesn't auto-bump)
- `changelog: true` (offers to update if exists)
- `auto_tag: false` (manual tagging)

## Enforcement Hooks

The devloop plugin includes hooks that implement enforcement:

**Pre-Commit Hook** (`hooks/pre-commit.sh`):
- Triggered before any `git commit` command
- Checks if plan has completed tasks without Progress Log entries
- In advisory mode: warns but allows commit
- In strict mode: blocks commit until plan is updated
- Checks `**Updated**:` timestamp (recent = approved)

**Post-Commit Hook** (`hooks/post-commit.sh`):
- Triggered after successful `git commit`
- Extracts commit hash and message
- Parses task references from commit message (e.g., "- Task 1.1")
- Updates worklog with commit entry
- Adds completed tasks to worklog's "Tasks Completed" section

**Hook Configuration**:
Hooks are configured in `plugins/devloop/hooks/hooks.json` and use the
`condition` field to match git commit commands specifically.
