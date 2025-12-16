#!/bin/bash
#
# Security Guard - Fast Security Validation Script
# Used by hooks for real-time security checks on code changes
#
# Usage: validate-security.sh [file_path] [--quick|--full]
#
# Exit codes:
#   0 - No issues found
#   1 - Critical security issues (block)
#   2 - High severity issues (warn)
#   3 - Medium severity issues (info)
#

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track findings
CRITICAL_COUNT=0
HIGH_COUNT=0
MEDIUM_COUNT=0
FINDINGS=()

# Validate file path - reject paths with dangerous characters
validate_file_path() {
    local file="$1"

    # Reject empty paths
    [[ -z "$file" ]] && return 1

    # Reject paths containing shell metacharacters or control characters
    # Allow: alphanumeric, /, ., -, _, space (common in paths)
    if [[ "$file" =~ [\$\`\|\;\&\<\>\!\(\)\{\}\[\]\'\"] ]] || [[ "$file" =~ [[:cntrl:]] ]]; then
        echo "Warning: Skipping file with suspicious characters: ${file:0:50}..." >&2
        return 1
    fi

    # Reject paths that look like command injection attempts
    if [[ "$file" == *'$('* ]] || [[ "$file" == *'`'* ]]; then
        echo "Warning: Skipping file with command substitution pattern" >&2
        return 1
    fi

    return 0
}

# Helper function to escape JSON strings
json_escape() {
    local str="$1"
    # Escape backslashes, quotes, and control characters for JSON
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    str="${str//$'\n'/\\n}"
    str="${str//$'\r'/\\r}"
    str="${str//$'\t'/\\t}"
    printf '%s' "$str"
}

# Helper function to add finding
add_finding() {
    local severity="$1"
    local message="$2"
    local file="$3"
    local line="${4:-}"

    local location=""
    if [[ -n "$line" ]]; then
        location="$file:$line"
    else
        location="$file"
    fi

    # Sanitize for safe storage
    local sanitized_msg
    sanitized_msg=$(json_escape "$message")
    local sanitized_loc
    sanitized_loc=$(json_escape "$location")

    FINDINGS+=("[$severity] $sanitized_msg ($sanitized_loc)")

    case "$severity" in
        CRITICAL) ((CRITICAL_COUNT++)) || true ;;
        HIGH) ((HIGH_COUNT++)) || true ;;
        MEDIUM) ((MEDIUM_COUNT++)) || true ;;
    esac
}

# Check for hardcoded secrets
check_secrets() {
    local file="$1"

    # API Keys (generic patterns)
    if grep -nE "(api[_-]?key|apikey)\s*[:=]\s*['\"][a-zA-Z0-9]{16,}['\"]" "$file" 2>/dev/null; then
        while IFS=: read -r line_num content; do
            add_finding "CRITICAL" "Hardcoded API key detected" "$file" "$line_num"
        done < <(grep -nE "(api[_-]?key|apikey)\s*[:=]\s*['\"][a-zA-Z0-9]{16,}['\"]" "$file" 2>/dev/null || true)
    fi

    # AWS Keys
    if grep -nE "AKIA[A-Z0-9]{16}" "$file" 2>/dev/null; then
        while IFS=: read -r line_num content; do
            add_finding "CRITICAL" "AWS access key detected" "$file" "$line_num"
        done < <(grep -nE "AKIA[A-Z0-9]{16}" "$file" 2>/dev/null || true)
    fi

    # Private Keys
    if grep -n "BEGIN.*PRIVATE KEY" "$file" 2>/dev/null; then
        while IFS=: read -r line_num content; do
            add_finding "CRITICAL" "Private key detected" "$file" "$line_num"
        done < <(grep -n "BEGIN.*PRIVATE KEY" "$file" 2>/dev/null || true)
    fi

    # Password assignments (excluding common false positives)
    if grep -nEi "(password|passwd|pwd)\s*[:=]\s*['\"][^'\"]{8,}['\"]" "$file" 2>/dev/null | grep -vE "(example|placeholder|your[_-]?password|changeme|test)" 2>/dev/null; then
        while IFS=: read -r line_num content; do
            add_finding "HIGH" "Hardcoded password detected" "$file" "$line_num"
        done < <(grep -nEi "(password|passwd|pwd)\s*[:=]\s*['\"][^'\"]{8,}['\"]" "$file" 2>/dev/null | grep -vE "(example|placeholder|your[_-]?password|changeme|test)" 2>/dev/null || true)
    fi
}

