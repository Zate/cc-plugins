---
description: View all issues (replaces and extends /devloop:bugs) - filter by type, status, or ID
argument-hint: Optional filter (bugs, features, backlog, BUG-001) or action (fix, close)
allowed-tools: ["Bash", "Read", "AskUserQuestion", "TodoWrite", "Skill"]
---

# Manage Issues

View, filter, and manage all tracked issues - bugs, features, tasks, chores, and spikes.

**IMPORTANT**: Invoke `Skill: issue-tracking` for issue format and storage details.

## Agent Routing

When working on issues, this command routes to appropriate agents:

| Action | Agent | Mode/Focus |
|--------|-------|------------|
| Investigate | `devloop:engineer` | Explore mode - understand issue context |
| Quick fix | Direct implementation | No agent needed for simple changes |
| Complex work | `/devloop` workflow | Full agent routing |

## Quick Usage

- `/devloop:issues` - Show all open issues
- `/devloop:issues bugs` - Show only bugs
- `/devloop:issues features` - Show only features
- `/devloop:issues backlog` - Show open features + tasks
- `/devloop:issues high` - Show high priority issues
- `/devloop:issues BUG-003` - Show specific issue
- `/devloop:issues stats` - Show statistics

## Workflow

### Step 1: Check Issue Directory

Check for issues using the list script:

```bash
./plugins/devloop/scripts/list-issues.sh --format table 2>/dev/null || echo "No issues found. Use /devloop:new to create one."
```

If the script fails with "directory not found", display:
```
No issues tracked yet. Use /devloop:new to create one.
```

### Step 2: Parse Arguments and Map to Script Flags

If `$ARGUMENTS` provided, map to script flags:

| Argument | Script Flags |
|----------|--------------|
| `bugs` | `--type bug` |
| `features` | `--type feature` |
| `tasks` | `--type task` |
| `backlog` | `--type feature --status open` (call twice for features + tasks) |
| `open` | `--status open` |
| `in-progress` | `--status in-progress` |
| `done` | `--status done` |
| `high` | `--priority high` |
| `medium` | `--priority medium` |
| `low` | `--priority low` |
| `all` | No filters (show everything) |
| `{PREFIX}-NNN` | Read specific file with Read tool |
| `stats` | Use `--format json` and compute statistics |

### Step 3: Display Issues Using Script

Call the list script with appropriate flags:

```bash
# Default view (open issues)
./plugins/devloop/scripts/list-issues.sh --format markdown --status open

# Bugs view
./plugins/devloop/scripts/list-issues.sh --format markdown --type bug

# Features view
./plugins/devloop/scripts/list-issues.sh --format markdown --type feature

# Backlog view (features + tasks)
echo "## Backlog (Open Features + Tasks)"
./plugins/devloop/scripts/list-issues.sh --format markdown --type feature --status open
./plugins/devloop/scripts/list-issues.sh --format markdown --type task --status open

# High priority
./plugins/devloop/scripts/list-issues.sh --format markdown --priority high
```

**Format**: The script outputs markdown with grouped sections by status.

### Step 4: Offer Actions

After displaying issues:

```
Use AskUserQuestion:
- question: "What would you like to do?"
- header: "Action"
- multiSelect: false
- options:
  - Work on issue (Start implementing or fixing)
  - View details (See full issue report)
  - Create new (Add a new issue)
  - Change filter (View different subset)
  - Close issue (Mark as done or won't do)
  - Done (Exit issue manager)
```

### Step 5: View Issue Details

If specific issue requested (e.g., `BUG-003`) or "View details" selected:

1. Read `.devloop/issues/{PREFIX}-{NNN}.md` using Read tool
2. Display full issue report
3. Offer actions:

```
Use AskUserQuestion:
- question: "What would you like to do with {PREFIX}-{NNN}?"
- header: "Issue Action"
- multiSelect: false
- options:
  - Work on it (Start implementing/fixing)
  - Change priority (Adjust importance)
  - Add comment (Update with more info)
  - Close (Mark as done or won't do)
  - Back (Return to list)
```

### Step 6: Work Mode

When user wants to work on an issue:

1. If no specific issue selected, show picker using list script:
   ```bash
   # Get high priority open issues
   ./plugins/devloop/scripts/list-issues.sh --priority high --status open --format json
   ```
   Parse JSON to create picker options

