#!/bin/bash
# Log Task tool invocations for debugging agent behavior

LOG_FILE="${HOME}/.devloop-agent-invocations.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Log that hook fired
echo "[$TIMESTAMP] Hook fired" >> "$LOG_FILE"

# Read and log stdin
INPUT=$(cat)
if [[ -n "$INPUT" ]]; then
    echo "[$TIMESTAMP] Input received (${#INPUT} chars)" >> "$LOG_FILE"
    # Log first 1000 chars
    echo "$INPUT" | head -c 1000 >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
else
    echo "[$TIMESTAMP] No input received" >> "$LOG_FILE"
fi

exit 0
