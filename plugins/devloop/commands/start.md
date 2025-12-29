---
description: Smart workflow entry point - detects context and routes to appropriate devloop command
argument-hint: Optional specific workflow to start
allowed-tools: [
  "Read", "Bash", "AskUserQuestion", "Skill",
  "Bash(${CLAUDE_PLUGIN_ROOT}/scripts/detect-workflow-state.sh:*)",
  "Bash(${CLAUDE_PLUGIN_ROOT}/scripts/workflow-state.sh:*)"
]
---

# Start - Smart Workflow Entry Point

Intelligent workflow detection and routing. Analyzes current project state and guides you to the appropriate devloop workflow.

**Core Reference**: `Skill: workflow-router` - Comprehensive routing logic and situation handling

---

## What This Command Does

`/devloop:start` is your **smart entry point** into devloop workflows. Instead of guessing which command to run, it:

1. **Detects your current context** - Active plans, fresh start state, open issues, uncommitted changes, recent spikes
2. **Presents guided options** - Shows you what's relevant based on what it finds
3. **Routes to the right workflow** - Launches the appropriate `/devloop:*` command

**When to use**:
- Starting a work session (not sure where you left off)
- After cloning a repository with existing devloop state
- When you're unsure which workflow to use
- Resuming after a break

**When NOT to use**:
- You already know which workflow you need (just run that command directly)
- In the middle of active work

---

## Step 1: Detect Workflow State

**Purpose**: Understand current project state to provide intelligent routing.

### 1a: Run Detection Script

Invoke the workflow state detection script:

```bash
Bash: "${CLAUDE_PLUGIN_ROOT}/scripts/detect-workflow-state.sh --json"
```

**Script output** (JSON):
```json
{
  "situation": "active_plan",
  "fresh_start": {
    "status": "valid|stale|none",
    "age_days": 0,
    "plan": ".devloop/plan.md",
    "next_task": "2.1"
  },
  "active_plan": {
    "status": "active|complete|blocked|none",
    "completed": 4,
    "total": 10,
    "name": "Feature: Authentication",
    "file": ".devloop/plan.md"
  },
  "open_issues": {
    "count": 2,
    "high_priority": 1
  },
  "uncommitted": {
    "staged": 0,
    "modified": 3,
    "untracked": 1
  },
  "recent_spike": {
    "topic": "authentication-approach",
    "age": "2h"
  },
  "context_usage_pct": 0,
  "recommended_action": "continue"
}
```

