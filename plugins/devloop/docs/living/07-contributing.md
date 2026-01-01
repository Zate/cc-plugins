# Contributing to Devloop

Guidelines for extending devloop.

---

## Setup

```bash
# Clone
git clone https://github.com/Zate/cc-plugins.git
cd cc-plugins

# Install locally
/plugin install /path/to/cc-plugins/plugins/devloop

# Debug mode
claude --debug
```

---

## Adding Components

### Command

1. Create `commands/my-command.md`
2. Add frontmatter and phases
3. Use checkpoints between phases

### Agent

1. Create `agents/my-agent.md`
2. Define capabilities
3. Add to agent list in docs

### Skill

1. Create `skills/my-skill/SKILL.md`
2. Include whenToUse/whenNotToUse
3. Add to `skills/INDEX.md`

---

## Versioning

- Patch (3.1.0 → 3.1.1): Bug fixes
- Minor (3.1.x → 3.2.0): New features
- Major (3.x → 4.0.0): Breaking changes

Update: `plugin.json`, `README.md`

---

## Commits

Use conventional commits:

```
feat(commands): add archive command
fix(hooks): handle missing plan
docs(skills): update go-patterns
```

---

## Pull Requests

1. Test locally with `/plugin install`
2. Update documentation
3. Follow commit conventions

---

## Getting Help

- Issues: [GitHub Issues](https://github.com/Zate/cc-plugins/issues)
- Docs: [Principles](02-principles.md), [Component Guide](05-component-guide.md)
