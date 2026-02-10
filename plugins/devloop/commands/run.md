---
description: Execute plan tasks autonomously until completion
argument-hint: "[--max-iterations N] [--interactive]"
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

# Devloop Run - Autonomous Plan Execution

Execute plan tasks autonomously. **You do the work directly.**

## Step 1: Check Plan State

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md
```

Parse JSON: `complete`, `total`, `done`, `pending`.

**No plan exists:** Display entry points (`/devloop:spike`, `/devloop:from-issue`, `/devloop`). STOP.

**Plan complete (`complete: true`):**
```yaml
AskUserQuestion:
  questions:
    - question: "All tasks done. What next?"
      header: "Complete"
      multiSelect: false
      options:
        - label: "Ship it (Recommended)"
          description: "Commit and optionally create PR"
        - label: "Archive and start new"
          description: "Move completed plan to archive"
        - label: "Review first"
          description: "Review work before shipping"
```
Route: Ship → `/devloop:ship`, Archive → run archive script then `/devloop`, Review → `/devloop:review`. STOP.

**Pending tasks:** Continue to Step 2.

## Step 2: Parse Arguments

Flags in `$ARGUMENTS`:
- `--max-iterations N`: Override 50 iteration limit
- `--interactive`: Prompt at each task
- `--next-issue[=auto]`: Issue-to-ship workflow

Default: **autonomous** (no `--interactive`).

If `--next-issue`: Jump to Step 2b.

## Step 2b: Next Issue Workflow

### 1. Check existing plan
If incomplete plan exists, prompt to replace or cancel.

### 2. Fetch issues
```bash
gh issue list --state open --limit 20 --json number,title,labels,createdAt
```
No issues? Display help and STOP.

### 3. Prioritize
| Priority | Criteria |
|----------|----------|
| 1 | bug, critical, urgent |
| 2 | security |
| 3 | feat, feature, enhancement |
| 4 | Oldest by createdAt |
| 5 | Everything else |

### 4. Confirm or auto-select
`--next-issue`: Prompt confirmation. `--next-issue=auto`: Proceed immediately.

### 5. Create plan from issue
```bash
gh issue view $ISSUE_NUMBER --json number,title,body,labels,url
```

Generate `.devloop/plan.md` with **required frontmatter**:
```yaml
---
title: [Issue title]
issue: [ISSUE_NUMBER]           # REQUIRED for auto-close
issue_url: [Full GitHub URL]
status: In Progress
created: [ISO date]
---
```

### 6. Continue to Step 3

### 7. Post-completion: Validate and ship
Run validation (tests, lint, build). If fails, prompt fix/ship-anyway/stop.

**IMPORTANT:** Commit MUST close the issue:
```bash
git add -A && git commit -m "feat(scope): summary

Closes #${ISSUE_NUMBER}"
```

## Step 3: Check Fresh Start State

```bash
if [ -f ".devloop/next-action.json" ]; then cat .devloop/next-action.json; rm .devloop/next-action.json; fi
```
If exists: Resume from saved state.

## Step 4: Setup Autonomous Mode

Unless `--interactive`, create ralph-loop state:
```bash
mkdir -p .claude && cat > .claude/ralph-loop.local.md <<'EOF'
---
active: true
iteration: 1
max_iterations: ${MAX_ITERATIONS:-50}
completion_promise: "ALL PLAN TASKS COMPLETE"
devloop_integration: true
---
Work on NEXT UNCHECKED task (`- [ ]`). Mark `- [x]` when done.
When ALL complete: <promise>ALL PLAN TASKS COMPLETE</promise>
EOF
```

Display: `Autonomous mode active. Progress: [done]/[total]. Starting...`

## Step 4b: Sync to Native Tasks (Optional)

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/sync-plan-to-tasks.sh" .devloop/plan.md
```

Use `TaskCreate` for pending tasks (subject, description, activeForm). Native tasks show UI progress; plan.md is authoritative.

**Task markers:** `- [ ]` pending, `- [~]` in_progress, `- [x]` completed, `- [!]` blocked.

## Step 5: Execute Tasks

Read plan, find next `- [ ]` task.

**Do the work directly:**
- Write/Edit for code
- Bash for tests and git
- Read/Grep/Glob for files

**Only use agents for:** parallel work, security scans, large exploration (50+ files).

Mark current task `in_progress` via TaskUpdate before starting.

## Step 6: Update Plan After Each Task

1. Mark done: `- [x] Task description`
2. Update native task: `TaskUpdate status: "completed"`
3. Check completion: `"${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md`

**All complete:** Output `<promise>ALL PLAN TASKS COMPLETE</promise>`

**Tasks remain:**
- Autonomous: Continue to next task
- Interactive: Prompt continue/commit/break

## Step 6b: Auto-Commit at Phase Checkpoints

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/parse-local-config.sh" | grep -o '"auto_commit":[^,}]*' | cut -d: -f2
```

If `auto_commit: true` and phase complete:
```bash
git add -A && git commit -m "feat(devloop): complete Phase N - [description]"
```

## Step 7: Handle Completion

```yaml
AskUserQuestion:
  questions:
    - question: "All tasks complete! What next?"
      header: "Done"
      multiSelect: false
      options:
        - label: "Ship it (Recommended)"
          description: "Commit and optionally create PR"
        - label: "Archive"
          description: "Move to archive, start fresh"
        - label: "Review first"
          description: "Review before shipping"
```

## Loop Termination

- All tasks `[x]` AND promise tag output
- Max iterations reached
- `/cancel-ralph`
- Error requiring user input

## Skills (On Demand)

Load when needed: `plan-management`, `git-workflows`, `testing-strategies`, `[language]-patterns`.

## Examples

```bash
/devloop:run                          # Autonomous (default)
/devloop:run --max-iterations 100     # Extended limit
/devloop:run --interactive            # Prompt each task
/devloop:run --next-issue             # Full issue-to-ship
/devloop:run --next-issue=auto        # No confirmation
```

## Migration

- `/devloop:continue` → `/devloop:run --interactive`
- `/devloop:ralph` → `/devloop:run`

---

**Now**: Check plan state and begin execution.
