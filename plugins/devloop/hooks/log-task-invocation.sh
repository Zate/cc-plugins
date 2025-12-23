#!/bin/bash
# Log Task tool invocations for debugging agent behavior
#
# This hook captures Task tool invocations (when agents are spawned) and logs:
# - Agent type/subagent being invoked
# - Task description
# - First 200 chars of the prompt
#
# Logs to: ~/.devloop-agent-invocations.log

set -euo pipefail

LOG_FILE="${HOME}/.devloop-agent-invocations.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Read JSON input from stdin
INPUT=$(cat)

# Check if jq is available for JSON parsing
if command -v jq &> /dev/null; then
    # Parse JSON with jq
    AGENT_TYPE=$(echo "$INPUT" | jq -r '.subagent_type // .task // "unknown"' 2>/dev/null || echo "unknown")
    DESCRIPTION=$(echo "$INPUT" | jq -r '.description // .task // ""' 2>/dev/null || echo "")
    PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null | head -c 200 || echo "")

    # Format log entry
    {
        echo "[$TIMESTAMP] Task Invocation: $AGENT_TYPE"
        if [[ -n "$DESCRIPTION" && "$DESCRIPTION" != "$AGENT_TYPE" ]]; then
            echo "  Description: $DESCRIPTION"
        fi
        if [[ -n "$PROMPT" ]]; then
            echo "  Prompt: ${PROMPT}..."
        fi
        echo ""
    } >> "$LOG_FILE"
else
    # Fallback: Use grep/sed for basic JSON extraction
    # Extract subagent_type or task field
    AGENT_TYPE=$(echo "$INPUT" | grep -oE '"(subagent_type|task)"\s*:\s*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"/\1/' || echo "unknown")

    # Extract description field
    DESCRIPTION=$(echo "$INPUT" | grep -oE '"description"\s*:\s*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"/\1/' || echo "")

    # Extract prompt field (first 200 chars)
    PROMPT=$(echo "$INPUT" | grep -oE '"prompt"\s*:\s*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"/\1/' | head -c 200 || echo "")

    # Format log entry
    {
        echo "[$TIMESTAMP] Task Invocation: $AGENT_TYPE"
        if [[ -n "$DESCRIPTION" && "$DESCRIPTION" != "$AGENT_TYPE" ]]; then
            echo "  Description: $DESCRIPTION"
        fi
        if [[ -n "$PROMPT" ]]; then
            echo "  Prompt: ${PROMPT}..."
        fi
        echo ""
    } >> "$LOG_FILE"
fi

# Always succeed - hooks should never block operations
exit 0
