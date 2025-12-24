# CC-Plugins

**A curated marketplace of high-quality Claude Code plugins for professional development workflows.**

[![Plugins](https://img.shields.io/badge/plugins-1-blue)](.claude-plugin/marketplace.json) [![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-green)](https://code.claude.com) [![License](https://img.shields.io/badge/license-MIT-purple)](LICENSE)

---

## Quick Start

```bash
# Add this marketplace
/plugin marketplace add Zate/cc-plugins

# Install the devloop plugin
/plugin install devloop

# Start with exploration (recommended)
/devloop:spike How should I implement user authentication?

# Save state and clear context
/devloop:fresh
/clear

# Resume work with fresh context
/devloop:continue
```

That's it. You're ready to go.

**New to plugins?** Check out the [Getting Started Guide](docs/GETTING_STARTED.md) for a complete walkthrough, or grab the [Quick Reference](docs/QUICK_REFERENCE.md) cheat sheet.

### The Recommended Workflow

devloop works best with the **spike → fresh → continue loop**:

1. **Spike first** - `/devloop:spike` explores and creates a solid plan
2. **Fresh regularly** - `/devloop:fresh` + `/clear` resets context every 5-10 tasks
3. **Continue seamlessly** - `/devloop:continue` picks up exactly where you left off

This pattern keeps responses fast and focused while maintaining progress.

---

## Available Plugins

| Plugin | Description | Components |
|--------|-------------|------------|
| **[devloop](plugins/devloop)** | Token-conscious feature development workflow with codebase refactoring analysis, 17 specialized agents, 22 skills, task completion enforcement, and strategic model selection | 17 agents, 11 commands, 22 skills |

---

## Featured: devloop

The flagship plugin for professional software development. A complete 12-phase workflow from requirements through deployment, plus codebase refactoring analysis.

```bash
/plugin install devloop

# The recommended workflow: spike → fresh → continue loop
/devloop:spike How should we add user authentication?
/devloop:fresh
/clear
/devloop:continue  # Work on tasks...
/devloop:fresh     # After 5-10 tasks
/clear
/devloop:continue  # Keep going...

# Other powerful commands
/devloop:analyze   # Find tech debt and refactoring opportunities
/devloop:quick Fix the typo in the header
/devloop:review    # Code review before shipping
```

**Why devloop?**

- **Fresh Start Loop**: Clear context regularly for faster, more focused responses
- **Token-conscious**: Strategic model selection (20% opus / 60% sonnet / 20% haiku)
- **Workflow Loop**: Mandatory checkpoints ensure tasks are actually completed
- **Consolidated Agents**: 9 super-agents (down from 18) with multi-mode operation
- **Refactoring Analysis**: Identify technical debt, large files, and code quality issues
- **Language-aware**: Built-in patterns for Go, React, Java, and Python
- **Quality-focused**: Security scanning, code review, and Definition of Done validation

**Recent Updates (v2.2.1)**:
- Fresh start mechanism for context management
- Workflow loop enforcement with mandatory checkpoints
- Spike-to-plan application workflow
- Agent consolidation reducing token overhead
- Unified issue tracking system

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
