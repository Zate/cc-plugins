---
name: dimension
description: "Manage Nyx dimensions — isolated contexts for projects and topics. Create, switch, list, and archive dimensions."
user-invocable: true
argument-hint: "[create|switch|list|archive] [name]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Dimension Management

Dimensions are isolated contexts — each with its own state, working memory, files, and momentum.

## Technical Model

Dimensions use **two layers of isolation**:

1. **File isolation**: Git branches in the Nyx home repo (`~/.nyx/`). Each dimension is a branch named `dim/<name>`. Branch-local files (notes, drafts, scratch) stay isolated. Shared files (templates, identity) live on `main`.

2. **Memory isolation**: ctx tag namespaces (`dim:<name>`). Knowledge tagged to a dimension stays scoped to that dimension via ctx recall.

- State files live at `dimensions/<name>.md` in the Nyx home repo (branch-local)
- The current dimension = the current git branch
- Template for new dimensions: `${CLAUDE_PLUGIN_ROOT}/templates/dimension-state.md`
- The Nyx home repo is at `~/.nyx/` (or `$NYX_HOME`)

## Commands

Parse `$ARGUMENTS` for the subcommand:

### `create [name] "[goal]"`

1. Verify we're in the Nyx home repo. If the current working directory isn't `~/.nyx/`, check if it's an additional working directory and operate there. If neither, warn and ask.
2. Commit any uncommitted changes on the current branch (ask first if there are changes)
3. Create and checkout a new branch: `git checkout -b dim/<name>`
4. Read the dimension state template from `${CLAUDE_PLUGIN_ROOT}/templates/dimension-state.md`
5. Replace `{{name}}` with the dimension name, `{{date}}` with today's date, `{{purpose}}` with the goal
6. Write to `dimensions/<name>.md`
7. Create a `notes/` directory for scratch (if it doesn't exist)
8. Commit: `git add -A && git commit -m "dim: create <name> — <goal>"`
9. Emit ctx command to seed the dimension: `<ctx:remember type="decision" tags="dim:<name>,tier:working">Created dimension <name>: <goal></ctx:remember>`
10. Confirm creation. Show the state file.

### `switch [name]`

1. Check the current branch with `git branch --show-current`
2. If currently on a `dim/` branch:
   - Ask: "Update return notes for [current] before switching?"
   - If yes, read the current dimension state file and update the Return Notes section
   - Commit any changes: `git add -A && git commit -m "dim: checkpoint <current>"`
3. Verify target branch exists: `git rev-parse --verify dim/<name>`
4. Checkout: `git checkout dim/<name>`
5. Read the target dimension state file at `dimensions/<name>.md`
6. Emit ctx recall: `<ctx:recall query="tag:dim:<name>"/>`
7. Orient: present the dimension's goal, active focus, and return notes
8. Confirm switch

### `list`

1. List dimension branches: `git branch --list 'dim/*'`
2. Also list archived branches: `git branch --list 'archive/*'`
3. Get the current branch: `git branch --show-current`
4. For each active dimension, try to read `dimensions/<name>.md` from that branch to get status and active focus (use `git show dim/<name>:dimensions/<name>.md` to read without checkout)
5. Present as table:

| Dimension | Status | Active Focus | Current |
|-----------|--------|--------------|---------|

Mark the current branch with `*`. Show archived dimensions separately if any exist.

If no dimensions exist, say so and suggest creating one.

### `archive [name]`

1. If currently on `dim/<name>`, switch to main first: `git checkout main`
2. Read the dimension state file: `git show dim/<name>:dimensions/<name>.md`
3. Summarize key decisions and findings from the dimension
4. Emit ctx command to create reference summary: `<ctx:remember type="decision" tags="dim:<name>,tier:reference">Archived dimension <name>: [summary of key decisions and outcomes]</ctx:remember>`
5. Rename branch: `git branch -m dim/<name> archive/<name>`
6. Confirm archive with summary of what was preserved

## No arguments

If `$ARGUMENTS` is empty, list dimensions (same as `list`).

## Notes

- `main` is not a dimension — it's Nyx's home. Shared templates, identity, and configuration live there.
- Dimension branches should be created from `main` to inherit shared files.
- The `notes/` directory is for scratch work — it's branch-local, use it freely.
- When archiving, long-term knowledge goes to ctx (persists everywhere). Branch-local files are preserved in the archive branch (accessible but not active).
