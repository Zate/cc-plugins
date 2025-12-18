---
description: View all issues (replaces and extends /devloop:bugs) - filter by type, status, or ID
argument-hint: Optional filter (bugs, features, backlog, BUG-001) or action (fix, close)
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill"]
---

# Manage Issues

View, filter, and manage all tracked issues - bugs, features, tasks, chores, and spikes.

**IMPORTANT**: Invoke `Skill: issue-tracking` for issue format and storage details.

## Quick Usage

- `/devloop:issues` - Show all open issues
- `/devloop:issues bugs` - Show only bugs
- `/devloop:issues features` - Show only features
- `/devloop:issues backlog` - Show open features + tasks
- `/devloop:issues high` - Show high priority issues
- `/devloop:issues BUG-003` - Show specific issue
- `/devloop:issues fix` - Enter fix mode

## Workflow

### Step 1: Check Issue Directory

Check for `.claude/issues/` directory:

```bash
if [ -d ".claude/issues" ]; then
    ls .claude/issues/
else
    echo "No issues tracked yet. Use /devloop:new to create one."
fi
```

If `.claude/bugs/` exists but not `.claude/issues/`, offer migration (see Migration section).

### Step 2: Parse Arguments

If `$ARGUMENTS` provided:

| Argument | Action |
|----------|--------|
| `bugs` | Filter to type:bug only |
| `features` | Filter to type:feature only |
| `tasks` | Filter to type:task only |
| `backlog` | Show open features + tasks |
| `open` | Filter to status:open |
| `in-progress` | Filter to status:in-progress |
| `done` | Filter to status:done |
| `high` | Filter to priority:high |
| `medium` | Filter to priority:medium |
| `low` | Filter to priority:low |
| `all` | Show all issues including done |
| `{PREFIX}-NNN` | Show specific issue (e.g., BUG-001, FEAT-002) |
| `fix` | Enter fix mode |
| `stats` | Show statistics |

### Step 3: Load and Display Issues

Read issue files and display based on filter:

#### Default View (Open Issues by Priority)

```markdown
## Issue Tracker

**Open**: {N} | **In Progress**: {N} | **Done**: {N}

[Bugs]({N}) | [Features]({N}) | [Tasks]({N}) | [Backlog]({N})

### High Priority
| ID | Type | Title | Created | Labels |
|----|------|-------|---------|--------|
| BUG-003 | bug | Auth token refresh | 2024-12-18 | auth, api |
| FEAT-001 | feature | User auth flow | 2024-12-17 | auth, mvp |

### Medium Priority
| ID | Type | Title | Created | Labels |
|----|------|-------|---------|--------|
| BUG-001 | bug | Button truncation | 2024-12-16 | ui |
| TASK-001 | task | Refactor helpers | 2024-12-18 | tech-debt |

### Low Priority
| ID | Type | Title | Created | Labels |
|----|------|-------|---------|--------|
| CHORE-001 | chore | Update deps | 2024-12-18 | maintenance |

### In Progress
| ID | Type | Title | Assignee |
|----|------|-------|----------|
| FEAT-002 | feature | Dark mode | current-session |
```

#### Bugs View (`bugs` argument)

```markdown
## Bugs

**Open**: {N} | **In Progress**: {N} | **Fixed**: {N}

### Open Bugs
| ID | Priority | Title | Created | Labels |
|----|----------|-------|---------|--------|
| BUG-003 | high | Auth token refresh | 2024-12-18 | auth |
| BUG-001 | medium | Button truncation | 2024-12-16 | ui |

### In Progress
| ID | Title | Assignee |
|----|-------|----------|
| BUG-002 | Form validation | current-session |

### Recently Fixed
| ID | Title | Fixed |
|----|-------|-------|
| BUG-004 | Missing null check | 2024-12-18 |
```

#### Features View (`features` argument)

```markdown
## Features

**Open**: {N} | **In Progress**: {N} | **Done**: {N}

### Open Features
| ID | Priority | Title | Estimate | Labels |
|----|----------|-------|----------|--------|
| FEAT-001 | high | User auth flow | L | auth, mvp |
| FEAT-003 | medium | Export to CSV | M | export |

### In Progress
| ID | Title | Assignee |
|----|-------|----------|
| FEAT-002 | Dark mode | current-session |
```

#### Backlog View (`backlog` argument)

