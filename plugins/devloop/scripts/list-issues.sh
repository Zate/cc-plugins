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
# Output:
#   Formatted table of issues or JSON
#
# Exit codes:
#   0 - Success
#   1 - No GitHub access method available
#   2 - Not in a GitHub repository
#   3 - API error

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default options
STATE="open"
LABELS=()
ASSIGNEE=""
LIMIT=30
JSON_OUTPUT=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --state)
            STATE="$2"
            shift 2
            ;;
        --label)
            LABELS+=("$2")
            shift 2
            ;;
        --assignee)
            ASSIGNEE="$2"
            shift 2
            ;;
        --limit)
            LIMIT="$2"
            shift 2
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Check GitHub setup
SETUP_JSON=$("$SCRIPT_DIR/check-gh-setup.sh" 2>/dev/null || echo '{"preferred_method":"none"}')
PREFERRED_METHOD=$(echo "$SETUP_JSON" | grep -o '"preferred_method": *"[^"]*"' | cut -d'"' -f4)
REPO_OWNER=$(echo "$SETUP_JSON" | grep -o '"repo_owner": *"[^"]*"' | cut -d'"' -f4)
REPO_NAME=$(echo "$SETUP_JSON" | grep -o '"repo_name": *"[^"]*"' | cut -d'"' -f4)
REPO_DETECTED=$(echo "$SETUP_JSON" | grep -o '"repo_detected": *[^,}]*' | cut -d':' -f2 | tr -d ' ')

if [ "$REPO_DETECTED" != "true" ]; then
    echo '{"error": "not_github_repo", "message": "Not in a GitHub repository or cannot detect remote"}' >&2
    exit 2
fi

if [ "$PREFERRED_METHOD" = "none" ]; then
    MESSAGE=$(echo "$SETUP_JSON" | grep -o '"message": *"[^"]*"' | cut -d'"' -f4)
    echo "{\"error\": \"no_access\", \"message\": \"$MESSAGE\"}" >&2
    exit 1
fi

# Function to fetch issues using gh CLI
fetch_with_gh() {
    local args=("issue" "list" "--state" "$STATE" "--limit" "$LIMIT")

    for label in "${LABELS[@]}"; do
        args+=("--label" "$label")
    done

    if [ -n "$ASSIGNEE" ]; then
        args+=("--assignee" "$ASSIGNEE")
    fi

    args+=("--json" "number,title,labels,assignees,createdAt,state")

    gh "${args[@]}"
}

# Function to fetch issues using curl with GITHUB_TOKEN
fetch_with_curl() {
    local url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues"
    local params="state=$STATE&per_page=$LIMIT"

    for label in "${LABELS[@]}"; do
        params+="&labels=$label"
    done

    if [ -n "$ASSIGNEE" ]; then
        params+="&assignee=$ASSIGNEE"
    fi

    curl -s -H "Authorization: token $GITHUB_TOKEN" \
         -H "Accept: application/vnd.github.v3+json" \
         "$url?$params"
}

# Function to format time ago
time_ago() {
    local created="$1"
    local now
    now=$(date +%s)
    local then
    then=$(date -d "$created" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$created" +%s 2>/dev/null || echo "$now")
    local diff=$((now - then))

    if [ $diff -lt 60 ]; then
        echo "now"
    elif [ $diff -lt 3600 ]; then
        echo "$((diff / 60))m ago"
    elif [ $diff -lt 86400 ]; then
        echo "$((diff / 3600))h ago"
    elif [ $diff -lt 604800 ]; then
        echo "$((diff / 86400))d ago"
    elif [ $diff -lt 2592000 ]; then
        echo "$((diff / 604800))w ago"
    else
        echo "$((diff / 2592000))mo ago"
    fi
}

# Function to format output as table
format_table() {
    local json="$1"
    local count
    count=$(echo "$json" | grep -o '"number":' | wc -l | tr -d ' ')

    if [ "$count" = "0" ]; then
        echo "No issues found matching criteria."
        return
    fi

    echo "# ${STATE^} Issues ($count)"
    echo ""

    # Parse JSON and format each issue
    # Using a simple approach that works with basic JSON
    echo "$json" | python3 -c "
import json
import sys
from datetime import datetime, timezone

data = json.load(sys.stdin)

for issue in data:
    num = issue.get('number', 0)
    title = issue.get('title', '')[:45]
    labels = issue.get('labels', [])
    assignees = issue.get('assignees', [])
    created = issue.get('createdAt', '')

    # Format labels
    label_str = ''
    if labels:
        if isinstance(labels[0], dict):
            label_str = '[' + ','.join(l.get('name', '')[:10] for l in labels[:2]) + ']'
        else:
            label_str = '[' + ','.join(str(l)[:10] for l in labels[:2]) + ']'

    # Format assignee
    assignee_str = '-'
    if assignees:
        if isinstance(assignees[0], dict):
            assignee_str = '@' + assignees[0].get('login', '')[:12]
        else:
            assignee_str = '@' + str(assignees[0])[:12]

    # Format time ago
    time_str = ''
    if created:
        try:
            dt = datetime.fromisoformat(created.replace('Z', '+00:00'))
            diff = datetime.now(timezone.utc) - dt
            days = diff.days
            if days == 0:
                hours = diff.seconds // 3600
                if hours == 0:
                    time_str = 'now'
                else:
                    time_str = f'{hours}h ago'
            elif days < 7:
                time_str = f'{days}d ago'
            elif days < 30:
                time_str = f'{days // 7}w ago'
            else:
                time_str = f'{days // 30}mo ago'
        except:
            time_str = ''

    # Pad title for alignment
    title_padded = title.ljust(45)
    label_padded = label_str.ljust(15) if label_str else ' ' * 15
    assignee_padded = assignee_str.ljust(14)

    print(f'#{num:<4} {label_padded} {title_padded} {assignee_padded} {time_str}')
" 2>/dev/null || echo "Error formatting output. Try --json for raw data."
}

# Fetch issues based on preferred method
if [ "$PREFERRED_METHOD" = "gh" ]; then
    ISSUES_JSON=$(fetch_with_gh)
else
    ISSUES_JSON=$(fetch_with_curl)
fi

# Check for errors
if echo "$ISSUES_JSON" | grep -q '"message":.*"Bad credentials"'; then
    echo '{"error": "auth_failed", "message": "Authentication failed. Check your credentials."}' >&2
    exit 3
fi

if echo "$ISSUES_JSON" | grep -q '"message":.*"Not Found"'; then
    echo '{"error": "not_found", "message": "Repository not found or no access."}' >&2
    exit 3
fi

# Count issues for summary
ISSUE_COUNT=$(echo "$ISSUES_JSON" | grep -o '"number":' | wc -l | tr -d ' ')

# Output summary line then full data
echo "issues: ${STATE} count=${ISSUE_COUNT}"
if [ "$JSON_OUTPUT" = true ]; then
    echo "$ISSUES_JSON"
else
    format_table "$ISSUES_JSON"
fi
