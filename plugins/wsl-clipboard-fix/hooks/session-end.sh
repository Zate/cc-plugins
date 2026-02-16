#!/bin/sh
# Stop clip2png watcher daemon on session end
# Note: Claude Code pipes JSON on stdin. Drain it to prevent dash heredoc issues.
cat > /dev/null

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLIP2PNG="${PLUGIN_ROOT}/scripts/clip2png"

if [ ! -x "$CLIP2PNG" ]; then
    printf '{"suppressOutput":true}\n'
    exit 0
fi

"$CLIP2PNG" --stop >/dev/null 2>&1 || true

printf '{"suppressOutput":true,"systemMessage":"wsl-clipboard-fix: clip2png watcher stopped"}\n'
