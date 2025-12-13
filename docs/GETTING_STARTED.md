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

### Try these commands right now:

**1. Start a feature** (full workflow)
```bash
/devloop Add a dark mode toggle to the settings page
```

**2. Quick fix** (skip the ceremony for simple tasks)
```bash
/devloop:quick Fix the typo in the header component
```

**3. Explore feasibility** (when you're not sure if something is possible)
```bash
/devloop:spike Can we migrate from REST to GraphQL?
```

**4. Resume work** (pick up where you left off)
```bash
/devloop:continue
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

When you run `/devloop`, you'll see a structured conversation:

```
[Devloop Phase 1: Discovery]
I'll analyze your requirements and identify edge cases...

[Devloop Phase 3: Exploration]
Let me find similar patterns in your codebase...

[Devloop Phase 5: Architecture]
Here are three approaches we could take...
```

**You're in control**: devloop asks clarifying questions when needed. Answer them thoughtfully—it prevents rework later.

**Plans are saved**: Your progress is stored in `.claude/devloop-plan.md`. If you need to stop, just run `/devloop:continue` later to pick up where you left off.

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
