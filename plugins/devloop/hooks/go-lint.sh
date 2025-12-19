#!/bin/bash
# go-lint.sh - PostToolUse hook for Go linting with golangci-lint
#
# Automatically lints Go files after Write/Edit operations
# Returns lint errors to Claude's context for fixing
#
# Requirements:
# - golangci-lint installed (silently skips if not)
# - jq for JSON parsing (falls back to basic output if not)

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract file path from tool input
# Works with Write, Edit, and MultiEdit tools
FILE=""
if command -v jq &> /dev/null; then
    FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
else
    # Fallback: basic grep for file_path
    FILE=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')
fi

# Only lint Go files
if [[ ! "$FILE" =~ \.go$ ]]; then
    exit 0
fi

# Check if golangci-lint is installed
if ! command -v golangci-lint &> /dev/null; then
    # Silent exit - don't bother users without the tool
    exit 0
fi

# Check if file still exists (might have been deleted)
if [[ ! -f "$FILE" ]]; then
    exit 0
fi

# Get the directory containing the file for proper Go module context
FILE_DIR=$(dirname "$FILE")

# Run golangci-lint on the specific file
# --fast: use only fast linters for quick feedback
# --out-format: plain text format
# 2>&1: capture both stdout and stderr
LINT_OUTPUT=$(cd "$FILE_DIR" && golangci-lint run --fast "$(basename "$FILE")" 2>&1 || true)

# No issues found
if [[ -z "$LINT_OUTPUT" ]]; then
    exit 0
fi

# Count the number of issues (lines containing file reference)
BASENAME=$(basename "$FILE")
ISSUE_COUNT=$(echo "$LINT_OUTPUT" | grep -c "$BASENAME:" || echo "0")

# If no actual issues (just noise), exit
if [[ "$ISSUE_COUNT" -eq 0 ]]; then
    exit 0
fi

# Format output for Claude's context
CONTEXT_MSG="## golangci-lint Results

Found $ISSUE_COUNT linting issue(s) in \`$FILE\`:

\`\`\`
$LINT_OUTPUT
\`\`\`

Please fix these issues before continuing. Run \`golangci-lint run $FILE\` to re-check."

# Return lint errors to context
if command -v jq &> /dev/null; then
    # Use jq for proper JSON escaping
    ESCAPED_CONTEXT=$(printf '%s' "$CONTEXT_MSG" | jq -Rs '.')
    cat <<EOF
{
  "decision": "warn",
  "systemMessage": "golangci-lint: $ISSUE_COUNT issue(s) in $(basename "$FILE")",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": $ESCAPED_CONTEXT
  }
}
EOF
else
    # Fallback: basic JSON output without context injection
    echo "{\"decision\": \"warn\", \"systemMessage\": \"golangci-lint: $ISSUE_COUNT issue(s) in $(basename "$FILE")\"}"
fi

exit 0
