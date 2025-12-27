---
description: Smart issue creation - analyzes input, detects type, asks confirmation, creates issue
argument-hint: Optional issue description
allowed-tools: ["Read", "Bash", "AskUserQuestion"]
---

# New Issue

Smart issue creation with automatic type detection. Analyzes your input to determine if it's a bug, feature, task, chore, or spike, then creates the appropriate issue using the standardized creation script.

**IMPORTANT**: Invoke `Skill: issue-tracking` for issue format and storage details.

## Quick Usage

- `/devloop:new` - Interactive issue creation
- `/devloop:new button is broken` - Creates a bug (detected from "broken")
- `/devloop:new add dark mode` - Creates a feature (detected from "add")
- `/devloop:new refactor auth module` - Creates a task (detected from "refactor")

## Workflow

### Step 1: Capture Input

If `$ARGUMENTS` provided, use as starting point.

Otherwise:
```
Use AskUserQuestion:
- question: "What would you like to track? (describe the issue, feature, or task)"
- header: "Description"
- Note: Free text response expected
```

### Step 2: Detect Issue Type

Analyze the input using smart routing keywords:

**Bug indicators**:
- "bug", "broken", "doesn't work", "not working"
- "error", "crash", "exception", "fail"
- "fix", "wrong", "incorrect", "unexpected"

**Feature indicators**:
- "add", "new", "implement", "create", "build"
- "feature", "enhancement", "request"
- "support", "enable", "allow"

**Task indicators**:
- "refactor", "clean up", "improve", "optimize"
- "update", "upgrade", "migrate"
- "reorganize", "restructure"

**Chore indicators**:
- "chore", "maintenance", "dependency"
- "bump", "upgrade dependency"
- "ci", "build system", "config"

**Spike indicators**:
- "investigate", "explore", "research"
- "spike", "poc", "prototype"
- "evaluate", "assess"

**Priority for ambiguous cases**: bug > feature > task

### Step 3: Confirm Type

Present detected type for confirmation:

```
Use AskUserQuestion:
- question: "I detected this as a [TYPE]. Is that correct?"
- header: "Type"
- multiSelect: false
- options:
  - Yes, [type] (Proceed with detected type) (Recommended)
  - Bug (Something is broken)
  - Feature (New functionality)
  - Task (Technical work, refactoring)
  - Chore (Maintenance, dependencies)
  - Spike (Research, investigation)
```

### Step 4: Gather Details

Based on issue type, gather relevant information:

#### For Bugs
```
Use AskUserQuestion:
- question: "How serious is this bug?"
- header: "Priority"
- multiSelect: false
- options:
  - Low (Cosmetic, no rush)
  - Medium (Should fix, workaround exists) (Recommended)
  - High (Broken functionality)
```

```
Use AskUserQuestion:
- question: "Can you describe the expected vs actual behavior?"
- header: "Details"
- Note: Free text for description
```

#### For Features
```
Use AskUserQuestion:
- question: "How important is this feature?"
- header: "Priority"
- multiSelect: false
- options:
  - Low (Nice to have)
  - Medium (Would improve product) (Recommended)
  - High (Critical for users/MVP)
```

```
Use AskUserQuestion:
- question: "What's the estimated size of this feature?"
- header: "Estimate"
- multiSelect: false
- options:
  - XS (A few hours)
  - S (A few hours to half day)
  - M (A day or two) (Recommended)
  - L (A week)
  - XL (Multiple weeks)
```

#### For Tasks/Chores
```
Use AskUserQuestion:
- question: "How urgent is this work?"
- header: "Priority"
- multiSelect: false
- options:
  - Low (When we get to it)
  - Medium (Should do soon) (Recommended)
  - High (Blocking other work)
```

#### For Spikes
```
Use AskUserQuestion:
- question: "What's the timebox for this investigation?"
- header: "Timebox"
- multiSelect: false
- options:
  - 30 minutes (Quick exploration)
  - 2 hours (Moderate investigation)
  - Half day (Deep dive)
```

