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

### Skill (Slash Command or Reference)

1. Create `skills/my-skill/SKILL.md`
2. Add frontmatter (`name`, `description`, `allowed-tools`)
3. For commands: add workflow phases with checkpoints
4. For reference skills: add domain knowledge content
5. Add to `skills/INDEX.md`

### Agent

1. Create `agents/my-agent.md`
2. Add frontmatter (`name`, `description`, `tools`, `model`, `maxTurns`)
3. Define capabilities and trigger conditions
4. Update agent lists in docs

---

## Versioning

See `CLAUDE.md` for full versioning guidelines. Summary:

- Patch (3.21.0 -> 3.21.1): Bug fixes, docs, refactoring
- Minor (3.21.x -> 3.22.0): New features (commands, agents, skills)
- Major (3.x -> 4.0.0): Breaking changes

Update: `plugin.json`, `CHANGELOG.md`, marketplace.json

---

## Commits

Use conventional commits:

```
feat(skills): add archive skill
fix(hooks): handle missing plan
docs(skills): update plan-management
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
