---
name: clear-and-run
description: "Clear Claude Code context and auto-run a follow-up skill or prompt in the fresh session. Use when the user wants to reset context and immediately start a new task, automate context cycling, or chain skills across clear boundaries."
user-invocable: true
allowed-tools: [Bash, Read]
argument-hint: '"/skill-name" or "prompt text" [--no-clear]'
---

# Context Reset: Clear and Run

Clears the current Claude Code context and automatically runs a command in the fresh session.

## How It Works

1. A trigger file is written with the follow-up command
2. `/clear` is sent to Claude Code via terminal injection (tmux/tiocsti/xdotool)
3. The SessionStart hook picks up the trigger and injects it as `initialUserMessage`

This two-phase approach avoids fragile sleep-based timing — the hook fires deterministically after `/clear` completes.

## Usage

Run the script from a terminal (outside Claude Code):

```bash
# Clear and run a skill
${CLAUDE_PLUGIN_ROOT}/scripts/claude-clear-and-run.sh "/my-skill"

# Clear and run with arguments
${CLAUDE_PLUGIN_ROOT}/scripts/claude-clear-and-run.sh "/devloop:plan 'add auth'"

# Just send a command (no clear)
${CLAUDE_PLUGIN_ROOT}/scripts/claude-clear-and-run.sh --no-clear "explain the auth module"
```

Or use `claude-send` directly for lower-level control:

```bash
# Send any input to Claude Code
${CLAUDE_PLUGIN_ROOT}/scripts/claude-send.sh "/clear"
${CLAUDE_PLUGIN_ROOT}/scripts/claude-send.sh "/my-skill" "follow up"

# Dry run to see what method would be used
${CLAUDE_PLUGIN_ROOT}/scripts/claude-send.sh --dry-run "/clear"
```

## Prerequisites

You need **one** of these terminal injection methods:

| Method | Setup | Reliability |
|--------|-------|-------------|
| **tmux** (recommended) | Run Claude inside `tmux new -s claude 'claude'` | Best |
| **tiocsti** | `sudo sysctl -w dev.tty.legacy_tiocsti=1` | Good (deprecated) |
| **xdotool** | `sudo apt install xdotool` | OK (needs window focus) |

The scripts auto-detect the best available method.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_SEND_METHOD` | auto | Force: `tmux`, `tiocsti`, or `xdotool` |
| `CLAUDE_SEND_DELAY` | `2` | Seconds between multi-command sends |
| `CLAUDE_SEND_PID` | auto | Target a specific Claude Code PID |
| `CLAUDE_AUTORUN_DIR` | `~/.cache/claude-autorun` | Trigger file directory |

## Example: Auto-Cycle with a Stop Hook

To automatically clear and restart a skill when Claude finishes:

```json
{
  "hooks": {
    "Stop": [{
      "type": "command",
      "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/claude-clear-and-run.sh '/my-recurring-skill'"
    }]
  }
}
```

**Warning:** This creates an infinite loop — the skill runs, completes, triggers Stop, which clears and runs the skill again. Use with care and add exit conditions.
