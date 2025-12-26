# Archived Plan: Plugin Best Practices Audit Fixes - Phase 1

**Archived**: 2025-12-26
**Original Plan**: Plugin Best Practices Audit Fixes
**Phase**: Phase 1 - Agent Description Format Fixes
**Phase Status**: Complete
**Tasks**: 9/9 complete

---

### Phase 1: Agent Description Format Fixes [parallel:partial]
**Goal**: Convert all agent descriptions to third-person format with integrated examples
**Complexity**: M-sized (3-4 hours)
**Dependencies**: None

- [x] Task 1.1: Fix engineer.md description
  - Convert to "Use this agent when..." format
  - Move Examples section into description field
  - Ensure `<example>` blocks are integrated in description
  - Fix color field: change `indigo` → `blue` or `cyan`
  - **How**: Read engineer.md:1-40, rewrite frontmatter description field to:
    ```yaml
    description: Use this agent when working on code-related tasks including understanding code, designing features, analyzing refactoring opportunities, and managing version control.

    <example>
    Context: User wants to understand how a feature works.
    user: "How does the payment processing work?"
    assistant: "I'll launch the devloop:engineer agent to explore..."
    <commentary>Use engineer for codebase exploration</commentary>
    </example>

    <example>
    Context: User wants to add a new feature.
    user: "Add user authentication"
    assistant: "I'll use devloop:engineer to design the architecture."
    <commentary>Use engineer for architectural decisions</commentary>
    </example>
    ```
  - Move current Examples section OUT of description
  - Acceptance: Description follows plugin-dev agent-development format exactly
  - Files: `plugins/devloop/agents/engineer.md`

- [x] Task 1.2: Fix code-reviewer.md description [parallel:A]
  - Apply same pattern as Task 1.1
  - Convert Examples → integrated `<example>` blocks in description
  - **How**:
    1. Read code-reviewer.md:1-30
    2. Extract trigger conditions from line 3
    3. Rewrite description to third-person with examples
    4. Remove separate Examples section
  - Acceptance: Matches plugin-dev format
  - Files: `plugins/devloop/agents/code-reviewer.md`

- [x] Task 1.3: Fix qa-engineer.md description [parallel:A]
  - Apply same pattern as Task 1.1
  - Convert Examples → integrated `<example>` blocks
  - Acceptance: Matches plugin-dev format
  - Files: `plugins/devloop/agents/qa-engineer.md`

- [x] Task 1.4: Fix security-scanner.md description [parallel:A]
  - Apply same pattern as Task 1.1
  - Convert Examples → integrated `<example>` blocks
  - Acceptance: Matches plugin-dev format
  - Files: `plugins/devloop/agents/security-scanner.md`

- [x] Task 1.5: Fix workflow-detector.md description [parallel:A]
  - Apply same pattern as Task 1.1
  - Convert Examples → integrated `<example>` blocks
  - Acceptance: Matches plugin-dev format
  - Files: `plugins/devloop/agents/workflow-detector.md`

- [x] Task 1.6: Fix complexity-estimator.md description [parallel:A]
  - Apply same pattern as Task 1.1
  - Convert Examples → integrated `<example>` blocks
  - Acceptance: Matches plugin-dev format
  - Files: `plugins/devloop/agents/complexity-estimator.md`

- [x] Task 1.7: Fix task-planner.md description (if exists) [parallel:A]
  - Check if task-planner.md exists
  - Apply same pattern if needed
  - Acceptance: Matches plugin-dev format or confirmed correct
  - Files: `plugins/devloop/agents/task-planner.md`

- [x] Task 1.8: Fix summary-generator.md description (if exists) [parallel:A]
  - Check if summary-generator.md exists
  - Apply same pattern if needed
  - Acceptance: Matches plugin-dev format or confirmed correct
  - Files: `plugins/devloop/agents/summary-generator.md`

- [x] Task 1.9: Fix doc-generator.md description (if exists) [parallel:A]
  - Check if doc-generator.md exists
  - Apply same pattern if needed
  - Acceptance: Matches plugin-dev format or confirmed correct
  - Files: `plugins/devloop/agents/doc-generator.md`


---

**Note**: This phase was archived to compress the active plan. The active plan focuses on current and upcoming work.
