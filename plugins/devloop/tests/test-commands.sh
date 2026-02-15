#!/usr/bin/env bash
# Smoke tests for devloop commands
# Validates that commands have valid structure and frontmatter

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

start_suite "Command Smoke Tests"

echo ""
echo "Checking commands for valid structure..."
echo ""

# Track results
ERRORS=0
CHECKED=0

# Validate command file structure
check_command_structure() {
    local file="$1"
    local filename=$(basename "$file")
    local has_error=false
    local errors=()

    # Check frontmatter exists (starts with ---)
    if ! head -1 "$file" | grep -q "^---$"; then
        has_error=true
        errors+=("Missing YAML frontmatter (file should start with ---)")
    fi

    # Check for description field
    if ! grep -q "^description:" "$file"; then
        has_error=true
        errors+=("Missing 'description:' in frontmatter")
    fi

    # Check for closing frontmatter
    if ! awk 'NR>1 && /^---$/{found=1} END{exit !found}' "$file"; then
        has_error=true
        errors+=("Frontmatter not properly closed (missing second ---)")
    fi

    # Check for allowed-tools (optional but common)
    # Not an error if missing, just informational

    # Check for markdown heading
    if ! grep -q "^#" "$file"; then
        has_error=true
        errors+=("Missing markdown heading (# Title)")
    fi

    if [ "$has_error" = true ]; then
        echo -e "  ${RED}[FAIL]${NC} $filename"
        for err in "${errors[@]}"; do
            echo "       - $err"
        done
        ((ERRORS++)) || true
    else
        # Get description for info
        local desc=$(grep "^description:" "$file" | sed 's/description: *//' | head -1)
        echo -e "  ${GREEN}[PASS]${NC} $filename"
        echo "       Description: $desc"
        ((TESTS_PASSED++)) || true
    fi
}

# Check all command files
if [ -d "$PLUGIN_DIR/commands" ]; then
    for file in "$PLUGIN_DIR/commands"/*.md; do
        [ -f "$file" ] || continue
        ((CHECKED++)) || true
        check_command_structure "$file"
    done
else
    echo -e "  ${RED}[FAIL]${NC} commands/ directory not found"
    ((ERRORS++)) || true
fi

# Summary
echo ""
echo "================================"
echo "Checked $CHECKED command files"
echo "================================"

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}FAILED: $ERRORS commands have structural issues${NC}"
    exit 1
else
    echo -e "${GREEN}All commands have valid structure!${NC}"
fi

print_summary
