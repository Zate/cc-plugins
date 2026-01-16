#!/usr/bin/env bash
# Test that a skill is invoked when explicitly requested by name
#
# Usage: ./run-test.sh <skill-name> <prompt-file> [max-turns]
#
# This tests that Claude correctly invokes the Skill tool when a user
# explicitly asks for a skill by name (e.g., "use the devloop skill").

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TESTS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source test helpers
source "$TESTS_ROOT/claude-code/test-helpers.sh"

# Parse arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <skill-name> <prompt-file> [max-turns]"
    echo ""
    echo "Example: $0 devloop:devloop prompts/devloop-explicit.txt 5"
    exit 1
fi

SKILL_NAME="$1"
PROMPT_FILE="$2"
MAX_TURNS="${3:-5}"

# Validate prompt file
if [ ! -f "$SCRIPT_DIR/$PROMPT_FILE" ]; then
    echo "Error: Prompt file not found: $SCRIPT_DIR/$PROMPT_FILE"
    exit 1
fi

# Read prompt
PROMPT=$(cat "$SCRIPT_DIR/$PROMPT_FILE")

# Setup output directory
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="/tmp/cc-plugins-tests/$TIMESTAMP/explicit-skill-requests/${SKILL_NAME//:/___}"
mkdir -p "$OUTPUT_DIR"

# Save prompt for reference
echo "$PROMPT" > "$OUTPUT_DIR/prompt.txt"

start_suite "Explicit Skill Request: $SKILL_NAME"

echo "Prompt file: $PROMPT_FILE"
echo "Max turns: $MAX_TURNS"
echo "Output dir: $OUTPUT_DIR"
echo ""

# Run Claude with the prompt
echo "Running Claude..."
OUTPUT_FILE="$OUTPUT_DIR/claude-output.json"

if ! claude -p --output-format stream-json --max-turns "$MAX_TURNS" "$PROMPT" > "$OUTPUT_FILE" 2>&1; then
    echo -e "  ${YELLOW}[WARN]${NC} Claude exited with non-zero status"
fi

echo ""

# Test 1: Check that the Skill tool was invoked
echo "Checking Skill tool invocation..."
assert_skill_invoked "$OUTPUT_FILE" "$SKILL_NAME" "Skill tool invoked with correct skill name"

# Test 2: Check that Skill was the first tool called (no premature actions)
echo "Checking tool order..."
FIRST_TOOL=$(grep '"type":"tool_use"' "$OUTPUT_FILE" | head -1 | grep -o '"name":"[^"]*"' | head -1 | sed 's/"name":"//;s/"//')

if [ "$FIRST_TOOL" = "Skill" ]; then
    echo -e "  ${GREEN}[PASS]${NC} Skill was the first tool called"
    ((TESTS_PASSED++))
else
    echo -e "  ${YELLOW}[INFO]${NC} First tool was: $FIRST_TOOL (might be acceptable)"
    # This is informational, not a failure - sometimes exploration tools are needed first
fi

# Test 3: Check that no code was written before skill invocation
echo "Checking no premature code changes..."
SKILL_LINE=$(grep -n '"skill":"'"$SKILL_NAME"'"' "$OUTPUT_FILE" | head -1 | cut -d: -f1)
if [ -n "$SKILL_LINE" ]; then
    # Check if Write/Edit tools were used before Skill
    WRITE_BEFORE_SKILL=$(head -n "$SKILL_LINE" "$OUTPUT_FILE" | grep -c '"name":"Write"\|"name":"Edit"' || echo "0")
    if [ "$WRITE_BEFORE_SKILL" -eq 0 ]; then
        echo -e "  ${GREEN}[PASS]${NC} No Write/Edit before Skill invocation"
        ((TESTS_PASSED++))
    else
        echo -e "  ${RED}[FAIL]${NC} Write/Edit used before Skill invocation"
        ((TESTS_FAILED++))
    fi
fi

# Analyze tokens
echo ""
echo "Token Analysis:"
analyze_tokens "$OUTPUT_FILE"

# Print summary
print_summary

echo ""
echo "Output saved to: $OUTPUT_DIR"
