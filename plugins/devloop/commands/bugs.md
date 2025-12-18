---
description: View and manage tracked bugs - list, filter, fix, or close bugs
argument-hint: Optional filter (open, high, etc.) or bug ID
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill"]
---

# Manage Bugs

View, filter, and manage tracked bugs in the project.

> **Note**: This command is an alias for `/devloop:issues bugs`.
> For the full unified issue tracking system, use `/devloop:issues`.

**IMPORTANT**: Invoke `Skill: issue-tracking` for issue format details.

## Storage Location

- **New projects**: `.claude/issues/` (unified system, check `bugs.md` view)
- **Legacy projects**: `.claude/bugs/` (if not migrated)

## Quick Usage

- `/devloop:bugs` - Show all open bugs
- `/devloop:bugs high` - Show high priority bugs
- `/devloop:bugs BUG-003` - Show specific bug
- `/devloop:bugs fix` - Start fixing bugs

## Workflow

### Step 1: Load Bug Index

Check for bugs in unified or legacy system:

```bash
# Check unified system first
if [ -f ".claude/issues/bugs.md" ]; then
    cat .claude/issues/bugs.md
# Fall back to legacy system
elif [ -f ".claude/bugs/index.md" ]; then
    cat .claude/bugs/index.md
else
    echo "No bugs tracked yet. Use /devloop:bug or /devloop:new to report one."
fi
```

### Step 2: Parse Arguments

If `$ARGUMENTS` provided:

| Argument | Action |
|----------|--------|
| `open` | Filter to open bugs only |
| `high` | Filter to high priority |
| `medium` | Filter to medium priority |
| `low` | Filter to low priority |
| `all` | Show all bugs including fixed |
| `BUG-NNN` | Show specific bug details |
| `fix` | Enter fix mode |
| `stats` | Show statistics |

### Step 3: Display Bugs

If no filter or showing list:

```markdown
## Bug Tracker

**Open**: {N} | **In Progress**: {N} | **Fixed**: {N}

### High Priority
| ID | Title | Created | Tags |
|----|-------|---------|------|
| BUG-003 | Auth token refresh | 2024-12-11 | auth |

### Medium Priority
| ID | Title | Created | Tags |
|----|-------|---------|------|
| BUG-001 | Button truncation | 2024-12-10 | ui |

### Low Priority
| ID | Title | Created | Tags |
|----|-------|---------|------|
| BUG-005 | Typo in message | 2024-12-11 | formatting |
```

Then ask:

```
Use AskUserQuestion:
- question: "What would you like to do?"
- header: "Action"
- multiSelect: false
- options:
  - Fix a bug (Start working on one)
  - View details (See full bug report)
  - Report new (Add another bug)
  - Close bug (Mark as won't fix)
  - Done (Exit bug manager)
```

### Step 4: View Bug Details

If specific bug requested or "View details" selected:

1. Read `.claude/bugs/BUG-{NNN}.md`
2. Display full bug report
3. Offer actions:

```
Use AskUserQuestion:
- question: "What would you like to do with BUG-{NNN}?"
- header: "Bug Action"
- multiSelect: false
- options:
  - Fix it (Start fixing this bug)
  - Change priority (Adjust importance)
  - Add context (Update with more info)
  - Close (Mark as won't fix)
  - Back (Return to list)
```

### Step 5: Fix Mode

When user wants to fix a bug:

1. If no specific bug, ask which to fix:
   ```
   Use AskUserQuestion:
   - question: "Which bug would you like to fix?"
   - header: "Select Bug"
   - options:
     - [BUG-003] High: Auth token refresh (Recommended)
     - [BUG-001] Medium: Button truncation
     - [BUG-005] Low: Typo in message
     - Let me pick (Show me the list)
   ```

2. Mark bug as `in-progress` in both bug file and index

3. Read the bug file for full context

4. Present the bug details and ask:
   ```
   Use AskUserQuestion:
   - question: "How would you like to approach this fix?"
   - header: "Approach"
   - options:
     - Quick fix (I know what to do - just fix it)
     - Investigate first (Explore the issue before fixing)
     - Full devloop (Use complete workflow for complex fix)
   ```

5. Based on approach:
   - **Quick fix**: Read related files, implement fix, run tests
   - **Investigate**: Launch code-explorer on related files
   - **Full devloop**: Redirect to `/devloop` with bug as input

6. After fixing:
   - Update bug status to `fixed`
   - Add Resolution section to bug file
   - Update index.md
   - Ask about next bug

### Step 6: Close Bug (Won't Fix)

When closing without fixing:

```
Use AskUserQuestion:
- question: "Why are you closing this bug?"
- header: "Reason"
- options:
  - Not a bug (Behavior is correct)
  - Won't fix (Not worth the effort)
  - Duplicate (Already tracked elsewhere)
  - Cannot reproduce (Unable to see the issue)
```

Then:
1. Update bug status to `wont-fix`
2. Add reason to bug file
3. Move in index from Open to a "Closed" section
4. Update counts

---

## Statistics Mode

When `$ARGUMENTS` is `stats`:

```markdown
## Bug Statistics

**Total Tracked**: {N}
**Open**: {N} ({%})
**Fixed**: {N} ({%})
**Won't Fix**: {N} ({%})

### By Priority
- High: {N} open, {N} fixed
- Medium: {N} open, {N} fixed
- Low: {N} open, {N} fixed

### By Tag
- ui: {N}
- api: {N}
- formatting: {N}

### Recent Activity
- BUG-007 fixed (2024-12-11)
- BUG-008 reported (2024-12-11)
- BUG-006 fixed (2024-12-10)

### Oldest Open Bugs
1. BUG-001 (5 days old) - Button truncation
2. BUG-002 (3 days old) - Form validation
```

---

## Batch Operations

For managing multiple bugs:

```
Use AskUserQuestion:
- question: "Select a batch operation"
- header: "Batch"
- multiSelect: false
- options:
  - Fix all low (Close all low priority as won't fix)
  - Reprioritize (Bulk change priorities)
  - Clean up (Archive old fixed bugs)
```

---

## Integration with Devloop

- Bugs can be addressed during `/devloop:continue` sessions
- DoD validator checks for open bugs/issues
- Summary generator notes bugs fixed
- Plan can include bug-fix tasks

---

## See Also

- `/devloop:new` - Smart issue creation (auto-detects type)
- `/devloop:issues` - View and manage all issues
- `/devloop:bug` - Report a new bug
