#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# claude-clear-and-run — Clear Claude Code context and run a skill/command
#
# Designed to be called from hooks, cron, or manually.
#
# Usage:
#   claude-clear-and-run "/my-skill"             # Clear then run /my-skill
#   claude-clear-and-run "/my-skill arg1 arg2"   # Clear then run with args
#   claude-clear-and-run --no-clear "/my-skill"  # Just send the skill
#
# How it works:
#   1. Writes the post-clear command to a trigger file
#   2. Sends /clear to Claude Code (via claude-send.sh)
#   3. The SessionStart hook picks up the trigger and injects the command
#
# The two-phase approach avoids fragile sleep-based timing. The SessionStart
# hook fires deterministically after /clear completes.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TRIGGER_DIR="${CLAUDE_AUTORUN_DIR:-$HOME/.cache/claude-autorun}"
TRIGGER_FILE="$TRIGGER_DIR/pending-command"

RED='\033[0;31m'
GREEN='\033[0;32m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

DO_CLEAR=true
COMMAND=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-clear) DO_CLEAR=false; shift ;;
    --help|-h)
      sed -n '2,/^# ──/{ /^# ──/d; s/^# \?//p }' "$0"
      exit 0 ;;
    *) COMMAND="$1"; shift ;;
  esac
done

if [[ -z "$COMMAND" ]]; then
  echo -e "${RED}Usage: claude-clear-and-run [--no-clear] \"/skill-or-prompt\"${NC}" >&2
  exit 1
fi

# ── Phase 1: Write the trigger file ─────────────────────────────────────────
mkdir -p "$TRIGGER_DIR"
echo "$COMMAND" > "$TRIGGER_FILE"
echo -e "${DIM}Trigger written: $TRIGGER_FILE${NC}"
echo -e "${DIM}Command: $COMMAND${NC}"

# ── Phase 2: Send /clear ────────────────────────────────────────────────────
if [[ "$DO_CLEAR" == true ]]; then
  echo -e "${BOLD}Sending /clear to Claude Code...${NC}"
  "$SCRIPT_DIR/claude-send.sh" "/clear"
else
  echo -e "${BOLD}Sending command directly (no clear)...${NC}"
  "$SCRIPT_DIR/claude-send.sh" "$COMMAND"
fi

echo -e "${GREEN}Queued. The SessionStart hook will execute: $COMMAND${NC}"