# Check for SQL injection patterns
check_sql_injection() {
    local file="$1"
    local ext="${file##*.}"

    case "$ext" in
        py)
            # Python f-string SQL
            if grep -nE 'f["\']SELECT|f["\']INSERT|f["\']UPDATE|f["\']DELETE' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "CRITICAL" "SQL injection risk - f-string in SQL query" "$file" "$line_num"
                done < <(grep -nE 'f["\']SELECT|f["\']INSERT|f["\']UPDATE|f["\']DELETE' "$file" 2>/dev/null || true)
            fi

            # Python % formatting in SQL
            if grep -nE '(SELECT|INSERT|UPDATE|DELETE).*%\s*\(' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "CRITICAL" "SQL injection risk - string formatting in query" "$file" "$line_num"
                done < <(grep -nE '(SELECT|INSERT|UPDATE|DELETE).*%\s*\(' "$file" 2>/dev/null || true)
            fi
            ;;
        js|ts|jsx|tsx)
            # Template literal SQL
            if grep -nE '\`SELECT.*\$\{|\`INSERT.*\$\{|\`UPDATE.*\$\{|\`DELETE.*\$\{' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "CRITICAL" "SQL injection risk - template literal in SQL query" "$file" "$line_num"
                done < <(grep -nE '\`SELECT.*\$\{|\`INSERT.*\$\{|\`UPDATE.*\$\{|\`DELETE.*\$\{' "$file" 2>/dev/null || true)
            fi
            ;;
        java)
            # String concatenation in SQL
            if grep -nE '"SELECT.*"\s*\+|"INSERT.*"\s*\+|"UPDATE.*"\s*\+|"DELETE.*"\s*\+' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "CRITICAL" "SQL injection risk - string concatenation in query" "$file" "$line_num"
                done < <(grep -nE '"SELECT.*"\s*\+|"INSERT.*"\s*\+|"UPDATE.*"\s*\+|"DELETE.*"\s*\+' "$file" 2>/dev/null || true)
            fi
            ;;
        go)
            # fmt.Sprintf in SQL
            if grep -nE 'fmt\.Sprintf.*SELECT|fmt\.Sprintf.*INSERT' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "CRITICAL" "SQL injection risk - fmt.Sprintf in SQL query" "$file" "$line_num"
                done < <(grep -nE 'fmt\.Sprintf.*SELECT|fmt\.Sprintf.*INSERT' "$file" 2>/dev/null || true)
            fi
            ;;
    esac
}

# Check for command injection patterns
check_command_injection() {
    local file="$1"
    local ext="${file##*.}"

    case "$ext" in
        py)
            # shell=True with potential user input
            if grep -n 'shell\s*=\s*True' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "HIGH" "Command injection risk - shell=True detected" "$file" "$line_num"
                done < <(grep -n 'shell\s*=\s*True' "$file" 2>/dev/null || true)
            fi

            # os.system with f-string or format
            if grep -nE 'os\.system\s*\(.*f["\']|os\.system\s*\(.*%' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "CRITICAL" "Command injection risk - os.system with user input" "$file" "$line_num"
                done < <(grep -nE 'os\.system\s*\(.*f["\']|os\.system\s*\(.*%' "$file" 2>/dev/null || true)
            fi
            ;;
        js|ts)
            # exec with template literals or concatenation
            if grep -nE 'exec\s*\(.*\$\{|exec\s*\(.*\+' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "CRITICAL" "Command injection risk - exec with user input" "$file" "$line_num"
                done < <(grep -nE 'exec\s*\(.*\$\{|exec\s*\(.*\+' "$file" 2>/dev/null || true)
            fi
            ;;
        php)
            # system/exec with variables
            if grep -nE '(system|exec|shell_exec|passthru)\s*\(\s*\$' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "CRITICAL" "Command injection risk - shell function with variable" "$file" "$line_num"
                done < <(grep -nE '(system|exec|shell_exec|passthru)\s*\(\s*\$' "$file" 2>/dev/null || true)
            fi
            ;;
        rb)
            # Backticks or system with interpolation
            if grep -nE '\`.*#\{|system\s*\(.*#\{' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "CRITICAL" "Command injection risk - command with interpolation" "$file" "$line_num"
                done < <(grep -nE '\`.*#\{|system\s*\(.*#\{' "$file" 2>/dev/null || true)
            fi
            ;;
    esac
}

