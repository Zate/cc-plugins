#!/usr/bin/env bash
# Analyze token usage for all sessions from a test run
#
# Usage:
#   ./analyze-all-sessions.sh                    # Analyze most recent test run
#   ./analyze-all-sessions.sh /path/to/test/dir  # Analyze specific test run
#   ./analyze-all-sessions.sh --list             # List available test runs
#   ./analyze-all-sessions.sh --json             # Output combined JSON

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_OUTPUT_BASE="/tmp/cc-plugins-tests"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
OUTPUT_JSON=false
LIST_RUNS=false
TEST_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --json)
            OUTPUT_JSON=true
            shift
            ;;
        --list)
            LIST_RUNS=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options] [test-dir]"
            echo ""
            echo "Analyze token usage for all sessions from a test run."
            echo ""
            echo "Options:"
            echo "  --json     Output combined JSON instead of tables"
            echo "  --list     List available test runs"
            echo "  --help     Show this help"
            echo ""
            echo "Arguments:"
            echo "  test-dir   Path to test output directory (default: most recent)"
            echo ""
            echo "Examples:"
            echo "  $0                              # Analyze most recent run"
            echo "  $0 --list                       # List all test runs"
            echo "  $0 /tmp/cc-plugins-tests/20260116_181200"
            exit 0
            ;;
        *)
            TEST_DIR="$1"
            shift
            ;;
    esac
done

# List available runs
if [ "$LIST_RUNS" = true ]; then
    echo "Available test runs in $TEST_OUTPUT_BASE:"
    echo ""
    if [ -d "$TEST_OUTPUT_BASE" ]; then
        ls -1t "$TEST_OUTPUT_BASE" | while read -r dir; do
            session_count=$(find "$TEST_OUTPUT_BASE/$dir" -name "claude-output.json" 2>/dev/null | wc -l)
            echo "  $dir ($session_count sessions)"
        done
    else
        echo "  (no test runs found)"
    fi
    exit 0
fi

# Find test directory
if [ -z "$TEST_DIR" ]; then
    if [ ! -d "$TEST_OUTPUT_BASE" ]; then
        echo "Error: No test runs found in $TEST_OUTPUT_BASE"
        echo "Run some tests first: ./tests/run-tests.sh --all"
        exit 1
    fi
    # Get most recent
    TEST_DIR="$TEST_OUTPUT_BASE/$(ls -1t "$TEST_OUTPUT_BASE" | head -1)"
fi

if [ ! -d "$TEST_DIR" ]; then
    echo "Error: Test directory not found: $TEST_DIR"
    exit 1
fi

echo "========================================"
echo " Token Usage Analysis"
echo "========================================"
echo ""
echo "Test run: $TEST_DIR"
echo ""

# Find all session files
SESSION_FILES=$(find "$TEST_DIR" -name "claude-output.json" -type f 2>/dev/null | sort)

if [ -z "$SESSION_FILES" ]; then
    echo "No session files found in $TEST_DIR"
    exit 1
fi

SESSION_COUNT=$(echo "$SESSION_FILES" | wc -l)
echo "Found $SESSION_COUNT session(s)"
echo ""

# Track totals
TOTAL_INPUT=0
TOTAL_OUTPUT=0
TOTAL_CACHE=0
TOTAL_COST=0

# JSON output array
if [ "$OUTPUT_JSON" = true ]; then
    echo "["
    FIRST=true
fi

# Analyze each session
for session_file in $SESSION_FILES; do
    # Get relative path for display
    rel_path="${session_file#$TEST_DIR/}"
    test_name=$(dirname "$rel_path" | tr '/' ' > ')

    if [ "$OUTPUT_JSON" = true ]; then
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            echo ","
        fi
        echo "  {"
        echo "    \"test\": \"$test_name\","
        echo "    \"file\": \"$session_file\","
        # Get JSON analysis
        analysis=$(python3 "$SCRIPT_DIR/analyze-token-usage.py" --json "$session_file" 2>/dev/null || echo '{}')
        echo "    \"analysis\": $analysis"
        echo -n "  }"
    else
        echo "----------------------------------------"
        echo -e "${BLUE}Test:${NC} $test_name"
        echo "----------------------------------------"

        # Run analysis
        if python3 "$SCRIPT_DIR/analyze-token-usage.py" "$session_file" 2>/dev/null; then
            # Extract totals for summary (parse from JSON)
            totals=$(python3 "$SCRIPT_DIR/analyze-token-usage.py" --json "$session_file" 2>/dev/null | grep -A20 '"totals"')
            input=$(echo "$totals" | grep '"input_tokens"' | grep -o '[0-9]*' | head -1 || echo "0")
            output=$(echo "$totals" | grep '"output_tokens"' | grep -o '[0-9]*' | head -1 || echo "0")
            cache=$(echo "$totals" | grep '"cache_read"' | grep -o '[0-9]*' | head -1 || echo "0")
            cost=$(echo "$totals" | grep '"estimated_cost_usd"' | grep -o '[0-9.]*' | head -1 || echo "0")

            TOTAL_INPUT=$((TOTAL_INPUT + ${input:-0}))
            TOTAL_OUTPUT=$((TOTAL_OUTPUT + ${output:-0}))
            TOTAL_CACHE=$((TOTAL_CACHE + ${cache:-0}))
            # Cost calculation is tricky in bash, skip for now
        else
            echo -e "  ${YELLOW}[WARN]${NC} Could not analyze session"
        fi

        echo ""
    fi
done

if [ "$OUTPUT_JSON" = true ]; then
    echo ""
    echo "]"
else
    # Print grand total summary
    echo "========================================"
    echo " Grand Total (All Sessions)"
    echo "========================================"
    echo ""
    echo "  Sessions analyzed:  $SESSION_COUNT"
    echo "  Total input tokens: $(printf "%'d" $TOTAL_INPUT)"
    echo "  Total output tokens: $(printf "%'d" $TOTAL_OUTPUT)"
    echo "  Total cache read:   $(printf "%'d" $TOTAL_CACHE)"
    echo ""
    echo "  Session files saved in: $TEST_DIR"
    echo ""
fi
