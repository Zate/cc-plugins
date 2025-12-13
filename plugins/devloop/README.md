# devloop

**A complete, token-conscious feature development workflow for professional software engineering.**

[![Version](https://img.shields.io/badge/version-1.6.0-blue)](./CHANGELOG.md) [![Agents](https://img.shields.io/badge/agents-17-green)](#agents) [![Skills](https://img.shields.io/badge/skills-19-purple)](#skills) [![Commands](https://img.shields.io/badge/commands-11-orange)](#commands)

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
| `/devloop:bug` | Report a bug | Track issues for later |
| `/devloop:bugs` | Manage bugs | View, fix, or close bugs |
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
```

---

## Agents

devloop includes 17 specialized agents, each optimized for a specific task. Agents are color-coded by category for easy visual identification when invoked.

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
| 🟠 orange | Integration | git-manager, bug-catcher |
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
| `bug-catcher` | orange | haiku | Create bug reports during development |

---

## Skills

devloop provides 19 skills—domain knowledge that Claude automatically applies when relevant:

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
| `bug-tracking` | Bug report management |
| `project-bootstrap` | New project setup from docs |

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

## Bug Tracking

Non-critical issues found during development go to `.claude/bugs/`:

```bash
# Report a bug
/devloop:bug

# View all bugs
/devloop:bugs

# View only high priority
/devloop:bugs high

# Fix a specific bug
/devloop:bugs fix BUG-001
```

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
├── skills/                   # 18 domain skills
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

### 1.6.0 (Current)

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
