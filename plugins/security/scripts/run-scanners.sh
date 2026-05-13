#!/bin/bash
set -euo pipefail

# run-scanners.sh — Orchestrate available security scanning tools.
# Usage: run-scanners.sh [output_directory] [--path scan_dir] [--files changed-files.json]
# Output: Summary JSON to stdout. Tool artifacts written to output_directory.

OUTPUT_DIR="${1:-.security/artifacts}"
FILES_JSON=""
SCAN_DIR="."

# Parse optional --files arg
shift || true
while [ $# -gt 0 ]; do
    case "$1" in
        --files) FILES_JSON="$2"; shift 2 ;;
        --path) SCAN_DIR="$2"; shift 2 ;;
        *) shift ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

if [ ! -d "$SCAN_DIR" ]; then
    echo "Error: scan path not found: $SCAN_DIR" >&2
    exit 1
fi

SCAN_DIR="$(cd "$SCAN_DIR" && pwd)"

# If diff mode, build file list for tools that support it
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
if find "$SCAN_DIR" -maxdepth 3 -name '*.py' -not -path '*/node_modules/*' -not -path '*/.git/*' -print -quit 2>/dev/null | grep -q .; then
    has_python=true
fi
if [ -f "$SCAN_DIR/go.mod" ] || find "$SCAN_DIR" -maxdepth 3 -name '*.go' -not -path '*/vendor/*' -not -path '*/.git/*' -print -quit 2>/dev/null | grep -q .; then
    has_go=true
fi

# Track results. Use scalar variables for macOS Bash 3 compatibility.
for tool in semgrep gitleaks trivy bandit gosec regex; do
    eval "${tool}_ran=false"
    eval "${tool}_findings=0"
    eval "${tool}_time=0"
    eval "${tool}_error=''"
done

set_ran() { eval "${1}_ran=\"$2\""; }
set_findings() { eval "${1}_findings=\"$2\""; }
set_time() { eval "${1}_time=\"$2\""; }
set_error() { eval "${1}_error=\"\$2\""; }
get_var() { eval "printf '%s' \"\${${1}_${2}:-}\""; }

total_start=$(date +%s)

# --- Semgrep ---
if [ "$(tool_available semgrep)" = "true" ]; then
    echo "scanner: running semgrep..." >&2
    start=$(date +%s)
    semgrep_target="."
    if [ -n "$SEMGREP_PATHS" ]; then
        semgrep_target="$SEMGREP_PATHS"
    else
        semgrep_target="$SCAN_DIR"
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
        set_ran semgrep true
        count=$(jq '[.runs[].results[]] | length' "$OUTPUT_DIR/semgrep.sarif.json" 2>/dev/null || echo 0)
        set_findings semgrep "$count"
    else
        set_ran semgrep true
        set_error semgrep "non-zero exit (may still have partial results)"
        if [ -f "$OUTPUT_DIR/semgrep.sarif.json" ]; then
            count=$(jq '[.runs[].results[]] | length' "$OUTPUT_DIR/semgrep.sarif.json" 2>/dev/null || echo 0)
            set_findings semgrep "$count"
        else
            set_findings semgrep 0
        fi
    fi
    end=$(date +%s)
    set_time semgrep $((end - start))
else
    set_ran semgrep false
fi

# --- Gitleaks ---
if [ "$(tool_available gitleaks)" = "true" ]; then
    echo "scanner: running gitleaks..." >&2
    start=$(date +%s)
    # gitleaks exits 1 when findings exist, which is normal
    if gitleaks detect \
        --source "$SCAN_DIR" \
        --report-format json \
        --report-path "$OUTPUT_DIR/gitleaks.json" \
        --no-banner 2>/dev/null; then
        set_ran gitleaks true
        set_findings gitleaks 0
    else
        set_ran gitleaks true
        if [ -f "$OUTPUT_DIR/gitleaks.json" ]; then
            count=$(jq 'length' "$OUTPUT_DIR/gitleaks.json" 2>/dev/null || echo 0)
            set_findings gitleaks "$count"
        else
            set_findings gitleaks 0
            set_error gitleaks "failed to produce output"
        fi
    fi
    end=$(date +%s)
    set_time gitleaks $((end - start))
else
    set_ran gitleaks false
fi

