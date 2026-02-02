---
description: Query ctx memory and inject results into context
argument-hint: "Query string, e.g. type:decision AND tag:project:myproject"
allowed-tools:
  - Bash
---

# ctx Recall

Run a query against stored knowledge and present the results.

The user provides a query string as the argument. If no argument given, ask what they want to recall.

Run:
```bash
ctx query "${ARGUMENTS}"
```

Present the results clearly, showing node type, content, and tags for each match.
