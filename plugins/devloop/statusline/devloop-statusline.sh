#!/bin/bash
# Devloop statusline for Claude Code
# Displays: Model | Context | Tokens | API Limits | Path | Branch | Plan | Bugs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ANSI color codes
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"
MAGENTA="\033[35m"
BLUE="\033[34m"
GREEN="\033[32m"
WHITE="\033[37m"

# Read JSON input from stdin
input=$(cat)

# Check if jq is available
if ! command -v jq &> /dev/null; then
    # Fallback: Extract basic info using grep/sed
    # Try to get model name
    MODEL_DISPLAY=$(echo "$input" | grep -o '"display_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "")

    if [ -z "$MODEL_DISPLAY" ]; then
        # Can't parse JSON without jq - show install message
        echo -e "${YELLOW}Install jq for devloop statusline: ${BOLD}sudo apt install jq${RESET}"
        exit 0
    fi

    # Basic extraction without jq (limited functionality)
    CURRENT_DIR=$(echo "$input" | grep -o '"current_dir"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "")
    PROJECT_DIR=$(echo "$input" | grep -o '"project_dir"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "")

    # No context tracking without jq
    CONTEXT_SIZE=0
    INPUT_TOKENS=0
    CACHE_CREATE=0
    CACHE_READ=0
    TOTAL_INPUT=0
    TOTAL_OUTPUT=0
else
    # Extract values using jq
    MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
    CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // ""')
    PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir // ""')

    # Extract context window usage
    CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
    INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
    CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
    CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

    # Extract session totals
    TOTAL_INPUT=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
    TOTAL_OUTPUT=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
fi

# Get shortened path (last 2 directories)
if [ -n "$CURRENT_DIR" ]; then
    SHORT_PATH=$(echo "$CURRENT_DIR" | rev | cut -d'/' -f1-2 | rev)
else
    SHORT_PATH="~"
fi

# Calculate context window percentage
CONTEXT_PCT=0
CONTEXT_DISPLAY=""
if [ "${CONTEXT_SIZE:-0}" -gt 0 ] 2>/dev/null; then
    CURRENT_CONTEXT=$((${INPUT_TOKENS:-0} + ${CACHE_CREATE:-0} + ${CACHE_READ:-0}))
    CONTEXT_PCT=$((CURRENT_CONTEXT * 100 / CONTEXT_SIZE))

    # Write context usage to file for hooks to read
    mkdir -p .claude
    cat > .claude/context-usage.json <<CONTEXT_EOF
{"context_pct": $CONTEXT_PCT, "current_tokens": $CURRENT_CONTEXT, "max_tokens": $CONTEXT_SIZE, "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"}
CONTEXT_EOF

    # Create mini progress bar (5 chars)
    BAR_FILLED=$((CONTEXT_PCT * 5 / 100))
    BAR_EMPTY=$((5 - BAR_FILLED))
    FILLED_BAR=""
    EMPTY_BAR=""
    for ((i=0; i<BAR_FILLED; i++)); do FILLED_BAR="${FILLED_BAR}█"; done
    for ((i=0; i<BAR_EMPTY; i++)); do EMPTY_BAR="${EMPTY_BAR}░"; done

    # Color code by usage level
    if [ "$CONTEXT_PCT" -ge 80 ]; then
        CONTEXT_DISPLAY="${RED}${FILLED_BAR}${DIM}${EMPTY_BAR}${RESET}${RED}${CONTEXT_PCT}%${RESET}"
    elif [ "$CONTEXT_PCT" -ge 60 ]; then
        CONTEXT_DISPLAY="${YELLOW}${FILLED_BAR}${DIM}${EMPTY_BAR}${RESET}${YELLOW}${CONTEXT_PCT}%${RESET}"
    else
        CONTEXT_DISPLAY="${WHITE}${FILLED_BAR}${DIM}${EMPTY_BAR}${RESET}${CONTEXT_PCT}%"
    fi
fi

# Calculate session tokens with K/M formatting
SESSION_TOKENS=""
SESSION_TOTAL=$((${TOTAL_INPUT:-0} + ${TOTAL_OUTPUT:-0}))
if [ "$SESSION_TOTAL" -gt 0 ]; then
    if [ "$SESSION_TOTAL" -ge 1000000 ]; then
        SESSION_TOKENS=$(awk "BEGIN {printf \"%.1fM\", $SESSION_TOTAL/1000000}")
    elif [ "$SESSION_TOTAL" -ge 1000 ]; then
        SESSION_TOKENS=$(awk "BEGIN {printf \"%.1fK\", $SESSION_TOTAL/1000}")
    else
        SESSION_TOKENS="$SESSION_TOTAL"
    fi
fi

# Fetch API usage (cached, fast)
API_DISPLAY=""
FETCH_SCRIPT="$SCRIPT_DIR/../scripts/fetch-api-usage.sh"
if [ -f "$FETCH_SCRIPT" ]; then
    API_USAGE=$("$FETCH_SCRIPT" 2>/dev/null) || API_USAGE=""
    if [ -n "$API_USAGE" ] && command -v jq &> /dev/null; then
        FIVE_HR=$(echo "$API_USAGE" | jq -r '.five_hour_pct // 0' 2>/dev/null)
        SEVEN_DAY=$(echo "$API_USAGE" | jq -r '.seven_day_pct // 0' 2>/dev/null)

        # Color code API usage
        color_pct() {
            local pct=$1
            if [ "$pct" -ge 90 ]; then
                echo "${RED}${pct}%${RESET}"
            elif [ "$pct" -ge 60 ]; then
                echo "${YELLOW}${pct}%${RESET}"
            else
                echo "${GREEN}${pct}%${RESET}"
            fi
        }

        FIVE_HR_DISPLAY=$(color_pct "${FIVE_HR:-0}")
        SEVEN_DAY_DISPLAY=$(color_pct "${SEVEN_DAY:-0}")
        API_DISPLAY="${DIM}5h ${RESET}$FIVE_HR_DISPLAY ${DIM}7d ${RESET}$SEVEN_DAY_DISPLAY"
    fi
fi

# Get git branch if in a git repo
GIT_BRANCH=""
WORK_DIR="${CURRENT_DIR:-$(pwd)}"
if { [ -n "$WORK_DIR" ] && [ -d "$WORK_DIR/.git" ]; } || git -C "$WORK_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$WORK_DIR" branch --show-current 2>/dev/null || echo "")
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH="${CYAN}${BRANCH}${RESET}"
    fi
fi

# Check for devloop plan progress (prefer .devloop/, fallback to .claude/)
PLAN_STATUS=""
PLAN_FILE=""

if [ -f "${PROJECT_DIR:-.}/.devloop/plan.md" ]; then
    PLAN_FILE="${PROJECT_DIR:-.}/.devloop/plan.md"
elif [ -f "${PROJECT_DIR:-.}/.claude/devloop-plan.md" ]; then
    PLAN_FILE="${PROJECT_DIR:-.}/.claude/devloop-plan.md"
fi

TOTAL=0
DONE=0

if [ -n "$PLAN_FILE" ] && [ -f "$PLAN_FILE" ]; then
    # Filter out code blocks, then count only actual task markers
    # Task pattern: "- [ ]", "- [x]", "- [~]", "- [!]", "- [-]"
    FILTERED=$(awk '/^```/ { in_code = !in_code; next } !in_code { print }' "$PLAN_FILE")
    TOTAL=$(echo "$FILTERED" | grep -cE "^[[:space:]]*- \[[ x~!-]\]" 2>/dev/null) || TOTAL=0
    COMPLETED=$(echo "$FILTERED" | grep -cE "^[[:space:]]*- \[x\]" 2>/dev/null) || COMPLETED=0
    SKIPPED=$(echo "$FILTERED" | grep -cE "^[[:space:]]*- \[-\]" 2>/dev/null) || SKIPPED=0
    DONE=$((COMPLETED + SKIPPED))
fi

# Ensure numeric values
TOTAL="${TOTAL:-0}"
DONE="${DONE:-0}"

if [ "$TOTAL" -gt 0 ] 2>/dev/null; then
    PLAN_STATUS="${MAGENTA}${DONE}/${TOTAL}${RESET}"
fi

# Check for open bugs/issues (prefer .devloop/, fallback to .claude/)
BUG_COUNT=""
ISSUES_DIR=""
if [ -d "${PROJECT_DIR:-.}/.devloop/issues" ]; then
    ISSUES_DIR="${PROJECT_DIR:-.}/.devloop/issues"
elif [ -d "${PROJECT_DIR:-.}/.claude/issues" ]; then
    ISSUES_DIR="${PROJECT_DIR:-.}/.claude/issues"
elif [ -d "${PROJECT_DIR:-.}/.claude/bugs" ]; then
    ISSUES_DIR="${PROJECT_DIR:-.}/.claude/bugs"
fi

if [ -n "$ISSUES_DIR" ] && [ -d "$ISSUES_DIR" ]; then
    OPEN_BUGS=$(grep -l "status: open" "$ISSUES_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    if [ "$OPEN_BUGS" -gt 0 ]; then
        BUG_COUNT="${RED}${OPEN_BUGS}${RESET}"
    fi
fi

# Build statusline
OUTPUT=""

# Model (always shown, shortened)
MODEL_SHORT=$(echo "$MODEL_DISPLAY" | sed 's/Claude //' | sed 's/ /-/g')
OUTPUT="${BOLD}${MODEL_SHORT}${RESET}"

# Context window (if available)
if [ -n "$CONTEXT_DISPLAY" ]; then
    OUTPUT="${OUTPUT} ${DIM}|${RESET} ${CONTEXT_DISPLAY}"
fi

# Session tokens (if available)
if [ -n "$SESSION_TOKENS" ]; then
    OUTPUT="${OUTPUT} ${DIM}|${RESET} ${CYAN}${SESSION_TOKENS}${RESET}"
fi

# API limits (if available)
if [ -n "$API_DISPLAY" ]; then
    OUTPUT="${OUTPUT} ${DIM}|${RESET} ${API_DISPLAY}"
fi

# Path (always shown)
OUTPUT="${OUTPUT} ${DIM}|${RESET} ${BLUE}${SHORT_PATH}${RESET}"

# Git branch (if available)
if [ -n "$GIT_BRANCH" ]; then
    OUTPUT="${OUTPUT} ${DIM}|${RESET} ${GIT_BRANCH}"
fi

# Plan progress (if exists)
if [ -n "$PLAN_STATUS" ]; then
    OUTPUT="${OUTPUT} ${DIM}|${RESET} ${DIM}P:${RESET}${PLAN_STATUS}"
fi

# Bug count (if any)
if [ -n "$BUG_COUNT" ]; then
    OUTPUT="${OUTPUT} ${DIM}|${RESET} ${DIM}B:${RESET}${BUG_COUNT}"
fi

# Output the statusline
echo -e "$OUTPUT"
