---
description: Comprehensive code review for existing changes or PR
argument-hint: Optional file/PR to review
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - TaskList
---

# Review - Code Review

Comprehensive code review for changes, PRs, or specific files. **You do the work directly.**

## Step 1: Identify Scope

```yaml
AskUserQuestion:
  questions:
    - question: "What would you like to review?"
      header: "Scope"
      multiSelect: false
      options:
        - label: "Uncommitted changes"
          description: "Review git diff"
        - label: "Staged changes"
          description: "Review git diff --cached"
        - label: "Recent commits"
          description: "Review last few commits"
        - label: "Specific files"
          description: "I'll specify paths"
```

## Step 2: Gather Code

```bash
git diff                    # Uncommitted
git diff --cached           # Staged
git log -p -n 3            # Recent commits
gh pr diff [number]        # PR
```

## Step 3: Review

**Check these areas directly:**

### Correctness
- Logic errors, edge cases, error handling

### Security
- Input validation, no hardcoded secrets, injection risks

### Quality
- Clear naming, no duplication, appropriate comments

### Performance
- No N+1 queries, proper resource handling

## Step 4: Report

Present findings by severity:

```markdown
## Code Review

### Critical (Must Fix)
- [Issue]: [Location] - [Problem and fix]

### High Priority
- [Issue]: [Location] - [Problem and fix]

### Suggestions
- [Minor improvements]

### Positive
- [Good patterns observed]
```

## Step 5: Next Steps

```yaml
AskUserQuestion:
  questions:
    - question: "Review complete. How proceed?"
      header: "Action"
      multiSelect: false
      options:
        - label: "Fix critical"
          description: "Address blockers only"
        - label: "Fix all"
          description: "Apply all suggested fixes"
        - label: "Accept as-is"
          description: "Proceed without changes"
```

If fixing, make the changes directly using Edit tool.
