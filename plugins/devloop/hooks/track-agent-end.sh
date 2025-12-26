#!/bin/bash
# Track agent (Task tool) invocation end
# Called by PostToolUse hook for Task tool
#
# Input: JSON with tool_output containing agent result
# Reads invocation_id from active tracking and records token usage

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOKEN_TRACKER="$SCRIPT_DIR/../scripts/token-tracker.sh"
ACTIVE_AGENTS_DIR="$HOME/.claude/devloop-stats/active-agents"

# Read input
input=$(cat)

# Try to get the latest invocation ID
INV_ID=""
if [ -f "$ACTIVE_AGENTS_DIR/latest" ]; then
    INV_ID=$(cat "$ACTIVE_AGENTS_DIR/latest")
    rm -f "$ACTIVE_AGENTS_DIR/latest"
fi

# Extract token info from output if available
TOKENS_USED=0
if command -v jq &> /dev/null; then
    # Try to extract token usage from tool_output
    # Claude Code may include usage stats in the output
    local output
    output=$(echo "$input" | jq -r '.tool_output // ""' 2>/dev/null)

    # Look for token patterns in output
    # Format varies, try common patterns
    if echo "$output" | grep -qo 'tokens\?[: ]*[0-9]\+' 2>/dev/null; then
        TOKENS_USED=$(echo "$output" | grep -o 'tokens\?[: ]*[0-9]\+' | grep -o '[0-9]\+' | head -1 || echo "0")
    fi

    # Alternative: Look for usage block
    if [ "$TOKENS_USED" = "0" ]; then
        TOKENS_USED=$(echo "$input" | jq -r '.usage.total_tokens // 0' 2>/dev/null)
    fi
fi

# End tracking
if [ -n "$INV_ID" ] && [ -f "$TOKEN_TRACKER" ]; then
    "$TOKEN_TRACKER" end "$INV_ID" "$TOKENS_USED" >/dev/null 2>&1 || true
fi

# Clean up old active files (older than 1 hour)
if [ -d "$ACTIVE_AGENTS_DIR" ]; then
    find "$ACTIVE_AGENTS_DIR" -type f -mmin +60 -delete 2>/dev/null || true
fi

# Output (don't modify the result)
cat <<EOF
{
  "continue": true
}
EOF
