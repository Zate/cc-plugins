#!/bin/bash
# Download and install ctx binary from GitHub releases
set -euo pipefail

REPO="Zate/Memdown"
BINARY_NAME="ctx"

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in
    linux)  OS="linux" ;;
    darwin) OS="darwin" ;;
    *)      echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *)       echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

# Get latest version tag
VERSION=$(curl -sI "https://github.com/${REPO}/releases/latest" | grep -i '^location:' | sed 's/.*tag\///' | tr -d '\r\n')
if [ -z "$VERSION" ]; then
    echo "Failed to determine latest version" >&2
    exit 1
fi

# Release assets use pattern: ctx_{version}_{os}_{arch}.tar.gz
ASSET_VERSION="${VERSION#v}"
ASSET_NAME="${BINARY_NAME}_${ASSET_VERSION}_${OS}_${ARCH}.tar.gz"
URL="https://github.com/${REPO}/releases/download/${VERSION}/${ASSET_NAME}"

# Find install directory
INSTALL_DIR="${HOME}/.local/bin"
mkdir -p "$INSTALL_DIR"

# Download and extract
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

echo "Downloading ctx ${VERSION} for ${OS}/${ARCH}..." >&2
if ! curl -sL "$URL" -o "$TMPDIR/$ASSET_NAME"; then
    echo "Failed to download from $URL" >&2
    exit 1
fi

tar -xzf "$TMPDIR/$ASSET_NAME" -C "$TMPDIR"
chmod +x "$TMPDIR/$BINARY_NAME"
mv "$TMPDIR/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"

# Verify
if "$INSTALL_DIR/$BINARY_NAME" version &> /dev/null; then
    INSTALLED_VERSION=$("$INSTALL_DIR/$BINARY_NAME" version 2>/dev/null)
    echo "installed:${INSTALLED_VERSION}"
else
    echo "warning:installed but version check failed" >&2
    echo "installed:$INSTALL_DIR/$BINARY_NAME"
fi

# Initialize database if needed
if [ ! -f "$HOME/.ctx/store.db" ]; then
    "$INSTALL_DIR/$BINARY_NAME" init
fi

# Check if install dir is in PATH
case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *) echo "path-warning:$INSTALL_DIR not in PATH" >&2 ;;
esac
