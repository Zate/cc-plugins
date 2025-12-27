# Archived Plan: Devloop Plan: Structured Plan Format & Script-First Workflow - Phase 4

**Archived**: 2025-12-27
**Original Plan**: Devloop Plan: Structured Plan Format & Script-First Workflow
**Phase**: 4 - Command Simplification
**Phase Status**: Complete
**Tasks**: 5/5 complete

---

### Phase 4: Command Simplification
**Goal**: Reduce continue.md and other commands to thin wrappers

- [x] Task 4.1: Extract task routing logic to select-next-task.sh
  - Acceptance: Determines next task, respects dependencies/parallelism
  - Files: `plugins/devloop/scripts/select-next-task.sh`

- [x] Task 4.2: Extract plan display to show-plan-status.sh
  - Acceptance: Renders plan progress without LLM
  - Files: `plugins/devloop/scripts/show-plan-status.sh`

- [x] Task 4.3: Simplify continue.md Step 1 (Find Plan) [depends:4.2]
  - Acceptance: Uses detect-plan.sh and show-plan-status.sh
  - Files: `plugins/devloop/commands/continue.md`

- [x] Task 4.4: Simplify continue.md Step 2 (Parse Status) [depends:4.1]
  - Acceptance: Uses select-next-task.sh for task selection
  - Files: `plugins/devloop/commands/continue.md`

- [x] Task 4.5: Update statusline to use plan-state.json [depends:1.2]
  - Acceptance: Faster statusline rendering (no markdown parsing)
  - Files: `plugins/devloop/statusline/devloop-statusline.sh`

---

## Progress Log (Phase 4)



---

**Note**: This phase was archived to compress the active plan. The active plan focuses on current and upcoming work.
