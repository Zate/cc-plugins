#!/bin/sh
# Start clip2png watcher daemon on session start (WSL2 only)
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLIP2PNG="${PLUGIN_ROOT}/scripts/clip2png"

if [ ! -x "$CLIP2PNG" ]; then
    echo '{"suppressOutput":true}'
    exit 0
fi

# Pre-flight: skip entirely if not WSL
if [ ! -f /proc/sys/fs/binfmt_misc/WSLInterop ] && [ ! -f /proc/sys/fs/binfmt_misc/WSLInterop-late ]; then
    if ! grep -qi microsoft /proc/version 2>/dev/null; then
        echo '{"suppressOutput":true}'
        exit 0
    fi
fi

# Pre-flight: check dependencies exist
for cmd in wl-paste wl-copy convert; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        cat <<EOF
{"suppressOutput":true,"systemMessage":"wsl-clipboard-fix: missing ${cmd}. Run: sudo apt install wl-clipboard imagemagick"}
EOF
        exit 0
    fi
done

# Start watcher in background
"$CLIP2PNG" --watch >/dev/null 2>&1 &

# Brief pause to let daemon write PID file
sleep 0.2

# Check status for reporting
status=$("$CLIP2PNG" --status 2>/dev/null) || true

if echo "$status" | grep -q "Running"; then
    pid=$(echo "$status" | grep -o '[0-9]*$')
    cat <<EOF
{"suppressOutput":true,"systemMessage":"wsl-clipboard-fix: clip2png watcher active (PID ${pid})","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"clip2png BMP-to-PNG watcher started for WSL2 image paste support"}}
EOF
else
    cat <<EOF
{"suppressOutput":true,"systemMessage":"wsl-clipboard-fix: watcher failed to start, check /tmp/clip2png.log"}
EOF
fi
