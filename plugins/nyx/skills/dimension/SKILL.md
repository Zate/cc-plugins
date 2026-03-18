---
name: dimension
description: "Manage Nyx dimensions — isolated contexts for projects and topics. Create, switch, list, and archive dimensions."
user-invocable: true
argument-hint: "[create|switch|list|archive] [name]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Dimension Management

Dimensions are isolated contexts — each with its own state, working memory, and momentum. They isolate knowledge and context, not files.

## Technical Model

- Each dimension is a named context backed by ctx tag namespaces (`dim:<name>`)
- State files live at `~/.claude/nyx/dimensions/<name>.md`
- The active dimension is tracked in `~/.claude/nyx/current` (plain text, just the name)
- Template for new dimensions: `${CLAUDE_PLUGIN_ROOT}/templates/dimension-state.md`

## Commands

Parse `$ARGUMENTS` for the subcommand:

### `create [name] "[goal]"`

1. Create `~/.claude/nyx/dimensions/` directory if it doesn't exist (use Bash: `mkdir -p`)
2. Read the dimension state template from `${CLAUDE_PLUGIN_ROOT}/templates/dimension-state.md`
3. Replace `{{name}}` with the dimension name, `{{date}}` with today's date, `{{purpose}}` with the goal
4. Write to `~/.claude/nyx/dimensions/<name>.md`
5. Write the dimension name to `~/.claude/nyx/current`
6. Emit ctx command to seed the dimension: `<ctx:remember type="decision" tags="dim:<name>,tier:working">Created dimension <name>: <goal></ctx:remember>`
7. Confirm creation. Show the state file.

### `switch [name]`

1. Read `~/.claude/nyx/current` to find current dimension
2. If currently in a dimension, ask: "Update return notes for [current] before switching?" If yes, read the current dimension state file and update the Return Notes section.
3. Verify target dimension exists at `~/.claude/nyx/dimensions/<name>.md`
4. Write new dimension name to `~/.claude/nyx/current`
5. Read the target dimension state file
6. Emit ctx recall: `<ctx:recall query="tag:dim:<name>"/>`
7. Orient: present the dimension's goal, active focus, and return notes
8. Confirm switch

### `list`

1. Glob `~/.claude/nyx/dimensions/*.md`
2. For each file, read the YAML frontmatter to get dimension name, status, created date
3. Read the Active Focus section for each
4. Read `~/.claude/nyx/current` to mark which is active
5. Present as table:

| Dimension | Status | Created | Active Focus | Current |
|-----------|--------|---------|--------------|---------|

If no dimensions exist, say so and suggest creating one.

### `archive [name]`

1. Read the dimension state file at `~/.claude/nyx/dimensions/<name>.md`
2. Summarize key decisions and findings from the dimension
3. Emit ctx command to create reference summary: `<ctx:remember type="decision" tags="dim:<name>,tier:reference">Archived dimension <name>: [summary of key decisions and outcomes]</ctx:remember>`
4. Update the state file's YAML frontmatter: change `status: active` to `status: archived`
5. Read `~/.claude/nyx/current` — if this is the active dimension, clear the file (write empty string)
6. Confirm archive with summary of what was preserved

## No arguments

If `$ARGUMENTS` is empty, list dimensions (same as `list`).
