# Claude Code Integration

How devloop uses the Claude Code plugin system.

---

## Plugin Structure

```
plugins/devloop/
├── .claude-plugin/
│   └── plugin.json       # Manifest (name, version)
├── agents/               # Specialized agents
├── skills/               # Slash commands + domain knowledge (SKILL.md)
├── hooks/                # Event handlers
├── scripts/              # Helper scripts
└── statusline/           # Statusline display scripts
```

---

## Skills (Slash Commands)

Skill directories in `skills/` that define workflows and reference knowledge.

```bash
/devloop            # Start workflow
/devloop:plan       # Planning (--deep/--quick/--from-issue)
/devloop:run        # Execute plan
/devloop:fresh      # Save state for restart
```

### Key Frontmatter Fields

```yaml
---
name: skill-name
description: What this skill does
argument-hint: Optional argument description
allowed-tools:
  - Read
  - Write
  - Bash
context: fork              # Run in forked context (optional)
disable-model-invocation: true  # Only via /command, not auto-trigger
agent: Explore             # Agent type hint (optional)
user-invocable: true       # Default true for skills
---
```

---

## Agents

Specialized subprocesses for parallel work.

```yaml
Agent:
  subagent_type: devloop:engineer
  description: "Implement feature"
  prompt: "..."
  run_in_background: true
```

### Key Frontmatter Fields

```yaml
---
name: agent-name
description: What this agent does
tools: Bash, Read, Write, Edit, Grep, Glob
model: sonnet
maxTurns: 30
color: green
memory: project            # user, project, or local
---
```

**v3 Philosophy**: Claude does work directly. Agents only for parallel tasks.

---

## Reference Skills

Domain knowledge loaded on-demand.

```
Skill: plan-management
Skill: local-config
```

Located in `skills/skill-name/SKILL.md`.

---

## Hooks

Event handlers configured in `hooks/hooks.json` or inline in `plugin.json`.

```json
{
  "hooks": [
    {
      "event": "SessionStart",
      "type": "command",
      "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
    }
  ]
}
```

### Hook Types

- `command` - Shell script execution
- `prompt` - LLM evaluation
- `agent` - Multi-turn agent

---

## Debugging

```bash
claude --debug
```

Shows plugin loading and component registration.

---

## Official Docs

- [Plugins](https://code.claude.com/docs/en/plugins)
- [Plugin Reference](https://code.claude.com/docs/en/plugins-reference)
- [Skills](https://code.claude.com/docs/en/skills/overview)
- [Hooks](https://code.claude.com/docs/en/hooks)
