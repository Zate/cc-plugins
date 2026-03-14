# State Management

Files devloop uses to maintain state.

---

## Core Files

```
.devloop/
├── plan.md               # Active plan (NOT git-tracked, ephemeral)
├── next-action.json      # Fresh start state (temporary)
├── worklog.md            # Completed work history (git-tracked)
├── local.md              # Local settings (NOT git-tracked)
├── context.json          # Tech stack cache (git-tracked)
└── archive/              # Archived completed plans (git-tracked)
```

---

## plan.md

The active plan file. Source of truth for current work.

```markdown
# Devloop Plan: User Authentication

**Status**: In Progress

## Tasks

### Phase 1: Foundation
- [x] Task 1.1: Create user model
- [~] Task 1.2: Add validation (partial)
- [ ] Task 1.3: Write unit tests
```

**Markers**:
- `[ ]` - Pending
- `[~]` - Partial
- `[x]` - Complete
- `[-]` - Skipped
- `[!]` - Blocked

---

## next-action.json

Saved state for fresh start mechanism.

```json
{
  "lastCompletedTask": "2.1",
  "nextTask": "2.2",
  "planName": "User Authentication"
}
```

**Lifecycle**:
1. Created by `/devloop:fresh`
2. Read by `/devloop:run`
3. Deleted after resume

---

## local.md

Project-specific settings (YAML frontmatter). See `Skill: local-config` for details.

---

## Git Tracking

| File | Git Status |
|------|------------|
| `plan.md` | NOT tracked (ephemeral session state) |
| `next-action.json` | NOT tracked |
| `worklog.md` | Tracked |
| `local.md` | NOT tracked |
| `context.json` | Tracked |
| `archive/` | Tracked |

Add to `.gitignore`:
```
.devloop/plan.md
.devloop/next-action.json
.devloop/local.md
.devloop/spikes/
```

---

## Next Steps

- [Component Guide](05-component-guide.md)
- [Contributing](07-contributing.md)
