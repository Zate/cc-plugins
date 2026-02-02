# ctx — Persistent Memory for Claude Code

Claude Code agents are stateless. Every session starts from zero. **ctx fixes that.**

It's a Claude Code plugin that gives agents structured, persistent memory backed by a SQLite knowledge graph. Decisions, patterns, preferences, debugging insights — stored automatically and injected into every new session.

No more re-explaining your project conventions. No more re-discovering the same bugs. No more losing context when a session ends.

## How It Works

```
Session 1: You debug a tricky auth issue with Claude.
           Claude stores the root cause as an observation.

Session 2: You hit a related problem.
           Claude already knows what happened last time.
```

The lifecycle is fully automated via hooks:

1. **Session starts** — stored knowledge is composed and injected into context
2. **You work** — Claude includes `<ctx:remember>` commands in responses as it learns things
3. **Every prompt** — commands are parsed and persisted immediately (not just at session end)
4. **Session ends** — final sweep catches anything from the last response

Everything is stored in `~/.ctx/store.db` — a single SQLite file you own.

## Installation

Add the plugin to Claude Code. On first session, the `ctx` binary is automatically downloaded from [GitHub releases](https://github.com/Zate/Memdown/releases) and the database is initialized. No manual setup required.

To verify or manually install: `/ctx:setup`

## Commands

| Command | What it does |
|---------|-------------|
| `/ctx:status` | Node counts, types, tiers, token usage |
| `/ctx:recall <query>` | Query stored knowledge (e.g. `type:decision AND tag:project:myapp`) |
| `/ctx:setup` | Manual install and verification |

## What Gets Stored

Claude stores knowledge using XML commands in its responses:

```xml
<ctx:remember type="decision" tags="tier:reference,project:myproject">
Chose gRPC over REST for internal service communication due to
streaming requirements and type safety from protobuf.
</ctx:remember>
```

### Node Types

| Type | When to use |
|------|------------|
| `fact` | Stable knowledge, user preferences, conventions |
| `decision` | Choices with rationale |
| `pattern` | Recurring approaches or techniques |
| `observation` | Debugging insights, root causes |
| `hypothesis` | Ideas worth revisiting later |
| `open-question` | Unresolved questions to track |

### Tiers

Tiers control what gets loaded into context and when:

| Tier | Behavior |
|------|----------|
| `tier:pinned` | Always loaded — critical facts |
| `tier:reference` | Loaded by default — most knowledge |
| `tier:working` | Current task context — temporary |
| `tier:off-context` | Archived — not loaded unless queried |

## Advanced Commands

Claude can also use these in responses:

- **`<ctx:recall query="..."/>`** — query stored knowledge (results injected on next prompt)
- **`<ctx:status/>`** — check memory stats
- **`<ctx:task name="X" action="start|end"/>`** — mark task boundaries
- **`<ctx:link from="ID" to="ID" type="DEPENDS_ON"/>`** — connect related knowledge
- **`<ctx:summarize nodes="ID1,ID2">...</ctx:summarize>`** — condense multiple nodes
- **`<ctx:supersede old="ID" new="ID"/>`** — replace outdated knowledge

## Query Language

The recall command supports a query language with boolean operators:

```
type:decision AND tag:project:myapp
type:fact OR type:pattern
tag:tier:reference AND created:>7d
NOT type:hypothesis
```

## Architecture

```
hooks/
  session-start.sh    # Compose + inject stored knowledge
  prompt-submit.sh    # Parse commands, inject pending recalls
  stop.sh             # Final command sweep
commands/
  status.md           # /ctx:status
  recall.md           # /ctx:recall
  setup.md            # /ctx:setup
skills/
  using-ctx/SKILL.md  # Enforces memory discipline
scripts/
  install-binary.sh   # Auto-downloads ctx binary
  check-binary.sh     # Verifies installation
```

The `ctx` binary ([source](https://github.com/Zate/Memdown)) is a Go CLI that manages the SQLite database. The plugin hooks shell out to it.

## Requirements

- macOS or Linux (amd64 or arm64)
- `curl` (for binary download)
- `jq` (required for session-start knowledge injection)

## FAQ

**Where is data stored?**
`~/.ctx/store.db` — a single SQLite file. Back it up, move it between machines, or delete it to start fresh.

**Does it slow down sessions?**
Hooks have strict timeouts (5-15s). The binary is compiled Go and runs in milliseconds.

**Can I use it across projects?**
Yes. Use `project:X` tags to organize knowledge. Knowledge tagged with one project is still available in others.

**Can I inspect or edit stored knowledge manually?**
Yes. The `ctx` CLI has `list`, `show`, `delete`, `tag`, and `query` subcommands. Or just open the SQLite file directly.
