# CC-Plugins Quick Reference

**Copy-paste commands for common tasks.**

---

## Setup

```bash
# Add marketplace
/plugin marketplace add Zate/cc-plugins

# Install devloop
/plugin install devloop
```

---

## devloop Commands

| Command | Use For |
|---------|---------|
| `/devloop [feature]` | Full feature development |
| `/devloop:quick [fix]` | Small, clear tasks |
| `/devloop:spike [question]` | Explore feasibility |
| `/devloop:continue` | Resume previous work |
| `/devloop:review` | Code review |
| `/devloop:ship` | Commit and PR |
| `/devloop:analyze` | Find tech debt |
| `/devloop:bug` | Report a bug |
| `/devloop:bugs` | View tracked bugs |

---

## Common Workflows

### New Feature
```bash
/devloop Add user authentication with OAuth
```

### Bug Fix
```bash
/devloop:quick Fix the null pointer in UserService
```

### Technical Exploration
```bash
/devloop:spike Can we migrate the database to PostgreSQL?
```

### Code Review
```bash
/devloop:review
```

### Ship Changes
```bash
/devloop:ship
```

### Resume Work
```bash
/devloop:continue
```

---

## Project Files

| File | Purpose |
|------|---------|
| `.claude/devloop-plan.md` | Current feature plan |
| `.claude/devloop.local.md` | Project-specific settings |
| `.claude/bugs/` | Tracked bugs |

---

## Tips

1. **Answer clarifying questions** - prevents rework
2. **Use `/devloop:quick`** for small tasks - skips ceremony
3. **Plans auto-save** - just run `/devloop:continue` to resume
4. **Skills activate automatically** - no configuration needed

---

## Links

- [Full Documentation](../plugins/devloop/README.md)
- [Getting Started Guide](GETTING_STARTED.md)
- [GitHub Issues](https://github.com/Zate/cc-plugins/issues)
