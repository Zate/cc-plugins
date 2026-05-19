# agent-help

Agent Skills-compatible guidance for implementing agent-native CLI surfaces.

`agent-help` supersedes the older `agent-cli` plugin. It teaches agents to add:

- `--agent-help` for AHF invocation help
- `--agent-out` for AHF envelope + TOON runtime results
- `err`/`hint`/`use` error responses that let agents self-correct

## Install As A Claude Code Plugin

```bash
/plugin marketplace add Zate/cc-plugins
/plugin install agent-help
```

## Install As A Portable Agent Skill

From this repo:

```bash
npx skills add . -g -a claude-code -a codex -a rovodev -a pi --skill agent-help
```

From the upstream source repo:

```bash
npx skills add Zate/agent-help -g -a claude-code -a codex -a rovodev -a pi --skill agent-help
```

The portable source copy in this repo lives at [`../../skills/agent-help`](../../skills/agent-help). The upstream source project remains [`Zate/agent-help`](https://github.com/Zate/agent-help).
