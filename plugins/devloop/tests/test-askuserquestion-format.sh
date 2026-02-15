#!/usr/bin/env bash
# Test that all AskUserQuestion instances use the correct format
# Correct format requires:
#   - questions: array wrapper
#   - multiSelect: field in each question

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

start_suite "AskUserQuestion Format Validation"

echo ""
echo "Checking commands/ and agents/ for AskUserQuestion format..."
echo ""

# Track errors
ERRORS=0
CHECKED=0

# Find all markdown files with AskUserQuestion
check_askuserquestion_format() {
    local dir="$1"
    local dir_name="$2"

    if [ ! -d "$dir" ]; then
        echo "  [SKIP] $dir_name directory not found"
        return 0
    fi

    for file in "$dir"/*.md; do
        [ -f "$file" ] || continue

        local filename=$(basename "$file")

        # Check if file contains AskUserQuestion
        if ! grep -q "AskUserQuestion:" "$file"; then
            continue
        fi

        ((CHECKED++)) || true

        # Count AskUserQuestion blocks
        local block_count
        block_count=$(grep -c "AskUserQuestion:" "$file" 2>/dev/null) || block_count=0

        # Count questions: lines (should match block_count)
        local questions_count
        questions_count=$(grep -c "questions:" "$file" 2>/dev/null) || questions_count=0

        # Count multiSelect: lines (should match block_count)
        local multiselect_count
        multiselect_count=$(grep -c "multiSelect:" "$file" 2>/dev/null) || multiselect_count=0

        local has_error=false
        local error_msg=""

        # Check questions: wrapper
        if [ "$questions_count" -lt "$block_count" ]; then
            has_error=true
            error_msg="Missing 'questions:' wrapper (found $questions_count, expected $block_count)"
        fi

        # Check multiSelect:
        if [ "$multiselect_count" -lt "$block_count" ]; then
            has_error=true
            if [ -n "$error_msg" ]; then
                error_msg="$error_msg; also missing 'multiSelect:' (found $multiselect_count, expected $block_count)"
            else
                error_msg="Missing 'multiSelect:' (found $multiselect_count, expected $block_count)"
            fi
        fi

        if [ "$has_error" = true ]; then
            echo -e "  ${RED}[FAIL]${NC} $dir_name/$filename"
            echo "       $error_msg"
            ((ERRORS++)) || true
        else
            echo -e "  ${GREEN}[PASS]${NC} $dir_name/$filename ($block_count AskUserQuestion blocks)"
            ((TESTS_PASSED++)) || true
        fi
    done
}

# Check commands directory
check_askuserquestion_format "$PLUGIN_DIR/commands" "commands"

# Check agents directory
check_askuserquestion_format "$PLUGIN_DIR/agents" "agents"

# Summary
echo ""
echo "================================"
echo "Checked $CHECKED files with AskUserQuestion"
echo "================================"

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}FAILED: $ERRORS files have incorrect AskUserQuestion format${NC}"
    echo ""
    echo "Correct format requires:"
    echo "  AskUserQuestion:"
    echo "    questions:"
    echo "      - question: \"...\""
    echo "        header: \"...\""
    echo "        multiSelect: false"
    echo "        options: [...]"
    exit 1
else
    echo -e "${GREEN}All AskUserQuestion blocks use correct format!${NC}"
fi

print_summary
