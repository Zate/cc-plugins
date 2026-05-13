# CC-Plugins Architecture

This repository is a multi-plugin Claude Code marketplace. The root marketplace file points Claude Code at individual plugin directories under `plugins/`.

## Repository Shape

```text
cc-plugins/
+-- .claude-plugin/
|   +-- marketplace.json
+-- plugins/
|   +-- devloop/
|   +-- ctx/
|   +-- security/
|   +-- diagrams/
|   +-- forge/
|   +-- plugin-lint/
|   +-- agent-cli/
|   +-- blog-writer/
|   +-- wsl-clipboard-fix/
+-- templates/
+-- docs/
+-- tests/
```

The marketplace registry is [.claude-plugin/marketplace.json](.claude-plugin/marketplace.json). Each plugin has its own `.claude-plugin/plugin.json` manifest.

## Component Model

The repo is skill-first. New capabilities generally live in `skills/<name>/SKILL.md`.

| Component | Location | Current role |
|-----------|----------|--------------|
| Skills | `skills/*/SKILL.md` | Primary unit for commands and domain knowledge |
| Agents | `agents/*.md` | Specialized delegated workers |
| Hooks | `hooks/hooks.json`, hook scripts | Session lifecycle automation |
| Scripts | `scripts/*` | Helper executables for skills and hooks |
| MCP | `.mcp.json` | External server integration |
| Legacy commands | `commands/*.md` | Supported by Claude Code, but not the preferred repo pattern |

User-facing slash commands in this repo mostly come from user-invocable skills. For example, `plugins/devloop/skills/plan/SKILL.md` provides `/devloop:plan`.

## Plugin Inventory

| Plugin | Primary purpose | Notable components |
|--------|-----------------|--------------------|
| `devloop` | Plan/run/fresh development workflow | 19 skills, 6 agents, hooks, scripts |
| `ctx` | Persistent memory | 5 skills, hooks, installer/check scripts |
| `security` | Hybrid security scanning | 14 skills, 1 triage agent, scanner scripts |
| `diagrams` | Diagram generation | Router plus SVG, Mermaid, Excalidraw, D2 skills |
| `forge` | Headless agent job runner integration | MCP setup/use skills and session hook |
| `plugin-lint` | Plugin correctness linting | Static lint skill and reference data |
| `agent-cli` | Agent-friendly CLI convention | `--agent-help` design skill |
| `blog-writer` | Interview-driven blog creation | Blog skill plus de-AI editing agent |
| `wsl-clipboard-fix` | WSL2 image paste fix | Session hooks and `clip2png` script |

## Runtime Flow

```text
User prompt or slash command
        |
        v
User-invocable skill or model-selected skill
        |
        +--> reads plugin references
        +--> calls scripts or MCP tools
        +--> delegates to agents when useful
        |
        v
Project files, generated artifacts, or session context
```

Hooks run around this flow for plugins that need lifecycle behavior. Examples:

- `ctx` injects stored memory at session start and persists `<ctx:remember>` commands during the session.
- `devloop` detects and preserves plan state.
- `security` can scan or warn around tool use.
- `wsl-clipboard-fix` starts and stops its clipboard conversion daemon on WSL2.

## devloop and ctx

`devloop` and `ctx` are complementary but independent.

| devloop | ctx |
|---------|-----|
| Tracks the work to do | Remembers facts, decisions, and patterns |
| Persists plan state in `.devloop/plan.md` | Persists memory in `~/.ctx/store.db` |
| Optimizes context with `/devloop:fresh` | Injects relevant memory at session start |
| Handles git and PR workflows | Preserves cross-session knowledge |

## Design Principles

1. Prefer skills for new user-facing capabilities.
2. Keep plugin manifests minimal and accurate.
3. Put component directories at the plugin root, not inside `.claude-plugin/`.
4. Keep hooks fast, quiet, and failure-tolerant.
5. Use scripts for repeatable shell work and emit concise agent-friendly output.
6. Document each plugin from the user workflow first, then implementation details.

## Learn More

| Resource | What it covers |
|----------|----------------|
| [README](README.md) | Marketplace overview and plugin list |
| [Getting Started](docs/GETTING_STARTED.md) | Installation and first workflows |
| [Plugin Creation Guide](docs/PLUGIN_CREATION_GUIDE.md) | Creating or updating plugins |
| [CLAUDE.md](CLAUDE.md) | Maintainer guidance for agents |
| [devloop README](plugins/devloop/README.md) | devloop workflow details |
