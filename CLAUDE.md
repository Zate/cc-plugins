# Claude Code Plugin Marketplace

This repository is a marketplace for Claude Code plugins.

## Repository Structure
```
cc-plugins/
├── .claude-plugin/
│   └── marketplace.json    # Marketplace configuration
├── plugins/                # Individual plugins
├── CLAUDE.md              # High-level guide
└── .claude/rules/         # Context-specific rules
```

## Key Guidance
- **Plugin Structure**: See `.claude/rules/plugin-guidelines.md` (auto-activates in `plugins/**`)
- **Devloop Patterns**: See `.claude/rules/devloop-patterns.md` (auto-activates in `plugins/devloop/**`)
- **Key Principles**: Documentation first, composable tools, secure inputs.

## Contributing
1. Copy `templates/plugin-template/`.
2. Update `.claude-plugin/plugin.json`.
3. Add entry to `.claude-plugin/marketplace.json`.