### Step 5: Add Context (Optional)

```
Use AskUserQuestion:
- question: "Any labels or additional context?"
- header: "Labels"
- multiSelect: true
- options:
  - ui (User interface)
  - api (Backend/API)
  - auth (Authentication)
  - perf (Performance)
  - docs (Documentation)
  - test (Testing)
  - No labels (Skip)
```

### Step 6: Create Issue with Script

Call the creation script:

```bash
./plugins/devloop/scripts/create-issue.sh \
  --type "$TYPE" \
  --title "$TITLE" \
  --priority "$PRIORITY" \
  ${LABELS:+--labels "$LABELS"} \
  ${ESTIMATE:+--estimate "$ESTIMATE"} \
  ${DESCRIPTION:+--description "$DESCRIPTION"} \
  --output-format md
```

**Note**: The script handles:
- ID generation (BUG-001, FEAT-002, etc.)
- File creation in `.devloop/issues/`
- Proper YAML frontmatter
- Issue template structure

### Step 7: Next Actions

Present options after creation:

```
Use AskUserQuestion:
- question: "What would you like to do next?"
- header: "Next"
- multiSelect: false
- options:
  - Continue working (Go back to what I was doing)
  - Create another (I have more items to track)
  - View all issues (Show me the issue list)
  - Work on this now (Start implementing/fixing)
```

If "View all issues" → Run `/devloop:issues`
If "Create another" → Restart this workflow
If "Work on this now" → Suggest `/devloop:continue` or relevant workflow

---

## Quick Mode

If `$ARGUMENTS` provides a clear description:

1. Parse the description as title
2. Detect type from keywords
3. Default to medium priority
4. Show confirmation:

```
Use AskUserQuestion:
- question: "Create {TYPE}: '{title}' (priority: medium)?"
- header: "Confirm"
- multiSelect: false
- options:
  - Create (Looks good) (Recommended)
  - Edit (Let me adjust details)
  - Cancel (Don't create)
```

If "Create" → call script immediately with defaults
If "Edit" → continue with full interactive flow

---

## Multiple Items

If input contains multiple items (numbered list, bullet points):

```
Use AskUserQuestion:
- question: "I detected multiple items. Create separate issues for each?"
- header: "Multiple"
- multiSelect: false
- options:
  - Yes, create all (Create separate issues)
  - No, combine (Create one issue)
  - Let me pick (Show me the list)
```

If creating multiple:
1. Parse each item
2. Detect type for each
3. Show summary:
   ```markdown
   ## Creating Issues
   1. BUG-004: Button doesn't work
   2. FEAT-002: Add dark mode
   3. TASK-001: Refactor utils
   ```
4. Ask for confirmation
5. Call script for each issue

---

## Type Reference

| Type | Prefix | Script Arg |
|------|--------|------------|
| Bug | BUG- | `--type bug` |
| Feature | FEAT- | `--type feature` |
| Task | TASK- | `--type task` |
| Chore | CHORE- | `--type chore` |
| Spike | SPIKE- | `--type spike` |

---

## Issue File Location

Issues are stored in `.devloop/issues/{PREFIX}-{NNN}.md`

To view issues:
- Use `/devloop:issues` to see all issues
- Use `/devloop:issues bugs` to see only bugs
- Use `/devloop:issues features` to see only features
- Use `/devloop:issues backlog` to see the backlog

---

## Integration

After creating an issue:
- Issues are tracked in `.devloop/issues/`
- Can be worked on during `/devloop:continue` sessions
- DoD validation checks for related open issues
- Use `/devloop:issues` to manage all issues

---

## Script Location

The creation script is located at:
```
plugins/devloop/scripts/create-issue.sh
```

See script help for all options:
```bash
./plugins/devloop/scripts/create-issue.sh --help
```
