# CC-Plugins Quick Reference

Copy-paste commands for common tasks.

## Marketplace

```bash
/plugin marketplace add Zate/cc-plugins
/plugin install devloop
/plugin list
```

## devloop

| Task | Command |
|------|---------|
| Start a plan | `/devloop:plan "add feature X"` |
| Quick plan | `/devloop:plan --quick "fix small bug"` |
| Deep exploration | `/devloop:plan --deep "evaluate migration options"` |
| Start from GitHub issue | `/devloop:plan --from-issue 42` |
| Execute plan | `/devloop:run` |
| Interactive execution | `/devloop:run --interactive` |
| Fresh context handoff | `/devloop:fresh` then `/clear` then `/devloop:run` |
| Review changes | `/devloop:review` |
| Ship work | `/devloop:ship` |
| Archive completed plan | `/devloop:archive` |
| List issues | `/devloop:issues` |
| Create issue | `/devloop:new "bug title"` |
| Configure statusline | `/devloop:statusline` |

Project files:

| File | Purpose |
|------|---------|
| `.devloop/plan.md` | Current plan and task state |
| `.devloop/local.md` | Local project preferences |
| `.devloop/archive/` | Completed plans |

## ctx

```bash
/plugin install ctx
/ctx:status
/ctx:recall type:decision
/ctx:cleanup
```

The backing CLI is also available to agents:

```bash
ctx --agent-help
ctx status --agent-out
ctx recall 'type:decision AND tag:tier:reference' --agent-out
```

## security

```bash
/plugin install security
/security:setup
/security:baseline
/security:scan
/security:scan --quick
/security:scan --deep
/security:scan --diff
/security:scan --diff --diff-base HEAD~3
/security:scan --path src/api
/security:results
/security:fix finding-003
/security:scan --suppress finding-004
```

Security project files:

| File | Purpose |
|------|---------|
| `.security/profile.json` | Project exposure and severity context |
| `.security/suppressions.json` | Persistent false-positive suppressions |
| `.security/report.md` | Latest human-readable report |
| `.security/triaged.json` | Latest triaged findings |
| `.security/artifacts/` | Raw scanner outputs |

Typical flow:

```bash
/security:baseline
/security:scan --diff
/security:fix finding-003
```

## diagrams

```text
Draw a sequence diagram showing the OAuth2 authorization code flow
Create a Mermaid flowchart for the CI/CD pipeline
Generate a D2 diagram of the deployment topology
Draw this as an SVG threat model
```

## plugin-lint

```bash
/plugin install plugin-lint
/plugin-lint:lint plugins/devloop
/plugin-lint:lint plugins/devloop --static-only
/plugin-lint:lint plugins/devloop --fix
```

## Other Plugins

```bash
/plugin install agent-cli
/plugin install forge
/plugin install blog-writer
/plugin install wsl-clipboard-fix
```

| Plugin | Main entry point |
|--------|------------------|
| `agent-cli` | `/agent-cli` |
| `forge` | `/forge:setup`, `/forge:use` |
| `blog-writer` | `/blog` |
| `wsl-clipboard-fix` | Automatic hooks, setup skill for troubleshooting |

## Links

- [Getting Started](GETTING_STARTED.md)
- [devloop README](../plugins/devloop/README.md)
- [Architecture](../ARCHITECTURE.md)
