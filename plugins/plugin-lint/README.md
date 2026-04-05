# plugin-lint

Static correctness linter and quality orchestrator for Claude Code plugins, skills, and hooks.

## What it does

Runs in two layers:

**Layer 1 — Static Correctness** (unique, source-verified)
Catches errors that silently break things based on Claude Code internals:
- Invalid hook output schemas (e.g., `PreCompact` with `hookSpecificOutput`, `updatedMCPToolOutput` on built-in tools)
- Wrong input field names (`tool_output` vs `tool_response`)
- Invalid `if` condition syntax (JS expressions vs permission-rule syntax)
- Nonexistent frontmatter fields (`when_not_to_use`)
- Find-and-replace body corruption (frontmatter keys leaking into YAML blocks)
- SessionStart matchers missing `clear`
- Empty placeholder hooks adding latency for nothing
- No-op `paths: ["**/*"]` wildcards

**Layer 2 — Quality Delegation** (orchestrated)
Delegates description optimization to `skill-creator`, which runs the trigger eval loop and returns improved descriptions with before/after scores.

## Usage

```bash
# Lint a whole plugin
/plugin-lint:lint plugins/devloop

# Lint a single skill
/plugin-lint:lint plugins/devloop/skills/run

# Lint only hooks
/plugin-lint:lint plugins/ctx/hooks

# Static analysis only (skip description optimization)
/plugin-lint:lint plugins/devloop --static-only

# Auto-fix all HIGH severity issues
/plugin-lint:lint plugins/devloop --fix
```

## Installation

```bash
/plugin install /path/to/cc-plugins/plugins/plugin-lint
```

## Reference Data

The `skills/lint/references/` directory contains source-verified lookup tables:
- `hook-schemas.md` — valid `hookSpecificOutput` fields per event type
- `frontmatter-fields.md` — valid frontmatter keys for skills and agents
- `common-mistakes.md` — top 10 failure patterns with source citations and fixes

These are based on direct source code audit of `~/projects/claude-code/src` (April 2026).