2. Mark issue as `in-progress` using script:
   ```bash
   ./plugins/devloop/scripts/update-issue.sh {ISSUE_ID} --status in-progress
   ```

3. Read the issue file for full context using Read tool

4. Present details and ask approach:
   ```
   Use AskUserQuestion:
   - question: "How would you like to approach this?"
   - header: "Approach"
   - options:
     - Quick fix (I know what to do)
     - Investigate first (Explore before implementing)
     - Full devloop (Use complete workflow)
   ```

5. Based on approach:
   - **Quick fix**: Read related files, implement, run tests
   - **Investigate**: Launch `devloop:engineer` agent in explore mode
   - **Full devloop**: Redirect to `/devloop` with issue as input

6. After completing, update issue:
   ```bash
   ./plugins/devloop/scripts/update-issue.sh {ISSUE_ID} --resolve "Brief summary of what was done"
   ```

### Step 7: Close Issue

When closing (done or won't do):

```
Use AskUserQuestion:
- question: "How should this issue be closed?"
- header: "Close Reason"
- options:
  - Done (Work completed)
  - Won't do (Not worth the effort)
  - Duplicate (Already tracked elsewhere)
  - Invalid (Not actually an issue)
```

If "Done":
1. Ask for resolution summary:
   ```
   Use AskUserQuestion:
   - question: "Brief summary of what was done?"
   - header: "Summary"
   - Note: Free text for resolution
   ```

2. Update issue using script:
   ```bash
   ./plugins/devloop/scripts/update-issue.sh {ISSUE_ID} --resolve "{SUMMARY}"
   ```

If other reasons:
1. Update status:
   ```bash
   ./plugins/devloop/scripts/update-issue.sh {ISSUE_ID} --status done --comment "Closed: {REASON}"
   ```

---

## Statistics Mode

When `$ARGUMENTS` is `stats`:

Use `--format json` to get all issues and compute statistics:

```bash
# Get all issues in JSON format
all_issues=$(./plugins/devloop/scripts/list-issues.sh --format json)

# Parse and count:
# - total, open, in-progress, done
# - by type (bug, feature, task, chore, spike)
# - by priority (high, medium, low)
# - by label (extract from each issue)
```

Display summary:

```markdown
## Issue Statistics

**Total Tracked**: {N}
**Open**: {N} ({%}) | **In Progress**: {N} ({%}) | **Done**: {N} ({%})

### By Type
| Type | Open | In Progress | Done | Total |
|------|------|-------------|------|-------|
| Bug | {N} | {N} | {N} | {N} |
| Feature | {N} | {N} | {N} | {N} |
| Task | {N} | {N} | {N} | {N} |
| Chore | {N} | {N} | {N} | {N} |
| Spike | {N} | {N} | {N} | {N} |

### By Priority (Open Only)
- High: {N}
- Medium: {N}
- Low: {N}

### Recent Activity
[Parse created/updated timestamps to show recent changes]
```

---

## Change Priority / Add Comment

When user selects "Change priority" or "Add comment":

**Change Priority**:
```
Use AskUserQuestion:
- question: "New priority for {ISSUE_ID}?"
- header: "Priority"
- options:
  - High
  - Medium
  - Low
```

Update using script:
```bash
./plugins/devloop/scripts/update-issue.sh {ISSUE_ID} --priority {PRIORITY}
```

**Add Comment**:
```
Use AskUserQuestion:
- question: "Enter comment for {ISSUE_ID}"
- header: "Comment"
```

Update using script:
```bash
./plugins/devloop/scripts/update-issue.sh {ISSUE_ID} --comment "{COMMENT}"
```

---

## Create New Issue

When user selects "Create new":

Redirect to `/devloop:new` command which uses the create-issue script.

---

## Integration with Devloop

- Issues can be addressed during `/devloop:continue` sessions
- DoD validator checks for related open issues
- Summary generator notes issues resolved
- Plan tasks can reference issues via `related-plan-task`
- `/devloop:new` creates issues that appear here

---

## Backwards Compatibility

These legacy commands still work:
- `/devloop:bugs` → equivalent to `/devloop:issues bugs`
- `/devloop:bug` → equivalent to `/devloop:new` with type=bug
