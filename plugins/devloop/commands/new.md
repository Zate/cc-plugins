---
description: Smart issue creation - analyzes input, detects type, asks confirmation, creates issue
argument-hint: Optional issue description
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "AskUserQuestion", "TodoWrite", "Skill", "Task"]
---

# New Issue

Smart issue creation with automatic type detection. Analyzes your input to determine if it's a bug, feature, task, chore, or spike, then creates the appropriate issue.

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
  - S (A few hours)
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

### Step 5: Add Context (All Types)

```
Use AskUserQuestion:
- question: "Any related files or additional context?"
- header: "Context"
- multiSelect: true
- options:
  - Current file (I was working in a specific file)
  - Add labels (I want to categorize this)
  - Link to plan (Related to current plan task)
  - No additional context (Skip)
```

If "Add labels" selected:
```
Use AskUserQuestion:
- question: "Select relevant labels"
- header: "Labels"
- multiSelect: true
- options:
  - ui (User interface)
  - api (Backend/API)
  - auth (Authentication)
  - perf (Performance)
  - docs (Documentation)
  - test (Testing)
```

### Step 6: Create Issue

1. **Check if directory exists**: Use `Glob(".claude/issues/*.md")` to check. If no results and no directory, use Write tool to create the first issue file (Write will create parent directories automatically).

2. **Determine next ID for the type**:
   - Use `Glob(".claude/issues/{PREFIX}-*.md")` to find existing issues of this type
   - Parse filenames to find highest number
   - Increment by 1, format as `{PREFIX}-{NNN}` (e.g., FEAT-001)

3. Create issue file with gathered information using Write tool

4. Regenerate view files (index.md, bugs.md, features.md, backlog.md)

### Step 7: Confirmation

Present the created issue:

```markdown
## Issue Created

**ID**: {PREFIX}-{NNN}
**Type**: {type}
**Title**: {title}
**Priority**: {priority}
**Location**: .claude/issues/{PREFIX}-{NNN}.md
```

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

---

## Quick Mode

If `$ARGUMENTS` provides a clear description:

1. Parse the description as title
2. Detect type from keywords
3. Default to medium priority
4. Auto-detect any file paths mentioned
5. Show confirmation:

```
Use AskUserQuestion:
- question: "Create {TYPE}-{NNN}: '{title}' (priority: medium)?"
- header: "Confirm"
- multiSelect: false
- options:
  - Create (Looks good) (Recommended)
  - Edit (Let me adjust)
  - Cancel (Don't create)
```

If "Create" → create issue immediately
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
5. Create all issues
6. Regenerate views once at end

---

## Type Prefix Reference

| Type | Prefix | Example |
|------|--------|---------|
| bug | BUG- | BUG-001 |
| feature | FEAT- | FEAT-001 |
| task | TASK- | TASK-001 |
| chore | CHORE- | CHORE-001 |
| spike | SPIKE- | SPIKE-001 |

---

## Issue File Location

Issues are stored in `.claude/issues/{PREFIX}-{NNN}.md`

Views:
- `.claude/issues/index.md` - All issues
- `.claude/issues/bugs.md` - Bugs only
- `.claude/issues/features.md` - Features only
- `.claude/issues/backlog.md` - Open features + tasks

---

## Integration

After creating an issue:
- Use `/devloop:issues` to see all issues
- Use `/devloop:issues bugs` to see only bugs
- Use `/devloop:issues backlog` to see the backlog
- Issues can be worked on during `/devloop:continue` sessions
- DoD validation checks for related open issues

---

## Migration Note

If `.claude/bugs/` exists but `.claude/issues/` doesn't, offer migration:

```
Use AskUserQuestion:
- question: "Found existing .claude/bugs/ directory. Would you like to migrate to the unified issue system?"
- header: "Migrate"
- multiSelect: false
- options:
  - Yes, migrate (Move bugs to issues)
  - No, keep separate (Use both systems)
  - Later (Skip for now)
```
