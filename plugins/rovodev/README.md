# Rovodev Plugin

Development workflow for Rovo Dev CLI (acra-python) with spike → plan → execute pattern.

This plugin provides prompts and subagents that enable rovodev to use the same structured workflow as the devloop plugin:
- **Spike**: Time-boxed exploration and investigation
- **Plan**: Create structured implementation plans
- **Execute**: Implement with progress tracking
- **Fresh**: Save state for context resets
- **Continue**: Resume from saved state

## Structure

```
plugins/rovodev/
├── prompts/              # Main workflow prompts (like devloop commands)
│   ├── rovodev.md        # Entry point - start new work
│   ├── spike.md          # Time-boxed exploration
│   ├── continue.md       # Resume from plan
│   ├── fresh.md          # Save state for restart
│   ├── quick.md          # Fast fixes
│   ├── review.md         # Code review
│   └── ship.md           # Commit and PR
├── subagents/            # Specialized agents (like devloop agents)
│   ├── task-planner.md   # Planning and DoD validation
│   ├── engineer.md       # Code exploration and git ops
│   ├── reviewer.md       # Code review
│   └── doc-generator.md  # Documentation
├── skills/               # Reusable knowledge (reference devloop skills)
│   ├── plan-management.md
│   ├── python-patterns.md
│   └── git-workflows.md
└── scripts/              # Helper bash scripts
    ├── check-plan-complete.sh
    └── parse-local-config.sh
```

## Usage with Rovodev

These prompts are designed to be invoked via rovodev's prompt system:

```bash
# Start new work
rovodev run "@rovodev Add user authentication"

# Run a spike investigation
rovodev run "@spike How does the MCP server work?"

# Continue from saved plan
rovodev run "@continue"

# Ship completed work
rovodev run "@ship"
```

## Integration with Devloop

This plugin **copies and adapts** devloop's patterns for rovodev, it doesn't modify devloop files.
The workflow is compatible - both use `.devloop/plan.md` format.
