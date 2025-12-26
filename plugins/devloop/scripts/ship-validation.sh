#!/usr/bin/env bash
#
# ship-validation.sh - DoD checklist and deployment readiness validation
#
# Usage: ship-validation.sh [--dod] [--tests] [--build] [--all]
#
# Options:
#   --dod     Run Definition of Done checks
#   --tests   Run test suite
#   --build   Run build verification
#   --all     Run all validations (default)
#
# Exit codes:
#   0 - All validations passed
#   1 - DoD validation failed
#   2 - Tests failed
#   3 - Build failed
#   10 - Invalid arguments
#
# Output format:
#   JSON object with validation results for parsing by commands

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default to all validations
RUN_DOD=false
RUN_TESTS=false
RUN_BUILD=false
RUN_ALL=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dod)
            RUN_DOD=true
            RUN_ALL=false
            shift
            ;;
        --tests)
            RUN_TESTS=true
            RUN_ALL=false
            shift
            ;;
        --build)
            RUN_BUILD=true
            RUN_ALL=false
            shift
            ;;
        --all)
            RUN_ALL=true
            shift
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        -h|--help)
            echo "Usage: ship-validation.sh [--dod] [--tests] [--build] [--all] [--json]"
            echo ""
            echo "Validates code is ready to ship."
            echo ""
            echo "Options:"
            echo "  --dod     Run Definition of Done checks"
            echo "  --tests   Run test suite"
            echo "  --build   Run build verification"
            echo "  --all     Run all validations (default)"
            echo "  --json    Output results as JSON"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 10
            ;;
    esac
done

# Enable all if --all
if [ "$RUN_ALL" = true ]; then
    RUN_DOD=true
    RUN_TESTS=true
    RUN_BUILD=true
fi

# Results tracking
DOD_PASSED=true
DOD_ISSUES=()
TESTS_PASSED=true
TEST_OUTPUT=""
BUILD_PASSED=true
BUILD_OUTPUT=""

