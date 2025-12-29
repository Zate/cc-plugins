---
name: workflow-router
description: This skill should be used at session start when the user hasn't specified a task, or when the SessionStart hook indicates workflow state that requires routing decisions. Analyzes workflow state and presents appropriate options via AskUserQuestion.
whenToUse: |
  - At session start when no specific task requested
  - When SessionStart hook detects active workflow state
  - When user asks "what should I work on?" or "where was I?"
  - When transitioning between workflow phases (spike→plan, plan→execution)
  - When the user seems uncertain about next steps
whenNotToUse: |
  - User has already specified a clear task
  - User explicitly invoked a /devloop command
  - In the middle of active task execution
  - When running in non-interactive mode (-p flag)
---

# Workflow Router Skill

Smart workflow detection and routing that presents appropriate options based on current state.

## When to Use This Skill

- **Session start**: When no specific task is requested
- **State detected**: When SessionStart hook indicates workflow state
- **User uncertainty**: "What should I work on?", "Where was I?"
- **Phase transitions**: Moving between spike, plan, execution, etc.

## When NOT to Use This Skill

- User has already specified a clear task
- User explicitly invoked a `/devloop:*` command
- In the middle of active task execution
- Non-interactive mode

---

## Core Workflow

The workflow-router skill follows a 3-step process:

```
┌───────────────────────────────────────────────────┐
│  1. DETECT: Gather workflow state                 │
│     → Run detect-workflow-state.sh                │
│     → Parse JSON output                           │
│     → Classify situation                          │
└────────────────────┬──────────────────────────────┘
                     ▼
┌───────────────────────────────────────────────────┐
│  2. PRESENT: Show guided options                  │
│     → Build AskUserQuestion based on situation    │
│     → Present context-aware choices               │
│     → Include recommended action                  │
└────────────────────┬──────────────────────────────┘
                     ▼
┌───────────────────────────────────────────────────┐
│  3. ROUTE: Execute chosen action                  │
│     → Invoke appropriate /devloop command         │
│     → Update workflow state if needed             │
│     → Provide clear next steps                    │
└───────────────────────────────────────────────────┘
```

---

## Step 1: Detect Workflow State

### Primary Detection Method

Use the workflow state detection script:

```bash
Bash: ${CLAUDE_PLUGIN_ROOT}/scripts/detect-workflow-state.sh --json
```

**Expected JSON Output**:
```json
{
  "situation": "active_plan",
  "fresh_start": {
    "status": "none",
    "age_days": 0,
    "plan": "",
    "next_task": ""
  },
  "active_plan": {
    "status": "active",
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
    "topic": "none",
    "age": ""
  },
  "context_usage_pct": 0,
  "recommended_action": "continue"
}
```

### Fallback Detection (if script fails)

If the script is not available or fails, manually check files:

1. **Fresh start state**: Check `.devloop/next-action.json`
2. **Active plan**: Check `.devloop/plan.md` or `.devloop/plan-state.json`
3. **Open issues**: Check `.devloop/issues/` directory
4. **Uncommitted changes**: Run `git status --porcelain`
5. **Recent spikes**: Check `.devloop/spikes/` for files < 24h old

---

## Step 2: Situation Classification

### Priority Order

The detection script classifies into these situations (highest to lowest priority):

| Priority | Situation | Criteria | Auto-Action |
|----------|-----------|----------|-------------|
| 1 | `fresh_start_resume` | `next-action.json` exists, < 7 days old | YES - invoke `/devloop:continue` |
| 2 | `stale_fresh_start` | `next-action.json` exists, > 7 days old | NO - ask user |
| 3 | `active_plan` | Plan has pending tasks | NO - ask user |
| 4 | `complete_plan` | All tasks complete | NO - ask user |
| 5 | `blocked_plan` | All remaining tasks blocked | NO - ask user |
| 6 | `uncommitted_work` | Staged/modified/untracked files | NO - ask user |
| 7 | `high_priority_issues` | Open issues with priority:high | NO - ask user |
| 8 | `open_issues` | Any open issues | NO - ask user |
| 9 | `recent_spike` | Spike < 24h old | NO - ask user |
| 10 | `clean_slate` | None of the above | NO - ask user |

