#!/bin/bash
# Devloop statusline for Claude Code
# Displays: Model | Path | Git Branch | Plan Progress | Bugs | Context Usage

set -euo pipefail

# ANSI color codes
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
CYAN="\033[36m"
YELLOW="\033[33m"
GREEN="\033[32m"
RED="\033[31m"
MAGENTA="\033[35m"
BLUE="\033[34m"

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
    INPUT_TOKENS=$(echo "$input" | grep -o '"total_input_tokens"[[:space:]]*:[[:space:]]*[0-9]*' | head -1 | sed 's/.*:[[:space:]]*//' || echo "0")
    OUTPUT_TOKENS=$(echo "$input" | grep -o '"total_output_tokens"[[:space:]]*:[[:space:]]*[0-9]*' | head -1 | sed 's/.*:[[:space:]]*//' || echo "0")
    CONTEXT_SIZE=$(echo "$input" | grep -o '"context_window_size"[[:space:]]*:[[:space:]]*[0-9]*' | head -1 | sed 's/.*:[[:space:]]*//' || echo "200000")
else
    # Extract values using jq
    MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
    CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // ""')
    PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir // ""')
    INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
    OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
    CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
fi

# Ensure numeric values for arithmetic
INPUT_TOKENS=${INPUT_TOKENS:-0}
OUTPUT_TOKENS=${OUTPUT_TOKENS:-0}
CONTEXT_SIZE=${CONTEXT_SIZE:-200000}

# Handle empty or non-numeric values
[[ "$INPUT_TOKENS" =~ ^[0-9]+$ ]] || INPUT_TOKENS=0
[[ "$OUTPUT_TOKENS" =~ ^[0-9]+$ ]] || OUTPUT_TOKENS=0
[[ "$CONTEXT_SIZE" =~ ^[0-9]+$ ]] || CONTEXT_SIZE=200000

# Calculate context usage percentage
TOTAL_TOKENS=$((INPUT_TOKENS + OUTPUT_TOKENS))
if [ "$CONTEXT_SIZE" -gt 0 ]; then
    PERCENT_USED=$((TOTAL_TOKENS * 100 / CONTEXT_SIZE))
else
    PERCENT_USED=0
fi

# Color context percentage based on usage
if [ "$PERCENT_USED" -lt 50 ]; then
    CTX_COLOR="$GREEN"
elif [ "$PERCENT_USED" -lt 75 ]; then
    CTX_COLOR="$YELLOW"
else
    CTX_COLOR="$RED"
fi

# Get shortened path (last 2 directories)
if [ -n "$CURRENT_DIR" ]; then
    SHORT_PATH=$(echo "$CURRENT_DIR" | rev | cut -d'/' -f1-2 | rev)
else
    SHORT_PATH="~"
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

# Check for devloop plan progress
PLAN_STATUS=""
PLAN_FILE="${PROJECT_DIR:-.}/.claude/devloop-plan.md"
if [ -f "$PLAN_FILE" ]; then
    TOTAL=$(grep -c "^\s*- \[" "$PLAN_FILE" 2>/dev/null || echo "0")
    DONE=$(grep -c "^\s*- \[x\]" "$PLAN_FILE" 2>/dev/null || echo "0")
    if [ "$TOTAL" -gt 0 ]; then
        PLAN_STATUS="${MAGENTA}${DONE}/${TOTAL}${RESET}"
    fi
fi

# Check for open bugs
BUG_COUNT=""
BUGS_DIR="${PROJECT_DIR:-.}/.claude/bugs"
if [ -d "$BUGS_DIR" ]; then
    OPEN_BUGS=$(grep -l "status: open" "$BUGS_DIR"/BUG-*.md 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    if [ "$OPEN_BUGS" -gt 0 ]; then
        BUG_COUNT="${RED}${OPEN_BUGS}${RESET}"
    fi
fi

# Build statusline
OUTPUT=""

# Model (always shown)
OUTPUT="${BOLD}${MODEL_DISPLAY}${RESET}"

# Path (always shown)
OUTPUT="${OUTPUT} ${DIM}|${RESET} ${BLUE}${SHORT_PATH}${RESET}"

# Git branch (if available)
if [ -n "$GIT_BRANCH" ]; then
    OUTPUT="${OUTPUT} ${DIM}|${RESET} ${GIT_BRANCH}"
fi

# Plan progress (if exists)
if [ -n "$PLAN_STATUS" ]; then
    OUTPUT="${OUTPUT} ${DIM}|${RESET} Plan:${PLAN_STATUS}"
fi

# Bug count (if any)
if [ -n "$BUG_COUNT" ]; then
    OUTPUT="${OUTPUT} ${DIM}|${RESET} Bugs:${BUG_COUNT}"
fi

# Context usage (always shown)
OUTPUT="${OUTPUT} ${DIM}|${RESET} ${CTX_COLOR}${PERCENT_USED}%${RESET}"

# Output the statusline
echo -e "$OUTPUT"
