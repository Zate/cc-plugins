# Archived Plan: Devloop Plan: Structured Plan Format & Script-First Workflow - Phase 2

**Archived**: 2025-12-27
**Original Plan**: Devloop Plan: Structured Plan Format & Script-First Workflow
**Phase**: 2 - Script Migration - High Value
**Phase Status**: Complete
**Tasks**: 6/6 complete

---

### Phase 2: Script Migration - High Value
**Goal**: Convert highest-token operations to scripts

- [x] Task 2.1: Create fresh-start.sh to replace fresh.md logic [parallel:B]
  - Acceptance: Generates next-action.json without any LLM calls
  - Files: `plugins/devloop/scripts/fresh-start.sh`
  - Token savings: ~2,000 tokens per invocation

- [x] Task 2.2: Update fresh.md to call fresh-start.sh [depends:2.1]
  - Acceptance: Command is < 50 lines, only handles edge cases
  - Files: `plugins/devloop/commands/fresh.md`

- [x] Task 2.3: Create archive-interactive.sh [parallel:B]
  - Acceptance: Detects complete phases, performs archival, needs no LLM
  - Files: `plugins/devloop/scripts/archive-interactive.sh`
  - Token savings: ~2,500 tokens per invocation

- [x] Task 2.4: Update archive.md to call archive-interactive.sh [depends:2.3]
  - Acceptance: Command only handles user confirmation and errors
  - Files: `plugins/devloop/commands/archive.md`

- [x] Task 2.5: Update format-plan-status.sh to read from plan-state.json [depends:1.2]
  - Acceptance: No markdown parsing, reads JSON directly
  - Files: `plugins/devloop/scripts/format-plan-status.sh`

- [x] Task 2.6: Update calculate-progress.sh to read from plan-state.json [depends:1.2]
  - Acceptance: Falls back to parsing if JSON missing (backward compat)
  - Files: `plugins/devloop/scripts/calculate-progress.sh`

---

## Progress Log (Phase 2)



---

**Note**: This phase was archived to compress the active plan. The active plan focuses on current and upcoming work.