### Context-Aware Checkpoint Pattern

**CRITICAL**: For all situations except `fresh_start_resume`, the workflow-router MUST use the context-aware checkpoint pattern from the ask-user-question-standards skill.

**Pattern**:

```
1. Present situation summary (what was detected)
2. AskUserQuestion with guided options
3. Execute chosen action
4. Confirm action started
```

**Why**: Users should understand why they're seeing options and what the detected state means before choosing.

---

## Step 3: Present Options by Situation

### Situation 1: Fresh Start Resume (Auto-action)

**Detection**:
- `situation: "fresh_start_resume"`
- `fresh_start.status: "valid"`
- `fresh_start.age_days: < 7`

**Action**: IMMEDIATELY invoke `/devloop:continue` without asking.

**Rationale**: Fresh start is an explicit previous decision by the user to save state and resume later. Auto-resuming honors that decision.

**Output**:
```markdown
🔄 **Fresh Start Auto-Resume Detected**

Saved state from {age_days} day(s) ago detected.
Automatically resuming work...

Invoking: `/devloop:continue`
```

---

### Situation 2: Stale Fresh Start

**Detection**:
- `situation: "stale_fresh_start"`
- `fresh_start.status: "stale"`
- `fresh_start.age_days: >= 7`

**Context Summary**:
```markdown
⚠️ **Stale Fresh Start State Detected**

A fresh start state file exists from **{age_days} days ago**.

- Saved plan: {fresh_start.plan}
- Next task: {fresh_start.next_task}
- State file: `.devloop/next-action.json`

This state may be outdated. Choose how to proceed:
```

**Options**:
```yaml
AskUserQuestion:
  question: "How to handle stale fresh start state?"
  header: "Stale State"
  options:
    - label: "Delete and start fresh"
      description: "Clear stale state, work on current plan (Recommended)"
      value: "delete"
    - label: "Resume anyway"
      description: "Attempt to continue from saved state"
      value: "resume"
    - label: "View saved state"
      description: "Show contents before deciding"
      value: "view"
```

**Actions**:
- `delete` → Remove `.devloop/next-action.json`, re-run detection
- `resume` → Invoke `/devloop:continue` (may fail if plan changed)
- `view` → Display next-action.json content, then re-present options

---

### Situation 3: Active Plan

**Detection**:
- `situation: "active_plan"`
- `active_plan.status: "active"`
- `active_plan.total > active_plan.completed`

**Context Summary**:
```markdown
📋 **Active Plan Detected**

Plan: **{active_plan.name}**
Progress: {active_plan.completed}/{active_plan.total} tasks ({percentage}%)
File: `{active_plan.file}`

{pending_count} pending tasks remaining.
```

**Options**:
```yaml
AskUserQuestion:
  question: "How to proceed with active plan?"
  header: "Active Plan"
  options:
    - label: "Continue plan"
      description: "Resume at next pending task (Recommended)"
      value: "continue"
    - label: "View progress"
      description: "Show detailed plan status first"
      value: "status"
    - label: "Fresh start"
      description: "Save state, clear context, resume later"
      value: "fresh"
    - label: "New work"
      description: "Start different work (keep plan for later)"
      value: "new"
```

**Actions**:
- `continue` → Invoke `/devloop:continue`
- `status` → Read and display plan.md, then re-present options
- `fresh` → Invoke `/devloop:fresh`, instruct user to `/clear`
- `new` → Present clean slate options (Situation 10)

---

### Situation 4: Complete Plan

**Detection**:
- `situation: "complete_plan"`
- `active_plan.status: "complete"`
- `active_plan.completed == active_plan.total`

**Context Summary**:
```markdown
✅ **Plan Complete**

Plan: **{active_plan.name}**
All {active_plan.total} tasks complete!

Ready to ship this work?
```

