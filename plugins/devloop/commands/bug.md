---
description: Report a new bug interactively for tracking and later fixing
argument-hint: Optional brief bug description
allowed-tools: ["Read", "Write", "Edit", "Glob", "Bash", "AskUserQuestion", "TodoWrite", "Skill"]
---

# Report Bug

Interactive bug reporting for issues that should be tracked for later fixing.

> **Note**: This command is an alias for `/devloop:new` with type=bug.
> For the full unified issue tracking system, use `/devloop:new` or `/devloop:issues`.

**IMPORTANT**: Invoke `Skill: issue-tracking` for issue format and storage details.

## Storage Location

- **New projects**: `.claude/issues/BUG-{NNN}.md` (unified system)
- **Legacy projects**: `.claude/bugs/BUG-{NNN}.md` (if not migrated)

## When to Use

- You noticed something broken but it's not urgent
- "We should fix this later" moments
- Minor formatting, UI, or logic issues
- Tech debt items worth tracking
- Issues discovered during development that aren't blocking

## Workflow

### Step 1: Initial Capture

If `$ARGUMENTS` provided, use as starting point for title.

```
Use AskUserQuestion:
- question: "What's the bug? (one line summary)"
- header: "Bug Title"
- options:
  - Use provided: "$ARGUMENTS" (if provided)
- Note: User can always type custom response
```

### Step 2: Gather Details

```
Use AskUserQuestion:
- question: "How would you describe the bug?"
- header: "Description"
- options:
  - Formatting issue (Visual/display problem)
  - Logic error (Code behaves incorrectly)
  - Missing feature (Expected functionality absent)
  - Performance (Slow or inefficient)
  - Let me describe (I'll provide details)
```

Based on selection, prompt for specifics:

```
Use AskUserQuestion:
- question: "Can you describe what's happening?"
- header: "Details"
- Note: Free text response expected
```

### Step 3: Set Priority

```
Use AskUserQuestion:
- question: "How important is fixing this?"
- header: "Priority"
- multiSelect: false
- options:
  - Low (Cosmetic, nice-to-have, no rush)
  - Medium (Should fix, but workaround exists) (Recommended)
  - High (Broken functionality, affects users)
```

### Step 4: Add Context

```
Use AskUserQuestion:
- question: "Any related files or additional context?"
- header: "Context"
- multiSelect: true
- options:
  - Current file (I was working in a specific file)
  - Recent changes (Related to recent work)
  - No specific files (General issue)
  - Add tags (I want to categorize this)
```

If "Current file" selected:
- Ask for file path or search for recently modified files
- Add to related-files in bug

If "Add tags" selected:
```
Use AskUserQuestion:
- question: "Select relevant tags"
- header: "Tags"
- multiSelect: true
- options:
  - ui (User interface)
  - api (Backend/API)
  - formatting (Display/style)
  - logic (Code behavior)
  - performance (Speed/efficiency)
  - docs (Documentation)
```

### Step 5: Create Bug

**Unified System** (preferred):
1. Ensure `.claude/issues/` directory exists
2. Determine next bug ID (BUG-{NNN})
3. Create bug file with gathered information and `type: bug`
4. Regenerate view files (index.md, bugs.md, etc.)
5. Confirm creation

**Legacy System** (if `.claude/issues/` doesn't exist):
1. Ensure `.claude/bugs/` directory exists
2. Determine next bug ID
3. Create bug file with gathered information
4. Update index.md
5. Confirm creation

### Step 6: Confirmation

Present the created bug:

```markdown
## Bug Reported

**ID**: BUG-{NNN}
**Title**: {title}
**Priority**: {priority}
**Location**: .claude/bugs/BUG-{NNN}.md

### Quick Actions
```

```
Use AskUserQuestion:
- question: "What would you like to do next?"
- header: "Next"
- multiSelect: false
- options:
  - Continue working (Go back to what I was doing)
  - Report another (I have more bugs to report)
  - View all bugs (Show me the bug list)
  - Fix this now (Actually, let me fix this)
```

---

## Quick Mode

If user provides a clear description in `$ARGUMENTS`, streamline:

1. Parse the description as title
2. Default to medium priority
3. Auto-detect any file paths mentioned
4. Create bug immediately
5. Show confirmation with option to edit

---

## Bug File Location

**Unified System**: `.claude/issues/BUG-{NNN}.md` (preferred)
**Legacy System**: `.claude/bugs/BUG-{NNN}.md`

---

## Integration

After creating a bug:
- The bug is tracked for later
- Use `/devloop:issues bugs` or `/devloop:bugs` to see all bugs
- Use `/devloop:issues` to see all issues including bugs
- Bugs can be fixed during `/devloop:continue` or dedicated bug-fix sessions
- DoD validation will check for related open issues

---

## See Also

- `/devloop:new` - Smart issue creation (auto-detects type)
- `/devloop:issues` - View and manage all issues
- `/devloop:bugs` - View bugs only
