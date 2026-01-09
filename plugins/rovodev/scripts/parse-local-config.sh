#!/bin/bash
# parse-local-config.sh - Parse .devloop/local.md config
#
# Usage:
#   ./parse-local-config.sh [key]
#
# Example:
#   ./parse-local-config.sh git.auto-branch
#
# Output:
#   Value of the key, or empty if not found

set -euo pipefail

CONFIG_FILE=".devloop/local.md"
KEY="${1:-}"

if [ -z "$KEY" ]; then
    echo "Usage: $0 <key>"
    echo "Example: $0 git.auto-branch"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    exit 0  # No config file, return empty
fi

# Parse YAML-like config from markdown
# Look for pattern: key: value
# Support nested keys with dot notation (git.auto-branch)

# Convert dot notation to grep pattern
# git.auto-branch -> look for "auto-branch:" under "git:" section
if [[ "$KEY" == *.* ]]; then
    SECTION="${KEY%%.*}"
    SUBKEY="${KEY#*.}"
    
    # Extract section and find key within it
    awk -v section="$SECTION:" -v key="$SUBKEY:" '
        $0 ~ section { in_section = 1; next }
        in_section && /^[a-z]/ && $0 !~ /^[[:space:]]/ { in_section = 0 }
        in_section && $0 ~ key { 
            sub(/^[[:space:]]*[^:]+:[[:space:]]*/, "")
            print
            exit
        }
    ' "$CONFIG_FILE"
else
    # Simple key
    grep "^$KEY:" "$CONFIG_FILE" | sed 's/^[^:]*:[[:space:]]*//' || true
fi
