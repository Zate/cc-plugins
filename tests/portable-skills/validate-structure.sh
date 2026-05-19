#!/usr/bin/env bash
# Validate portable Agent Skills and their Claude plugin adapters.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

failures=0

fail() {
    echo "[FAIL] $*"
    failures=$((failures + 1))
}

pass() {
    echo "[PASS] $*"
}

frontmatter_value() {
    local file="$1"
    local key="$2"

    awk -v key="$key" '
        BEGIN { in_fm = 0; seen_open = 0 }
        NR == 1 && $0 == "---" { in_fm = 1; seen_open = 1; next }
        in_fm && $0 == "---" { exit }
        in_fm && $0 ~ "^" key ":" {
            sub("^" key ":[[:space:]]*", "")
            gsub(/^"|"$/, "")
            print
            exit
        }
    ' "$file"
}

body_without_frontmatter() {
    local file="$1"

    awk '
        NR == 1 && $0 == "---" { in_fm = 1; next }
        in_fm && $0 == "---" { in_fm = 0; next }
        !in_fm { print }
    ' "$file"
}

if [ ! -d "$REPO_ROOT/skills" ]; then
    fail "top-level skills directory is missing"
else
    pass "top-level skills directory exists"
fi

if [ ! -x "$REPO_ROOT/scripts/sync-portable-skill-adapter.sh" ]; then
    fail "portable skill adapter sync script is missing or not executable"
else
    pass "portable skill adapter sync script exists"
fi

for skill_dir in "$REPO_ROOT"/skills/*; do
    [ -d "$skill_dir" ] || continue

    skill_name="$(basename "$skill_dir")"
    skill_file="$skill_dir/SKILL.md"

    if [ ! -f "$skill_file" ]; then
        fail "$skill_name is missing SKILL.md"
        continue
    fi

    declared_name="$(frontmatter_value "$skill_file" "name")"
    description="$(frontmatter_value "$skill_file" "description")"

    if [ "$declared_name" != "$skill_name" ]; then
        fail "$skill_name frontmatter name must match directory name; got '$declared_name'"
    else
        pass "$skill_name frontmatter name matches directory"
    fi

    if [ -z "$description" ]; then
        fail "$skill_name description is missing"
    else
        pass "$skill_name description exists"
    fi
done

if ! python3 -m json.tool "$REPO_ROOT/.claude-plugin/marketplace.json" >/dev/null; then
    fail "marketplace.json is invalid JSON"
else
    pass "marketplace.json is valid JSON"
fi

if [ ! -d "$REPO_ROOT/plugins/agent-help" ]; then
    fail "plugins/agent-help Claude adapter is missing"
else
    pass "plugins/agent-help Claude adapter exists"
fi

if ! grep -q '"name": "agent-help"' "$REPO_ROOT/.claude-plugin/marketplace.json"; then
    fail "marketplace does not expose agent-help"
else
    pass "marketplace exposes agent-help"
fi

if grep -q '"name": "agent-cli"' "$REPO_ROOT/.claude-plugin/marketplace.json"; then
    fail "marketplace still exposes deprecated agent-cli"
else
    pass "deprecated agent-cli is not exposed in marketplace"
fi

adapter_skill="$REPO_ROOT/plugins/agent-help/skills/agent-help/SKILL.md"

if [ -f "$adapter_skill" ]; then
    if [ "$(frontmatter_value "$adapter_skill" "user-invocable")" = "true" ]; then
        pass "agent-help Claude adapter is user-invocable"
    else
        fail "agent-help Claude adapter should be user-invocable"
    fi

    if diff -u <(body_without_frontmatter "$REPO_ROOT/skills/agent-help/SKILL.md") <(body_without_frontmatter "$adapter_skill") >/dev/null; then
        pass "agent-help Claude adapter mirrors portable SKILL.md body"
    else
        fail "agent-help Claude adapter SKILL.md body differs from portable SKILL.md"
    fi
else
    fail "agent-help Claude adapter skill is missing"
fi

if [ -f "$REPO_ROOT/plugins/agent-help/skills/agent-help/references/REFERENCE.md" ]; then
    if cmp -s "$REPO_ROOT/skills/agent-help/references/REFERENCE.md" "$REPO_ROOT/plugins/agent-help/skills/agent-help/references/REFERENCE.md"; then
        pass "agent-help Claude adapter mirrors portable reference"
    else
        fail "agent-help Claude adapter reference differs from portable reference"
    fi
else
    fail "agent-help Claude adapter reference is missing"
fi

if [ "$failures" -gt 0 ]; then
    echo "Portable skill validation failed with $failures failure(s)."
    exit 1
fi

echo "Portable skill validation passed."
