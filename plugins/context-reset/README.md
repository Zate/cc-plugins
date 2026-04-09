# context-reset

Programmatic context clearing for Claude Code. Send `/clear` and auto-run a follow-up skill from hooks, cron, or scripts — no binary patching required.

## Problem

Claude Code has no API or IPC mechanism to programmatically clear context. The `/clear` command only works via interactive input. This makes it impossible to automate "clear and restart with a fresh task" workflows from hooks or external scripts.

## Solution

A two-phase approach using terminal injection + SessionStart hooks:

```
External trigger (hook/cron/script)
  → writes pending command to trigger file + lockfile
  → injects /clear via tmux send-keys (or tiocsti/xdotool)
  → Claude processes /clear, resets state
  → SessionStart hook fires (matcher: clear only)
  → checks for lockfile (no lockfile = manual /clear, exit)
  → reads trigger file, removes both files
  → initialUserMessage injects the follow-up command
  → Claude executes it in a fresh session
```

Manual `/clear` is never affected -- the hook only acts when the lockfile is present.

## Quick Start

1. Install the plugin (it's part of cc-plugins)
2. Run Claude inside tmux: `tmux new -s claude 'claude'`
3. From another terminal:
   ```bash
   ./scripts/claude-clear-and-run.sh "/my-skill"
   ```

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/claude-send.sh` | Low-level: inject any input into Claude's terminal |
| `scripts/claude-clear-and-run.sh` | High-level: clear + auto-run a command |

## Injection Methods

| Method | How | Reliability | Setup |
|--------|-----|-------------|-------|
| tmux | `send-keys` to the pane | Best | Run Claude inside tmux |
| tiocsti | `ioctl(TIOCSTI)` to PTY | Good | `sudo sysctl -w dev.tty.legacy_tiocsti=1` |
| xdotool | X11 keystroke simulation | OK | `sudo apt install xdotool` + window focus |

Auto-detected in preference order. Override with `CLAUDE_SEND_METHOD=tmux`.

## Hook Contract

The SessionStart hook (`hooks/session-start-autorun.sh`) outputs:

```json
{
  "suppressOutput": true,
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "initialUserMessage": "/the-command-to-run"
  }
}
```

The hook only fires on `clear` events (via matcher) and only when `autorun.lock` exists (written by `claude-clear-and-run.sh`). Manual `/clear` commands are ignored.

Verified against Claude Code source (`src/types/hooks.ts:84-86`).
