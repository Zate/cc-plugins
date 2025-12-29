---
description: Archive completed phases from plan.md to compress active plan and rotate Progress Log to worklog
argument-hint: Optional phase numbers to archive (e.g., "1 2" to archive Phase 1 and 2)
allowed-tools: [
  "Bash", "AskUserQuestion",
  "Bash(${CLAUDE_PLUGIN_ROOT}/scripts/archive-interactive.sh:*)"
]
---

# Archive Plan

Archive completed phases from `.devloop/plan.md` to reduce file size and improve `/devloop:continue` performance.

## Execution

Run the archive-interactive script:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/archive-interactive.sh [plan-file]
```

**Exit codes:**
- `0` - Success: phases archived or nothing to archive (display output to user)
- `1` - Plan file not found: show error, suggest `/devloop`
- `2` - Script dependencies missing: show error
- `3` - Archive operation failed: show error details

The script handles:
- Detecting completed phases (all tasks `[x]`, `[~]`, `[-]`, or `[!]`)
- Creating archive files in `.devloop/archive/`
- Compressing the active plan
- Updating worklog with archived phase references
- Interactive confirmation for small plans (<100 lines)

## When to Use

- Plan exceeds 200 lines
- 2+ phases are 100% complete
- `/devloop:continue` feels slow
- You want to focus on active/pending tasks

## References

- `Skill: plan-management` - Plan format specification
- `Skill: worklog-management` - Worklog integration
- Scripts: `archive-interactive.sh`, `archive-phase.sh`