# Check for unsafe deserialization
check_deserialization() {
    local file="$1"
    local ext="${file##*.}"

    case "$ext" in
        py)
            # pickle.loads
            if grep -n 'pickle\.load' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "CRITICAL" "Unsafe deserialization - pickle.load detected" "$file" "$line_num"
                done < <(grep -n 'pickle\.load' "$file" 2>/dev/null || true)
            fi

            # yaml.load without SafeLoader
            if grep -n 'yaml\.load' "$file" 2>/dev/null | grep -v 'SafeLoader\|safe_load' 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "CRITICAL" "Unsafe deserialization - yaml.load without SafeLoader" "$file" "$line_num"
                done < <(grep -n 'yaml\.load' "$file" 2>/dev/null | grep -v 'SafeLoader\|safe_load' 2>/dev/null || true)
            fi
            ;;
        java)
            # ObjectInputStream
            if grep -n 'ObjectInputStream\|readObject()' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "HIGH" "Potential unsafe deserialization - ObjectInputStream detected" "$file" "$line_num"
                done < <(grep -n 'ObjectInputStream\|readObject()' "$file" 2>/dev/null || true)
            fi
            ;;
        php)
            # unserialize
            if grep -n 'unserialize\s*(\s*\$' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "CRITICAL" "Unsafe deserialization - unserialize with user input" "$file" "$line_num"
                done < <(grep -n 'unserialize\s*(\s*\$' "$file" 2>/dev/null || true)
            fi
            ;;
    esac
}

# Check for XSS patterns
check_xss() {
    local file="$1"
    local ext="${file##*.}"

    case "$ext" in
        js|ts|jsx|tsx)
            # innerHTML assignment
            if grep -n '\.innerHTML\s*=' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    # Skip if it looks like a static string
                    if ! echo "$content" | grep -qE '\.innerHTML\s*=\s*["\']<'; then
                        add_finding "HIGH" "XSS risk - innerHTML assignment" "$file" "$line_num"
                    fi
                done < <(grep -n '\.innerHTML\s*=' "$file" 2>/dev/null || true)
            fi

            # dangerouslySetInnerHTML
            if grep -n 'dangerouslySetInnerHTML' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "HIGH" "XSS risk - dangerouslySetInnerHTML usage" "$file" "$line_num"
                done < <(grep -n 'dangerouslySetInnerHTML' "$file" 2>/dev/null || true)
            fi

            # document.write
            if grep -n 'document\.write' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "HIGH" "XSS risk - document.write usage" "$file" "$line_num"
                done < <(grep -n 'document\.write' "$file" 2>/dev/null || true)
            fi

            # eval
            if grep -n 'eval\s*(' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "CRITICAL" "Code injection risk - eval() detected" "$file" "$line_num"
                done < <(grep -n 'eval\s*(' "$file" 2>/dev/null || true)
            fi
            ;;
    esac
}

