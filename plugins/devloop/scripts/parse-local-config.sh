#!/bin/bash
# Parse .devloop/local.md YAML frontmatter and return JSON config
# Returns defaults if file doesn't exist or has no frontmatter

set -euo pipefail

LOCAL_MD=".devloop/local.md"

# Default configuration as JSON
default_config() {
    cat <<'EOF'
{
  "git": {
    "auto_branch": false,
    "branch_pattern": "feat/{slug}",
    "main_branch": "main",
    "pr_on_complete": "ask"
  },
  "commits": {
    "style": "conventional",
    "scope_from_plan": true,
    "sign": false
  },
  "review": {
    "before_commit": "ask",
    "use_plugin": null
  },
  "github": {
    "link_issues": false,
    "auto_close": "ask",
    "comment_on_complete": true
  }
}
EOF
}

# Extract YAML frontmatter from markdown file
extract_frontmatter() {
    local file="$1"

    if [ ! -f "$file" ]; then
        return 1
    fi

    # Check if file starts with ---
    if ! head -1 "$file" | grep -q "^---$"; then
        return 1
    fi

    # Extract content between first and second ---
    awk '
        /^---$/ {
            if (count == 0) { count++; next }
            if (count == 1) { exit }
        }
        count == 1 { print }
    ' "$file"
}

# Convert YAML to JSON using available tools
yaml_to_json() {
    local yaml="$1"

    # Try yq first (preferred)
    if command -v yq &> /dev/null; then
        echo "$yaml" | yq -o json '.' 2>/dev/null && return 0
    fi

    # Try python with PyYAML
    if command -v python3 &> /dev/null; then
        echo "$yaml" | python3 -c "
import sys, json
try:
    import yaml
    data = yaml.safe_load(sys.stdin.read())
    print(json.dumps(data if data else {}))
except Exception:
    print('{}')
" 2>/dev/null && return 0
    fi

    # Fallback: basic key-value parsing (limited)
    # Only handles simple flat structure
    echo "{}"
}

# Merge user config with defaults
merge_configs() {
    local defaults="$1"
    local user_config="$2"

    if command -v jq &> /dev/null; then
        # Deep merge: defaults * user_config (user overrides defaults)
        echo "$defaults" | jq --argjson user "$user_config" '
            . * $user |
            .git = (.git // {}) |
            .commits = (.commits // {}) |
            .review = (.review // {}) |
            .github = (.github // {})
        ' | jq --argjson defaults "$defaults" '
            # Fill in missing nested values from defaults
            .git = ($defaults.git * .git) |
            .commits = ($defaults.commits * .commits) |
            .review = ($defaults.review * .review) |
            .github = ($defaults.github * .github)
        '
    else
        # No jq, just return user config or defaults
        if [ "$user_config" = "{}" ] || [ -z "$user_config" ]; then
            echo "$defaults"
        else
            echo "$user_config"
        fi
    fi
}

# Normalize keys: kebab-case to snake_case for consistency
normalize_keys() {
    local json="$1"

    if command -v jq &> /dev/null; then
        echo "$json" | jq '
            walk(if type == "object" then
                with_entries(.key |= gsub("-"; "_"))
            else . end)
        '
    else
        echo "$json"
    fi
}

# Main execution
main() {
    local defaults
    defaults=$(default_config)

    # Try to extract and parse user config
    local user_yaml
    local user_json="{}"

    if user_yaml=$(extract_frontmatter "$LOCAL_MD"); then
        if [ -n "$user_yaml" ]; then
            user_json=$(yaml_to_json "$user_yaml")
        fi
    fi

    # Normalize keys to snake_case
    user_json=$(normalize_keys "$user_json")

    # Merge and output
    merge_configs "$defaults" "$user_json"
}

main "$@"
