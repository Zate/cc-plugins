---
name: status
description: "Show what's in flight across all Nyx dimensions — active work, recent decisions, and dimension states."
user-invocable: true
allowed-tools: Read, Glob, Grep
---

# Status

Cross-dimension overview of what's in flight.

## Process

1. Check if `~/.claude/nyx/dimensions/` exists. If not: "No dimensions yet. Create one with `/nyx dimension create [name] \"[goal]\"`" and stop.

2. Read `~/.claude/nyx/current` for the active dimension name.

3. Glob `~/.claude/nyx/dimensions/*.md` — for each dimension state file:
   - Read YAML frontmatter: name, status, created date
   - Read the Active Focus section
   - Read the most recent Decision Log entry (last line with a date)
   - Note if this is the current dimension

4. Present as a table:

| Dimension | Status | Active Focus | Last Decision | Current |
|-----------|--------|--------------|---------------|---------|

5. If there are recent working-tier ctx nodes, show a brief "Recent activity" section:
   - Emit: `<ctx:recall query="tier:working"/>` and summarize the top 3-5 most recent items

6. If devloop has an active plan (check `.devloop/plan.md`), mention it briefly.

Keep it concise. This is a dashboard, not a report.
