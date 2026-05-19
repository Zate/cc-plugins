# Portable Skills

This directory contains Agent Skills-compatible skills intended to work across agent harnesses.

Each skill must be a directory whose name matches the `name` field in its `SKILL.md` frontmatter. Keep reusable, harness-neutral instructions here. Put Claude Code marketplace packaging, hooks, agents, MCP config, and other Claude-specific adapters under `plugins/`.

## Install

List available skills:

```bash
npx skills add . --list
```

Install all portable skills into common local agents:

```bash
npx skills add . \
  -g \
  -a rovodev \
  -a claude-code \
  -a codex \
  -a pi \
  --skill '*'
```

Install only `agent-help`:

```bash
npx skills add . -g -a claude-code -a codex --skill agent-help
```

## Validate

Use the Agent Skills reference validator when available:

```bash
skills-ref validate ./skills/agent-help
```

The broader migration plan lives in [`docs/PORTABLE_SKILLS_PLAN.md`](../docs/PORTABLE_SKILLS_PLAN.md).

## Claude Code Adapters

When a Claude Code marketplace plugin mirrors a portable skill, generate the adapter skill from the portable source:

```bash
CLAUDE_USER_INVOCABLE=true \
CLAUDE_ARGUMENT_HINT="[language/framework context, e.g. 'go cobra', 'python click']" \
  scripts/sync-portable-skill-adapter.sh agent-help
```

The sync script keeps the portable body and references as the source of truth while adding Claude-only frontmatter to the adapter copy.
