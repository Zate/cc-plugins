---
description: Complete validation and git integration for shipping a feature
argument-hint: Optional commit message or PR title
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "AskUserQuestion", "TodoWrite"]
---

# Ship - Commit and PR

Validate and ship your changes. **You do the work directly.**

## Step 1: Pre-flight Check

```bash
git status
git diff --stat
```

Ask ship mode:

```yaml
AskUserQuestion:
  question: "How would you like to ship?"
  header: "Mode"
  options:
    - label: "Full validation"
      description: "Run tests, then commit/PR"
    - label: "Quick commit"
      description: "Skip validation, just commit"
    - label: "PR only"
      description: "Changes already committed"
```

## Step 2: Validation (if full)

Run tests:

```bash
npm test          # or
go test ./...     # or
pytest            # etc
```

Check for issues:
- TODO/FIXME markers in staged files
- Debug statements (console.log, print, etc.)
- Secrets or credentials

## Step 3: Commit

Generate conventional commit message based on changes:

```bash
git add -A
git commit -m "feat(scope): description"
```

Commit types:
- `feat` - New functionality
- `fix` - Bug fixes
- `refactor` - Code restructuring
- `test` - Test changes
- `docs` - Documentation
- `chore` - Build/config

## Step 4: PR (if requested)

```bash
gh pr create --title "Title" --body "## Summary
- Change 1
- Change 2

## Testing
- [ ] Tests pass
"
```

## Step 5: Update Plan

If `.devloop/plan.md` exists, mark current task complete and add progress log entry.

---

## Safety Checks

Before committing:
- No secrets in staged files
- No debug code
- Correct branch
- Tests pass
