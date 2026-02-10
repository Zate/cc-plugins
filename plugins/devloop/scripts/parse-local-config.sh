#!/bin/bash
# Parse .devloop/local.md YAML frontmatter and return JSON config
# Returns defaults if file doesn't exist or has no frontmatter

set -euo pipefail

LOCAL_MD=".devloop/local.md"

# Default configuration as JSON
default_config() {
    cat <<'EOF'
{
  "git": {"auto_branch": false, "branch_pattern": "feat/{slug}", "main_branch": "main", "pr_on_complete": "ask"},
  "commits": {"style": "conventional", "scope_from_plan": true, "sign": false},
  "review": {"before_commit": "ask", "use_plugin": null},
  "github": {"link_issues": false, "auto_close": "ask", "comment_on_complete": true}
}
EOF
}

# Extract YAML frontmatter from markdown file
extract_frontmatter() {
    local file="$1"
    [[ -f "$file" ]] || return 1
    head -1 "$file" | grep -q "^---$" || return 1
    awk '/^---$/ { if (count++ == 1) exit } count == 1 { print }' "$file"
}

# Convert YAML to JSON
yaml_to_json() {
    local yaml="$1"

    # Try yq first (preferred)
    if command -v yq &> /dev/null; then
        echo "$yaml" | yq -o json '.' 2>/dev/null && return 0
    fi

    # Fallback: basic key-value extraction for simple YAML
    # Only handles flat structure like: key: value
    echo "$yaml" | awk '
        BEGIN { print "{"; first=1 }
        /^[a-zA-Z_][a-zA-Z0-9_]*:/ {
            gsub(/^[ \t]+|[ \t]+$/, "")
            split($0, a, /: */)
            key = a[1]; val = a[2]
            gsub(/-/, "_", key)  # kebab to snake
            if (!first) print ","
            first = 0
            if (val ~ /^(true|false)$/) printf "  \"%s\": %s", key, val
            else if (val ~ /^[0-9]+$/) printf "  \"%s\": %s", key, val
            else printf "  \"%s\": \"%s\"", key, val
        }
        END { print "\n}" }
    '
}

# Merge configs with jq (if available) or return user config
merge_configs() {
    local defaults="$1" user_config="$2"

    if command -v jq &> /dev/null; then
        echo "$defaults" | jq --argjson user "$user_config" '. * $user'
    elif [[ "$user_config" == "{}" ]]; then
        echo "$defaults"
    else
        echo "$user_config"
    fi
}

# Main
main() {
    local defaults user_yaml user_json="{}"
    defaults=$(default_config)

    if user_yaml=$(extract_frontmatter "$LOCAL_MD"); then
        [[ -n "$user_yaml" ]] && user_json=$(yaml_to_json "$user_yaml")
    fi

    merge_configs "$defaults" "$user_json"
}

main "$@"
