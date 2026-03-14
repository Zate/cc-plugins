#!/bin/bash
set -euo pipefail

# run-scanners.sh — Orchestrate available security scanning tools.
# Usage: run-scanners.sh [output_directory] [--files changed-files.json]
# Output: Summary JSON to stdout. Tool artifacts written to output_directory.

OUTPUT_DIR="${1:-.security/artifacts}"
FILES_JSON=""

# Parse optional --files arg
shift || true
while [ $# -gt 0 ]; do
    case "$1" in
        --files) FILES_JSON="$2"; shift 2 ;;
        *) shift ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$OUTPUT_DIR"

# If diff mode, build file list for tools that support it
SCAN_PATHS="."
SEMGREP_PATHS=""
if [ -n "$FILES_JSON" ] && [ -f "$FILES_JSON" ]; then
    file_count=$(jq '.count // 0' "$FILES_JSON")
    if [ "$file_count" -eq 0 ]; then
        echo '{"scan_time_seconds":0,"tools":{},"total_raw_findings":0,"diff_mode":true,"changed_files":0}' | jq '.'
        exit 0
    fi
    # Build space-separated file list for semgrep
    SEMGREP_PATHS=$(jq -r '.files[]' "$FILES_JSON" | tr '\n' ' ')
    echo "scanner: diff mode, scanning $file_count changed files" >&2
fi

# Detect available tools
tools_json=$("$SCRIPT_DIR/detect-tools.sh")

tool_available() {
    echo "$tools_json" | jq -r ".tools.${1}.available" 2>/dev/null
}

# Detect project languages for conditional scanners
has_python=false
has_go=false
if find . -maxdepth 3 -name '*.py' -not -path '*/node_modules/*' -not -path '*/.git/*' -print -quit 2>/dev/null | grep -q .; then
    has_python=true
fi
if [ -f "go.mod" ] || find . -maxdepth 3 -name '*.go' -not -path '*/vendor/*' -not -path '*/.git/*' -print -quit 2>/dev/null | grep -q .; then
    has_go=true
fi

# Track results
declare -A tool_ran
declare -A tool_findings
declare -A tool_time
declare -A tool_error
total_start=$(date +%s)

# --- Semgrep ---
if [ "$(tool_available semgrep)" = "true" ]; then
    echo "scanner: running semgrep..." >&2
    start=$(date +%s)
    semgrep_target="."
    if [ -n "$SEMGREP_PATHS" ]; then
        semgrep_target="$SEMGREP_PATHS"
    fi
    if semgrep scan \
        --config auto \
        --config p/owasp-top-ten \
        --sarif \
        --output "$OUTPUT_DIR/semgrep.sarif.json" \
        --quiet \
        --no-git-ignore \
        --timeout 300 \
        $semgrep_target 2>/dev/null; then
        tool_ran[semgrep]=true
        count=$(jq '[.runs[].results[]] | length' "$OUTPUT_DIR/semgrep.sarif.json" 2>/dev/null || echo 0)
        tool_findings[semgrep]=$count
    else
        tool_ran[semgrep]=true
        tool_error[semgrep]="non-zero exit (may still have partial results)"
        if [ -f "$OUTPUT_DIR/semgrep.sarif.json" ]; then
            count=$(jq '[.runs[].results[]] | length' "$OUTPUT_DIR/semgrep.sarif.json" 2>/dev/null || echo 0)
            tool_findings[semgrep]=$count
        else
            tool_findings[semgrep]=0
        fi
    fi
    end=$(date +%s)
    tool_time[semgrep]=$((end - start))
else
    tool_ran[semgrep]=false
fi

# --- Gitleaks ---
if [ "$(tool_available gitleaks)" = "true" ]; then
    echo "scanner: running gitleaks..." >&2
    start=$(date +%s)
    # gitleaks exits 1 when findings exist, which is normal
    if gitleaks detect \
        --source . \
        --report-format json \
        --report-path "$OUTPUT_DIR/gitleaks.json" \
        --no-banner 2>/dev/null; then
        tool_ran[gitleaks]=true
        tool_findings[gitleaks]=0
    else
        tool_ran[gitleaks]=true
        if [ -f "$OUTPUT_DIR/gitleaks.json" ]; then
            count=$(jq 'length' "$OUTPUT_DIR/gitleaks.json" 2>/dev/null || echo 0)
            tool_findings[gitleaks]=$count
        else
            tool_findings[gitleaks]=0
            tool_error[gitleaks]="failed to produce output"
        fi
    fi
    end=$(date +%s)
    tool_time[gitleaks]=$((end - start))
else
    tool_ran[gitleaks]=false
fi

