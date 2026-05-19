# agent-cli

Deprecated compatibility package for the older agent-friendly CLI convention.

Use [`agent-help`](../agent-help) for new work. `agent-help` supersedes `agent-cli` with the current AHF-based `--agent-help` convention and recommended `--agent-out` runtime result format.

Existing direct installs of `plugins/agent-cli` remain usable as a compatibility bridge, but the Claude Code marketplace entry now points to `agent-help`.

## Install The Replacement

```bash
/plugin marketplace add Zate/cc-plugins
/plugin install agent-help
```

For portable Agent Skills installation:

```bash
npx skills add . -g -a claude-code -a codex -a rovodev -a pi --skill agent-help
```
