# Claude Code Integration

This document describes how devloop integrates with Claude Code's plugin system, explaining the underlying mechanisms and how to leverage them effectively.

---

## Overview

Devloop is a Claude Code plugin that uses the full plugin system:

- **Commands**: Slash commands invoked via `/devloop:*`
- **Agents**: Specialized subprocesses via the `Task` tool
- **Skills**: Domain knowledge loaded on-demand
- **Hooks**: Event handlers for lifecycle events

---

## Plugin System Fundamentals

### Plugin Manifest

Every plugin requires a manifest at `.claude-plugin/plugin.json`:

```json
{
  "name": "devloop",
  "version": "2.4.8",
  "description": "Complete feature development workflow...",
  "author": {
    "name": "Zate",
    "email": "zate75+claude-code-plugins@gmail.com"
  }
}
```

**Required**: Only `name` is strictly required. Other fields are metadata.

**Version**: We follow semantic versioning. Increment:
- Patch (2.4.8 → 2.4.9): Bug fixes, documentation
- Minor (2.4.x → 2.5.0): New features, backward compatible
- Major (2.x → 3.0.0): Breaking changes

### Directory Structure

Component directories MUST be at plugin root:

```
plugins/devloop/
├── .claude-plugin/
│   └── plugin.json       # Manifest (REQUIRED)
├── commands/             # Slash commands
├── agents/               # Agent definitions  
├── skills/               # Domain skills
├── hooks/                # Event handlers
│   └── hooks.json        # Hook configuration
└── ...
```

**Critical**: Directories like `commands/` must NOT be inside `.claude-plugin/`.

---

## Commands

### What Commands Are

Commands are markdown files that define slash command behavior. When a user types `/devloop:spike`, Claude Code:

1. Finds `plugins/devloop/commands/spike.md`
2. Loads the content as instructions
3. Executes according to the defined phases

### Command Structure

```markdown
---
description: Technical exploration and spike
aliases: [explore, investigate]
---

# Spike Command

## Phase 1: Exploration
[Instructions for exploration phase]

## Phase 2: Analysis  
[Instructions for analysis phase]

## Phase 3: Planning
[Instructions for planning phase]
```

### Frontmatter

| Field | Purpose | Example |
|-------|---------|---------|
| `description` | Shown in help/completion | "Technical exploration" |
| `aliases` | Alternative invocations | `[explore, spike]` |
| `arguments` | Expected arguments | `[topic, --depth]` |

### Key Commands in Devloop

| Command | File | Purpose |
|---------|------|---------|
| `/devloop` | `devloop.md` | Full 12-phase workflow |
| `/devloop:continue` | `continue.md` | Resume from plan |
| `/devloop:fresh` | `fresh.md` | Save state for context refresh |
| `/devloop:spike` | `spike.md` | Technical exploration |
| `/devloop:quick` | `quick.md` | Fast implementation |
| `/devloop:ship` | `ship.md` | Git integration |
| `/devloop:review` | `review.md` | Code review |

---

## Agents

### What Agents Are

Agents are specialized subprocesses invoked via the `Task` tool. They execute autonomously and return results.

### Invoking Agents

Commands invoke agents like this:

```yaml
Task:
  subagent_type: devloop:engineer
  description: "Implement user authentication"
  prompt: |
    Implement JWT-based authentication.
    
    Requirements:
    - Token generation with RS256
    - Validation middleware
    
    Files to modify:
    - services/auth.go
```

### Agent Structure

Agents are markdown files in `agents/`:

```markdown
---
model: sonnet
color: blue
---

# Engineer Agent

## System Role
You are a senior software engineer...

## Capabilities
- Code implementation
- Architecture design
- Refactoring analysis
- Git operations

## Modes
Detect mode from task keywords:
- "explore", "understand" → Explorer mode
- "design", "architecture" → Architect mode
- "refactor", "cleanup" → Refactorer mode
- "commit", "branch", "pr" → Git mode

## Workflow
1. Analyze the task
2. Apply appropriate skills
3. Execute implementation
4. Return results
```

### Model Selection

| Model | Use Case | Token Cost |
|-------|----------|------------|
| `haiku` | Classification, checklists, simple tasks | Low |
| `sonnet` | Implementation, exploration, review | Medium |
| `opus` | Complex architecture, high-stakes decisions | High |

### Background Execution

For parallel independent tasks:

```yaml
Task:
  subagent_type: devloop:engineer
  description: "Implement user model"
  run_in_background: true

Task:
  subagent_type: devloop:engineer  
  description: "Implement product model"
  run_in_background: true

# Later, collect results
TaskOutput(block=true)
```

---

## Skills

### What Skills Are

Skills are domain knowledge that Claude applies when relevant. They're catalogs of best practices, patterns, and guidance.

### Skill Structure

Each skill has its own directory with `SKILL.md`:

```
skills/go-patterns/
├── SKILL.md           # Main skill content
└── references/        # Optional detailed references
    ├── error-handling.md
    └── testing.md
```

**SKILL.md format**:

```markdown
---
description: Go-specific patterns and best practices
whenToUse: |
  - Writing new Go code
  - Reviewing Go code for idioms
whenNotToUse: |
  - Non-Go projects
  - Simple fixes that don't need Go expertise
---

# Go Patterns

## Error Handling
Always check errors explicitly...

## Interfaces
Define interfaces at the call site...
```

### Invoking Skills

Skills are referenced in commands or agent prompts:

