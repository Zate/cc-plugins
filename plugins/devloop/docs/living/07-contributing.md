# Contributing to Devloop

Guidelines for extending and improving the devloop plugin.

---

## Getting Started

### Prerequisites

- Claude Code installed
- Git for version control
- Basic understanding of markdown

### Local Development Setup

```bash
# Clone the repository
git clone https://github.com/Zate/cc-plugins.git
cd cc-plugins

# Install the plugin locally for testing
/plugin install /path/to/cc-plugins/plugins/devloop

# Make changes, then reinstall to test
/plugin uninstall devloop
/plugin install /path/to/cc-plugins/plugins/devloop
```

### Debug Mode

Run Claude Code with debug flag to see plugin loading:

```bash
claude --debug
```

---

## Contribution Areas

### Commands

Commands are the most impactful contributions. They define user-facing workflows.

**To Add a New Command**:

1. Create `commands/my-command.md`
2. Add frontmatter:
   ```yaml
   ---
   description: What this command does
   aliases: [alias1, alias2]
   ---
   ```
3. Define phases with clear actions
4. Use `AskUserQuestion` for checkpoints
5. Invoke agents via `Task` tool for subtasks
6. Update `docs/commands.md` and README

**Command Checklist**:
- [ ] Phase-based structure
- [ ] Checkpoints between phases
- [ ] Agents for subtasks (not silent execution)
- [ ] State file updates where appropriate
- [ ] Documentation updated

---

### Agents

Agents are specialized helpers invoked by commands.

**To Add a New Agent**:

1. Create `agents/my-agent.md`
2. Define system role, capabilities, and model:
   ```yaml
   ---
   model: sonnet
   color: blue
   ---
   ```
3. Include clear workflow instructions
4. Reference relevant skills
5. Update `docs/agents.md`

**Agent Checklist**:
- [ ] Clear responsibility definition
- [ ] Appropriate model selection
- [ ] Mode detection if multi-modal
- [ ] Skills referenced
- [ ] Documentation updated

---

### Skills

Skills provide domain knowledge.

**To Add a New Skill**:

1. Create directory: `skills/my-skill/`
2. Create `SKILL.md` with frontmatter:
   ```yaml
   ---
   description: What this skill provides
   whenToUse: |
     - When to apply this skill
   whenNotToUse: |
     - When NOT to apply
   ---
   ```
3. Add practical, actionable content
4. Use `references/` for deep-dive content
5. Add to `skills/INDEX.md`

**Skill Checklist**:
- [ ] Clear whenToUse/whenNotToUse
- [ ] Actionable guidance (not just theory)
- [ ] Examples included
- [ ] Added to INDEX.md
- [ ] References for deep content

---

### Hooks

Hooks respond to lifecycle events.

**To Add a New Hook**:

1. Create script in `hooks/`
2. Add configuration to `hooks/hooks.json`:
   ```json
   {
     "name": "my-hook",
     "event": "SessionStart",
     "script": "${CLAUDE_PLUGIN_ROOT}/hooks/my-hook.sh"
   }
   ```
3. Make script executable
4. Use environment variables for paths
5. Handle errors gracefully

**Hook Checklist**:
- [ ] Fast execution
- [ ] Graceful error handling
- [ ] Uses `${CLAUDE_PLUGIN_ROOT}`
- [ ] Documented in hooks reference

---

## Design Guidelines

### Follow the Principles

Before contributing, review [Principles](02-principles.md). Key rules:

1. **Commands orchestrate, agents assist**
2. **Work in loops, not lines**
3. **Token consciousness**
4. **Mandatory checkpoints**
5. **State survives sessions**

### User Experience

- Keep questions clear and options limited (2-4)
- Always recommend when possible
- Don't re-ask decided questions
- Show progress, don't run silently

### Token Efficiency

- Use appropriate models (haiku/sonnet/opus)
- Load skills on-demand
- Keep descriptions brief
- Batch related questions

---

## Code Standards

### Markdown Files

- Use clear headers with `##`
- Include examples for complex concepts
- Keep tables readable
- Use code blocks with language hints

### Shell Scripts

```bash
#!/bin/bash
set -e  # Exit on error

# Use plugin root for paths
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"

# Handle missing files gracefully
if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 0  # Don't break workflow
fi
```

### JSON Files

- Use 2-space indentation
- Include comments in related docs (JSON doesn't support comments)
- Validate with schema where available

---

## Testing

### Manual Testing

1. Install plugin locally
2. Run through common workflows
3. Test edge cases (missing files, errors)
4. Verify state files update correctly

### Testing Checklist

- [ ] Command executes without errors
- [ ] Agent invocations work
- [ ] Skills load when referenced
- [ ] Hooks fire on events
- [ ] State files created/updated
- [ ] Fresh start/continue cycle works

---

## Versioning

We use semantic versioning:

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Bug fixes | Patch | 2.4.8 → 2.4.9 |
| New features (compatible) | Minor | 2.4.x → 2.5.0 |
| Breaking changes | Major | 2.x → 3.0.0 |

**Update version in**:
1. `.claude-plugin/plugin.json`
2. `CHANGELOG.md`
3. `README.md` badges

---

## Pull Request Process

### Before Submitting

1. Test locally with `/plugin install`
2. Update documentation
3. Add CHANGELOG entry
4. Follow commit message convention

### Commit Messages

Use conventional commits:

```
type(scope): description

feat(commands): add /devloop:archive command
fix(hooks): handle missing plan file gracefully
docs(skills): update go-patterns for Go 1.22
refactor(agents): consolidate engineer modes
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

### PR Description Template

```markdown
## Summary
Brief description of changes.

## Changes
- Added X
- Fixed Y
- Updated Z

## Testing
How was this tested?

## Checklist
- [ ] Documentation updated
- [ ] CHANGELOG entry added
- [ ] Version bumped (if appropriate)
- [ ] Tested locally
```

---

## Documentation

### Update When

- Adding new commands/agents/skills
- Changing behavior
- Fixing bugs
- Improving explanations

### Documentation Files

| File | Update For |
|------|------------|
| `README.md` | Feature additions, major changes |
| `CHANGELOG.md` | All changes |
| `docs/` files | Detailed documentation |
| `docs/living/` | Architecture/principle changes |

---

## Getting Help

### Resources

- [Architecture](01-architecture.md) - How devloop works
- [Principles](02-principles.md) - Design philosophy
- [Claude Code Docs](https://code.claude.com/docs/en/plugins) - Plugin system

### Asking Questions

- Open a GitHub issue for bugs
- Use discussions for questions
- Tag issues appropriately

---

## Recognition

Contributors are recognized in:
- CHANGELOG.md for each release
- README.md contributors section
- Git commit history

Thank you for contributing to devloop!

---

## Next Steps

- [Architecture](01-architecture.md) - Understand the system
- [Principles](02-principles.md) - Design philosophy
- [Component Guide](05-component-guide.md) - Component details
