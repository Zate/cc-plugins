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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# Log file for tracking
SECURITY_LOG="${PLUGIN_ROOT}/.security-scan.log"

# Get timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Log function with file locking to prevent race conditions
log_finding() {
    local severity="$1"
    local message="$2"
    local file="${3:-unknown}"

    # Sanitize inputs to prevent log injection
    severity="${severity//[^A-Z]/_}"
    message="${message//[$'\n\r']/}"
    file="${file//[$'\n\r']/}"

    # Use flock for atomic append (create lock file if needed)
    (
        flock -w 5 200 || { echo "Warning: Could not acquire log lock" >&2; return 1; }
        echo "[$TIMESTAMP] [$severity] $message (file: $file)" >> "$SECURITY_LOG"
    ) 200>"${SECURITY_LOG}.lock"
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
    # Check for obvious secrets using fixed-string matching where possible
    # AWS Access Key ID pattern (fixed prefix, then alphanumeric)
    if printf '%s' "$CONTENT" | grep -qE 'AKIA[A-Z0-9]{16}'; then
        log_finding "CRITICAL" "AWS key detected in written content" "${TOOL_INPUT_FILE:-unknown}"
        echo '{"status": "warning", "message": "Security: AWS key detected"}'
        exit 0
    fi

    # Private key detection using fixed string (more reliable than regex)
    if printf '%s' "$CONTENT" | grep -qF 'BEGIN' && printf '%s' "$CONTENT" | grep -qF 'PRIVATE KEY'; then
        log_finding "CRITICAL" "Private key detected in written content" "${TOOL_INPUT_FILE:-unknown}"
        echo '{"status": "warning", "message": "Security: Private key detected"}'
        exit 0
    fi

    # Check for SQL injection patterns (Python f-strings)
    # Pattern: f"SELECT or f'SELECT with variable interpolation
    if printf '%s' "$CONTENT" | grep -qE 'f"SELECT|f'\''SELECT|f"INSERT|f'\''INSERT'; then
        log_finding "HIGH" "SQL injection pattern detected" "${TOOL_INPUT_FILE:-unknown}"
    fi

    # Check for command injection (fixed string matching)
    if printf '%s' "$CONTENT" | grep -qF 'shell=True'; then
        log_finding "MEDIUM" "shell=True usage detected" "${TOOL_INPUT_FILE:-unknown}"
    fi
fi

# Success - no blocking issues
echo '{"status": "ok"}'
exit 0
