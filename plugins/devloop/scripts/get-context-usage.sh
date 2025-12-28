#!/bin/bash
# Get current context usage percentage
# Reuses logic from devloop-statusline.sh for consistency
# Outputs simple percentage number (0-100)

set -euo pipefail

# Read JSON input from stdin
input=$(cat)

# Check if jq is available
if ! command -v jq &> /dev/null; then
    # Without jq, we can't parse the context window data reliably
    # Return 0 to indicate unknown (fail open - won't trigger fresh start)
    echo "0"
    exit 0
fi

# Extract context window usage (same logic as statusline)
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

# Calculate context window percentage
CONTEXT_PCT=0
if [ "${CONTEXT_SIZE:-0}" -gt 0 ] 2>/dev/null; then
    CURRENT_CONTEXT=$((${INPUT_TOKENS:-0} + ${CACHE_CREATE:-0} + ${CACHE_READ:-0}))
    CONTEXT_PCT=$((CURRENT_CONTEXT * 100 / CONTEXT_SIZE))
fi

# Output just the percentage number
echo "$CONTEXT_PCT"
