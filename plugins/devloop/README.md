# devloop

**A complete, token-conscious feature development workflow for professional software engineering.**

[![Version](https://img.shields.io/badge/version-1.10.0-blue)](./CHANGELOG.md) [![Agents](https://img.shields.io/badge/agents-18-green)](#agents) [![Skills](https://img.shields.io/badge/skills-26-purple)](#skills) [![Commands](https://img.shields.io/badge/commands-14-orange)](#commands)

---

## What is devloop?

devloop is a Claude Code plugin that brings structure and efficiency to software development. It guides you through a complete workflow—from vague requirements to shipped code—while optimizing token usage through strategic model selection.

**The core insight**: Different tasks need different capabilities. Code review needs opus for catching subtle bugs. Test generation can use haiku for formulaic patterns. devloop automates this selection so you get the best results without thinking about it.

---

## Quick Start

```bash
# Install
/plugin install devloop

# Start a feature
/devloop Add user authentication with OAuth

# That's it. devloop guides you through the rest.
```

### Using devloop with Other AI Agents

**Don't have Claude Code?** You can still use devloop methodology with Cursor, Aider, Gemini, or any AI coding agent.

See **[DEVLOOP_FOR_GENERIC_AGENTS.md](./docs/DEVLOOP_FOR_GENERIC_AGENTS.md)** for:
- Complete workflow documentation without plugin requirements
- Plan file format specification
- Integration with `.cursorrules`, `.aider.conf.yml`, and other agent configs
- Best practices for non-Claude agents

---

## The Workflow

devloop provides a 12-phase workflow that mirrors how senior engineers approach complex features:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  0. Triage  │────▶│ 1. Discovery│────▶│ 2. Estimate │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
┌─────────────┐     ┌─────────────┐     ┌──────▼──────┐
│ 5. Architect│◀────│4. Clarify   │◀────│ 3. Explore  │
└──────┬──────┘     └─────────────┘     └─────────────┘
       │
┌──────▼──────┐     ┌─────────────┐     ┌─────────────┐
│  6. Plan    │────▶│ 7. Implement│────▶│  8. Test    │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
┌─────────────┐     ┌─────────────┐     ┌──────▼──────┐
│ 11. Git     │◀────│10. Validate │◀────│  9. Review  │
└──────┬──────┘     └─────────────┘     └─────────────┘
       │
       ▼
┌─────────────┐
│ 12. Summary │
└─────────────┘
```

**You don't have to use all phases.** Use `/devloop:quick` for small tasks, `/devloop:review` for code review, `/devloop:spike` for exploration.

---

## Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/devloop` | Full feature workflow | New features, complex changes |
| `/devloop:analyze` | Codebase refactoring analysis | Technical debt, messy code, large files |
| `/devloop:bootstrap` | New project setup | Greenfield projects with docs |
| `/devloop:continue` | Resume existing plan | Continuing previous work |
| `/devloop:quick` | Fast implementation | Small, well-defined tasks |
| `/devloop:spike` | Technical exploration | Unknown feasibility |
| `/devloop:review` | Code review | Before commits, PR review |
| `/devloop:ship` | Git integration | Ready to commit/PR |
| `/devloop:new` | Smart issue creation | Track bugs, features, tasks |
| `/devloop:issues` | Manage all issues | View, filter, work on issues |
| `/devloop:bug` | Report a bug | Quick bug tracking |
| `/devloop:bugs` | View bugs | Bug-only view |
| `/devloop:worklog` | Manage work history | View, sync, reconstruct worklog |
| `/devloop:statusline` | Configure status bar | Setup status display |

### Examples

```bash
# Bootstrap a new project from documentation
/devloop:bootstrap ./docs/PRD.md ./specs/api.yaml

# Full feature development
/devloop Add rate limiting to API endpoints

# Analyze codebase for refactoring
/devloop:analyze
/devloop:analyze Focus on the API layer

# Quick fix
/devloop:quick Fix the null pointer in UserService

# Explore feasibility
/devloop:spike Can we migrate from REST to GraphQL?

# Review changes
/devloop:review

# Ship it
/devloop:ship

# Resume where you left off
/devloop:continue

# Track issues for later
/devloop:new Add dark mode support eventually
/devloop:new The button is broken on mobile

# View and manage issues
/devloop:issues
/devloop:issues bugs
/devloop:issues backlog
```

---

## Agents

devloop includes 18 specialized agents, each optimized for a specific task. Agents are color-coded by category for easy visual identification when invoked.

### Color Scheme

| Color | Category | Agents |
|-------|----------|--------|
| 🟡 yellow | Exploration | code-explorer, workflow-detector |
| 🟣 indigo | Architecture | code-architect, task-planner |
| 🔴 red | Critical Review | code-reviewer, security-scanner |
| 🟠 orange | Analysis | refactor-analyzer |
| 🔵 cyan | Testing | test-generator, test-runner |
| 🟢 green | Validation | qa-agent, dod-validator |
| 🔵 blue | Requirements | requirements-gatherer, complexity-estimator |
| 🟠 orange | Integration | git-manager, bug-catcher, issue-manager |
| 🔷 teal | Documentation | doc-generator, summary-generator |

### Core Development

| Agent | Color | Model | Purpose |
|-------|-------|-------|---------|
| `code-explorer` | yellow | sonnet | Deep codebase analysis, traces execution paths |
| `code-architect` | indigo | sonnet | Architecture design and implementation blueprints |
| `code-reviewer` | red | sonnet | Quality review with confidence-based filtering |
| `task-planner` | indigo | sonnet | Break architecture into ordered, actionable tasks |
| `refactor-analyzer` | orange | sonnet | Identify refactoring opportunities and technical debt |

### Testing & Quality

| Agent | Color | Model | Purpose |
|-------|-------|-------|---------|
| `test-generator` | cyan | sonnet | Generate tests following project patterns |
| `test-runner` | cyan | sonnet | Execute tests and analyze failures |
| `qa-agent` | green | sonnet | Deployment readiness validation |
| `dod-validator` | green | haiku | Definition of Done checklist verification |
| `security-scanner` | red | haiku | OWASP Top 10, secrets, injection vulnerabilities |

### Workflow

| Agent | Color | Model | Purpose |
|-------|-------|-------|---------|
| `requirements-gatherer` | blue | sonnet | Transform vague requests into specifications |
| `complexity-estimator` | blue | haiku | T-shirt sizing and risk assessment |
| `workflow-detector` | yellow | haiku | Classify task type (feature/bug/refactor) |
| `summary-generator` | teal | haiku | Session summaries and handoff docs |
| `doc-generator` | teal | sonnet | Generate and update documentation |

### Integration

| Agent | Color | Model | Purpose |
|-------|-------|-------|---------|
| `git-manager` | orange | haiku | Commits, branches, PRs with conventional messages |
| `bug-catcher` | orange | haiku | Create bug reports during development (legacy) |
| `issue-manager` | orange | haiku | Create any issue type during development |

---

## Skills

devloop provides 26 skills—domain knowledge that Claude automatically applies when relevant:

### Architecture & Design

| Skill | Trigger |
|-------|---------|
| `architecture-patterns` | Architecture decisions |
| `api-design` | API design work |
| `database-patterns` | Schema design, queries |

### Language-Specific Patterns

| Skill | Version | Focus |
|-------|---------|-------|
| `go-patterns` | Go 1.21+ | Interfaces, errors, goroutines, generics |
| `react-patterns` | React 18+ | Hooks, components, state, a11y |
| `java-patterns` | Java 17+ | Spring, records, streams, DI |
| `python-patterns` | Python 3.10+ | Type hints, async, pytest, match |

### Quality & Testing

| Skill | Purpose |
|-------|---------|
| `testing-strategies` | Test design and coverage |
| `security-checklist` | OWASP, auth, data protection |
| `deployment-readiness` | Pre-deploy validation |
| `refactoring-analysis` | Codebase analysis for technical debt |

### Workflow

| Skill | Purpose |
|-------|---------|
| `workflow-selection` | Choose the right workflow |
| `model-selection-guide` | When to use opus/sonnet/haiku |
| `complexity-estimation` | T-shirt sizing framework |
| `requirements-patterns` | Requirements gathering |
| `git-workflows` | Branching, commits, releases |
| `plan-management` | Plan file conventions |
| `worklog-management` | Worklog format and updates |
| `file-locations` | Where devloop files belong |
| `bug-tracking` | Bug report management (legacy) |
| `issue-tracking` | Unified issue management |
| `project-bootstrap` | New project setup from docs |

### Task Completion

| Skill | Purpose |
|-------|---------|
| `task-checkpoint` | Task completion checklist and verification |
| `atomic-commits` | Commit strategy and logical grouping |
| `version-management` | Semantic versioning and CHANGELOG management |

---

## Model Selection Strategy

devloop uses a **20/60/20 strategy** for token efficiency:

| Model | Usage | When |
|-------|-------|------|
| **opus** | 20% | High-stakes decisions, complex architecture |
| **sonnet** | 60% | Implementation, exploration, code review |
| **haiku** | 20% | Classification, checklists, simple tasks |

This is automatic. devloop selects the right model for each phase and agent.

---

## Plan Management

devloop saves plans to `.claude/devloop-plan.md` so you can:

- **Resume later**: `/devloop:continue` picks up where you left off
- **Track progress**: Plans show completed/pending tasks
- **Hand off**: Share plans with teammates

```markdown
# Devloop Plan: User Authentication

**Status**: In Progress
**Current Phase**: Implementation

## Tasks
- [x] Task 1: Set up OAuth provider
- [~] Task 2: Implement login flow
- [ ] Task 3: Add session management
- [ ] Task 4: Write tests
```

---

## Consistency & Enforcement

devloop 1.10.0 introduces a consistency system that ensures plans stay in sync with actual work.

### Workflow Diagram

```
Task Complete → Plan Update (REQUIRED) → Commit Decision
                                              ↓
                        PreCommit Hook (verifies plan sync)
                                              ↓
                              Git Commit (proceeds)
                                              ↓
                        PostCommit Hook (updates worklog)
                                              ↓
                              Worklog Updated
```

### Key Components

| Component | Purpose |
|-----------|---------|
| **Plan** (`.claude/devloop-plan.md`) | What's in progress |
| **Worklog** (`.claude/devloop-worklog.md`) | What's done (with commits) |
| **Pre-commit hook** | Blocks if plan not updated |
| **Post-commit hook** | Auto-updates worklog |

### Enforcement Modes

Configure in `.claude/devloop.local.md`:

```yaml
enforcement: advisory  # advisory (default) | strict
```

| Mode | Behavior |
|------|----------|
| **advisory** | Warns when plan is out of sync, allows override |
| **strict** | Blocks commits until plan is updated |

### Recovery Flows

`/devloop:continue` detects and offers recovery for:

- **Plan not updated**: Tasks marked complete without Progress Log entries
- **Uncommitted changes**: Code changes without corresponding commits
- **Worklog drift**: Plan entries not synced to worklog
- **Commits without tasks**: Work done outside the plan

### File Locations

```
.claude/
├── devloop-plan.md         # Active plan (git-tracked)
├── devloop-worklog.md      # Completed work (git-tracked)
├── devloop.local.md        # Local settings (NOT git-tracked)
├── project-context.json    # Tech cache (git-tracked)
├── issues/                 # Issue tracking (git-tracked)
└── security/               # Audit reports (NOT git-tracked)
```

See `Skill: file-locations` for complete documentation.

---

## Parallel Task Execution

devloop can run independent tasks in parallel for faster feature development:

### Task Markers

Plans can include parallelism markers:

```markdown
### Phase 2: Core Implementation  [parallel:partial]
**Parallel Groups**:
- Group A: Tasks 2.1, 2.2 (independent implementations)

- [ ] Task 2.1: Create user model  [parallel:A]
- [ ] Task 2.2: Create product model  [parallel:A]
- [ ] Task 2.3: Create relationships  [depends:2.1,2.2]
```

| Marker | Meaning |
|--------|---------|
| `[parallel:X]` | Can run with other tasks in group X |
| `[depends:N.M]` | Must wait for task N.M to complete |
| `[background]` | Low priority, can run in background |
| `[sequential]` | Must run alone |

### How It Works

1. **Detection**: `/devloop:continue` detects tasks with matching `[parallel:X]` markers
2. **User Choice**: Asks if you want to run them together
3. **Parallel Execution**: Spawns agents for each task with `run_in_background: true`
4. **Progress Tracking**: Shows status as tasks complete
5. **Dependency Handling**: Only proceeds to dependent tasks when group completes

### Token Cost Awareness

Not all parallelism is free. Guidelines:
- **3x haiku agents**: Low cost, high benefit
- **3x sonnet agents**: Medium cost, evaluate need
- **3x opus agents**: High cost, usually avoid
- **Max 3-4 parallel agents**: Beyond this, coordination costs exceed benefits

---

## Issue Tracking

devloop includes a unified issue tracking system for bugs, features, tasks, chores, and spikes. Issues are stored in `.claude/issues/` with type-prefixed IDs for quick identification.

### Issue Types

| Type | Prefix | When to Use |
|------|--------|-------------|
| Bug | BUG- | Something is broken |
| Feature | FEAT- | New functionality |
| Task | TASK- | Technical work, refactoring |
| Chore | CHORE- | Maintenance, dependencies |
| Spike | SPIKE- | Research, investigation |

### Commands

```bash
# Smart issue creation (auto-detects type)
/devloop:new Add dark mode support
/devloop:new Button doesn't work on mobile

# View all issues
/devloop:issues

# Filter by type
/devloop:issues bugs
/devloop:issues features
/devloop:issues backlog

# Filter by priority
/devloop:issues high

# Work on specific issue
/devloop:issues FEAT-001

# Legacy commands (still work)
/devloop:bug    # Quick bug creation
/devloop:bugs   # Bug-only view
```

### Smart Type Detection

`/devloop:new` analyzes your input to auto-detect issue type:

| Input Keywords | Detected Type |
|----------------|---------------|
| "broken", "error", "crash", "fix" | Bug |
| "add", "create", "implement", "new" | Feature |
| "refactor", "clean up", "optimize" | Task |
| "dependency", "upgrade", "config" | Chore |
| "investigate", "explore", "research" | Spike |

### Directory Structure

```
.claude/issues/
├── index.md        # Master index (all issues)
├── bugs.md         # Bug-only view
├── features.md     # Feature-only view
├── backlog.md      # Open features + tasks
├── BUG-001.md      # Individual issue files
├── FEAT-001.md
└── TASK-001.md
```

### Migration from .claude/bugs/

If you have an existing `.claude/bugs/` directory, devloop will:
1. Detect it automatically
2. Offer to migrate to the unified system
3. Preserve all existing bug data with BUG- prefixes
4. Both systems can coexist during transition

See [Migration Guide](#migration-from-bugs-to-issues) below for details.

---

## Hooks

devloop includes automated hooks:

### SessionStart

Automatically detects and sets:
- `$FEATURE_DEV_PROJECT_LANGUAGE` - Primary language
- `$FEATURE_DEV_FRAMEWORK` - Framework (React, Spring, etc.)
- `$FEATURE_DEV_TEST_FRAMEWORK` - Test framework
- Shows plan progress if active plan exists
- Shows bug count if bugs tracked

### Statusline

Optional status bar showing:
- Current model
- Git branch
- Plan progress
- Bug count
- Context usage

Configure with `/devloop:statusline`.

---

## Migration from Bugs to Issues

If you have an existing `.claude/bugs/` directory and want to migrate to the unified issue system:

### Automatic Migration

1. Run `/devloop:issues` - it will detect `.claude/bugs/` and offer migration
2. Choose "Yes, migrate" when prompted
3. All bugs are copied to `.claude/issues/` with `type: bug` added
4. Original `.claude/bugs/` is preserved (delete manually when ready)

### Manual Migration

```bash
# 1. Create issues directory
mkdir -p .claude/issues

# 2. For each bug file, copy and add type field
# The migration adds: type: bug to frontmatter

# 3. Regenerate view files
# Run /devloop:issues to regenerate index.md, bugs.md, etc.

# 4. Verify migration worked
# Check .claude/issues/ has all your bugs

# 5. (Optional) Remove old directory
rm -rf .claude/bugs/
```

### Coexistence Mode

During transition, both systems work:
- `/devloop:bug` creates in `.claude/issues/` (preferred) or `.claude/bugs/` (fallback)
- `/devloop:bugs` checks both locations
- New issues always go to `.claude/issues/`

---

## Best Practices

### Use the Right Command

| Situation | Command |
|-----------|---------|
| New feature, complex | `/devloop` |
| Messy code, tech debt | `/devloop:analyze` |
| Small fix, clear scope | `/devloop:quick` |
| Unknown if possible | `/devloop:spike` |
| Ready to commit | `/devloop:ship` |
| Reviewing code | `/devloop:review` |
| Continuing work | `/devloop:continue` |
| Track for later | `/devloop:new` |
| View/manage issues | `/devloop:issues` |

### Answer Clarifying Questions

Phase 4 asks questions to prevent confusion later. Take time to answer thoughtfully—it saves rework.

### Trust the Workflow

Each phase exists for a reason. Skipping exploration leads to wrong architecture. Skipping review leads to bugs. The workflow is designed from how senior engineers actually work.

### Use Plan Files

Save your plan. Resume later. Hand off to teammates. The plan file is your project's memory.

---

## Directory Structure

```
plugins/devloop/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── agents/                   # 16 specialized agents
│   ├── code-explorer.md
│   ├── code-architect.md
│   ├── code-reviewer.md
│   └── ...
├── commands/                 # 9 slash commands
│   ├── devloop.md
│   ├── quick.md
│   ├── continue.md
│   └── ...
├── hooks/                    # Event handlers
│   ├── hooks.json
│   └── session-start.sh
├── skills/                   # 22 domain skills
│   ├── go-patterns/
│   ├── react-patterns/
│   ├── architecture-patterns/
│   └── ...
├── statusline/               # Status bar script
│   └── devloop-statusline.sh
└── README.md
```

---

## Changelog

### 1.10.0 (Current)

- **Consistency & Enforcement System**: Plan and worklog synchronization with configurable enforcement
- Added worklog management (`devloop-worklog.md`) for completed work history with commits
- Added `file-locations` skill documenting all `.claude/` file locations and git tracking
- Added `worklog-management` skill for worklog format and update procedures
- Added `/devloop:worklog` command for viewing, syncing, and reconstructing worklog
- Added pre-commit hook to verify plan sync before commits
- Added post-commit hook to auto-update worklog after commits
- Added recovery flows in `/devloop:continue` for out-of-sync scenarios
- Added `.gitignore` template for devloop (`templates/gitignore-devloop`)
- Updated `devloop.local.md` template with enforcement settings
- Updated `task-checkpoint` skill with worklog integration
- Updated `summary-generator` to use worklog as source of truth
- Updated `plan-management` with enforcement hooks documentation
- Updated CLAUDE.md with `.claude/` directory structure guidance

### 1.9.0

- **Unified Issue Tracking**: New system supporting bugs, features, tasks, chores, and spikes
- Added `/devloop:new` command with smart type detection from keywords
- Added `/devloop:issues` command for viewing and managing all issue types
- Added `issue-manager` agent for creating any issue type
- Added `issue-tracking` skill with full schema and view generation rules
- Type-prefixed IDs: BUG-001, FEAT-001, TASK-001, CHORE-001, SPIKE-001
- Auto-generated view files: index.md, bugs.md, features.md, backlog.md
- Updated `workflow-detector` to route issue tracking requests
- Migration support from `.claude/bugs/` to unified `.claude/issues/`
- Backwards compatibility: `/devloop:bug` and `/devloop:bugs` still work

### 1.8.0

- **Smart Parallel Task Execution**: Run independent tasks in parallel for faster development
- **Unified Plan Integration**: All commands and agents now consistently work from `.claude/devloop-plan.md`
- Added parallelism markers: `[parallel:X]`, `[depends:N.M]`, `[background]`, `[sequential]`
- Updated `plan-management` skill with parallelism guidelines and token cost awareness
- Updated `/devloop:continue` to detect and spawn parallel task groups
- Updated `/devloop:spike` with mandatory plan integration and update recommendations
- Updated `/devloop:quick` to check for existing plans before starting
- Updated `/devloop` Phase 7 with parallel task detection
- Updated `task-planner` to generate parallelism annotations
- Updated `code-explorer`, `code-architect`, `code-reviewer` with plan update recommendations
- Updated `test-generator` with parallel execution awareness
- Updated `task-checkpoint` with parallel sibling detection
- Updated `atomic-commits` with parallel task grouping guidance

### 1.7.0

- **Task Completion Enforcement**: New checkpoint system ensures tasks are properly completed
- Added `task-checkpoint` skill for task completion verification
- Added `atomic-commits` skill for commit strategy guidance
- Added `version-management` skill for semantic versioning and CHANGELOG
- Updated `/devloop:continue` with task and phase completion checkpoints
- Updated `/devloop:ship` with version bumping and CHANGELOG generation
- Updated `/devloop:bootstrap` to include devloop workflow in generated CLAUDE.md
- Enhanced `git-manager` agent with task-linked commits
- Enhanced `summary-generator` agent with commit tracking
- Enhanced `dod-validator` agent with commit verification
- Updated `plan-management` skill with enforcement configuration
- Support for per-project enforcement modes (advisory/strict)
- Auto-detection of version bumps from conventional commits

### 1.6.0

- Added `/devloop:analyze` command for codebase refactoring analysis
- Added `refactor-analyzer` agent for identifying technical debt
- Added `refactoring-analysis` skill with analysis methodology
- Analysis findings can be converted directly to devloop plan tasks
- Merged functionality from retired `code-refactor-analyzer` plugin

### 1.5.0

- Added `/devloop:bootstrap` command for greenfield projects
- Added `project-bootstrap` skill for CLAUDE.md best practices
- Now supports starting projects from PRD/specs before any code exists
- Comprehensive documentation in `docs/` directory

### 1.4.0

- Added statusline integration (`/devloop:statusline`)
- Fixed JSON injection vulnerability in session-start hook
- Optimized language detection performance
- Updated test-generator, test-runner, doc-generator to sonnet
- Added "When NOT to Use" sections to all 17 skills
- Added version notes to language-specific skills
- Clarified qa-agent vs dod-validator responsibilities

### 1.3.0

- Added bug tracking system (`/devloop:bug`, `/devloop:bugs`)
- Added bug-catcher agent
- Added bug-tracking skill

### 1.2.0

- Added memory integration agents
- Added summary-generator agent
- Enhanced plan management

### 1.0.0

- Initial release
- 12-phase workflow
- Core agents and skills
- SessionStart hook

---

## Author

**Zate**
- GitHub: [@Zate](https://github.com/Zate)

Originally based on feature-dev by Sid Bidasaria (sbidasaria@anthropic.com)

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

## Support

- **Issues**: [GitHub Issues](https://github.com/Zate/cc-plugins/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Zate/cc-plugins/discussions)

---

<p align="center">
  <strong>Ship features, not excuses.</strong>
</p>
