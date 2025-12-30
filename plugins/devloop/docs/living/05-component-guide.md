# Component Guide

A deep dive into each type of component in devloop: commands, agents, skills, and hooks.

---

## Commands Reference

### Core Workflow Commands

#### `/devloop`

**File**: `commands/devloop.md`

**Purpose**: Full 12-phase feature development workflow

**Phases**:
1. Triage - Classify task type
2. Discovery - Understand requirements
3. Complexity - Estimate effort
4. Exploration - Study existing code
5. Clarification - Resolve ambiguities
6. Architecture - Design approach
7. Planning - Break into tasks
8. Implementation - Build features
9. Testing - Write and run tests
10. Review - Code quality check
11. Git Integration - Commit/PR
12. Summary - Document completion

**Best For**: Complex features requiring structured approach

---

#### `/devloop:continue`

**File**: `commands/continue.md`

**Purpose**: Resume work from existing plan

**Flow**:
1. Check for `next-action.json` (fresh start state)
2. Read `.devloop/plan.md`
3. Find next pending task `[ ]`
4. Route to appropriate agent
5. Execute task
6. Mandatory checkpoint
7. Loop back to step 3

**Key Feature**: Automatic state detection and resumption

---

#### `/devloop:fresh`

**File**: `commands/fresh.md`

**Purpose**: Save state for context refresh

**What It Saves** (to `next-action.json`):
```json
{
  "lastCompletedTask": "2.1",
  "nextTask": "2.2",
  "planName": "User Authentication",
  "timestamp": "2024-12-30T10:30:00Z",
  "sessionMetrics": {
    "tasksCompleted": 4,
    "contextUsage": 67
  }
}
```

**Follow-up**: User runs `/clear` then `/devloop:continue`

---

#### `/devloop:spike`

**File**: `commands/spike.md`

**Purpose**: Technical exploration before implementation

**Phases**:
1. Exploration - Investigate codebase
2. Analysis - Assess feasibility
3. Findings - Document discoveries
4. Planning - Create task breakdown
5. Integration - Apply to plan

**Output**: Spike report + updated plan

---

#### `/devloop:quick`

**File**: `commands/quick.md`

**Purpose**: Fast implementation for simple tasks

**When to Use**:
- Single-file changes
- Clear requirements
- Well-defined scope

**Skips**: Discovery, exploration, extensive planning

---

### Utility Commands

| Command | Purpose |
|---------|---------|
| `/devloop:ship` | Git integration (commit/PR) |
| `/devloop:review` | Code review workflow |
| `/devloop:analyze` | Codebase refactoring analysis |
| `/devloop:onboard` | Set up devloop for existing repo |
| `/devloop:bootstrap` | New project setup |
| `/devloop:new` | Create new issue |
| `/devloop:issues` | Manage issues |
| `/devloop:bug` | Quick bug creation |
| `/devloop:bugs` | View bugs |
| `/devloop:worklog` | Manage work history |
| `/devloop:statusline` | Configure status bar |
| `/devloop:stats` | Usage statistics |

---

## Agent Reference

### Super-Agents

#### `engineer`

**Model**: sonnet

**Modes**:
| Mode | Trigger Keywords | Purpose |
|------|-----------------|---------|
| Explorer | "explore", "understand", "investigate" | Codebase exploration |
| Architect | "design", "architecture", "structure" | Design decisions |
| Refactorer | "refactor", "cleanup", "improve" | Code improvement |
| Git | "commit", "branch", "pr", "push" | Git operations |
| Default | (other) | Implementation |

**Skills Applied**:
- Language patterns (go, react, python, java)
- Architecture patterns
- Testing strategies
- Git workflows

---

#### `qa-engineer`

**Model**: sonnet

**Modes**:
| Mode | Trigger | Purpose |
|------|---------|---------|
| Generator | "write tests", "generate tests" | Test creation |
| Runner | "run tests", "execute tests" | Test execution |
| Bug Tracker | "track bug", "create issue" | Bug management |
| Validator | "validate", "verify" | Deployment checks |

---

#### `task-planner`

**Model**: sonnet

**Modes**:
| Mode | Trigger | Purpose |
|------|---------|---------|
| Planner | "plan", "break down" | Task breakdown |
| Requirements | "requirements", "gather" | Requirements gathering |
| Issue Manager | "issue", "track" | Issue management |
| DoD Validator | "done", "complete", "verify" | Definition of Done |

---

### Specialized Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| `code-reviewer` | sonnet | Quality review with confidence filtering |
| `security-scanner` | haiku | OWASP Top 10, secrets detection |
| `workflow-detector` | haiku | Classify task type |
| `complexity-estimator` | haiku | T-shirt sizing |
| `doc-generator` | sonnet | Documentation generation |
| `summary-generator` | haiku | Session summaries |

---

## Skills Reference

### Quick Navigation

Skills are organized by category:

