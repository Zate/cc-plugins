#!/usr/bin/env bash
# Run all explicit skill request tests
#
# Tests that skills are correctly invoked when explicitly named by the user.
# Each test uses a prompt file from prompts/ directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo " Explicit Skill Request Tests"
echo "========================================"
echo ""
echo "These tests verify that Claude correctly invokes skills"
echo "when the user explicitly requests them by name."
echo ""

# Track results
TOTAL_PASSED=0
TOTAL_FAILED=0

# Define tests: skill-name:prompt-file:max-turns
TESTS=(
    "devloop:devloop:prompts/devloop-explicit.txt:5"
    "devloop:continue:prompts/continue-explicit.txt:5"
    "devloop:quick:prompts/quick-explicit.txt:5"
    "devloop:spike:prompts/spike-explicit.txt:5"
)

# Run each test
for test_spec in "${TESTS[@]}"; do
    IFS=':' read -r skill prompt max_turns <<< "$test_spec"

    # Skip if prompt file doesn't exist
    if [ ! -f "$SCRIPT_DIR/$prompt" ]; then
        echo "Skipping $skill - prompt file not found: $prompt"
        continue
    fi

    echo "----------------------------------------"
    echo "Testing: $skill"
    echo "----------------------------------------"

    if "$SCRIPT_DIR/run-test.sh" "$skill" "$prompt" "$max_turns"; then
        ((TOTAL_PASSED++))
    else
        ((TOTAL_FAILED++))
    fi

    echo ""
done

# Summary
echo "========================================"
echo " Summary"
echo "========================================"
echo "Passed: $TOTAL_PASSED"
echo "Failed: $TOTAL_FAILED"
echo "========================================"

if [ $TOTAL_FAILED -gt 0 ]; then
    exit 1
fi
