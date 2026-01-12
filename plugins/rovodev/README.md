# Rovodevloop

Development workflow for Rovo Dev CLI with spike → plan → execute pattern.

This repository provides prompts, subagents, skills, and scripts that enable rovodev to use a structured development workflow:
- **Spike**: Time-boxed exploration and investigation (15-20 min)
- **Plan**: Create structured implementation plans
- **Execute**: Implement with progress tracking
- **Fresh**: Save state for context resets
- **Continue**: Resume from saved state
- **Quick**: Fast fixes without planning overhead
- **Review**: Code review workflow
- **Ship**: Commit and create PRs

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

### Quick Install (Global with symlinks)

```bash
# Clone the repository
git clone https://github.com/yourusername/rovodevloop.git ~/projects/rovodevloop

# Run the installer
cd ~/projects/rovodevloop
./install.sh
```

This will:
1. Create symlinks in `~/.rovodev/` pointing to this repository
2. Prompt you to create/update `~/.rovodev/prompts.yml`
3. Make the prompts available to all your projects

### Quick Install (Project-specific with symlinks)

```bash
# Clone the repository (if not already cloned)
git clone https://github.com/yourusername/rovodevloop.git ~/projects/rovodevloop

# Install to specific project
cd ~/projects/rovodevloop
./install.sh --local ~/projects/your-project
```

### Other Installation Options

```bash
# Copy files instead of symlinking (global)
./install.sh --no-link

# Copy files to specific project
./install.sh --local ~/projects/your-project --no-link

# Update existing installation
./install.sh -u
./install.sh -u --local ~/projects/your-project

# Uninstall
./install.sh --uninstall
./install.sh --uninstall --local ~/projects/your-project
```

See [INSTALL.md](INSTALL.md) for detailed installation instructions.

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
