---
name: statusline
description: Configure the devloop statusline for Claude Code
argument-hint: None required
allowed-tools:
  - Read
  - Edit
  - Bash
  - AskUserQuestion
---

# Devloop Statusline Setup

Configure the devloop statusline to display real-time session information.

## What the Statusline Shows

- **Model**: Current model name (Opus/Sonnet/Haiku)
- **Context**: Progress bar + percentage of context window used
- **Tokens**: Total session tokens (formatted as K/M)
- **Path**: Current working directory (shortened)
- **Git Branch**: Current branch name
- **Plan Progress**: Tasks completed (X/Y) from `.devloop/plan.md`

## Step 1: Read Current Settings

Read the user's Claude Code settings:

```
Read ~/.claude/settings.json
```

## Step 2: Check Current Status

Analyze the settings to determine the current state:

1. **No statusLine field**: Safe to configure
2. **Existing devloop statusline**: May need path update
3. **Other statusline**: Ask user what to do

## Step 3: Get Plugin Path

The devloop statusline script path follows this pattern:
`~/.claude/plugins/cache/cc-plugins/devloop/{version}/statusline/devloop-statusline.sh`

Find the installed version by checking the plugin cache directory.

## Step 4: Handle Based on State

### If no statusline configured:
Add the statusLine field to settings.json:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/plugins/cache/cc-plugins/devloop/{version}/statusline/devloop-statusline.sh",
    "padding": 0
  }
}
```

### If existing devloop statusline:
Check if path needs updating (version change). Update if necessary.

### If other statusline configured:
```yaml
AskUserQuestion:
  questions:
    - question: "You have an existing statusline configured. What would you like to do?"
      header: "Statusline"
      multiSelect: false
      options:
        - label: "Replace with devloop"
          description: "Use devloop statusline instead"
        - label: "Keep existing"
          description: "Don't change current statusline"
```

## Step 5: Apply Configuration

Use the Edit tool to update `~/.claude/settings.json` with the statusLine configuration.

## Step 6: Confirm

Tell the user:
- Statusline has been configured
- Restart Claude Code to see the changes
- The statusline shows: Model, Context %, Tokens, Path, Git branch, Plan progress

## Dependencies

The statusline requires `jq` for JSON parsing. If not installed:
- macOS: `brew install jq`
- Ubuntu/Debian: `sudo apt install jq`
- Windows: `choco install jq`

## Troubleshooting

If the statusline doesn't appear after restart:
1. Verify jq is installed: `which jq`
2. Check settings.json is valid JSON
3. Ensure the script path exists and is executable
4. Try running the script manually to test

## Customization

To customize the statusline:
1. Copy the script: `cp ~/.claude/plugins/cache/cc-plugins/devloop/*/statusline/devloop-statusline.sh ~/.claude/statusline.sh`
2. Edit `~/.claude/statusline.sh` to your preferences
3. Update settings.json to point to your custom script