**Options**:
```yaml
AskUserQuestion:
  question: "Plan complete. Next steps?"
  header: "Complete"
  options:
    - label: "Ship it"
      description: "Run validation and create commit/PR (Recommended)"
      value: "ship"
    - label: "Archive plan"
      description: "Compress completed phases, start fresh"
      value: "archive"
    - label: "Review changes"
      description: "See what was done before shipping"
      value: "review"
    - label: "Add more tasks"
      description: "Extend the plan with additional work"
      value: "extend"
```

**Actions**:
- `ship` → Invoke `/devloop:ship`
- `archive` → Invoke `/devloop:archive`
- `review` → Run `git diff HEAD~{commit_count}`, display, re-present
- `extend` → Ask user what to add, append to plan, invoke `/devloop:continue`

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

**Options**:
```yaml
AskUserQuestion:
  question: "All remaining tasks blocked. How to proceed?"
  header: "Blocked"
  options:
    - label: "Review blockers"
      description: "Show blocked tasks and reasons"
      value: "review"
    - label: "Unblock tasks"
      description: "Work on resolving blockers"
      value: "unblock"
    - label: "Skip blockers"
      description: "Mark as skipped, continue with other work"
      value: "skip"
    - label: "Ship partial"
      description: "Ship completed work, defer blocked tasks"
      value: "ship_partial"
```

**Actions**:
- `review` → Grep plan for `[!]` tasks, display with context, re-present
- `unblock` → Ask which blocker to work on, guide user through resolution
- `skip` → Change `[!]` to `[-]` for selected tasks, invoke `/devloop:continue`
- `ship_partial` → Invoke `/devloop:ship` with partial completion

---

### Situation 6: Uncommitted Work

**Detection**:
- `situation: "uncommitted_work"`
- `uncommitted.staged > 0` OR `uncommitted.modified > 0` OR `uncommitted.untracked > 0`

**Context Summary**:
```markdown
📝 **Uncommitted Changes Detected**

- Staged: {uncommitted.staged} files
- Modified: {uncommitted.modified} files
- Untracked: {uncommitted.untracked} files

Commit before continuing?
```

**Options**:
```yaml
AskUserQuestion:
  question: "Handle uncommitted changes?"
  header: "Uncommitted"
  options:
    - label: "Commit now"
      description: "Create commit with conventional message (Recommended)"
      value: "commit"
    - label: "Review changes"
      description: "Show diff before deciding"
      value: "review"
    - label: "Continue anyway"
      description: "Proceed without committing"
      value: "continue"
    - label: "Stash changes"
      description: "Save for later, clean working tree"
      value: "stash"
```

**Actions**:
- `commit` → Generate conventional commit message based on changes, invoke git commit
- `review` → Run `git diff`, display, re-present options
- `continue` → Proceed to next situation (re-run detection ignoring uncommitted)
- `stash` → Run `git stash`, proceed to next situation

---

### Situation 7: High Priority Issues

**Detection**:
- `situation: "high_priority_issues"`
- `open_issues.high_priority > 0`

**Context Summary**:
```markdown
🔥 **High Priority Issues Detected**

- Total open issues: {open_issues.count}
- High priority: {open_issues.high_priority}

Address urgent issues?
```

**Options**:
```yaml
AskUserQuestion:
  question: "Work on high priority issues?"
  header: "Issues"
  options:
    - label: "Fix highest priority"
      description: "Start on most urgent issue (Recommended)"
      value: "fix_high"
    - label: "View all issues"
      description: "List all open issues to pick one"
      value: "view"
    - label: "Different work"
      description: "Address issues later"
      value: "defer"
```

**Actions**:
- `fix_high` → Find first `priority: high` issue, read it, ask user to confirm, start work
- `view` → Invoke `/devloop:issues` to display list
- `defer` → Proceed to next situation (re-run detection ignoring issues)

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

**Options**:
```yaml
AskUserQuestion:
  question: "Handle open issues?"
  header: "Issues"
  options:
    - label: "View issues"
      description: "List all open issues (Recommended)"
      value: "view"
    - label: "Pick one"
      description: "Choose which issue to work on"
      value: "pick"
    - label: "New work"
      description: "Do something else"
      value: "new"
```

