# Claude Code Plugin Marketplace

A curated marketplace of Claude Code plugins to enhance your development workflows.

## What is This?

This is a community-driven marketplace for [Claude Code](https://code.claude.com) plugins. Plugins extend Claude Code with custom commands, specialized agents, skills, and integrations with external tools.

## Installation

Add this marketplace to your Claude Code installation:

```bash
/plugin marketplace add YOUR_USERNAME/cc-plugins
```

Then browse and install individual plugins:

```bash
/plugin list
/plugin install plugin-name
```

## Available Plugins

Currently, this marketplace is ready for plugin contributions. Browse the `plugins/` directory to see available plugins.

## For Plugin Developers

Want to contribute a plugin? Great! Here's how:

### Quick Start

1. **Copy the template**:
   ```bash
   cp -r templates/plugin-template plugins/your-plugin-name
   ```

2. **Update the manifest**:
   Edit `plugins/your-plugin-name/.claude-plugin/plugin.json`

3. **Build your plugin**:
   Add commands, agents, skills, or MCP integrations as needed

4. **Test locally**:
   ```bash
   /plugin install /absolute/path/to/plugins/your-plugin-name
   ```

5. **Submit**:
   Create a PR adding your plugin entry to `.claude-plugin/marketplace.json`

### Plugin Structure

Each plugin follows the official Claude Code structure:

```
your-plugin-name/
├── .claude-plugin/
│   └── plugin.json      # Required manifest
├── commands/            # Optional: slash commands
├── agents/              # Optional: specialized agents
├── skills/              # Optional: model-invoked capabilities
├── hooks/               # Optional: event handlers
├── .mcp.json           # Optional: MCP server config
└── README.md           # Plugin documentation
```

### Documentation

- **For developers working in this repo**: See [CLAUDE.md](./CLAUDE.md) for detailed guidance
- **For contributors**: See [CONTRIBUTING.md](./CONTRIBUTING.md) for submission guidelines
- **Official docs**: https://code.claude.com/docs/en/plugins.md

## Plugin Categories

Plugins can provide:

- **Commands**: Custom slash commands for common workflows
- **Agents**: Specialized subagents for complex tasks
- **Skills**: Domain-specific knowledge and best practices
- **Hooks**: Automation and workflow validation
- **MCP Integrations**: Connect to external tools and services

## Support

- **Documentation**: https://code.claude.com/docs/
- **Issues**: Create an issue in this repository
- **Discussions**: Use GitHub Discussions for questions and ideas

## License

Each plugin may have its own license. See individual plugin directories for details.

The marketplace infrastructure is MIT licensed.

## Contributing

We welcome contributions! Please read [CONTRIBUTING.md](./CONTRIBUTING.md) before submitting.

---

Built for the Claude Code community.
