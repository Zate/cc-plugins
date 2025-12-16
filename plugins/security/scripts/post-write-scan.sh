#!/bin/bash
#
# Post-Write Security Scan
# Lightweight security check after file writes
# Used by PostToolUse hooks to track security status
#
# This script runs quickly and logs findings for later review
# It does NOT block operations (PreToolUse handles blocking)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# Log file for tracking
SECURITY_LOG="${PLUGIN_ROOT}/.security-scan.log"

# Get timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Log function
log_finding() {
    local severity="$1"
    local message="$2"
    local file="${3:-unknown}"

    echo "[$TIMESTAMP] [$severity] $message (file: $file)" >> "$SECURITY_LOG"
}

# Quick pattern checks on stdin or files from environment
# Tool input comes via stdin from hook context

# Read any input (file content from hook)
CONTENT=""
if [[ -p /dev/stdin ]]; then
    CONTENT=$(cat)
fi

# Quick checks on content
if [[ -n "$CONTENT" ]]; then
    # Check for obvious secrets
    if echo "$CONTENT" | grep -qE 'AKIA[A-Z0-9]{16}'; then
        log_finding "CRITICAL" "AWS key detected in written content" "${TOOL_INPUT_FILE:-unknown}"
        echo '{"status": "warning", "message": "Security: AWS key detected"}'
        exit 0
    fi

    if echo "$CONTENT" | grep -qE "BEGIN.*PRIVATE KEY"; then
        log_finding "CRITICAL" "Private key detected in written content" "${TOOL_INPUT_FILE:-unknown}"
        echo '{"status": "warning", "message": "Security: Private key detected"}'
        exit 0
    fi

    # Check for SQL injection patterns
    if echo "$CONTENT" | grep -qE 'f["'"'"']SELECT|f["'"'"']INSERT.*\{'; then
        log_finding "HIGH" "SQL injection pattern detected" "${TOOL_INPUT_FILE:-unknown}"
    fi

    # Check for command injection
    if echo "$CONTENT" | grep -q 'shell\s*=\s*True'; then
        log_finding "MEDIUM" "shell=True usage detected" "${TOOL_INPUT_FILE:-unknown}"
    fi
fi

# Success - no blocking issues
echo '{"status": "ok"}'
exit 0
