# Installation Guide

How to install and configure the rovodev plugin for use with Rovo Dev CLI.

## Installation Methods

### Method 1: Via prompts.yml (Recommended)

This method registers the prompts in your project's `.rovodev/prompts.yml` file so rovodev can find them.

#### Step 1: Copy Files to .rovodev

```bash
cd ~/projects/acra-python

# Create directories
mkdir -p .rovodev/prompts/devloop
mkdir -p .rovodev/subagents/devloop
mkdir -p .rovodev/scripts
mkdir -p .rovodev/skills

# Copy prompts
cp ~/projects/claude-plugins/plugins/rovodev/prompts/*.md .rovodev/prompts/devloop/

# Copy subagents
cp ~/projects/claude-plugins/plugins/rovodev/subagents/*.md .rovodev/subagents/devloop/

# Copy scripts
cp ~/projects/claude-plugins/plugins/rovodev/scripts/*.sh .rovodev/scripts/
chmod +x .rovodev/scripts/*.sh

# Copy skills
cp ~/projects/claude-plugins/plugins/rovodev/skills/*.md .rovodev/skills/
```

#### Step 2: Register in prompts.yml

Add these entries to `.rovodev/prompts.yml`:

```yaml
prompts:
  # ... existing prompts ...

  # Devloop workflow prompts
  - name: devloop
    description: "Start new development work with structured planning"
    content_file: prompts/devloop/rovodev.md
  
  - name: spike
    description: "Time-boxed investigation and exploration (15-20 min)"
    content_file: prompts/devloop/spike.md
  
  - name: continue
    description: "Resume work from existing plan or saved state"
    content_file: prompts/devloop/continue.md
  
  - name: fresh
    description: "Save state for context reset"
    content_file: prompts/devloop/fresh.md
  
  - name: quick
    description: "Fast fixes without planning overhead"
    content_file: prompts/devloop/quick.md
  
  - name: review
    description: "Code review for changes or PRs"
    content_file: prompts/devloop/review.md
  
  - name: ship
    description: "Commit and create PR"
    content_file: prompts/devloop/ship.md
```

#### Step 3: Use the Prompts

```bash
# Start new work
rovodev run "@devloop Add user authentication"

# Run a spike
rovodev run "@spike How does MCP authentication work?"

# Continue from plan
rovodev run "@continue"

# Save state
rovodev run "@fresh"

# Quick fix
rovodev run "@quick Fix whitespace bug"

# Review code
rovodev run "@review"

# Ship it
rovodev run "@ship"
```

### Method 2: Global Installation (~/.rovodev)

Install globally so all your projects can use the prompts.

#### Step 1: Copy to Global Config

```bash
# Create directories
mkdir -p ~/.rovodev/prompts/devloop
mkdir -p ~/.rovodev/subagents/devloop
mkdir -p ~/.rovodev/scripts
mkdir -p ~/.rovodev/skills

# Copy files
cp ~/projects/claude-plugins/plugins/rovodev/prompts/*.md ~/.rovodev/prompts/devloop/
cp ~/projects/claude-plugins/plugins/rovodev/subagents/*.md ~/.rovodev/subagents/devloop/
cp ~/projects/claude-plugins/plugins/rovodev/scripts/*.sh ~/.rovodev/scripts/
chmod +x ~/.rovodev/scripts/*.sh
cp ~/projects/claude-plugins/plugins/rovodev/skills/*.md ~/.rovodev/skills/
```

#### Step 2: Create Global prompts.yml

If `~/.rovodev/prompts.yml` doesn't exist, create it:

```yaml
prompts:
  - name: devloop
    description: "Start new development work with structured planning"
    content_file: prompts/devloop/rovodev.md
  
  - name: spike
    description: "Time-boxed investigation and exploration"
    content_file: prompts/devloop/spike.md
  
  - name: continue
    description: "Resume work from existing plan"
    content_file: prompts/devloop/continue.md
  
  - name: fresh
    description: "Save state for context reset"
    content_file: prompts/devloop/fresh.md
  
  - name: quick
    description: "Fast fixes without planning"
    content_file: prompts/devloop/quick.md
  
  - name: review
    description: "Code review"
    content_file: prompts/devloop/review.md
  
  - name: ship
    description: "Commit and PR"
    content_file: prompts/devloop/ship.md
```

**Note**: Check if rovodev supports global prompts by default. You may need to configure this in `~/.rovodev/config.yml`.