**Actions**:
- `view` → Invoke `/devloop:issues`
- `pick` → Invoke `/devloop:issues`, user selects, start work on selected
- `new` → Present clean slate options (Situation 10)

---

### Situation 9: Recent Spike

**Detection**:
- `situation: "recent_spike"`
- `recent_spike.topic != "none"`
- `recent_spike.age < "24h"`

**Context Summary**:
```markdown
🔍 **Recent Spike Report Detected**

Topic: **{recent_spike.topic}**
Created: {recent_spike.age} ago
File: `.devloop/spikes/{recent_spike.topic}.md`

Apply spike findings to a plan?
```

**Options**:
```yaml
AskUserQuestion:
  question: "What to do with spike findings?"
  header: "Spike"
  options:
    - label: "Create plan from spike"
      description: "Seed new plan from recommendations (Recommended)"
      value: "apply"
    - label: "View spike report"
      description: "Read findings first"
      value: "view"
    - label: "Continue spike"
      description: "More investigation needed"
      value: "continue_spike"
    - label: "Different work"
      description: "Findings not relevant now"
      value: "defer"
```

**Actions**:
- `apply` → Read spike report, extract recommendations, invoke `/devloop` with context
- `view` → Read and display spike report, re-present options
- `continue_spike` → Invoke `/devloop:spike {topic}` to continue investigation
- `defer` → Present clean slate options (Situation 10)

---

### Situation 10: Clean Slate

**Detection**:
- `situation: "clean_slate"`
- No other situations detected

**Context Summary**:
```markdown
🆕 **No Active Workflow Detected**

Starting with a clean slate. What would you like to do?
```

**Options**:
```yaml
AskUserQuestion:
  question: "What type of work?"
  header: "Start"
  options:
    - label: "New feature"
      description: "Full feature workflow with planning"
      value: "feature"
    - label: "Quick task"
      description: "Small, well-defined task (< 1 hour)"
      value: "quick"
    - label: "Explore first"
      description: "Investigate feasibility with spike"
      value: "spike"
    - label: "Fix a bug"
      description: "Report and track a bug"
      value: "bug"
    - label: "Something else"
      description: "Describe what you need"
      value: "custom"
```

**Actions**:
- `feature` → Ask for feature description, invoke `/devloop {description}`
- `quick` → Ask for task description, invoke `/devloop:quick {description}`
- `spike` → Ask for topic, invoke `/devloop:spike {topic}`
- `bug` → Invoke `/devloop:bug` to report interactively
- `custom` → Let user describe, interpret intent, route to appropriate command

---

## Step 4: Execute Routing Action

After user selects an option, execute the corresponding action:

### Command Invocation Pattern

```markdown
✓ **{Action Name}**

{Brief explanation of what will happen}

Invoking: `{command}`
```

**Example**:
```markdown
✓ **Continuing Plan**

Resuming work on "Feature: Authentication" at Task 2.5.

Invoking: `/devloop:continue`
```

### State Update (if needed)

For certain actions, update workflow state before invoking command:

**Example: Deleting stale fresh start**:
```bash
Bash: rm .devloop/next-action.json
```

Then confirm:
```markdown
✓ Removed stale state file

Proceeding with current plan...
```

---

## Integration with SessionStart Hook

The SessionStart hook can trigger this skill automatically:

### Hook Output Pattern

**In `session-start.sh`**:
```markdown
**Workflow State Detected**: `active_plan`

If the user hasn't specified a task, consider invoking `Skill: workflow-router` to present options.
The workflow-router skill will:
1. Analyze the current state in detail
2. Present appropriate options via AskUserQuestion
3. Route to the correct command based on user choice
```

### Auto-Invocation Logic

**When to auto-invoke**:
- User hasn't specified a task
- SessionStart detects a non-`clean_slate` situation
- User seems uncertain

