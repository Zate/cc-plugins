---
name: using-ctx
description: "MANDATORY persistent memory system for decisions, facts, patterns, and observations."
when_to_use: "Making decisions, learning facts, debugging issues, or establishing conventions."
paths: ["**/*"]
---

# ctx: Persistent Memory

You are stateless. Use `ctx` to persist knowledge across sessions.

For command syntax: `ctx --agent-help` (index) or `ctx --agent-help <command>` (detail).

## When to Store
Run via Bash BEFORE responding. Store when you learn something that would be useful in a future session.

## Core Commands

```bash
# Store knowledge
ctx add "content" --type TYPE --tag tier:pinned --tag project:NAME

# Query / recall
ctx recall 'type:decision AND tag:project:NAME'        # immediate results
ctx recall 'tag:tier:reference' --inject               # inject into next prompt

# Search full-text
ctx search "keyword"

# Status
ctx status --agent-out

# Show a node
ctx show <id>
```

**Node types:** `fact`, `decision`, `pattern`, `observation`, `hypothesis`, `task`, `summary`, `source`, `open-question`

## Tagging Convention
Always include `tier:` and `project:` tags on every node.
- **tier:pinned**: Critical, loaded every session. Facts, foundational decisions.
- **tier:working**: Task-scoped, temporary. Active debugging, current plan state.
- **tier:reference**: Durable but not always loaded. Past decisions, resolved issues.
- **tier:off-context**: Archived, never loaded.
- **project:NAME**: Scope to current project (`basename` of git root, lowercase).

## Recall vs Query
- `ctx recall <query>` — run immediately and print results (use this for on-demand lookups)
- `ctx recall <query> --inject` — run and queue results for injection at next prompt-submit
- `ctx query <expression>` — low-level filtered query (same syntax, no injection support)

## --agent-out Flag
Use `--agent-out` on any result command for dense AOF output optimised for agent consumption (no markdown, no prose):
```bash
ctx recall 'tag:project:myapp' --agent-out
ctx status --agent-out
ctx list --agent-out
ctx query 'type:decision' --agent-out
```

## XML Commands (written in responses)
The stop hook parses these from your response text automatically:

```xml
<ctx:remember type="decision" tags="project:NAME,tier:reference">
Decision text here.
</ctx:remember>

<ctx:recall query="type:decision AND tag:project:NAME"/>
<ctx:status/>
<ctx:task name="task-name" action="start"/>
<ctx:task name="task-name" action="end"/>
<ctx:summarize nodes="ID1,ID2" archive="true">Summary text.</ctx:summarize>
<ctx:link from="ID1" to="ID2" type="DEPENDS_ON"/>
<ctx:supersede old="OLD_ID" new="NEW_ID"/>
```

## ctx doc Subsystem
Import markdown documents for agent-accessible decomposition (separate from memory nodes):

```bash
ctx doc import README.md          # decompose into doc+content nodes
ctx doc show <doc-id>             # show document metadata
ctx doc search "migration"        # substring search over doc content
ctx doc promote <node-id> --into-memory --type fact  # promote content → memory
ctx doc export <doc-id>           # recompose full markdown
```

Doc nodes are invisible to memory queries (`recall`, `search`, `list`, `status`). Use `doc promote` to graduate content into the memory graph.

## Coordination with MEMORY.md
- **MEMORY.md**: Short project-specific reminders, release rules, user preferences.
- **ctx**: Structured, typed knowledge (decisions, patterns, observations, facts).
- Don't duplicate across both. Check before writing.

**If you don't store it, it's gone.**
