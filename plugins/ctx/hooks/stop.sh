#!/bin/bash
# ctx Stop hook - parse ctx commands from transcript
set -euo pipefail

# Ensure ctx is available
if ! command -v ctx &> /dev/null; then
    [ -x "$HOME/.local/bin/ctx" ] && export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v ctx &> /dev/null; then
    echo '{}'
    exit 0
fi

# Pass stdin through to ctx hook stop (it reads transcript_path from stdin)
ctx hook stop
