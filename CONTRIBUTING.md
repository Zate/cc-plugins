# Contributing to CC-Plugins Marketplace

Thank you for your interest in contributing to the Claude Code plugin marketplace! This document provides guidelines for contributing plugins and improvements.

## How to Contribute

### Contributing a Plugin

1. **Check for duplicates**: Search existing plugins to avoid duplication
2. **Use the template**: Copy `templates/plugin-template/` as your starting point
3. **Follow the structure**: Adhere to the official Claude Code plugin structure
4. **Test thoroughly**: Test your plugin locally before submitting
5. **Document well**: Write clear README with examples and usage instructions
6. **Submit PR**: Add your plugin to the marketplace

### Step-by-Step Plugin Submission

1. **Fork and clone** this repository

2. **Create your plugin**:
   ```bash
   cp -r templates/plugin-template plugins/your-plugin-name
   cd plugins/your-plugin-name
   ```

3. **Update plugin metadata**:
   - Edit `.claude-plugin/plugin.json` with your plugin details
   - Use kebab-case for the plugin name
   - Follow semantic versioning (0.1.0 for new plugins)

4. **Implement your plugin**:
   - Add commands to `commands/`
   - Add agents to `agents/`
   - Add skills to `skills/skillname/SKILL.md`
   - Configure hooks if needed
   - Add MCP configuration if needed
   - Remove unused directories

5. **Write documentation**:
   - Update `README.md` with comprehensive usage instructions
   - Include examples and common use cases
   - Document any configuration or environment variables
   - Add troubleshooting section if applicable

6. **Test locally**:
   ```bash
   /plugin install /absolute/path/to/plugins/your-plugin-name
   # Test all functionality
   /plugin uninstall your-plugin-name
   ```

7. **Add to marketplace**:
   Edit `.claude-plugin/marketplace.json` and add:
   ```json
   {
     "name": "your-plugin-name",
     "source": "./plugins/your-plugin-name"
   }
   ```

8. **Submit Pull Request**:
   - Create a PR with a clear title: "Add plugin: your-plugin-name"
   - Describe what your plugin does
   - List any dependencies or requirements
   - Mention if this is a breaking change

## Plugin Quality Guidelines

### Required

- [ ] Valid `.claude-plugin/plugin.json` manifest
- [ ] Comprehensive README with examples
- [ ] Clear, descriptive plugin name (kebab-case)
- [ ] Semantic version number
- [ ] License specified
- [ ] Tested locally

### Recommended

- [ ] Skills include "when to use" and "when NOT to use" sections
- [ ] Commands have clear descriptions
- [ ] Error handling for edge cases
- [ ] Security considerations documented
- [ ] Examples for all major features
- [ ] Clean, focused implementation

### Code Quality

- **Security**: Never expose credentials, validate inputs, handle errors gracefully
- **Simplicity**: Keep components focused and single-purpose
- **Documentation**: Code should be clear and well-commented when needed
- **Testing**: Verify functionality works as expected
- **Compatibility**: Ensure it works with current Claude Code version

## Plugin Categories

When submitting, categorize your plugin:

- **Development Tools**: Coding assistance, build tools, testing
- **Documentation**: Documentation generation, API docs
- **Integration**: External service connections (APIs, databases)
- **Workflow**: Automation, project setup, common tasks
- **Domain-Specific**: Specialized knowledge (ML, DevOps, security, etc.)

## Review Process

1. **Automated checks**: PR will be checked for structure compliance
2. **Manual review**: Maintainers will review code quality and security
3. **Testing**: Plugin will be tested in a clean environment
4. **Feedback**: You may receive requests for changes
5. **Merge**: Once approved, plugin will be added to marketplace

## What Gets Accepted?

### We Accept

- Well-documented, useful plugins
- Domain-specific knowledge and workflows
- Integrations with popular tools/services
- Improvements to existing plugins (with author permission)
- Bug fixes and documentation improvements

### We May Reject

- Duplicate functionality without clear improvement
- Security vulnerabilities or unsafe code
- Insufficient documentation
- Overly complex or unfocused plugins
- Malicious or spam content

## Updating Your Plugin

To update an existing plugin:

1. Make changes to your plugin in `plugins/your-plugin-name/`
2. Update version in `.claude-plugin/plugin.json` (follow semver)
3. Update README with changelog
4. Test changes locally
5. Submit PR with clear description of changes

## Getting Help

- **Questions**: Open a GitHub Discussion
- **Bugs**: Open an Issue with reproduction steps
- **Ideas**: Open an Issue with the "enhancement" label
- **Documentation**: See [CLAUDE.md](./CLAUDE.md) for development guidance
- **Official Docs**: https://code.claude.com/docs/en/plugins.md

## Code of Conduct

- Be respectful and constructive
- Help others learn and improve
- Focus on technical merit
- Welcome newcomers
- Follow the golden rule

## License

By contributing, you agree that your contributions will be licensed under the same license as the plugin you're contributing to (specified in your plugin's manifest).

---

Thank you for contributing to the Claude Code community!
