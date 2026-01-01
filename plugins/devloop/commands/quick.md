---
description: Quick implementation for small, well-defined tasks (skip exploration/architecture)
argument-hint: Task description
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "AskUserQuestion", "TodoWrite"]
---

# Quick - Fast Implementation

Streamlined workflow for small, well-defined tasks. **You do the work directly.**

## When to Use

- Bug fixes with known cause
- Small feature additions to existing patterns
- Configuration changes
- Documentation updates
- Test additions

## When NOT to Use

- New features with unclear requirements → Use `/devloop`
- Changes touching multiple systems → Use `/devloop`
- Security-related changes → Use `/devloop:review` first

## Step 1: Understand

Initial request: $ARGUMENTS

1. Create brief todo list
2. If unclear, ask ONE clarifying question
3. If too complex, suggest switching to `/devloop`

## Step 2: Implement

**Do it directly:**

1. Read relevant files (limit to 3-5 files)
2. Make the change using Write/Edit tools
3. Follow existing patterns exactly
4. Update todos as you go

## Step 3: Verify

Run relevant tests:

```bash
npm test -- --related  # or
go test ./...          # or
pytest -x              # etc
```

If tests fail, fix immediately.

## Step 4: Done

Mark todos complete. Brief summary:

- What was changed
- Files modified
- Any follow-up needed

---

## Escalation

If during implementation you discover complexity:

```yaml
AskUserQuestion:
  question: "This is more complex than expected. Switch to full workflow?"
  header: "Escalate"
  options:
    - label: "Yes, full workflow"
      description: "Use /devloop for comprehensive approach"
    - label: "Continue quick"
      description: "Accept limitations, keep going"
```
