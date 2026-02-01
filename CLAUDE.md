# Claude Code Plugin Marketplace - Developer Guide

This repository is a marketplace for Claude Code plugins. This document provides guidance for agents working in this codebase on how to build, structure, and contribute plugins.

## Repository Structure

```
cc-plugins/
├── .claude-plugin/
│   └── marketplace.json    # Marketplace configuration (required)
├── plugins/                # Individual plugin directories
├── templates/              # Templates for creating new plugins
├── docs/                   # Additional documentation
├── CLAUDE.md              # This file - guidance for agents
├── CONTRIBUTING.md        # Contribution guidelines
└── README.md              # Public-facing marketplace documentation
```

## Official Plugin Structure

Each plugin MUST follow this structure:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json        # Required manifest file
├── commands/              # Optional: Custom slash commands (.md files)
├── agents/                # Optional: Agent definitions (.md files)
├── skills/                # Optional: Skills (subdirs with SKILL.md)
├── hooks/                 # Optional: Event handlers
├── .mcp.json             # Optional: MCP server configuration
└── README.md             # Plugin documentation
```

**Critical**: Component directories (commands/, agents/, skills/, hooks/) MUST be at plugin root, NOT inside .claude-plugin/

## Plugin Development Guidelines

### Plugin Manifest (plugin.json)

Required location: `.claude-plugin/plugin.json`

**Required field:**
- `name`: Unique identifier in kebab-case format

**Common metadata:**
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Brief plugin purpose",
  "author": "Your Name",
  "homepage": "https://github.com/...",
  "repository": "https://github.com/...",
  "license": "MIT"
}
```

### Component Types

1. **Commands**: Custom slash commands in `commands/` directory
   - Markdown files with frontmatter
   - Integrate into `/command-name` syntax

2. **Agents**: Specialized subagents in `agents/` directory
   - Claude invokes automatically based on context
   - Markdown files with capabilities and usage guidelines

3. **Skills**: Model-invoked capabilities in `skills/` subdirectories
   - Each skill has its own directory with `SKILL.md`
   - Claude autonomously determines when to apply
   - Include "when to use" and "when NOT to use" sections

4. **Hooks**: Event handlers responding to lifecycle events
   - Configure via `hooks.json` or inline in `plugin.json`
   - Support validation, automation, and notifications

5. **MCP Servers**: External tool integrations
   - Configure in `.mcp.json`
   - Start automatically when plugin activates

### Environment Variables

Use `${CLAUDE_PLUGIN_ROOT}` for absolute plugin directory paths in:
- Hook scripts
- MCP configurations
- Any file references

### Best Practices

1. **Naming**: Use kebab-case for plugin names
2. **Versioning**: Follow semantic versioning (major.minor.patch)
3. **Documentation**: Comprehensive README with examples
4. **Testing**: Test locally before submitting to marketplace
5. **Security**: Never expose credentials, validate all inputs
6. **Focused Tools**: Single-purpose, composable functionality
7. **Clear Scope**: Define when skills/agents should be invoked

### Script & Hook Output Patterns

All plugin scripts and hooks should follow consistent output patterns for a clean user experience.

**Scripts** — Print a brief summary line before full JSON data:

```bash
# Summary line (visible in verbose mode, easy to scan)
echo "devloop: state=active_plan priority=2"
# Full structured data (for agent consumption)
cat <<EOF
{
  "state": "active_plan",
  "priority": 2,
  "details": { ... }
}
EOF
```

**Hooks** — Use `suppressOutput` with `systemMessage` for user-facing feedback:

```json
{
  "suppressOutput": true,
  "systemMessage": "Brief status for user",
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Detailed context for agent"
  }
}
```

**Key principles:**
- Users see brief summaries; agents receive full structured data
- Bash tool output is hidden by default (Ctrl+O toggles verbose mode)
- Hook `systemMessage` becomes the user-visible feedback line
- `suppressOutput: true` prevents raw JSON from cluttering verbose view

## Development Workflow

### Creating a New Plugin

