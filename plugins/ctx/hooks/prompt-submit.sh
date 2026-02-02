#!/bin/bash
# ctx UserPromptSubmit hook - inject pending recalls and nudges
set -euo pipefail

# Ensure ctx is available
if ! command -v ctx &> /dev/null; then
    [ -x "$HOME/.local/bin/ctx" ] && export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v ctx &> /dev/null; then
    echo '{}'
    exit 0
fi

ctx hook prompt-submit
