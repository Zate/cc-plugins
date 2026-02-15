#!/bin/bash
# Check if a newer version of ctx is available on GitHub releases.
# Outputs one of:
#   up-to-date:<current_version>
#   update-available:<current_version>:<latest_version>
#   check-failed:<reason>
set -euo pipefail

REPO="Zate/Memdown"

# Get current installed version
if ! command -v ctx &> /dev/null; then
    echo "check-failed:binary-not-found"
    exit 0
fi

CURRENT=$(ctx version 2>/dev/null || echo "")
if [ -z "$CURRENT" ]; then
    echo "check-failed:version-unknown"
    exit 0
fi

# Extract semver from "ctx v0.1.0 (commit abc, built ...)" or "ctx dev ..."
CURRENT_TAG=$(echo "$CURRENT" | sed -n 's/^ctx \([^ ]*\).*/\1/p')
if [ -z "$CURRENT_TAG" ] || [ "$CURRENT_TAG" = "dev" ]; then
    echo "check-failed:dev-build"
    exit 0
fi

# Normalize: ensure it starts with v
case "$CURRENT_TAG" in
    v*) ;;
    *)  CURRENT_TAG="v${CURRENT_TAG}" ;;
esac

# Get latest release tag from GitHub (timeout after 3 seconds to not block session start)
LATEST_TAG=$(curl -sI --max-time 3 "https://github.com/${REPO}/releases/latest" 2>/dev/null \
    | grep -i '^location:' | sed 's/.*tag\///' | tr -d '\r\n' || echo "")

if [ -z "$LATEST_TAG" ]; then
    echo "check-failed:network"
    exit 0
fi

# Extract base semver from current tag (strip git describe suffixes like -4-gabc123-dirty)
# v0.1.0-4-g596b677-dirty → 0.1.0
# v0.1.0 → 0.1.0
CURRENT_CLEAN="${CURRENT_TAG#v}"
CURRENT_BASE=$(echo "$CURRENT_CLEAN" | sed 's/-[0-9]*-g[0-9a-f].*$//')
LATEST_CLEAN="${LATEST_TAG#v}"

if [ "$CURRENT_BASE" = "$LATEST_CLEAN" ]; then
    echo "up-to-date:${CURRENT_TAG}"
else
    # Only report update if latest is actually newer
    # Sort versions and check if latest sorts after current base
    NEWER=$(printf '%s\n%s\n' "$CURRENT_BASE" "$LATEST_CLEAN" | sort -V | tail -1)
    if [ "$NEWER" = "$LATEST_CLEAN" ] && [ "$NEWER" != "$CURRENT_BASE" ]; then
        echo "update-available:${CURRENT_TAG}:${LATEST_TAG}"
    else
        echo "up-to-date:${CURRENT_TAG}"
    fi
fi