**Fallback Detection** (if script doesn't exist or fails):

If the script is unavailable (older plugin version) or fails, manually detect:

1. **Fresh start state**: Check `.devloop/next-action.json`
   ```bash
   Bash: "test -f .devloop/next-action.json && echo 'exists' || echo 'none'"
   ```

2. **Active plan**: Check `.devloop/plan.md` or `.devloop/plan-state.json`
   ```bash
   Bash: "test -f .devloop/plan.md && grep -c '^\s*-\s*\[' .devloop/plan.md || echo '0'"
   ```

3. **Open issues**: Check `.devloop/issues/` directory
   ```bash
   Bash: "test -d .devloop/issues && find .devloop/issues -name '*.md' -type f | wc -l || echo '0'"
   ```

4. **Uncommitted changes**: Check git status
   ```bash
   Bash: "git status --porcelain | wc -l"
   ```

5. **Recent spikes**: Check `.devloop/spikes/` for files < 24h old
   ```bash
   Bash: "find .devloop/spikes -name '*.md' -type f -mtime -1 2>/dev/null | head -1"
   ```

Build a simplified JSON structure from manual detection results.

---

### 1b: Situation Classification

The detection script classifies into these situations (highest to lowest priority):

| Priority | Situation | Auto-Action? | Routing |
|----------|-----------|--------------|---------|
| 1 | `fresh_start_resume` | YES | `/devloop:continue` |
| 2 | `stale_fresh_start` | NO | Ask user |
| 3 | `active_plan` | NO | Ask user |
| 4 | `complete_plan` | NO | Ask user |
| 5 | `blocked_plan` | NO | Ask user |
| 6 | `uncommitted_work` | NO | Ask user |
| 7 | `high_priority_issues` | NO | Ask user |
| 8 | `open_issues` | NO | Ask user |
| 9 | `recent_spike` | NO | Ask user |
| 10 | `clean_slate` | NO | Ask user |

**Auto-action**: Only `fresh_start_resume` automatically invokes a command without asking. All others present options.

---

## Step 2: Route Based on Situation

### Situation 1: Fresh Start Resume (Auto-action)

**Detection**:
- `situation: "fresh_start_resume"`
- `fresh_start.status: "valid"`
- `fresh_start.age_days: < 7`

**Action**: IMMEDIATELY invoke `/devloop:continue` without user prompt.

**Output**:
```markdown
🔄 **Fresh Start Auto-Resume**

Saved state from {fresh_start.age_days} day(s) ago detected.
Automatically resuming work...

Invoking: `/devloop:continue`
```

**Rationale**: Fresh start is an explicit previous decision to save state and resume later. Auto-resuming honors that decision.

Then **END** - let `/devloop:continue` handle the rest.

---

### Situation 2: Stale Fresh Start

**Detection**:
- `situation: "stale_fresh_start"`
- `fresh_start.status: "stale"`
- `fresh_start.age_days: >= 7`

**Context Summary**:
```markdown
⚠️ **Stale Fresh Start State**

A fresh start state file exists from **{fresh_start.age_days} days ago**.

- Saved plan: {fresh_start.plan}
- Next task: {fresh_start.next_task}
- State file: `.devloop/next-action.json`

This state may be outdated. Choose how to proceed:
```

**Present Options**:
```yaml
AskUserQuestion:
  question: "How to handle stale fresh start state?"
  header: "Stale State"
  options:
    - label: "Delete and start fresh"
      description: "Clear stale state, work on current plan (Recommended)"
    - label: "Resume anyway"
      description: "Attempt to continue from saved state"
    - label: "View saved state"
      description: "Show contents before deciding"
```

**Handle Response**:
- **Delete and start fresh**: Remove `.devloop/next-action.json`, re-run detection (Step 1)
- **Resume anyway**: Invoke `/devloop:continue` (may fail if plan changed)
- **View saved state**: Read and display `next-action.json`, re-present options

---

### Situation 3: Active Plan

**Detection**:
- `situation: "active_plan"`
- `active_plan.status: "active"`
- Pending tasks remain

**Context Summary**:
```markdown
📋 **Active Plan**

Plan: **{active_plan.name}**
Progress: {active_plan.completed}/{active_plan.total} tasks ({percentage}%)
File: `{active_plan.file}`

{pending_count} pending task(s) remaining.
```

**Present Options**:
```yaml
AskUserQuestion:
  question: "How to proceed with active plan?"
  header: "Active Plan"
  options:
    - label: "Continue plan"
      description: "Resume at next pending task (Recommended)"
    - label: "View progress"
      description: "Show detailed plan status first"
    - label: "Fresh start"
      description: "Save state, clear context, resume later"
    - label: "New work"
      description: "Start different work (keep plan for later)"
```

**Handle Response**:
- **Continue plan**: Invoke `/devloop:continue`
- **View progress**: Read and display `plan.md`, re-present options
- **Fresh start**: Invoke `/devloop:fresh`, instruct user to `/clear`
- **New work**: Go to Situation 10 (Clean Slate)

---

### Situation 4: Complete Plan

**Detection**:
- `situation: "complete_plan"`
- `active_plan.status: "complete"`
- All tasks marked `[x]` or `[-]`

**Context Summary**:
```markdown
✅ **Plan Complete**

Plan: **{active_plan.name}**
All {active_plan.total} tasks complete!

Ready to ship this work?
```

**Present Options**:
```yaml
AskUserQuestion:
  question: "Plan complete. Next steps?"
  header: "Complete"
  options:
    - label: "Ship it"
      description: "Run validation and create commit/PR (Recommended)"
    - label: "Archive plan"
      description: "Compress completed phases, start fresh"
    - label: "Review changes"
      description: "See what was done before shipping"
    - label: "Add more tasks"
      description: "Extend the plan with additional work"
```

**Handle Response**:
- **Ship it**: Invoke `/devloop:ship`
- **Archive plan**: Invoke `/devloop:archive`
- **Review changes**: Run `git diff HEAD~{estimate_commits}`, display, re-present
- **Add more tasks**: Ask user what to add, append to plan, invoke `/devloop:continue`

---

### Situation 5: Blocked Plan

**Detection**:
- `situation: "blocked_plan"`
- `active_plan.status: "blocked"`
- All remaining tasks marked `[!]`

**Context Summary**:
```markdown
🚫 **Plan Blocked**

Plan: **{active_plan.name}**
Progress: {active_plan.completed}/{active_plan.total} tasks
All remaining tasks are blocked.

Review blocked tasks to unblock or change approach.
```

**Present Options**:
```yaml
AskUserQuestion:
  question: "All remaining tasks blocked. How to proceed?"
  header: "Blocked"
  options:
    - label: "Review blockers"
      description: "Show blocked tasks and reasons"
    - label: "Unblock tasks"
      description: "Work on resolving blockers"
    - label: "Skip blockers"
      description: "Mark as skipped, continue with other work"
    - label: "Ship partial"
      description: "Ship completed work, defer blocked tasks"
```

**Handle Response**:
- **Review blockers**: Grep plan for `[!]` tasks, display with context, re-present
- **Unblock tasks**: Ask which blocker to work on, guide user through resolution
- **Skip blockers**: Change `[!]` to `[-]` for selected tasks, invoke `/devloop:continue`
- **Ship partial**: Invoke `/devloop:ship` with partial completion warning

---

### Situation 6: Uncommitted Work

**Detection**:
- `situation: "uncommitted_work"`
- `uncommitted.staged > 0` OR `uncommitted.modified > 0` OR `uncommitted.untracked > 0`

**Context Summary**:
```markdown
📝 **Uncommitted Changes**

- Staged: {uncommitted.staged} file(s)
- Modified: {uncommitted.modified} file(s)
- Untracked: {uncommitted.untracked} file(s)

Commit before continuing?
```

**Present Options**:
```yaml
AskUserQuestion:
  question: "Handle uncommitted changes?"
  header: "Uncommitted"
  options:
    - label: "Commit now"
      description: "Create commit with conventional message (Recommended)"
    - label: "Review changes"
      description: "Show diff before deciding"
    - label: "Continue anyway"
      description: "Proceed without committing"
    - label: "Stash changes"
      description: "Save for later, clean working tree"
```

**Handle Response**:
- **Commit now**: Generate conventional commit message, invoke git commit, re-run detection
- **Review changes**: Run `git diff`, display, re-present options
- **Continue anyway**: Ignore uncommitted, re-run detection (will detect next situation)
- **Stash changes**: Run `git stash`, re-run detection

---

### Situation 7: High Priority Issues

**Detection**:
- `situation: "high_priority_issues"`
- `open_issues.high_priority > 0`

**Context Summary**:
```markdown
🔥 **High Priority Issues**

- Total open issues: {open_issues.count}
- High priority: {open_issues.high_priority}

Address urgent issues?
```

**Present Options**:
```yaml
AskUserQuestion:
  question: "Work on high priority issues?"
  header: "Issues"
  options:
    - label: "Fix highest priority"
      description: "Start on most urgent issue (Recommended)"
    - label: "View all issues"
      description: "List all open issues to pick one"
    - label: "Different work"
      description: "Address issues later"
```

**Handle Response**:
- **Fix highest priority**: Find first `priority: high` issue, read it, confirm with user, start work
- **View all issues**: Invoke `/devloop:issues`
- **Different work**: Ignore issues, re-run detection (will detect next situation)

---

### Situation 8: Open Issues

**Detection**:
- `situation: "open_issues"`
- `open_issues.count > 0`

**Context Summary**:
```markdown
📌 **Open Issues Tracked**

{open_issues.count} open issue(s) in `.devloop/issues/`.

Work on tracked issues?
```

**Present Options**:
```yaml
AskUserQuestion:
  question: "Handle open issues?"
  header: "Issues"
  options:
    - label: "View issues"
      description: "List all open issues (Recommended)"
    - label: "Pick one"
      description: "Choose which issue to work on"
    - label: "New work"
      description: "Do something else"
```

**Handle Response**:
- **View issues**: Invoke `/devloop:issues`
- **Pick one**: Invoke `/devloop:issues` with selection flow
- **New work**: Go to Situation 10 (Clean Slate)

---

### Situation 9: Recent Spike

**Detection**:
- `situation: "recent_spike"`
- `recent_spike.topic != "none"`
- `recent_spike.age < "24h"`

**Context Summary**:
```markdown
🔍 **Recent Spike Report**

Topic: **{recent_spike.topic}**
Created: {recent_spike.age} ago
File: `.devloop/spikes/{recent_spike.topic}.md`

Apply spike findings to a plan?
```

**Present Options**:
```yaml
AskUserQuestion:
  question: "What to do with spike findings?"
  header: "Spike"
  options:
    - label: "Create plan from spike"
      description: "Seed new plan from recommendations (Recommended)"
    - label: "View spike report"
      description: "Read findings first"
    - label: "Continue spike"
      description: "More investigation needed"
    - label: "Different work"
      description: "Findings not relevant now"
```

**Handle Response**:
- **Create plan from spike**: Read spike report, extract recommendations, invoke `/devloop` with context
- **View spike report**: Read and display spike report, re-present options
- **Continue spike**: Invoke `/devloop:spike {topic}` to continue investigation
- **Different work**: Ignore spike, go to Situation 10 (Clean Slate)

---

### Situation 10: Clean Slate

**Detection**:
- `situation: "clean_slate"`
- No other situations detected

**Context Summary**:
```markdown
🆕 **Clean Slate**

No active workflow detected. What would you like to do?
```

**Present Options**:
```yaml
AskUserQuestion:
  question: "What type of work?"
  header: "Start"
  options:
    - label: "New feature"
      description: "Full feature workflow with planning"
    - label: "Quick task"
      description: "Small, well-defined task (< 1 hour)"
    - label: "Explore first"
      description: "Investigate feasibility with spike"
    - label: "Fix a bug"
      description: "Report and track a bug"
    - label: "Something else"
      description: "Describe what you need"
```

**Handle Response**:
- **New feature**: Ask for feature description, invoke `/devloop {description}`
- **Quick task**: Ask for task description, invoke `/devloop:quick {description}`
- **Explore first**: Ask for topic, invoke `/devloop:spike {topic}`
- **Fix a bug**: Invoke `/devloop:bug` for interactive bug reporting
- **Something else**: Let user describe, interpret intent, route to appropriate command

---

## Step 3: Command Invocation Pattern

After user selects an option, confirm and invoke the appropriate command:

**Invocation Template**:
```markdown
✓ **{Action Name}**

{Brief explanation of what will happen}

Invoking: `{command}`
```

**Example**:
```markdown
✓ **Continuing Plan**

Resuming work on "Feature: Authentication" at next pending task.

Invoking: `/devloop:continue`
```

**Then END** - let the invoked command handle the rest.

---

## Step 4: Workflow State Integration

### Initialize Workflow State (Optional Enhancement)

If `workflow.json` doesn't exist and this is a new workflow, optionally initialize it:

```bash
Bash: "${CLAUDE_PLUGIN_ROOT}/scripts/workflow-state.sh --init .devloop/plan.md"
```

**When to initialize**:
- Situation is NOT `fresh_start_resume` (already has state)
- User chose to start new work (feature, quick, spike)
- `workflow.json` doesn't exist yet

**Skip initialization if**:
- `workflow.json` already exists
- User chose to view/review (read-only action)
- Older plugin version (script doesn't exist)

**Backward compatibility**: If script fails or doesn't exist, continue without workflow.json. The system works without it.

---

## Error Handling

### Detection Script Failure

If `detect-workflow-state.sh` fails or doesn't exist:

```markdown
⚠️ **Workflow detection unavailable**

Falling back to basic detection...

[Perform manual file checks per Step 1a Fallback]
```

Continue with manual detection - don't fail the command.

---

### Invalid State Files

If state files are corrupt or invalid:

```markdown
⚠️ **Invalid state file: {file}**

Options:
1. Delete and start fresh
2. Attempt to view/repair
3. Continue without state

[Present options via AskUserQuestion]
```

---

### Command Invocation Failure

If a routed command fails:

```markdown
❌ **Command failed: {command}**

Error: {error_message}

[Present recovery options or suggest manual invocation]
```

---

## Integration Points

### Session Start Hook

The SessionStart hook can suggest this command when state is detected:

**Hook output pattern**:
```markdown
**Workflow State Detected**: `{situation}`

Consider `/devloop:start` for guided routing options.
```

### Workflow Router Skill

This command is a **lightweight wrapper** around `Skill: workflow-router`:

- **start.md**: Command entry point, runs detection, handles basic routing
- **workflow-router skill**: Comprehensive routing logic, used by other agents

**When to invoke the skill**: If this command becomes complex or needs to be called by other agents, delegate to `Skill: workflow-router`.

---

## Tips

- Run `/devloop:start` when you're **not sure what to do next**
- It's **safe to run repeatedly** - it just detects and guides
- Fresh starts **auto-resume** - no need to remember where you left off
- If you know what you want, **skip this** and run the command directly
- Detection is **fast** - haiku-compatible, uses scripts for deterministic checks

---

## Examples

### Example 1: Active Plan Auto-Continue

**Scenario**: User starts session with active plan at 4/10 tasks.

**Command Output**:
```markdown
📋 **Active Plan**

Plan: **Feature: Authentication**
Progress: 4/10 tasks (40%)
File: `.devloop/plan.md`

6 pending task(s) remaining.

[Presents options]

User selects: "Continue plan"

✓ **Continuing Plan**

Resuming work on "Feature: Authentication" at Task 2.1.

Invoking: `/devloop:continue`
```

---

### Example 2: Fresh Start Auto-Resume

**Scenario**: User starts session 1 day after `/devloop:fresh`.

**Command Output**:
```markdown
🔄 **Fresh Start Auto-Resume**

Saved state from 1 day(s) ago detected.
Automatically resuming work...

Invoking: `/devloop:continue`
```

**No user interaction needed** - respects previous fresh start decision.

---

### Example 3: Clean Slate New Feature

**Scenario**: User starts session in clean repository.

**Command Output**:
```markdown
🆕 **Clean Slate**

No active workflow detected. What would you like to do?

[Presents options]

User selects: "New feature"

User provides: "Add OAuth login support"

✓ **Starting Feature Workflow**

Launching full feature development workflow for "Add OAuth login support".

Invoking: `/devloop Add OAuth login support`
```

---

### Example 4: Multi-Stage Routing (Uncommitted → Active Plan)

**Scenario**: User has uncommitted changes AND active plan.

**Command Output**:
```markdown
📝 **Uncommitted Changes**

- Staged: 0 file(s)
- Modified: 3 file(s)
- Untracked: 1 file(s)

Commit before continuing?

[Presents commit options]

User selects: "Commit now"

✓ **Creating Commit**

Generating conventional commit message...
[Creates commit]

[Re-runs detection]

📋 **Active Plan**

Plan: **Feature: Authentication**
Progress: 5/10 tasks (50%)

[Presents continue options]

User selects: "Continue plan"

✓ **Continuing Plan**

Invoking: `/devloop:continue`
```

**Chain routing** - handles multi-stage scenarios.

---

## See Also

- **`Skill: workflow-router`** - Comprehensive routing logic this command uses
- **`/devloop:continue`** - Resume from existing plan
- **`/devloop:fresh`** - Save state and clear context
- **`/devloop`** - Full feature workflow
- **`/devloop:spike`** - Exploratory workflow
- **`/devloop:issues`** - Issue tracking
- **`scripts/detect-workflow-state.sh`** - Detection script
- **`scripts/workflow-state.sh`** - State management script
