#!/bin/bash
# Extract metrics from Claude session logs
# Usage: ./extract-metrics.sh <session-id> [project-path]

set -euo pipefail

SESSION_ID="${1:-}"
PROJECT_PATH="${2:-$(pwd)}"

if [ -z "$SESSION_ID" ]; then
    echo "Usage: $0 <session-id> [project-path]"
    echo ""
    echo "Find session IDs in ~/.claude/projects/"
    exit 1
fi

# Construct log path
SAFE_PATH=$(echo "$PROJECT_PATH" | sed 's|/|-|g' | sed 's|^-||')
LOG_DIR="$HOME/.claude/projects/$SAFE_PATH"
MAIN_LOG="$LOG_DIR/${SESSION_ID}.jsonl"

if [ ! -f "$MAIN_LOG" ]; then
    echo "Log file not found: $MAIN_LOG"
    echo "Looking for logs in: $LOG_DIR"
    ls -la "$LOG_DIR"/*.jsonl 2>/dev/null | head -10
    exit 1
fi

echo "Analyzing: $MAIN_LOG"
echo ""

# Extract token usage from the log
echo "=== Token Usage ==="
grep -o '"usage":{[^}]*}' "$MAIN_LOG" 2>/dev/null | tail -1 || echo "No usage data found"

echo ""
echo "=== Subagent Count ==="
AGENT_COUNT=$(ls "$LOG_DIR"/agent-*.jsonl 2>/dev/null | wc -l)
echo "Subagents spawned: $AGENT_COUNT"

if [ "$AGENT_COUNT" -gt 0 ]; then
    echo ""
    echo "Subagent files:"
    ls -lh "$LOG_DIR"/agent-*.jsonl 2>/dev/null
fi

echo ""
echo "=== Main Log Size ==="
ls -lh "$MAIN_LOG"

echo ""
echo "=== Message Count ==="
USER_MSGS=$(grep -c '"type":"user"' "$MAIN_LOG" 2>/dev/null || echo "0")
ASST_MSGS=$(grep -c '"type":"assistant"' "$MAIN_LOG" 2>/dev/null || echo "0")
echo "User messages: $USER_MSGS"
echo "Assistant messages: $ASST_MSGS"

echo ""
echo "=== Tool Usage ==="
grep -o '"tool_name":"[^"]*"' "$MAIN_LOG" 2>/dev/null | sort | uniq -c | sort -rn | head -20 || echo "No tool usage found"
