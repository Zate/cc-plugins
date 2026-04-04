#!/bin/bash
set -euo pipefail

# Check for forge binary
if ! command -v forge &>/dev/null; then
    cat <<'EOF'
{"suppressOutput":false,"systemMessage":"forge: not installed. Run /forge:setup to build and install.","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"Forge binary not found on PATH. The user needs to build forge from source and add it to PATH. Direct them to /forge:setup."}}
EOF
    exit 0
fi

# Get version
VERSION=$(forge version 2>/dev/null || echo "unknown")

# Check daemon status via PID file
PIDFILE="$HOME/.forge/forge.pid"
DAEMON_RUNNING=false
DAEMON_PID=""

if [[ -f "$PIDFILE" ]]; then
    DAEMON_PID=$(tr -d '[:space:]' < "$PIDFILE")
    if [[ -n "$DAEMON_PID" ]] && kill -0 "$DAEMON_PID" 2>/dev/null; then
        DAEMON_RUNNING=true
    fi
fi

if [[ "$DAEMON_RUNNING" == "true" ]]; then
    STATUS_MSG="forge: $VERSION - daemon running (pid $DAEMON_PID)"
    CONTEXT="Forge daemon is active. MCP tools available: forge_submit (submit a job), forge_status (check job), forge_output (get result), forge_list (list jobs). Use MCP tools for all forge interactions."
else
    STATUS_MSG="forge: $VERSION - daemon not running. Start with: forge daemon &"
    CONTEXT="Forge is installed but the daemon is not running. Jobs will stay pending until the daemon starts. Start it with \`forge daemon &\` or use /forge:setup."
fi

# Output structured JSON
if command -v jq &>/dev/null; then
    jq -n --arg status "$STATUS_MSG" --arg ctx "$CONTEXT" \
        '{suppressOutput: false, systemMessage: $status, hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
else
    cat <<EOF
{"suppressOutput":false,"systemMessage":"$STATUS_MSG","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"$CONTEXT"}}
EOF
fi