```
skills/
├── INDEX.md                    # Catalog (start here)
├── Language Patterns
│   ├── go-patterns/
│   ├── react-patterns/
│   ├── python-patterns/
│   └── java-patterns/
├── Workflow
│   ├── workflow-loop/
│   ├── workflow-selection/
│   ├── plan-management/
│   └── task-checkpoint/
├── Code Quality
│   ├── architecture-patterns/
│   ├── testing-strategies/
│   ├── security-checklist/
│   └── refactoring-analysis/
├── Git & Versioning
│   ├── git-workflows/
│   ├── atomic-commits/
│   └── version-management/
└── Meta
    ├── file-locations/
    ├── tool-usage-policy/
    └── model-selection-guide/
```

### High-Impact Skills

#### `workflow-loop`

**Purpose**: Multi-task workflow patterns with checkpoints

**Contains**:
- Standard loop pattern
- State transitions
- Checkpoint sequences
- Error recovery

**Key Concept**: Every task → checkpoint → decision

---

#### `plan-management`

**Purpose**: Plan file conventions and procedures

**Contains**:
- Plan format specification
- Task markers (`[ ]`, `[~]`, `[x]`)
- Progress tracking
- Parallelism markers

**Key Files**:
- `.devloop/plan.md` - Active plan
- `.devloop/plan-state.json` - Machine-readable state

---

#### `task-checkpoint`

**Purpose**: Task completion verification

**Checklist**:
1. ✓ Code changes complete
2. ✓ Tests pass
3. ✓ Plan markers updated
4. ✓ Worklog entry added
5. ✓ No uncommitted changes (or intentional)

---

#### `atomic-commits`

**Purpose**: Commit strategy guidance

**Principles**:
- One logical change per commit
- Self-contained and reviewable
- Conventional commit format
- Task linkage in messages

---

### Language Pattern Skills

Each language skill follows the same structure:

```markdown
# {Language} Patterns

## Error Handling
[Language-specific patterns]

## Testing
[Framework and patterns]

## Common Idioms
[Idiomatic code patterns]

## Pitfalls to Avoid
[Anti-patterns]
```

| Skill | Version | Focus Areas |
|-------|---------|-------------|
| `go-patterns` | Go 1.21+ | Interfaces, errors, goroutines |
| `react-patterns` | React 18+ | Hooks, state, a11y |
| `python-patterns` | Python 3.10+ | Type hints, async, pytest |
| `java-patterns` | Java 17+ | Spring, streams, DI |

---

## Hooks Reference

### Session Lifecycle

#### `session-start.sh`

**Event**: `SessionStart`

**Actions**:
1. Detect project language/framework
2. Check for active plan
3. Check for saved state
4. Display status message

---

#### `session-end.sh`

**Event**: `SessionEnd`

**Actions**:
1. Update session metrics
2. Rotate worklog if needed
3. Clean up temporary state

---

### Git Hooks

#### `pre-commit.sh`

**Event**: `PreToolUse` (git commit)

**Actions**:
1. Check plan sync
2. Validate no uncommitted tasks
3. Block if out of sync (strict mode)

---

#### `post-commit.sh`

**Event**: `PostToolUse` (git commit)

**Actions**:
1. Extract commit hash
2. Update worklog with commit reference
3. Update plan markers if needed

---

### Hook Configuration

All hooks are configured in `hooks/hooks.json`:

```json
{
  "hooks": [
    {
      "name": "session-start",
      "event": "SessionStart",
      "script": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
    },
    {
      "name": "pre-commit",
      "event": "PreToolUse",
      "matcher": {
        "tool": "Bash",
        "command_pattern": "^git commit"
      },
      "script": "${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit.sh"
    }
  ]
}
```

---

## Scripts Reference

Utility scripts in `scripts/`:

| Script | Purpose |
|--------|---------|
| `detect-plan.sh` | Find active plan file |
| `validate-plan.sh` | Check plan syntax |
| `calculate-progress.sh` | Count task completion |
| `sync-plan-state.sh` | Sync markdown ↔ JSON state |
| `rotate-worklog.sh` | Archive old worklog entries |
| `suggest-fresh.sh` | Check if fresh start needed |
| `get-context-usage.sh` | Calculate context usage |

---

## Templates

Reusable templates in `templates/`:

### Bootstrap Templates

For new projects:
- `claudemd-template.md` - CLAUDE.md template
- `initial-plan-template.md` - First plan template

### Onboard Templates

For existing projects:
- `claudemd-template.md` - CLAUDE.md for existing repos
- `plan-template.md` - Migration plan template
- `devloop-section.md` - Devloop workflow section

### Local Configuration

- `devloop.local.md` - Local settings template

---

## Next Steps

- [State Management](06-state-management.md) - File formats and state
- [Architecture](01-architecture.md) - How components interact
- [Contributing](07-contributing.md) - Add your own components
