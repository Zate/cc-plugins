# ctx — Persistent Memory for Claude Code

A Claude Code plugin that gives agents structured, persistent memory across sessions using a knowledge graph backed by SQLite.

## What It Does

- **SessionStart**: Auto-installs the `ctx` binary if needed, composes stored knowledge, and injects it into context with enforcement instructions
- **Stop**: Parses `<ctx:*>` commands from the agent's responses and persists them to the database
- **UserPromptSubmit**: Injects pending recall results and nudges the agent if no knowledge has been stored yet

## Installation

Install the plugin in Claude Code. On first session, the `ctx` binary will be automatically downloaded from [GitHub releases](https://github.com/Zate/Memdown/releases) and the database initialized.

## Commands

- `/ctx:setup` — Manual install and verification
- `/ctx:status` — Show memory stats (node counts, types, tiers)
- `/ctx:recall <query>` — Query stored knowledge mid-session

## How It Works

Agents store knowledge by including XML commands in their responses:

```xml
<ctx:remember type="decision" tags="tier:reference,project:myproject">
Chose gRPC over REST for internal service communication.
</ctx:remember>
```

The Stop hook parses these commands and persists them to `~/.ctx/store.db`. On the next session start, stored knowledge is automatically composed and injected into context.

## Node Types

| Type | Purpose |
|------|---------|
| `fact` | Stable knowledge |
| `decision` | A choice with rationale |
| `pattern` | Recurring approach |
| `observation` | Current/temporary context |
| `hypothesis` | Unvalidated idea |
| `open-question` | Unresolved question |

## Requirements

- macOS or Linux (amd64 or arm64)
- `curl` for binary download
- `jq` recommended (fallback works without it)
