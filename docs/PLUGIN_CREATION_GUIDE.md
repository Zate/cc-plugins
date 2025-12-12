# Claude Code Plugin Creation Guide for Agents

This guide provides comprehensive instructions for AI agents to create new Claude Code plugins within this multi-plugin marketplace repository.

## Table of Contents

1. [Overview](#overview)
2. [Plugin Structure](#plugin-structure)
3. [Creating a New Plugin](#creating-a-new-plugin)
4. [Component Specifications](#component-specifications)
5. [Best Practices](#best-practices)
6. [Testing and Validation](#testing-and-validation)

---

## Overview

### What is a Claude Code Plugin?

A Claude Code plugin extends Claude's capabilities with:
- **Custom slash commands** - User-invocable commands (e.g., `/namespace:command`)
- **Specialized agents** - Autonomous task-focused assistants
- **Skills** - Auto-activating expertise based on context
- **Hooks** - Event-driven automation
- **Scripts** - Reusable bash utilities

### Multi-Plugin Repository Structure

```
repository-root/
├── .claude-plugin/
│   └── marketplace.json        # Lists all plugins in this marketplace
├── plugins/
│   ├── plugin-name-1/         # First plugin
│   │   └── .claude-plugin/
│   │       └── plugin.json
│   └── plugin-name-2/         # Second plugin
│       └── .claude-plugin/
│           └── plugin.json
├── README.md                   # Main marketplace documentation
└── PLUGIN_CREATION_GUIDE.md   # This guide
```

---

## Plugin Structure

### Required Directory Structure

Each plugin MUST follow this structure:

```
plugins/{plugin-name}/
├── .claude-plugin/
│   └── plugin.json             # REQUIRED: Plugin metadata
├── commands/                   # OPTIONAL: Slash commands
│   └── *.md                   # Command definitions
├── agents/                     # OPTIONAL: Custom agents
│   └── *.md                   # Agent definitions
├── skills/                     # OPTIONAL: Auto-activating skills
│   └── {skill-name}/
│       └── SKILL.md           # Skill definition (MUST be named SKILL.md)
├── hooks/                      # OPTIONAL: Event hooks
│   └── hooks.json             # Hook definitions
├── scripts/                    # OPTIONAL: Helper scripts
│   └── *.sh                   # Bash scripts
└── README.md                   # RECOMMENDED: Plugin documentation
```

### Naming Conventions

- **Plugin namespace**: Short, lowercase, no spaces (e.g., `gd`, `py`, `web`)
- **Commands**: Use `namespace:action` format (e.g., `/gd:setup`, `/py:test`)
- **Files**: Use kebab-case for markdown files (e.g., `setup.md`, `init-game.md`)
- **Scripts**: Use kebab-case with `.sh` extension (e.g., `validate-env.sh`)
- **Directories**: Use lowercase with hyphens (e.g., `game-planner`, `godot-dev`)

---

## Creating a New Plugin

### Step 1: Plan Your Plugin

Define:
1. **Purpose**: What does this plugin do?
2. **Target users**: Who will use it?
3. **Namespace**: What 2-4 letter prefix? (e.g., `gd` for Godot, `py` for Python)
4. **Core features**: What commands/agents/skills are needed?
5. **Dependencies**: What external tools or MCP servers are required?

### Step 2: Create Plugin Directory

```bash
mkdir -p plugins/{namespace}/.claude-plugin
mkdir -p plugins/{namespace}/commands
mkdir -p plugins/{namespace}/agents
mkdir -p plugins/{namespace}/skills
mkdir -p plugins/{namespace}/hooks
mkdir -p plugins/{namespace}/scripts
```

### Step 3: Create plugin.json

**Required file**: `plugins/{namespace}/.claude-plugin/plugin.json`

```json
{
  "name": "namespace",
  "version": "1.0.0",
  "description": "Brief description of what this plugin does and its key features",
  "author": {
    "name": "Author Name",
    "email": "author@example.com",
    "url": "https://github.com/username"
  },
  "homepage": "https://github.com/username/repo",
  "repository": "https://github.com/username/repo",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2", "keyword3"]
}
```

**Required fields**:
- `name`: Plugin namespace (MUST match directory name)
- `version`: Semantic version (e.g., "1.0.0")
- `description`: Clear, concise description

**Optional but recommended**:
- `author`: Object with `name`, `email`, `url`
- `homepage`: Plugin website or repo
- `repository`: GitHub repo URL
- `license`: License type
- `keywords`: Array of searchable keywords

### Step 4: Register in Marketplace

Edit `.claude-plugin/marketplace.json` to add your plugin:

```json
{
  "name": "marketplace-name",
  "owner": {
    "name": "Owner Name",
    "email": "owner@example.com"
  },
  "plugins": [
    {
      "name": "existing-plugin",
      "source": "./plugins/existing-plugin",
      "description": "Existing plugin description",
      "category": "development",
      "tags": ["tag1", "tag2"]
    },
    {
      "name": "namespace",
      "source": "./plugins/namespace",
      "description": "Your new plugin description",
      "category": "development",
      "tags": ["your", "tags"]
    }
  ]
}
```

**Categories**: `development`, `productivity`, `ai`, `tools`, `gaming`, `web`, `data`, `other`

### Step 5: Add Components

Add commands, agents, skills, hooks, and scripts as needed (see Component Specifications below).

### Step 6: Create Documentation

Create `plugins/{namespace}/README.md` with:
- Plugin overview
- Installation instructions
- Usage examples
- Available commands
- Configuration options
- Troubleshooting

---

## Component Specifications

### Commands (`commands/*.md`)

Slash commands are markdown files with YAML frontmatter.

**File format**: `commands/{command-name}.md`

**Template**:
```markdown
---
description: Brief description of what this command does
allowed-tools:
  - Tool1
  - Tool2(specific:function)
  - Bash(command1:*,command2:*)
---

Prompt that Claude will receive when the command is invoked.

You can:
- Give instructions
- Reference scripts: !bash ${CLAUDE_PLUGIN_ROOT}/scripts/script-name.sh
- Use environment variables: ${CLAUDE_PROJECT_DIR}, ${CLAUDE_PLUGIN_ROOT}
- Provide context and guidance
```

**Frontmatter fields**:
- `description` (REQUIRED): Shows up when listing commands
- `allowed-tools` (OPTIONAL): Restrict which tools Claude can use
  - Use `*` for wildcards (e.g., `mcp__godot__*`)
  - Specify exact patterns (e.g., `Bash(ls:*,which:*,test:*)`)

**Available environment variables**:
- `${CLAUDE_PROJECT_DIR}`: Absolute path to user's project root
- `${CLAUDE_PLUGIN_ROOT}`: Absolute path to plugin directory

**Command invocation**:
- Users type: `/namespace:command-name`
- Example: `/gd:setup` runs `commands/setup.md`

**Best practices**:
- Keep commands focused on one task
- Use descriptive names (verb-noun pattern)
- Delegate complex logic to scripts
- Provide clear success/failure messages
- Remind users to restart Claude Code if needed (e.g., after MCP changes)

### Agents (`agents/*.md`)

Agents are autonomous assistants launched via the Task tool.

**File format**: `agents/{agent-name}.md`

**Template**:
```markdown
---
description: Brief description of what this agent does and when to use it
allowed-tools:
  - AskUserQuestion
  - Read
  - Write
  - Bash(specific:commands)
---

You are a specialized agent for [specific purpose].

## Your Goal

Clearly state what the agent should accomplish.

## Process

1. Step 1: What to do first
2. Step 2: What to do next
3. Step 3: Final steps

## Guidelines

- Specific behavior instructions
- What to ask the user
- What output to produce
- How to handle errors

## Output

Define exactly what the agent should return to the calling command or user.
```

**Frontmatter fields**:
- `description` (REQUIRED): When this agent should be used
- `allowed-tools` (OPTIONAL): Restrict available tools

**Invocation methods**:

1. **From commands**: Use Task tool in command markdown
   ```markdown
   !task subagent_type=custom-agent-name
   ```

2. **Programmatically**: Commands can invoke agents
   ```markdown
   Use the Task tool to launch the {agent-name} agent.
   ```

**Best practices**:
- Make agents conversational (use AskUserQuestion)
- Have clear, structured output
- Handle edge cases gracefully
- Return comprehensive results

### Skills (`skills/{skill-name}/SKILL.md`)

Skills auto-activate based on context matching.

**File format**: `skills/{skill-name}/SKILL.md` (MUST be named `SKILL.md`)

**Template**:
```markdown
---
name: skill-identifier
description: Detailed description of when this skill should activate. Be specific about topics, keywords, and use cases that should trigger this skill.
allowed-tools:
  - mcp__service__*
  - Read
  - Write
  - Edit
---

# Skill Name

You are an expert in [domain/technology].

## Core Knowledge

### Topic 1
- Detailed information
- Key concepts
- Common patterns

### Topic 2
- More expertise
- Best practices

## Available Tools

Document any MCP tools or special capabilities:
- `mcp__service__tool1`: What it does
- `mcp__service__tool2`: What it does

## Common Tasks

### Task 1: Description
Step-by-step approach:
1. Do this
2. Then this
3. Finally this

### Task 2: Description
Another common pattern...

## Code Examples

```language
# Provide relevant code samples
```

## Best Practices

- Practice 1
- Practice 2

## When to Use This Skill

Explicitly list scenarios:
- User asks about X
- User wants to do Y
- User mentions keywords like Z
```

**Frontmatter fields**:
- `name` (REQUIRED): Unique skill identifier
- `description` (REQUIRED): Claude matches this against user messages to auto-activate
- `allowed-tools` (OPTIONAL): Restrict available tools

**Activation**:
- Skills activate automatically when user messages match the description
- Be specific in descriptions to avoid false activations
- Include relevant keywords and phrases users might say

**Best practices**:
- Make descriptions specific and detailed
- Include domain knowledge and patterns
- Document available MCP tools
- Provide code examples
- Use skills for deep expertise areas
- Test activation by asking questions that should trigger it

### Hooks (`hooks/hooks.json`)

Hooks run automatically on events.

**File format**: `hooks/hooks.json`

**Template**:
```json
{
  "description": "Brief description of what these hooks do",
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/script-name.sh",
        "description": "What this hook does"
      }
    ],
    "PreToolUse": [
      {
        "type": "command",
        "command": "echo 'Before tool use'",
        "description": "Runs before each tool use"
      }
    ]
  }
}
```

**Available hook events**:
- `SessionStart`: When Claude Code session starts
- `SessionEnd`: When session ends
- `PreToolUse`: Before any tool is used
- `PostToolUse`: After any tool is used
- `UserPromptSubmit`: When user submits a message
- `Stop`: When user stops Claude
- `SubagentStop`: When subagent is stopped
- `Notification`: On notifications
- `PreCompact`: Before context compaction

**Hook structure**:
- `type`: Always `"command"` for now
- `command`: Shell command to run (can use `${CLAUDE_PLUGIN_ROOT}`)
- `description`: What the hook does

**Best practices**:
- Make hooks non-blocking (exit code 0 for validation)
- Keep hooks fast (avoid slow operations)
- Use for validation, setup, cleanup
- Provide helpful warnings, not errors
- Test thoroughly (hooks run automatically)

### Scripts (`scripts/*.sh`)

Reusable bash scripts called by commands and hooks.

**File format**: `scripts/{script-name}.sh`

**Template**:
```bash
#!/bin/bash
#
# Description: What this script does
# Usage: script-name.sh [args]
# Returns: Exit code 0 on success, 1 on failure

set -e  # Exit on error (optional, use for strict mode)

# Available environment variables:
# - CLAUDE_PROJECT_DIR: User's project root
# - CLAUDE_PLUGIN_ROOT: Plugin directory

# Script logic here
echo "Doing something..."

# Exit with appropriate code
exit 0
```

**Best practices**:
- Include shebang: `#!/bin/bash`
- Add header comments
- Use `set -e` for strict error handling (optional)
- Make scripts executable: `chmod +x script.sh`
- Use `${CLAUDE_PROJECT_DIR}` for user's project
- Use `${CLAUDE_PLUGIN_ROOT}` for plugin files
- Provide clear output messages
- Exit with proper codes (0 = success, 1 = failure)

**Common patterns**:

1. **Validation script**:
```bash
#!/bin/bash
# Validate environment

if [ ! -f "${CLAUDE_PROJECT_DIR}/.config" ]; then
    echo "Warning: Configuration not found"
    exit 0  # Non-blocking warning
fi

echo "Environment OK"
exit 0
```

2. **Setup script**:
```bash
#!/bin/bash
# Setup environment

echo "Setting up..."

# Detect tools
TOOL_PATH=$(which tool_name 2>/dev/null || echo "")

if [ -z "$TOOL_PATH" ]; then
    echo "Error: tool_name not found"
    exit 1
fi

# Create config
cat > "${CLAUDE_PROJECT_DIR}/.config" <<EOF
tool_path=$TOOL_PATH
EOF

echo "Setup complete!"
exit 0
```

---

## Quality Standards

This section defines the quality bar for plugins in this marketplace, based on lessons learned from code reviews.

### Skill Quality Standards

Every skill MUST include:

1. **Frontmatter with name and description**:
   ```yaml
   ---
   name: skill-name
   description: Clear description including when to invoke. Use when [specific triggers].
   ---
   ```

2. **"When NOT to Use" section** (REQUIRED):
   ```markdown
   ## When NOT to Use This Skill

   - **Scenario 1**: Reason not to use
   - **Scenario 2**: Reason not to use
   - **Alternative**: Use X skill instead for Y
   ```

3. **Version notes for language-specific skills**:
   ```markdown
   **Python Version**: These patterns target Python 3.10+.
   ```

4. **Quick Reference table** (recommended for complex skills):
   ```markdown
   | Pattern | Use When | Avoid When |
   |---------|----------|------------|
   ```

### Agent Quality Standards

Every agent MUST include:

1. **Clear description with invocation triggers**:
   ```yaml
   description: Does X. Use when Y happens or user asks Z.
   ```

2. **Appropriate model selection**:
   | Task Type | Model |
   |-----------|-------|
   | Simple classification, formulaic patterns | haiku |
   | Code generation, analysis, implementation | sonnet |
   | Security review, complex architecture | opus |

3. **Differentiation from similar agents**:
   If overlap exists with another agent, add a comparison table:
   ```markdown
   ## When to Use vs. other-agent

   | Scenario | Use This | Use other-agent |
   |----------|----------|-----------------|
   ```

4. **Tools matching actual needs**:
   - Don't include tools the agent won't use
   - Don't omit tools the agent needs
   - Review tool list against agent's workflow

5. **Color coding for visual identification**:
   The `color` frontmatter field displays when the agent is invoked, helping users identify agent categories:
   ```yaml
   color: indigo
   ```

   Recommended color scheme:
   | Color | Category | Use For |
   |-------|----------|---------|
   | yellow | Exploration | Discovery, investigation agents |
   | indigo | Architecture | Design, planning agents |
   | red | Critical | Review, security agents |
   | cyan | Testing | Test generation, execution |
   | green | Validation | QA, approval gate agents |
   | blue | Requirements | Analysis, assessment agents |
   | orange | Integration | Git, issue tracking agents |
   | teal | Documentation | Docs, summary agents |

### Command Quality Standards

Every command MUST include:

1. **Complete frontmatter**:
   ```yaml
   ---
   description: Clear description of what the command does
   argument-hint: What arguments the command accepts (or "None required")
   allowed-tools: [List of tools needed]
   ---
   ```

2. **Standard section order** (recommended):
   1. Title + Brief intro
   2. Plan Integration (if applicable)
   3. When to Use
   4. When NOT to Use (if helpful)
   5. Workflow
   6. Output format / Examples
   7. Model Usage (if varies)

3. **Tool permissions matching workflow**:
   - List only tools actually used in the command
   - Include all tools referenced in the workflow

### Hook & Script Quality Standards

#### Shell Scripts

1. **Use `set -euo pipefail`** for strict error handling
2. **Check for dependencies** before using them:
   ```bash
   if ! command -v jq &> /dev/null; then
       echo "Warning: jq not installed"
       # fallback logic
   fi
   ```

3. **Proper JSON escaping** - use jq when available:
   ```bash
   if command -v jq &> /dev/null; then
       ESCAPED=$(printf '%s' "$VALUE" | jq -Rs '.')
   else
       # robust fallback
   fi
   ```

4. **Performance optimization**:
   - Combine multiple `find` commands into single pass
   - Avoid unnecessary subshells
   - Use efficient patterns for large codebases

5. **Quote all variables**:
   ```bash
   # Good
   if [ -d "$SOME_DIR" ]; then

   # Bad
   if [ -d $SOME_DIR ]; then
   ```

6. **Use explicit grouping for complex conditionals**:
   ```bash
   # Good - explicit precedence
   if { [ -n "$VAR" ] && [ -d "$VAR" ]; } || some_command; then

   # Bad - ambiguous precedence
   if [ -n "$VAR" ] && [ -d "$VAR" ] || some_command; then
   ```

#### Hook Configuration

1. **Appropriate timeouts**:
   - SessionStart: 30s for large projects
   - PreToolUse: 10-15s
   - PostToolUse: 10s
   - Stop: 20s

2. **Non-blocking by default**:
   - Hooks should not fail the operation unless critical
   - Use warnings instead of errors for non-critical issues

### Consistency Guidelines

#### Formatting Standards

1. **Tables**: Use aligned columns for readability
   ```markdown
   | Column 1 | Column 2 | Column 3 |
   |----------|----------|----------|
   | Value    | Value    | Value    |
   ```

2. **Code blocks**: Always specify language
   ```markdown
   ```bash  # Good
   ```      # Bad - no language
   ```

3. **Section headers**: Use consistent capitalization
   - `## When to Use` (not "When To Use" or "WHEN TO USE")

#### Naming Standards

1. **Files**: kebab-case (`my-command.md`, not `myCommand.md`)
2. **Skills**: kebab-case directories (`skill-name/SKILL.md`)
3. **Agents**: kebab-case (`code-reviewer.md`)
4. **JSON keys**: snake_case for data, camelCase for config

### Pre-Release Checklist

Before releasing a plugin update:

- [ ] All skills have "When NOT to Use" sections
- [ ] All agents have appropriate model selection
- [ ] All commands have complete frontmatter
- [ ] Shell scripts handle missing dependencies gracefully
- [ ] JSON output is properly escaped
- [ ] Similar components are differentiated clearly
- [ ] Version has been bumped appropriately
- [ ] All changes tested locally

---

## Best Practices

### General Guidelines

1. **Namespace everything**: Use consistent namespace across all commands
2. **Document thoroughly**: README, command descriptions, inline comments
3. **Test extensively**: Try all commands, agents, skills in real projects
4. **Keep it simple**: Start minimal, add complexity as needed
5. **Follow conventions**: Use established patterns from existing plugins
6. **Handle errors gracefully**: Provide helpful error messages
7. **Be idempotent**: Commands should be safe to run multiple times
8. **Version properly**: Use semantic versioning

### Plugin Design Patterns

#### Pattern 1: Setup Command + SessionStart Hook

Many plugins need environment setup:

1. **Setup command** (`/namespace:setup`): Interactive, creates config
2. **SessionStart hook**: Validates silently, warns if misconfigured

Example flow:
- User runs `/namespace:setup` → Creates `.config.json`
- Next session → Hook validates → Shows warning if broken
- Hook is non-blocking (exit 0) to avoid interrupting work

#### Pattern 2: Planning Agent + Init Command

For project initialization:

1. **Planning agent**: Asks questions, creates plan
2. **Init command**: Launches agent, uses plan to scaffold

Example flow:
- User runs `/namespace:init` → Launches planner agent
- Agent asks questions → Creates comprehensive plan
- Command receives plan → Creates files/folders

#### Pattern 3: Expertise Skill + Specialized Commands

For domain expertise:

1. **Skill**: Auto-activates on relevant questions
2. **Commands**: Specific actions in that domain

Example flow:
- User asks "How do I...?" → Skill activates → Provides guidance
- User runs `/namespace:action` → Command performs specific task

### Security Considerations

1. **Validate inputs**: Don't trust user input in scripts
2. **Restrict tools**: Use `allowed-tools` to limit access
3. **Avoid secrets**: Don't hardcode API keys or passwords
4. **Use absolute paths**: Prefer `${CLAUDE_PROJECT_DIR}` over relative paths
5. **Check file operations**: Verify paths before writing files

### Performance Tips

1. **Keep hooks fast**: Slow hooks delay every session
2. **Cache when possible**: Don't re-detect on every run
3. **Lazy load**: Only load what's needed
4. **Parallel operations**: Use multiple tool calls when possible
5. **Provide feedback**: Show progress for long operations

---

## Testing and Validation

### Before Publishing

1. **Test all commands**: Run every command in various scenarios
2. **Test skills activation**: Ask questions that should trigger skills
3. **Test agents**: Invoke agents with different inputs
4. **Test hooks**: Verify hooks run correctly and quickly
5. **Test scripts**: Run scripts with various inputs
6. **Check documentation**: Ensure README is complete and accurate
7. **Validate JSON**: Ensure all JSON files are valid
8. **Validate YAML**: Ensure all frontmatter is valid
9. **Test installation**: Install plugin fresh in clean environment
10. **Test with real users**: Get feedback on UX

### Validation Checklist

```markdown
- [ ] plugin.json exists and is valid
- [ ] All required fields in plugin.json are filled
- [ ] Plugin is registered in marketplace.json
- [ ] All commands have descriptions
- [ ] All agents have clear goals
- [ ] All skills have specific descriptions
- [ ] All scripts are executable (chmod +x)
- [ ] All scripts have proper shebangs
- [ ] hooks.json is valid JSON (if exists)
- [ ] README.md is complete
- [ ] All examples in README work
- [ ] No hardcoded paths (use env vars)
- [ ] Error messages are helpful
- [ ] Success messages are clear
- [ ] Tested in real project
```

### Common Issues and Fixes

| Issue | Solution |
|-------|----------|
| Commands not appearing | Restart Claude Code, check YAML syntax |
| Skills not activating | Make description more specific and detailed |
| Hooks not running | Check script paths, make executable, validate JSON |
| Scripts failing | Add error handling, check permissions, use absolute paths |
| MCP tools unavailable | User needs to restart Claude Code after config changes |

---

## Quick Reference

### File Extensions

- `.md` - Commands, agents, skills, README
- `.json` - Plugin metadata, hooks, marketplace listing
- `.sh` - Bash scripts

### Required Files

- `plugins/{namespace}/.claude-plugin/plugin.json` - Plugin metadata
- At least one of: command, agent, skill, hook, or script

### Optional but Recommended

- `plugins/{namespace}/README.md` - Plugin documentation
- `plugins/{namespace}/hooks/hooks.json` - SessionStart validation hook

### Environment Variables

- `${CLAUDE_PROJECT_DIR}` - User's project root
- `${CLAUDE_PLUGIN_ROOT}` - Plugin directory

### Command Format

```markdown
---
description: Command description
allowed-tools:
  - Tool1
  - Tool2
---

Command prompt here.
```

### Agent Format

```markdown
---
description: Agent description
allowed-tools:
  - Tool1
---

Agent instructions here.
```

### Skill Format

```markdown
---
name: skill-name
description: When to activate (be specific!)
allowed-tools:
  - Tool1
---

Skill expertise here.
```

---

## Example: Creating a Python Plugin

Let's create a Python development plugin step by step.

### 1. Plan

- **Purpose**: Python development tools
- **Namespace**: `py`
- **Features**: Virtual env setup, testing, linting
- **Dependencies**: Python, pytest, ruff

### 2. Create Structure

```bash
mkdir -p plugins/py/.claude-plugin
mkdir -p plugins/py/commands
mkdir -p plugins/py/skills/python-dev
mkdir -p plugins/py/hooks
mkdir -p plugins/py/scripts
```

### 3. Create plugin.json

```json
{
  "name": "py",
  "version": "1.0.0",
  "description": "Python development tools with /py:setup, /py:test commands and Python expertise",
  "author": {
    "name": "Your Name",
    "email": "your@email.com"
  },
  "license": "MIT",
  "keywords": ["python", "testing", "development"]
}
```

### 4. Add Setup Command

`plugins/py/commands/setup.md`:
```markdown
---
description: Set up Python development environment
allowed-tools:
  - Bash(python*:*,pip*:*)
  - Write
---

Set up a Python virtual environment for this project:

1. Create virtual environment: `python -m venv .venv`
2. Create requirements.txt if it doesn't exist
3. Install dependencies
4. Provide activation instructions
```

### 5. Add Test Command

`plugins/py/commands/test.md`:
```markdown
---
description: Run Python tests with pytest
allowed-tools:
  - Bash(pytest:*,python:*)
---

Run the test suite:

!bash pytest -v

Analyze results and report any failures.
```

### 6. Add Python Skill

`plugins/py/skills/python-dev/SKILL.md`:
```markdown
---
name: python-development
description: Expert Python developer knowledge including testing, package management, virtual environments, and common frameworks like FastAPI, Django, Flask
allowed-tools:
  - Bash(python*:*,pip*:*)
  - Read
  - Write
  - Edit
---

# Python Development Skill

You are an expert Python developer.

## Best Practices

- Use virtual environments
- Type hints for clarity
- Pytest for testing
- Ruff for linting
...
```

### 7. Add Validation Hook

`plugins/py/hooks/hooks.json`:
```json
{
  "description": "Python environment validation",
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate-python.sh",
        "description": "Check Python environment"
      }
    ]
  }
}
```

### 8. Add Validation Script

`plugins/py/scripts/validate-python.sh`:
```bash
#!/bin/bash
# Validate Python environment

if [ ! -d "${CLAUDE_PROJECT_DIR}/.venv" ]; then
    echo "Tip: Run /py:setup to create a virtual environment"
fi

exit 0  # Non-blocking
```

Make executable:
```bash
chmod +x plugins/py/scripts/validate-python.sh
```

### 9. Register in Marketplace

Edit `.claude-plugin/marketplace.json`:
```json
{
  "plugins": [
    ...existing plugins...,
    {
      "name": "py",
      "source": "./plugins/py",
      "description": "Python development tools",
      "category": "development",
      "tags": ["python", "testing"]
    }
  ]
}
```

### 10. Create README

`plugins/py/README.md`:
```markdown
# Python Development Plugin

Tools for Python development in Claude Code.

## Installation
/plugin install py@python-dev

## Commands
- /py:setup - Create virtual environment
- /py:test - Run pytest

...
```

### 11. Test

1. Restart Claude Code
2. Run `/py:setup` in a Python project
3. Run `/py:test`
4. Ask "How do I write a Python test?" (should activate skill)

---

## Summary

To create a new plugin:

1. ✅ Plan your plugin (purpose, namespace, features)
2. ✅ Create directory structure in `plugins/{namespace}/`
3. ✅ Create `plugin.json` with metadata
4. ✅ Register in `marketplace.json`
5. ✅ Add components (commands, agents, skills, hooks, scripts)
6. ✅ Create README documentation
7. ✅ Test thoroughly
8. ✅ Publish to marketplace

**Key principles**:
- **One plugin, one purpose**: Keep plugins focused
- **Namespace everything**: Use consistent prefixes
- **Document thoroughly**: READMEs, descriptions, examples
- **Test extensively**: Real projects, real users
- **Follow patterns**: Learn from existing plugins

Now you're ready to create amazing Claude Code plugins! 🚀