**When NOT to auto-invoke**:
- User said "continue" or similar (direct intent)
- User invoked a specific `/devloop:*` command
- User asked a specific question unrelated to workflow

---

## Error Handling

### Script Execution Failure

If `detect-workflow-state.sh` fails:

```markdown
⚠️ **Workflow detection script failed**

Falling back to manual detection...

[Perform manual file checks]
```

### Invalid State Files

If state files are corrupt or invalid:

```markdown
⚠️ **Invalid state file detected: {file}**

Options:
1. Delete and start fresh
2. Attempt manual repair
3. Continue without state file

[Present options via AskUserQuestion]
```

### Command Invocation Failure

If a routed command fails:

```markdown
❌ **Command failed: {command}**

Error: {error_message}

Options:
1. Retry with different approach
2. Investigate error
3. Choose different action

[Present recovery options]
```

---

## Model Selection

This skill is designed for **haiku** execution:

| Phase | Complexity | Model |
|-------|------------|-------|
| Detection | Low (script execution) | haiku |
| Classification | Low (formula-based) | haiku |
| Option presentation | Low (template-based) | haiku |
| Command routing | Low (direct mapping) | haiku |

**Total estimated tokens**: ~5,000 per routing session (well within haiku capabilities)

---

## Examples

### Example 1: Active Plan Routing

**Input**: User starts session, no specific task mentioned

**SessionStart Output**:
```markdown
**Active Plan**: Feature: Authentication (4/10 tasks)
→ Consider `Skill: workflow-router` for guided options.
```

**Agent Action**:
```
1. Invoke Skill: workflow-router
2. Skill runs detect-workflow-state.sh
3. Detects: situation = "active_plan"
4. Presents options via AskUserQuestion
5. User selects "Continue plan"
6. Skill invokes /devloop:continue
```

---

### Example 2: Uncommitted Changes with Active Plan

**Input**: User starts session

**Detection Output**:
```json
{
  "situation": "uncommitted_work",
  "uncommitted": {"staged": 2, "modified": 5, "untracked": 1},
  "active_plan": {"status": "active", "completed": 6, "total": 10}
}
```

**Agent Action**:
```
1. Detects uncommitted_work (higher priority than active_plan)
2. Presents commit options
3. User selects "Commit now"
4. Skill generates conventional commit message
5. Creates commit
6. Re-runs detection
7. Now detects active_plan
8. Presents plan continuation options
```

**Multi-stage routing**: The skill can chain through multiple situations.

---

### Example 3: Fresh Start Auto-Resume

**Input**: User starts session after previous `/devloop:fresh`

**Detection Output**:
```json
{
  "situation": "fresh_start_resume",
  "fresh_start": {
    "status": "valid",
    "age_days": 1,
    "plan": ".devloop/plan.md",
    "next_task": "3.2"
  }
}
```

**Agent Action**:
```
1. Detects fresh_start_resume
2. IMMEDIATELY invokes /devloop:continue (no AskUserQuestion)
3. Continue command reads next-action.json
4. Resumes at Task 3.2
```

**No interaction needed** - fresh start auto-resumes.

---

## Summary

The workflow-router skill provides:

✓ **Smart detection**: Comprehensive state analysis
✓ **Guided choices**: Context-aware options via AskUserQuestion
✓ **Priority-based**: Handles most urgent situations first
✓ **Auto-resume**: Respects explicit previous decisions
✓ **Error recovery**: Graceful fallbacks when detection fails
✓ **Chain routing**: Handles multi-stage scenarios (commit → continue)
✓ **Token efficient**: Designed for haiku execution

**Use this skill** when:
- User starts session without specific intent
- SessionStart hook detects workflow state
- User asks "what should I work on?"
- Transitions between workflow phases needed

**Integration points**:
- `session-start.sh` → Triggers skill invocation
- `detect-workflow-state.sh` → Provides state detection
- `/devloop:*` commands → Execution targets
- `next-action.json` → Fresh start state
- `plan.md` → Active plan tracking

**Key principle**: Present clear, actionable choices based on detected context, then execute the chosen route decisively.
