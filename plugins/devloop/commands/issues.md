---
description: List GitHub issues for the current repository
argument-hint: "[--state open|closed|all] [--label LABEL] [--assignee USER]"
allowed-tools:
  - Read
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - AskUserQuestion
---

# Issues - List GitHub Issues

Display GitHub issues for the current repository. **You execute this directly.**

## Step 1: Check GitHub Setup

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-gh-setup.sh"
```

Parse the JSON output and check `preferred_method`:

**If `preferred_method` is "none":**

Check the specific issue:

- If `gh_installed` is false:
```
GitHub CLI is not installed.

To install:
- macOS: brew install gh
- Windows: winget install GitHub.cli
- Linux: See https://github.com/cli/cli/blob/trunk/docs/install_linux.md

Alternatively, set a GITHUB_TOKEN environment variable to use the API directly.
```

- If `gh_installed` is true but `gh_authenticated` is false:
```
GitHub CLI is installed but not authenticated.

Run: gh auth login

This will guide you through authentication with your GitHub account.
```

Then exit - do not continue to Step 2.

**If `preferred_method` is "gh" or "curl":**

Continue to Step 2.

## Step 2: Parse Arguments

Parse `$ARGUMENTS` for filter options:
- `--state STATE` - Filter by state: open (default), closed, all
- `--label LABEL` - Filter by label (can appear multiple times)
- `--assignee USER` - Filter by assignee

Build the command arguments.

## Step 3: Fetch and Display Issues

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/list-issues.sh" [options from step 2]
```

Display the formatted output to the user.

**If no issues found:**
```
No issues found matching your criteria.

Try different filters:
- /devloop:issues --state all
- /devloop:issues --state closed
```

## Step 4: Offer Next Actions

```yaml
AskUserQuestion:
  questions:
    - question: "What would you like to do?"
      header: "Action"
      multiSelect: false
      options:
        - label: "Start work on an issue"
          description: "Use /devloop:from-issue <number>"
        - label: "Filter differently"
          description: "Search with different criteria"
        - label: "Done"
          description: "Exit issue list"
```

### If "Start work on an issue":
Ask which issue number, then run `/devloop:from-issue <number>`

### If "Filter differently":
Ask for new filter criteria and re-run Step 3

### If "Done":
Exit

---

## Quick Reference

| Option | Description | Default |
|--------|-------------|---------|
| `--state` | Issue state: open, closed, all | open |
| `--label` | Filter by label | none |
| `--assignee` | Filter by assignee | none |

## Examples

```bash
# List open issues (default)
/devloop:issues

# List all issues
/devloop:issues --state all

# List bugs only
/devloop:issues --label bug

# List issues assigned to me
/devloop:issues --assignee @me

# Combined filters
/devloop:issues --state open --label enhancement
```

## Output Format

```
# Open Issues (12)

#42  [bug]        Login fails on Safari                          @alice   2d ago
#38  [feature]    Add dark mode                                  @bob     5d ago
#35  [docs]       Update README                                  -        1w ago
```
