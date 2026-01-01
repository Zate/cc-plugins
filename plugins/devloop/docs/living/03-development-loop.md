# The Development Loop

The iterative cycle that makes devloop effective.

---

## The Pattern

```
┌─────────┐     ┌─────────┐     ┌──────────┐     ┌─────────────┐
│  SPIKE  │────▶│  FRESH  │────▶│ CONTINUE │────▶│ WORK 5-10   │
│         │     │         │     │          │     │ tasks       │
└─────────┘     └────┬────┘     └──────────┘     └──────┬──────┘
                     │                                   │
                     │                           Context heavy?
                     │                                   │
                     │              ┌────────────────────┴───┐
                     │              Yes                      No
                     │               │                        │
                     │               ▼                        ▼
                     │          ┌─────────┐            Keep working
                     │          │  FRESH  │                  │
                     │          └────┬────┘                  │
                     │               │                       │
                     └───────────────┴───────────────────────┘
```

---

## Commands

### `/devloop:spike`

Explore and plan before implementation.

```bash
/devloop:spike How should we add user authentication?
```

Creates: `.devloop/plan.md` with task breakdown.

### `/devloop:fresh`

Save state for context refresh.

```bash
/devloop:fresh
/clear
/devloop:continue
```

### `/devloop:continue`

Resume work from plan.

```bash
/devloop:continue
```

Reads plan, finds next `[ ]` task, works on it.

---

## When to Fresh Start

- After 5-10 tasks completed
- Context feels heavy/slow
- After long exploration
- Before a break

---

## Example Session

```bash
# Day 1: Understand and plan
/devloop:spike Add rate limiting to API
/devloop:fresh
/clear

# Day 1-2: Work
/devloop:continue  # Tasks 1.1, 1.2, 1.3
/devloop:fresh
/clear

# Day 2: Continue
/devloop:continue  # Tasks 2.1, 2.2, 2.3
/devloop:ship      # Done!
```

---

## Why This Works

1. **Fresh context = better reasoning**
2. **Plan preserves progress across sessions**
3. **Checkpoints keep user in control**
4. **Work never lost**

---

## Next Steps

- [Principles](02-principles.md)
- [Component Guide](05-component-guide.md)
