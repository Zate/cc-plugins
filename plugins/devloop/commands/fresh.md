---
description: Save current plan state and prepare for fresh context restart
argument-hint: none
allowed-tools: ["Read", "Write", "Bash", "AskUserQuestion"]
---

# Fresh Start

Save the current devloop plan state for resuming after a context reset. **You do the work directly.**

## Step 1: Read Current Plan

```bash
cat .devloop/plan.md
```

If no plan exists, tell user to run `/devloop` first.

## Step 2: Find Current Task

Identify the next pending task (first `- [ ]` in the plan).

## Step 3: Save State

Write to `.devloop/next-action.json`:

```json
{
  "task": "Task X.Y: Description",
  "phase": "Current Phase Name",
  "notes": "Any context about work in progress",
  "saved_at": "YYYY-MM-DD HH:MM"
}
```

## Step 4: Confirm

Tell user:

```
State saved to .devloop/next-action.json

Next steps:
1. Run /clear to reset context
2. Run /devloop:continue to resume work
```

---

**Note**: The next-action.json file is consumed (deleted) when `/devloop:continue` runs.
