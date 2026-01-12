# Rovodevloop Setup Summary

## What We've Created

A complete standalone repository structure for rovodevloop with an automated installer script.

### Files Created/Updated

1. **install.sh** - Automated installation script with full feature set
2. **README.md** - Updated for standalone repository
3. **INSTALL.md** - Comprehensive installation guide
4. All existing prompts, subagents, skills, and scripts

## Current Status

✅ **Completed:**
- Install script with symlink/copy support
- Documentation updated for standalone repo
- All features implemented:
  - Global install (`./install.sh`)
  - Local install (`./install.sh --local <path>`)
  - Copy mode (`--no-link`)
  - Update mode (`-u`)
  - Uninstall mode (`--uninstall`)

🔄 **Next Steps:**
- Test global install
- Test local install with symlinks
- Test copy mode

## Files to Copy to ~/projects/rovodevloop

You already have most files in `~/projects/rovodevloop/`. Just need to update these:

```bash
# Copy updated files from cc-plugins workspace
cd /Users/zberg/projects/cc-plugins

# Copy to rovodevloop
cp plugins/rovodev/install.sh ~/projects/rovodevloop/
cp plugins/rovodev/README.md ~/projects/rovodevloop/
cp plugins/rovodev/INSTALL.md ~/projects/rovodevloop/

# Make install script executable
chmod +x ~/projects/rovodevloop/install.sh
```

## Install Script Features

### Usage Examples

```bash
# Global install (symlink) - DEFAULT
cd ~/projects/rovodevloop
./install.sh

# Local install (symlink)
./install.sh --local ~/projects/acra-python

# Global install (copy)
./install.sh --no-link

# Local install (copy)
./install.sh --local ~/projects/acra-python --no-link

# Update global (symlink auto-updates on git pull)
./install.sh -u

# Update local
./install.sh -u --local ~/projects/acra-python

# Update copied version
./install.sh -u --no-link
./install.sh -u --local ~/projects/acra-python --no-link

# Uninstall global
./install.sh --uninstall

# Uninstall local
./install.sh --uninstall --local ~/projects/acra-python

# Help
./install.sh --help
```

### What the Installer Does

1. **Creates directories** in target location (`~/.rovodev/` or `<project>/.rovodev/`)
2. **Installs files** via symlink or copy:
   - `prompts/devloop/` → All workflow prompts
   - `subagents/devloop/` → All subagents
   - `skills/*.md` → All skill documentation
   - `scripts/*.sh` → Helper scripts
3. **Makes scripts executable**
4. **Prompts to create prompts.yml** if it doesn't exist
5. **Shows next steps** for verification and usage

### Installation Methods

| Method | Pros | Cons | Use When |
|--------|------|------|----------|
| **Symlink (global)** | Auto-updates, available everywhere | Requires rovodevloop repo | Development, personal use |
| **Symlink (local)** | Auto-updates, project-specific | Requires rovodevloop repo | Project-specific workflows |
| **Copy (global)** | Works offline, no dependencies | Must manually update | CI/CD, shared systems |
| **Copy (local)** | Works offline, portable | Must manually update | Distributing to team |

## Testing Plan

### Test 1: Global Install (Symlink)

```bash
cd ~/projects/rovodevloop
./install.sh

# Verify
ls -la ~/.rovodev/prompts/devloop/
ls -la ~/.rovodev/subagents/devloop/
cat ~/.rovodev/prompts.yml | grep devloop

# Test usage
cd ~/projects/acra-python
rovodev run "@devloop Test workflow"
```

### Test 2: Local Install (Symlink)

```bash
cd ~/projects/rovodevloop
./install.sh --local ~/projects/acra-python

# Verify
ls -la ~/projects/acra-python/.rovodev/prompts/devloop/
cat ~/projects/acra-python/.rovodev/prompts.yml | grep devloop

# Test usage
cd ~/projects/acra-python
rovodev run "@spike Test spike workflow"
```

### Test 3: Copy Mode

```bash
cd ~/projects/rovodevloop
./install.sh --no-link

# Verify files are copies, not symlinks
ls -la ~/.rovodev/prompts/devloop/ | grep -v "^l"

# Test update
./install.sh -u --no-link
```

### Test 4: Update and Uninstall

