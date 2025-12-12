---
description: Configure the devloop statusline for Claude Code
argument-hint: None required
allowed-tools: ["Read", "Write", "Edit", "Glob", "Bash", "AskUserQuestion"]
---

# Devloop Statusline Setup

Configure a rich statusline that displays:
- **Model**: Current model name (Opus/Sonnet/Haiku)
- **Path**: Current working directory (shortened)
- **Git Branch**: Current branch name
- **Plan Progress**: Tasks completed from active devloop plan (X/Y)
- **Bug Count**: Number of open tracked bugs
- **Context Usage**: Percentage of context window consumed

## Setup Process

### Step 1: Check Current Configuration

First, read the user's Claude settings to see if a statusline is already configured:

```bash
# Check if settings file exists
cat ~/.claude/settings.json 2>/dev/null || echo "{}"
```

### Step 2: Configure the Statusline

The devloop statusline script is located at:
`${CLAUDE_PLUGIN_ROOT}/statusline/devloop-statusline.sh`

Add or update the statusline configuration in `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "${CLAUDE_PLUGIN_ROOT}/statusline/devloop-statusline.sh",
    "padding": 0
  }
}
```

**IMPORTANT**: You must replace `${CLAUDE_PLUGIN_ROOT}` with the actual absolute path to the devloop plugin. Find this by:

1. Looking for the devloop plugin installation location
2. The path should look like: `/home/USER/.claude/plugins/devloop` or wherever plugins are installed

### Step 3: Verify Dependencies

The statusline script requires `jq` for JSON parsing. Check if it's installed:

```bash
which jq || echo "jq not found - please install with: sudo apt install jq"
```

### Step 4: Test the Statusline

Test the script manually:

```bash
echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"/test","project_dir":"/test"},"context_window":{"total_input_tokens":1000,"total_output_tokens":500,"context_window_size":200000}}' | ${CLAUDE_PLUGIN_ROOT}/statusline/devloop-statusline.sh
```

### Step 5: Confirm Setup

After updating settings, inform the user:

1. The statusline will appear at the bottom of Claude Code
2. It updates whenever the conversation changes
3. Shows real-time context usage and project status

## Customization Options

If the user wants to customize, they can:

1. Copy the script to `~/.claude/statusline.sh`
2. Modify the script to their preferences
3. Update settings.json to point to their custom version

## Example Output

```
Opus | cc-plugins | main | Plan:3/10 | Bugs:2 | 45%
```

## Troubleshooting

If the statusline doesn't appear:

1. Ensure the script is executable: `chmod +x ~/.claude/plugins/devloop/statusline/devloop-statusline.sh`
2. Verify `jq` is installed
3. Check that settings.json has valid JSON
4. Restart Claude Code to pick up settings changes