# Check for weak cryptography
check_weak_crypto() {
    local file="$1"
    local ext="${file##*.}"

    case "$ext" in
        py)
            # MD5/SHA1 for security
            if grep -nE 'hashlib\.(md5|sha1)\s*\(' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "HIGH" "Weak cryptography - MD5/SHA1 detected (use SHA-256+ or bcrypt)" "$file" "$line_num"
                done < <(grep -nE 'hashlib\.(md5|sha1)\s*\(' "$file" 2>/dev/null || true)
            fi

            # random module for security
            if grep -nE 'random\.(choice|randint|random)\s*\(' "$file" 2>/dev/null | grep -iE 'token|key|secret|session|password' 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "HIGH" "Insecure randomness - use secrets module for security tokens" "$file" "$line_num"
                done < <(grep -nE 'random\.(choice|randint|random)\s*\(' "$file" 2>/dev/null | grep -iE 'token|key|secret|session|password' 2>/dev/null || true)
            fi
            ;;
        js|ts)
            # Math.random for security
            if grep -n 'Math\.random' "$file" 2>/dev/null | grep -iE 'token|key|secret|session|id' 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "HIGH" "Insecure randomness - use crypto.randomBytes for security" "$file" "$line_num"
                done < <(grep -n 'Math\.random' "$file" 2>/dev/null | grep -iE 'token|key|secret|session|id' 2>/dev/null || true)
            fi

            # MD5/SHA1
            if grep -nE "createHash\s*\(\s*['\"]md5|createHash\s*\(\s*['\"]sha1" "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "HIGH" "Weak cryptography - MD5/SHA1 detected" "$file" "$line_num"
                done < <(grep -nE "createHash\s*\(\s*['\"]md5|createHash\s*\(\s*['\"]sha1" "$file" 2>/dev/null || true)
            fi
            ;;
        java)
            # MD5/SHA1
            if grep -nE 'getInstance\s*\(\s*"MD5|getInstance\s*\(\s*"SHA-?1' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "HIGH" "Weak cryptography - MD5/SHA1 detected" "$file" "$line_num"
                done < <(grep -nE 'getInstance\s*\(\s*"MD5|getInstance\s*\(\s*"SHA-?1' "$file" 2>/dev/null || true)
            fi
            ;;
        go)
            # crypto/md5, crypto/sha1
            if grep -n 'crypto/md5\|crypto/sha1' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "HIGH" "Weak cryptography - MD5/SHA1 import detected" "$file" "$line_num"
                done < <(grep -n 'crypto/md5\|crypto/sha1' "$file" 2>/dev/null || true)
            fi
            ;;
    esac
}

# Check for TLS verification disabled
check_tls() {
    local file="$1"
    local ext="${file##*.}"

    case "$ext" in
        py)
            if grep -n 'verify\s*=\s*False' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "HIGH" "TLS verification disabled" "$file" "$line_num"
                done < <(grep -n 'verify\s*=\s*False' "$file" 2>/dev/null || true)
            fi
            ;;
        js|ts)
            if grep -n 'rejectUnauthorized.*false' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "HIGH" "TLS verification disabled" "$file" "$line_num"
                done < <(grep -n 'rejectUnauthorized.*false' "$file" 2>/dev/null || true)
            fi
            if grep -n 'NODE_TLS_REJECT_UNAUTHORIZED.*0' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "HIGH" "TLS verification disabled via environment" "$file" "$line_num"
                done < <(grep -n 'NODE_TLS_REJECT_UNAUTHORIZED.*0' "$file" 2>/dev/null || true)
            fi
            ;;
        go)
            if grep -n 'InsecureSkipVerify.*true' "$file" 2>/dev/null; then
                while IFS=: read -r line_num content; do
                    add_finding "HIGH" "TLS verification disabled" "$file" "$line_num"
                done < <(grep -n 'InsecureSkipVerify.*true' "$file" 2>/dev/null || true)
            fi
            ;;
    esac
}

