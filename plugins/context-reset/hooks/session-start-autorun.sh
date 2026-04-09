#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# SessionStart hook: Auto-run a queued command after programmatic /clear
#
# Only fires on "clear" events (via matcher in settings.json).
# Only acts when a lockfile exists (written by claude-clear-and-run.sh),
# which distinguishes programmatic clears from manual /clear typed by user.
#
# The lockfile + trigger are consumed (deleted) on first read — one-shot.
# ─────────────────────────────────────────────────────────────────────────────

TRIGGER_DIR="${CLAUDE_AUTORUN_DIR:-$HOME/.cache/claude-autorun}"
TRIGGER_FILE="$TRIGGER_DIR/pending-command"
LOCK_FILE="$TRIGGER_DIR/autorun.lock"

# No lockfile → this was a manual /clear, not a programmatic one. Do nothing.
if [[ ! -f "$LOCK_FILE" ]]; then
  exit 0
fi

# Lockfile exists → programmatic clear. Remove it immediately (one-shot).
rm -f "$LOCK_FILE"

# No trigger file → lockfile was stale or command wasn't written. Clean exit.
if [[ ! -f "$TRIGGER_FILE" ]]; then
  exit 0
fi

# Read and atomically remove the trigger (prevents double-fire)
COMMAND="$(cat "$TRIGGER_FILE")"
rm -f "$TRIGGER_FILE"

# Empty command → nothing to inject
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Escape the command for safe JSON embedding
ESCAPED="${COMMAND//\\/\\\\}"
ESCAPED="${ESCAPED//\"/\\\"}"
ESCAPED="${ESCAPED//$'\n'/\\n}"

# Return the hookSpecificOutput JSON that Claude Code expects.
# suppressOutput hides the raw JSON from verbose mode.
# initialUserMessage becomes the first prompt in the new session.
cat <<EOF
{
  "suppressOutput": true,
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "initialUserMessage": "${ESCAPED}"
  }
}
EOF
