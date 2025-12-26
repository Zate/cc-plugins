#!/bin/bash
# Devloop SessionEnd hook
# Records session end state and provides context usage summary
#
# Input (stdin): JSON with session info from Claude Code
# Output: JSON with systemMessage for user

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSION_TRACKER="$SCRIPT_DIR/../scripts/session-tracker.sh"

# Read JSON input from stdin
input=$(cat)

# Extract session ID and reason
SESSION_ID=""
END_REASON=""

if command -v jq &> /dev/null; then
    SESSION_ID=$(echo "$input" | jq -r '.session_id // ""' 2>/dev/null)
    END_REASON=$(echo "$input" | jq -r '.reason // "exit"' 2>/dev/null)
fi

# Run session tracker end command (pass stdin data)
SESSION_OUTPUT=""
if [ -f "$SESSION_TRACKER" ]; then
    SESSION_OUTPUT=$(echo "$input" | "$SESSION_TRACKER" end "$SESSION_ID" 2>&1) || true
fi

# Build response message
MESSAGE=""
if [ -n "$SESSION_OUTPUT" ]; then
    # Extract key stats if available
    if echo "$SESSION_OUTPUT" | grep -q "Context:"; then
        CONTEXT_LINE=$(echo "$SESSION_OUTPUT" | grep "Context:" | head -1)
        TOKENS_LINE=$(echo "$SESSION_OUTPUT" | grep "Tokens:" | head -1 || echo "")

        MESSAGE="Session saved. $CONTEXT_LINE"

        # Check for clear recommendation
        if echo "$SESSION_OUTPUT" | grep -q "consider /clear"; then
            MESSAGE="$MESSAGE | ⚠️ Consider /clear"
        elif echo "$SESSION_OUTPUT" | grep -q "/clear recommended"; then
            MESSAGE="$MESSAGE | 💡 /clear recommended"
        fi
    else
        MESSAGE="Session ended"
    fi
else
    MESSAGE="Session ended (reason: $END_REASON)"
fi

# Output JSON response
if command -v jq &> /dev/null; then
    ESCAPED_MSG=$(printf '%s' "$MESSAGE" | jq -Rs '.')
    cat <<EOF
{
  "systemMessage": $ESCAPED_MSG
}
EOF
else
    # Escape for JSON without jq
    ESCAPED_MSG=$(printf '%s' "$MESSAGE" | sed 's/"/\\"/g')
    cat <<EOF
{
  "systemMessage": "$ESCAPED_MSG"
}
EOF
fi

exit 0
