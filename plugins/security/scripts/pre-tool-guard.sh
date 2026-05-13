#!/bin/bash
set -euo pipefail

# Deterministic PreToolUse guard for security-critical patterns.
# Reads hook JSON on stdin and emits current PreToolUse hook response JSON.

if ! command -v jq >/dev/null 2>&1; then
    echo '{"suppressOutput":true,"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
    exit 0
fi

INPUT="$(cat)"
TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // ""')"

json_response() {
    local decision="$1"
    local reason="${2:-}"
    local message="${3:-}"
    jq -n \
        --arg decision "$decision" \
        --arg reason "$reason" \
        --arg message "$message" \
        '{
            suppressOutput: true,
            hookSpecificOutput: {
                hookEventName: "PreToolUse",
                permissionDecision: $decision
            }
        }
        | if $message == "" then . else .systemMessage = $message end
        | if $reason == "" then . else .hookSpecificOutput.permissionDecisionReason = $reason end'
}

is_low_risk_path() {
    local path="$1"
    case "$path" in
        *test*|*spec*|*fixture*|*example*|*.md|docs/*|*/docs/*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

check_content() {
    local content="$1"
    local path="$2"

    if is_low_risk_path "$path"; then
        json_response "allow"
        return
    fi

    if printf '%s' "$content" | grep -qE 'AKIA[A-Z0-9]{16}'; then
        json_response "deny" "AWS access key literal detected in code change." "[SECURITY] Blocked: AWS access key literal detected."
        return
    fi

    if printf '%s' "$content" | grep -qF 'PRIVATE KEY' && printf '%s' "$content" | grep -qF 'BEGIN'; then
        json_response "deny" "Private key material detected in code change." "[SECURITY] Blocked: private key material detected."
        return
    fi

    if printf '%s' "$content" | grep -qE 'subprocess\.(run|call|Popen)\([^)]*shell\s*=\s*True|os\.system\s*\(|child_process\.exec\s*\('; then
        json_response "allow" "Potential command injection sink introduced; follow up with /security:scan --diff." "[SECURITY] Warning: command execution sink changed."
        return
    fi

    if printf '%s' "$content" | grep -qE 'dangerouslySetInnerHTML|\.innerHTML\s*=|document\.write\s*\('; then
        json_response "allow" "Potential XSS sink introduced; follow up with /security:scan --diff." "[SECURITY] Warning: browser HTML sink changed."
        return
    fi

    json_response "allow"
}

case "$TOOL_NAME" in
    Write)
        file_path="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""')"
        content="$(printf '%s' "$INPUT" | jq -r '.tool_input.content // ""')"
        check_content "$content" "$file_path"
        ;;
    Edit)
        file_path="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""')"
        content="$(printf '%s' "$INPUT" | jq -r '.tool_input.new_string // ""')"
        check_content "$content" "$file_path"
        ;;
    MultiEdit)
        file_path="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""')"
        content="$(printf '%s' "$INPUT" | jq -r '[.tool_input.edits[]?.new_string // ""] | join("\n")')"
        check_content "$content" "$file_path"
        ;;
    Bash)
        command_text="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')"
        if printf '%s' "$command_text" | grep -qE 'rm\s+-rf\s+(/|~|\*)($|[[:space:]])'; then
            json_response "deny" "Destructive rm command targets a broad path." "[SECURITY] Blocked: destructive rm command targets a broad path."
        elif printf '%s' "$command_text" | grep -qE 'curl[^|]*\|\s*(sh|bash)|wget[^|]*\|\s*(sh|bash)'; then
            json_response "ask" "Remote script execution requires explicit user approval." "[SECURITY] Approval required: remote script piped to shell."
        elif printf '%s' "$command_text" | grep -qE '(^|[[:space:]])(env|printenv)($|[[:space:]])|git push --force'; then
            json_response "allow" "Command may expose environment data or rewrite remote history." "[SECURITY] Warning: risky command, check intent."
        else
            json_response "allow"
        fi
        ;;
    *)
        json_response "allow"
        ;;
esac
