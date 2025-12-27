# Archived Plan: Plugin Optimization - Phase 2

**Archived**: 2025-12-27
**Original Plan**: Plugin Optimization - Token Efficiency & Progressive Disclosure
**Phase Status**: Complete
**Tasks**: 4/4 complete

---

## Phase 2: Core Utility Scripts [parallel:none]
**Goal**: Create 3 high-value scripts to replace repeated logic
**Complexity**: S-sized (2-3 hours)
**Expected Impact**: DRY principle, consistency, single source of truth

- [x] Task 2.1: Create scripts/validate-plan.sh
  - Extract plan validation logic from `hooks/pre-commit.sh`, plan-management skill
  - Support features:
    - Format validation (YAML frontmatter, section headers)
    - Task marker validation (`[ ]`, `[x]`, `[~]`, `[!]`, `[-]`)
    - Dependency checking (`[depends:X.Y]` references valid tasks)
    - Parallelism marker validation (`[parallel:A]` consistency)
  - Error messages: Specific, actionable (line numbers, issue description)
  - **Acceptance**: Script validates all plan.md format rules, returns 0 on success
  - **Files**: `plugins/devloop/scripts/validate-plan.sh`
  - **Testing**: Run on valid plan (passes), invalid plan (fails with clear errors)

- [x] Task 2.2: Update consumers to use validate-plan.sh
  - Update `hooks/pre-commit.sh` to call `validate-plan.sh` instead of inline logic
  - Update `/devloop:archive` to validate before archiving phases
  - Update `/devloop:continue` to validate on resume (optional check)
  - Remove duplicated validation logic from consumers
  - **Acceptance**: All 3 consumers use centralized script, no inline duplication
  - **Files**: `hooks/pre-commit.sh`, `commands/archive.md`, `commands/continue.md`

- [x] Task 2.3: Create scripts/update-worklog.sh
  - Extract worklog format specification from worklog-management skill
  - Support operations:
    - Append entry (with timestamp, commit hash, description)
    - Rotate worklog (when exceeds size limit, use existing rotate-worklog.sh)
    - Format dates consistently (ISO 8601)
    - Validate entry format before appending
  - Usage: `update-worklog.sh "commit-hash" "description"`
  - **Acceptance**: Script maintains consistent worklog format, atomic updates
  - **Files**: `plugins/devloop/scripts/update-worklog.sh`
  - **Testing**: Append 5 entries, verify format consistency

- [x] Task 2.4: Create scripts/format-commit.sh [parallel:B]
  - Extract conventional commit rules from atomic-commits skill, git-workflows skill
  - Generate conventional commit messages from task context
  - Support features:
    - Type detection (feat, fix, refactor, docs, test, chore)
    - Scope extraction (from task description or file paths)
    - Body formatting (multi-line description)
    - Breaking change detection (BREAKING CHANGE: footer)
  - Usage: `format-commit.sh "task-description" "file-list"`
  - Output: Formatted commit message ready for `git commit -F -`
  - **Acceptance**: Script generates valid conventional commits following atomic-commits pattern
  - **Files**: `plugins/devloop/scripts/format-commit.sh`
  - **Testing**: Generate 3 commits (feat, fix, refactor), verify format

---

## Progress Log (Phase 2)

- 2025-12-26: **Phase 2 Complete** - Core utility scripts
  - Created: validate-plan.sh (plan format validation with actionable errors)
  - Created: update-worklog.sh (centralized worklog management)
  - Created: format-commit.sh (conventional commit formatting)
  - Updated: pre-commit.sh, archive.md, continue.md to use validate-plan.sh

---

**Note**: This phase was archived to compress the active plan. The active plan focuses on current and upcoming work.
