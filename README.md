# CC-Plugins

**A curated marketplace of high-quality Claude Code plugins for professional development workflows.**

[![Plugins](https://img.shields.io/badge/plugins-3-blue)](.claude-plugin/marketplace.json) [![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-green)](https://code.claude.com) [![License](https://img.shields.io/badge/license-MIT-purple)](LICENSE)

---

## Quick Start

```bash
# Add this marketplace
/plugin marketplace add Zate/cc-plugins

# Install plugins
/plugin install devloop    # Workflow engine
/plugin install ctx        # Persistent memory (optional but recommended)
```

### The 4-Step Workflow

```bash
/devloop:plan "add user authentication"   # 1. Plan - explore and design
/devloop:run                               # 2. Build - implement autonomously
/devloop:ship                              # 3. Ship - commit and PR
# Repeat                                   # 4. Start next feature
```

That's it. Claude does the work. You stay in control.

**Need deep exploration?** Use `/devloop:plan --deep "topic"` for comprehensive analysis.

**Context getting heavy?** Use `/devloop:fresh && /clear && /devloop:run` every 5-10 tasks.

**New to plugins?** Check out the [Getting Started Guide](docs/GETTING_STARTED.md) for a complete walkthrough.

---

## Available Plugins

| Plugin | Description | Components |
|--------|-------------|------------|
| **[devloop](plugins/devloop)** | Development workflow engine with autonomous planning and execution | 13 commands, 7 agents, 15 skills |
| **[ctx](plugins/ctx)** | Persistent memory for Claude across sessions | 3 commands, 1 skill |
| **[security](plugins/security)** | OWASP ASVS-aligned security audits | 1 command, 17 agents |

---

## Featured: devloop

The flagship plugin for professional software development. Simple workflow: plan, build, ship, repeat.

```bash
/plugin install devloop

# The workflow
/devloop:plan "add user authentication"   # Plan with autonomous exploration
/devloop:run                               # Execute tasks autonomously
/devloop:ship                              # Commit and create PR

# Variations
/devloop:plan --deep "should we use OAuth?"  # Deep exploration first
/devloop:plan --quick "fix the typo"         # Skip planning for tiny tasks
/devloop:plan --from-issue 42                # Start from GitHub issue
```

**Why devloop?**

- **Claude does the work directly** - No routine agent spawning
- **Fresh context = better reasoning** - Clear after 5-10 tasks
- **Plans survive sessions** - Pick up where you left off
- **Language-aware skills** - Go, React, Java, Python patterns on demand
- **GitHub integration** - Issue-to-PR workflow

**v3.18 Highlights:**
- Consolidated commands with flag-based modes
- Autonomous execution with `/devloop:run`
- Simplified agent set (7 focused agents)
- 15 on-demand skills

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
| [Getting Started](docs/GETTING_STARTED.md) | New user guide - start here |
| [Quick Reference](docs/QUICK_REFERENCE.md) | Command cheat sheet |
| [devloop Documentation](plugins/devloop/README.md) | Full devloop plugin docs |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guidelines |
| [Plugin Creation Guide](docs/PLUGIN_CREATION_GUIDE.md) | Build your own plugins |
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
