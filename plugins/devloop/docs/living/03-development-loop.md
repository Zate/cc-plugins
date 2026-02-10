# The Development Loop

The iterative cycle that makes devloop effective.

---

## The Pattern

```
┌─────────┐     ┌─────────┐     ┌─────────────┐
│  PLAN   │────▶│   RUN   │────▶│ WORK 5-10   │
│         │     │         │     │ tasks       │
└─────────┘     └────┬────┘     └──────┬──────┘
                     │                  │
                     │          Context heavy?
                     │                  │
                     │     ┌────────────┴───┐
                     │     Yes              No
                     │      │                │
                     │      ▼                ▼
                     │ ┌─────────┐    Keep working
                     │ │  FRESH  │           │
                     │ └────┬────┘           │
                     │      │                │
                     └──────┴────────────────┘
```

---

## Commands

### `/devloop:plan`

Create actionable plan with exploration.

```bash
/devloop:plan "Add user authentication"
```

Creates: `.devloop/plan.md` with task breakdown.

Flags:
- `--deep`: Comprehensive exploration with spike report
- `--quick`: Fast path for small tasks
- `--from-issue N`: Start from GitHub issue

### `/devloop:run`

Execute plan tasks autonomously.

```bash
/devloop:run
```

Reads plan, finds next `[ ]` task, works on it.

### `/devloop:fresh`

Save state for context refresh.

```bash
/devloop:fresh
/clear
/devloop:run
```

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
/devloop:plan "Add rate limiting to API"

# Day 1-2: Work autonomously
/devloop:run  # Tasks 1.1, 1.2, 1.3, ...

# Context heavy? Fresh and continue
/devloop:fresh
/clear
/devloop:run  # Resumes from checkpoint

# Done?
/devloop:ship
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
