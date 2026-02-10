#!/bin/bash
# list-issues.sh - List GitHub issues for the current repository
#
# Usage:
#   ./list-issues.sh [options]
#
# Options:
#   --state STATE      Issue state: open, closed, all (default: open)
#   --label LABEL      Filter by label (can be repeated)
#   --assignee USER    Filter by assignee
#   --limit N          Max issues to return (default: 30)
#   --json             Output raw JSON instead of formatted table
#
# Requires: gh CLI (GitHub CLI)

set -euo pipefail

# Default options
STATE="open"
LABELS=()
ASSIGNEE=""
LIMIT=30
JSON_OUTPUT=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --state)   STATE="$2"; shift 2 ;;
        --label)   LABELS+=("$2"); shift 2 ;;
        --assignee) ASSIGNEE="$2"; shift 2 ;;
        --limit)   LIMIT="$2"; shift 2 ;;
        --json)    JSON_OUTPUT=true; shift ;;
        *)         echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# Check gh CLI is available
if ! command -v gh &> /dev/null; then
    echo '{"error": "gh_not_found", "message": "GitHub CLI (gh) is required. Install from https://cli.github.com/"}' >&2
    exit 1
fi

# Check we're in a GitHub repo
if ! gh repo view &> /dev/null; then
    echo '{"error": "not_github_repo", "message": "Not in a GitHub repository or not authenticated. Run: gh auth login"}' >&2
    exit 2
fi

# Build gh CLI arguments
GH_ARGS=("issue" "list" "--state" "$STATE" "--limit" "$LIMIT")
for label in "${LABELS[@]}"; do
    GH_ARGS+=("--label" "$label")
done
if [[ -n "$ASSIGNEE" ]]; then
    GH_ARGS+=("--assignee" "$ASSIGNEE")
fi
GH_ARGS+=("--json" "number,title,labels,assignees,createdAt,state")

# Fetch issues
ISSUES_JSON=$(gh "${GH_ARGS[@]}" 2>&1) || {
    echo "{\"error\": \"gh_error\", \"message\": \"$ISSUES_JSON\"}" >&2
    exit 3
}

# Count issues
ISSUE_COUNT=$(echo "$ISSUES_JSON" | jq 'length')

# Output summary line then data
echo "issues: ${STATE} count=${ISSUE_COUNT}"

if [[ "$JSON_OUTPUT" == "true" ]]; then
    echo "$ISSUES_JSON"
else
    # Format as table using jq
    if [[ "$ISSUE_COUNT" == "0" ]]; then
        echo "No issues found matching criteria."
    else
        echo "# ${STATE^} Issues ($ISSUE_COUNT)"
        echo ""
        echo "$ISSUES_JSON" | jq -r '
            def time_ago:
                now - (. | fromdateiso8601) |
                if . < 3600 then "\(. / 60 | floor)m ago"
                elif . < 86400 then "\(. / 3600 | floor)h ago"
                elif . < 604800 then "\(. / 86400 | floor)d ago"
                elif . < 2592000 then "\(. / 604800 | floor)w ago"
                else "\(. / 2592000 | floor)mo ago"
                end;

            .[] |
            "#\(.number | tostring | .[0:4] | . + "    "[length:]) " +
            (if .labels | length > 0 then
                "[" + ([.labels[0:2][] | .name[0:10]] | join(",")) + "]"
            else "" end | . + "               "[length:]) + " " +
            (.title[0:45] | . + "                                             "[length:]) + " " +
            (if .assignees | length > 0 then
                "@" + .assignees[0].login[0:12]
            else "-" end | . + "              "[length:]) + " " +
            (.createdAt | time_ago)
        '
    fi
fi
