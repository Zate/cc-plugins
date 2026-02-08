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
<ctx:remember type="decision" tags="tier:pinned,project:myproject">
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

Tiers control what gets loaded into context and when. **Key question:** Every session? → `pinned`. Someday? → `reference`. This task? → `working`.

| Tier | Behavior |
|------|----------|
| `tier:pinned` | Always loaded — critical facts, foundational decisions, active conventions |
| `tier:reference` | Not auto-loaded — durable knowledge, accessed via `<ctx:recall>` |
| `tier:working` | Loaded for current task — temporary debugging, hypotheses |
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
  run-hook.cmd        # Polyglot dispatcher (CMD → .ps1, bash → .sh)
  session-start.sh    # Compose + inject stored knowledge (Unix)
  session-start.ps1   # Compose + inject stored knowledge (Windows)
  prompt-submit.sh    # Parse commands, inject pending recalls (Unix)
  prompt-submit.ps1   # Parse commands, inject pending recalls (Windows)
  stop.sh             # Final command sweep (Unix)
  stop.ps1            # Final command sweep (Windows)
commands/
  status.md           # /ctx:status
  recall.md           # /ctx:recall
  setup.md            # /ctx:setup
skills/
  using-ctx/SKILL.md  # Enforces memory discipline
scripts/
  install-binary.sh   # Auto-downloads ctx binary (Unix)
  install-binary.ps1  # Auto-downloads ctx binary (Windows)
  check-binary.sh     # Verifies installation (Unix)
  check-binary.ps1    # Verifies installation (Windows)
  check-update.sh     # Version check (Unix)
  check-update.ps1    # Version check (Windows)
```

The `ctx` binary ([source](https://github.com/Zate/Memdown)) is a Go CLI that manages the SQLite database. All hooks go through `run-hook.cmd`, a polyglot script valid in both CMD.exe and bash. On Windows, CMD runs the `.ps1` scripts via PowerShell. On Unix, bash runs the `.sh` scripts directly.

## Requirements

- **Windows**, **macOS**, or **Linux** (amd64 or arm64)
- **Unix:** `curl`, `jq`
- **Windows:** PowerShell 5.1+ (ships with Windows 10/11)

## FAQ

**Where is data stored?**
`~/.ctx/store.db` — a single SQLite file. Back it up, move it between machines, or delete it to start fresh.

**Does it slow down sessions?**
Hooks have strict timeouts (5-15s). The binary is compiled Go and runs in milliseconds.

**Can I use it across projects?**
Yes. Use `project:X` tags to organize knowledge. Knowledge tagged with one project is still available in others.

**Can I inspect or edit stored knowledge manually?**
Yes. The `ctx` CLI has `list`, `show`, `delete`, `tag`, and `query` subcommands. Or just open the SQLite file directly.
