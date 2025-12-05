# Claude Code Plugin Marketplace - Developer Guide

This repository is a marketplace for Claude Code plugins. This document provides guidance for agents working in this codebase on how to build, structure, and contribute plugins.

## Repository Structure

```
cc-plugins/
├── .claude-plugin/
│   └── marketplace.json    # Marketplace configuration (required)
├── plugins/                # Individual plugin directories
├── templates/              # Templates for creating new plugins
├── docs/                   # Additional documentation
├── CLAUDE.md              # This file - guidance for agents
├── CONTRIBUTING.md        # Contribution guidelines
└── README.md              # Public-facing marketplace documentation
```

## Official Plugin Structure

Each plugin MUST follow this structure:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json        # Required manifest file
├── commands/              # Optional: Custom slash commands (.md files)
├── agents/                # Optional: Agent definitions (.md files)
├── skills/                # Optional: Skills (subdirs with SKILL.md)
├── hooks/                 # Optional: Event handlers
├── .mcp.json             # Optional: MCP server configuration
└── README.md             # Plugin documentation
```

**Critical**: Component directories (commands/, agents/, skills/, hooks/) MUST be at plugin root, NOT inside .claude-plugin/

## Plugin Development Guidelines

### Plugin Manifest (plugin.json)

Required location: `.claude-plugin/plugin.json`

**Required field:**
- `name`: Unique identifier in kebab-case format

**Common metadata:**
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Brief plugin purpose",
  "author": "Your Name",
  "homepage": "https://github.com/...",
  "repository": "https://github.com/...",
  "license": "MIT"
}
```

### Component Types

1. **Commands**: Custom slash commands in `commands/` directory
   - Markdown files with frontmatter
   - Integrate into `/command-name` syntax

2. **Agents**: Specialized subagents in `agents/` directory
   - Claude invokes automatically based on context
   - Markdown files with capabilities and usage guidelines

3. **Skills**: Model-invoked capabilities in `skills/` subdirectories
   - Each skill has its own directory with `SKILL.md`
   - Claude autonomously determines when to apply
   - Include "when to use" and "when NOT to use" sections

4. **Hooks**: Event handlers responding to lifecycle events
   - Configure via `hooks.json` or inline in `plugin.json`
   - Support validation, automation, and notifications

5. **MCP Servers**: External tool integrations
   - Configure in `.mcp.json`
   - Start automatically when plugin activates

### Environment Variables

Use `${CLAUDE_PLUGIN_ROOT}` for absolute plugin directory paths in:
- Hook scripts
- MCP configurations
- Any file references

### Best Practices

1. **Naming**: Use kebab-case for plugin names
2. **Versioning**: Follow semantic versioning (major.minor.patch)
3. **Documentation**: Comprehensive README with examples
4. **Testing**: Test locally before submitting to marketplace
5. **Security**: Never expose credentials, validate all inputs
6. **Focused Tools**: Single-purpose, composable functionality
7. **Clear Scope**: Define when skills/agents should be invoked

## Development Workflow

### Creating a New Plugin

1. Copy the plugin template from `templates/plugin-template/`
2. Update `.claude-plugin/plugin.json` with your metadata
3. Implement components in appropriate directories:
   - Add commands to `commands/`
   - Add agents to `agents/`
   - Add skills to `skills/skillname/SKILL.md`
   - Configure hooks if needed
   - Add MCP servers if integrating external tools
4. Write comprehensive README with usage examples
5. Test locally: `/plugin install /path/to/your/plugin`
6. Submit PR to add plugin entry to `.claude-plugin/marketplace.json`

**Pro tip**: When creating skills, use the `skill-creator` skill to help design effective skills:
```bash
/skill skill-creator
```
This built-in skill provides guidance on creating high-quality skills with proper structure and best practices.

### Adding Plugin to Marketplace

Edit `.claude-plugin/marketplace.json` and add entry to `plugins` array:

```json
{
  "name": "your-plugin-name",
  "source": "./plugins/your-plugin-name"
}
```

### Local Testing

```bash
# Install plugin locally for testing
/plugin install /absolute/path/to/plugin-directory

# List installed plugins
/plugin list

# Uninstall for iterative testing
/plugin uninstall plugin-name
```

### Debugging

Run Claude Code with debug flag:
```bash
claude --debug
```

This shows plugin loading, manifest validation, and component registration.

## Official Documentation References

**Do NOT recreate documentation that exists on the Claude Code site. Reference it instead:**

- [Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces.md) - Marketplace structure and distribution
- [Plugins Overview](https://code.claude.com/docs/en/plugins.md) - Plugin development guide
- [Plugin Reference](https://code.claude.com/docs/en/plugins-reference.md) - API reference and specifications
- [Skills Documentation](https://code.claude.com/docs/en/skills/overview) - Creating skills
- [Commands Documentation](https://code.claude.com/docs/en/commands) - Custom slash commands

## Key Principles

### For All Plugins
- **Quality over Quantity**: Well-designed, useful additions
- **Documentation First**: Good docs are as important as good code
- **User-Centric**: Think about developer experience
- **Composability**: Work well with existing tools
- **Security**: Validate inputs, handle errors gracefully

### Plugin Organization
- Follow the official directory structure exactly
- Use environment variables for portability
- Keep components focused and single-purpose
- Include clear invocation criteria for skills/agents

## Marketplace Structure

This repository uses the official marketplace format:

- **Location**: `.claude-plugin/marketplace.json`
- **Required fields**: name, owner, plugins array
- **Plugin sources**: Relative paths, GitHub repos, or Git URLs
- **Distribution**: Via GitHub (recommended) or other Git hosting

Users add this marketplace via:
```bash
/plugin marketplace add YOUR_USERNAME/cc-plugins
```

## Getting Help

When working in this repository:
- Reference official Claude Code docs for implementation details
- Check existing plugins in `plugins/` for patterns
- Use the plugin template in `templates/plugin-template/`
- Test thoroughly before submitting
- Follow the contribution guidelines in CONTRIBUTING.md

---

**Remember**: Build plugins that solve real problems and that you would want to use yourself.
