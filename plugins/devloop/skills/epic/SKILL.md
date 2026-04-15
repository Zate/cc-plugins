---
name: epic
description: Create a multi-phase epic plan with TDD structure for large features
argument-hint: <topic> [--no-tdd]
when_to_use: "Large features spanning multiple phases, multi-session work, TDD-driven development"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - LSP
  - Agent
  - AskUserQuestion
  - mcp__mdv__list_contexts
  - mcp__mdv__navigate_to
  - mcp__mdv__scroll_to_element
  - mcp__mdv__get_document_outline
  - mcp__mdv__add_annotation
---

# Devloop Epic

Create a multi-phase epic plan. Produces `epic.md` (full plan) and `epic.json` (state machine). **Do the work directly.**

## Step 1: Parse Input
Extract topic from `$ARGUMENTS`. If missing, show usage and STOP.
`--no-tdd` skips the tests-first structure.

## Step 2: Check Existing Epic
If `.devloop/epic.json` exists:
- `"complete"`: archive to `.devloop/archive/`. Continue.
- `"in_progress"`: Report progress. **AskUserQuestion**: "Archive and replace" or "Cancel".

## Step 3: Explore & Ask in Parallel

### 3a. Background Exploration
Spawn an Explore agent with `run_in_background: true` to scan the codebase for context on the topic. Let it report back: tech stack, testing framework, affected areas, existing patterns, risks.

The agent should use `LSP.workspaceSymbol` to find topic-related symbols and `LSP.documentSymbol` to map affected file structure. If LSP errors or is unavailable, fall back to Grep + Glob for pattern-based discovery.

> **Token efficiency**: Instruct the Explore agent to cap its report at ~500 words. It should report findings as concise bullet points (file paths + one-line description), not raw file contents. Filter out files unrelated to the epic topic before reporting. This keeps the exploration context lean so the planning phase receives signal, not noise.

### 3b. While Explorer Runs -- End State
**AskUserQuestion**: "What does 'done' look like for this epic? What should the user/system be able to do when it's complete?"

## Review Pattern (applies to Steps 4, 5, 8)

`AskUserQuestion` truncates long content -- users cannot scroll inside it. **Never embed full content in the question.**

### mdv Detection (once, before first review)

Call `mcp__mdv__list_contexts`. If it succeeds, mdv is available -- remember this for all subsequent reviews. If the tool errors or is not found, mdv is unavailable -- skip all mdv calls for the rest of the session.

### Presenting content for review

1. **Write** the full content to `.devloop/draft/<name>.md` (create `.devloop/draft/` if needed)
2. **Output** a concise summary as regular conversation text (this is scrollable)
3. **mdv available**: call `mcp__mdv__navigate_to` to open the draft file. Use `scroll_to_element` or `add_annotation` to highlight areas needing attention if useful.
4. **mdv unavailable**: tell the user: "Full content at `.devloop/draft/<name>.md` -- open it in your editor to review."
5. **AskUserQuestion**: only the short prompt (e.g., "Add, remove, or modify any?"), never the content itself

## Step 4: User Stories

Draft 3-6 user stories from the end state description:
```
As a [role], I want to [action], so that [benefit].
  - Acceptance: [measurable criteria]
```

**Write** the full user stories to `.devloop/draft/user-stories.md`. **Output** a one-line-per-story summary (role + action only). Follow the Review Pattern above. **AskUserQuestion**: "Add, remove, or modify any? (Or 'looks good')"

## Step 5: Threat Model & Gap Analysis

By now the explorer should have returned. Combine codebase context with user stories.

Identify:
- **Invariants**: Things that must always be true
- **Non-negotiables**: Hard requirements from the user or codebase
- **Negative cases**: Things the system must NOT do
- **Edge cases**: Boundary conditions worth testing
- **Gaps**: Missing coverage or unclear assumptions

**Write** the full threat model to `.devloop/draft/threat-model.md`. **Output** a bullet-per-category summary (category name + count of items). Follow the Review Pattern. **AskUserQuestion**: "Anything to add, correct, or flag as out of scope?"

If the scope is large, also ask about priorities and constraints.

## Step 6: Generate Epic

### epic.md

The human-readable plan. Include these sections:
- **Overview**: What and why
- **End State**: User's description of done
- **User Stories**: With acceptance criteria
- **Invariants & Rules**: From the threat model
- **Phase Tracker**: Table with phase name, task count, status
- **Phase Details**: Each phase with goal, test tasks, implementation tasks
- **Completion Criteria**: What "phase done" means

### epic.json

The state machine. Required fields:
```json
{
  "title": "...",
  "created": "YYYY-MM-DD",
  "status": "planning",
  "current_phase": 1,
  "test_command": "detected or null",
  "end_state": "...",
  "user_stories": ["..."],
  "invariants": ["..."],
  "negative_cases": ["..."],
  "phases": [
    {"number": 1, "name": "...", "status": "pending", "tasks": N, "committed": null}
  ]
}
```

Detect `test_command` from project files (package.json, Makefile, go.mod, pyproject.toml). Use `null` if unclear.

### TDD Structure (default)
Each phase has two sections:
1. **Tests first**: Write failing tests. Use `[parallel:A]` for independent tests, `[model:haiku]` for simple ones.
2. **Implementation**: Make tests pass. Use `[depends:N.M]` to link to test tasks.

User stories, invariants, and negative cases should inform what gets tested. Each user story should map to at least one test. Invariants become assertions. Negative cases become "should reject" tests.

### Phase Sizing
- 5-8 tasks per phase (tests + implementation)
- Each phase completable in one subagent session
- Group related functionality together
- Foundational work first, polish last
- Each phase should deliver at least one user story when possible

## Step 7: Promote Phase 1
Run `${CLAUDE_PLUGIN_ROOT}/scripts/promote-phase.sh` to load Phase 1 into plan.md.

## Step 8: Review

**Output** a brief summary: title, phase count, total tasks, test command. If mdv is available, navigate to `.devloop/epic.md` for the full view. Otherwise tell the user the file path.

**AskUserQuestion**:
- **Run now**: Invoke `/devloop:run-epic`.
- **Review epic**: Show full epic.md.
- **Stop here**: "Run `/devloop:run-epic` when ready."

---
**Now**: Parse input and begin.
