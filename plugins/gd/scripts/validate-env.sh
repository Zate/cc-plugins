#!/bin/bash

# Godot Development Environment Validation
# This script checks if the Godot and MCP server are properly configured
# Exit code 0 (non-blocking) - shows friendly messages to user

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MCP_CONFIG="$PROJECT_DIR/.mcp.json"

# Check if .mcp.json exists
if [ ! -f "$MCP_CONFIG" ]; then
    echo "⚠️  Godot MCP server not configured yet."
    echo ""
    echo "Run /setup to configure your Godot development environment."
    echo ""
    exit 0
fi

# Parse and validate paths from .mcp.json
# Extract Godot MCP path (the arg value)
MCP_PATH=$(grep -o '"args"[[:space:]]*:[[:space:]]*\[[[:space:]]*"[^"]*"' "$MCP_CONFIG" | sed 's/.*"\([^"]*\)".*/\1/')
# Expand ~ to home directory
MCP_PATH="${MCP_PATH/#\~/$HOME}"

# Extract Godot path (the env variable)
GODOT_PATH=$(grep -o '"GODOT_PATH"[[:space:]]*:[[:space:]]*"[^"]*"' "$MCP_CONFIG" | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/')
# Expand ~ to home directory
GODOT_PATH="${GODOT_PATH/#\~/$HOME}"

issues_found=false

# Validate MCP server path
if [ -z "$MCP_PATH" ]; then
    echo "⚠️  Could not find Godot MCP server path in .mcp.json"
    issues_found=true
elif [ ! -f "$MCP_PATH" ]; then
    echo "⚠️  Godot MCP server not found at: $MCP_PATH"
    echo ""
    echo "The MCP server may need to be built. Run these commands:"
    echo "  cd ~/projects/godot-mcp"
    echo "  npm install"
    echo "  npm run build"
    echo ""
    issues_found=true
fi

# Validate Godot path
if [ -z "$GODOT_PATH" ]; then
    echo "⚠️  Could not find GODOT_PATH in .mcp.json"
    issues_found=true
elif [ ! -f "$GODOT_PATH" ] && [ ! -x "$GODOT_PATH" ]; then
    echo "⚠️  Godot not found at: $GODOT_PATH"
    echo ""
    echo "Please install Godot or update the path in .mcp.json"
    echo ""
    issues_found=true
fi

if [ "$issues_found" = true ]; then
    echo "Run /setup to reconfigure your environment."
    echo ""
fi

# Always exit 0 to be non-blocking
exit 0
