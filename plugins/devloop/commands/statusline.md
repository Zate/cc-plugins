---
description: Configure the devloop statusline for Claude Code
argument-hint: None required
allowed-tools:
  - Read
  - Edit
  - Bash
  - AskUserQuestion
  - Task
---

# Devloop Statusline Setup

Configure the devloop statusline to display real-time session information.

## What the Statusline Shows

- **Model**: Current model name (Opus/Sonnet/Haiku)
- **Context**: Progress bar + percentage of context window used
- **Tokens**: Total session tokens (formatted as K/M)
- **API Limits**: 5-hour and 7-day usage percentages (if available)
- **Path**: Current working directory (shortened)
- **Git Branch**: Current branch name
- **Plan Progress**: Tasks completed (X/Y) from `.devloop/plan.md`
- **Bug Count**: Open issues from `.devloop/issues/`

## Setup Process

Use the Task tool to launch the `statusline-setup` agent:

```
Task: statusline-setup agent
Prompt: Configure the devloop statusline. Check for existing statusline configuration and set up appropriately.
```

The agent will:
1. Check `~/.claude/settings.json` for existing statusline
2. Handle conflicts (offer to replace or keep existing)
3. Configure the devloop statusline path
4. Confirm the setup

## After Setup

Once configured, restart Claude Code to see the statusline at the bottom of your terminal.

Example output:
```
Opus-4.6 | █░░░░ 23% | 45.2K | 5h 12% 7d 8% | cc-plugins | main | P:3/10
```

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
