#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# SessionStart hook: Auto-run a queued command after /clear
#
# Called by Claude Code after every /clear and on session start.
# Checks for a pending command left by claude-clear-and-run.sh and returns
# it as an initialUserMessage so Claude executes it immediately.
#
# The trigger file is consumed (deleted) on first read — one-shot by design.
# ─────────────────────────────────────────────────────────────────────────────

TRIGGER_DIR="${CLAUDE_AUTORUN_DIR:-$HOME/.cache/claude-autorun}"
TRIGGER_FILE="$TRIGGER_DIR/pending-command"

# No trigger file → nothing to do (normal /clear or session start)
if [[ ! -f "$TRIGGER_FILE" ]]; then
  exit 0
fi

# Read and atomically remove the trigger (one-shot, prevents double-fire)
COMMAND="$(cat "$TRIGGER_FILE")"
rm -f "$TRIGGER_FILE"

# Empty command → nothing to do
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Escape the command for safe JSON embedding
ESCAPED="${COMMAND//\\/\\\\}"
ESCAPED="${ESCAPED//\"/\\\"}"
ESCAPED="${ESCAPED//$'\n'/\\n}"

# Return the hookSpecificOutput JSON that Claude Code expects.
# hookEventName MUST match "SessionStart" or Claude Code throws.
# initialUserMessage becomes the first prompt in the new session.
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "initialUserMessage": "${ESCAPED}"
  }
}
EOF