# --- Trivy ---
if [ "$(tool_available trivy)" = "true" ]; then
    echo "scanner: running trivy..." >&2
    start=$(date +%s)
    if trivy fs . \
        --format json \
        --output "$OUTPUT_DIR/trivy.json" \
        --scanners vuln,secret \
        --quiet 2>/dev/null; then
        tool_ran[trivy]=true
        count=$(jq '[.Results[]? | (.Vulnerabilities // [])[], (.Secrets // [])[]] | length' "$OUTPUT_DIR/trivy.json" 2>/dev/null || echo 0)
        tool_findings[trivy]=$count
    else
        tool_ran[trivy]=true
        tool_error[trivy]="non-zero exit"
        tool_findings[trivy]=0
    fi
    end=$(date +%s)
    tool_time[trivy]=$((end - start))
else
    tool_ran[trivy]=false
fi

# --- Bandit (Python only) ---
if [ "$(tool_available bandit)" = "true" ] && [ "$has_python" = true ]; then
    echo "scanner: running bandit..." >&2
    start=$(date +%s)
    # bandit exits 1 when findings exist
    if bandit -r . -f json -o "$OUTPUT_DIR/bandit.json" --quiet 2>/dev/null; then
        tool_ran[bandit]=true
        tool_findings[bandit]=0
    else
        tool_ran[bandit]=true
        if [ -f "$OUTPUT_DIR/bandit.json" ]; then
            count=$(jq '.results | length' "$OUTPUT_DIR/bandit.json" 2>/dev/null || echo 0)
            tool_findings[bandit]=$count
        else
            tool_findings[bandit]=0
            tool_error[bandit]="failed to produce output"
        fi
    fi
    end=$(date +%s)
    tool_time[bandit]=$((end - start))
else
    tool_ran[bandit]=false
fi

# --- gosec (Go only) ---
if [ "$(tool_available gosec)" = "true" ] && [ "$has_go" = true ]; then
    echo "scanner: running gosec..." >&2
    start=$(date +%s)
    # gosec exits non-zero when findings exist
    if gosec -fmt json -out "$OUTPUT_DIR/gosec.json" ./... 2>/dev/null; then
        tool_ran[gosec]=true
        tool_findings[gosec]=0
    else
        tool_ran[gosec]=true
        if [ -f "$OUTPUT_DIR/gosec.json" ]; then
            count=$(jq '.Issues | length' "$OUTPUT_DIR/gosec.json" 2>/dev/null || echo 0)
            tool_findings[gosec]=$count
        else
            tool_findings[gosec]=0
            tool_error[gosec]="failed to produce output"
        fi
    fi
    end=$(date +%s)
    tool_time[gosec]=$((end - start))
else
    tool_ran[gosec]=false
fi

# --- Always run regex scan as baseline ---
echo "scanner: running regex scan..." >&2
start=$(date +%s)
if [ -n "$FILES_JSON" ] && [ -f "$FILES_JSON" ]; then
    "$SCRIPT_DIR/run-regex-scan.sh" "." "$OUTPUT_DIR/regex-scan.json" --files "$FILES_JSON" 2>/dev/null || true
else
    "$SCRIPT_DIR/run-regex-scan.sh" "." "$OUTPUT_DIR/regex-scan.json" 2>/dev/null || true
fi
tool_ran[regex]=true
if [ -f "$OUTPUT_DIR/regex-scan.json" ]; then
    count=$(jq 'length' "$OUTPUT_DIR/regex-scan.json" 2>/dev/null || echo 0)
    tool_findings[regex]=$count
else
    tool_findings[regex]=0
fi
end=$(date +%s)
tool_time[regex]=$((end - start))

total_end=$(date +%s)
total_time=$((total_end - total_start))

# Build summary JSON
summary="{"
summary+="\"scan_time_seconds\":$total_time,"
summary+="\"tools\":{"

first=true
for tool in semgrep gitleaks trivy bandit gosec regex; do
    if [ "$first" = true ]; then first=false; else summary+=","; fi
    ran="${tool_ran[$tool]:-false}"
    findings="${tool_findings[$tool]:-0}"
    elapsed="${tool_time[$tool]:-0}"
    error="${tool_error[$tool]:-}"

    summary+="\"$tool\":{"
    summary+="\"ran\":$ran"
    summary+=",\"findings\":$findings"
    summary+=",\"elapsed_seconds\":$elapsed"
    if [ -n "$error" ]; then
        summary+=",\"error\":\"$error\""
    fi
    summary+="}"
done

summary+="},"

# Total findings
total=0
for tool in semgrep gitleaks trivy bandit gosec regex; do
    total=$((total + ${tool_findings[$tool]:-0}))
done
summary+="\"total_raw_findings\":$total"
summary+="}"

echo "$summary" | jq '.'

# Also save summary
echo "$summary" | jq '.' > "$OUTPUT_DIR/scan-summary.json"
