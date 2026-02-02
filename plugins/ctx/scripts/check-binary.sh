#!/bin/bash
# Check if ctx binary is available and working
set -euo pipefail

if command -v ctx &> /dev/null; then
    VERSION=$(ctx version 2>/dev/null || echo "unknown")
    echo "found:${VERSION}"
    exit 0
else
    echo "not-found"
    exit 1
fi
