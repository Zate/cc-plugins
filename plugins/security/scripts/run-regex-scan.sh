#!/bin/bash
set -euo pipefail

# run-regex-scan.sh — Zero-dependency regex scanner using patterns from data/regex-patterns.json.
# Usage: run-regex-scan.sh [directory] [output_file]
# Output: JSON array of findings (to stdout or output_file).

SCAN_DIR="${1:-.}"
OUTPUT_FILE="${2:-}"
FILES_JSON=""
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Parse optional --files arg from remaining args
shift 2 2>/dev/null || true
while [ $# -gt 0 ]; do
    case "$1" in
        --files) FILES_JSON="$2"; shift 2 ;;
        *) shift ;;
    esac
done
PATTERNS_FILE="$SCRIPT_DIR/../data/regex-patterns.json"

if [ ! -f "$PATTERNS_FILE" ]; then
    echo "Error: Patterns file not found at $PATTERNS_FILE" >&2
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required for regex scanning" >&2
    exit 1
fi

SCAN_DIR=$(cd "$SCAN_DIR" && pwd)

# File extension to language mapping
ext_lang() {
    case "$1" in
        py)         echo "python" ;;
        js|jsx)     echo "javascript" ;;
        ts|tsx)     echo "typescript" ;;
        go)         echo "go" ;;
        rb)         echo "ruby" ;;
        java)       echo "java" ;;
        php)        echo "php" ;;
        sh|bash)    echo "shell" ;;
        pl|pm)      echo "perl" ;;
        rs)         echo "rust" ;;
        cs)         echo "csharp" ;;
        c|h)        echo "c" ;;
        cpp|hpp)    echo "cpp" ;;
        *)          echo "unknown" ;;
    esac
}

# Build grep include patterns for source files
SOURCE_INCLUDES=(
    --include='*.py' --include='*.js' --include='*.ts' --include='*.tsx' --include='*.jsx'
    --include='*.go' --include='*.rb' --include='*.java' --include='*.php'
    --include='*.sh' --include='*.bash' --include='*.c' --include='*.cpp' --include='*.h'
    --include='*.cs' --include='*.rs' --include='*.pl' --include='*.kt' --include='*.swift'
    --include='*.yml' --include='*.yaml' --include='*.json' --include='*.toml' --include='*.cfg'
    --include='*.ini' --include='*.env' --include='*.conf'
)

EXCLUDE_DIRS=(
    --exclude-dir=node_modules --exclude-dir=vendor --exclude-dir=.git
    --exclude-dir=__pycache__ --exclude-dir=dist --exclude-dir=build
    --exclude-dir=.venv --exclude-dir=venv --exclude-dir=.tox
    --exclude-dir=.mypy_cache --exclude-dir=.pytest_cache
)

# Read pattern count
pattern_count=$(jq 'length' "$PATTERNS_FILE")

findings="[]"

for i in $(seq 0 $((pattern_count - 1))); do
    # Extract pattern info
    p_id=$(jq -r ".[$i].id" "$PATTERNS_FILE")
    p_pattern=$(jq -r ".[$i].pattern" "$PATTERNS_FILE")
    p_severity=$(jq -r ".[$i].severity" "$PATTERNS_FILE")
    p_category=$(jq -r ".[$i].category" "$PATTERNS_FILE")
    p_cwe=$(jq -r ".[$i].cwe" "$PATTERNS_FILE")
    p_description=$(jq -r ".[$i].description" "$PATTERNS_FILE")
    p_languages=$(jq -r ".[$i].languages" "$PATTERNS_FILE")

    # Run grep, capture matches
    while IFS=: read -r file line match_text; do
        # Skip empty lines
        [ -z "$file" ] && continue

        # Make file path relative to scan dir
        rel_file="${file#$SCAN_DIR/}"

        # Check language applicability if not "all"
        if [ "$p_languages" != "all" ]; then
            file_ext="${rel_file##*.}"
            file_lang=$(ext_lang "$file_ext")
            if ! echo "$p_languages" | jq -e "index(\"$file_lang\")" &>/dev/null; then
                continue
            fi
        fi

        # Sanitize match text for JSON (escape special chars)
        safe_match=$(echo "$match_text" | head -c 200 | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g' | tr -d '\n\r')

        findings=$(echo "$findings" | jq \
            --arg pid "$p_id" \
            --arg file "$rel_file" \
            --arg line "$line" \
            --arg match "$safe_match" \
            --arg severity "$p_severity" \
            --arg category "$p_category" \
            --arg cwe "$p_cwe" \
            --arg desc "$p_description" \
            '. + [{
                "pattern_id": $pid,
                "file": $file,
                "line": ($line | tonumber),
                "match": $match,
                "severity": $severity,
                "category": $category,
                "cwe": $cwe,
                "description": $desc
            }]')
    done < <(
        if [ -n "$FILES_JSON" ] && [ -f "$FILES_JSON" ]; then
            # Diff mode: grep only changed files
            jq -r '.files[]' "$FILES_JSON" | while read -r f; do
                [ -f "$f" ] && grep -nE "$p_pattern" "$f" 2>/dev/null | sed "s|^|$f:|" || true
            done
        else
            grep -rnE "$p_pattern" "$SCAN_DIR" \
                "${SOURCE_INCLUDES[@]}" "${EXCLUDE_DIRS[@]}" 2>/dev/null || true
        fi
    )
done

# Sort by severity: CRITICAL > HIGH > MEDIUM > LOW
severity_order='{"CRITICAL":0,"HIGH":1,"MEDIUM":2,"LOW":3}'
result=$(echo "$findings" | jq --argjson order "$severity_order" \
    'sort_by($order[.severity] // 99)')

if [ -n "$OUTPUT_FILE" ]; then
    echo "$result" > "$OUTPUT_FILE"
    count=$(echo "$result" | jq 'length')
    echo "regex-scan: $count findings written to $OUTPUT_FILE" >&2
else
    echo "$result"
fi