1. Copy the plugin template from `templates/plugin-template/`
2. Update `.claude-plugin/plugin.json` with your metadata
3. Implement components in appropriate directories:
   - Add commands to `commands/`
   - Add agents to `agents/`
   - Add skills to `skills/skillname/SKILL.md`
   - Configure hooks if needed
   - Add MCP servers if integrating external tools
4. Write comprehensive README with usage examples
5. Test locally: `/plugin install /path/to/your/plugin`
6. Submit PR to add plugin entry to `.claude-plugin/marketplace.json`

**Pro tip**: When creating skills, use the `skill-creator` skill to help design effective skills:
```bash
/skill skill-creator
```
This built-in skill provides guidance on creating high-quality skills with proper structure and best practices.

### Adding Plugin to Marketplace

Edit `.claude-plugin/marketplace.json` and add entry to `plugins` array:

```json
{
  "name": "your-plugin-name",
  "source": "./plugins/your-plugin-name"
}
```

### Local Testing

```bash
# Install plugin locally for testing
/plugin install /absolute/path/to/plugin-directory

# List installed plugins
/plugin list

# Uninstall for iterative testing
/plugin uninstall plugin-name
```

### Debugging

Run Claude Code with debug flag:
```bash
claude --debug
```

This shows plugin loading, manifest validation, and component registration.

## Official Documentation References

**Do NOT recreate documentation that exists on the Claude Code site. Reference it instead:**

