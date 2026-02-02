---
description: Show ctx memory status (node counts, types, tiers, tokens)
argument-hint: None required
allowed-tools:
  - Bash
---

# ctx Status

Show a summary of stored knowledge.

Run:
```bash
ctx show --stats 2>/dev/null || echo "No stats available"
```

Also run:
```bash
ctx show --count 2>/dev/null || ctx show | head -20
```

Report to the user: total nodes, breakdown by type and tier if available, database size.
