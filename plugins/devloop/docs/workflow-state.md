# Workflow State Documentation

**Version**: 1.0.0
**Schema**: `plugins/devloop/schemas/workflow.schema.json`
**File Location**: `.devloop/workflow.json`

## Overview

The workflow state file (`workflow.json`) is the **unified source of truth** for tracking your development workflow position, progress, and health across multiple sessions. Unlike `plan.md` which tracks tasks, `workflow.json` tracks your **position in the entire development loop**: idea → spike → plan → execution → validation → shipping.

## Purpose

### What It Tracks

| Category | Examples |
|----------|----------|
| **Position** | Current phase, task, command |
| **Origin** | How you started (spike, manual, issue) |
| **Plan** | Active plan reference and progress |
| **Sessions** | History of work sessions |
| **Metrics** | Velocity, health, completion rates |
| **Transitions** | Phase changes over time |
| **Recommendations** | Smart next actions |

### What It Enables

- **Smart routing**: `/devloop:start` auto-detects where you are
- **Health monitoring**: Track workflow effectiveness
- **Context awareness**: Know when to refresh
- **Automatic handoffs**: Seamless transitions between phases
- **Metrics**: Understand velocity and trends

## File Location

```
.devloop/workflow.json
```

**Creation**: Automatically created when you run `/devloop`, `/devloop:spike`, or `/devloop:start`

**Updates**: Updated at checkpoints during `/devloop:continue`, `/devloop:fresh`, and phase transitions

## Schema Version

Current version: `1.0.0`

The schema version allows for future evolution while maintaining backward compatibility. Scripts should check the schema version and handle gracefully.

## Top-Level Fields

### workflow_id (required)

Unique identifier for this workflow. Can be UUID or timestamp-based.

```json
"workflow_id": "550e8400-e29b-41d4-a716-446655440000"
```

### started (required)

ISO 8601 timestamp when workflow was initiated.

```json
"started": "2025-12-29T10:00:00Z"
```

### last_active (required)

ISO 8601 timestamp of most recent activity. Used for staleness detection.

```json
"last_active": "2025-12-29T14:30:00Z"
```

### position (required)

Current position within the workflow loop.

#### position.phase

Where you are in the development cycle:

| Phase | Meaning |
|-------|---------|
| `idea` | Initial concept, unclear requirements |
| `spike` | Exploratory investigation |
| `planning` | Creating or refining plan |
| `execution` | Implementing tasks |
| `validation` | Testing and DoD checks |
| `shipping` | Committing, PR, deployment |
| `complete` | Workflow finished |

#### position.subphase

Phase-specific detail (optional):
- **spike**: `exploring`, `documenting`
- **execution**: `implementing`, `testing`, `reviewing`
- **validation**: `running_tests`, `checking_dod`

#### position.current_task

Current task ID being worked on (e.g., `"2.1"`). Null if not task-based.

#### position.current_command

Last devloop command executed: `spike`, `devloop`, `continue`, `fresh`, `quick`, `ship`, `review`

**Example**:
```json
"position": {
  "phase": "execution",
  "subphase": "implementing",
  "current_task": "2.1",
  "current_command": "continue"
}
```

### origin

How the workflow was initiated.

#### origin.type

| Type | When Used |
|------|-----------|
| `manual` | User ran `/devloop` directly |
| `spike` | Workflow started from spike report |
| `issue` | Started from bug/feature issue |
| `quick` | Quick task workflow |

#### origin.source

Reference to originating artifact:
- Spike: `.devloop/spikes/auth-flow.md`
- Issue: `BUG-123`, `FEAT-456`
- Manual: User description or null

**Example**:
```json
"origin": {
  "type": "spike",
  "source": ".devloop/spikes/auth-flow.md",
  "timestamp": "2025-12-29T09:00:00Z"
}
```

### plan

Information about associated plan (if exists).

**Example**:
```json
"plan": {
  "file": ".devloop/plan.md",
  "name": "Feature: Authentication",
  "total_tasks": 10,
  "completed_tasks": 4,
  "current_phase_name": "Phase 2: Implementation"
}
```

