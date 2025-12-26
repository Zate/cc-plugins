#!/bin/bash
# Track agent (Task tool) invocation start
# Called by PreToolUse hook for Task tool
#
# Input: JSON with tool_input containing agent details
# Output: JSON with invocation_id stored for PostToolUse

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOKEN_TRACKER="$SCRIPT_DIR/../scripts/token-tracker.sh"
ACTIVE_AGENTS_DIR="$HOME/.claude/devloop-stats/active-agents"

# Read input
input=$(cat)

# Extract agent info
AGENT_TYPE="unknown"
AGENT_DESC=""
PROJECT=$(basename "$(pwd)")

if command -v jq &> /dev/null; then
    # Extract from tool_input
    AGENT_TYPE=$(echo "$input" | jq -r '.tool_input.subagent_type // "unknown"' 2>/dev/null)
    AGENT_DESC=$(echo "$input" | jq -r '.tool_input.description // ""' 2>/dev/null)

    # If subagent_type not found, try to detect from prompt
    if [ "$AGENT_TYPE" = "unknown" ] || [ "$AGENT_TYPE" = "null" ]; then
        local prompt
        prompt=$(echo "$input" | jq -r '.tool_input.prompt // ""' 2>/dev/null)
        # Try to infer type from common patterns
        if echo "$prompt" | grep -qi "explore\|search\|find"; then
            AGENT_TYPE="Explore"
        elif echo "$prompt" | grep -qi "review\|check"; then
            AGENT_TYPE="code-reviewer"
        fi
    fi
fi

# Start tracking
mkdir -p "$ACTIVE_AGENTS_DIR"

if [ -f "$TOKEN_TRACKER" ]; then
    INV_ID=$("$TOKEN_TRACKER" start "agent" "$AGENT_TYPE" "$PROJECT" 2>/dev/null) || INV_ID=""

    if [ -n "$INV_ID" ]; then
        # Store invocation ID keyed by a session-unique identifier
        # Use PID and timestamp as key since we don't have tool_use_id
        local key="${$}_$(date +%s%N)"
        echo "$INV_ID" > "$ACTIVE_AGENTS_DIR/$key"

        # Also store in a latest file for simpler lookup
        echo "$INV_ID" > "$ACTIVE_AGENTS_DIR/latest"
    fi
fi

# Output approval (don't block the tool)
cat <<EOF
{
  "continue": true
}
EOF
