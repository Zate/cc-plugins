#!/bin/bash
# check-plugin.sh - Check if a plugin is installed
#
# Usage:
#   ./check-plugin.sh <plugin-name>
#
# Output (JSON):
#   {"installed": true/false, "name": "plugin-name", "path": "/path/to/plugin"}
#
# Exit codes:
#   0 - Plugin is installed
#   1 - Plugin is not installed
#   2 - Invalid arguments

set -euo pipefail

PLUGIN_NAME="${1:-}"

if [ -z "$PLUGIN_NAME" ]; then
    echo '{"error": "missing_argument", "message": "Plugin name required"}'
    exit 2
fi

# Claude Code plugin cache location
CLAUDE_PLUGIN_DIR="${HOME}/.claude/plugins"

# Check multiple possible locations for the plugin
check_plugin_installed() {
    local name="$1"

    # Check in cache directory (marketplace plugins)
    if [ -d "$CLAUDE_PLUGIN_DIR/cache" ]; then
        # Check for plugin in any marketplace cache
        for marketplace_dir in "$CLAUDE_PLUGIN_DIR/cache"/*; do
            if [ -d "$marketplace_dir/$name" ]; then
                # Found plugin, return newest version path
                local newest_version
                newest_version=$(ls -v "$marketplace_dir/$name" 2>/dev/null | tail -1)
                if [ -n "$newest_version" ]; then
                    echo "$marketplace_dir/$name/$newest_version"
                    return 0
                fi
            fi
        done
    fi

    # Check in local directory (local installs)
    if [ -d "$CLAUDE_PLUGIN_DIR/local/$name" ]; then
        echo "$CLAUDE_PLUGIN_DIR/local/$name"
        return 0
    fi

    # Check marketplaces directory (source)
    if [ -d "$CLAUDE_PLUGIN_DIR/marketplaces" ]; then
        for marketplace_dir in "$CLAUDE_PLUGIN_DIR/marketplaces"/*; do
            if [ -d "$marketplace_dir/plugins/$name" ]; then
                echo "$marketplace_dir/plugins/$name"
                return 0
            fi
        done
    fi

    return 1
}

# Check if the plugin is installed
if plugin_path=$(check_plugin_installed "$PLUGIN_NAME"); then
    # Escape path for JSON
    escaped_path=$(echo "$plugin_path" | sed 's/\\/\\\\/g; s/"/\\"/g')
    echo "{\"installed\": true, \"name\": \"$PLUGIN_NAME\", \"path\": \"$escaped_path\"}"
    exit 0
else
    echo "{\"installed\": false, \"name\": \"$PLUGIN_NAME\", \"path\": null}"
    exit 1
fi
