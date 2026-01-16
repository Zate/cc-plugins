#!/usr/bin/env bash
# Main test runner for cc-plugins test suite
#
# Usage:
#   ./tests/run-tests.sh                    # Run fast tests only
#   ./tests/run-tests.sh --integration      # Include Claude Code integration tests
#   ./tests/run-tests.sh --explicit-skills  # Run explicit skill request tests
#   ./tests/run-tests.sh --skill-triggering # Run skill triggering tests
#   ./tests/run-tests.sh --all              # Run everything
#   ./tests/run-tests.sh --verbose          # Show verbose output
#   ./tests/run-tests.sh --test <name>      # Run specific test
#
# Test Categories:
#   - Fast: Structure validation, frontmatter checks (no Claude Code required)
#   - Integration: Tests requiring Claude Code CLI
#   - Explicit Skills: Tests that skills are invoked when explicitly named
#   - Skill Triggering: Tests that skills auto-detect from context

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "========================================"
echo " CC-Plugins Test Suite"
echo "========================================"
echo ""
echo "Repository: $REPO_ROOT"
echo "Test time: $(date)"
echo ""

# Parse command line arguments
RUN_INTEGRATION=false
RUN_EXPLICIT_SKILLS=false
RUN_SKILL_TRIGGERING=false
VERBOSE=false
SPECIFIC_TEST=""
RUN_ALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --integration|-i)
            RUN_INTEGRATION=true
            shift
            ;;
        --explicit-skills|-e)
            RUN_EXPLICIT_SKILLS=true
            shift
            ;;
        --skill-triggering|-s)
            RUN_SKILL_TRIGGERING=true
            shift
            ;;
        --all|-a)
            RUN_ALL=true
            RUN_INTEGRATION=true
            RUN_EXPLICIT_SKILLS=true
            RUN_SKILL_TRIGGERING=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --test|-t)
            SPECIFIC_TEST="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --integration, -i       Run integration tests (requires Claude Code)"
            echo "  --explicit-skills, -e   Run explicit skill request tests"
            echo "  --skill-triggering, -s  Run skill auto-triggering tests"
            echo "  --all, -a              Run all tests"
            echo "  --verbose, -v          Show verbose output"
            echo "  --test, -t NAME        Run only the specified test suite"
            echo "  --help, -h             Show this help"
            echo ""
            echo "Test Suites:"
            echo "  devloop                Plugin structure and command tests"
            echo "  explicit-skills        Explicit skill invocation tests"
            echo "  skill-triggering       Skill auto-detection tests"
            echo ""
            echo "Examples:"
            echo "  $0                     # Fast tests only"
            echo "  $0 --all               # Run everything"
            echo "  $0 -i -v               # Integration tests with verbose output"
            echo "  $0 -t devloop          # Just devloop plugin tests"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Track overall results
SUITES_PASSED=0
SUITES_FAILED=0
SUITES_SKIPPED=0

# Run a test suite
run_suite() {
    local suite_name="$1"
    local suite_script="$2"
    local requires_claude="${3:-false}"

    echo ""
    echo "========================================"
    echo " Suite: $suite_name"
    echo "========================================"

    if [ ! -f "$suite_script" ]; then
        echo -e "  ${YELLOW}[SKIP]${NC} Test script not found: $suite_script"
        SUITES_SKIPPED=$((SUITES_SKIPPED + 1))
        return 0
    fi

    if [ ! -x "$suite_script" ]; then
        chmod +x "$suite_script"
    fi

    # Check if Claude Code is available for integration tests
    if [ "$requires_claude" = "true" ]; then
        if ! command -v claude &> /dev/null; then
            echo -e "  ${YELLOW}[SKIP]${NC} Claude Code CLI not available"
            SUITES_SKIPPED=$((SUITES_SKIPPED + 1))
            return 0
        fi
    fi

    local start_time=$(date +%s)

    if [ "$VERBOSE" = true ]; then
        if bash "$suite_script"; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            echo ""
            echo -e "  ${GREEN}[PASS]${NC} $suite_name (${duration}s)"
            SUITES_PASSED=$((SUITES_PASSED + 1))
            return 0
        else
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            echo ""
            echo -e "  ${RED}[FAIL]${NC} $suite_name (${duration}s)"
            SUITES_FAILED=$((SUITES_FAILED + 1))
            return 1
        fi
    else
        if output=$(bash "$suite_script" 2>&1); then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            echo -e "  ${GREEN}[PASS]${NC} (${duration}s)"
            SUITES_PASSED=$((SUITES_PASSED + 1))
            return 0
        else
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            echo -e "  ${RED}[FAIL]${NC} (${duration}s)"
            echo ""
            echo "  Output:"
            echo "$output" | tail -50 | sed 's/^/    /'
            SUITES_FAILED=$((SUITES_FAILED + 1))
            return 1
        fi
    fi
}

