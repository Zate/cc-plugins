# Getting Started with CC-Plugins

Install the marketplace, add the plugins you need, then invoke the slash entry points provided by their skills.

## Prerequisites

You need Claude Code installed and running. If needed, visit [claude.ai/code](https://claude.ai/code).

## Install

```bash
/plugin marketplace add Zate/cc-plugins
/plugin install devloop
```

Recommended extras:

```bash
/plugin install ctx
/plugin install security
```

## First Workflow: devloop

devloop is the main development workflow plugin. The normal loop is:

```bash
/devloop:plan "add a dark mode toggle to settings"
/devloop:run
/devloop:review
/devloop:ship
```

For small fixes:

```bash
/devloop:plan --quick "fix typo in the header"
/devloop:run
```

For deeper exploration:

```bash
/devloop:plan --deep "should this service use OAuth or JWT?"
```

When the session gets large:

```bash
/devloop:fresh
/clear
/devloop:run
```

Plans are stored in `.devloop/plan.md`, so `/devloop:run` can continue from a later session.

## Other Useful Plugins

| Plugin | Install | Main use |
|--------|---------|----------|
| `ctx` | `/plugin install ctx` | Persistent memory across sessions |
| `security` | `/plugin install security` | SAST-backed security scanning |
| `diagrams` | `/plugin install diagrams` | Generate SVG, Mermaid, Excalidraw, or D2 diagrams |
| `plugin-lint` | `/plugin install plugin-lint` | Validate plugins, skills, and hooks |
| `agent-cli` | `/plugin install agent-cli` | Design CLIs with `--agent-help` |
| `forge` | `/plugin install forge` | Submit headless background agent jobs |
| `blog-writer` | `/plugin install blog-writer` | Create blog posts through an interview workflow |
| `wsl-clipboard-fix` | `/plugin install wsl-clipboard-fix` | Fix image paste on WSL2 |

## First Security Workflow

The security plugin combines deterministic scanners with LLM triage. Start by creating a project profile, then scan:

```bash
/security:setup       # Inspect available scanners; installs only with approval
/security:baseline    # Create .security/profile.json and suppression policy
/security:scan        # Standard scan with triage
```

For pull request or local-change checks:

```bash
/security:scan --diff
```

For a deeper pass:

```bash
/security:scan --deep
```

To handle findings:

```bash
/security:results
/security:fix finding-003
/security:scan --suppress finding-004
```

Scan output lives under `.security/`. The baseline workflow keeps policy files such as `.security/profile.json` and `.security/suppressions.json` separate from generated artifacts.

## Common Commands

| What you want | Command |
|---------------|---------|
| Start a development plan | `/devloop:plan "task"` |
| Execute the current plan | `/devloop:run` |
| Preserve state before clearing context | `/devloop:fresh` |
| Review current changes | `/devloop:review` |
| Validate, commit, and create a PR | `/devloop:ship` |
| List GitHub issues | `/devloop:issues` |
| Check persistent memory | `/ctx:status` |
| Search memory | `/ctx:recall type:decision` |
| Create security baseline | `/security:baseline` |
| Run security scan | `/security:scan` |
| Scan changed files | `/security:scan --diff` |
| Fix a security finding | `/security:fix finding-003` |
| Show latest security report | `/security:results` |
| Lint a plugin | `/plugin-lint:lint plugins/devloop` |

## How Plugins Work Here

Most plugins in this repository expose capabilities through skills in `skills/<name>/SKILL.md`. Some skills are user-invocable and appear as slash commands, such as `/devloop:plan` or `/security:scan`. Other skills are loaded automatically when Claude needs their domain knowledge.

Legacy `commands/` directories are not the main pattern in this repo.

## Troubleshooting

### "Plugin not found"

```bash
/plugin marketplace add Zate/cc-plugins
/plugin install devloop
```

### "Command not recognized"

Restart Claude Code after installing or updating plugins.

### "A skill did not activate"

Use the explicit slash form when available, for example `/devloop:plan`, `/ctx:status`, or `/security:scan`.

## Next

- Read the [devloop README](../plugins/devloop/README.md)
- Keep the [Quick Reference](QUICK_REFERENCE.md) handy
- See [Plugin Creation Guide](PLUGIN_CREATION_GUIDE.md) if you are building a new plugin
