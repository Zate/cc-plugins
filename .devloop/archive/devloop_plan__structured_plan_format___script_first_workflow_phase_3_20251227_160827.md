# Archived Plan: Devloop Plan: Structured Plan Format & Script-First Workflow - Phase 3

**Archived**: 2025-12-27
**Original Plan**: Devloop Plan: Structured Plan Format & Script-First Workflow
**Phase**: 3 - Script Migration - Issue Tracking
**Phase Status**: Complete
**Tasks**: 6/6 complete

---

### Phase 3: Script Migration - Issue Tracking
**Goal**: Make issue tracking mostly script-driven

- [x] Task 3.1: Create create-issue.sh [parallel:C]
  - Acceptance: Creates BUG-NNN.md or FEAT-NNN.md with correct structure
  - Files: `plugins/devloop/scripts/create-issue.sh`
  - Token savings: ~2,000 tokens per invocation

- [x] Task 3.2: Create list-issues.sh [parallel:C]
  - Acceptance: Lists issues with filtering (type, status), outputs markdown or JSON
  - Files: `plugins/devloop/scripts/list-issues.sh`

- [x] Task 3.3: Create update-issue.sh [parallel:C]
  - Acceptance: Updates issue status, adds comments
  - Files: `plugins/devloop/scripts/update-issue.sh`

- [x] Task 3.4: Update issues.md to use issue scripts [depends:3.1,3.2,3.3]
  - Acceptance: Command reduced to routing + user questions
  - Files: `plugins/devloop/commands/issues.md`

- [x] Task 3.5: Update new.md to use create-issue.sh [depends:3.1]
  - Acceptance: Only uses LLM for type detection when ambiguous
  - Files: `plugins/devloop/commands/new.md`

- [x] Task 3.6: Update bugs.md to use list-issues.sh [depends:3.2]
  - Acceptance: Pure script invocation + display
  - Files: `plugins/devloop/commands/bugs.md`

---

## Progress Log (Phase 3)



---

**Note**: This phase was archived to compress the active plan. The active plan focuses on current and upcoming work.
