#!/bin/bash
# post-tool-bash.sh - Filter noisy bash tool outputs to save tokens
set -euo pipefail

# Read stdin JSON to get the tool output
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // ""')
TOOL_OUTPUT=$(echo "$INPUT" | jq -r '.tool_output // ""')

if [ "$TOOL_NAME" != "Bash" ]; then
    echo '{"suppressOutput": true}'
    exit 0
fi

# 1. Filter npm install (keep only summary)
if [[ "$TOOL_INPUT" == *"npm install"* ]]; then
    SUMMARY=$(echo "$TOOL_OUTPUT" | grep -E "added [0-9]+ packages|audited [0-9]+ packages|found [0-9]+ vulnerabilities" | tr '\n' ' ')
    if [ -n "$SUMMARY" ]; then
        UPDATED="[npm install output suppressed] Summary: $SUMMARY"
        jq -n --arg updated "$UPDATED" '{suppressOutput: true, systemMessage: "devloop: filtered npm output", hookSpecificOutput: {hookEventName: "PostToolUse", updatedMCPToolOutput: $updated}}'
        exit 0
    fi
fi

# 2. Filter long git status (if too long)
if [[ "$TOOL_INPUT" == *"git status"* ]]; then
    LINE_COUNT=$(echo "$TOOL_OUTPUT" | wc -l)
    if [ "$LINE_COUNT" -gt 50 ]; then
        UPDATED=$(echo "$TOOL_OUTPUT" | head -n 20 && echo "... [$(($LINE_COUNT - 20)) lines omitted] ...")
        jq -n --arg updated "$UPDATED" '{suppressOutput: true, systemMessage: "devloop: truncated git status", hookSpecificOutput: {hookEventName: "PostToolUse", updatedMCPToolOutput: $updated}}'
        exit 0
    fi
fi

# 3. Filter large directory listings
if [[ "$TOOL_INPUT" == *"ls "* || "$TOOL_INPUT" == "ls" ]]; then
    CHAR_COUNT=${#TOOL_OUTPUT}
    if [ "$CHAR_COUNT" -gt 5000 ]; then
        UPDATED="[Large directory listing truncated] Output size: $CHAR_COUNT bytes. Use grep or find for specific files."
        jq -n --arg updated "$UPDATED" '{suppressOutput: true, systemMessage: "devloop: truncated ls output", hookSpecificOutput: {hookEventName: "PostToolUse", updatedMCPToolOutput: $updated}}'
        exit 0
    fi
fi

echo '{"suppressOutput": true}'
