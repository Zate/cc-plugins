# Rovodev Integration Guide

How to use the rovodev plugin prompts and subagents with the Rovo Dev CLI.

## Overview

This plugin provides a structured development workflow (spike → plan → execute) for the Rovo Dev CLI project. The prompts and subagents are stored here in this repository, and can be used by rovodev when working on the acra-python project.

## Two Ways to Use

### Method 1: Copy to .rovodev/ Directory

Copy the prompts and subagents to your acra-python project:

```bash
# From this repo root
cd ~/projects/acra-python

# Copy prompts
cp -r /path/to/claude-plugins/plugins/rovodev/prompts/* .rovodev/
cp -r /path/to/claude-plugins/plugins/rovodev/subagents/* .rovodev/subagents/

# Copy scripts
mkdir -p .rovodev/scripts
cp /path/to/claude-plugins/plugins/rovodev/scripts/* .rovodev/scripts/

# Make scripts executable
chmod +x .rovodev/scripts/*.sh
```

### Method 2: Reference from Claude Plugins Repo

Keep files in this repo and reference them when needed by passing the full context.

## Usage Patterns

### Starting New Work

```bash
rovodev run "Add user authentication to the CLI"
```

Then reference the `@rovodev` prompt pattern:
- Check for existing plans
- Create feature branch (if configured)
- Break down into tasks
- Create `.devloop/plan.md`
- Start implementation

### Running a Spike

```bash
rovodev run "Spike: How does the MCP server authentication work?"
```

Follow the `@spike` prompt pattern:
- Define scope (2 min)
- Investigate (12-15 min)
- Summarize (3-5 min)
- Save to `.devloop/spikes/YYYY-MM-DD-[topic].md`

### Continuing Work

```bash
rovodev run "Continue working on authentication feature"
```

Follow the `@continue` prompt pattern:
- Read `.devloop/plan.md`
- Find next pending task
- Execute and update plan

### Quick Fixes

```bash
rovodev run "Quick fix: handle whitespace in directory paths"
```

Follow the `@quick` prompt pattern:
- Make focused change
- Run tests
- Commit with conventional message

### Code Review

```bash
rovodev run "Review the authentication changes"
```

Follow the `@review` prompt pattern:
- Analyze code for correctness, quality, style
- Generate structured feedback
- Offer to fix issues

### Shipping Work

```bash
rovodev run "Ship the authentication feature"
```

Follow the `@ship` prompt pattern:
- Review changes
- Run quality checks
- Create commit
- Push and create PR

## Using Subagents

### Task Planning

```bash
rovodev run "Break down the authentication feature into tasks"
```

Reference the `@task-planner` subagent:
- Analyze requirements
- Create structured plan
- Save to `.devloop/plan.md`

### Code Exploration

```bash
rovodev run "How does the MCP server work?"
```

Reference the `@engineer` subagent in explorer mode:
- Find entry points
- Trace execution flow
- Map architecture

### Architecture Design

```bash
rovodev run "Design the JWT authentication system"
```

Reference the `@engineer` subagent in architect mode:
- Extract existing patterns
- Design components
- Create implementation sequence

## Skills Reference

Skills provide reusable knowledge. Reference them when needed:

### Plan Management

Reference `plugins/rovodev/skills/plan-management.md`:
- Plan format and structure
- Task markers and states
- Operations (create, update, check)

### Python Patterns

Reference `plugins/rovodev/skills/python-patterns.md`:
- Code style (ruff, imports)
- Type hints
- Error handling
- Click patterns
- Pydantic models
- Testing patterns

### Git Workflows

Reference `plugins/rovodev/skills/git-workflows.md`:
- Conventional commits
- Branch naming
- Workflow patterns
- Git commands

## Scripts

Helper scripts for workflow automation:

### Check Plan Completion

```bash
bash plugins/rovodev/scripts/check-plan-complete.sh .devloop/plan.md
```

