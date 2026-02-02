#!/bin/bash
# Check if ctx binary is available and working
set -euo pipefail

if command -v ctx &> /dev/null; then
    LOCATION=$(command -v ctx)
    echo "found:${LOCATION}"
    exit 0
else
    echo "not-found"
    exit 1
fi
