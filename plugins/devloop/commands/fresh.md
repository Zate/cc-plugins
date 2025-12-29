---
description: Save current plan state and prepare for fresh context restart
argument-hint: none
allowed-tools: [
  "Bash", "AskUserQuestion",
  "Bash(${CLAUDE_PLUGIN_ROOT}/scripts/fresh-start.sh:*)"
]
---

# Fresh Start

Save the current devloop plan state for resuming after a context reset.

## Execution

Run the fresh-start script:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/fresh-start.sh
```

**Exit codes:**
- `0` - Success: state saved, display output to user
- `1` - No plan found: show error, suggest `/devloop` or creating a plan
- `2` - Invalid plan: show error, plan has no tasks

## Edge Case: State File Already Exists

If `.devloop/next-action.json` exists before running:

```yaml
AskUserQuestion:
  question: "Fresh start state already exists from previous session. Overwrite?"
  header: "Overwrite"
  options:
    - label: "Yes, update state"
      description: "Save current progress (Recommended)"
    - label: "No, keep existing"
      description: "Exit without changing state"
```

If "No, keep existing" → exit without running script.

## References

- `Skill: workflow-loop` - Context management patterns
- `Skill: plan-management` - Plan state format
- Script: `plugins/devloop/scripts/fresh-start.sh`
