---
name: recall
description: Query ctx memory and inject results into context
when_to_use: "Searching for past decisions, facts, or patterns relevant to the current task"
argument-hint: "Query string, e.g. type:decision AND tag:project:myproject"
user-invocable: true
allowed-tools:
  - Bash
---

# ctx Recall

Run a query against stored knowledge and present the results.

The user provides a query string as the argument. If no argument given, ask what they want to recall.

Run:
```bash
ctx recall "${ARGUMENTS}" --agent-out
```

Use `--inject` to queue results for injection at the next prompt-submit (useful when you want the knowledge available at the start of the next turn):
```bash
ctx recall "${ARGUMENTS}" --inject
```

Query syntax examples:
- `type:decision AND tag:project:myproject`
- `tag:tier:reference`
- `type:fact OR type:pattern`

Present the results clearly, showing node type, content, and tags for each match.