```bash
# Test update
./install.sh -u
./install.sh -u --local ~/projects/acra-python

# Test uninstall
./install.sh --uninstall
# Verify files removed
ls ~/.rovodev/prompts/devloop/ # Should not exist

# Reinstall for continued use
./install.sh
```

## Rovodevloop Repository Structure

```
rovodevloop/
├── install.sh              # Installation script
├── README.md               # Repository overview
├── INSTALL.md              # Installation guide
├── INTEGRATION.md          # Usage patterns
├── CHANGELOG.md            # Version history
├── prompts.yml.snippet     # YAML config snippet
├── prompts/                # Workflow prompts (7 files)
│   ├── rovodev.md
│   ├── spike.md
│   ├── continue.md
│   ├── fresh.md
│   ├── quick.md
│   ├── review.md
│   └── ship.md
├── subagents/              # Specialized agents (4 files)
│   ├── task-planner.md
│   ├── engineer.md
│   ├── reviewer.md
│   └── doc-generator.md
├── skills/                 # Knowledge docs (3 files)
│   ├── plan-management.md
│   ├── python-patterns.md
│   └── git-workflows.md
└── scripts/                # Helper scripts (2 files)
    ├── check-plan-complete.sh
    └── parse-local-config.sh
```

## Usage After Installation

Once installed, use the prompts with rovodev:

```bash
# Start new work
rovodev run "@devloop Add user authentication"

# Run investigation
rovodev run "@spike How does JWT work?"

# Continue from plan
rovodev run "@continue"

# Save state
rovodev run "@fresh"

# Quick fix
rovodev run "@quick Fix bug"

# Review code
rovodev run "@review"

# Ship changes
rovodev run "@ship"
```

## Workflow Files Created

The workflow uses these files in your projects:

```
<project>/
├── .devloop/
│   ├── plan.md              # Current work plan
│   ├── next-action.json     # Fresh start state (temp)
│   ├── local.md             # Project config (optional)
│   ├── spikes/              # Spike reports
│   │   └── YYYY-MM-DD-topic.md
│   └── archive/             # Completed plans
│       └── YYYY-MM-DD-feature.md
└── .rovodev/
    └── prompts.yml          # Prompt registration
```

## Next Actions

1. **Copy updated files** to rovodevloop repository:
   ```bash
   cp /Users/zberg/projects/cc-plugins/plugins/rovodev/{install.sh,README.md,INSTALL.md} ~/projects/rovodevloop/
   chmod +x ~/projects/rovodevloop/install.sh
   ```

2. **Test the installer:**
   ```bash
   cd ~/projects/rovodevloop
   ./install.sh --help
   ./install.sh  # Try global install
   ```

3. **Initialize git repo** (if not already):
   ```bash
   cd ~/projects/rovodevloop
   git init
   git add .
   git commit -m "feat: initial rovodevloop with automated installer"
   ```

4. **Test with rovodev:**
   ```bash
   cd ~/projects/acra-python
   rovodev run "@devloop Test the workflow"
   ```

5. **Push to GitHub** (optional):
   ```bash
   cd ~/projects/rovodevloop
   git remote add origin https://github.com/yourusername/rovodevloop.git
   git push -u origin main
   ```

## Advantages of This Setup

✅ **No source code modification** - Uses rovodev's existing `.rovodev/prompts.yml` system
✅ **Flexible installation** - Global, local, symlink, or copy
✅ **Easy updates** - Symlinks auto-update, copies have update command
✅ **Portable** - Can be cloned and used on any system
✅ **Version controlled** - Full git history of prompts and workflows
✅ **Team friendly** - Easy to share and collaborate on workflows
✅ **CI/CD ready** - Copy mode works in automated environments

## Questions?

- **Where are files installed?** 
  - Global: `~/.rovodev/prompts/devloop/`, etc.
  - Local: `<project>/.rovodev/prompts/devloop/`, etc.

- **How do I update?**
  - Symlinks: Just `git pull` in rovodevloop repo
  - Copies: Run `./install.sh -u` or `./install.sh -u --local <path>`

- **Can I customize prompts?**
  - Yes! Edit files in rovodevloop repo, symlinks update immediately

- **Can I use both global and local?**
  - Yes! Local `.rovodev/prompts.yml` takes precedence

- **What if I don't want all prompts?**
  - Edit `prompts.yml` to include only the prompts you want

Happy coding! 🚀
