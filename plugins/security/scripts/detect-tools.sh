#!/bin/bash
set -euo pipefail

# detect-tools.sh — Check for available security scanning tools and output JSON summary.
# Usage: detect-tools.sh
# Output: JSON to stdout with tool availability, tier, and coverage estimate.

get_version() {
    local tool="$1"
    case "$tool" in
        semgrep)   semgrep --version 2>/dev/null | head -1 ;;
        gitleaks)  gitleaks version 2>/dev/null | sed 's/^v//' ;;
        trivy)     trivy --version 2>/dev/null | grep -oP 'Version:\s*\K\S+' || trivy --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+\.\d+' ;;
        bandit)    bandit --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 ;;
        gosec)     gosec --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 || echo "unknown" ;;
        sg)        sg --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+\.\d+' || sg --version 2>/dev/null | head -1 ;;
    esac
}

tools_json="{"
first=true

for tool in semgrep gitleaks trivy bandit gosec sg; do
    if [ "$first" = true ]; then
        first=false
    else
        tools_json+=","
    fi

    if command -v "$tool" &>/dev/null; then
        version=$(get_version "$tool" || echo "unknown")
        # Sanitize version string for JSON
        version=$(echo "$version" | tr -d '\n\r' | sed 's/"/\\"/g')
        tools_json+="\"$tool\":{\"available\":true,\"version\":\"$version\"}"
    else
        tools_json+="\"$tool\":{\"available\":false,\"version\":null}"
    fi
done

tools_json+="}"

# Determine tier
has_semgrep=false
has_gitleaks=false
has_trivy=false
has_lang_specific=false

if command -v semgrep &>/dev/null; then has_semgrep=true; fi
if command -v gitleaks &>/dev/null; then has_gitleaks=true; fi
if command -v trivy &>/dev/null; then has_trivy=true; fi
if command -v bandit &>/dev/null || command -v gosec &>/dev/null; then has_lang_specific=true; fi

if [ "$has_semgrep" = true ] && [ "$has_gitleaks" = true ] && [ "$has_trivy" = true ] && [ "$has_lang_specific" = true ]; then
    tier="full"
    coverage=85
elif [ "$has_semgrep" = true ] && ([ "$has_gitleaks" = true ] || [ "$has_trivy" = true ]); then
    tier="recommended"
    coverage=75
elif [ "$has_semgrep" = true ]; then
    tier="basic"
    coverage=55
else
    tier="minimal"
    coverage=35
fi

cat <<EOF
{
  "tools": $tools_json,
  "tier": "$tier",
  "coverage_estimate": $coverage
}
EOF
