#!/usr/bin/env bash
# Sync a portable Agent Skill into a Claude Code plugin adapter.

set -euo pipefail

usage() {
    cat <<'USAGE'
Usage:
  scripts/sync-portable-skill-adapter.sh <skill-name> [plugin-name]

Environment:
  CLAUDE_USER_INVOCABLE  Set to true/false to add Claude Code invocation metadata.
  CLAUDE_ARGUMENT_HINT   Optional Claude Code argument hint.

Example:
  CLAUDE_USER_INVOCABLE=true \
  CLAUDE_ARGUMENT_HINT="[language/framework context, e.g. 'go cobra', 'python click']" \
    scripts/sync-portable-skill-adapter.sh agent-help
USAGE
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    usage
    exit 0
fi

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    usage >&2
    exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

skill_name="$1"
plugin_name="${2:-$skill_name}"
source_dir="$REPO_ROOT/skills/$skill_name"
dest_dir="$REPO_ROOT/plugins/$plugin_name/skills/$skill_name"
source_skill="$source_dir/SKILL.md"
dest_skill="$dest_dir/SKILL.md"

if [ ! -f "$source_skill" ]; then
    echo "error: missing portable skill: $source_skill" >&2
    exit 1
fi

if [ ! -d "$REPO_ROOT/plugins/$plugin_name" ]; then
    echo "error: missing Claude plugin adapter: $REPO_ROOT/plugins/$plugin_name" >&2
    exit 1
fi

mkdir -p "$dest_dir"

tmp_skill="$(mktemp)"
trap 'rm -f "$tmp_skill"' EXIT

awk \
    -v user_invocable="${CLAUDE_USER_INVOCABLE:-}" \
    -v argument_hint="${CLAUDE_ARGUMENT_HINT:-}" '
    NR == 1 && $0 == "---" {
        in_frontmatter = 1
        print
        next
    }

    in_frontmatter && $0 == "---" {
        if (user_invocable != "") {
            print "user-invocable: " user_invocable
        }
        if (argument_hint != "") {
            gsub(/"/, "\\\"", argument_hint)
            print "argument-hint: \"" argument_hint "\""
        }
        in_frontmatter = 0
        print
        next
    }

    {
        print
    }
' "$source_skill" > "$tmp_skill"

cp "$tmp_skill" "$dest_skill"

find "$source_dir" -type f ! -name 'SKILL.md' | while IFS= read -r source_file; do
    relative_path="${source_file#"$source_dir"/}"
    dest_file="$dest_dir/$relative_path"
    mkdir -p "$(dirname "$dest_file")"
    cp "$source_file" "$dest_file"
done

echo "synced $source_dir -> $dest_dir"
