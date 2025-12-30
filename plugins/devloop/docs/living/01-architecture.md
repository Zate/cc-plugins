# Devloop Architecture

This document describes the internal architecture of the devloop plugin, how its components interact, and the design decisions behind them.

---

## Plugin Structure

```
plugins/devloop/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest (name, version, metadata)
├── agents/                   # 9 specialized agents
│   ├── engineer.md           # Super-agent with 4 modes
│   ├── qa-engineer.md        # Super-agent with 4 modes  
│   ├── task-planner.md       # Super-agent with 4 modes
│   ├── code-reviewer.md      # Focused reviewer
│   ├── security-scanner.md   # OWASP checker
│   ├── workflow-detector.md  # Task classifier
│   ├── complexity-estimator.md
│   ├── doc-generator.md
│   └── summary-generator.md
├── commands/                 # 16 slash commands
│   ├── devloop.md            # Full 12-phase workflow
│   ├── continue.md           # Resume from plan
│   ├── fresh.md              # Context management
│   ├── spike.md              # Technical exploration
│   ├── quick.md              # Fast implementation
│   ├── review.md             # Code review
│   ├── ship.md               # Git integration
│   └── ...
├── skills/                   # 29 domain skills
│   ├── INDEX.md              # Skill catalog
│   ├── workflow-loop/        # Multi-task patterns
│   ├── plan-management/      # Plan file conventions
│   ├── go-patterns/          # Language-specific
│   ├── react-patterns/
│   └── ...
├── hooks/                    # Event handlers
│   ├── hooks.json            # Hook configuration
│   ├── session-start.sh      # Session initialization
│   ├── session-end.sh
│   ├── pre-commit.sh
│   └── post-commit.sh
├── scripts/                  # Helper scripts
│   ├── detect-plan.sh
│   ├── validate-plan.sh
│   ├── calculate-progress.sh
│   └── ...
├── templates/                # Reusable templates
│   ├── bootstrap/
│   └── onboard/
├── schemas/                  # JSON schemas
│   ├── plan-state.schema.json
│   └── workflow.schema.json
└── statusline/               # Optional status bar
    └── devloop-statusline.sh
```

---

## Component Types

### Commands

Commands are the user-facing interface. They:

- Are invoked via `/devloop:command-name`
- Orchestrate multi-phase workflows
- Stay visible in the conversation
- Call agents for subtasks

**Key Design Decision**: Commands orchestrate, agents assist. This keeps the user informed and in control.

```yaml
# Example command structure
---
description: Resume work from existing plan
aliases: [continue, cont]
---

## Phase 1: Read Plan
Read .devloop/plan.md and find next pending task

## Phase 2: Execute Task
Launch appropriate agent based on task type

## Phase 3: Checkpoint
Ask user: continue, commit, fresh, or stop
```

### Agents

Agents are specialized subprocesses. They:

- Are invoked via the `Task` tool with `subagent_type: devloop:agent-name`
- Execute autonomously without interrupting
- Return results to the calling command
- Have specific capabilities and models

**Super-Agents (v2.0)**: We consolidated from 18 to 9 agents by creating multi-mode super-agents:

| Super-Agent | Modes | Purpose |
|-------------|-------|---------|
| `engineer` | Explorer, Architect, Refactorer, Git | All code-related work |
| `qa-engineer` | Generator, Runner, Bug Tracker, Validator | All testing work |
| `task-planner` | Planner, Requirements, Issue Manager, DoD | All planning work |

Mode is detected from task keywords:
- "explore", "understand" → Explorer mode
- "design", "architecture" → Architect mode
- "implement", "add" → Default mode

### Skills

Skills are domain knowledge that Claude applies when relevant. They:

- Are stored in `skills/{skill-name}/SKILL.md`
- Are invoked via `Skill: skill-name`
- Load on-demand (not all at startup)
- Have "when to use" and "when NOT to use" guidance

**Dynamic Loading (v2.0)**: Skills now load on-demand from `skills/INDEX.md`, reducing initial context by ~50%.

```markdown
---
description: Go-specific patterns and best practices
whenToUse: |
  - Writing new Go code
  - Reviewing Go code for idioms
whenNotToUse: |
  - Non-Go projects
  - Simple fixes that don't need Go expertise
---

# Go Patterns

## Error Handling
...
```

### Hooks

Hooks are event handlers that respond to lifecycle events:

| Event | When | Example Use |
|-------|------|-------------|
| `SessionStart` | New conversation | Detect project, show plan status |
| `SessionEnd` | Conversation ends | Save session metrics |
| `PreToolUse` | Before tool execution | Validate operations |
| `PostToolUse` | After tool execution | Log operations |
| `SubagentStop` | Agent completes | Update worklog |

**Configuration** (hooks.json):
```json
{
  "hooks": [
    {
      "name": "session-start",
      "event": "SessionStart",
      "script": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
    }
  ]
}
```

---

## State Architecture

### File Locations

```
.devloop/                     # Devloop artifacts (separate from .claude/)
├── plan.md                   # Active plan (git-tracked)
├── plan-state.json           # Machine-readable plan state
├── worklog.md                # Completed work history (git-tracked)
├── local.md                  # Local settings (NOT git-tracked)
├── context.json              # Tech stack cache (git-tracked)
├── next-action.json          # Fresh start state (temporary)
├── sessions.json             # Session history
├── issues/                   # Issue tracking (git-tracked)
│   ├── index.md
│   ├── BUG-001.md
│   ├── FEAT-001.md
│   └── ...
├── spikes/                   # Spike reports (NOT git-tracked)
└── archive/                  # Archived plans and worklogs
```

