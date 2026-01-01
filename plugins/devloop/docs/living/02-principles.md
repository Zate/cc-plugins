# Devloop Design Principles

Core design philosophies for devloop v3.

---

## 1. Claude Does the Work

Claude implements tasks directly. Use Write, Edit, Bash, Read tools.

**Agents only for**:
- Parallel independent tasks
- Full security scans
- Large codebase exploration (50+ files)

---

## 2. Work in Loops

Complex features need multiple context-fresh sessions.

```
Spike → Fresh → Continue → [5-10 tasks] → Fresh → Continue → ...
```

- **Fresh every 5-10 tasks**
- **Plans survive sessions**: `.devloop/plan.md`
- **State saves at breaks**: `next-action.json`

---

## 3. Plans Drive Progress

All work flows through plan files.

```markdown
## Tasks
- [x] Task 1.1: Create user model
- [~] Task 1.2: Add validation (partial)
- [ ] Task 1.3: Write unit tests
```

Resume anytime with `/devloop:continue`.

---

## 4. Skills Load On-Demand

Skills are catalogs loaded when needed.

```
Skill: go-patterns
Skill: testing-strategies
```

See `skills/INDEX.md` for the catalog.

---

## 5. Checkpoints Keep Control

Users decide direction at key points.

- Continue to next task
- Commit the work
- Fresh start for context
- Stop and save state

---

## Anti-Patterns

- **Silent execution**: Running for minutes without feedback
- **Over-spawning**: Using agents for single tasks
- **Skipping checkpoints**: Not updating plan markers
- **Ignoring context health**: Working 20+ tasks without fresh start

---

## Next Steps

- [The Development Loop](03-development-loop.md)
- [Component Guide](05-component-guide.md)
