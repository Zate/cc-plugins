---
description: Start development workflow - lightweight entry point
argument-hint: Optional task description
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - Task
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - TaskList
  - Skill
---

# Devloop - Smart Development Workflow

The main entry point for devloop. Detects your current state and suggests the most relevant actions. **You do the work directly.**

## Step 1: Detect State

Run the state detection script:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-devloop-state.sh"
```

Parse the JSON output:
- `state`: Current state identifier
- `priority`: 1-7 (lower = more urgent)
- `details`: State-specific information
- `suggestions`: Recommended actions

## Step 2: Display Status and Options

Based on detected state, display status and present contextual options:

### State: `not_setup` (Priority 1)

```
Devloop not set up in this project.

The .devloop/ directory doesn't exist yet.
```

```yaml
AskUserQuestion:
  questions:
    - question: "What would you like to do?"
      header: "Setup"
      multiSelect: false
      options:
        - label: "Start a spike (Recommended)"
          description: "Explore and plan before implementing"
        - label: "Quick task"
          description: "Small, well-defined fix or change"
        - label: "Create from GitHub issue"
          description: "Start work from an existing issue"
```

**Routing:**
- "Start a spike" → `/devloop:spike $ARGUMENTS`
- "Quick task" → `/devloop:quick $ARGUMENTS`
- "Create from GitHub issue" → `/devloop:issues`

### State: `active_plan` (Priority 2)

Display plan status from details:

```
Active Plan: [plan_title]
Progress: [done]/[total] tasks ([pending] remaining)
Next: [next_task]
```

```yaml
AskUserQuestion:
  questions:
    - question: "What would you like to do?"
      header: "Action"
      multiSelect: false
      options:
        - label: "Continue working (Recommended)"
          description: "Pick up where you left off"
        - label: "Ship progress"
          description: "Commit and optionally create PR"
        - label: "View full plan"
          description: "Review the complete plan"
        - label: "Start fresh"
          description: "Archive current plan and start new"
```

**Routing:**
- "Continue working" → `/devloop:continue`
- "Ship progress" → `/devloop:ship`
- "View full plan" → Display `.devloop/plan.md` content
- "Start fresh" → Archive then `/devloop:spike` or ask what to do

### State: `uncommitted` (Priority 3)

```
Uncommitted Changes Detected
[total_changes] files changed ([staged] staged, [unstaged] unstaged)
```

```yaml
AskUserQuestion:
  questions:
    - question: "You have uncommitted changes. What would you like to do?"
      header: "Git"
      multiSelect: false
      options:
        - label: "Commit changes (Recommended)"
          description: "Create a commit with current changes"
        - label: "Review changes"
          description: "See what's changed before committing"
        - label: "Continue without committing"
          description: "Start new work, keep changes staged"
        - label: "Stash changes"
          description: "Save changes for later"
```

**Routing:**
- "Commit changes" → `/devloop:ship`
- "Review changes" → Run `git diff --stat` then `git diff`
- "Continue without committing" → Proceed with $ARGUMENTS or ask
- "Stash changes" → Run `git stash push -m "devloop: work in progress"`

### State: `open_bugs` (Priority 4)

```
Open Bugs: [bug_count]
```

```yaml
AskUserQuestion:
  questions:
    - question: "[bug_count] open bug(s) found. What would you like to do?"
      header: "Bugs"
      multiSelect: false
      options:
        - label: "Fix a bug"
          description: "View and work on open bugs"
        - label: "Start new feature"
          description: "Work on something new instead"
        - label: "Create spike"
          description: "Research or explore an idea"
```

**Routing:**
- "Fix a bug" → List bugs from `.devloop/issues/` then create plan
- "Start new feature" → Ask for details, create plan
- "Create spike" → `/devloop:spike`

### State: `backlog` (Priority 5)

```
Backlog: [feature_count] feature(s) waiting
```

```yaml
AskUserQuestion:
  questions:
    - question: "[feature_count] item(s) in backlog. What would you like to do?"
      header: "Backlog"
      multiSelect: false
      options:
        - label: "Work on backlog item"
          description: "Pick from existing features/tasks"
        - label: "Start new spike"
          description: "Research or explore an idea"
        - label: "Quick task"
          description: "Small, well-defined fix"
```

**Routing:**
- "Work on backlog item" → List items then create plan
- "Start new spike" → `/devloop:spike`
- "Quick task" → `/devloop:quick`

### State: `complete_plan` (Priority 6)

```
Plan Complete: [plan_title]
All [total] tasks finished!
```

```yaml
AskUserQuestion:
  questions:
    - question: "Plan is complete. What would you like to do?"
      header: "Complete"
      multiSelect: false
      options:
        - label: "Ship it (Recommended)"
          description: "Commit and optionally create PR"
        - label: "Archive and start new"
          description: "Move to archive, begin fresh"
        - label: "Review before shipping"
          description: "Look over the work one more time"
```

**Routing:**
- "Ship it" → `/devloop:ship`
- "Archive and start new" → Archive then ask what's next
- "Review before shipping" → `/devloop:review`

### State: `clean` (Priority 7)

```
Ready for new work!
No active plans or pending changes.
```

```yaml
AskUserQuestion:
  questions:
    - question: "What would you like to work on?"
      header: "Start"
      multiSelect: false
      options:
        - label: "Create a plan (Recommended)"
          description: "Autonomous exploration → actionable plan"
        - label: "Start a spike"
          description: "Deep exploration without immediate action"
        - label: "GitHub issues"
          description: "View and work from GitHub issues"
        - label: "Quick task"
          description: "Small, well-defined fix"
```

**Routing:**
- "Create a plan" → `/devloop:plan`
- "Start a spike" → `/devloop:spike`
- "GitHub issues" → `/devloop:issues`
- "Quick task" → `/devloop:quick`

## Step 3: Handle Arguments

If `$ARGUMENTS` is provided and non-empty:
- Skip state display
- Use arguments as task description
- Route appropriately based on state:
  - `active_plan` → Ask: continue plan or start new with this task?
  - Other states → Create new plan/spike with the description

## Key Principles

1. **You (Claude) do the work** - Don't spawn subagents for tasks you can do yourself
2. **Skills on demand** - Load with `Skill: skill-name` only when needed
3. **Minimal questions** - One question at a time, not multi-part interrogations
4. **Fast iteration** - Ship working code, then improve

## Workflow Commands

| Command | Purpose |
|---------|---------|
| `/devloop` | Smart entry point (this command) |
| `/devloop:plan` | Autonomous exploration → actionable plan |
| `/devloop:run` | Execute plan autonomously |
| `/devloop:spike` | Deep exploration (detailed reports) |
| `/devloop:fresh` | Save state and exit cleanly |
| `/devloop:quick` | Small, well-defined fixes |
| `/devloop:new` | Create local issue |
| `/devloop:issues` | List GitHub issues |
| `/devloop:review` | Code review |
| `/devloop:ship` | Commit and/or PR |

## Files

- `.devloop/plan.md` - Current task plan
- `.devloop/local.md` - Project settings (git workflow, etc.)
- `.devloop/next-action.json` - Fresh start state
- `.devloop/issues/` - Local issue tracker
- `.devloop/spikes/` - Spike reports

---

**Now**: Detect state and present options.
