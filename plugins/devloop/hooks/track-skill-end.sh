#!/bin/bash
# Track Skill tool invocation end
# Called by PostToolUse hook for Skill tool
#
# Input: JSON with tool_output
# Reads invocation_id from active tracking and records completion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOKEN_TRACKER="$SCRIPT_DIR/../scripts/token-tracker.sh"
ACTIVE_SKILLS_DIR="$HOME/.claude/devloop-stats/active-skills"

# Read input
input=$(cat)

# Try to get the latest invocation ID
INV_ID=""
if [ -f "$ACTIVE_SKILLS_DIR/latest" ]; then
    INV_ID=$(cat "$ACTIVE_SKILLS_DIR/latest")
    rm -f "$ACTIVE_SKILLS_DIR/latest"
fi

# Skills don't typically report token usage directly
# We track the API usage delta instead
TOKENS_USED=0

# End tracking
if [ -n "$INV_ID" ] && [ -f "$TOKEN_TRACKER" ]; then
    "$TOKEN_TRACKER" end "$INV_ID" "$TOKENS_USED" >/dev/null 2>&1 || true
fi

# Clean up old active files
if [ -d "$ACTIVE_SKILLS_DIR" ]; then
    find "$ACTIVE_SKILLS_DIR" -type f -mmin +60 -delete 2>/dev/null || true
fi

# Output
cat <<EOF
{
  "continue": true
}
EOF