# Check for debug mode in production-like files
check_debug_mode() {
    local file="$1"
    local filename=$(basename "$file")

    # Skip obvious test/dev files
    if echo "$filename" | grep -qiE 'test|spec|dev|local|example'; then
        return
    fi

    # Check for DEBUG = True in config-like files
    if echo "$filename" | grep -qiE 'settings|config|app'; then
        if grep -n 'DEBUG\s*=\s*True' "$file" 2>/dev/null; then
            while IFS=: read -r line_num content; do
                add_finding "MEDIUM" "Debug mode enabled in config file" "$file" "$line_num"
            done < <(grep -n 'DEBUG\s*=\s*True' "$file" 2>/dev/null || true)
        fi
    fi
}

# Main scanning function
scan_file() {
    local file="$1"

    # Validate file path for security (prevent command injection via filenames)
    if ! validate_file_path "$file"; then
        return
    fi

    # Skip non-existent files
    [[ ! -f "$file" ]] && return

    # Skip binary files using MIME type detection (more reliable than 'file' text output)
    local mime_type
    if mime_type=$(file -b --mime-type -- "$file" 2>/dev/null); then
        case "$mime_type" in
            application/octet-stream|application/x-executable|application/x-mach-binary|image/*|audio/*|video/*)
                return
                ;;
        esac
    fi

    # Skip test files in quick mode
    if [[ "$MODE" == "quick" ]]; then
        if [[ "$file" =~ (test|spec|mock|fixture|__test__|\.test\.|_test\.) ]]; then
            return
        fi
    fi

    # Get file extension
    local ext="${file##*.}"

    # Skip non-code files
    case "$ext" in
        py|js|ts|jsx|tsx|java|go|rb|php|cs|sh|yaml|yml|json|env) ;;
        *) return ;;
    esac

    # Run all checks
    check_secrets "$file"
    check_sql_injection "$file"
    check_command_injection "$file"
    check_deserialization "$file"
    check_xss "$file"
    check_weak_crypto "$file"
    check_tls "$file"
    check_debug_mode "$file"
}

# Output results
output_results() {
    if [[ ${#FINDINGS[@]} -eq 0 ]]; then
        echo '{"status": "clean", "message": "No security issues found"}'
        exit 0
    fi

    # Output summary
    echo "{"
    echo "  \"status\": \"issues_found\","
    echo "  \"summary\": {"
    echo "    \"critical\": $CRITICAL_COUNT,"
    echo "    \"high\": $HIGH_COUNT,"
    echo "    \"medium\": $MEDIUM_COUNT"
    echo "  },"
    echo "  \"findings\": ["

    local first=true
    for finding in "${FINDINGS[@]}"; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo ","
        fi
        echo -n "    \"$finding\""
    done

    echo ""
    echo "  ]"
    echo "}"

    # Exit with appropriate code
    if [[ $CRITICAL_COUNT -gt 0 ]]; then
        exit 1  # Block
    elif [[ $HIGH_COUNT -gt 0 ]]; then
        exit 2  # Warn
    else
        exit 3  # Info
    fi
}

# Parse arguments
MODE="quick"
FILES=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --quick)
            MODE="quick"
            shift
            ;;
        --full)
            MODE="full"
            shift
            ;;
        --help|-h)
            echo "Usage: validate-security.sh [file_path...] [--quick|--full]"
            echo ""
            echo "Options:"
            echo "  --quick    Skip test files, use fast patterns (default)"
            echo "  --full     Scan all files with all patterns"
            echo ""
            echo "Exit codes:"
            echo "  0 - No issues found"
            echo "  1 - Critical security issues (block)"
            echo "  2 - High severity issues (warn)"
            echo "  3 - Medium severity issues (info)"
            exit 0
            ;;
        *)
            FILES+=("$1")
            shift
            ;;
    esac
done

# Scan files
if [[ ${#FILES[@]} -eq 0 ]]; then
    # No files specified, scan current directory
    while IFS= read -r -d '' file; do
        scan_file "$file"
    done < <(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.java" -o -name "*.go" -o -name "*.rb" -o -name "*.php" \) -print0 2>/dev/null)
else
    # Scan specified files
    for file in "${FILES[@]}"; do
        scan_file "$file"
    done
fi

# Output results
output_results
