# State Management

Files devloop uses to maintain state.

---

## Core Files

```
.devloop/
├── plan.md               # Active plan (git-tracked)
└── next-action.json      # Fresh start state (temporary)
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
2. Read by `/devloop:continue`
3. Deleted after resume

---

## Git Tracking

| File | Git Status |
|------|------------|
| `plan.md` | Tracked |
| `next-action.json` | NOT tracked |

Add to `.gitignore`:
```
.devloop/next-action.json
```

---

## Next Steps

- [Component Guide](05-component-guide.md)
- [Contributing](07-contributing.md)
