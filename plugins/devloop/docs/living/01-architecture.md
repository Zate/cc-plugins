# Devloop Architecture

**A lightweight plugin structure for Claude Code.**

---

## Overview

Devloop v3.0 is intentionally minimal. The architecture prioritizes:

1. **Low overhead** - Minimal hooks, no prompt hooks
2. **Direct execution** - Claude does the work, not agents
3. **On-demand loading** - Skills loaded only when needed
4. **Simple state** - Plan file + optional fresh start state

---

## Directory Structure

```
plugins/devloop/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/                 # User-invokable commands
│   ├── devloop.md           # Main entry point
│   ├── continue.md          # Resume work
│   ├── spike.md             # Time-boxed exploration
│   ├── fresh.md             # Save state for context clear
│   ├── quick.md             # Small fixes
│   ├── review.md            # Code review
│   └── ship.md              # Commit/PR
├── hooks/
│   ├── hooks.json           # Hook definitions (minimal)
│   └── session-start.sh     # Session initialization
├── skills/                   # On-demand knowledge
│   ├── INDEX.md             # Skill catalog
│   └── [skill-name]/
│       └── SKILL.md
├── agents/                   # Specialized agents (rarely used)
│   └── [agent-name].md
└── docs/
    └── living/              # This documentation
```

---

## Components

### Commands

Commands are the primary interface. Each is a markdown file with YAML frontmatter:

```yaml
---
description: Start development workflow
argument-hint: Task description
allowed-tools: [Read, Write, Edit, Bash, ...]
---

# Command content (instructions for Claude)
```

**Core commands:**

| Command | Purpose | Typical Use |
|---------|---------|-------------|
| `/devloop` | Start work | New feature |
| `/devloop:continue` | Resume | After fresh start |
| `/devloop:spike` | Explore | Unknown territory |
| `/devloop:fresh` | Save & exit | Context getting heavy |
| `/devloop:quick` | Fast fix | Small, clear task |
| `/devloop:ship` | Commit | Ready to ship |

### Hooks

v3.0 uses minimal hooks—only command-type hooks that run scripts:

```json
{
  "hooks": [
    {
      "event": "SessionStart",
      "type": "command",
      "command": "./hooks/session-start.sh"
    }
  ]
}
```

**Removed in v3.0:**
- All `type: "prompt"` hooks (caused extra LLM calls)
- PreToolUse/PostToolUse prompt hooks
- Stop hook
- Notification hook

**Why?** Each prompt hook triggered an LLM call. For a typical session:
- 50 tool calls × 2 hooks each = 100 extra LLM calls
- Each call: ~500ms + token cost
- Result: 10x slower, 10x more expensive

### Skills

Skills are knowledge files loaded on-demand:

```
skills/
├── INDEX.md              # Catalog (always available)
├── go-patterns/
│   └── SKILL.md          # Go-specific patterns
├── testing-strategies/
│   └── SKILL.md          # Testing approaches
└── git-workflows/
    └── SKILL.md          # Git operations
```

**How skills work:**
1. Claude sees `skills/INDEX.md` which lists available skills
2. When needed, Claude reads the specific `SKILL.md`
3. No skills are auto-loaded at startup

**v3.0 skills (12 total):**
- Core: plan-management, git-workflows, atomic-commits, testing-strategies
- Languages: go-patterns, python-patterns, react-patterns, java-patterns
- Other: api-design, architecture-patterns, database-patterns, security-checklist

### Agents

Agents are specialized prompts for complex subtasks. In v3.0, they're rarely needed:

```yaml
---
description: Engineer agent for complex implementation
model: sonnet
allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# Agent instructions
```

**When to use agents:**
- Genuinely parallel work (multiple independent tasks)
- Specialized analysis (security scan, complex review)
- Large codebase exploration

**When NOT to use agents:**
- Writing code (Claude does it directly)
- Running tests (use Bash)
- Git operations (use Bash)
- Single-file changes
- Documentation

---

## State Management

### Plan File

The primary state file is `.devloop/plan.md`:

```markdown
# Feature Name

## Tasks
- [x] Completed task
- [~] Partial task
- [ ] Pending task
```

**Task markers:**
- `[ ]` - Pending
- `[x]` - Complete
- `[~]` - Partial/In progress

### Fresh Start State

When using `/devloop:fresh`, state is saved to `.devloop/next-action.json`:

```json
{
  "timestamp": "2024-12-30T10:00:00Z",
  "plan_file": ".devloop/plan.md",
  "current_task": "Add JWT validation",
  "next_task": "Write tests",
  "summary": "Implemented auth endpoints"
}
```

This file is automatically read and deleted by `/devloop:continue`.

---

## Execution Flow

### Typical Session

```
User: /devloop Add user authentication

Claude:
1. Check for existing .devloop/plan.md
2. If exists: ask continue or new?
3. Create plan with tasks
4. Implement directly (no agents)
5. After progress: checkpoint
6. User: continue or break?
```

### Fresh Start Flow

```
User: /devloop:fresh
Claude: Saves state to next-action.json
        "Run /clear then /devloop:continue"

User: /clear

User: /devloop:continue
Claude: Reads next-action.json
        Deletes it
        Resumes from saved state
```

---

## Design Decisions

### Why No Prompt Hooks?

In v2.x, prompt hooks like `PreToolUse` and `PostToolUse` triggered LLM calls for every tool use. For a typical session:

- 50 tool calls × 2 hooks each = 100 extra LLM calls
- Each call: ~500ms + token cost
- Result: 10x slower, 10x more expensive

v3.0 removes all prompt hooks. If validation is needed, it happens in Claude's main reasoning loop.

### Why Minimal Agents?

In v2.x, the pattern was "spawn an agent for everything":

```
User: Add auth
→ spawn task-planner
→ spawn engineer
→ spawn qa-engineer
→ spawn doc-generator
```

Each agent spawn has overhead:
- Context construction
- Tool permission setup
- Result parsing

v3.0 pattern: Claude does the work directly. Only spawn agents for genuinely parallel or specialized work.

### Why On-Demand Skills?

In v2.x, agents had `skills:` frontmatter that auto-loaded skills:

```yaml
skills:
  - go-patterns
  - testing-strategies
  - git-workflows
  # ... 14 more
```

This loaded 50K+ tokens before any work started.

v3.0: No auto-loading. Claude reads `INDEX.md` and loads specific skills when actually needed.

---

## File Locations

| File | Purpose | Git tracked? |
|------|---------|--------------|
| `.devloop/plan.md` | Current task plan | Yes |
| `.devloop/next-action.json` | Fresh start state | No (temporary) |
| `.devloop/worklog.md` | Work history | Optional |
| `.devloop/archive/` | Archived plans | Optional |

---

## Next Steps

- [Principles](02-principles.md) - Design philosophy
- [Development Loop](03-development-loop.md) - Workflow patterns
- [Component Guide](05-component-guide.md) - Writing commands/skills