### Git Tracking Strategy

| Category | Files | Git Status | Rationale |
|----------|-------|------------|-----------|
| Shared State | plan.md, worklog.md, issues/ | Tracked | Team visibility |
| Configuration | context.json | Tracked | Tech stack sharing |
| Local Settings | local.md | NOT tracked | Personal preferences |
| Security Data | audit reports | NOT tracked | Sensitive details |
| Temporary | next-action.json | NOT tracked | Session-specific |

### Plan State Machine

```
┌────────────────────────────────────────────────────────────────┐
│                         PLAN STATES                             │
├────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌──────────┐    ┌──────────────┐    ┌──────────┐              │
│   │  Draft   │───▶│  In Progress │───▶│  Review  │              │
│   └──────────┘    └──────┬───────┘    └────┬─────┘              │
│                          │                  │                    │
│                          │                  ▼                    │
│                          │            ┌──────────┐               │
│                          └───────────▶│ Complete │               │
│                                       └──────────┘               │
│                                                                  │
│   Task States:                                                   │
│   [ ] Pending  →  [~] Partial  →  [x] Complete                  │
│                                                                  │
└────────────────────────────────────────────────────────────────┘
```

---

## Information Flow

### Workflow Execution Flow

```
User Command (/devloop:continue)
       │
       ▼
┌─────────────────┐
│  Read Plan      │ ← .devloop/plan.md
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Find Next Task │ ← Grep for "- [ ]"
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Route to Agent │ ← Task type → agent selection
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Agent Executes │ ← Autonomous work
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Checkpoint     │ ← AskUserQuestion (MANDATORY)
└────────┬────────┘
         │
    ┌────┴────┬──────────┬──────────┐
    ▼         ▼          ▼          ▼
Continue   Commit     Fresh      Stop
    │         │          │          │
    │         │          │          ▼
    │         │          │     Generate Summary
    │         │          ▼
    │         │     Save State
    │         │     Suggest /clear
    │         ▼
    │     Create Commit
    │     Update Worklog
    │         │
    └────┬────┘
         │
         ▼
    Loop back to Read Plan
```

### Agent Invocation Pattern

```yaml
# Command invokes agent via Task tool
Task:
  subagent_type: devloop:engineer
  description: "Implement user authentication"
  prompt: |
    Implement JWT-based authentication.
    
    Requirements:
    - Token generation with RS256
    - Validation middleware
    - Refresh token support
    
    Files to modify:
    - services/auth.go
    - middleware/jwt.go

# Agent returns when complete
# Command handles result at checkpoint
```

### Skill Loading Pattern

```
Command needs architecture guidance
       │
       ▼
┌─────────────────────────────┐
│ Reference: Skill: arch-pat  │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Claude loads skill content  │ ← skills/architecture-patterns/SKILL.md
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│ Apply knowledge to task     │
└─────────────────────────────┘
```

---

## Design Decisions

### Why Super-Agents?

**Problem**: 18 individual agents meant:
- High context overhead (each agent prompt loaded)
- Coordination complexity
- Redundant capabilities

**Solution**: Consolidate into 9 super-agents with modes:
- Reduced token overhead
- Shared context within agent
- Mode detection from task keywords

### Why Commands Orchestrate?

**Problem**: Silent agents are poor UX:
- User doesn't see progress
- No opportunity to course-correct
- Feels like the system is hanging

**Solution**: Commands stay in control:
- Show phase progress
- Ask checkpoints between phases
- Spawn agents only for subtasks

### Why Fresh Starts?

**Problem**: Long conversations degrade:
- Responses slow down
- Reasoning becomes confused
- Context window fills up

**Solution**: Explicit context management:
- Save state to `.devloop/next-action.json`
- Suggest fresh starts every 5-10 tasks
- `/devloop:continue` auto-resumes

### Why Plan Files?

**Problem**: Work doesn't persist across sessions:
- No handoff capability
- No way to resume
- No team visibility

**Solution**: Persistent plans in `.devloop/plan.md`:
- Survive session boundaries
- Git-tracked for team sharing
- Machine-readable progress markers

---

## Extension Points

### Adding a New Command

1. Create `commands/my-command.md`
2. Add frontmatter with description and aliases
3. Define phases with clear actions
4. Use existing agents via Task tool
5. Include checkpoints with AskUserQuestion

### Adding a New Skill

1. Create `skills/my-skill/SKILL.md`
2. Add to `skills/INDEX.md` catalog
3. Define whenToUse and whenNotToUse
4. Structure with clear sections
5. Test with `Skill: my-skill`

### Adding a New Agent

1. Create `agents/my-agent.md`
2. Define system role and capabilities
3. Specify model (haiku/sonnet/opus)
4. Add to agent routing table in commands
5. Document in `docs/agents.md`

---

## Next Steps

- [Principles](02-principles.md) - Design philosophies behind these decisions
- [Component Guide](05-component-guide.md) - Deep dive into each component type
- [State Management](06-state-management.md) - Detailed state file specifications
