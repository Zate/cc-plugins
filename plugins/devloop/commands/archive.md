---
description: Archive a completed plan to .devloop/archive/
argument-hint: "[--force]"
allowed-tools:
  - Read
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - AskUserQuestion
---

# Archive - Move Completed Plan to Archive

Archive a completed plan to `.devloop/archive/` and clear the active plan. **You do the work directly.**

## Step 1: Check Plan Status

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md
```

Parse the JSON output to get task counts.

**If no plan exists:**
```
No active plan to archive.
Run /devloop or /devloop:plan to create a new plan.
```

**If plan has pending tasks:**
Show status and ask:

```yaml
AskUserQuestion:
  questions:
    - question: "Plan has N pending tasks. Archive anyway?"
      header: "Incomplete"
      multiSelect: false
      options:
        - label: "Archive anyway"
          description: "Force archive incomplete plan"
        - label: "Continue work"
          description: "Keep working on pending tasks"
        - label: "Cancel"
          description: "Don't archive"
```

## Step 2: Show What Will Be Archived

Read the plan header to show the user:

```bash
head -20 .devloop/plan.md
```

Display:
```
Plan to archive:
  Title: [Plan title]
  Tasks: N completed / M total
  Created: [date]

Archive destination: .devloop/archive/YYYY-MM-DD-{slug}.md
```

## Step 3: Confirm Archive

```yaml
AskUserQuestion:
  questions:
    - question: "Archive this completed plan?"
      header: "Confirm"
      multiSelect: false
      options:
        - label: "Archive now"
          description: "Move plan to archive, clear active plan"
        - label: "Cancel"
          description: "Keep plan active"
```

## Step 4: Execute Archive

If confirmed (or --force in arguments):

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/archive-plan.sh" .devloop/plan.md
```

If user selected "Archive anyway" for incomplete plan:
```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/archive-plan.sh" .devloop/plan.md --force
```

Parse the JSON output.

## Step 5: Report Result

**On success:**
```
Plan archived successfully!

  Archived to: .devloop/archive/YYYY-MM-DD-{slug}.md
  Tasks completed: N

Next steps:
  - /devloop:plan --deep "topic"  - Start new exploration
  - /devloop               - Start new plan directly
  - git add .devloop/archive/  - Commit archive to git
```

**On failure:**
```
Archive failed: [error message]
```

---

## Quick Reference

| Scenario | Action |
|----------|--------|
| Plan complete | Archive directly |
| Plan incomplete | Ask before force-archive |
| No plan | Show error message |
| --force argument | Skip confirmation |
