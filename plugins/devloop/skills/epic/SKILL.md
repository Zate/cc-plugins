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

## Step 3: Explore & Ask in Parallel

Launch exploration in the background while starting the conversation with the user. This avoids dead time -- the user talks while the agent reads.

### 3a. Launch Background Explorer
Spawn an Agent with `run_in_background: true`:
```yaml
Agent:
  subagent_type: "Explore"
  run_in_background: true
  description: "Explore codebase for epic"
  prompt: |
    Explore this codebase for context on: [topic]
    1. Run check-devloop-state.sh for tech stack detection
    2. Grep/Glob for keywords related to the topic
    3. Read 5-10 relevant files (source, tests, configs)
    4. Report: tech stack, testing framework, affected areas, existing patterns,
       file structure, and any obvious complexity or risks.
```

### 3b. While Explorer Runs -- Ask End State
**AskUserQuestion**: "What does 'done' look like for this epic? Describe the end state -- what should the user/system be able to do when all phases are complete?"

Use their answer to define the epic's completion criteria and scope boundaries.

## Step 4: User Stories

Based on their end state and what you already know about the topic, draft 3-6 user stories:
```
As a [role], I want to [action], so that [benefit].
  - Acceptance: [measurable criteria]
```

Present them and **AskUserQuestion**: "Here are the user stories I've identified. Add, remove, or modify any of these? (Or say 'looks good' to continue.)"

These user stories drive test design:
- Each story maps to at least one E2E/integration test
- Story acceptance criteria become unit test assertions
- Stories help sequence phases (foundational stories first)

## Step 5: Threat Model & Gap Analysis

By now the background explorer should have returned. Combine what you learned from exploration with the user's end state and stories.

### 5a. Identify
From the user stories and codebase context, extract:
- **Invariants**: Things that must always be true (e.g. "a reclaimer can only be on one raid at a time")
- **Non-negotiables**: Hard requirements the user stated or that the codebase implies (e.g. "all API calls must be authenticated")
- **Negative use cases**: Things the system must NOT do (e.g. "user cannot equip items belonging to another player")
- **Edge cases**: Boundary conditions worth testing (e.g. "empty inventory", "max items reached", "concurrent requests")
- **Gaps**: User stories that are missing coverage, unclear acceptance criteria, or assumptions that need validating

### 5b. Present & Validate
Present the findings grouped by category and **AskUserQuestion**: "Here's what I've identified as invariants, rules, edge cases, and potential gaps. Anything to add, correct, or flag as out of scope?"

These feed directly into test design:
- Invariants become assertion checks in unit tests
- Negative use cases become explicit "should NOT" test cases
- Edge cases become boundary tests
- Gaps get addressed in the plan or flagged as known limitations

### 5c. Priorities & Constraints (optional)
If the epic has more than 6 phases worth of scope, **AskUserQuestion**: "Any priorities or constraints? Must-have vs nice-to-have phases, performance targets, compatibility requirements, things to avoid."

Skip for smaller epics -- just note obvious constraints.

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

## Invariants & Rules

- **Invariant**: [thing that must always be true]
- **Non-negotiable**: [hard requirement]
- **Must NOT**: [negative use case -- what the system must never do]
- **Edge case**: [boundary condition to test]

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
  "invariants": [
    "thing that must always be true"
  ],
  "negative_cases": [
    "thing the system must never do"
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

### Connecting Requirements to Tests
- Each **user story** maps to at least one E2E/integration test ("As a user, I want to X" -> test that does X)
- Story **acceptance criteria** become unit test assertions
- **Invariants** become assertion checks that run across multiple tests (e.g. "reclaimer count never exceeds max")
- **Negative use cases** become explicit "should NOT" / "should reject" test cases
- **Edge cases** become boundary tests (empty state, max values, concurrent access)
- Reference the source in test descriptions: "Write test for story: [user can filter inventory]" or "Write test for invariant: [equipped items reduce from stash]"
- Stories that span multiple phases: test the phase's portion, note full story completes later

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