```markdown
## Phase 5: Architecture
1. Invoke architecture skill: `Skill: architecture-patterns`
2. If Go project, also invoke: `Skill: go-patterns`
```

### Skill Catalog

We maintain a lightweight index at `skills/INDEX.md`:

```markdown
# Devloop Skills Index

## Language Patterns
| Skill | Description |
|-------|-------------|
| `go-patterns` | Go-specific best practices... |
| `react-patterns` | React and TypeScript... |

## Workflow
| Skill | Description |
|-------|-------------|
| `workflow-loop` | Multi-task patterns... |
```

This enables dynamic loading—skills are only loaded when invoked.

---

## Hooks

### What Hooks Are

Hooks are event handlers that respond to Claude Code lifecycle events.

### Available Events

| Event | When Triggered | Common Use |
|-------|----------------|------------|
| `SessionStart` | New conversation starts | Detect project, show status |
| `SessionEnd` | Conversation ends | Save metrics |
| `PreToolUse` | Before tool execution | Validate operations |
| `PostToolUse` | After tool execution | Log operations |
| `SubagentStop` | Agent completes | Update state |
| `PreCompact` | Before context compact | Save important context |

### Hook Configuration

Hooks are configured in `hooks/hooks.json`:

```json
{
  "hooks": [
    {
      "name": "session-start",
      "event": "SessionStart", 
      "script": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
    },
    {
      "name": "pre-commit",
      "event": "PreToolUse",
      "script": "${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit.sh",
      "matcher": {
        "tool": "Bash",
        "command_pattern": "^git commit"
      }
    }
  ]
}
```

### Environment Variables

Scripts have access to:

| Variable | Value |
|----------|-------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin directory |
| `${TOOL_NAME}` | Name of tool being executed (PreToolUse/PostToolUse) |
| `${TOOL_INPUT}` | Tool input as JSON |

### Example Hook Script

```bash
#!/bin/bash
# hooks/session-start.sh

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
PLAN_FILE=".devloop/plan.md"

# Check for active plan
if [ -f "$PLAN_FILE" ]; then
    # Calculate progress
    total=$(grep -c "^- \[" "$PLAN_FILE" 2>/dev/null || echo 0)
    done=$(grep -c "^- \[x\]" "$PLAN_FILE" 2>/dev/null || echo 0)
    
    echo "📋 Active plan detected: $done/$total tasks complete"
fi

# Check for saved state
if [ -f ".devloop/next-action.json" ]; then
    echo "💾 Saved state found. Run /devloop:continue to resume."
fi
```

---

## Tool Integration

### The Task Tool

The `Task` tool spawns agents:

```yaml
Task:
  subagent_type: devloop:engineer
  description: "Brief description"
  prompt: "Detailed instructions"
  model: "sonnet"                    # Optional: override default
  run_in_background: true            # Optional: async execution
```

### AskUserQuestion

For user decisions:

```yaml
AskUserQuestion:
  question: "How should we proceed?"
  header: "Decision"
  options:
    - label: "Option A"
      description: "Description of A"
    - label: "Option B"
      description: "Description of B"
  multiSelect: false
```

### TodoWrite

For progress tracking:

```yaml
TodoWrite:
  todos:
    - content: "Create user model"
      status: "completed"
      activeForm: "Creating user model"
    - content: "Add validation"
      status: "in_progress"
      activeForm: "Adding validation"
```

---

## Best Practices

### Command Design

1. **Phase-based structure**: Break into clear phases
2. **Use AskUserQuestion** between major phases
3. **Invoke agents** for specific subtasks
4. **Reference skills** for domain knowledge
5. **Update state files** to persist progress

### Agent Design

1. **Single responsibility**: One agent, one domain
2. **Mode detection**: Handle variations via modes
3. **Clear output**: Return actionable results
4. **Appropriate model**: Match complexity to capability

### Skill Design

1. **Clear scope**: Define whenToUse and whenNotToUse
2. **Practical content**: Focus on actionable guidance
3. **Reference structure**: Use references/ for deep dives
4. **Keep current**: Update with new best practices

### Hook Design

1. **Fast execution**: Hooks should be quick
2. **Graceful failure**: Don't break workflows on errors
3. **Minimal output**: Only output what's needed
4. **JSON parsing**: Handle tool input carefully

---

## Debugging

### Enable Debug Mode

```bash
claude --debug
```

Shows:
- Plugin loading
- Component registration
- Hook execution
- Tool invocations

### Common Issues

| Issue | Solution |
|-------|----------|
| Command not found | Check file exists in `commands/` |
| Agent not invoked | Verify `subagent_type: devloop:agent-name` |
| Skill not loading | Check `skills/skill-name/SKILL.md` exists |
| Hook not firing | Check `hooks/hooks.json` configuration |

### Testing Locally

```bash
# Install plugin for testing
/plugin install /path/to/devloop

# List installed
/plugin list

# Uninstall and reinstall for changes
/plugin uninstall devloop
/plugin install /path/to/devloop
```

---

## Official Documentation

Reference the official Claude Code docs for:

- [Plugin Development](https://code.claude.com/docs/en/plugins) - Full plugin guide
- [Plugin Reference](https://code.claude.com/docs/en/plugins-reference) - API specifications
- [Skills](https://code.claude.com/docs/en/skills/overview) - Skill creation
- [Commands](https://code.claude.com/docs/en/commands) - Command creation

---

## Next Steps

- [Component Guide](05-component-guide.md) - Deep dive into devloop's components
- [Architecture](01-architecture.md) - How it all fits together
- [Contributing](07-contributing.md) - Add your own extensions