### sessions

Array of session objects tracking individual work sessions.

**Example**:
```json
"sessions": [
  {
    "id": "session-1",
    "started": "2025-12-29T10:00:00Z",
    "ended": "2025-12-29T12:00:00Z",
    "tasks_completed": 3,
    "commits": ["abc1234", "def5678"],
    "context_peak_pct": 67,
    "tokens_used": 45000,
    "agents_spawned": 2
  }
]
```

### metrics

Aggregated metrics across all sessions.

#### metrics.velocity

```json
"velocity": {
  "tasks_per_hour": 1.5,
  "trend": "stable"  // improving | stable | declining | unknown
}
```

#### metrics.health

Overall workflow health score (0-100) with factor breakdown:

```json
"health": {
  "score": 85,
  "factors": {
    "plan_freshness": 100,      // Plan updated < 24h
    "worklog_sync": 80,          // Worklog in sync with tasks
    "commit_frequency": 75,      // Regular commits
    "context_management": 85     // Fresh starts when needed
  }
}
```

**Health Factor Calculation**:

| Factor | Weight | Formula |
|--------|--------|---------|
| plan_freshness | 25% | Updated < 24h = 100%, < 48h = 75%, < 7d = 50%, else 25% |
| worklog_sync | 25% | Pending worklog entries / completed tasks (inverted) |
| commit_frequency | 25% | Commits in last session vs tasks completed |
| context_management | 25% | Fresh starts appropriately used, context % managed |

**Overall Score** = Average of all four factors

### transitions

Array of phase transition records.

**Example**:
```json
"transitions": [
  {
    "from": "spike",
    "to": "planning",
    "timestamp": "2025-12-29T09:30:00Z",
    "trigger": "manual"
  },
  {
    "from": "planning",
    "to": "execution",
    "timestamp": "2025-12-29T10:00:00Z",
    "trigger": "auto"
  }
]
```

**Trigger Types**:
- `manual`: User explicitly invoked command
- `auto`: Automatic transition based on state
- `checkpoint`: Triggered at task checkpoint
- `command`: Result of command execution

### next_action

Smart recommendation for what to do next.

**Example**:
```json
"next_action": {
  "recommended": "continue",
  "reason": "4 tasks remaining in current phase",
  "alternatives": ["commit", "fresh", "ship"],
  "freshness_warning": false
}
```

**Recommended Actions**:
| Action | When Recommended |
|--------|------------------|
| `continue` | Active plan with pending tasks |
| `fresh` | Context > 60%, session getting heavy |
| `commit` | Uncommitted changes exist |
| `ship` | All tasks complete, ready for PR |
| `review` | Code review needed |
| `spike` | Unclear requirements, need exploration |
| `new_workflow` | Current workflow complete or stale |
| `archive` | Workflow old but complete |

**freshness_warning**: Set to `true` if `last_active` is > 7 days old

## Complete Example

