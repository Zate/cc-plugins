#!/bin/bash
# Track Skill tool invocation start
# Called by PreToolUse hook for Skill tool
#
# Input: JSON with tool_input containing skill name
# Output: JSON allowing the tool to proceed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOKEN_TRACKER="$SCRIPT_DIR/../scripts/token-tracker.sh"
ACTIVE_SKILLS_DIR="$HOME/.claude/devloop-stats/active-skills"

# Read input
input=$(cat)

# Extract skill info
SKILL_NAME="unknown"
PROJECT=$(basename "$(pwd)")

if command -v jq &> /dev/null; then
    # Extract skill name from tool_input
    SKILL_NAME=$(echo "$input" | jq -r '.tool_input.skill // "unknown"' 2>/dev/null)

    # Handle fully qualified names (plugin:skill-name)
    if [[ "$SKILL_NAME" == *":"* ]]; then
        # Keep the full name for tracking
        :
    fi
fi

# Start tracking
mkdir -p "$ACTIVE_SKILLS_DIR"

if [ -f "$TOKEN_TRACKER" ]; then
    INV_ID=$("$TOKEN_TRACKER" start "skill" "$SKILL_NAME" "$PROJECT" 2>/dev/null) || INV_ID=""

    if [ -n "$INV_ID" ]; then
        # Store invocation ID for PostToolUse hook
        echo "$INV_ID" > "$ACTIVE_SKILLS_DIR/latest"
    fi
fi

# Output approval
cat <<EOF
{
  "continue": true
}
EOF
