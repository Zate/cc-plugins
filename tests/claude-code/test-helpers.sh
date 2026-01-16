#!/usr/bin/env bash
# Helper functions for cc-plugins tests
# Adapted from superpowers testing framework

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track test results
TESTS_PASSED=0
TESTS_FAILED=0

# Test output directory (timestamped)
TEST_OUTPUT_DIR="${TEST_OUTPUT_DIR:-/tmp/cc-plugins-tests/$(date +%Y%m%d_%H%M%S)}"

# Create output directory
setup_test_output() {
    mkdir -p "$TEST_OUTPUT_DIR"
    echo "$TEST_OUTPUT_DIR"
}

# Run Claude Code with a prompt and capture output
# Usage: run_claude "prompt text" [timeout_seconds] [allowed_tools] [output_format]
run_claude() {
    local prompt="$1"
    local timeout="${2:-120}"
    local allowed_tools="${3:-}"
    local output_format="${4:-text}"
    local output_file=$(mktemp)
    local json_file=$(mktemp)

    # Build command
    local cmd="claude -p"

    if [ "$output_format" = "stream-json" ]; then
        cmd="$cmd --output-format stream-json"
    fi

    if [ -n "$allowed_tools" ]; then
        cmd="$cmd --allowed-tools $allowed_tools"
    fi

    # Run Claude in headless mode with timeout
    if timeout "$timeout" bash -c "$cmd \"$prompt\"" > "$output_file" 2>&1; then
        cat "$output_file"
        if [ "$output_format" = "stream-json" ]; then
            cp "$output_file" "$json_file"
            echo ""
            echo "__JSON_OUTPUT_FILE__=$json_file"
        fi
        rm -f "$output_file"
        return 0
    else
        local exit_code=$?
        cat "$output_file" >&2
        rm -f "$output_file"
        return $exit_code
    fi
}

# Run Claude with stream-json output and save to file
# Usage: run_claude_json "prompt" "output_file" [timeout] [allowed_tools]
run_claude_json() {
    local prompt="$1"
    local output_file="$2"
    local timeout="${3:-120}"
    local allowed_tools="${4:-}"

    local cmd="claude -p --output-format stream-json"

    if [ -n "$allowed_tools" ]; then
        cmd="$cmd --allowed-tools $allowed_tools"
    fi

    mkdir -p "$(dirname "$output_file")"

    if timeout "$timeout" bash -c "$cmd \"$prompt\"" > "$output_file" 2>&1; then
        return 0
    else
        return $?
    fi
}

# Check if output contains a pattern
# Usage: assert_contains "output" "pattern" "test name"
assert_contains() {
    local output="$1"
    local pattern="$2"
    local test_name="${3:-test}"

    if echo "$output" | grep -q "$pattern"; then
        echo -e "  ${GREEN}[PASS]${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}[FAIL]${NC} $test_name"
        echo "  Expected to find: $pattern"
        echo "  In output (first 30 lines):"
        echo "$output" | head -30 | sed 's/^/    /'
        ((TESTS_FAILED++))
        return 1
    fi
}

# Check if output does NOT contain a pattern
# Usage: assert_not_contains "output" "pattern" "test name"
assert_not_contains() {
    local output="$1"
    local pattern="$2"
    local test_name="${3:-test}"

    if echo "$output" | grep -q "$pattern"; then
        echo -e "  ${RED}[FAIL]${NC} $test_name"
        echo "  Did not expect to find: $pattern"
        echo "  In output (first 20 lines):"
        echo "$output" | head -20 | sed 's/^/    /'
        ((TESTS_FAILED++))
        return 1
    else
        echo -e "  ${GREEN}[PASS]${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    fi
}

# Check if output matches a count
# Usage: assert_count "output" "pattern" expected_count "test name"
assert_count() {
    local output="$1"
    local pattern="$2"
    local expected="$3"
    local test_name="${4:-test}"

    local actual=$(echo "$output" | grep -c "$pattern" || echo "0")

    if [ "$actual" -eq "$expected" ]; then
        echo -e "  ${GREEN}[PASS]${NC} $test_name (found $actual instances)"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}[FAIL]${NC} $test_name"
        echo "  Expected $expected instances of: $pattern"
        echo "  Found $actual instances"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Check if pattern A appears before pattern B
