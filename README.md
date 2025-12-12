# CC-Plugins

**A curated marketplace of high-quality Claude Code plugins for professional development workflows.**

[![Plugins](https://img.shields.io/badge/plugins-3-blue)](.claude-plugin/marketplace.json)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-green)](https://code.claude.com)
[![License](https://img.shields.io/badge/license-MIT-purple)](LICENSE)

---

## Quick Start

```bash
# Add this marketplace
/plugin marketplace add Zate/cc-plugins

# Browse available plugins
/plugin list

# Install a plugin
/plugin install devloop
```

That's it. You're ready to go.

---

## Available Plugins

| Plugin | Description | Components |
|--------|-------------|------------|
| **[devloop](plugins/devloop)** | Token-conscious feature development workflow with 16 specialized agents, 17 skills, and strategic model selection | 16 agents, 9 commands, 17 skills |
| **[gd](plugins/gd)** | Comprehensive Godot game development with project setup, scene/UI templates, debugging, and performance optimization | 2 agents, 8 commands, 4 skills |
| **[code-refactor-analyzer](plugins/code-refactor-analyzer)** | Multi-language codebase analysis for refactoring opportunities with interactive vetting and actionable reports | 1 agent, 1 command, 1 skill |

---

## Featured: devloop

The flagship plugin for professional software development. A complete 12-phase workflow from requirements through deployment.

```bash
/plugin install devloop

# Start a new feature
/devloop Add user authentication with OAuth

# Resume work on an existing plan
/devloop:continue

# Quick implementation for small tasks
/devloop:quick Fix the typo in the header

# Code review
/devloop:review
```

**Why devloop?**

- **Token-conscious**: Strategic model selection (20% opus / 60% sonnet / 20% haiku)
- **Language-aware**: Built-in patterns for Go, React, Java, and Python
- **Agent-powered**: 16 specialized agents for exploration, architecture, testing, and review
- **Quality-focused**: Security scanning, code review, and Definition of Done validation

[Read the full devloop documentation →](plugins/devloop/README.md)

---

## What Can Plugins Do?

Claude Code plugins extend your development environment with:

| Component | Purpose | Example |
|-----------|---------|---------|
| **Commands** | Custom slash commands | `/devloop:quick Fix the bug` |
| **Agents** | Specialized subagents | `code-reviewer`, `test-generator` |
| **Skills** | Domain knowledge | `go-patterns`, `security-checklist` |
| **Hooks** | Event automation | Auto-detect project type on session start |
| **MCP Servers** | External integrations | Connect to databases, APIs, services |

---

## Installation Options

### From Marketplace (Recommended)

```bash
# Add marketplace
/plugin marketplace add Zate/cc-plugins

# Install specific plugin
/plugin install devloop
```

### Direct Install

```bash
# Install from local path
/plugin install /path/to/cc-plugins/plugins/devloop

# Install from GitHub
/plugin install https://github.com/Zate/cc-plugins/plugins/devloop
```

### Verify Installation

```bash
# List installed plugins
/plugin list

# Check plugin details
/plugin info devloop
```

---

## For Plugin Developers

Want to contribute a plugin? We maintain high quality standards.

### Quick Start

```bash
# Copy the template
cp -r templates/plugin-template plugins/your-plugin-name

# Update manifest
vim plugins/your-plugin-name/.claude-plugin/plugin.json

# Test locally
/plugin install /absolute/path/to/plugins/your-plugin-name
```

### Plugin Structure

```
your-plugin-name/
├── .claude-plugin/
│   └── plugin.json      # Required manifest
├── commands/            # Slash commands (.md)
├── agents/              # Specialized agents (.md)
├── skills/              # Domain knowledge (subdirs with SKILL.md)
├── hooks/               # Event handlers
├── .mcp.json           # MCP server config
└── README.md           # Documentation
```

### Quality Standards

All plugins in this marketplace must meet these standards:

**Skills:**
- Complete frontmatter (name, description)
- "When NOT to Use" section
- Version notes for language-specific patterns

**Agents:**
- Appropriate model selection (haiku/sonnet/opus)
- Clear differentiation from similar agents
- Tools list matching actual capabilities

**Commands:**
- Complete frontmatter including `argument-hint`
- Consistent section ordering
- Documented allowed-tools

**Hooks:**
- Proper JSON escaping for output
- Graceful error handling
- Performance-conscious implementation

See [PLUGIN_CREATION_GUIDE.md](docs/PLUGIN_CREATION_GUIDE.md) for complete standards.

### Submit Your Plugin

1. Fork this repository
2. Create your plugin in `plugins/your-plugin-name/`
3. Add entry to `.claude-plugin/marketplace.json`
4. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## Documentation

| Resource | Description |
|----------|-------------|
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guidelines |
| [CLAUDE.md](CLAUDE.md) | Agent guidance for this repo |
| [Plugin Creation Guide](docs/PLUGIN_CREATION_GUIDE.md) | Detailed plugin development guide |
| [Official Docs](https://code.claude.com/docs/en/plugins.md) | Claude Code plugin documentation |

---

## Support

- **Issues**: [GitHub Issues](https://github.com/Zate/cc-plugins/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Zate/cc-plugins/discussions)
- **Official Docs**: [code.claude.com/docs](https://code.claude.com/docs)

---

## License

Each plugin may have its own license. See individual plugin directories for details.

The marketplace infrastructure is [MIT licensed](LICENSE).

---

## Related Marketplaces

Looking for more plugins? Check out these community marketplaces:

- [jeremylongshore/claude-code-plugins-plus](https://github.com/jeremylongshore/claude-code-plugins-plus) - 240+ Agent Skills
- [kivilaid/plugin-marketplace](https://github.com/kivilaid/plugin-marketplace) - 87 plugins from 10+ sources
- [Dev-GOM/claude-code-marketplace](https://github.com/Dev-GOM/claude-code-marketplace) - Productivity and automation plugins

---

<p align="center">
  <strong>Built for developers who ship.</strong>
</p>
