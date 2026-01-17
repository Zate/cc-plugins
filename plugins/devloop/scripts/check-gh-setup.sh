#!/bin/bash
# check-gh-setup.sh - Check GitHub CLI setup status and available methods
#
# Usage:
#   ./check-gh-setup.sh
#
# Output (JSON):
#   {
#     "gh_installed": true/false,
#     "gh_authenticated": true/false,
#     "github_token": true/false,
#     "repo_detected": true/false,
#     "repo_owner": "owner",
#     "repo_name": "repo",
#     "preferred_method": "gh|curl|none",
#     "message": "Human-readable status"
#   }
#
# Exit codes:
#   0 - At least one method available (gh or curl with token)
#   1 - No method available

set -euo pipefail

# Initialize result variables
GH_INSTALLED=false
GH_AUTHENTICATED=false
GITHUB_TOKEN_SET=false
REPO_DETECTED=false
REPO_OWNER=""
REPO_NAME=""
PREFERRED_METHOD="none"
MESSAGE=""

# Check if gh CLI is installed
if command -v gh &>/dev/null; then
    GH_INSTALLED=true

    # Check if gh is authenticated
    if gh auth status &>/dev/null; then
        GH_AUTHENTICATED=true
    fi
fi

# Check if GITHUB_TOKEN is set
if [ -n "${GITHUB_TOKEN:-}" ]; then
    GITHUB_TOKEN_SET=true
fi

# Try to detect repo from git remote
parse_github_remote() {
    local remote_url="$1"

    # Handle SSH format: git@github.com:owner/repo.git
    if [[ "$remote_url" =~ git@github\.com:([^/]+)/([^/.]+)(\.git)?$ ]]; then
        REPO_OWNER="${BASH_REMATCH[1]}"
        REPO_NAME="${BASH_REMATCH[2]}"
        REPO_DETECTED=true
        return 0
    fi

    # Handle HTTPS format: https://github.com/owner/repo.git
    if [[ "$remote_url" =~ https://github\.com/([^/]+)/([^/.]+)(\.git)?$ ]]; then
        REPO_OWNER="${BASH_REMATCH[1]}"
        REPO_NAME="${BASH_REMATCH[2]}"
        REPO_DETECTED=true
        return 0
    fi

    # Handle HTTPS format without .git: https://github.com/owner/repo
    if [[ "$remote_url" =~ https://github\.com/([^/]+)/([^/]+)/?$ ]]; then
        REPO_OWNER="${BASH_REMATCH[1]}"
        REPO_NAME="${BASH_REMATCH[2]}"
        REPO_DETECTED=true
        return 0
    fi

    return 1
}

# Try to get remote URL
if git rev-parse --is-inside-work-tree &>/dev/null; then
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    if [ -n "$REMOTE_URL" ]; then
        parse_github_remote "$REMOTE_URL" || true
    fi
fi

# Determine preferred method and message
if [ "$GH_INSTALLED" = true ] && [ "$GH_AUTHENTICATED" = true ]; then
    PREFERRED_METHOD="gh"
    MESSAGE="GitHub CLI is installed and authenticated"
elif [ "$GH_INSTALLED" = true ] && [ "$GH_AUTHENTICATED" = false ]; then
    if [ "$GITHUB_TOKEN_SET" = true ]; then
        PREFERRED_METHOD="curl"
        MESSAGE="GitHub CLI installed but not authenticated. Using GITHUB_TOKEN fallback"
    else
        PREFERRED_METHOD="none"
        MESSAGE="GitHub CLI installed but not authenticated. Run 'gh auth login' to authenticate"
    fi
elif [ "$GITHUB_TOKEN_SET" = true ]; then
    PREFERRED_METHOD="curl"
    MESSAGE="GitHub CLI not installed. Using GITHUB_TOKEN for API access"
else
    PREFERRED_METHOD="none"
    MESSAGE="No GitHub access method available. Install gh CLI (https://cli.github.com) or set GITHUB_TOKEN"
fi

# Output JSON
cat <<EOF
{
  "gh_installed": $GH_INSTALLED,
  "gh_authenticated": $GH_AUTHENTICATED,
  "github_token": $GITHUB_TOKEN_SET,
  "repo_detected": $REPO_DETECTED,
  "repo_owner": "$REPO_OWNER",
  "repo_name": "$REPO_NAME",
  "preferred_method": "$PREFERRED_METHOD",
  "message": "$MESSAGE"
}
EOF

# Exit with appropriate code
if [ "$PREFERRED_METHOD" != "none" ]; then
    exit 0
else
    exit 1
fi