- [Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces.md) - Marketplace structure and distribution
- [Plugins Overview](https://code.claude.com/docs/en/plugins.md) - Plugin development guide
- [Plugin Reference](https://code.claude.com/docs/en/plugins-reference.md) - API reference and specifications
- [Skills Documentation](https://code.claude.com/docs/en/skills/overview) - Creating skills
- [Commands Documentation](https://code.claude.com/docs/en/commands) - Custom slash commands

## Recommended Workflow Pattern (devloop)

**The devloop workflow uses autonomous planning and execution:**

### The Plan → Run Loop

```
┌──────────────────────────────────────────────────┐
│  1. /devloop:plan "topic or feature"            │
│     └─→ Autonomous exploration (silent)          │
│     └─→ Creates actionable plan (1-2 prompts)    │
└─────────────────┬────────────────────────────────┘
                  ↓
┌──────────────────────────────────────────────────┐
│  2. /devloop:run                                 │
│     └─→ Executes tasks autonomously              │
│     └─→ Auto-commits at phase boundaries         │
│     └─→ Loops until complete or blocked          │
└─────────────────┬────────────────────────────────┘
                  │
                  ↓
            Need fresh context?
                  │
                  ├─→ Yes: /devloop:fresh → /clear → /devloop:run
                  └─→ No: Continues automatically
```

### Why This Pattern Works

1. **Plan with minimal prompts** - Autonomous exploration, only 1-2 user prompts
2. **Run autonomously** - Tasks execute without manual intervention
3. **Fresh when needed** - Clear context every 5-10 tasks if responses slow down
4. **Faster completion** - Quick from idea to implementation

### Example Session

```bash
# Create plan with autonomous exploration (1-2 prompts)
/devloop:plan "add user authentication"

# Execute plan autonomously
/devloop:run  # Completes tasks automatically until done

# If context gets heavy after many tasks:
/devloop:fresh
/clear
/devloop:run  # Resumes from checkpoint

# When all tasks complete, /devloop:ship to commit and PR
```

### Command Options

| Command | Behavior |
|---------|----------|
| `/devloop:new "title"` | Create GitHub issue (default), `--local` for offline |
| `/devloop:issues` | List open GitHub issues |
| `/devloop:from-issue N` | Create plan from GitHub issue #N |
| `/devloop:plan "topic"` | Autonomous exploration → plan (1-2 prompts) |
| `/devloop:plan --from-issue N` | Plan from GitHub issue |
| `/devloop:spike "topic"` | Deep exploration (4-5 prompts, detailed report) |
| `/devloop:run` | Autonomous execution (default) |
| `/devloop:run --interactive` | Prompt at each task checkpoint |
| `/devloop:run --next-issue` | Auto-select next issue, plan, and run |

### Hybrid Task Tracking

devloop uses a hybrid approach for task tracking:

| System | Purpose | Persistence |
|--------|---------|-------------|
| `plan.md` | Source of truth | Cross-session |
| Native Tasks | UI visibility (spinner, `/tasks`) | Session only |

During `/devloop:run`:
1. Pending tasks sync to native Tasks (optional)
2. Progress shows in spinner (`activeForm`)
3. Completions update BOTH systems
4. After `/clear`, native tasks recreate from plan.md

### When to Use Fresh Start

- After completing 5-10 tasks
- When responses feel slow
- After long agent invocations
- When context feels heavy

See `plugins/devloop/commands/fresh.md` for details.

### Deprecated Commands

- `/devloop:continue` → Use `/devloop:run --interactive`
- `/devloop:ralph` → Use `/devloop:run` (autonomous is default)

---

## Command Orchestration Pattern

**Critical**: All plugins in this marketplace MUST follow the command orchestration pattern for complex workflows. This ensures consistent user experience across plugins.

### The Pattern

**Commands orchestrate, agents assist.**

- **Commands** (slash commands) should stay in control of multi-phase workflows
- **Agents** should be helpers for specific subtasks, NOT silent controllers
- The user should always see progress in the main conversation

### Why This Matters

Bad pattern (silent agent):
```
User: /plugin:audit
→ Spawns orchestrator-agent
→ Agent runs silently for 5 minutes
→ User thinks it hung
→ Poor UX
```

Good pattern (command orchestrates):
```
User: /plugin:audit
→ Command runs Phase 1: Discovery
→ Shows results, asks user to confirm
→ Command runs Phase 2: Planning
→ Shows plan, asks user to approve
→ Command spawns agents for subtasks
→ Shows progress as agents complete
→ User always sees what's happening
```

### Implementation Guidelines

1. **Phased Workflow**: Break complex operations into phases
2. **User Checkpoints**: Use `AskUserQuestion` between phases
3. **Progress Visibility**: Track with `TodoWrite`, show status updates
4. **Artifact State**: Save phase outputs to `.claude/` for resumability
5. **Agent Helpers**: Spawn agents for subtasks, not as main controllers

### Example Structure

```markdown
## Phase 1: Discovery
**Goal**: Understand the context
**Actions**:
1. Detect relevant information
2. Save to `.claude/plugin-name/discovery.json`
3. Display findings to user
4. AskUserQuestion: Confirm/adjust

## Phase 2: Planning
**Goal**: Propose an action plan
**Actions**:
1. Read discovery.json
2. Generate plan
3. Save to `.claude/plugin-name/plan.json`
4. AskUserQuestion: Approve/customize

## Phase 3: Execution
**Goal**: Execute the plan with visibility
**Actions**:
1. Read plan.json
2. Launch helper agents in parallel (run_in_background)
3. Poll TaskOutput for progress
4. Display status: "✓ task-a complete, ⏳ task-b running"
5. Save results to `.claude/plugin-name/results/`

## Phase 4: Review
**Goal**: Let user review and select results
**Actions**:
1. Read all results
2. Display grouped by category
3. AskUserQuestion: Include/exclude items
4. Save reviewed output

## Phase 5: Report
**Goal**: Generate final output
**Actions**:
1. Read reviewed output
2. Generate report/summary
3. Display in conversation
4. AskUserQuestion: Next steps
```

### Reference Implementation

See these plugins for the pattern in action:
- `plugins/devloop/commands/devloop.md` - Lightweight workflow with checkpoints
- `plugins/security/commands/audit.md` - 5-phase security audit (if available)

## .devloop/ Directory Structure

The devloop plugin uses a standalone `.devloop/` directory for all its artifacts:

```
.devloop/
├── plan.md               # Active plan (NOT git-tracked - ephemeral)
├── worklog.md            # Completed work history (git-tracked)
├── local.md              # Local settings (NOT git-tracked)
├── context.json          # Tech stack cache (git-tracked)
├── issues/               # Local issue tracking (NOT git-tracked - deprecated)
│   ├── index.md          # Only used with /devloop:new --local
│   └── BUG-001.md, etc.  # Local-only issues for offline work
└── spikes/               # Spike reports (NOT git-tracked)
    └── {topic}.md
```

**Issue Tracking**: Use GitHub issues via `/devloop:new` (default). Local issues (`.devloop/issues/`) are only for offline work with `--local` flag.

**Plans**: Ephemeral session state, never committed. Use GitHub issues as permanent tracking.

Other plugins may use `.claude/` for their artifacts.

### Git Tracking Guidelines

| Category | Examples | Git Status |
|----------|----------|------------|
| **Shared State** | Worklog, context | Tracked |
| **Ephemeral State** | Plans (session working memory) | NOT tracked |
| **Local Config** | Settings, preferences | NOT tracked |
| **Sensitive Data** | Security findings | NOT tracked |
| **Working Notes** | Spike reports, local issues | NOT tracked |

**Why NOT track plans?** Plans are working memory for a development session, not permanent artifacts. GitHub issues provide permanent tracking.
**Why track worklog?** Team visibility, historical record of completed work.
**Why NOT track local config?** Personal preferences vary, avoids merge conflicts.
**Why NOT track security?** May contain sensitive vulnerability details.

### .gitignore for Plugins

Add these patterns to exclude ephemeral and local-only files:

```gitignore
# Devloop ephemeral files
.devloop/plan.md
.devloop/local.md
.devloop/spikes/
.devloop/issues/

# Claude Code local settings
.claude/settings.local.json
```

Add these patterns to your project's `.gitignore`.

For detailed file specifications, see `plugins/devloop/skills/plan-management/SKILL.md`.

## Key Principles

### For All Plugins
- **Quality over Quantity**: Well-designed, useful additions
- **Documentation First**: Good docs are as important as good code
- **User-Centric**: Think about developer experience
- **Composability**: Work well with existing tools
- **Security**: Validate inputs, handle errors gracefully

### Plugin Organization
- Follow the official directory structure exactly
- Use environment variables for portability
- Keep components focused and single-purpose
- Include clear invocation criteria for skills/agents

## Marketplace Structure

This repository uses the official marketplace format:

- **Location**: `.claude-plugin/marketplace.json`
- **Required fields**: name, owner, plugins array
- **Plugin sources**: Relative paths, GitHub repos, or Git URLs
- **Distribution**: Via GitHub (recommended) or other Git hosting

Users add this marketplace via:
```bash
/plugin marketplace add YOUR_USERNAME/cc-plugins
```

## Getting Help

When working in this repository:
- Reference official Claude Code docs for implementation details
- Check existing plugins in `plugins/` for patterns
- Use the plugin template in `templates/plugin-template/`
- Test thoroughly before submitting
- Follow the contribution guidelines in CONTRIBUTING.md

---

**Remember**: Build plugins that solve real problems and that you would want to use yourself.

## Versioning Guidelines (A.B.C)

Follow strict semantic versioning to avoid version inflation:

| Component | When to Increment | Examples |
|-----------|-------------------|----------|
| **A** (Major) | Breaking changes only | Removed commands, changed behavior that breaks existing workflows, incompatible plan format changes |
| **B** (Minor) | New features | New commands, new agents, new skills, significant new functionality |
| **C** (Patch) | Everything else | Bug fixes, documentation updates, refactoring, small improvements, config changes |

**Rules:**
1. **Default to patch (C)** - Most changes are patches. When in doubt, increment C.
2. **Documentation = patch** - README updates, changelog entries, comment improvements → increment C only
3. **Bug fixes = patch** - Even significant bug fixes are patches unless they change behavior
4. **New command/agent/skill = minor** - Adding new user-facing functionality → increment B, reset C to 0
5. **Breaking changes are rare** - Think twice before incrementing A. Most "breaking" changes can be made backwards-compatible.

**Examples:**
```
3.9.1 → 3.9.2   Documentation update, bug fix, refactoring
3.9.2 → 3.10.0  New /devloop:issues command added
3.10.0 → 3.10.1 Fixed bug in issues command
3.10.1 → 4.0.0  Changed plan.md format (breaks old plans)
```

**Anti-patterns to avoid:**
- Incrementing minor version for docs-only changes
- Incrementing major version for new features
- Skipping versions (3.9 → 3.11)