```json
{
  "schema_version": "1.0.0",
  "workflow_id": "550e8400-e29b-41d4-a716-446655440000",
  "started": "2025-12-29T10:00:00Z",
  "last_active": "2025-12-29T14:30:00Z",

  "position": {
    "phase": "execution",
    "subphase": "implementing",
    "current_task": "2.1",
    "current_command": "continue"
  },

  "origin": {
    "type": "spike",
    "source": ".devloop/spikes/auth-flow.md",
    "timestamp": "2025-12-29T09:00:00Z"
  },

  "plan": {
    "file": ".devloop/plan.md",
    "name": "Feature: Authentication",
    "total_tasks": 10,
    "completed_tasks": 4,
    "current_phase_name": "Phase 2: Implementation"
  },

  "sessions": [
    {
      "id": "session-1",
      "started": "2025-12-29T10:00:00Z",
      "ended": "2025-12-29T12:00:00Z",
      "tasks_completed": 3,
      "commits": ["abc1234"],
      "context_peak_pct": 67,
      "tokens_used": 45000,
      "agents_spawned": 2
    },
    {
      "id": "session-2",
      "started": "2025-12-29T13:00:00Z",
      "ended": null,
      "tasks_completed": 1,
      "commits": [],
      "context_peak_pct": 45,
      "tokens_used": 12000,
      "agents_spawned": 0
    }
  ],

  "metrics": {
    "total_tasks_completed": 4,
    "total_commits": 1,
    "total_sessions": 2,
    "avg_tasks_per_session": 2.0,
    "avg_context_peak": 56,
    "velocity": {
      "tasks_per_hour": 1.5,
      "trend": "stable"
    },
    "health": {
      "score": 85,
      "factors": {
        "plan_freshness": 100,
        "worklog_sync": 80,
        "commit_frequency": 75,
        "context_management": 85
      }
    }
  },

  "transitions": [
    {
      "from": "spike",
      "to": "planning",
      "timestamp": "2025-12-29T09:30:00Z",
      "trigger": "manual"
    },
    {
      "from": "planning",
      "to": "execution",
      "timestamp": "2025-12-29T10:00:00Z",
      "trigger": "auto"
    }
  ],

  "next_action": {
    "recommended": "continue",
    "reason": "6 tasks remaining in Phase 2",
    "alternatives": ["fresh", "commit", "status"],
    "freshness_warning": false
  }
}
```

## How It's Used

### Session Start Hook

The `session-start.sh` hook reads workflow.json and outputs structured state:

```bash
# Check for active workflow
if [ -f .devloop/workflow.json ]; then
  phase=$(jq -r '.position.phase' .devloop/workflow.json)
  task=$(jq -r '.position.current_task // "none"' .devloop/workflow.json)

  # Output to agent
  echo "Active workflow detected: $phase phase, task $task"
fi
```

### Workflow Router Skill

The `workflow-router` skill interprets workflow.json and presents guided choices:

```markdown
Based on workflow state:
- Phase: execution
- Progress: 4/10 tasks (40%)
- Health: 85/100

Recommended: Continue to Task 2.1

[Continue] [Take Fresh Start] [View Status] [New Work]
```

### /devloop:start Command

The start command reads workflow.json to auto-detect context and route appropriately:

```markdown
📍 Workflow Status: Active workflow detected

   Plan: Feature: Authentication
   Progress: 4/10 tasks (40%)
   Last active: 2 hours ago
   Health: 85/100 ✓

   Recommended: Continue execution

[Continue] [Fresh start] [View status] [New workflow]
```

### /devloop:continue Updates

At each checkpoint, `/devloop:continue` updates workflow.json:

```bash
# Update current task
jq '.position.current_task = "2.2"' workflow.json > tmp.json && mv tmp.json workflow.json

# Update session metrics
jq '.sessions[-1].tasks_completed += 1' workflow.json > tmp.json && mv tmp.json workflow.json

# Update last_active timestamp
jq ".last_active = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" workflow.json > tmp.json && mv tmp.json workflow.json
```

## Backward Compatibility

**If workflow.json doesn't exist**:
- Scripts fall back to plan.md detection only
- First devloop command creates workflow.json
- No manual migration needed

**If workflow.json is stale** (last_active > 7 days):
- `freshness_warning` set to true
- User prompted to resume or archive
- No data loss, just warning

## Validation

Validate workflow.json against schema:

```bash
# Using ajv-cli
ajv validate -s plugins/devloop/schemas/workflow.schema.json -d .devloop/workflow.json

# Using jq (basic checks)
jq -e '.schema_version and .workflow_id and .started and .last_active and .position' .devloop/workflow.json
```

## Migration from Pre-2.5.0

Users upgrading from devloop 2.4.x:

1. **No action required** - workflow.json created on first use of new commands
2. **Existing plans work** - plan.md continues to function
3. **Gradual adoption** - New features enable as you use them

## See Also

- `plugins/devloop/schemas/workflow.schema.json` - JSON Schema definition
- `plugins/devloop/scripts/workflow-state.sh` - State management script (Task 7.2)
- `plugins/devloop/skills/workflow-router/SKILL.md` - Routing skill (Task 7.3)
- `plugins/devloop/commands/start.md` - Smart entry point command (Task 8.1)
