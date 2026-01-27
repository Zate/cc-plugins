---
description: Create a GitHub issue (or local issue with --local)
argument-hint: [title or description] [--local]
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

Create a new GitHub issue via `gh issue create`. **You do the work directly.**

For offline/private work, use `--local` flag to create local `.devloop/issues/` files.

## Step 1: Parse Arguments and Check GitHub Setup

Check if `$ARGUMENTS` contains:
- Title/description text
- `--local` flag (creates local issue instead)

**Check GitHub availability:**

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-gh-setup.sh"
```

Parse the JSON output and check `preferred_method`:

### If `preferred_method` is "none":

Check the specific issue:

- If `gh_installed` is false:
```
GitHub CLI is not installed.

To install:
- macOS: brew install gh
- Windows: winget install GitHub.cli
- Linux: See https://github.com/cli/cli/blob/trunk/docs/install_linux.md

Falling back to local issue creation (--local mode).
```

- If `gh_installed` is true but `gh_authenticated` is false:
```
GitHub CLI is installed but not authenticated.

Run: gh auth login

Falling back to local issue creation (--local mode).
```

Automatically enable `--local` mode and continue to Step 2 (Local Mode).

### If `preferred_method` is "gh" or "curl":

Continue to Step 2 (GitHub Mode) unless `--local` was explicitly specified.

---

## Step 2: GitHub Mode - Create GitHub Issue

### Step 2.1: Collect Basic Info

Present a consolidated form:

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
    - question: "Add labels? (select all that apply)"
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

Parse the responses:
- `type`: Bug, Feature, Task (used for auto-labeling and title prefix)
- `labels`: Array of selected labels

Auto-add type label:
- Bug → Add "bug" label (if not already selected)
- Feature → Add "enhancement" label (if not already selected)

### Step 2.2: Collect Title and Body

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
- Acceptance criteria (optional)
```

Read the user's next message as the body.

### Step 2.3: Create GitHub Issue

Build the gh command:

```bash
gh issue create \
  --title "${title}" \
  --body "${body}" \
  --label "${labels_comma_separated}" \
  --repo $(git remote get-url origin | sed 's/.*[:/]\([^/]*\/[^/]*\)\.git/\1/')
```

**Capture the output** which includes the issue URL and number.

Parse the issue number from output (format: `https://github.com/owner/repo/issues/N`).

### Step 2.4: Display Result and Offer Next Actions

```
Created GitHub Issue #N
Title: ${title}
Labels: ${labels}
URL: ${issue_url}
```

```yaml
AskUserQuestion:
  questions:
    - question: "Issue #N created. What next?"
      header: "Next"
      multiSelect: false
      options:
        - label: "Start work"
          description: "Create plan from this issue (/devloop:from-issue N)"
        - label: "Create more"
          description: "Create another issue"
        - label: "View issues"
          description: "List all open issues (/devloop:issues)"
        - label: "Done"
          description: "Return to conversation"
```

### Routing:
- "Start work" → `/devloop:from-issue N`
- "Create more" → Loop back to Step 2.1
- "View issues" → `/devloop:issues`
- "Done" → Exit

---

## Step 3: Local Mode - Create Local Issue

**Only execute this if `--local` flag was specified or GitHub unavailable.**

### Step 3.1: Collect Basic Info (Single Form)

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

### Step 3.2: Type-Specific Details

Based on the selected type, ask additional questions:

#### If Bug:
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

#### If Feature or Task:
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

#### If Spike:
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

### Step 3.3: Collect Title and Description

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

### Step 3.4: Generate Issue ID

Determine the next ID for this type:

```bash
ls .devloop/issues/${TYPE}-*.md 2>/dev/null | wc -l
```

Format: `{TYPE}-{NUMBER}` where NUMBER is padded to 3 digits.
Example: If 2 FEAT files exist, next is FEAT-003.

### Step 3.5: Create Issue File

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

### Step 3.6: Update Index

Read `.devloop/issues/index.md` and add the new issue to the appropriate priority section.

If index doesn't exist, create it.

### Step 3.7: Display Result and Offer Next Actions

```
Created Local Issue: ${TYPE}-${NUMBER}
Title: ${title}
Priority: ${priority}
Labels: ${labels}

File: .devloop/issues/${TYPE}-${NUMBER}.md
```

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
          description: "List all local issues"
        - label: "Done"
          description: "Return to conversation"
```

### Routing:
- "Start work" → Create plan from local issue
- "Create more" → Loop back to Step 3.1
- "View issues" → Display contents of `.devloop/issues/index.md`
- "Done" → Exit

---

## Quick Mode

If `$ARGUMENTS` contains a full description (more than 5 words), enable quick mode:

1. Auto-detect type from keywords:
   - "bug", "fix", "broken", "error" → Bug
   - "add", "new", "feature", "enhance" → Feature
   - Default → Task

2. Extract title from arguments (remove --local flag if present)

3. **GitHub Mode**: Create issue immediately with auto-detected type/labels, prompt only for confirmation:
   ```yaml
   AskUserQuestion:
     questions:
       - question: "Create ${type} issue: '${title}'?"
         header: "Confirm"
         multiSelect: false
         options:
           - label: "Yes, create it"
             description: "Create GitHub issue now"
           - label: "Edit first"
             description: "Customize before creating"
           - label: "Cancel"
             description: "Don't create"
   ```

4. **Local Mode** (with `--local`): Create local issue immediately, skip most prompts

---

## Examples

```bash
# Interactive mode - full form (GitHub)
/devloop:new

# Quick mode with description (GitHub)
/devloop:new Fix the login button not responding on mobile

# Quick mode with title hint (GitHub)
/devloop:new Add dark mode support

# Local-only issue (offline work)
/devloop:new --local Private refactoring notes

# Interactive local mode
/devloop:new --local
```

## Output Format

### GitHub Mode:
```
Created GitHub Issue #42
Title: Fix login button not responding on mobile
Labels: bug, ux
URL: https://github.com/owner/repo/issues/42

What next? [Start work] [Create more] [View issues] [Done]
```

### Local Mode:
```
Created Local Issue: BUG-003
Title: Login button not responding on mobile
Priority: high
Labels: bug, ux

File: .devloop/issues/BUG-003.md

What next? [Start work] [Create more] [View issues] [Done]
```

---

## Migration Notes

- **Default behavior changed**: Now creates GitHub issues by default
- **Local issues**: Use `--local` flag for offline/private work
- **Existing local issues**: Remain valid, not automatically migrated
- **.devloop/issues/**: Still supported for `--local` mode