Output:
```json
{"complete": false, "total": 10, "done": 7, "pending": 3, "partial": 0, "blocked": 0}
```

### Parse Local Config

```bash
bash plugins/rovodev/scripts/parse-local-config.sh git.auto-branch
```

Output:
```
true
```

## File Structure

The workflow uses these files:

```
acra-python/
├── .devloop/
│   ├── plan.md                 # Current work plan
│   ├── next-action.json        # Fresh start state (temp)
│   ├── local.md                # Project config (optional)
│   ├── spikes/                 # Spike reports
│   │   └── YYYY-MM-DD-topic.md
│   ├── issues/                 # Issue tracking (optional)
│   │   └── BUG-001.md
│   └── archive/                # Completed plans
│       └── YYYY-MM-DD-feature.md
└── .rovodev/                   # Rovodev config (optional)
    ├── prompts/                # Custom prompts
    ├── subagents/              # Custom subagents
    └── scripts/                # Helper scripts
```

## Example Workflow

### Complete Feature Implementation

```bash
# 1. Start new work
rovodev run "Add JWT authentication to CLI"
# Creates .devloop/plan.md with tasks

# 2. Work through tasks
rovodev run "Continue"
# Implements Task 1.1, marks complete

# 3. Need investigation
rovodev run "Spike: Best JWT library for Python"
# Creates spike report in .devloop/spikes/

# 4. Continue implementation
rovodev run "Continue"
# Implements more tasks

# 5. Context getting full, save state
rovodev run "Save state for fresh start"
# Creates .devloop/next-action.json

# ... reset context ...

# 6. Resume work
rovodev run "Continue"
# Loads state, resumes from saved task

# 7. Review before shipping
rovodev run "Review the authentication code"
# Generates code review feedback

# 8. Ship it
rovodev run "Ship the authentication feature"
# Commits, pushes, creates PR
```

## Integration with Existing .rovodev/

The rovodev plugin complements existing `.rovodev/` content:

**Existing** (keep these):
- `peta.md` - PETA automation
- `create-*-docs.md` - Documentation prompts
- `prompts.yml` - Prompt registry

**New** (add these):
- `rovodev.md` - Main workflow entry
- `spike.md`, `continue.md`, etc. - Workflow prompts
- `subagents/` - Specialized agents

## Customization

### Local Configuration

Create `.devloop/local.md` in acra-python:

```yaml
git:
  auto-branch: true
  branch-prefix: feat/
  default-base: main

workflow:
  auto-test: true
  format-on-save: true
```

### Project-Specific Prompts

Add custom prompts to `acra-python/.rovodev/`:

```bash
# Custom prompt for acra-python
cat > ~/.rovodev/rda-task.md << 'EOF'
# RDA Task - Create Jira Task

Create a task in the RDA (Rovo Dev Agents) Jira project.

Reference: https://softwareteams.atlassian.net/jira/software/projects/RDA
EOF
```

## Tips

1. **Start with @rovodev**: Main entry point for new work
2. **Use @spike for unknowns**: Time-boxed investigation
3. **Keep plans updated**: Mark tasks complete as you go
4. **Reference skills**: Load knowledge on demand
5. **Use @fresh before context resets**: Save your place
6. **Ship early, ship often**: Use @ship to commit regularly

## Troubleshooting

### Plan not found

```bash
# Check if plan exists
ls -la .devloop/plan.md

# Create new plan
rovodev run "@rovodev [feature description]"
```

### Scripts not executable

```bash
chmod +x plugins/rovodev/scripts/*.sh
```

### Can't find prompts

Ensure prompts are either:
1. Copied to `acra-python/.rovodev/`
2. Or referenced from this repo with full path

## Next Steps

1. **Copy prompts**: Move prompts to acra-python project
2. **Try a spike**: Run a quick investigation
3. **Create a plan**: Start a feature with structured tasks
4. **Iterate**: Use continue → fresh → continue pattern
5. **Ship**: Commit and PR with conventional commits

See individual prompt files for detailed workflows.
