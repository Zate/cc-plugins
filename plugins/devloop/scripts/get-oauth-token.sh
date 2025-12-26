#!/bin/bash
# Cross-platform OAuth token retrieval for Claude Code
# Supports macOS (Keychain) and Linux (credentials file)
#
# Usage: ./get-oauth-token.sh
# Returns: OAuth access token on stdout, or exits with error code
#
# Exit codes:
#   0 - Success, token on stdout
#   1 - No credentials found
#   2 - Credentials expired
#   3 - Parse error

set -euo pipefail

# Detect platform
get_platform() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

# Get token from macOS Keychain
get_token_macos() {
    local keychain_data
    keychain_data=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null) || return 1

    if command -v jq &> /dev/null; then
        echo "$keychain_data" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null
    else
        # Fallback: grep/sed parsing
        echo "$keychain_data" | grep -o '"accessToken"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/'
    fi
}

# Get token from Linux credentials file
get_token_linux() {
    local cred_file="$HOME/.claude/.credentials.json"

    if [ ! -f "$cred_file" ]; then
        return 1
    fi

    if command -v jq &> /dev/null; then
        jq -r '.claudeAiOauth.accessToken // empty' "$cred_file" 2>/dev/null
    else
        # Fallback: grep/sed parsing
        grep -o '"accessToken"[[:space:]]*:[[:space:]]*"[^"]*"' "$cred_file" | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/'
    fi
}

# Check if token is expired (optional, returns info)
check_expiry() {
    local platform=$1
    local expires_at=""

    case "$platform" in
        macos)
            local keychain_data
            keychain_data=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null) || return
            if command -v jq &> /dev/null; then
                expires_at=$(echo "$keychain_data" | jq -r '.claudeAiOauth.expiresAt // empty' 2>/dev/null)
            fi
            ;;
        linux)
            local cred_file="$HOME/.claude/.credentials.json"
            if [ -f "$cred_file" ] && command -v jq &> /dev/null; then
                expires_at=$(jq -r '.claudeAiOauth.expiresAt // empty' "$cred_file" 2>/dev/null)
            fi
            ;;
    esac

    if [ -n "$expires_at" ] && [ "$expires_at" != "null" ]; then
        local now_ms=$(($(date +%s) * 1000))
        if [ "$expires_at" -lt "$now_ms" ]; then
            echo "expired"
            return 2
        fi
    fi

    echo "valid"
    return 0
}

# Main execution
main() {
    local platform
    platform=$(get_platform)

    local token=""

    case "$platform" in
        macos)
            token=$(get_token_macos) || {
                echo "Error: Could not retrieve token from macOS Keychain" >&2
                exit 1
            }
            ;;
        linux)
            token=$(get_token_linux) || {
                echo "Error: Could not find credentials at ~/.claude/.credentials.json" >&2
                exit 1
            }
            ;;
        *)
            echo "Error: Unsupported platform: $(uname -s)" >&2
            exit 1
            ;;
    esac

    if [ -z "$token" ]; then
        echo "Error: Token is empty" >&2
        exit 1
    fi

    # Optional: Check expiry (warning only)
    local expiry_status
    expiry_status=$(check_expiry "$platform" 2>/dev/null) || true
    if [ "$expiry_status" = "expired" ]; then
        echo "Warning: Token may be expired" >&2
    fi

    echo "$token"
}

# Run if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
