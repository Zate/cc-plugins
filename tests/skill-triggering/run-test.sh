#!/usr/bin/env bash
# Test that a skill is automatically triggered based on context
#
# Usage: ./run-test.sh <expected-skill> <prompt-file> [max-turns]
#
# This tests that Claude's skill auto-detection works - it should
# recognize when a skill is applicable based on the user's request,
# even without explicit mention of the skill name.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TESTS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source test helpers
source "$TESTS_ROOT/claude-code/test-helpers.sh"

# Parse arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <expected-skill> <prompt-file> [max-turns]"
    echo ""
    echo "Example: $0 devloop:devloop prompts/start-feature-work.txt 5"
    echo ""
    echo "This tests whether Claude automatically detects that a skill"
    echo "should be used, based on the context of the user's request."
    exit 1
fi

EXPECTED_SKILL="$1"
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
OUTPUT_DIR="/tmp/cc-plugins-tests/$TIMESTAMP/skill-triggering/${EXPECTED_SKILL//:/___}"
mkdir -p "$OUTPUT_DIR"

# Save prompt for reference
echo "$PROMPT" > "$OUTPUT_DIR/prompt.txt"

start_suite "Skill Triggering: $EXPECTED_SKILL"

echo "Prompt file: $PROMPT_FILE"
echo "Max turns: $MAX_TURNS"
echo "Output dir: $OUTPUT_DIR"
echo ""
echo "Prompt (should NOT mention skill name):"
echo "---"
echo "$PROMPT" | head -5
echo "---"
echo ""

# Run Claude with the prompt
echo "Running Claude..."
OUTPUT_FILE="$OUTPUT_DIR/claude-output.json"

if ! claude -p --output-format stream-json --max-turns "$MAX_TURNS" "$PROMPT" > "$OUTPUT_FILE" 2>&1; then
    echo -e "  ${YELLOW}[WARN]${NC} Claude exited with non-zero status"
fi

echo ""

# Test 1: Check that the expected Skill was invoked
echo "Checking skill auto-detection..."
if grep -q '"name":"Skill"' "$OUTPUT_FILE" && grep -q "\"skill\":\"$EXPECTED_SKILL\"" "$OUTPUT_FILE"; then
    echo -e "  ${GREEN}[PASS]${NC} Skill '$EXPECTED_SKILL' was auto-detected and invoked"
    ((TESTS_PASSED++))
else
    # Check what skill (if any) was invoked
    INVOKED_SKILL=$(grep '"skill":"' "$OUTPUT_FILE" | head -1 | grep -o '"skill":"[^"]*"' | sed 's/"skill":"//;s/"//') || true
    if [ -n "$INVOKED_SKILL" ]; then
        echo -e "  ${RED}[FAIL]${NC} Expected skill '$EXPECTED_SKILL' but got '$INVOKED_SKILL'"
    else
        echo -e "  ${RED}[FAIL]${NC} No skill was invoked (expected '$EXPECTED_SKILL')"
    fi
    ((TESTS_FAILED++))
fi

# Test 2: Check that Skill was invoked early (before heavy exploration)
echo "Checking skill invocation timing..."
SKILL_LINE=$(grep -n '"name":"Skill"' "$OUTPUT_FILE" | head -1 | cut -d: -f1) || true
TOTAL_TOOL_CALLS=$(grep -c '"type":"tool_use"' "$OUTPUT_FILE" || echo "0")

if [ -n "$SKILL_LINE" ] && [ "$TOTAL_TOOL_CALLS" -gt 0 ]; then
    # Calculate what percentage of tool calls occurred before skill
    TOOLS_BEFORE=$(head -n "$SKILL_LINE" "$OUTPUT_FILE" | grep -c '"type":"tool_use"' || echo "0")
    TOOLS_BEFORE=$((TOOLS_BEFORE - 1))  # Don't count the Skill call itself

    if [ "$TOOLS_BEFORE" -le 3 ]; then
        echo -e "  ${GREEN}[PASS]${NC} Skill invoked early ($TOOLS_BEFORE tool calls before)"
        ((TESTS_PASSED++))
    else
        echo -e "  ${YELLOW}[INFO]${NC} Skill invoked after $TOOLS_BEFORE tool calls (may indicate exploration)"
    fi
else
    echo -e "  ${YELLOW}[INFO]${NC} Could not determine skill timing"
fi

# Test 3: Verify prompt doesn't contain explicit skill name (sanity check)
if echo "$PROMPT" | grep -qi "\\/$EXPECTED_SKILL\\|skill.*$EXPECTED_SKILL\\|$EXPECTED_SKILL.*skill"; then
    echo -e "  ${YELLOW}[WARN]${NC} Prompt appears to mention skill name - this test may be invalid"
else
    echo -e "  ${GREEN}[INFO]${NC} Prompt does not mention skill name (good test)"
fi

# Analyze tokens
echo ""
echo "Token Analysis:"
analyze_tokens "$OUTPUT_FILE"

# Print summary
print_summary

echo ""
echo "Output saved to: $OUTPUT_DIR"