### Method 3: Symlink (Development)

For active development on the prompts, use symlinks:

```bash
cd ~/projects/acra-python/.rovodev

# Create symlinks
ln -sf ~/projects/claude-plugins/plugins/rovodev/prompts prompts/devloop
ln -sf ~/projects/claude-plugins/plugins/rovodev/subagents subagents/devloop
ln -sf ~/projects/claude-plugins/plugins/rovodev/scripts scripts
ln -sf ~/projects/claude-plugins/plugins/rovodev/skills skills
```

Then register in `prompts.yml` as in Method 1.

## Verification

After installation, verify the prompts are registered:

```bash
# Check if files exist
ls -la .rovodev/prompts/devloop/
ls -la .rovodev/subagents/devloop/

# Try using a prompt
rovodev run "@devloop Test if prompts work"
```

## Usage Examples

### Complete Workflow

```bash
# 1. Start new feature
rovodev run "@devloop Add JWT authentication"
# Creates .devloop/plan.md

# 2. Need investigation first?
rovodev run "@spike Which JWT library to use?"
# Creates .devloop/spikes/YYYY-MM-DD-jwt-library.md

# 3. Continue implementation
rovodev run "@continue"
# Implements tasks from plan

# 4. Context getting full
rovodev run "@fresh"
# Saves state to .devloop/next-action.json

# ... new session ...

# 5. Resume
rovodev run "@continue"
# Loads saved state and continues

# 6. Review before shipping
rovodev run "@review"
# Generates code review

# 7. Ship it
rovodev run "@ship"
# Commits with conventional message, creates PR
```

### Quick Fix

```bash
rovodev run "@quick Fix the whitespace handling bug"
# No plan needed, just fix and commit
```

### Code Review

```bash
rovodev run "@review Review the authentication changes"
# Analyzes staged or branch changes
```

## Subagent Usage

Subagents are specialized for specific tasks. Rovodev should automatically recognize them from the YAML frontmatter.

**Current subagents:**
- `task-planner` - Planning and DoD validation
- `engineer` - Code exploration and architecture
- `reviewer` - Code review
- `doc-generator` - Documentation

**Note**: Check rovodev documentation for how to invoke subagents (may be automatic based on task or manual with `@subagent-name`).

## Scripts

Helper scripts are available in `.rovodev/scripts/`:

```bash
# Check plan completion
bash .rovodev/scripts/check-plan-complete.sh .devloop/plan.md

# Parse local config
bash .rovodev/scripts/parse-local-config.sh git.auto-branch
```

## Skills Reference

Skills provide reusable knowledge. Reference them when needed:

```bash
# In a rovodev session
rovodev run "How do I manage plans? Reference .rovodev/skills/plan-management.md"
```

## Configuration

### Local Project Config

Create `.devloop/local.md` in your project:

```yaml
git:
  auto-branch: true
  branch-prefix: feat/
  default-base: main

workflow:
  auto-test: true
  format-on-save: true
```

### Global Config

Edit `~/.rovodev/config.yml` if you want to customize agent behavior for devloop workflows.

## Troubleshooting

### Prompts not found

```bash
# Check prompts.yml syntax
cat .rovodev/prompts.yml

# Verify file paths are correct
ls -la .rovodev/prompts/devloop/rovodev.md
```

### Scripts not executable

```bash
chmod +x .rovodev/scripts/*.sh
```

### Subagents not working

Check the YAML frontmatter in subagent files:
```yaml
---
name: subagent-name
description: Description
tools:
  - bash
  - open_files
---
```

## Uninstallation

```bash
# Remove from prompts.yml (edit file)
# Then delete files
rm -rf .rovodev/prompts/devloop
rm -rf .rovodev/subagents/devloop
rm -rf .rovodev/scripts/check-plan-complete.sh
rm -rf .rovodev/scripts/parse-local-config.sh
rm -rf .rovodev/skills/plan-management.md
rm -rf .rovodev/skills/python-patterns.md
rm -rf .rovodev/skills/git-workflows.md
```

## Next Steps

1. **Install** using Method 1 (prompts.yml)
2. **Test** with a simple spike: `rovodev run "@spike Test workflow"`
3. **Try a feature** with full workflow: `@devloop → @continue → @ship`
4. **Customize** prompts for your needs
5. **Share** improvements back to this repo

See [INTEGRATION.md](INTEGRATION.md) for more details on the workflow patterns.
