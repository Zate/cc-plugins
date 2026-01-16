#!/usr/bin/env bash
# Run all skill triggering tests
#
# Tests that skills are correctly auto-detected based on context,
# WITHOUT the user explicitly naming the skill.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo " Skill Triggering Tests"
echo "========================================"
echo ""
echo "These tests verify that Claude automatically detects and invokes"
echo "the appropriate skill based on context, without explicit mention."
echo ""

# Track results
TOTAL_PASSED=0
TOTAL_FAILED=0

# Define tests: expected-skill:prompt-file:max-turns
TESTS=(
    "devloop:devloop:prompts/start-feature-work.txt:5"
    "devloop:spike:prompts/need-to-explore.txt:5"
    "devloop:quick:prompts/small-quick-fix.txt:5"
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
    echo "Testing auto-detection of: $skill"
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
