# Spike Report: Devloop Consistency & Enforcement

## Questions Investigated

1. **File Location Consistency** → Needs explicit git-tracked vs local-only categorization
2. **Worklog System** → Currently no separation between active plan and completed work history
3. **Enforcement Mechanisms** → Exists but is advisory-only, inconsistently applied
4. **Happy Path & Recovery** → Missing explicit checkpoints and recovery flows

## Findings

### 1. Current `.claude/` File Ecosystem

| File/Directory | Purpose | Should Git Track? | Current Guidance |
|----------------|---------|-------------------|------------------|
| `devloop-plan.md` | Active implementation plan | **Yes** | Clear |
| `devloop-worklog.md` | Completed work history | **Yes** | NEW - doesn't exist |
| `devloop.local.md` | Local settings/overrides | **No** | Clear |
| `issues/` | Issue tracking (bugs, features, tasks) | **Yes** | Clear |
| `bugs/` | Legacy bug tracking | **Yes** | Deprecated |
| `project-context.json` | Tech stack detection | **Yes** | Unclear - needs doc |
| `*-spike-report.md` | Spike investigation results | **No** | Unclear - needs doc |
| `settings.json` | Claude global settings | **No** | External (Claude Code) |
| `security/` | Security audit reports | **No** | Exists but undocumented |

**Finding**: Need a `file-locations` skill documenting what goes where and why.

### 2. Plan vs Worklog Problem

**Current State**:
- Plan file (`devloop-plan.md`) contains:
  - Task definitions (static)
  - Task status (changes during work)
  - Progress Log (grows unbounded)
  - Commit references (mixed in log)

**Problems**:
1. Progress Log grows large, mixes with active tasks
2. No clear separation of "what to do" vs "what was done"
3. Hard to see work history separate from plan
4. No archival when plan completes

**Proposed Solution - Worklog**:

```
.claude/
├── devloop-plan.md      # Active plan: tasks + status
└── devloop-worklog.md   # History: completed tasks + commits
```

**Worklog File Format**:
```markdown
# Devloop Worklog

**Project**: [from plan]
**Started**: 2025-12-18

## Completed Work

### 2025-12-18

#### Task 1.1: Create issue-tracking skill [x]
- **Completed**: 11:15
- **Commit**: abc1234
- **Summary**: Created SKILL.md with full schema, type definitions

#### Task 1.2: Define view file generation [x]
- **Completed**: 11:15
- **Commit**: abc1234 (grouped with 1.1)
- **Summary**: Added view generation rules to skill

### 2025-12-17
...
```

**Transition Flow**:
1. Task marked `[x]` in plan + Progress Log entry added
2. On commit → Task details move to worklog with commit hash
3. Progress Log in plan stays minimal (only uncommitted work)
4. When plan completes → Archive to `devloop-worklog.md` (history persists)

### 3. Enforcement Inconsistency

**Current State**:

| Action | Enforcement | Location |
|--------|-------------|----------|
| Plan update after task | Advisory | `continue.md`, `task-checkpoint` |
| Commit decision | Optional prompt | `continue.md` Step 5.5 |
| Worklog update | None | Doesn't exist |
| Pre-commit sync | None | No hook |
| Post-commit cleanup | None | No hook |

**Finding**: The `continue.md` command says "REQUIRED" but only warns, doesn't block.

**Proposed Enforcement Levels** (in `devloop.local.md`):

```yaml
enforcement:
  plan_update: strict    # Block task progression until plan updated
  commit_sync: strict    # Block commit if plan not updated
  worklog: advisory      # Warn but allow skipping worklog update
```

| Level | Behavior |
|-------|----------|
| `strict` | Block until requirement met |
| `advisory` | Warn with override option |
| `none` | No enforcement |

