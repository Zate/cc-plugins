# Getting Started with CC-Plugins

**Install professional development plugins for Claude Code in under a minute.**

---

## Prerequisites

You need Claude Code installed and running. If you haven't installed it yet, visit [claude.ai/code](https://claude.ai/code).

---

## Quick Install

Three commands to get started:

```bash
# 1. Add this marketplace to Claude Code
/plugin marketplace add Zate/cc-plugins

# 2. Install the devloop plugin (our flagship plugin)
/plugin install devloop

# 3. Start using it immediately
/devloop Add user authentication with OAuth
```

That's it. You're ready to go.

---

## What You Just Installed

### devloop - Professional Feature Development

devloop transforms how you build features. Instead of ad-hoc prompting, it guides you through a structured workflow:

| Phase | What Happens |
|-------|--------------|
| **Discover** | Understand requirements, identify edge cases |
| **Explore** | Analyze existing code, find patterns |
| **Architect** | Design the right solution |
| **Implement** | Build with full codebase context |
| **Test & Review** | Catch bugs before they ship |
| **Ship** | Clean commits and PR creation |

**The key insight**: Different tasks need different AI capabilities. devloop automatically uses the right model—opus for architecture decisions, sonnet for implementation, haiku for simple tasks. You get better results without thinking about it.

---

## Your First 5 Minutes

### Try the recommended workflow:

**The spike → fresh → continue loop** (best for any real work)
```bash
# 1. Start with exploration
/devloop:spike Add a dark mode toggle to the settings page

# 2. Save state and clear context
/devloop:fresh
/clear

# 3. Resume and work on tasks
/devloop:continue

# 4. After 5-10 tasks, repeat step 2-3
/devloop:fresh
/clear
/devloop:continue
```

**Other useful commands:**

**Quick fix** (skip the ceremony for simple tasks)
```bash
/devloop:quick Fix the typo in the header component
```

**Analyze codebase** (find tech debt and refactoring opportunities)
```bash
/devloop:analyze
```

**Review code** (before committing)
```bash
/devloop:review
```

---

## Common Commands Reference

| What You Want | Command | When to Use |
|---------------|---------|-------------|
| Build a feature | `/devloop [description]` | New features, complex changes |
| Quick fix | `/devloop:quick [fix]` | Small, well-defined tasks |
| Explore feasibility | `/devloop:spike [question]` | Unknown if possible |
| Review code | `/devloop:review` | Before commits |
| Continue work | `/devloop:continue` | Resume from previous session |
| Ship it | `/devloop:ship` | Ready to commit/PR |
| Analyze codebase | `/devloop:analyze` | Find tech debt, large files |

---

## Understanding the Workflow

### The Recommended Pattern: Spike → Fresh → Continue Loop

**Modern devloop usage follows this iterative cycle:**

```
┌─────────────────────────────────────────────┐
│ 1. /devloop:spike                           │
│    └─→ Explore problem, create plan         │
└──────────────────┬──────────────────────────┘
                   ↓
┌─────────────────────────────────────────────┐
│ 2. /devloop:fresh + /clear                  │
│    └─→ Save state, reset context            │
└──────────────────┬──────────────────────────┘
                   ↓
┌─────────────────────────────────────────────┐
│ 3. /devloop:continue                        │
│    └─→ Work on tasks with checkpoints       │
└──────────────────┬──────────────────────────┘
                   │
                   ↓ After 5-10 tasks
                   └─→ Loop back to step 2
```

**Why this works:**

- **Spike** creates a comprehensive plan with full context
- **Fresh** keeps responses fast by clearing heavy context
- **Continue** picks up exactly where you left off
- **Loop** maintains momentum while staying efficient

### The Traditional Workflow

When you run `/devloop` (traditional full workflow), you'll see a structured conversation through 12 phases. However, **the spike → fresh → continue loop is now recommended** for better context management.

**You're in control**: devloop asks clarifying questions when needed. Answer them thoughtfully—it prevents rework later.

**Plans are saved**: Your progress is stored in `.devloop/plan.md`. The fresh start mechanism ensures you can always resume with `/devloop:continue`.

---

## Working with Different Project Types

devloop automatically detects your project type and loads relevant knowledge:

| Project Type | What Gets Activated |
|--------------|---------------------|
| **React** | `react-patterns` skill, component best practices |
| **Go** | `go-patterns` skill, interface and error handling patterns |
| **Python** | `python-patterns` skill, type hints, pytest patterns |
| **Java/Spring** | `java-patterns` skill, DI and Spring conventions |

You don't need to configure this. devloop detects it from your codebase.

---

## Tips for Best Results

### 1. Answer Clarifying Questions

Phase 4 asks questions to prevent confusion later. Take time to answer thoughtfully—it saves rework.

### 2. Use the Right Command

| Situation | Use This |
|-----------|----------|
| Building something new and complex | `/devloop` |
| Small fix, clear scope | `/devloop:quick` |
| Not sure if it's possible | `/devloop:spike` |
| Ready to commit | `/devloop:ship` |

### 3. Trust the Workflow

Each phase exists for a reason. Skipping exploration leads to wrong architecture. Skipping review leads to bugs.

### 4. Use Plan Files

Save your plan. Resume later. Hand off to teammates. The plan file is your project's memory.

---

## Troubleshooting

### "Plugin not found"

```bash
# Make sure the marketplace is added
/plugin marketplace add Zate/cc-plugins

# Then install
/plugin install devloop
```

### "Command not recognized"

Restart Claude Code after installing plugins. Some commands need a fresh session.

### "Skills not activating"

Skills activate automatically based on context. Ask about specific topics (e.g., "How should I structure this React component?") to trigger relevant skills.

---

## What's Next?

### Explore More Commands

See the full [devloop documentation](../plugins/devloop/README.md) for:
- All 11 commands
- 17 specialized agents
- 22 domain skills

### Check Out Other Plugins

Browse available plugins:
```bash
/plugin list
```

### Get Help

- **Issues**: [GitHub Issues](https://github.com/Zate/cc-plugins/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Zate/cc-plugins/discussions)

---

## Contributing

Want to create your own plugin? See [CONTRIBUTING.md](../CONTRIBUTING.md) and the [Plugin Creation Guide](PLUGIN_CREATION_GUIDE.md).

---

<p align="center">
  <strong>Built for developers who ship.</strong>
</p>
