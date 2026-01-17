---
description: Create a new local issue in .devloop/issues/
argument-hint: [title or description]
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - AskUserQuestion
  - Glob
---

# New Issue - Create Local Issue

Create a new issue in `.devloop/issues/` with a form-like experience. **You do the work directly.**

## Step 1: Parse Arguments

Check if `$ARGUMENTS` contains a title/description:
- If provided: Use as suggested title
- If empty: Will prompt for title in form

## Step 2: Collect Basic Info (Single Form)

Present a consolidated form with up to 4 questions:

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
        - label: "Spike"
          description: "Research or investigation"
    - question: "What priority?"
      header: "Priority"
      multiSelect: false
      options:
        - label: "High"
          description: "Urgent - needs immediate attention"
        - label: "Medium (Recommended)"
          description: "Normal priority"
        - label: "Low"
          description: "Nice to have, can wait"
    - question: "Add labels? (select all that apply)"
      header: "Labels"
      multiSelect: true
      options:
        - label: "devloop"
          description: "Related to devloop plugin"
        - label: "commands"
          description: "Related to slash commands"
        - label: "agents"
          description: "Related to agents"
        - label: "ux"
          description: "User experience improvement"
```

Parse the responses:
- `type`: Bug → BUG, Feature → FEAT, Task → TASK, Spike → SPIKE
- `priority`: high, medium, low
- `labels`: Array of selected labels

## Step 3: Type-Specific Details

Based on the selected type, ask additional questions:

### If Bug:
```yaml
AskUserQuestion:
  questions:
    - question: "How severe is this bug?"
      header: "Severity"
      multiSelect: false
      options:
        - label: "Critical"
          description: "System unusable, data loss, security issue"
        - label: "Major"
          description: "Core functionality broken"
        - label: "Minor"
          description: "Works but has issues"
        - label: "Cosmetic"
          description: "Visual or minor UX issue"
```

### If Feature or Task:
```yaml
AskUserQuestion:
  questions:
    - question: "Size estimate?"
      header: "Estimate"
      multiSelect: false
      options:
        - label: "XS"
          description: "Less than an hour"
        - label: "S"
          description: "A few hours"
        - label: "M"
          description: "A day or two"
        - label: "L"
          description: "Several days to a week"
```

### If Spike:
```yaml
AskUserQuestion:
  questions:
    - question: "What depth of investigation?"
      header: "Depth"
      multiSelect: false
      options:
        - label: "Quick"
          description: "High-level feasibility check"
        - label: "Standard"
          description: "Solid analysis with recommendations"
        - label: "Deep"
          description: "Comprehensive exploration with prototypes"
```

## Step 4: Collect Title and Description

If title wasn't provided in arguments:

```yaml
AskUserQuestion:
  questions:
    - question: "Brief title for this issue?"
      header: "Title"
      multiSelect: false
      options:
        - label: "Enter title..."
          description: "Type your title using 'Other'"
```

Then ask for description:

```
Please provide a description for this issue.
Include:
- What needs to be done
- Why it's needed
- Any relevant context
```

Read the user's next message as the description.

## Step 5: Generate Issue ID

Determine the next ID for this type:

```bash
ls .devloop/issues/${TYPE}-*.md 2>/dev/null | wc -l
```

Format: `{TYPE}-{NUMBER}` where NUMBER is padded to 3 digits.
Example: If 2 FEAT files exist, next is FEAT-003.

## Step 6: Create Issue File

Generate the issue file with YAML frontmatter:

```markdown
---
id: ${TYPE}-${NUMBER}
type: ${type_lowercase}
title: ${title}
status: open
priority: ${priority}
created: ${ISO_DATE}
updated: ${ISO_DATE}
reporter: user
assignee: null
labels: [${labels_joined}]
${type_specific_fields}
related-files: []
---

# ${TYPE}-${NUMBER}: ${title}

## Description

${description}

## Acceptance Criteria

- [ ] ${auto_generated_criteria}

## Technical Notes

<!-- Add implementation notes here -->

## Resolution

<!-- Filled in when done -->
- **Resolved in**:
- **Resolved by**:
- **Resolution summary**:
```

Write to `.devloop/issues/${TYPE}-${NUMBER}.md`.

## Step 7: Update Index

Read `.devloop/issues/index.md` and add the new issue to the appropriate priority section.

## Step 8: Offer Next Actions

```yaml
AskUserQuestion:
  questions:
    - question: "Issue ${TYPE}-${NUMBER} created. What next?"
      header: "Next"
      multiSelect: false
      options:
        - label: "Start work"
          description: "Create plan and begin implementation"
        - label: "Create more"
          description: "Create another issue"
        - label: "View issues"
          description: "List all open issues"
        - label: "Done"
          description: "Return to conversation"
```

### If "Start work":
Create a plan from this issue and run `/devloop:continue`

### If "Create more":
Loop back to Step 2

### If "View issues":
Display contents of `.devloop/issues/index.md`

---

## Quick Mode

If `$ARGUMENTS` contains a full description (more than 5 words), enable quick mode:

1. Auto-detect type from keywords:
   - "bug", "fix", "broken", "error" → BUG
   - "add", "new", "feature", "enhance" → FEAT
   - "investigate", "research", "spike", "explore" → SPIKE
   - Default → TASK

2. Set default priority: medium

3. Skip to Step 4 (title/description) with auto-suggested title

4. Ask only: "Confirm creating {TYPE} issue: '{title}'? [Yes/Edit/Cancel]"

---

## Examples

```bash
# Interactive mode - full form
/devloop:new

# Quick mode with description
/devloop:new Fix the login button not responding on mobile

# Quick mode with title hint
/devloop:new Add dark mode support
```

## Output Format

```
Created: BUG-003
Title: Login button not responding on mobile
Priority: high
Labels: bug, ux

File: .devloop/issues/BUG-003.md

What next? [Start work] [Create more] [View issues] [Done]
```
