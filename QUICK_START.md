# Quick Start - Copy Files to Rovodevloop

## Step 1: Copy Updated Files

```bash
# Copy the three updated files
cp /Users/zberg/projects/cc-plugins/plugins/rovodev/install.sh ~/projects/rovodevloop/
cp /Users/zberg/projects/cc-plugins/plugins/rovodev/README.md ~/projects/rovodevloop/
cp /Users/zberg/projects/cc-plugins/plugins/rovodev/INSTALL.md ~/projects/rovodevloop/

# Make install script executable
chmod +x ~/projects/rovodevloop/install.sh
```

## Step 2: Test the Install Script

```bash
cd ~/projects/rovodevloop

# Show help
./install.sh --help

# Try a dry run (global install)
./install.sh
```

## Step 3: Use with Rovodev

```bash
# Go to your project
cd ~/projects/acra-python

# Test a prompt
rovodev run "@devloop Test the workflow"
```

## What You'll Have

After running `./install.sh`, you'll have:

- **Prompts**: `~/.rovodev/prompts/devloop/` (7 prompts)
- **Subagents**: `~/.rovodev/subagents/devloop/` (4 subagents)
- **Skills**: `~/.rovodev/skills/` (3 skills)
- **Scripts**: `~/.rovodev/scripts/` (2 scripts)
- **Config**: `~/.rovodev/prompts.yml` (auto-created if missing)

All linked via symlinks, so they auto-update when you `git pull` in rovodevloop!

## Available Prompts

| Prompt | Description | Usage |
|--------|-------------|-------|
| `@devloop` | Start new work with planning | `rovodev run "@devloop Add feature"` |
| `@spike` | 15-20 min investigation | `rovodev run "@spike How does X work?"` |
| `@continue` | Resume from plan | `rovodev run "@continue"` |
| `@fresh` | Save state for reset | `rovodev run "@fresh"` |
| `@quick` | Fast fixes | `rovodev run "@quick Fix bug"` |
| `@review` | Code review | `rovodev run "@review"` |
| `@ship` | Commit and PR | `rovodev run "@ship"` |

## Troubleshooting

### Files not found after install

```bash
# Check if symlinks were created
ls -la ~/.rovodev/prompts/devloop/

# Check prompts.yml
cat ~/.rovodev/prompts.yml | grep devloop
```

### Prompts not recognized by rovodev

```bash
# Make sure prompts.yml has the entries
cat ~/.rovodev/prompts.yml

# If missing, the installer should have prompted you
# Run installer again and answer 'y' when asked
cd ~/projects/rovodevloop
./install.sh
```

### Want to test without affecting global install

```bash
# Use local install on a test project
./install.sh --local ~/projects/test-project
```

## Next Steps

1. ✅ Copy files (commands above)
2. ✅ Run installer
3. ✅ Test with rovodev
4. 📝 Try a real workflow:
   ```bash
   cd ~/projects/acra-python
   rovodev run "@spike Explore the MCP server architecture"
   rovodev run "@devloop Add JWT authentication"
   rovodev run "@continue"
   rovodev run "@ship"
   ```

That's it! You're ready to use rovodevloop! 🚀
