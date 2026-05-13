# CC-Plugins

**A curated marketplace of Claude Code plugins and skills for development workflows.**

[![Plugins](https://img.shields.io/badge/plugins-9-blue)](.claude-plugin/marketplace.json) [![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-green)](https://code.claude.com) [![License](https://img.shields.io/badge/license-MIT-purple)](LICENSE)

---

## Quick Start

```bash
# Add this marketplace
/plugin marketplace add Zate/cc-plugins

# Install the main workflow plugin
/plugin install devloop

# Optional but useful companions
/plugin install ctx
/plugin install security
```

Start new work with devloop:

```bash
/devloop:plan "add user authentication"
/devloop:run
/devloop:ship
```

For a larger investigation, use `/devloop:plan --deep "topic"`. When context gets heavy, use `/devloop:fresh`, then `/clear`, then `/devloop:run`.

New to the marketplace? See [Getting Started](docs/GETTING_STARTED.md).

---

## Available Plugins

| Plugin | What it does | Components |
|--------|--------------|------------|
| [devloop](plugins/devloop) | Lightweight plan/run/fresh development workflow with git and PR support | 19 skills, 6 agents, hooks, scripts |
| [ctx](plugins/ctx) | Persistent memory backed by the external `ctx` SQLite knowledge graph | 5 skills, hooks, scripts |
| [security](plugins/security) | Hybrid security scanner: deterministic tools detect, LLM triages | 14 skills, 1 agent, hooks, scripts |
| [diagrams](plugins/diagrams) | Text-based diagram generation with SVG, Mermaid, Excalidraw, and D2 | 6 skills |
| [forge](plugins/forge) | Integration with the Forge headless agent job runner via MCP | 2 skills, hooks |
| [plugin-lint](plugins/plugin-lint) | Static correctness and quality linting for Claude Code plugins | 1 skill |
| [agent-cli](plugins/agent-cli) | Convention for agent-friendly CLIs using `--agent-help` | 1 skill |
| [blog-writer](plugins/blog-writer) | Interview-driven blog writing workflow with a de-AI editing agent | 1 skill, 1 agent |
| [wsl-clipboard-fix](plugins/wsl-clipboard-fix) | WSL2 image paste fix that converts BMP clipboard content to PNG | 1 skill, hooks, script |

The authoritative marketplace list lives in [.claude-plugin/marketplace.json](.claude-plugin/marketplace.json).

---

## How These Plugins Are Built

This repository is now skill-first. Most user-facing entry points are `skills/*/SKILL.md` files, not legacy `commands/*.md` files. User-invocable skills expose slash-style commands such as `/devloop:plan`, `/ctx:status`, `/security:scan`, and `/plugin-lint:lint`.

Common plugin components:

| Component | Location | Purpose |
|-----------|----------|---------|
| Manifest | `.claude-plugin/plugin.json` | Plugin metadata used by Claude Code |
| Skills | `skills/<name>/SKILL.md` | User-invocable commands and model-invoked expertise |
| Agents | `agents/*.md` | Specialized subagents for delegated work |
| Hooks | `hooks/hooks.json` plus scripts | Lifecycle automation |
| MCP | `.mcp.json` | External tool integrations |
| Scripts | `scripts/*` | Helper commands used by skills and hooks |

`commands/` is still valid for old-style slash commands, but new plugins in this repo should prefer skills.

---

## Featured: devloop

devloop is the main development workflow plugin.

```bash
/plugin install devloop

/devloop:plan "add user authentication"       # Explore and create .devloop/plan.md
/devloop:run                                  # Execute plan tasks
/devloop:fresh && /clear && /devloop:run      # Reset context and continue
/devloop:review                               # Review current changes
/devloop:ship                                 # Validate, commit, and create PR
```

Useful variants:

```bash
/devloop:plan --quick "fix typo in settings"
/devloop:plan --deep "should we use OAuth or JWT?"
/devloop:plan --from-issue 42
/devloop:run --interactive
```

Plans persist in `.devloop/plan.md`, so work can resume across sessions. See the [devloop README](plugins/devloop/README.md) for the full workflow.

---

## Installation Options

### From Marketplace

```bash
/plugin marketplace add Zate/cc-plugins
/plugin install devloop
```

Install any plugin by name after adding the marketplace:

```bash
/plugin install ctx
/plugin install security
/plugin install diagrams
```

### From a Local Checkout

```bash
/plugin install /absolute/path/to/cc-plugins/plugins/devloop
```

### Verify Installation

```bash
/plugin list
/plugin info devloop
```

---

## For Plugin Developers

Start from the template:

```bash
cp -r templates/plugin-template plugins/your-plugin-name
```

Required structure:

```text
plugins/your-plugin-name/
+-- .claude-plugin/
|   +-- plugin.json
+-- skills/
|   +-- your-skill/
|       +-- SKILL.md
+-- agents/
+-- hooks/
+-- scripts/
+-- .mcp.json
+-- README.md
```

Only `.claude-plugin/plugin.json` is required. Add the component directories your plugin actually needs.

Before submitting:

1. Keep the plugin focused and documented.
2. Prefer skills over legacy `commands/`.
3. Test local installation with `/plugin install /absolute/path/to/plugins/your-plugin-name`.
4. Add an entry to [.claude-plugin/marketplace.json](.claude-plugin/marketplace.json).
5. Run plugin linting when relevant: `/plugin-lint:lint plugins/your-plugin-name`.

See [Plugin Creation Guide](docs/PLUGIN_CREATION_GUIDE.md), [CONTRIBUTING.md](CONTRIBUTING.md), and [CLAUDE.md](CLAUDE.md) for the detailed development rules.

---

## Documentation

| Resource | Description |
|----------|-------------|
| [Getting Started](docs/GETTING_STARTED.md) | First install and common workflows |
| [Quick Reference](docs/QUICK_REFERENCE.md) | Copy-paste commands |
| [Architecture](ARCHITECTURE.md) | Repository layout and component model |
| [Plugin Creation Guide](docs/PLUGIN_CREATION_GUIDE.md) | How to create plugins in this repo |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guidelines |
| [devloop README](plugins/devloop/README.md) | Full devloop documentation |

---

## Support

- **Issues**: [GitHub Issues](https://github.com/Zate/cc-plugins/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Zate/cc-plugins/discussions)
- **Official Docs**: [code.claude.com/docs](https://code.claude.com/docs)

## License

Each plugin may have its own license. See individual plugin manifests for details. The marketplace infrastructure is [MIT licensed](LICENSE).
