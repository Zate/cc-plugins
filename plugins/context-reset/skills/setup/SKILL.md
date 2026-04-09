---
name: setup
description: "Guide the user through setting up context-reset: verify terminal injection method (tmux/tiocsti/xdotool), test the hook, and confirm everything works."
user-invocable: true
allowed-tools: [Bash, Read]
---

# Context Reset Setup

Verify that context-reset is properly configured and a terminal injection method is available.

## Step 1: Check injection methods

Run the diagnostic:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/claude-send.sh --dry-run "/test"
```

If this fails, the user needs one of:

1. **tmux** (recommended): Run Claude Code inside tmux
   ```bash
   tmux new-session -s claude 'claude'
   ```

2. **Enable TIOCSTI** (Linux, requires root):
   ```bash
   sudo sysctl -w dev.tty.legacy_tiocsti=1
   # Persist across reboots:
   echo 'dev.tty.legacy_tiocsti=1' | sudo tee /etc/sysctl.d/99-tiocsti.conf
   ```

3. **Install xdotool** (needs X11/WSLg, window must be focused):
   ```bash
   sudo apt install xdotool
   ```

## Step 2: Verify the SessionStart hook

The plugin's `settings.json` registers the hook automatically. Verify it's active:

```bash
cat ${CLAUDE_PLUGIN_ROOT}/settings.json
```

## Step 3: Test end-to-end

From a **separate terminal** (not this Claude session):

```bash
# Write a test trigger
mkdir -p ~/.cache/claude-autorun
echo "say 'context-reset is working'" > ~/.cache/claude-autorun/pending-command

# Then in this Claude session, run /clear
# After clear, Claude should automatically say the test message
```

Or use the full flow:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/claude-clear-and-run.sh "say 'hello from context-reset'"
```
