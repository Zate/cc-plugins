---
description: Install and configure ctx persistent memory system
argument-hint: None required
allowed-tools:
  - Bash
  - AskUserQuestion
---

# ctx Setup

Install and verify the ctx persistent memory system.

## Steps

1. Check if `ctx` binary is in PATH:
   ```bash
   command -v ctx && ctx status
   ```

2. If not found, install from GitHub releases:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/install-binary.sh
   ```

3. Verify database exists:
   ```bash
   ls -la ~/.ctx/store.db
   ```

4. If database missing, initialize:
   ```bash
   ctx init
   ```

5. Show current status:
   ```bash
   ctx status
   ```

6. Report results to user: binary location, database path, node count, tier breakdown.