```markdown
## Backlog

Open features and tasks, sorted by priority.

**Total Items**: {N}

### High Priority
| ID | Type | Title | Estimate | Labels |
|----|------|-------|----------|--------|
| FEAT-001 | feature | User auth flow | L | mvp |

### Medium Priority
| ID | Type | Title | Estimate | Labels |
|----|------|-------|----------|--------|
| FEAT-003 | feature | Export to CSV | M | export |
| TASK-001 | task | Add unit tests | M | testing |

### Low Priority
| ID | Type | Title | Estimate | Labels |
|----|------|-------|----------|--------|
| TASK-002 | task | Refactor helpers | S | tech-debt |
```

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

1. Read `.claude/issues/{PREFIX}-{NNN}.md`
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
  - Add context (Update with more info)
  - Close (Mark as done or won't do)
  - Back (Return to list)
```

### Step 6: Work Mode

When user wants to work on an issue:

1. If no specific issue selected, show picker:
   ```
   Use AskUserQuestion:
   - question: "Which issue would you like to work on?"
   - header: "Select Issue"
   - options:
     - [BUG-003] High: Auth token refresh (Recommended)
     - [FEAT-001] High: User auth flow
     - [BUG-001] Medium: Button truncation
     - Let me pick (Show full list)
   ```

2. Mark issue as `in-progress` in both issue file and views

3. Read the issue file for full context

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
   - **Investigate**: Launch code-explorer on related files
   - **Full devloop**: Redirect to `/devloop` with issue as input

6. After completing:
   - Update issue status to `done`
   - Add Resolution section to issue file
   - Regenerate all views
   - Ask about next issue

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

2. Update issue:
   - Set status to `done`
   - Add Resolution section with summary
   - Add commit/PR reference if available

If other reasons:
1. Update issue:
   - Set status to `wont-do`
   - Add reason to issue file

3. Regenerate all views

---

## Statistics Mode

When `$ARGUMENTS` is `stats`:

```markdown
## Issue Statistics

**Total Tracked**: {N}
**Open**: {N} ({%}) | **In Progress**: {N} ({%}) | **Done**: {N} ({%})

### By Type
| Type | Open | In Progress | Done | Total |
|------|------|-------------|------|-------|
| Bug | 3 | 1 | 5 | 9 |
| Feature | 2 | 1 | 3 | 6 |
| Task | 2 | 0 | 1 | 3 |
| Chore | 1 | 0 | 2 | 3 |
| Spike | 0 | 0 | 2 | 2 |

### By Priority (Open Only)
- High: {N}
- Medium: {N}
- Low: {N}

### By Label
| Label | Count |
|-------|-------|
| auth | 4 |
| ui | 3 |
| api | 2 |

### Recent Activity
- BUG-007 fixed (2024-12-18)
- FEAT-003 created (2024-12-18)
- TASK-001 started (2024-12-17)

### Oldest Open Issues
1. BUG-001 (5 days) - Button truncation
2. FEAT-001 (3 days) - User auth flow
```

---

## Batch Operations

For managing multiple issues:

```
Use AskUserQuestion:
- question: "Select a batch operation"
- header: "Batch"
- multiSelect: false
- options:
  - Close all low (Mark all low priority as won't do)
  - Reprioritize (Bulk change priorities)
  - Archive done (Move old done issues to archive)
  - Label issues (Add labels to multiple issues)
```

---

## View File Management

After any modification (create, update, close):

1. Regenerate `index.md` - Master index of all issues
2. Regenerate `bugs.md` - Bug-only view
3. Regenerate `features.md` - Feature-only view
4. Regenerate `backlog.md` - Open features + tasks

View files are derived from issue files. Issue files are the source of truth.

---

## Migration from .claude/bugs/

If `.claude/bugs/` exists but `.claude/issues/` doesn't:

```
Use AskUserQuestion:
- question: "Found existing .claude/bugs/ directory. Migrate to unified issue system?"
- header: "Migrate"
- multiSelect: false
- options:
  - Yes, migrate (Recommended - keeps all data)
  - No, use separately (Both systems will work)
  - Later (Skip for now)
```

If migrating:
1. Create `.claude/issues/` directory
2. Copy each `BUG-*.md` file, adding `type: bug` to frontmatter
3. Rename `tags` to `labels` if present
4. Generate all view files
5. Optionally remove `.claude/bugs/` after verification

---

## Backwards Compatibility

These legacy commands still work:
- `/devloop:bugs` → equivalent to `/devloop:issues bugs`
- `/devloop:bug` → equivalent to `/devloop:new` with type=bug

---

## Integration with Devloop

- Issues can be addressed during `/devloop:continue` sessions
- DoD validator checks for related open issues
- Summary generator notes issues resolved
- Plan tasks can reference issues via `related-plan-task`
- `/devloop:new` creates issues that appear here
