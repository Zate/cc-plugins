#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# claude-send — Reliably inject input into a running Claude Code session
#
# Usage:
#   claude-send "/clear"                    # Send /clear to Claude
#   claude-send "/clear" "/my-skill"        # Send /clear, wait, then /my-skill
#   claude-send --pid 12345 "/clear"        # Target a specific PID
#   claude-send --method tmux "/clear"      # Force a specific method
#   claude-send --dry-run "/clear"          # Show what would happen
#
# Methods (auto-detected in order of preference):
#   tmux      — send-keys to the pane running claude (most reliable)
#   tiocsti   — ioctl injection via /dev/pts (requires sysctl enabled)
#   xdotool   — X11 keystroke simulation (requires focused window)
#
# Environment:
#   CLAUDE_SEND_METHOD   — override auto-detection (tmux|tiocsti|xdotool)
#   CLAUDE_SEND_DELAY    — seconds between commands (default: 2)
#   CLAUDE_SEND_PID      — target PID (auto-detected if omitted)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

DELAY="${CLAUDE_SEND_DELAY:-2}"
TARGET_PID="${CLAUDE_SEND_PID:-}"
FORCE_METHOD="${CLAUDE_SEND_METHOD:-}"
DRY_RUN=false
COMMANDS=()

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pid)     TARGET_PID="$2"; shift 2 ;;
    --method)  FORCE_METHOD="$2"; shift 2 ;;
    --delay)   DELAY="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --help|-h)
      sed -n '2,/^# ──/{ /^# ──/d; s/^# \?//p }' "$0"
      exit 0 ;;
    *)         COMMANDS+=("$1"); shift ;;
  esac
done

