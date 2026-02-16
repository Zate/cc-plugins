#!/bin/sh
# Start clip2png watcher daemon on session start (WSL2 only)
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLIP2PNG="${PLUGIN_ROOT}/scripts/clip2png"

if [ ! -x "$CLIP2PNG" ]; then
    echo '{"suppressOutput":true}'
    exit 0
fi

# Start watcher in background (clip2png handles WSL detection internally)
"$CLIP2PNG" --watch >/dev/null 2>&1 &

# Check status for reporting
status=$("$CLIP2PNG" --status 2>/dev/null) || true

if echo "$status" | grep -q "Running"; then
    pid=$(echo "$status" | grep -o '[0-9]*$')
    cat <<EOF
{"suppressOutput":true,"systemMessage":"wsl-clipboard-fix: clip2png watcher active (PID ${pid})","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"clip2png BMP-to-PNG watcher started for WSL2 image paste support"}}
EOF
else
    cat <<EOF
{"suppressOutput":true,"systemMessage":"wsl-clipboard-fix: not active (non-WSL or missing deps)"}
EOF
fi
