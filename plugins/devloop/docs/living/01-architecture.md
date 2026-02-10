# Devloop Architecture

**A lightweight plugin structure for Claude Code.**

---

## Directory Structure

```
plugins/devloop/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/                 # User-invokable commands
│   ├── devloop.md           # Main entry point
│   ├── plan.md              # Unified planning (--deep/--quick/--from-issue)
│   ├── run.md               # Autonomous execution
│   ├── fresh.md             # Save state for context clear
│   ├── review.md            # Code review
│   └── ship.md              # Commit/PR
├── hooks/
│   ├── hooks.json           # Minimal hook definitions
│   └── session-start.sh     # Session initialization
├── skills/                   # On-demand knowledge
│   ├── INDEX.md             # Skill catalog
│   └── [skill-name]/SKILL.md
├── agents/                   # Specialized agents (rarely used)
└── docs/living/             # Documentation
```

---

## Components

### Commands

Markdown files with YAML frontmatter defining the command interface.

| Command | Purpose |
|---------|---------|
| `/devloop` | Start work |
| `/devloop:plan` | Unified planning (default) |
| `/devloop:plan --deep` | Deep exploration |
| `/devloop:plan --quick` | Fast fix |
| `/devloop:run` | Autonomous execution |
| `/devloop:fresh` | Save & exit |
| `/devloop:ship` | Commit |

### Skills

Knowledge files loaded on-demand via `Skill: skill-name`.

**Available (12):** plan-management, git-workflows, atomic-commits, testing-strategies, go-patterns, python-patterns, react-patterns, java-patterns, api-design, architecture-patterns, database-patterns, security-checklist

### Agents

Rarely used. Only for parallel work, security scans, or large exploration.

---

## State Management

### Plan File (`.devloop/plan.md`)

```markdown
# Feature Name

## Tasks
- [x] Completed task
- [~] Partial task
- [ ] Pending task
```

### Fresh Start (`.devloop/next-action.json`)

Temporary file created by `/devloop:fresh`, read and deleted by `/devloop:run`.

---

## File Locations

| File | Purpose | Git tracked? |
|------|---------|--------------|
| `.devloop/plan.md` | Current plan | Yes |
| `.devloop/next-action.json` | Fresh start state | No |
| `.devloop/worklog.md` | Work history | Optional |
| `.devloop/spikes/` | Spike reports | No |

---

## Design Decisions

**No prompt hooks**: v2.x prompt hooks caused 10x overhead. v3.0 removes all prompt hooks.

**Minimal agents**: Claude does work directly instead of spawning agents for everything.

**On-demand skills**: No auto-loading. Load only what's needed.

---

## Next Steps

- [Principles](02-principles.md) - Design philosophy
- [Development Loop](03-development-loop.md) - Workflow patterns
