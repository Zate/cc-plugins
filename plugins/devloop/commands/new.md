---
description: Create a GitHub issue (or local issue with --local)
argument-hint: "[title or description] [--local]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - AskUserQuestion
  - Glob
---

# New Issue - Create GitHub Issue

Create a GitHub issue via `gh issue create`. **You do the work directly.**

Use `--local` for offline/private work in `.devloop/issues/`.

## Step 1: Parse Arguments and Check GitHub

Check `$ARGUMENTS` for title/description and `--local` flag.

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-gh-setup.sh"
```

**If `preferred_method` is "none":**
- `gh_installed: false`: Display install instructions, fall back to `--local`
- `gh_authenticated: false`: Prompt `gh auth login`, fall back to `--local`

**If "gh" or "curl":** Continue to GitHub Mode (unless `--local` specified).

---

## Step 2: GitHub Mode

### 2.1 Collect Info
```yaml
AskUserQuestion:
  questions:
    - question: "What type of issue?"
      header: "Type"
      multiSelect: false
      options:
        - label: "Bug"
          description: "Something isn't working correctly"
        - label: "Feature"
          description: "New functionality or enhancement"
        - label: "Task"
          description: "General work item or chore"
    - question: "Add labels?"
      header: "Labels"
      multiSelect: true
      options:
        - label: "bug"
          description: "Bug fix"
        - label: "enhancement"
          description: "New feature or improvement"
        - label: "devloop"
          description: "Related to devloop plugin"
        - label: "documentation"
          description: "Documentation update"
```

Auto-add type label: Bug → "bug", Feature → "enhancement".

### 2.2 Title and Body

If no title in arguments, prompt for it. Then ask for description (what, why, context, acceptance criteria).

### 2.3 Create Issue
```bash
gh issue create \
  --title "${title}" \
  --body "${body}" \
  --label "${labels_comma_separated}" \
  --repo $(git remote get-url origin | sed 's/.*[:/]\([^/]*\/[^/]*\)\.git/\1/')
```

Parse issue URL and number from output.

### 2.4 Next Actions
```yaml
AskUserQuestion:
  questions:
    - question: "Issue #N created. What next?"
      header: "Next"
      multiSelect: false
      options:
        - label: "Start work"
          description: "Create plan from this issue"
        - label: "Create more"
          description: "Create another issue"
        - label: "View issues"
          description: "List all open issues"
        - label: "Done"
          description: "Return to conversation"
```

Route: Start → `/devloop:plan --from-issue N`, More → loop, View → `/devloop:issues`, Done → exit.

---

## Step 3: Local Mode

**Only if `--local` specified or GitHub unavailable.**

### 3.1 Collect Info
```yaml
AskUserQuestion:
  questions:
    - question: "What type of issue?"
      header: "Type"
      multiSelect: false
      options:
        - label: "Bug"
          description: "Something isn't working"
        - label: "Feature"
          description: "New functionality"
        - label: "Task"
          description: "General work item"
        - label: "Spike"
          description: "Research or investigation"
    - question: "Priority?"
      header: "Priority"
      multiSelect: false
      options:
        - label: "High"
          description: "Urgent"
        - label: "Medium (Recommended)"
          description: "Normal priority"
        - label: "Low"
          description: "Nice to have"
    - question: "Labels?"
      header: "Labels"
      multiSelect: true
      options:
        - label: "devloop"
          description: "Related to devloop"
        - label: "commands"
          description: "Related to commands"
        - label: "agents"
          description: "Related to agents"
        - label: "ux"
          description: "User experience"
```

### 3.2 Type-Specific Details

**Bug:** Severity (Critical/Major/Minor/Cosmetic)
**Feature/Task:** Size estimate (XS/S/M/L)
**Spike:** Depth (Quick/Standard/Deep)

### 3.3 Title and Description

If no title, prompt. Then ask for description.

### 3.4 Generate Issue ID

```bash
ls .devloop/issues/${TYPE}-*.md 2>/dev/null | wc -l
```

Format: `{TYPE}-{NUMBER}` (e.g., FEAT-003).

### 3.5 Create Issue File

Write to `.devloop/issues/${TYPE}-${NUMBER}.md`:

```markdown
---
id: ${TYPE}-${NUMBER}
type: ${type}
title: ${title}
status: open
priority: ${priority}
created: ${ISO_DATE}
labels: [${labels}]
---

# ${TYPE}-${NUMBER}: ${title}

## Description
${description}

## Acceptance Criteria
- [ ] ${auto_criteria}

## Technical Notes
<!-- Implementation notes -->

## Resolution
<!-- Filled when done -->
```

### 3.6 Update Index

Add to `.devloop/issues/index.md` (create if needed).

### 3.7 Next Actions

Same as GitHub mode but for local issues.

---

## Quick Mode

If `$ARGUMENTS` has 5+ words, enable quick mode:

1. Auto-detect type: "bug", "fix", "broken" → Bug; "add", "new", "feature" → Feature; else → Task
2. Extract title from arguments

**GitHub:** Prompt confirmation only, then create.
**Local:** Create immediately.

---

## Examples

```bash
/devloop:new                                          # Interactive GitHub
/devloop:new Fix login button not responding          # Quick mode GitHub
/devloop:new Add dark mode support                    # Quick mode GitHub
/devloop:new --local Private refactoring notes        # Local issue
/devloop:new --local                                  # Interactive local
```

## Migration

- **Default**: GitHub issues (was local)
- **Local**: Use `--local` flag
- **.devloop/issues/**: Still supported for `--local`
