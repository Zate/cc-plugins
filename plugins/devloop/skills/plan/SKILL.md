---
name: plan
description: Create a devloop workflow plan with autonomous exploration and task breakdown
argument-hint: <topic> [--deep|--quick|--from-issue N]
when_to_use: "Initial project setup, starting new features, designing bug fixes, architectural spikes"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - Agent
  - AskUserQuestion
  - WebSearch
  - WebFetch
  - TaskCreate
  - TaskUpdate
  - TaskList
---

# Devloop Plan

Create actionable plan from topic. **Do the work directly.**

**Bash hygiene**: prefer quiet flags to minimize output (`npm install --silent`, `git status -sb`, pipe long output through `| tail -n 20`).

## Step 1: Parse Input
Extract topic from `$ARGUMENTS`. If missing, show usage: `/devloop:plan <topic> [--deep|--quick|--from-issue N]`.
If `--from-issue N`: Fetch with `gh issue view $N --json number,title,body,url`. Use title as topic, body as context.

## Step 2: Check Existing Plan (Silent)
If `.devloop/plan.md` exists:
1. Count tasks (no file read needed):
   ```bash
   done=$(grep -cE "^\s*- \[x\]" .devloop/plan.md 2>/dev/null || echo 0)
   total=$(grep -cE "^\s*- \[[ x~!-]\]" .devloop/plan.md 2>/dev/null || echo 0)
   ```
2. If `done == total` and `total > 0`: auto-archive silently:
   ```bash
   "${CLAUDE_PLUGIN_ROOT}/scripts/archive-plan.sh" .devloop/plan.md --force
   ```
3. If incomplete (`done < total`): prompt to archive (force) or cancel.
4. If no plan file or `total == 0`: continue to Step 3.

## Step 3: Route by Mode

### If `--quick`: Fast Path
Use for bug fixes with known cause or small additions.
1. Create todo list (2-4 tasks).
2. If too complex, suggest removing `--quick`.
3. Implement directly: Read (3-5 files), Write/Edit, test, summarize.
4. **STOP** after completion.

### If `--deep`: Comprehensive Exploration
Use for unclear requirements or architectural changes.
1. **Define Scope**: Detect spike type (Tech decision, New feature, Risk, etc.). 
2. **AskUserQuestion**: User selects aspects (Feasibility, Scope, Risk, Dependencies, Approach, Effort, Impact).
3. **Research**: Explore 8-10 files.
4. **Evaluate**: Provide verdict per aspect (Confidence, Blockers, Size, Hours/Days).
5. **Write Report**: Save to `.devloop/spikes/{topic}.md`.
6. **Display Summary**: Show direct answer, recommendation, and findings.
7. **Proceed to Step 4**.

### Default Mode: Autonomous Planning (Steps 4-7)

## Step 4: Context Detection (Silent)
Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-devloop-state.sh`. Detect tech stack and patterns from `CLAUDE.md`.

## Step 5: Exploration (Silent)
1. **Search**: Grep keywords, Glob patterns.
2. **Read**: 3-5 files (Standard) or 8-10 (Deep).
3. **Assess**: Affected files, dependencies, complexity (XS-XL), and risks.

## Step 6: Plan Generation (Silent)
Create `.devloop/plan.md` with: Overview, Approach, Considerations, and Phased Tasks.
**Tasks**: Phased, specific, actionable, testable. (XS: 2-3 tasks, XL: 8-12 tasks).

### Model Annotations
Annotate each task with a model hint based on complexity:
- `[model:haiku]` — Simple/mechanical: writing tests from existing patterns, documentation, formatting, linting, config changes, file renames
- `[model:sonnet]` — Complex reasoning: architecture, debugging, multi-file refactoring, security, performance optimization
- No annotation — Inline by orchestrator: single-line edits, running commands, status checks

### Parallel Groups
Identify tasks that can execute concurrently and assign `[parallel:X]` groups:
- Tasks modifying different files with no data dependency → same parallel group
- Within a phase, default to looking for parallelism
- Add `[depends:N.M]` for tasks that require prior task output

## Step 7: Review Checkpoint
Display Summary: Complexity, Task/Phase count, Key files, and Approach.
**AskUserQuestion**:
- **Save and start**: Write plan, begin `/devloop:run`.
- **Save only**: Write plan, display path.
- **Show full plan**: Review before saving.

---
**Now**: Parse input and begin.
