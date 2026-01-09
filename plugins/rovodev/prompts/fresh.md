# Fresh - Save State for Context Reset

Save the current plan state for resuming after a context reset.

## When to Use

- **Context running low**: Need to reset conversation context
- **Switching work**: Pausing to work on something else
- **End of session**: Saving progress before logging off

## Process

### Step 1: Read Current Plan

```bash
cat .devloop/plan.md
```

If no plan exists, tell user to run `@rovodev` first.

### Step 2: Find Current Task

Identify the next pending task (first `- [ ]` in the plan).

Look for:
1. The phase name (e.g., "Phase 2: Implementation")
2. The specific task (e.g., "Task 2.1: Add validation layer")
3. Any context from recent progress log entries

### Step 3: Save State

Create `.devloop/next-action.json`:

```json
{
  "task": "Task 2.1: Add validation layer",
  "phase": "Phase 2: Implementation",
  "notes": "Started implementing validator classes, need to add tests",
  "saved_at": "2026-01-09 14:30"
}
```

**Fields**:
- `task`: Full task identifier and description
- `phase`: Current phase name from plan
- `notes`: Brief context about work in progress (1-2 sentences)
- `saved_at`: Current timestamp (YYYY-MM-DD HH:MM format)

### Step 4: Confirm

Tell user:

```
✓ State saved to .devloop/next-action.json

Next steps:
1. End this conversation or /clear to reset context
2. Start new conversation
3. Run @continue to resume work

Saved state:
- Task: [task description]
- Phase: [phase name]
- Notes: [context notes]
```

## What Gets Saved

**Saved**:
- Current task and phase
- Brief work-in-progress context
- Timestamp

**NOT saved** (still in plan.md):
- Complete task list
- Completed tasks
- Full progress log
- Plan metadata

The `next-action.json` is a **pointer** to help you quickly resume. The full plan stays in `plan.md`.

## Resume Flow

When user returns:

```bash
rovodev run "@continue"
```

The `@continue` prompt will:
1. Load `.devloop/next-action.json`
2. Load `.devloop/plan.md`
3. Show user where they left off
4. Delete `next-action.json` (consumed)
5. Resume work

## Example Usage

```bash
# Working on a feature...
rovodev run "@rovodev Add user authentication"
# ... implement some tasks ...

# Need to reset context
rovodev run "@fresh"
# ✓ State saved

# Later... 
rovodev run "@continue"
# Resuming from fresh start...
# Task: Implement JWT token validation
# Ready to continue? yes
```

## Notes

- `next-action.json` is **consumed** (deleted) when `@continue` runs
- If you run `@fresh` multiple times, it overwrites previous state
- The file is ignored by git (should be in `.gitignore`)
- If context is lost without `@fresh`, `@continue` can still resume from `plan.md`

---

**Ready to save state?**
