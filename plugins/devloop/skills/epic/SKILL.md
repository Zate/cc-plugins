---
name: epic
description: Create a multi-phase epic plan with TDD structure for large features
argument-hint: <topic> [--phases N] [--no-tdd]
when_to_use: "Large features spanning multiple phases, multi-session work, TDD-driven development"
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

# Devloop Epic

Create a multi-phase epic plan with TDD structure. **Do the work directly.**

**Bash hygiene**: prefer quiet flags to minimize output.

## Step 1: Parse Input
Extract topic from `$ARGUMENTS`. If missing, show usage: `/devloop:epic <topic> [--phases N] [--no-tdd]`.
- `--phases N`: Target phase count (default: auto-detect based on complexity).
- `--no-tdd`: Skip TDD structure (no test-first tasks).

## Step 2: Check Existing Epic
Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-epic-state.sh`.
- **All complete**: Auto-archive (move to `.devloop/archive/`). Continue.
- **In progress**: Report status. **AskUserQuestion**: "Archive and replace" or "Cancel".
- **No epic**: Continue.

## Step 3: Context Detection (Silent)
Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-devloop-state.sh`. Detect tech stack from `CLAUDE.md`.

## Step 4: Exploration (Silent)
1. **Search**: Grep keywords, Glob patterns related to the topic.
2. **Read**: 5-10 key files to understand scope.
3. **Assess**: Complexity, affected areas, testing infrastructure.

## Step 5: Epic Generation (Silent)
Create `.devloop/epic.md` with this structure:

```markdown
# Epic: [Feature Name]

**Created**: YYYY-MM-DD
**Updated**: YYYY-MM-DD
**Status**: Planning
**Current Phase**: 1

## Overview

Brief description of the epic scope.

## Phase Tracker

| Phase | Name | Tasks | Status |
|-------|------|-------|--------|
| 1 | ... | N | `pending` |
| 2 | ... | N | `pending` |

---

### Phase 1: [Phase Name]

**Goal**: What this phase achieves.

#### Tests (write first -- all should fail)
- [ ] Task 1.1: Write test for X [model:haiku] [parallel:A]
  - Acceptance: Test exists and fails
  - Files: `path/to/test`
- [ ] Task 1.2: Write test for Y [model:haiku] [parallel:A]
  - Acceptance: Test exists and fails
  - Files: `path/to/test`

#### Implementation (make tests pass)
- [ ] Task 1.3: Implement X [model:sonnet] [depends:1.1]
  - Acceptance: Test 1.1 passes
  - Files: `path/to/source`
- [ ] Task 1.4: Implement Y [model:haiku] [depends:1.2]
  - Acceptance: Test 1.2 passes
  - Files: `path/to/source`

---

### Phase 2: [Phase Name]
...

## Completion Criteria

Each phase is **done** when:
1. All tests pass (unit + E2E)
2. No regressions -- all prior tests still pass
3. Changes are committed
4. Phase status in tracker is updated to `complete`
```

### TDD Structure Rules (default, skip with `--no-tdd`)
Each phase contains two sections:
1. **Tests (write first)**: Test tasks with `[parallel:A]` and `[model:haiku]`. These should all fail initially.
2. **Implementation (make tests pass)**: Implementation tasks with `[depends:N.M]` linking to their test task. Use `[model:sonnet]` for complex work, `[model:haiku]` for simple.

### Phase Sizing Guidelines
- 5-8 tasks per phase (including tests + implementation)
- Each phase should be completable in one `/devloop:run` session
- Group related functionality into the same phase
- Order phases by dependency: foundations first, polish last

### Model Annotations
Same rules as `/devloop:plan`:
- `[model:haiku]` -- Tests, docs, simple implementation, config
- `[model:sonnet]` -- Architecture, complex logic, multi-file coordination
- No annotation -- Inline by orchestrator

## Step 6: Review Checkpoint
Display summary: phase count, total tasks, TDD structure.
**AskUserQuestion**:
- **Save and promote Phase 1**: Write epic, promote Phase 1 to plan.md, start run.
- **Save only**: Write epic, show path.
- **Show full epic**: Review before saving.

## Step 7: Auto-promote Phase 1
If user chose "Save and promote":
1. Write `.devloop/epic.md`.
2. Run `${CLAUDE_PLUGIN_ROOT}/scripts/promote-phase.sh` to copy Phase 1 into plan.md.
3. Invoke `/devloop:run` to begin execution.

---
**Now**: Parse input and begin.