# ========================================
# Fast Tests (no Claude Code required)
# ========================================

if [ -z "$SPECIFIC_TEST" ] || [ "$SPECIFIC_TEST" = "devloop" ]; then
    echo ""
    echo "----------------------------------------"
    echo " Fast Tests (no Claude Code required)"
    echo "----------------------------------------"

    # Devloop plugin tests
    if [ -f "$REPO_ROOT/plugins/devloop/tests/run-tests.sh" ]; then
        run_suite "Devloop Plugin" "$REPO_ROOT/plugins/devloop/tests/run-tests.sh" false
    fi
fi

# ========================================
# Integration Tests (require Claude Code)
# ========================================

if [ "$RUN_INTEGRATION" = true ]; then
    echo ""
    echo "----------------------------------------"
    echo " Integration Tests (require Claude Code)"
    echo "----------------------------------------"

    # Add integration test suites here as they are created
    echo -e "  ${YELLOW}[INFO]${NC} No integration tests defined yet"
fi

# ========================================
# Explicit Skill Request Tests
# ========================================

if [ "$RUN_EXPLICIT_SKILLS" = true ]; then
    if [ -z "$SPECIFIC_TEST" ] || [ "$SPECIFIC_TEST" = "explicit-skills" ]; then
        run_suite "Explicit Skill Requests" "$SCRIPT_DIR/explicit-skill-requests/run-all.sh" true
    fi
fi

# ========================================
# Skill Triggering Tests
# ========================================

if [ "$RUN_SKILL_TRIGGERING" = true ]; then
    if [ -z "$SPECIFIC_TEST" ] || [ "$SPECIFIC_TEST" = "skill-triggering" ]; then
        run_suite "Skill Triggering" "$SCRIPT_DIR/skill-triggering/run-all.sh" true
    fi
fi

# ========================================
# Summary
# ========================================

echo ""
echo "========================================"
echo " Test Results Summary"
echo "========================================"
echo ""
echo -e "  ${GREEN}Passed:${NC}  $SUITES_PASSED"
echo -e "  ${RED}Failed:${NC}  $SUITES_FAILED"
echo -e "  ${YELLOW}Skipped:${NC} $SUITES_SKIPPED"
echo ""

# Show what was skipped if not running all tests
if [ "$RUN_ALL" = false ]; then
    SKIPPED_ITEMS=()
    if [ "$RUN_INTEGRATION" = false ]; then
        SKIPPED_ITEMS+=("Integration tests (use --integration)")
    fi
    if [ "$RUN_EXPLICIT_SKILLS" = false ]; then
        SKIPPED_ITEMS+=("Explicit skill tests (use --explicit-skills)")
    fi
    if [ "$RUN_SKILL_TRIGGERING" = false ]; then
        SKIPPED_ITEMS+=("Skill triggering tests (use --skill-triggering)")
    fi

    if [ ${#SKIPPED_ITEMS[@]} -gt 0 ]; then
        echo "Note: Some test suites were not run:"
        for item in "${SKIPPED_ITEMS[@]}"; do
            echo "  - $item"
        done
        echo ""
        echo "Use --all to run everything."
        echo ""
    fi
fi

# Show session output info for Claude tests
if [ "$RUN_EXPLICIT_SKILLS" = true ] || [ "$RUN_SKILL_TRIGGERING" = true ]; then
    LATEST_OUTPUT=$(ls -1td /tmp/cc-plugins-tests/*/ 2>/dev/null | head -1)
    if [ -n "$LATEST_OUTPUT" ]; then
        SESSION_COUNT=$(find "$LATEST_OUTPUT" -name "claude-output.json" 2>/dev/null | wc -l)
        if [ "$SESSION_COUNT" -gt 0 ]; then
            echo "Session files saved to: $LATEST_OUTPUT"
            echo "  ($SESSION_COUNT session files)"
            echo ""
            echo "To analyze token usage:"
            echo "  ./tests/claude-code/analyze-all-sessions.sh"
            echo "  ./tests/claude-code/analyze-all-sessions.sh --json"
            echo ""
        fi
    fi
fi

if [ $SUITES_FAILED -gt 0 ]; then
    echo "STATUS: FAILED"
    exit 1
else
    echo "STATUS: PASSED"
    exit 0
fi
