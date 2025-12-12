---
name: plan-management
description: Central reference for devloop plan file location, format, and update procedures. All agents and commands MUST follow these conventions to keep plans in sync. Use when working with devloop plans.
---

# Plan Management

**CRITICAL**: All devloop agents and commands MUST follow these conventions to ensure plan consistency.

## When NOT to Use This Skill

- **Quick tasks**: Simple fixes don't need formal plans - use `/devloop:quick`
- **No existing plan**: If starting fresh, let `/devloop` create the plan
- **Read-only agents**: Agents with `permissionMode: plan` can't update plans
- **Bug fixes**: Use bug tracking, not the feature plan
- **Exploratory work**: Spikes create reports, not plans

## Plan File Location

The canonical plan location is:

```
.claude/devloop-plan.md
```

**Discovery order** (for finding existing plans):
1. `.claude/devloop-plan.md` ← Primary location
2. `docs/PLAN.md`
3. `PLAN.md`
4. `~/.claude/plans/*.md` (fallback to most recent)

**Always save new plans to**: `.claude/devloop-plan.md`

## Plan File Format

```markdown
# Devloop Plan: [Feature Name]

**Created**: [YYYY-MM-DD]
**Updated**: [YYYY-MM-DD HH:MM]
**Status**: [Planning | In Progress | Review | Complete]
**Current Phase**: [Phase name]

## Overview
[2-3 sentence description of the feature]

## Requirements
[Key requirements or link to requirements doc]

## Architecture
[Chosen approach summary]

## Tasks

### Phase 1: [Phase Name]
- [ ] Task 1.1: [Description]
  - Acceptance: [Criteria]
  - Files: [Expected files to create/modify]
- [ ] Task 1.2: [Description]
  ...

### Phase 2: [Phase Name]
- [ ] Task 2.1: [Description]
...

## Progress Log
- [YYYY-MM-DD HH:MM]: [Event description]
- [YYYY-MM-DD HH:MM]: [Event description]
```

## Task Status Markers

| Marker | Meaning |
|--------|---------|
| `- [ ]` | Pending / Not started |
| `- [x]` | Completed |
| `- [~]` | In progress |
| `- [-]` | Skipped / Not applicable |
| `- [!]` | Blocked |

## Plan Update Rules

### When to Update the Plan

| Event | Action |
|-------|--------|
| Task started | Mark `- [~]`, add to Progress Log |
| Task completed | Mark `- [x]`, add to Progress Log |
| Task blocked | Mark `- [!]`, add blocker note |
| Phase completed | Update Current Phase |
| New task discovered | Add to appropriate phase |
| Task skipped | Mark `- [-]`, add reason |
| Plan approved | Update Status to "In Progress" |
| All tasks done | Update Status to "Review" |
| DoD passed | Update Status to "Complete" |

### How to Update

1. **Read the current plan** from `.claude/devloop-plan.md`
2. **Make changes** to task markers and Progress Log
3. **Update timestamps**: Set `Updated` to current date/time
4. **Write back** to the same location

### Progress Log Format

```markdown
## Progress Log
- 2024-12-11 14:30: Plan created
- 2024-12-11 15:00: Started Phase 1
- 2024-12-11 15:45: Completed Task 1.1 - Created user model
- 2024-12-11 16:00: Task 1.2 blocked - waiting for API spec
- 2024-12-11 17:00: Phase 1 complete, starting Phase 2
```

## Agent Responsibilities

### Agents that CREATE plans
- **task-planner**: Creates initial plan, saves to `.claude/devloop-plan.md`

### Agents that UPDATE plans
- **task-planner**: Modifies plan structure
- **summary-generator**: Marks tasks complete, adds to Progress Log
- **dod-validator**: Updates Status when validation passes/fails

### Agents that READ plans (but don't modify)
- **complexity-estimator**: Reads to assess remaining work
- **code-explorer**: Reads for context
- **code-architect**: Reads for design context
- **code-reviewer**: Reads to understand scope
- **requirements-gatherer**: Reads existing requirements

### Agents with `permissionMode: plan`
These agents have read-only access and CANNOT update the plan directly.
They should:
1. Note any plan updates needed in their output
2. Return recommendations for plan changes
3. The parent agent/command is responsible for applying updates

## Command Responsibilities

| Command | Plan Action |
|---------|-------------|
| `/devloop` | Creates plan in Phase 6, updates throughout |
| `/devloop:continue` | Reads plan, marks tasks in progress/complete |
| `/devloop:quick` | May skip plan (simple tasks) |
| `/devloop:spike` | Creates spike report, may recommend plan changes |
| `/devloop:review` | Reads plan for context, doesn't modify |
| `/devloop:ship` | Reads plan, updates Status to Complete if DoD passes |

## Ensuring Sync

### Before Starting Work
```
1. Check if .claude/devloop-plan.md exists
2. If yes, read and understand current state
3. If no, either create one or confirm this is intentional
```

### After Completing Work
```
1. Update task status in plan
2. Add Progress Log entry
3. Update timestamps
4. If phase complete, update Current Phase
```

### On Session Start
The session-start hook automatically:
- Detects if a plan exists
- Shows plan progress (X/Y tasks)
- Suggests `/devloop:continue` if plan is active

## Environment Variable

The plan path can be referenced via:
```
DEVLOOP_PLAN_PATH=.claude/devloop-plan.md
```

## Error Handling

| Scenario | Action |
|----------|--------|
| Plan file missing | Ask user: create new or continue without? |
| Plan file corrupted | Attempt recovery, ask user if fails |
| Task not in plan | Ask user: add to plan or proceed without? |
| Multiple plans found | Use priority order, warn user |

## Integration with Claude's Plan Mode

If using Claude's built-in plan mode (`--permission-mode plan`):
- Claude may create plans in `~/.claude/plans/`
- After plan mode, **copy/merge** the plan to `.claude/devloop-plan.md`
- This ensures the project-local plan stays current

## See Also

- `Skill: workflow-selection` - Choosing the right workflow
- `Skill: complexity-estimation` - Estimating task complexity
- `/devloop:continue` - Resuming from a plan