# ============================================================================
# DoD Validation
# ============================================================================
validate_dod() {
    echo -e "${YELLOW}Running DoD validation...${NC}"

    local issues=()

    # Check for TODO/FIXME comments in staged files
    if git diff --cached --name-only 2>/dev/null | xargs grep -l -E '(TODO|FIXME|XXX|HACK)' 2>/dev/null; then
        issues+=("TODO/FIXME comments found in staged files")
    fi

    # Check for console.log/print/fmt.Print debug statements
    local debug_patterns="console\.log|fmt\.Print|print\(|debugger|binding\.pry"
    if git diff --cached --name-only 2>/dev/null | xargs grep -l -E "$debug_patterns" 2>/dev/null; then
        issues+=("Debug statements found (console.log, print, etc.)")
    fi

    # Check for hardcoded secrets patterns
    local secret_patterns="(password|secret|api_key|apikey|token).*=.*['\"][^'\"]{8,}"
    if git diff --cached 2>/dev/null | grep -iE "$secret_patterns" 2>/dev/null; then
        issues+=("Possible hardcoded secrets detected")
    fi

    # Check for large files (>1MB)
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            local size
            size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
            if [ "$size" -gt 1048576 ]; then
                issues+=("Large file detected: $file ($(numfmt --to=iec-i --suffix=B "$size" 2>/dev/null || echo "${size}B"))")
            fi
        fi
    done < <(git diff --cached --name-only 2>/dev/null)

    # Check for merge conflict markers
    if git diff --cached 2>/dev/null | grep -E "^[<>=]{7}" 2>/dev/null; then
        issues+=("Merge conflict markers found")
    fi

    # Check documentation exists for new functions/classes (basic heuristic)
    # This is a simple check - more sophisticated analysis would need language-specific parsing

    # Return results
    if [ ${#issues[@]} -eq 0 ]; then
        echo -e "${GREEN}DoD validation passed${NC}"
        DOD_PASSED=true
    else
        echo -e "${RED}DoD validation found issues:${NC}"
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
        DOD_PASSED=false
        DOD_ISSUES=("${issues[@]}")
    fi
}

# ============================================================================
# Test Verification
# ============================================================================
run_tests() {
    echo -e "${YELLOW}Running tests...${NC}"

    local test_cmd=""
    local test_result=0

    # Detect test framework and run
    if [ -f "package.json" ]; then
        # Node.js project
        if grep -q '"test"' package.json; then
            test_cmd="npm test"
        fi
    elif [ -f "go.mod" ]; then
        # Go project
        test_cmd="go test ./..."
    elif [ -f "pytest.ini" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        # Python project
        if command -v pytest &> /dev/null; then
            test_cmd="pytest"
        elif command -v python &> /dev/null; then
            test_cmd="python -m pytest"
        fi
    elif [ -f "pom.xml" ]; then
        # Java/Maven project
        test_cmd="mvn test"
    elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        # Java/Gradle project
        test_cmd="./gradlew test"
    elif [ -f "Cargo.toml" ]; then
        # Rust project
        test_cmd="cargo test"
    fi

    if [ -z "$test_cmd" ]; then
        echo -e "${YELLOW}No test framework detected, skipping tests${NC}"
        TESTS_PASSED=true
        TEST_OUTPUT="No test framework detected"
        return 0
    fi

    echo "Running: $test_cmd"
    TEST_OUTPUT=$($test_cmd 2>&1) || test_result=$?

    if [ $test_result -eq 0 ]; then
        echo -e "${GREEN}Tests passed${NC}"
        TESTS_PASSED=true
    else
        echo -e "${RED}Tests failed${NC}"
        TESTS_PASSED=false
    fi

    return $test_result
}

# ============================================================================
# Build Verification
# ============================================================================
verify_build() {
    echo -e "${YELLOW}Verifying build...${NC}"

    local build_cmd=""
    local build_result=0

    # Detect build system and run
    if [ -f "package.json" ]; then
        # Node.js project
        if grep -q '"build"' package.json; then
            build_cmd="npm run build"
        fi
    elif [ -f "go.mod" ]; then
        # Go project
        build_cmd="go build ./..."
    elif [ -f "pom.xml" ]; then
        # Java/Maven project
        build_cmd="mvn compile -DskipTests"
    elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        # Java/Gradle project
        build_cmd="./gradlew build -x test"
    elif [ -f "Cargo.toml" ]; then
        # Rust project
        build_cmd="cargo build"
    elif [ -f "Makefile" ]; then
        # Generic Makefile project
        build_cmd="make"
    fi

    if [ -z "$build_cmd" ]; then
        echo -e "${YELLOW}No build system detected, skipping build verification${NC}"
        BUILD_PASSED=true
        BUILD_OUTPUT="No build system detected"
        return 0
    fi

    echo "Running: $build_cmd"
    BUILD_OUTPUT=$($build_cmd 2>&1) || build_result=$?

    if [ $build_result -eq 0 ]; then
        echo -e "${GREEN}Build successful${NC}"
        BUILD_PASSED=true
    else
        echo -e "${RED}Build failed${NC}"
        BUILD_PASSED=false
    fi

    return $build_result
}

# ============================================================================
# Main
# ============================================================================
main() {
    local exit_code=0

    echo "========================================"
    echo "Ship Validation"
    echo "========================================"
    echo ""

    # Run requested validations
    if [ "$RUN_DOD" = true ]; then
        validate_dod || true  # Don't exit on failure, continue to collect all results
        echo ""
    fi

    if [ "$RUN_TESTS" = true ]; then
        run_tests || true
        echo ""
    fi

    if [ "$RUN_BUILD" = true ]; then
        verify_build || true
        echo ""
    fi

    # Summary
    echo "========================================"
    echo "Validation Summary"
    echo "========================================"

    if [ "$RUN_DOD" = true ]; then
        if [ "$DOD_PASSED" = true ]; then
            echo -e "DoD:    ${GREEN}PASS${NC}"
        else
            echo -e "DoD:    ${RED}FAIL${NC}"
            exit_code=1
        fi
    fi

    if [ "$RUN_TESTS" = true ]; then
        if [ "$TESTS_PASSED" = true ]; then
            echo -e "Tests:  ${GREEN}PASS${NC}"
        else
            echo -e "Tests:  ${RED}FAIL${NC}"
            [ $exit_code -eq 0 ] && exit_code=2
        fi
    fi

    if [ "$RUN_BUILD" = true ]; then
        if [ "$BUILD_PASSED" = true ]; then
            echo -e "Build:  ${GREEN}PASS${NC}"
        else
            echo -e "Build:  ${RED}FAIL${NC}"
            [ $exit_code -eq 0 ] && exit_code=3
        fi
    fi

    echo ""

    # JSON output if requested
    if [ "$JSON_OUTPUT" = true ]; then
        cat << EOF
{
  "dod": {
    "passed": $DOD_PASSED,
    "issues": [$(printf '"%s",' "${DOD_ISSUES[@]}" | sed 's/,$//' )]
  },
  "tests": {
    "passed": $TESTS_PASSED,
    "output": "$(echo "$TEST_OUTPUT" | head -20 | sed 's/"/\\"/g' | tr '\n' ' ')"
  },
  "build": {
    "passed": $BUILD_PASSED,
    "output": "$(echo "$BUILD_OUTPUT" | head -20 | sed 's/"/\\"/g' | tr '\n' ' ')"
  },
  "overall_passed": $([ $exit_code -eq 0 ] && echo "true" || echo "false")
}
EOF
    fi

    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}All validations passed! Ready to ship.${NC}"
    else
        echo -e "${RED}Some validations failed. Review issues before shipping.${NC}"
    fi

    return $exit_code
}

main "$@"
