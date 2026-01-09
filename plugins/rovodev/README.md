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

## Installation

See [INSTALL.md](INSTALL.md) for detailed installation instructions.

**Quick Install:**

```bash
cd ~/projects/acra-python

# Copy files
mkdir -p .rovodev/prompts/devloop .rovodev/subagents/devloop .rovodev/scripts .rovodev/skills
cp ~/projects/claude-plugins/plugins/rovodev/prompts/*.md .rovodev/prompts/devloop/
cp ~/projects/claude-plugins/plugins/rovodev/subagents/*.md .rovodev/subagents/devloop/
cp ~/projects/claude-plugins/plugins/rovodev/scripts/*.sh .rovodev/scripts/
cp ~/projects/claude-plugins/plugins/rovodev/skills/*.md .rovodev/skills/
chmod +x .rovodev/scripts/*.sh
```

Then add to `.rovodev/prompts.yml`:

```yaml
prompts:
  - name: devloop
    description: "Start new development work"
    content_file: prompts/devloop/rovodev.md
  - name: spike
    description: "Time-boxed investigation"
    content_file: prompts/devloop/spike.md
  # ... see INSTALL.md for full list
```

## Usage with Rovodev

```bash
# Start new work
rovodev run "@devloop Add user authentication"

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
