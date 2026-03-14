#!/bin/bash
set -euo pipefail

# apply-suppressions.sh — Filter correlated findings against suppressions file.
# Usage: apply-suppressions.sh [correlated.json] [suppressions.json] [output.json]
# If no suppressions file exists, copies input to output unchanged.

CORRELATED="${1:-.security/correlated.json}"
SUPPRESSIONS="${2:-.security/suppressions.json}"
OUTPUT="${3:-.security/correlated.json}"

if ! command -v jq &>/dev/null; then
    echo "Error: jq required" >&2
    exit 1
fi

if [ ! -f "$CORRELATED" ]; then
    echo "Error: correlated findings not found: $CORRELATED" >&2
    exit 1
fi

# If no suppressions file, nothing to filter
if [ ! -f "$SUPPRESSIONS" ]; then
    if [ "$CORRELATED" != "$OUTPUT" ]; then
        cp "$CORRELATED" "$OUTPUT"
    fi
    echo '{"suppressed": 0, "remaining": '$(jq '.findings | length' "$CORRELATED")'}' >&2
    exit 0
fi

# Apply suppressions: match by file+rule_id or file+line+cwe
filtered=$(jq --slurpfile supp "$SUPPRESSIONS" '
    .findings as $findings |
    ($supp[0].suppressions // []) as $rules |

    # Build suppression matchers
    .findings = [
        $findings[] |
        . as $f |
        # Check each suppression rule
        (reduce $rules[] as $rule (
            false;
            . or (
                # Match by rule_id (if specified)
                (if $rule.rule_id then
                    ($f.rule_ids // [] | any(. == $rule.rule_id)) or
                    ($f.rule_ids // [] | any(contains($rule.rule_id)))
                else true end)
                and
                # Match by file pattern (glob-like)
                (if $rule.file then
                    ($f.file | test($rule.file | gsub("\\*\\*"; ".*") | gsub("\\*"; "[^/]*")))
                else true end)
                and
                # Match by CWE (if specified)
                (if $rule.cwe then
                    ($f.cwe // "" | contains($rule.cwe))
                else true end)
                and
                # At least one criterion must be specified
                ($rule.rule_id != null or $rule.file != null or $rule.cwe != null)
            )
        )) as $is_suppressed |
        if $is_suppressed then
            . + {"suppressed": true, "suppression_reason": (
                reduce $rules[] as $rule (
                    "Matched suppression rule";
                    if (
                        (if $rule.rule_id then
                            ($f.rule_ids // [] | any(. == $rule.rule_id)) or
                            ($f.rule_ids // [] | any(contains($rule.rule_id)))
                        else true end)
                        and
                        (if $rule.file then
                            ($f.file | test($rule.file | gsub("\\*\\*"; ".*") | gsub("\\*"; "[^/]*")))
                        else true end)
                        and
                        (if $rule.cwe then
                            ($f.cwe // "" | contains($rule.cwe))
                        else true end)
                        and
                        ($rule.rule_id != null or $rule.file != null or $rule.cwe != null)
                    ) then $rule.reason // "Suppressed by rule"
                    else . end
                )
            )}
        else .
        end
    ] |

    # Count
    (.findings | map(select(.suppressed == true)) | length) as $suppressed_count |
    (.findings | map(select(.suppressed != true)) | length) as $remaining_count |

    # Update summary
    .summary.suppressed_findings = $suppressed_count |
    .summary.total_after_suppression = $remaining_count
' "$CORRELATED")

echo "$filtered" > "$OUTPUT"

suppressed=$(echo "$filtered" | jq '.summary.suppressed_findings // 0')
remaining=$(echo "$filtered" | jq '.summary.total_after_suppression // 0')
echo "suppressions: $suppressed suppressed, $remaining remaining" >&2
