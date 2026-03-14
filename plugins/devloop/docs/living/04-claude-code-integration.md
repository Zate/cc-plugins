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
└── hooks/                # Event handlers
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

**v3 Philosophy**: Claude does work directly. Agents only for parallel tasks.

---

## Skills

Domain knowledge loaded on-demand.

```
Skill: go-patterns
Skill: testing-strategies
```

Located in `skills/skill-name/SKILL.md`.

---

## Hooks

Event handlers in `hooks/hooks.json`.

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
