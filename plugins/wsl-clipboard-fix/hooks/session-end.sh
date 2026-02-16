#!/bin/sh
# Stop clip2png watcher daemon on session end
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLIP2PNG="${PLUGIN_ROOT}/scripts/clip2png"

if [ ! -x "$CLIP2PNG" ]; then
    echo '{"suppressOutput":true}'
    exit 0
fi

"$CLIP2PNG" --stop >/dev/null 2>&1 || true

cat <<EOF
{"suppressOutput":true,"systemMessage":"wsl-clipboard-fix: clip2png watcher stopped"}
EOF
