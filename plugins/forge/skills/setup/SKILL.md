---
name: setup
description: "Install, build, and configure the Forge agent job runner. Verify the binary, start the daemon, and validate everything works."
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

# Forge Setup

Build, install, and verify the Forge agent job runner.

## Step 1: Check if forge is already installed

```bash
command -v forge && forge version
```

If found and working, skip to Step 4.

## Step 2: Build from source

The forge source lives at `~/projects/forge`.

```bash
cd ~/projects/forge && go build -o forge ./cmd/forge
```

## Step 3: Install the binary

Ask the user where to install. Common options:
- `~/.local/bin/forge` (user-local, usually on PATH)
- `/usr/local/bin/forge` (system-wide, needs sudo)
- Leave in `~/projects/forge/` and add to PATH

```bash
cp ~/projects/forge/forge ~/.local/bin/forge
```

Verify:
```bash
forge version
```

## Step 4: Check daemon status

```bash
if [[ -f ~/.forge/forge.pid ]]; then
    PID=$(cat ~/.forge/forge.pid | tr -d '[:space:]')
    if kill -0 "$PID" 2>/dev/null; then
        echo "Daemon running (pid $PID)"
    else
        echo "Stale PID file - daemon not running"
    fi
else
    echo "Daemon not running"
fi
```

## Step 5: Start daemon if needed

```bash
nohup forge daemon > ~/.forge/daemon.log 2>&1 &
sleep 1
forge list
```

## Step 6: Verify config

```bash
cat ~/.forge/config.yaml 2>/dev/null || echo "No config - using defaults (agent: claude, model: sonnet, timeout: 10m)"
```

## Step 7: Test with a quick job

```bash
forge run --agent claude --model haiku "Say hello in one sentence"
```

## Report to user

Summarize:
- Binary location and version
- Daemon status and PID
- Config file location and key settings
- Available agents: claude, gemini, local (Ollama), lmstudio
- MCP tools are now available: `forge_submit`, `forge_status`, `forge_output`, `forge_list`
