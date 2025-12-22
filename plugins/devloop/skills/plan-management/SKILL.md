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
.devloop/plan.md
```

**Discovery order** (for finding existing plans):
1. `.devloop/plan.md` ← Primary location
2. `docs/PLAN.md`
3. `PLAN.md`
4. `~/.claude/plans/*.md` (fallback to most recent)

**Always save new plans to**: `.devloop/plan.md`

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

## Plan Archival

When plans grow large (>200 lines) or have multiple completed phases, use `/devloop:archive` to compress the active plan while preserving historical context.

### When to Archive

**DO archive when:**
- Plan file exceeds 200 lines
- 2+ phases are 100% complete (all tasks `[x]`)
- `/devloop:continue` feels slow due to plan size
- Team wants active plan focused on "what's next"

**DON'T archive when:**
- Plan < 100 lines (too small, no benefit)
- Active phases still in progress
- All phases complete (use `/devloop:ship` instead)

### Archive Format

Archived phases are saved to `.devloop/archive/{plan-name}_phase_{N}_{timestamp}.md`:

```markdown
# Archived Plan: {Plan Name} - Phase {N}

**Archived**: {YYYY-MM-DD}
**Original Plan**: {Plan name}
**Phase Status**: Complete
**Tasks**: {X}/{X} complete

---

{Complete phase section from plan}

---

## Progress Log (Phase {N})

{Progress log entries for this phase}

---

**Note**: This phase was archived to compress the active plan.
```

### Compressed Plan Structure

After archival, the active `.devloop/plan.md` is compressed to:

1. **Keep**:
   - Plan header with metadata
   - Overview, Architecture, Requirements sections
   - All non-archived phases (pending or in-progress)
   - Last 10 Progress Log entries
   - Notes and Success Criteria

2. **Remove**:
   - Archived phases (saved to archive files)
   - Older Progress Log entries (rotated to worklog)

3. **Update**:
   - Progress Log with archival note:
     ```markdown
     - {YYYY-MM-DD}: Archived Phase 1, Phase 2 to .devloop/archive/
     ```

### Archive-Worklog Integration

When archiving, Progress Log entries for completed phases are extracted and appended to `.devloop/worklog.md`:

```markdown
## {YYYY-MM-DD}

### {Plan Name} - Phase {N} Complete

**Tasks Completed**:
- Task N.1: {Description}
- Task N.2: {Description}

**Commits**: {List commit hashes from Progress Log}

**Archived Plan**: `.devloop/archive/{filename}.md`

---
```

### Archive Awareness

**Commands that handle archives:**
- `/devloop:continue` - Detects archived phases, displays "Archive Status" note
- `/devloop:archive` - Creates and manages archives

**Hooks that handle archives:**
- Pre-commit hook - Skips task count validation for archived plans

**Git tracking:**
- Archive files ARE git-tracked (team visibility)
- Compressed plan IS git-tracked
- Both committed together

### Restoration from Archive

To restore an archived phase:
1. Read archive file from `.devloop/archive/`
2. Copy phase section back into plan.md
3. Update Progress Log
4. Update Current Phase metadata

Archives are complete backups - no information is lost during archival.

## Task Status Markers

| Marker | Meaning |
|--------|---------|
| `- [ ]` | Pending / Not started |
| `- [x]` | Completed |
| `- [~]` | In progress |
| `- [-]` | Skipped / Not applicable |
| `- [!]` | Blocked |

## Parallelism Markers

Tasks can include optional markers to indicate parallelization potential:

| Marker | Meaning | Example |
|--------|---------|---------|
| `[parallel:X]` | Can run with other tasks in group X | `[parallel:A]` |
| `[depends:N.M,...]` | Must wait for listed tasks | `[depends:1.1,1.2]` |
| `[background]` | Low priority, can run in background | |
| `[sequential]` | Must run alone, not parallelizable | |

### Phase-Level Parallelism

Phases can indicate overall parallelization:

```markdown
### Phase 2: Core Implementation  [parallel:partial]
**Parallelizable**: full | partial | none
**Parallel Groups**:
- Group A: Tasks 2.1, 2.2 (independent implementations)
- Group B: Tasks 2.3, 2.4 (can run after Group A completes)

- [ ] Task 2.1: Create user model  [parallel:A]
  - Acceptance: ...
- [ ] Task 2.2: Create auth service  [parallel:A]
  - Acceptance: ...
- [ ] Task 2.3: Wire up middleware  [depends:2.1,2.2] [parallel:B]
  - Acceptance: ...
- [ ] Task 2.4: Add logging  [parallel:B]
  - Acceptance: ...
```

### Detecting Parallel Tasks

When `/devloop:continue` reads a plan:
1. Find all pending tasks with `[parallel:X]` markers sharing the same group
2. Offer to spawn agents in parallel for those tasks
3. Track progress of all parallel tasks together
4. Only proceed to dependent tasks when group completes

---

## Smart Parallelism Guidelines

### When to Parallelize

**DO parallelize:**
- **Read-only operations**: Multiple explorers, reviewers, analyzers examining different areas
- **Independent implementations**: Tasks in same phase that touch different files
- **Test generation + implementation**: Tests can be written while implementing (when marked)
- **Multiple audits**: Security auditors analyzing different domains
- **Documentation tasks**: API docs, README updates can run parallel to code

**Parallel-safe patterns:**
```markdown
# Good: Independent file creation
- [ ] Task 2.1: Create user model  [parallel:A]
- [ ] Task 2.2: Create product model  [parallel:A]

# Good: Read-only exploration
- [ ] Explore auth patterns  [parallel:A]
- [ ] Explore API patterns  [parallel:A]
```

### When NOT to Parallelize

**DO NOT parallelize:**
- **Dependent tasks**: Task B needs output from Task A
- **Same file modifications**: Risk of merge conflicts
- **Complex context sharing**: When agents need to coordinate closely
- **High token cost scenarios**: Multiple Opus agents running in parallel
- **User interaction required**: Background agents can't ask questions

**Sequential patterns:**
```markdown
# Bad: Dependent tasks marked parallel
- [ ] Task 2.1: Create base class  [parallel:A]
- [ ] Task 2.2: Extend base class  [parallel:A]  # WRONG - depends on 2.1!

# Good: Express dependency
- [ ] Task 2.1: Create base class
- [ ] Task 2.2: Extend base class  [depends:2.1]
```

### Token Cost Awareness

| Scenario | Parallel? | Rationale |
|----------|-----------|-----------|
| 3x haiku explorers | Yes | Low cost (~$0.01), high benefit |
| 3x sonnet architects | Maybe | Medium cost, evaluate if all needed |
| 3x opus reviewers | No | High cost (~$0.15+ each), diminishing returns |
| 1 opus + 2 haiku | Yes | Balanced - heavy lifting + quick helpers |
| 5+ agents of any type | No | Context coordination costs exceed benefits |

**Rule of thumb**: Max 3-4 parallel agents. Beyond that, coordination overhead negates benefits.

### Model Selection for Parallel Work

| Agent Type | Model | Notes |
|------------|-------|-------|
| code-explorer | sonnet | Multiple explorers useful |
| code-architect | sonnet | Usually only need 2-3 variants |
| code-reviewer | sonnet | Run parallel, different focus areas |
| test-generator | haiku | Can run parallel to implementation |
| security auditors | sonnet | Designed for parallel execution |

### Marking Tasks for Parallelism

When creating plans, task-planner should:

1. **Identify independent tasks**: Tasks that don't share files or dependencies
2. **Group by execution order**: Tasks that can run at the same time get same group letter
3. **Mark dependencies explicitly**: Use `[depends:X.Y]` for clear ordering
4. **Consider token costs**: Don't mark expensive tasks for parallel without justification

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

1. **Read the current plan** from `.devloop/plan.md`
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
- **task-planner**: Creates initial plan, saves to `.devloop/plan.md`

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
1. Check if .devloop/plan.md exists
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
DEVLOOP_PLAN_PATH=.devloop/plan.md
```

---

## Enforcement Configuration

Configure enforcement behavior in `.devloop/local.md`:

```yaml
---
enforcement: advisory    # advisory (default) | strict
auto_commit: true        # Prompt for commits after tasks
auto_version: true       # Suggest version bumps at phase completion
changelog: true          # Maintain CHANGELOG.md
auto_tag: false          # Create git tags (or prompt)
---
```

### Enforcement Modes

#### Advisory Mode (default)

When plan is not updated after task completion:
```
⚠️ Warning: Plan file not updated for completed task.

The task appears complete but .devloop/plan.md
was not updated. This may cause sync issues.

Would you like to:
- Update now (Update the plan file)
- Continue anyway (Skip plan update)
- Review task (Verify completion status)
```

When changes are uncommitted:
```
⚠️ Warning: Uncommitted changes detected.

You have changes that may need to be committed.
Consider creating an atomic commit before proceeding.

Would you like to:
- Commit now (Create atomic commit)
- Continue (Keep changes uncommitted)
- Review changes (Show diff)
```

#### Strict Mode

When plan is not updated:
```
🛑 Blocked: Plan update required.

Strict enforcement is enabled. Cannot proceed to next task
until .devloop/plan.md is updated.

Required actions:
1. Mark Task X.Y as [x] complete
2. Add Progress Log entry

Run the plan update now.
```

When changes are uncommitted at phase boundary:
```
🛑 Blocked: Commit required before phase transition.

Strict enforcement requires all work to be committed
before completing a phase.

Pending changes:
- [list of modified files]

Create a commit to proceed.
```

### Per-Project Settings

The `.devloop/local.md` file:
- Is project-specific (not committed to git)
- Has YAML frontmatter for settings
- Can include markdown notes/preferences
- Is read at session start and during enforcement checks

### Default Behavior

If no `.devloop/local.md` exists:
- `enforcement: advisory`
- `auto_commit: true` (prompts, doesn't auto-commit)
- `auto_version: true` (suggests, doesn't auto-bump)
- `changelog: true` (offers to update if exists)
- `auto_tag: false` (manual tagging)

### Enforcement Hooks

The devloop plugin includes hooks that implement enforcement:

**Pre-Commit Hook** (`hooks/pre-commit.sh`):
- Triggered before any `git commit` command
- Checks if plan has completed tasks without Progress Log entries
- In advisory mode: warns but allows commit
- In strict mode: blocks commit until plan is updated
- Checks `**Updated**:` timestamp (recent = approved)

**Post-Commit Hook** (`hooks/post-commit.sh`):
- Triggered after successful `git commit`
- Extracts commit hash and message
- Parses task references from commit message (e.g., "- Task 1.1")
- Updates worklog with commit entry
- Adds completed tasks to worklog's "Tasks Completed" section

**Hook Configuration**:
Hooks are configured in `plugins/devloop/hooks/hooks.json` and use the
`condition` field to match git commit commands specifically.

---

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
- After plan mode, **copy/merge** the plan to `.devloop/plan.md`
- This ensures the project-local plan stays current

## See Also

- `Skill: workflow-selection` - Choosing the right workflow
- `Skill: worklog-management` - Worklog format and updates
- `Skill: file-locations` - Where devloop files belong
- `Skill: complexity-estimation` - Estimating task complexity
- `/devloop:continue` - Resuming from a plan
- `/devloop:archive` - Compressing large plans by archiving completed phases
