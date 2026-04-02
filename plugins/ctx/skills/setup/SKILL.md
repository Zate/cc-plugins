---
name: setup
description: Install, upgrade, or verify ctx persistent memory system
when_to_use: "Installing or upgrading the ctx binary and database"
when_not_to_use: "Regular memory operations"
argument-hint: None required
user-invocable: true
allowed-tools:
  - Bash
  - AskUserQuestion
---

# ctx Setup

Install, upgrade, or verify the ctx persistent memory system.

## Steps

1. Check if `ctx` binary is in PATH and get current version:
   ```bash
   command -v ctx && ctx version
   ```

2. Check for updates from GitHub releases:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-update.sh
   ```

3. If binary not found OR an update is available, install/upgrade from GitHub releases:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/install-binary.sh
   ```

4. Verify database exists:
   ```bash
   ls -la ~/.ctx/store.db
   ```

5. If database missing, initialize:
   ```bash
   ctx init
   ```

6. Show current status:
   ```bash
   ctx status
   ```

7. Report results to user: binary location, version, database path, node count, tier breakdown. If an upgrade was performed, mention the old and new versions.