# Usage: assert_order "output" "pattern_a" "pattern_b" "test name"
assert_order() {
    local output="$1"
    local pattern_a="$2"
    local pattern_b="$3"
    local test_name="${4:-test}"

    local line_a=$(echo "$output" | grep -n "$pattern_a" | head -1 | cut -d: -f1)
    local line_b=$(echo "$output" | grep -n "$pattern_b" | head -1 | cut -d: -f1)

    if [ -z "$line_a" ]; then
        echo -e "  ${RED}[FAIL]${NC} $test_name"
        echo "  Pattern A not found: $pattern_a"
        ((TESTS_FAILED++))
        return 1
    fi

    if [ -z "$line_b" ]; then
        echo -e "  ${RED}[FAIL]${NC} $test_name"
        echo "  Pattern B not found: $pattern_b"
        ((TESTS_FAILED++))
        return 1
    fi

    if [ "$line_a" -lt "$line_b" ]; then
        echo -e "  ${GREEN}[PASS]${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}[FAIL]${NC} $test_name"
        echo "  Expected '$pattern_a' (line $line_a) before '$pattern_b' (line $line_b)"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Check if file contains a pattern
# Usage: assert_file_contains "filepath" "pattern" "test name"
assert_file_contains() {
    local filepath="$1"
    local pattern="$2"
    local test_name="${3:-test}"

    if [ ! -f "$filepath" ]; then
        echo -e "  ${RED}[FAIL]${NC} $test_name"
        echo "  File not found: $filepath"
        ((TESTS_FAILED++))
        return 1
    fi

    if grep -q "$pattern" "$filepath"; then
        echo -e "  ${GREEN}[PASS]${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}[FAIL]${NC} $test_name"
        echo "  Expected to find: $pattern"
        echo "  In file: $filepath"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Check if JSON output contains a skill invocation
# Usage: assert_skill_invoked "json_file" "skill_name" "test name"
assert_skill_invoked() {
    local json_file="$1"
    local skill_name="$2"
    local test_name="${3:-test}"

    if grep -q '"name":"Skill"' "$json_file" && grep -q "\"skill\":\"$skill_name\"" "$json_file"; then
        echo -e "  ${GREEN}[PASS]${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}[FAIL]${NC} $test_name"
        echo "  Expected Skill tool invocation with skill: $skill_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Check if JSON output contains a tool invocation
# Usage: assert_tool_invoked "json_file" "tool_name" "test name"
assert_tool_invoked() {
    local json_file="$1"
    local tool_name="$2"
    local test_name="${3:-test}"

    if grep -q "\"name\":\"$tool_name\"" "$json_file"; then
        echo -e "  ${GREEN}[PASS]${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}[FAIL]${NC} $test_name"
        echo "  Expected tool invocation: $tool_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Equality check
# Usage: assert_equals "actual" "expected" "test name"
assert_equals() {
    local actual="$1"
    local expected="$2"
    local test_name="${3:-test}"

    if [ "$actual" = "$expected" ]; then
        echo -e "  ${GREEN}[PASS]${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "  ${RED}[FAIL]${NC} $test_name"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Create a temporary test project directory
# Usage: test_project=$(create_test_project)
create_test_project() {
    local test_dir=$(mktemp -d)
    # Initialize git repo
    cd "$test_dir"
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test User"
    echo "$test_dir"
}

# Cleanup test project
# Usage: cleanup_test_project "$test_dir"
cleanup_test_project() {
    local test_dir="$1"
    if [ -d "$test_dir" ]; then
        rm -rf "$test_dir"
    fi
}

# Print test summary
# Usage: print_summary
print_summary() {
    echo ""
    echo "================================"
    echo "Test Summary"
    echo "================================"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo "================================"

    if [ $TESTS_FAILED -gt 0 ]; then
        return 1
    else
        return 0
    fi
}

# Start a test suite
# Usage: start_suite "Suite Name"
start_suite() {
    local suite_name="$1"
    echo ""
    echo "================================"
    echo "Test Suite: $suite_name"
    echo "================================"
}

# Analyze token usage from JSON output
# Usage: analyze_tokens "json_file"
analyze_tokens() {
    local json_file="$1"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [ -f "$script_dir/analyze-token-usage.py" ]; then
        python3 "$script_dir/analyze-token-usage.py" "$json_file"
    else
        echo "Warning: analyze-token-usage.py not found"
    fi
}

# Export functions for use in tests
export -f run_claude
export -f run_claude_json
export -f assert_contains
export -f assert_not_contains
export -f assert_count
export -f assert_order
export -f assert_file_contains
export -f assert_skill_invoked
export -f assert_tool_invoked
export -f assert_equals
export -f create_test_project
export -f cleanup_test_project
export -f print_summary
export -f start_suite
export -f setup_test_output
export -f analyze_tokens

# Export color codes
export RED GREEN YELLOW BLUE NC
export TESTS_PASSED TESTS_FAILED
