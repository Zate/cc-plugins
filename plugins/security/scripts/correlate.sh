#!/bin/bash
set -euo pipefail

# correlate.sh — Deterministic finding correlation and deduplication.
# Usage: correlate.sh <artifacts_dir> <output_file>
# Output: Correlated findings JSON written to output_file.

ARTIFACTS_DIR="${1:-.security/artifacts}"
OUTPUT_FILE="${2:-.security/correlated.json}"

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required for correlation" >&2
    exit 1
fi

if [ ! -d "$ARTIFACTS_DIR" ]; then
    echo "Error: artifacts directory not found: $ARTIFACTS_DIR" >&2
    exit 1
fi

# Collect all normalized findings into a single array
all_findings="[]"

# --- Normalize Semgrep SARIF ---
if [ -f "$ARTIFACTS_DIR/semgrep.sarif.json" ]; then
    semgrep_findings=$(jq '
        [.runs[]? | .results[]? | {
            source: "semgrep",
            rule_id: .ruleId,
            file: .locations[0]?.physicalLocation?.artifactLocation?.uri,
            line: (.locations[0]?.physicalLocation?.region?.startLine // 0),
            severity: (
                if .level == "error" then "HIGH"
                elif .level == "warning" then "MEDIUM"
                else "LOW"
                end
            ),
            message: .message.text,
            cwe: (
                [.properties?.tags[]? | select(startswith("CWE-"))] | first // null
            ),
            snippet: .locations[0]?.physicalLocation?.region?.snippet?.text
        }]
    ' "$ARTIFACTS_DIR/semgrep.sarif.json" 2>/dev/null || echo "[]")
    all_findings=$(echo "$all_findings" | jq --argjson new "$semgrep_findings" '. + $new')
fi

# --- Normalize Gitleaks JSON ---
if [ -f "$ARTIFACTS_DIR/gitleaks.json" ]; then
    gitleaks_findings=$(jq '
        [.[]? | {
            source: "gitleaks",
            rule_id: .RuleID,
            file: .File,
            line: (.StartLine // 0),
            severity: "CRITICAL",
            message: .Description,
            cwe: "CWE-798",
            snippet: (.Match // .Secret | .[0:100])
        }]
    ' "$ARTIFACTS_DIR/gitleaks.json" 2>/dev/null || echo "[]")
    all_findings=$(echo "$all_findings" | jq --argjson new "$gitleaks_findings" '. + $new')
fi

# --- Normalize Trivy JSON ---
if [ -f "$ARTIFACTS_DIR/trivy.json" ]; then
    trivy_findings=$(jq '
        [.Results[]? | (
            (.Vulnerabilities // [])[] | {
                source: "trivy",
                rule_id: .VulnerabilityID,
                file: .PkgName,
                line: 0,
                severity: .Severity,
                message: .Title,
                cwe: (
                    if .CweIDs then .CweIDs[0] else null end
                ),
                snippet: (.InstalledVersion + " -> " + .FixedVersion)
            }
        ), (
            (.Secrets // [])[] | {
                source: "trivy",
                rule_id: .RuleID,
                file: .Target,
                line: (.StartLine // 0),
                severity: .Severity,
                message: .Title,
                cwe: "CWE-798",
                snippet: (.Match // "")[0:100]
            }
        )]
    ' "$ARTIFACTS_DIR/trivy.json" 2>/dev/null || echo "[]")
    all_findings=$(echo "$all_findings" | jq --argjson new "$trivy_findings" '. + $new')
fi

# --- Normalize Bandit JSON ---
if [ -f "$ARTIFACTS_DIR/bandit.json" ]; then
    bandit_findings=$(jq '
        [.results[]? | {
            source: "bandit",
            rule_id: .test_id,
            file: .filename,
            line: (.line_number // 0),
            severity: (
                if .issue_severity == "HIGH" then "HIGH"
                elif .issue_severity == "MEDIUM" then "MEDIUM"
                else "LOW"
                end
            ),
            message: .issue_text,
            cwe: (.issue_cwe.id // null | if . then "CWE-\(.)" else null end),
            snippet: .code
        }]
    ' "$ARTIFACTS_DIR/bandit.json" 2>/dev/null || echo "[]")
    all_findings=$(echo "$all_findings" | jq --argjson new "$bandit_findings" '. + $new')
fi

# --- Normalize gosec JSON ---
if [ -f "$ARTIFACTS_DIR/gosec.json" ]; then
    gosec_findings=$(jq '
        [.Issues[]? | {
            source: "gosec",
            rule_id: .rule_id,
            file: .file,
            line: (.line | tonumber // 0),
            severity: .severity,
            message: .details,
            cwe: ("CWE-" + .cwe.id),
            snippet: .code
        }]
    ' "$ARTIFACTS_DIR/gosec.json" 2>/dev/null || echo "[]")
    all_findings=$(echo "$all_findings" | jq --argjson new "$gosec_findings" '. + $new')
fi

# --- Normalize regex scan JSON ---
if [ -f "$ARTIFACTS_DIR/regex-scan.json" ]; then
    regex_findings=$(jq '
        [.[]? | {
            source: "regex",
            rule_id: .pattern_id,
            file: .file,
            line: .line,
            severity: .severity,
            message: .description,
            cwe: .cwe,
            snippet: .match
        }]
    ' "$ARTIFACTS_DIR/regex-scan.json" 2>/dev/null || echo "[]")
    all_findings=$(echo "$all_findings" | jq --argjson new "$regex_findings" '. + $new')
fi

# --- Deduplicate and correlate ---
# Group by file+line, merge sources, mark corroborated
correlated=$(echo "$all_findings" | jq '
    # Normalize severity values
    map(.severity = (
        if .severity == "CRITICAL" then "CRITICAL"
        elif (.severity == "HIGH" or .severity == "high") then "HIGH"
        elif (.severity == "MEDIUM" or .severity == "medium" or .severity == "WARNING") then "MEDIUM"
        else "LOW"
        end
    ))
    # Group by file + line
    | group_by(.file + ":" + (.line | tostring))
    | map(
        if length > 1 then
            # Multiple findings at same location — corroborated
            {
                file: .[0].file,
                line: .[0].line,
                severity: (map(.severity) | map(
                    if . == "CRITICAL" then 0
                    elif . == "HIGH" then 1
                    elif . == "MEDIUM" then 2
                    else 3 end
                ) | min | if . == 0 then "CRITICAL"
                    elif . == 1 then "HIGH"
                    elif . == 2 then "MEDIUM"
                    else "LOW" end),
                sources: [.[] | .source] | unique,
                rule_ids: [.[] | .rule_id] | unique,
                message: .[0].message,
                cwe: ([.[] | .cwe | select(. != null)] | first // null),
                snippet: .[0].snippet,
                corroborated: true,
                corroboration_count: ([.[] | .source] | unique | length)
            }
        else
            .[0] + {
                sources: [.[0].source],
                rule_ids: [.[0].rule_id],
                corroborated: false,
                corroboration_count: 1
            } | del(.source, .rule_id)
        end
    )
    # Sort by severity
    | sort_by(
        if .severity == "CRITICAL" then 0
        elif .severity == "HIGH" then 1
        elif .severity == "MEDIUM" then 2
        else 3 end
    )
')

# Build output with metadata
total=$(echo "$correlated" | jq 'length')
critical=$(echo "$correlated" | jq '[.[] | select(.severity == "CRITICAL")] | length')
high=$(echo "$correlated" | jq '[.[] | select(.severity == "HIGH")] | length')
medium=$(echo "$correlated" | jq '[.[] | select(.severity == "MEDIUM")] | length')
low=$(echo "$correlated" | jq '[.[] | select(.severity == "LOW")] | length')
corroborated_count=$(echo "$correlated" | jq '[.[] | select(.corroborated == true)] | length')

output=$(jq -n \
    --argjson findings "$correlated" \
    --argjson total "$total" \
    --argjson critical "$critical" \
    --argjson high "$high" \
    --argjson medium "$medium" \
    --argjson low "$low" \
    --argjson corroborated "$corroborated_count" \
    '{
        summary: {
            total_findings: $total,
            by_severity: {
                CRITICAL: $critical,
                HIGH: $high,
                MEDIUM: $medium,
                LOW: $low
            },
            corroborated_findings: $corroborated
        },
        findings: $findings
    }')

echo "$output" > "$OUTPUT_FILE"

# Summary to stderr
echo "correlate: $total findings ($critical critical, $high high, $medium medium, $low low), $corroborated_count corroborated" >&2
echo "$output"
