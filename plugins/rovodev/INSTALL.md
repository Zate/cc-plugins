# Installation Guide

How to install and configure rovodevloop for use with Rovo Dev CLI.

## Prerequisites

- Rovo Dev CLI installed and working
- Git (for cloning the repository)
- Bash shell

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/rovodevloop.git ~/projects/rovodevloop

# Run installer (global install with symlinks)
cd ~/projects/rovodevloop
./install.sh
```

That's it! The installer will guide you through the rest.

## Installation Methods

### Method 1: Automated Install with Symlinks (Recommended)

This method uses the provided `install.sh` script to create symlinks, so you always have the latest version.

#### Global Install (Available to all projects)

```bash
# Clone repository
git clone https://github.com/yourusername/rovodevloop.git ~/projects/rovodevloop

# Run installer
cd ~/projects/rovodevloop
./install.sh
```

**What this does:**
- Creates symlinks in `~/.rovodev/prompts/devloop/`, `~/.rovodev/subagents/devloop/`, etc.
- Prompts you to create `~/.rovodev/prompts.yml` if it doesn't exist
- Makes prompts available to all your projects
- Updates automatically when you `git pull` in rovodevloop repo

#### Local Install (Project-specific)

```bash
# Clone repository (if not already)
git clone https://github.com/yourusername/rovodevloop.git ~/projects/rovodevloop

# Install to specific project
cd ~/projects/rovodevloop
./install.sh --local ~/projects/acra-python
```

**What this does:**
- Creates symlinks in `~/projects/acra-python/.rovodev/`
- Prompts you to create/update `.rovodev/prompts.yml` in that project
- Only available in that specific project

### Method 2: Automated Install with Copies

If you prefer copying files instead of symlinking (e.g., for CI/CD or offline use):

#### Global Install (Copy)

```bash
cd ~/projects/rovodevloop
./install.sh --no-link
```

#### Local Install (Copy)

```bash
cd ~/projects/rovodevloop
./install.sh --local ~/projects/acra-python --no-link
```

**Note:** With copies, you need to run `./install.sh -u` or `./install.sh -u --local <path>` to update when rovodevloop changes.

### Method 3: Manual Installation

If you prefer manual control:

#### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/rovodevloop.git ~/projects/rovodevloop
```

#### Step 2: Create Symlinks or Copy Files

**For global install:**
```bash
mkdir -p ~/.rovodev/{prompts,subagents,skills,scripts}
ln -sf ~/projects/rovodevloop/prompts ~/.rovodev/prompts/devloop
ln -sf ~/projects/rovodevloop/subagents ~/.rovodev/subagents/devloop
ln -sf ~/projects/rovodevloop/skills/*.md ~/.rovodev/skills/
ln -sf ~/projects/rovodevloop/scripts/*.sh ~/.rovodev/scripts/
chmod +x ~/.rovodev/scripts/*.sh
```

**For local install:**
```bash
mkdir -p ~/projects/acra-python/.rovodev/{prompts,subagents,skills,scripts}
ln -sf ~/projects/rovodevloop/prompts ~/projects/acra-python/.rovodev/prompts/devloop
ln -sf ~/projects/rovodevloop/subagents ~/projects/acra-python/.rovodev/subagents/devloop
ln -sf ~/projects/rovodevloop/skills/*.md ~/projects/acra-python/.rovodev/skills/
ln -sf ~/projects/rovodevloop/scripts/*.sh ~/projects/acra-python/.rovodev/scripts/
chmod +x ~/projects/acra-python/.rovodev/scripts/*.sh
```

#### Step 3: Register in prompts.yml

Add these entries to `~/.rovodev/prompts.yml` (global) or `<project>/.rovodev/prompts.yml` (local):

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

## Updating Installation

### Update Symlinked Installation

If you used symlinks (default), just pull the latest changes:

```bash
cd ~/projects/rovodevloop
git pull
```

Your installation automatically uses the latest version!

### Update Copied Installation

If you used `--no-link`, run the update command:

```bash
# Update global
cd ~/projects/rovodevloop
./install.sh -u

# Update local
./install.sh -u --local ~/projects/acra-python
```

### Update with --no-link

To update a copied installation:

```bash
./install.sh -u --no-link
./install.sh -u --local ~/projects/acra-python --no-link
```

## Uninstalling

### Uninstall Global

```bash
cd ~/projects/rovodevloop
./install.sh --uninstall
```

### Uninstall Local

```bash
cd ~/projects/rovodevloop
./install.sh --uninstall --local ~/projects/acra-python
```

**Note:** You may need to manually remove entries from `prompts.yml` after uninstalling.

## Verification

After installation, verify everything is set up correctly:

```bash
# Check files are in place (global)
ls -la ~/.rovodev/prompts/devloop/
ls -la ~/.rovodev/subagents/devloop/

# Check files are in place (local)
ls -la ~/projects/acra-python/.rovodev/prompts/devloop/

# Check prompts.yml has entries
cat ~/.rovodev/prompts.yml | grep devloop

# Test a prompt
rovodev run "@devloop Test if it works"
```

## Usage Examples

### Complete Workflow

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