# --- Trivy ---
if [ "$(tool_available trivy)" = "true" ]; then
    echo "scanner: running trivy..." >&2
    start=$(date +%s)
    if trivy fs "$SCAN_DIR" \
        --format json \
        --output "$OUTPUT_DIR/trivy.json" \
        --scanners vuln,secret \
        --quiet 2>/dev/null; then
        set_ran trivy true
        count=$(jq '[.Results[]? | (.Vulnerabilities // [])[], (.Secrets // [])[]] | length' "$OUTPUT_DIR/trivy.json" 2>/dev/null || echo 0)
        set_findings trivy "$count"
    else
        set_ran trivy true
        set_error trivy "non-zero exit"
        set_findings trivy 0
    fi
    end=$(date +%s)
    set_time trivy $((end - start))
else
    set_ran trivy false
fi

# --- Bandit (Python only) ---
if [ "$(tool_available bandit)" = "true" ] && [ "$has_python" = true ]; then
    echo "scanner: running bandit..." >&2
    start=$(date +%s)
    # bandit exits 1 when findings exist
    if bandit -r "$SCAN_DIR" -f json -o "$OUTPUT_DIR/bandit.json" --quiet 2>/dev/null; then
        set_ran bandit true
        set_findings bandit 0
    else
        set_ran bandit true
        if [ -f "$OUTPUT_DIR/bandit.json" ]; then
            count=$(jq '.results | length' "$OUTPUT_DIR/bandit.json" 2>/dev/null || echo 0)
            set_findings bandit "$count"
        else
            set_findings bandit 0
            set_error bandit "failed to produce output"
        fi
    fi
    end=$(date +%s)
    set_time bandit $((end - start))
else
    set_ran bandit false
fi

# --- gosec (Go only) ---
if [ "$(tool_available gosec)" = "true" ] && [ "$has_go" = true ]; then
    echo "scanner: running gosec..." >&2
    start=$(date +%s)
    # gosec exits non-zero when findings exist
    if (
        cd "$SCAN_DIR"
        gosec -fmt json -out "$OUTPUT_DIR/gosec.json" ./...
    ) 2>/dev/null; then
        set_ran gosec true
        set_findings gosec 0
    else
        set_ran gosec true
        if [ -f "$OUTPUT_DIR/gosec.json" ]; then
            count=$(jq '.Issues | length' "$OUTPUT_DIR/gosec.json" 2>/dev/null || echo 0)
            set_findings gosec "$count"
        else
            set_findings gosec 0
            set_error gosec "failed to produce output"
        fi
    fi
    end=$(date +%s)
    set_time gosec $((end - start))
else
    set_ran gosec false
fi

# --- Always run regex scan as baseline ---
echo "scanner: running regex scan..." >&2
start=$(date +%s)
if [ -n "$FILES_JSON" ] && [ -f "$FILES_JSON" ]; then
    "$SCRIPT_DIR/run-regex-scan.sh" "$SCAN_DIR" "$OUTPUT_DIR/regex-scan.json" --files "$FILES_JSON" 2>/dev/null || true
else
    "$SCRIPT_DIR/run-regex-scan.sh" "$SCAN_DIR" "$OUTPUT_DIR/regex-scan.json" 2>/dev/null || true
fi
set_ran regex true
if [ -f "$OUTPUT_DIR/regex-scan.json" ]; then
    count=$(jq 'length' "$OUTPUT_DIR/regex-scan.json" 2>/dev/null || echo 0)
    set_findings regex "$count"
else
    set_findings regex 0
fi
end=$(date +%s)
set_time regex $((end - start))

total_end=$(date +%s)
total_time=$((total_end - total_start))

# Build summary JSON
summary="{"
summary+="\"scan_time_seconds\":$total_time,"
summary+="\"scan_path\":\"$SCAN_DIR\","
summary+="\"tools\":{"

first=true
for tool in semgrep gitleaks trivy bandit gosec regex; do
    if [ "$first" = true ]; then first=false; else summary+=","; fi
    ran="$(get_var "$tool" ran)"
    findings="$(get_var "$tool" findings)"
    elapsed="$(get_var "$tool" time)"
    error="$(get_var "$tool" error)"
    [ -z "$ran" ] && ran=false
    [ -z "$findings" ] && findings=0
    [ -z "$elapsed" ] && elapsed=0

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
    findings="$(get_var "$tool" findings)"
    [ -z "$findings" ] && findings=0
    total=$((total + findings))
done
summary+="\"total_raw_findings\":$total"
summary+="}"

echo "$summary" | jq '.'

# Also save summary
echo "$summary" | jq '.' > "$OUTPUT_DIR/scan-summary.json"