**Default**: `strict` for plan_update and commit_sync (the user's request)

### 4. Missing Hooks

**Current hooks.json supports**:
- SessionStart
- PreToolUse, PostToolUse
- Stop
- Notification

**Missing for devloop consistency**:

#### A. PreCommit Hook
```json
{
  "matcher": "git commit",
  "hooks": [{
    "type": "command",
    "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/pre-commit.sh",
    "timeout": 10
  }]
}
```

**pre-commit.sh checks**:
1. Does `.claude/devloop-plan.md` exist?
2. Are there `[x]` tasks without Progress Log entries?
3. Are there uncommitted Progress Log entries? (If yes, good - commit can proceed)
4. Are there staged files without corresponding plan task? (Warning)

**If checks fail**:
```json
{"decision": "block", "message": "Plan update required before commit. Run task checkpoint."}
```

#### B. PostCommit Hook
```json
{
  "matcher": "git commit",
  "hooks": [{
    "type": "command",
    "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/post-commit.sh",
    "timeout": 10
  }]
}
```

**post-commit.sh actions**:
1. Get commit hash from `git rev-parse HEAD`
2. Find Progress Log entries without commit hash
3. Move completed entries to worklog with commit hash
4. Update plan file timestamps

### 5. Happy Path Definition

**Complete Devloop Happy Path**:

```
1. Task selected from plan
   └─ Mark in-progress, update timestamp

2. Implementation work
   └─ Code changes, tests pass

3. Task checkpoint (REQUIRED)
   ├─ Mark [x] in plan
   ├─ Add Progress Log entry
   └─ Enforcement check

4. Commit decision
   ├─ Commit now → proceed to step 5
   └─ Group with next → return to step 1

5. Git commit (PreCommit hook runs)
   ├─ Hook verifies plan sync
   └─ If block → return to step 3

6. PostCommit hook runs
   ├─ Move entry to worklog
   ├─ Add commit hash
   └─ Clean Progress Log

7. Next task or done
```

### 6. Recovery Flows

**Scenario A: Plan not updated but commit already made**
```
Recovery:
1. Detect: Commit exists, plan shows [ ] for related task
2. Prompt: "Commit abc1234 appears related to Task X.Y. Mark complete?"
3. Action: Update plan retroactively, add to worklog with commit hash
```

**Scenario B: Code changes without plan task**
```
Recovery:
1. Detect: git status shows changes, no task in-progress
2. Prompt: "Changes detected but no task in progress. Options:"
   - Create ad-hoc task (adds to plan, marks in-progress)
   - Link to existing task (select from pending)
   - Ignore (one-off change, skip tracking)
```

**Scenario C: Worklog out of sync with git history**
```
Recovery:
1. Detect: git log shows commits, worklog missing entries
2. Prompt: "Found N commits not in worklog. Reconstruct?"
3. Action: Parse git log, match to plan tasks, populate worklog
```

## Feasibility

**Is this feasible?** Yes

**What's the complexity?**
- **Size**: L (Large)
- **Risk**: Medium
- **Confidence**: High

## Recommended Approach

Implement in 4 phases:

### Phase 1: Foundation (S)
1. Create `file-locations` skill documenting .claude/ structure
2. Add `.gitignore` template for devloop
3. Update CLAUDE.md with file location guidance

### Phase 2: Worklog System (M)
1. Create `worklog-management` skill with format spec
2. Update `task-checkpoint` skill to write to worklog
3. Create worklog initialization in devloop command
4. Update summary-generator to use worklog

### Phase 3: Enforcement Hooks (L)
1. Add PreCommit hook to hooks.json
2. Implement pre-commit.sh verification script
3. Add PostCommit hook to hooks.json
4. Implement post-commit.sh worklog updater
5. Update devloop.local.md template with enforcement settings
6. Update plan-management skill with enforcement docs

### Phase 4: Recovery & Polish (M)
1. Implement recovery prompts in continue.md
2. Add worklog reconstruction command
3. Update devloop README with workflow diagrams
4. Add integration tests for happy path

## Risks & Concerns

| Risk | Mitigation |
|------|------------|
| Hook complexity | Start with command hooks (simple bash), upgrade to prompt hooks if needed |
| Performance impact | Hooks timeout at 10s, keep scripts fast |
| User friction | Default to advisory first, let users opt into strict |
| Migration burden | Existing projects get advisory, new projects get strict |
| Git hook conflicts | Don't use actual git hooks, use Claude hook system |

## Recommendation

**Proceed with implementation**, but:

1. Start with **advisory defaults** to avoid breaking existing workflows
2. Document upgrade path to strict enforcement
3. Build worklog as optional initially (can reconstruct from git log)
4. Focus on happy path first, recovery flows in Phase 4

## Prototype Location

No prototype code created - this spike was design-focused.

## Next Steps

If proceeding:
1. Create implementation plan with all 4 phases
2. Start with Phase 1 (Foundation) - quick win
3. Phase 2 (Worklog) is the core value add
4. Phase 3 (Hooks) provides enforcement
5. Phase 4 (Recovery) handles edge cases

If deferring:
1. Document current limitations in README
2. Add "known issues" to devloop
3. Consider simpler interim: just make plan update blocking

## Plan Updates Required

**Existing Plan**: Devloop Plan: Unified Issue Tracking System (Complete)
**Relationship**: New work (independent feature)

### Recommended Changes

1. [ ] Create new plan: "Devloop Consistency & Enforcement System"
2. [ ] Phase 1: Foundation (3 tasks)
3. [ ] Phase 2: Worklog System (4 tasks)
4. [ ] Phase 3: Enforcement Hooks (6 tasks)
5. [ ] Phase 4: Recovery & Polish (4 tasks)

Total: ~17 tasks, size L, estimate 1-2 focused sessions
