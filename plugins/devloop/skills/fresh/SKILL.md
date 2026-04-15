---
name: fresh
description: Save current plan state and prepare for fresh context restart
when_to_use: "Restarting context while preserving plan state"
argument-hint: none
allowed-tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
---

# Fresh Start

Save the current devloop plan state for resuming after a context reset. **You do the work directly.**

## Step 1: Read Current Plan

Use the **Read** tool to read `.devloop/plan.md`.

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
2. Run /devloop:run to resume work
```

---

**Tip**: Before doing a full `/devloop:fresh` + `/clear`, try pressing `Esc+Esc` first. This triggers partial summarization which compresses your context without losing state — often enough to keep working without a restart.

**Note**: The next-action.json file is consumed (deleted) when `/devloop:run` runs.

---

## Token Efficiency & Fresh Threshold

The default `fresh_threshold` is 10 tasks. However, token-heavy workloads exhaust session context faster and benefit from a lower threshold.

**Recommended thresholds by workload**:

| Workload | Recommended `fresh_threshold` | Why |
|----------|------------------------------|-----|
| Sequential tasks (default) | 10 | One agent at a time, moderate context growth |
| Swarm (parallel workers) | 5-7 | Each spawn adds its full context; N parallel spawns = N× context cost |
| Large `token_budget` (8000+) | 5 | Heavy context per task exhausts budget sooner |
| 1M context model | 25-50 | Much larger budget; fresh restarts are less urgent |
| Epic phases (run-epic) | per-phase | Each phase uses a fresh subagent already; fresh is less needed |

**When to lower the threshold**:
- Running `/devloop:run-swarm` with 5+ concurrent workers per batch
- Using a high `tokens.token_budget` (>8000) in local.md
- Experiencing slow responses or context warnings before completing the plan

**When to raise the threshold**:
- Using a 1M-context model (configure `fresh_threshold: 25` or higher in `.devloop/local.md`)
- Sequential tasks with small, focused file changes

**Configure in `.devloop/local.md`**:
```yaml
---
fresh_threshold: 7        # Lower for swarm workloads
context_threshold: 70     # Exit ralph loop at this context %
tokens:
  token_budget: 4000      # Context per task affects how fast budget fills
---
```
