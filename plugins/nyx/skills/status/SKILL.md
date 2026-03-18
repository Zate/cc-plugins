---
name: status
description: "Show what's in flight across all Nyx dimensions — active work, recent decisions, and dimension states."
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
---

# Status

Cross-dimension overview of what's in flight.

## Process

1. Check if Nyx home exists (`~/.nyx/.git`). If not: "Nyx isn't set up yet. Run `nyx` from your terminal to initialize." and stop.

2. Get current branch: `git -C ~/.nyx branch --show-current`

3. List dimension branches: `git -C ~/.nyx branch --list 'dim/*'`
   - If none: "No dimensions yet. Create one with `/nyx:dimension create [name] \"[goal]\"`" and stop.

4. For each dimension branch, read its state file without switching branches:
   `git -C ~/.nyx show dim/<name>:dimensions/<name>.md`
   - Extract: name, status, active focus, most recent decision log entry

5. Present as a table:

| Dimension | Active Focus | Last Decision | Current |
|-----------|--------------|---------------|---------|

Mark the current branch with `*`.

6. List any archived dimensions: `git -C ~/.nyx branch --list 'archive/*'`
   - Show count if any: "Plus N archived dimensions."

7. If there are recent working-tier ctx nodes, show a brief "Recent activity" section:
   - Emit: `<ctx:recall query="tier:working"/>` and summarize the top 3-5 most recent items

8. If devloop has an active plan (check `.devloop/plan.md` in the user's project directory), mention it briefly.

Keep it concise. This is a dashboard, not a report.
