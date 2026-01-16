---
description: Start work from a GitHub issue
argument-hint: <issue-number>
allowed-tools:
  - Read
  - Write
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - AskUserQuestion
  - Skill
---

# From Issue - Start Work from GitHub Issue

Fetch a GitHub issue and start a devloop plan based on its content. **You do the work directly.**

## Step 1: Parse Issue Number

Extract issue number from `$ARGUMENTS`.

If no issue number provided:
```
Usage: /devloop:from-issue <issue-number>

Example: /devloop:from-issue 123
```

## Step 2: Check GitHub Config

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/parse-local-config.sh"
```

Parse the output. If `github.link_issues` is `false`, warn:
```
GitHub issue integration is not enabled.

To enable, add to .devloop/local.md:
---
github:
  link-issues: true
---

Continue anyway? (The issue will still be referenced in the plan)
```

## Step 3: Check Existing Plan

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md
```

If a plan exists:

**If plan is complete:**
```yaml
AskUserQuestion:
  questions:
    - question: "Existing plan is complete. Archive before starting from issue?"
      header: "Archive"
      multiSelect: false
      options:
        - label: "Archive and continue"
          description: "Move completed plan to archive"
        - label: "Replace"
          description: "Overwrite without archiving"
        - label: "Cancel"
          description: "Keep existing plan"
```

**If plan is incomplete:**
```yaml
AskUserQuestion:
  questions:
    - question: "Existing plan has N pending tasks. What to do?"
      header: "Conflict"
      multiSelect: false
      options:
        - label: "Replace"
          description: "Overwrite incomplete plan"
        - label: "Cancel"
          description: "Keep existing plan"
```

## Step 4: Fetch Issue Details

```bash
gh issue view $ISSUE_NUMBER --json number,title,body,labels,state,url
```

Parse the JSON output:
- `number`: Issue number
- `title`: Issue title (becomes plan title)
- `body`: Issue description (provides context)
- `labels`: Issue labels (may inform task types)
- `state`: Should be "open" (warn if closed)
- `url`: Full URL for plan reference

**If issue not found:**
```
Issue #$ISSUE_NUMBER not found.
Make sure you're in a repository with this issue.
```

**If issue is closed:**
```yaml
AskUserQuestion:
  questions:
    - question: "Issue #123 is already closed. Continue anyway?"
      header: "Closed"
      multiSelect: false
      options:
        - label: "Yes, start anyway"
          description: "Create plan for closed issue"
        - label: "Cancel"
          description: "Don't create plan"
```

## Step 5: Create Plan from Issue

Generate a new plan with issue context:

```markdown
# Devloop Plan: [Issue Title]

**Created**: YYYY-MM-DD
**Updated**: YYYY-MM-DD
**Status**: Planning
**Issue**: #123 (https://github.com/owner/repo/issues/123)

---

## Overview

[Issue body / description]

---

## Phase 1: Implementation

- [ ] Task 1.1: [Derived from issue description]
- [ ] Task 1.2: [Additional tasks as needed]

---

## Progress Log

- YYYY-MM-DD: Plan created from Issue #123
```

Write to `.devloop/plan.md`.

## Step 6: Next Steps

```yaml
AskUserQuestion:
  questions:
    - question: "Plan created from Issue #123. What next?"
      header: "Next"
      multiSelect: false
      options:
        - label: "Spike first"
          description: "Explore before implementing (/devloop:spike)"
        - label: "Start work"
          description: "Begin implementation (/devloop:continue)"
        - label: "Refine plan"
          description: "Review and adjust tasks first"
```

### If "Spike first":
Run `/devloop:spike` with issue context

### If "Start work":
Run `/devloop:continue`

### If "Refine plan":
Display the plan for user review

---

## Quick Reference

| Step | Action |
|------|--------|
| 1 | Fetch issue from GitHub |
| 2 | Archive existing plan (if complete) |
| 3 | Create plan with Issue reference |
| 4 | Suggest next action |

## Example

```bash
# Start work from issue
/devloop:from-issue 42

# Output:
# Fetched Issue #42: "Add dark mode support"
# Plan created at .devloop/plan.md
# What next? [Spike first] [Start work] [Refine plan]
```
