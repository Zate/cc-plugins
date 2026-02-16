#!/bin/sh
# Start clip2png watcher daemon on session start (WSL2 only)
# Note: Claude Code pipes JSON on stdin. Drain it to prevent dash heredoc issues.
cat > /dev/null

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLIP2PNG="${PLUGIN_ROOT}/scripts/clip2png"

if [ ! -x "$CLIP2PNG" ]; then
    printf '{"suppressOutput":true}\n'
    exit 0
fi

# Pre-flight: skip entirely if not WSL
if [ ! -f /proc/sys/fs/binfmt_misc/WSLInterop ] && [ ! -f /proc/sys/fs/binfmt_misc/WSLInterop-late ]; then
    if ! grep -qi microsoft /proc/version 2>/dev/null; then
        printf '{"suppressOutput":true}\n'
        exit 0
    fi
fi

# Pre-flight: check dependencies exist
for cmd in wl-paste wl-copy convert; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf '{"suppressOutput":true,"systemMessage":"wsl-clipboard-fix: missing %s. Run: sudo apt install wl-clipboard imagemagick"}\n' "$cmd"
        exit 0
    fi
done

# Start watcher in background (no-op if already running)
"$CLIP2PNG" --watch >/dev/null 2>&1 &

# Brief pause to let daemon write PID file
sleep 0.2

# Register this session
"$CLIP2PNG" --ref-up >/dev/null 2>&1

# Check status for reporting
status=$("$CLIP2PNG" --status 2>/dev/null) || true

if echo "$status" | grep -q "Running"; then
    pid=$(echo "$status" | grep -o '[0-9]*$')
    printf '{"suppressOutput":true,"systemMessage":"wsl-clipboard-fix: clip2png watcher active (PID %s)","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"clip2png BMP-to-PNG watcher started for WSL2 image paste support"}}\n' "$pid"
else
    printf '{"suppressOutput":true,"systemMessage":"wsl-clipboard-fix: watcher failed to start, check /tmp/clip2png.log"}\n'
fi
