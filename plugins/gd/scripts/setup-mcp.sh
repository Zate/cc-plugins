#!/bin/bash

# Godot MCP Server Setup Script
# Detects Godot and MCP server, validates or creates .mcp.json configuration

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT}"
MCP_TEMPLATE="$PLUGIN_DIR/.mcp.json.template"
MCP_CONFIG="$PROJECT_DIR/.mcp.json"

echo "🎮 Godot Development Environment Setup"
echo "======================================"
echo ""

# Function to validate existing .mcp.json
validate_existing_config() {
    echo "📋 Validating existing .mcp.json..."
    echo ""

    # Extract paths from existing config
    EXISTING_MCP_PATH=$(grep -o '"args"[[:space:]]*:[[:space:]]*\[[[:space:]]*"[^"]*"' "$MCP_CONFIG" | sed 's/.*"\([^"]*\)".*/\1/' | head -1)
    EXISTING_GODOT_PATH=$(grep -o '"GODOT_PATH"[[:space:]]*:[[:space:]]*"[^"]*"' "$MCP_CONFIG" | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/' | head -1)

    # Expand ~ to home directory
    EXISTING_MCP_PATH="${EXISTING_MCP_PATH/#\~/$HOME}"
    EXISTING_GODOT_PATH="${EXISTING_GODOT_PATH/#\~/$HOME}"

    issues_found=false

    # Validate MCP server path
    if [ -z "$EXISTING_MCP_PATH" ]; then
        echo "   ⚠️  Could not find MCP server path in config"
        issues_found=true
    elif [ ! -f "$EXISTING_MCP_PATH" ]; then
        echo "   ⚠️  MCP server not found at: $EXISTING_MCP_PATH"
        issues_found=true
    else
        echo "   ✓ MCP server: $EXISTING_MCP_PATH"
    fi

    # Validate Godot path
    if [ -z "$EXISTING_GODOT_PATH" ]; then
        echo "   ⚠️  Could not find Godot path in config"
        issues_found=true
    elif [ ! -f "$EXISTING_GODOT_PATH" ] && [ ! -x "$EXISTING_GODOT_PATH" ]; then
        echo "   ⚠️  Godot not found at: $EXISTING_GODOT_PATH"
        issues_found=true
    else
        echo "   ✓ Godot: $EXISTING_GODOT_PATH"
    fi

    echo ""

    if [ "$issues_found" = false ]; then
        echo "✅ Configuration is valid!"
        echo ""
        echo "Your environment is ready. You can:"
        echo "  • Run /init-game to start planning your game"
        echo "  • Run /run to test your game"
        echo ""
        return 0
    else
        echo "Configuration has issues. Recreating with auto-detected paths..."
        echo ""
        return 1
    fi
}

# Check if .mcp.json already exists
if [ -f "$MCP_CONFIG" ]; then
    if validate_existing_config; then
        exit 0
    fi
    # If validation failed, continue to recreate config
fi

# Check if template exists
if [ ! -f "$MCP_TEMPLATE" ]; then
    echo "❌ Error: .mcp.json.template not found"
    echo "Expected at: $MCP_TEMPLATE"
    exit 1
fi

# Detect Godot installation
echo "🔍 Detecting Godot installation..."
GODOT_PATH=""

# Try common locations
if [ -f "/Applications/Godot.app/Contents/MacOS/Godot" ]; then
    GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
    echo "   Found Godot (macOS): $GODOT_PATH"
elif command -v godot &> /dev/null; then
    GODOT_PATH=$(which godot)
    echo "   Found Godot in PATH: $GODOT_PATH"
elif [ -f "/usr/bin/godot" ]; then
    GODOT_PATH="/usr/bin/godot"
    echo "   Found Godot (Linux): $GODOT_PATH"
elif [ -f "/usr/local/bin/godot" ]; then
    GODOT_PATH="/usr/local/bin/godot"
    echo "   Found Godot: $GODOT_PATH"
elif [ -n "$GODOT_PATH" ]; then
    echo "   Using GODOT_PATH environment variable: $GODOT_PATH"
else
    echo "   ❌ Could not auto-detect Godot"
    echo ""
    echo "Please install Godot or set the GODOT_PATH environment variable."
    echo "Download from: https://godotengine.org"
    exit 1
fi

# Verify Godot exists
if [ ! -f "$GODOT_PATH" ] && [ ! -x "$GODOT_PATH" ]; then
    echo "❌ Godot not found at: $GODOT_PATH"
    exit 1
fi

echo "✓ Godot verified"
echo ""

# Check Godot MCP server
echo "🔍 Checking Godot MCP server..."
MCP_SERVER_PATH="$HOME/projects/godot-mcp/build/index.js"

if [ ! -f "$MCP_SERVER_PATH" ]; then
    echo "   ❌ MCP server not found at: $MCP_SERVER_PATH"
    echo ""
    echo "   The Godot MCP server needs to be installed and built."
    echo "   Expected location: ~/projects/godot-mcp"
    echo ""
    echo "   To install:"
    echo "   1. Clone the repository:"
    echo "      git clone <godot-mcp-repo-url> ~/projects/godot-mcp"
    echo "   2. Build the server:"
    echo "      cd ~/projects/godot-mcp"
    echo "      npm install"
    echo "      npm run build"
    echo ""
    exit 1
fi

echo "✓ MCP server verified"
echo ""

# Create .mcp.json from template
echo "📝 Creating .mcp.json configuration..."

# Read template and replace placeholders
sed "s|GODOT_MCP_PATH_PLACEHOLDER|$MCP_SERVER_PATH|g; s|GODOT_PATH_PLACEHOLDER|$GODOT_PATH|g" "$MCP_TEMPLATE" > "$MCP_CONFIG"

echo "✓ Configuration created"
echo ""

# Display the configuration
echo "📋 Configuration:"
echo "   Godot: $GODOT_PATH"
echo "   MCP Server: $MCP_SERVER_PATH"
echo ""

echo "✅ Setup complete!"
echo ""
echo "⚠️  IMPORTANT: Restart Claude Code for MCP server changes to take effect"
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code"
echo "  2. Run /init-game to start planning your game"
echo "  3. Use /run to test your game"
echo ""

exit 0
