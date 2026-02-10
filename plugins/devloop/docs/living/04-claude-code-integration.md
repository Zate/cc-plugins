# Claude Code Integration

How devloop uses the Claude Code plugin system.

---

## Plugin Structure

```
plugins/devloop/
├── .claude-plugin/
│   └── plugin.json       # Manifest (name, version)
├── commands/             # Slash commands
├── agents/               # Specialized agents
├── skills/               # Domain knowledge
└── hooks/                # Event handlers
```

---

## Commands

Markdown files in `commands/` that define workflows.

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
Task:
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
      "script": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
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
