---
description: View and manage tracked bugs - list, filter, fix, or close bugs
argument-hint: Optional filter (open, high, etc.) or bug ID
allowed-tools: ["Read", "Bash", "AskUserQuestion", "Skill"]
---

# Manage Bugs

View, filter, and manage tracked bugs in the project.

> **Note**: For full unified issue tracking, use `/devloop:issues`.

## Quick Usage

- `/devloop:bugs` - Show all open bugs
- `/devloop:bugs high` - Show high priority bugs
- `/devloop:bugs BUG-003` - Show specific bug
- `/devloop:bugs fix` - Start fixing bugs
- `/devloop:bugs stats` - Show statistics

## Workflow

### 1. Parse Arguments

Handle different argument patterns:

| Argument | Action |
|----------|--------|
| (none) | List open bugs: `--type bug --status open --format markdown` |
| `high` | Filter high priority: `--priority high` |
| `medium` | Filter medium priority: `--priority medium` |
| `low` | Filter low priority: `--priority low` |
| `open` | Show open only: `--status open` |
| `all` | Show all statuses (no status filter) |
| `BUG-NNN` | Read `.devloop/issues/BUG-NNN.md` directly |
| `fix` | Enter fix mode (see step 3) |
| `stats` | Show statistics (see step 4) |

### 2. List Bugs

Use list-issues.sh script:

```bash
# Default: open bugs
./plugins/devloop/scripts/list-issues.sh --type bug --status open --format markdown

# With priority filter
./plugins/devloop/scripts/list-issues.sh --type bug --priority high --format markdown

# All bugs (no status filter)
./plugins/devloop/scripts/list-issues.sh --type bug --format markdown
```

### 3. Fix Mode

When user wants to fix a bug:

1. **Select bug** using AskUserQuestion (list from script output)
2. **Mark in-progress**: `./plugins/devloop/scripts/update-issue.sh ISSUE_ID --status in-progress`
3. **Read bug details**: `Read .devloop/issues/BUG-NNN.md`
4. **Route to agent** based on approach:

| Approach | Action |
|----------|--------|
| Quick fix | Direct implementation - read related files and fix |
| Investigate | Use `/devloop:engineer` in explore mode |
| Full workflow | Redirect to `/devloop` with bug context |

5. **Mark resolved**: `./plugins/devloop/scripts/update-issue.sh ISSUE_ID --resolve "Fix description"`

### 4. Statistics Mode

When `$ARGUMENTS` is `stats`:

```bash
# Get JSON output and parse for counts
./plugins/devloop/scripts/list-issues.sh --type bug --format json
```

Parse JSON to display:
- Total bugs
- Count by status (open, in-progress, done, blocked)
- Count by priority (high, medium, low)

---

## Agent Routing

When fixing bugs:

| Action | Agent | Mode/Focus |
|--------|-------|------------|
| Investigate | `devloop:engineer` | Explore mode - trace bug source |
| Quick fix | Direct implementation | No agent needed |
| Complex fix | `/devloop` workflow | Full agent routing |

---

## See Also

- `/devloop:new` - Smart issue creation
- `/devloop:issues` - View all issues
- `/devloop:bug` - Report a new bug
