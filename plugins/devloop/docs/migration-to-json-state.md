# Migration Guide: JSON State for Devloop Plans

This guide helps you migrate existing devloop workflows to use the new dual-file state management system: `plan.md` (human-readable) + `plan-state.json` (machine-readable).

## Overview

### What Changed

The devloop plugin now uses a JSON state file alongside your markdown plan:

| File | Purpose | Who Edits | Git Tracked |
|------|---------|-----------|-------------|
| `.devloop/plan.md` | Human-readable plan | You + Claude | Yes |
| `.devloop/plan-state.json` | Machine-readable state | Scripts only | Yes |

### Benefits

- **80% fewer tokens**: Scripts handle parsing, counting, and status operations
- **Faster responses**: No LLM calls for deterministic operations
- **Better accuracy**: Consistent task counting and status tracking
- **Backward compatible**: Works without JSON file (falls back to markdown parsing)

## Migration Steps

### Step 1: Verify Your Plan Format

Your `plan.md` should follow the devloop format:

```markdown
# Plan Name

**Created**: 2025-01-15
**Updated**: 2025-01-15 09:00
**Status**: In Progress
**Current Phase**: Phase 1

## Tasks

### Phase 1: Phase Name
**Goal**: What this phase accomplishes

- [ ] Task 1.1: Description [parallel:A]
  - Acceptance: What defines done
  - Files: `path/to/file.ts`

- [ ] Task 1.2: Another task [depends:1.1]
```

**Required elements**:
- `**Status**:` line with value: `Planning`, `In Progress`, `Review`, `Complete`, or `Archived`
- `**Current Phase**:` line with phase number
- Tasks in format: `- [ ] Task N.M: Description`

### Step 2: Generate Initial JSON State

Run the sync script to create your first `plan-state.json`:

```bash
# From your project root
./plugins/devloop/scripts/sync-plan-state.sh .devloop/plan.md
```

This creates `.devloop/plan-state.json` with:
- Parsed task statuses
- Phase information
- Dependency graph
- Parallel group mappings
- Progress statistics

### Step 3: Validate the State File

Verify the generated state is correct:

```bash
./plugins/devloop/scripts/validate-plan-state.sh
```

Expected output:
```
Validating: .devloop/plan-state.json
--------------------------------------
Validation passed
```

If validation fails, use `--fix` to regenerate:

```bash
./plugins/devloop/scripts/validate-plan-state.sh --fix
```

### Step 4: Update Git Tracking

Add the state file to version control:

```bash
git add .devloop/plan-state.json
git commit -m "chore: add devloop JSON state tracking"
```

**Why track it?** Team visibility - everyone sees the same plan state.

### Step 5: Verify Hooks Are Active

The devloop plugin automatically syncs state via hooks. Verify hooks are registered:

```bash
# Check session-start hook exists
cat plugins/devloop/hooks.json | grep session-start

# Check pre-commit hook exists
cat plugins/devloop/hooks.json | grep PreCommit
```

If hooks aren't triggering, restart your Claude Code session.

## How Sync Works

### Automatic Sync Triggers

| Event | Script Called | What Happens |
|-------|---------------|--------------|
| Session start | `sync-plan-state.sh` | Ensures state matches plan |
| Before commit | `sync-plan-state.sh` | Updates state with latest changes |
| Validation failure | `validate-plan-state.sh --fix` | Regenerates from plan.md |

### Manual Sync

If state gets out of sync, manually regenerate:

```bash
# Regenerate from plan.md
./plugins/devloop/scripts/sync-plan-state.sh

# Validate result
./plugins/devloop/scripts/validate-plan-state.sh
```

## Task Marker Reference

The sync script recognizes these markers in `plan.md`:

| Marker | JSON Status | Meaning |
|--------|-------------|---------|
| `[ ]` | `pending` | Not started |
| `[x]` or `[X]` | `complete` | Done |
| `[~]` | `in_progress` | Currently working |
| `[!]` | `blocked` | Cannot proceed |
| `[-]` | `skipped` | Intentionally skipped |

### Dependencies and Parallelism

```markdown
- [ ] Task 2.1: Create script [parallel:A]
- [ ] Task 2.2: Create tests [parallel:A]
- [ ] Task 2.3: Update docs [depends:2.1,2.2]
```

These are tracked in `plan-state.json`:

```json
{
  "parallel_groups": {
    "A": ["2.1", "2.2"]
  },
  "dependencies": {
    "2.3": ["2.1", "2.2"]
  }
}
```

## JSON State Schema

The `plan-state.json` file follows this structure:

```json
{
  "schema_version": "1.0.0",
  "plan_file": ".devloop/plan.md",
  "last_sync": "2025-01-15T09:00:00Z",
  "plan_name": "Feature Implementation",
  "status": "in_progress",
  "current_phase": 1,
  "stats": {
    "total": 10,
    "completed": 3,
    "pending": 7,
    "in_progress": 0,
    "blocked": 0,
    "skipped": 0,
    "done": 3,
    "percentage": 30
  },
  "phases": [...],
  "tasks": {...},
  "parallel_groups": {...},
  "dependencies": {...},
  "next_task": "1.4"
}
```

See `plugins/devloop/schemas/plan-state.schema.json` for the full schema.

## Troubleshooting

### State File Not Updating

**Symptom**: `plan-state.json` doesn't reflect recent plan changes.

**Solution**:
1. Check if hooks are active: `claude --debug`
2. Manually sync: `./plugins/devloop/scripts/sync-plan-state.sh`
3. Validate: `./plugins/devloop/scripts/validate-plan-state.sh --fix`

### Validation Errors

**Symptom**: `validate-plan-state.sh` reports errors.

**Common causes**:
- Task marker typos in plan.md (use `[ ]` not `[]`)
- Phase header format incorrect (use `### Phase N: Name`)
- Missing `**Status**:` or `**Current Phase**:` lines

**Solution**:
```bash
# Fix plan.md format issues, then:
./plugins/devloop/scripts/validate-plan-state.sh --fix
```

### Stats Mismatch

**Symptom**: Warning about stats not matching.

**Cause**: Manual edits to JSON file (don't do this).

**Solution**:
```bash
# Always regenerate from plan.md
./plugins/devloop/scripts/sync-plan-state.sh
```

### Stale State Warning

**Symptom**: "plan.md modified after last sync - state may be stale"

**Cause**: Plan was edited but sync didn't run.

**Solution**:
```bash
./plugins/devloop/scripts/sync-plan-state.sh
```

## Backward Compatibility

The new system is fully backward compatible:

- **No JSON file?** Scripts fall back to markdown parsing
- **Old plan format?** Still works, just generates new JSON on sync
- **Team members without update?** They'll get JSON on next session start

## Best Practices

1. **Never edit `plan-state.json` directly** - always edit `plan.md`
2. **Commit both files together** - they should stay in sync
3. **Use standard task markers** - `[ ]`, `[x]`, `[~]`, `[!]`, `[-]`
4. **Keep phase headers consistent** - `### Phase N: Name` format
5. **Run validate after major plan changes** - catches format issues early

## Scripts Reference

| Script | Purpose |
|--------|---------|
| `sync-plan-state.sh` | Parse plan.md → create plan-state.json |
| `validate-plan-state.sh` | Verify state file integrity |
| `detect-plan.sh` | Find plan.md in standard locations |
| `show-plan-status.sh` | Display plan progress (uses JSON) |
| `select-next-task.sh` | Get next task respecting deps (uses JSON) |

All scripts support `--help` for usage details.
