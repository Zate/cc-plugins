---
name: status
description: Show ctx memory status (node counts, types, tiers, tokens)
when_to_use: "Checking memory health, node counts, and database location"
when_not_to_use: "Querying for specific knowledge"
argument-hint: None required
user-invocable: true
allowed-tools:
  - Bash
---

# ctx Status

Show a summary of stored knowledge.

Run:
```bash
ctx status
```

Report to the user: total nodes, breakdown by type and tier, token counts, and database size.
