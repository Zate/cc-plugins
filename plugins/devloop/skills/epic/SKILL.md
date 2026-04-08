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

Create a multi-phase epic plan. Produces two files: `epic.md` (the full plan) and `epic.json` (the state machine for execution). **Do the work directly.**

**Bash hygiene**: prefer quiet flags to minimize output.

## Step 1: Parse Input
Extract topic from `$ARGUMENTS`. If missing, show usage: `/devloop:epic <topic> [--phases N] [--no-tdd]`.
- `--phases N`: Target phase count (default: auto-detect based on complexity).
- `--no-tdd`: Skip TDD structure (no test-first tasks).

## Step 2: Check Existing Epic
If `.devloop/epic.json` exists:
- Read it. If `status` is `"complete"`: archive both files to `.devloop/archive/`. Continue.
- If `status` is `"in_progress"`: Report progress. **AskUserQuestion**: "Archive and replace" or "Cancel".
- If no epic: Continue.

## Step 3: Context Detection (Silent)
Run `${CLAUDE_PLUGIN_ROOT}/scripts/check-devloop-state.sh`. Detect tech stack from `CLAUDE.md`.

## Step 4: Exploration (Silent)
1. **Search**: Grep keywords, Glob patterns related to the topic.
2. **Read**: 5-10 key files to understand scope.
3. **Assess**: Complexity, affected areas, testing infrastructure.

## Step 5: Requirements Gathering

Present what you learned from exploration, then ask the user to define the epic scope.

### 5a. End State
**AskUserQuestion**: "What does 'done' look like for this epic? Describe the end state -- what should the user/system be able to do when all phases are complete?"

Use their answer to define the epic's completion criteria and scope boundaries.

### 5b. User Stories
Based on their end state description, draft 3-6 user stories in this format:
```
As a [role], I want to [action], so that [benefit].
```

Present them and **AskUserQuestion**: "Here are the user stories I've identified. Add, remove, or modify any of these? (Or say 'looks good' to continue.)"

These user stories drive test design:
- Each story maps to at least one E2E/integration test
- Story acceptance criteria become unit test assertions
- Stories help sequence phases (foundational stories first)

### 5c. Priorities & Constraints (optional)
If the epic has more than 6 phases worth of scope, **AskUserQuestion**: "Any priorities or constraints I should know about? For example: must-have vs nice-to-have phases, performance targets, compatibility requirements, things to avoid."

Skip this question for smaller epics (6 phases or fewer) -- just note any obvious constraints from exploration.

## Step 6: Epic Generation

### 6a. Write `.devloop/epic.md`

Full human-readable plan. Include the user stories as a section -- they serve as the testing north star.

```markdown
# Epic: [Feature Name]

**Created**: YYYY-MM-DD
**Status**: Planning

## Overview

Brief description of the epic scope.

## End State

[User's description of what "done" looks like]

## User Stories

- As a [role], I want to [action], so that [benefit].
  - Acceptance: [criteria -- these become test assertions]
- ...

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

#### Implementation (make tests pass)
- [ ] Task 1.3: Implement X [model:sonnet] [depends:1.1]
  - Acceptance: Test 1.1 passes
  - Files: `path/to/source`

---

### Phase 2: [Phase Name]
...

## Completion Criteria

Each phase is **done** when:
1. All tests pass (unit + E2E)
2. No regressions -- all prior tests still pass
3. Changes are committed
```

### 6b. Write `.devloop/epic.json`

State machine for execution:

```json
{
  "title": "Feature Name",
  "created": "YYYY-MM-DD",
  "status": "planning",
  "current_phase": 1,
  "test_command": "npm test",
  "end_state": "User's description of done",
  "user_stories": [
    "As a [role], I want to [action], so that [benefit]"
  ],
  "phases": [
    {
      "number": 1,
      "name": "Phase Name",
      "status": "pending",
      "tasks": 7,
      "committed": null
    }
  ]
}
```

**Detect `test_command`** from the project:
- `package.json` with vitest/jest -> `npm test`
- `Makefile` with `test` target -> `make test`
- `go.mod` -> `go test ./...`
- `pytest.ini` / `pyproject.toml` -> `pytest`
- Fallback: `null` (skip test validation)

### TDD Structure Rules (default, skip with `--no-tdd`)
Each phase contains two sections:
1. **Tests (write first)**: Test tasks with `[parallel:A]` and `[model:haiku]`. These should all fail initially.
2. **Implementation (make tests pass)**: Implementation tasks with `[depends:N.M]` linking to their test task. Use `[model:sonnet]` for complex work, `[model:haiku]` for simple.

### Connecting User Stories to Tests
- Each user story from Step 5b should map to at least one test task
- E2E tests validate the full user story ("As a user, I want to X" -> Playwright/Cypress test that does X)
- Component/unit tests validate acceptance criteria within the story
- Reference the story in test task descriptions: "Write E2E test for story: [user can filter inventory by type]"
- Stories that span multiple phases: test the phase's portion, with a note that the full story completes in a later phase

### Phase Sizing Guidelines
- 5-8 tasks per phase (including tests + implementation)
- Each phase should be completable in one subagent session
- Group related functionality into the same phase
- Order phases by dependency: foundational stories first, polish last
- Each phase should deliver at least one complete user story when possible

## Step 7: Promote Phase 1 to plan.md
Run `${CLAUDE_PLUGIN_ROOT}/scripts/promote-phase.sh` to copy Phase 1 into `.devloop/plan.md`.
Update `epic.json`: set `status` to `"in_progress"`, phase 1 status to `"in_progress"`.

## Step 8: Review Checkpoint
Display summary: phase count, total tasks, TDD structure, test command detected.
**AskUserQuestion**:
- **Run now**: Invoke `/devloop:run-epic` to begin execution.
- **Review epic**: Show the full epic.md content.
- **Stop here**: "Epic planned. Run `/devloop:run-epic` when ready."

---
**Now**: Parse input and begin.
