# Claude Code Plugin Creation Guide

This guide describes how to create plugins for this marketplace as it exists today. The repository is skill-first: new user-facing capabilities should usually be implemented as `skills/<name>/SKILL.md`, not legacy `commands/*.md`.

## Repository Layout

```text
cc-plugins/
+-- .claude-plugin/
|   +-- marketplace.json
+-- plugins/
|   +-- your-plugin/
|       +-- .claude-plugin/
|       |   +-- plugin.json
|       +-- skills/
|       |   +-- your-skill/
|       |       +-- SKILL.md
|       +-- agents/
|       +-- hooks/
|       +-- scripts/
|       +-- .mcp.json
|       +-- README.md
+-- templates/
+-- docs/
```

Only `.claude-plugin/plugin.json` is required. Add other directories only when the plugin needs them.

## Component Choices

| Component | Use when | Location |
|-----------|----------|----------|
| Skill | You need a slash entry point or reusable domain expertise | `skills/<name>/SKILL.md` |
| Agent | You need a specialized delegated worker | `agents/*.md` |
| Hook | You need lifecycle automation | `hooks/hooks.json` plus scripts |
| Script | You need repeatable shell logic | `scripts/*` |
| MCP server | You integrate external tools | `.mcp.json` |
| Legacy command | You maintain old command-style plugins | `commands/*.md` |

For new work in this repo, prefer skills.

## Create a Plugin

1. Copy the template:

   ```bash
   cp -r templates/plugin-template plugins/your-plugin-name
   ```

2. Edit `plugins/your-plugin-name/.claude-plugin/plugin.json`.

3. Add one or more skills under `skills/`.

4. Write `plugins/your-plugin-name/README.md`.

5. Add the plugin to `.claude-plugin/marketplace.json`.

6. Test local installation:

   ```bash
   /plugin install /absolute/path/to/cc-plugins/plugins/your-plugin-name
   ```

7. If installed, run plugin lint:

   ```bash
   /plugin-lint:lint plugins/your-plugin-name
   ```

## Manifest

Required file: `plugins/<name>/.claude-plugin/plugin.json`

```json
{
  "name": "your-plugin-name",
  "version": "0.1.0",
  "description": "Brief, accurate description of what this plugin does",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "homepage": "https://github.com/your/repo",
  "repository": "https://github.com/your/repo",
  "license": "MIT",
  "keywords": ["claude-code", "plugin"]
}
```

The `name` should match the plugin directory.

## Skills

Skills live at `skills/<skill-name>/SKILL.md`.

```markdown
---
name: skill-name
description: Clear trigger description for users and the model
argument-hint: "[optional arguments]"
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Bash
---

# Skill Name

Explain what Claude should do when this skill is invoked.

## When to Use

- Specific situations where this skill applies

## When NOT to Use

- Situations where another skill or normal reasoning is better

## Workflow

1. Inspect the project context.
2. Make the requested change or produce the requested artifact.
3. Verify the result.
```

Use `user-invocable: true` when the skill should be callable explicitly. A user-invocable skill named `scan` in the `security` plugin is invoked as `/security:scan`.

Common fields:

| Field | Purpose |
|-------|---------|
| `name` | Skill name |
| `description` | Trigger and listing text |
| `argument-hint` | Short usage hint |
| `user-invocable` | Exposes slash entry point |
| `disable-model-invocation` | Prevents automatic model selection |
| `allowed-tools` | Tools the skill may use |
| `when_to_use` | Extra trigger guidance |
| `context` / `agent` | Optional execution behavior |

Use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative scripts and `${CLAUDE_SKILL_DIR}` for files beside the skill.

## Agents

Agents live at `agents/<agent-name>.md`.

```markdown
---
name: triage-agent
description: Investigates scan findings and classifies false positives
model: sonnet
tools:
  - Read
  - Grep
  - Bash
---

You are a focused agent for ...
```

Add agents when a plugin benefits from specialization, background work, or parallel delegation. Keep the agent's responsibility narrow and document the expected output.

## Hooks

Hooks are configured in `hooks/hooks.json` and usually call scripts in `hooks/` or `scripts/`.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

Hook guidance:

- Keep hooks fast and fail gracefully.
- Use `${CLAUDE_PLUGIN_ROOT}` for paths.
- Prefer concise user-visible summaries.
- Avoid empty placeholder hooks.
- Test on the platforms the plugin claims to support.
- For `PreToolUse`, prefer `hookSpecificOutput.permissionDecision` (`allow`, `deny`, or `ask`) over deprecated top-level `decision`.
- Use deterministic command hooks for cheap checks. Reserve prompt hooks for cases where static checks cannot make a reliable decision.

Example `PreToolUse` response:

```json
{
  "suppressOutput": true,
  "systemMessage": "Blocked: secret literal detected.",
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "AWS access key literal detected in code change."
  }
}
```

## Scripts

Scripts should be idempotent and agent-friendly. Prefer a short summary line followed by structured details when useful.

```bash
echo "plugin-name: status=ok checks=3"
```

Do not hide important failures. Exit nonzero when the skill or hook should know the script failed.

Write shell scripts for the oldest shell you claim to support. This repo's cross-platform hooks should avoid Bash 4-only features such as associative arrays unless the plugin explicitly requires a newer Bash.

## README Requirements

Every plugin README should include:

- What the plugin does.
- Installation instructions.
- Main slash entry points or automatic behavior.
- Requirements and external dependencies.
- Configuration files or environment variables.
- Output artifacts.
- Troubleshooting notes when relevant.

## Marketplace Entry

Add your plugin to `.claude-plugin/marketplace.json`:

```json
{
  "name": "your-plugin-name",
  "source": "./plugins/your-plugin-name",
  "description": "Same practical description users see in the marketplace",
  "category": "development",
  "tags": ["tag-one", "tag-two"]
}
```

Use an existing category where possible. Keep tags concrete and searchable.

## Quality Checklist

- [ ] Plugin manifest is valid JSON.
- [ ] Manifest `name` matches the directory name.
- [ ] README describes current behavior, not planned behavior.
- [ ] User-invocable skills include clear `description` and `argument-hint`.
- [ ] Model-invoked skills have precise trigger descriptions.
- [ ] Hooks are necessary, fast, and tested.
- [ ] PreToolUse hooks use current `permissionDecision` output.
- [ ] Scripts handle missing dependencies cleanly.
- [ ] Scripts avoid platform-specific flags unless guarded or documented.
- [ ] External tools and MCP requirements are documented.
- [ ] Local install has been tested.
- [ ] Marketplace entry is present and accurate.

## Naming

- Plugin names: kebab-case, short, descriptive.
- Skill directories: kebab-case.
- Agents: kebab-case markdown files.
- Scripts: kebab-case shell or PowerShell files.
- Slash entry points are derived from plugin and skill names, for example `/devloop:plan`.

## Legacy Commands

Claude Code still supports `commands/*.md`, but this repository has moved away from that pattern. Use legacy commands only when maintaining an existing plugin that already depends on them. For new plugins, create user-invocable skills instead.