if [[ ${#COMMANDS[@]} -eq 0 ]]; then
  echo -e "${RED}Usage: claude-send [OPTIONS] COMMAND [COMMAND...]${NC}" >&2
  echo "  Try: claude-send --help" >&2
  exit 1
fi

# ── Find Claude Code PID ────────────────────────────────────────────────────
find_claude_pid() {
  local pids
  pids=$(ps -eo pid,tty,comm,args --no-headers 2>/dev/null \
    | grep -E '(claude|bun)' \
    | grep -v -E '(grep|claude-send|defunct)' \
    | grep -v '?' \
    | head -5)

  if [[ -z "$pids" ]]; then
    return 1
  fi

  local pid
  pid=$(echo "$pids" \
    | awk '$2 != "?" { print $1 }' \
    | head -1)

  if [[ -z "$pid" ]]; then
    return 1
  fi

  echo "$pid"
}

if [[ -z "$TARGET_PID" ]]; then
  TARGET_PID=$(find_claude_pid) || {
    echo -e "${RED}Could not find a running Claude Code process.${NC}" >&2
    echo "  Specify with: claude-send --pid PID ..." >&2
    exit 1
  }
fi

if ! kill -0 "$TARGET_PID" 2>/dev/null; then
  echo -e "${RED}PID $TARGET_PID is not running.${NC}" >&2
  exit 1
fi

echo -e "${DIM}Target PID: $TARGET_PID ($(ps -p "$TARGET_PID" -o comm= 2>/dev/null || echo unknown))${NC}"

# ── Detect terminal of target process ────────────────────────────────────────
get_target_tty() {
  local tty
  tty=$(ps -p "$TARGET_PID" -o tty= 2>/dev/null | tr -d ' ')
  if [[ -n "$tty" && "$tty" != "?" ]]; then
    if [[ "$tty" != /dev/* ]]; then
      tty="/dev/$tty"
    fi
    echo "$tty"
  fi
}

TARGET_TTY=$(get_target_tty)

# ── Method: tmux ─────────────────────────────────────────────────────────────
tmux_available() {
  command -v tmux &>/dev/null || return 1
  tmux list-sessions &>/dev/null 2>&1 || return 1
  tmux_find_pane &>/dev/null
}

tmux_find_pane() {
  local pane_id pane_pid
  while IFS=' ' read -r pane_id pane_pid; do
    if [[ "$pane_pid" == "$TARGET_PID" ]]; then
      echo "$pane_id"
      return 0
    fi
    if pgrep -P "$pane_pid" 2>/dev/null | grep -qw "$TARGET_PID"; then
      echo "$pane_id"
      return 0
    fi
    local walk="$TARGET_PID"
    while [[ -n "$walk" && "$walk" != "1" ]]; do
      if [[ "$walk" == "$pane_pid" ]]; then
        echo "$pane_id"
        return 0
      fi
      walk=$(ps -o ppid= -p "$walk" 2>/dev/null | tr -d ' ')
    done
  done < <(tmux list-panes -a -F '#{pane_id} #{pane_pid}' 2>/dev/null)
  return 1
}

tmux_send() {
  local pane_id text="$1"
  pane_id=$(tmux_find_pane) || {
    echo -e "${RED}tmux: could not find pane for PID $TARGET_PID${NC}" >&2
    return 1
  }
  echo -e "  ${DIM}tmux send-keys -t $pane_id${NC}"

  if [[ "$DRY_RUN" == true ]]; then
    echo -e "  ${YELLOW}[dry-run]${NC} tmux send-keys -t $pane_id \"$text\" Enter"
    return 0
  fi

  tmux send-keys -t "$pane_id" C-u
  tmux send-keys -t "$pane_id" "$text"
  tmux send-keys -t "$pane_id" Enter
}

# ── Method: tiocsti ──────────────────────────────────────────────────────────
TIOCSTI_HELPER=""

tiocsti_available() {
  [[ -n "$TARGET_TTY" ]] || return 1
  local val
  val=$(cat /proc/sys/dev/tty/legacy_tiocsti 2>/dev/null || echo 0)
  [[ "$val" == "1" ]] || return 1
  tiocsti_ensure_helper
}

tiocsti_ensure_helper() {
  TIOCSTI_HELPER="${TMPDIR:-/tmp}/claude-send-tiocsti"
  if [[ -x "$TIOCSTI_HELPER" ]]; then
    return 0
  fi
  cat > "${TIOCSTI_HELPER}.c" <<'CEOF'
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>
int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s /dev/pts/N \"text\"\n", argv[0]);
        return 1;
    }
    int fd = open(argv[1], O_RDWR);
    if (fd < 0) { perror("open"); return 1; }
    const char *s = argv[2];
    for (size_t i = 0; i < strlen(s); i++) {
        if (ioctl(fd, TIOCSTI, &s[i]) < 0) {
            perror("ioctl TIOCSTI");
            close(fd);
            return 1;
        }
    }
    close(fd);
    return 0;
}
CEOF
  gcc -o "$TIOCSTI_HELPER" "${TIOCSTI_HELPER}.c" 2>/dev/null || {
    rm -f "${TIOCSTI_HELPER}.c"
    return 1
  }
  rm -f "${TIOCSTI_HELPER}.c"
}

tiocsti_send() {
  local text="$1"
  echo -e "  ${DIM}tiocsti -> $TARGET_TTY${NC}"

  if [[ "$DRY_RUN" == true ]]; then
    echo -e "  ${YELLOW}[dry-run]${NC} TIOCSTI inject \"$text\\r\" -> $TARGET_TTY"
    return 0
  fi

  "$TIOCSTI_HELPER" "$TARGET_TTY" "${text}"$'\r'
}

# ── Method: xdotool ──────────────────────────────────────────────────────────
xdotool_available() {
  command -v xdotool &>/dev/null || return 1
  [[ -n "${DISPLAY:-}" ]] || return 1
  xdotool_find_window &>/dev/null
}

xdotool_find_window() {
  local wid
  for wid in $(xdotool search --name "claude\|terminal\|tmux\|bash\|zsh" 2>/dev/null); do
    local wpid
    wpid=$(xdotool getwindowpid "$wid" 2>/dev/null) || continue
    if [[ "$wpid" == "$TARGET_PID" ]] || pgrep -s 0 -P "$wpid" 2>/dev/null | grep -qw "$TARGET_PID"; then
      echo "$wid"
      return 0
    fi
  done
  return 1
}

xdotool_send() {
  local text="$1"
  local wid
  wid=$(xdotool_find_window) || {
    echo -e "${RED}xdotool: could not find window for PID $TARGET_PID${NC}" >&2
    return 1
  }
  echo -e "  ${DIM}xdotool -> window $wid${NC}"

  if [[ "$DRY_RUN" == true ]]; then
    echo -e "  ${YELLOW}[dry-run]${NC} xdotool type --window $wid \"$text\" + Return"
    return 0
  fi

  xdotool key --window "$wid" ctrl+u
  xdotool type --window "$wid" --clearmodifiers --delay 12 "$text"
  xdotool key --window "$wid" Return
}

# ── Method selection ─────────────────────────────────────────────────────────
METHODS=("tmux" "tiocsti" "xdotool")

detect_method() {
  if [[ -n "$FORCE_METHOD" ]]; then
    echo "$FORCE_METHOD"
    return
  fi
  for m in "${METHODS[@]}"; do
    if "${m}_available"; then
      echo "$m"
      return
    fi
  done
  return 1
}

send_input() {
  local method="$1" text="$2"
  "${method}_send" "$text"
}

METHOD=$(detect_method) || {
  echo -e "${RED}No injection method available.${NC}" >&2
  echo ""
  echo "  Options to fix this:"
  echo ""
  echo -e "  ${BOLD}1. Use tmux${NC} (recommended):"
  echo "     Launch Claude Code inside tmux:"
  echo "       tmux new-session -s claude 'claude'"
  echo ""
  echo -e "  ${BOLD}2. Enable TIOCSTI${NC} (quick, but deprecated):"
  echo "     sudo sysctl -w dev.tty.legacy_tiocsti=1"
  echo "     # Persist across reboots:"
  echo "     echo 'dev.tty.legacy_tiocsti=1' | sudo tee /etc/sysctl.d/99-tiocsti.conf"
  echo ""
  echo -e "  ${BOLD}3. Install xdotool${NC} (requires X11/WSLg focus):"
  echo "     sudo apt install xdotool"
  echo ""
  exit 1
}

echo -e "${GREEN}Method: ${BOLD}$METHOD${NC}"

# ── Send commands ────────────────────────────────────────────────────────────
for i in "${!COMMANDS[@]}"; do
  cmd="${COMMANDS[$i]}"
  echo -e "${BOLD}-> Sending:${NC} $cmd"
  send_input "$METHOD" "$cmd"

  if [[ $i -lt $((${#COMMANDS[@]} - 1)) ]]; then
    echo -e "  ${DIM}Waiting ${DELAY}s...${NC}"
    sleep "$DELAY"
  fi
done

echo -e "${GREEN}Done.${NC}"
