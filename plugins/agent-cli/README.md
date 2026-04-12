# agent-cli

A convention for building CLIs that are optimized for LLM agent consumption.

## The Problem

`--help` output is designed for humans: verbose prose, grouped sections, multiple examples, flag aliases. Agents parse this poorly, waste tokens on it, and still get invocations wrong.

## The Solution

`--agent-help` — a single flag that returns token-minimal, structured output optimized for agents. Three tiers of progressive disclosure:

| Tier | Call | Purpose | Tokens |
|------|------|---------|--------|
| 1 | `tool --agent-help` | Command index | <300 |
| 2 | `tool --agent-help cmd` | Command detail | <150 |
| 3 | (on error) | Self-correction hint | <50 |

## Usage

Install the plugin, then use the skill when building any CLI:

```
/agent-cli
```

The skill provides the format spec, implementation patterns for Go/Python/Rust/Node, and the bootstrap breadcrumb convention for `--help`.

## Install

```bash
/plugin marketplace add Zate/cc-plugins
/plugin install agent-cli
```
