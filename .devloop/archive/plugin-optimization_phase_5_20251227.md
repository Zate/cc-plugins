# Archived Plan: Plugin Optimization - Phase 5

**Archived**: 2025-12-27
**Original Plan**: Plugin Optimization - Token Efficiency & Progressive Disclosure
**Phase Status**: Complete
**Tasks**: 10/10 complete

---

## Phase 5: Additional Optimizations [parallel:none]
**Goal**: Extract command templates, split large hook scripts, optimize remaining skills
**Complexity**: L-sized (4-6 hours)
**Expected Impact**: Consistency, maintainability, completeness

- [x] Task 5.1: Extract onboard.md templates
  - Current: 492 lines (command for onboarding existing projects)
  - Create `plugins/devloop/templates/onboard/`:
    - `claudemd-template.md` - Default CLAUDE.md structure
    - `gitignore-devloop` - Git ignore patterns for .devloop/
    - `directory-structure.txt` - Standard .devloop/ layout
  - Update command to reference templates (read & populate)
  - **Acceptance**: onboard.md <300 lines, 3 template files created
  - **Files**: `commands/onboard.md`, `templates/onboard/*.md`

- [x] Task 5.2: Extract ship.md validation logic
  - Current: 462 lines (validation and deployment prep)
  - Create `scripts/ship-validation.sh`:
    - DoD checklist validation (tests pass, docs updated, etc.)
    - Deployment readiness checks
    - Version bump suggestions
  - Update command to call script for validation phases
  - **Acceptance**: ship.md <300 lines, validation in script
  - **Files**: `commands/ship.md`, `scripts/ship-validation.sh`

- [x] Task 5.3: Split session-start.sh into smaller scripts [parallel:E]
  - Current: 861 lines (largest hook script)
  - Create subscripts:
    - `scripts/detect-plan.sh` - Plan file discovery logic (~200 lines)
    - `scripts/calculate-progress.sh` - Task counting, completion % (~150 lines)
    - `scripts/format-plan-status.sh` - Status message formatting (~100 lines)
  - Update `session-start.sh` to orchestrate subscripts (~400 lines)
  - **Acceptance**: Main script <450 lines, 3 subscripts created
  - **Files**: `hooks/session-start.sh`, `scripts/detect-plan.sh`, `scripts/calculate-progress.sh`, `scripts/format-plan-status.sh`

- [x] Task 5.4: Create archive-phase.sh script [parallel:E]
  - Extract phase archival logic from `/devloop:archive` command (361 lines)
  - Create `scripts/archive-phase.sh`:
    - Phase extraction logic
    - Archive file generation
    - Worklog integration
  - Usage: `archive-phase.sh <phase-number> <plan-file> <archive-dir>`
  - Update `/devloop:archive` to use script for phase operations
  - **Acceptance**: Reusable script, command simplified
  - **Files**: `scripts/archive-phase.sh`, `commands/archive.md`

- [x] Task 5.5: Create suggest-skills.sh script [parallel:E]
  - Centralized skill routing based on context
  - Inputs: file type, task type, keywords
  - Output: Recommended skills with rationale
  - Usage: `suggest-skills.sh "python" "testing" "pytest"`
  - Used by: PreToolUse hook, commands
  - **Acceptance**: Script suggests relevant skills accurately
  - **Files**: `scripts/suggest-skills.sh`

- [x] Task 5.6: Add version-management references/ [parallel:F]
  - Current: 420 lines
  - Create `plugins/devloop/skills/version-management/references/`:
    - `semver-guide.md` - Semantic versioning rules, examples (~100 lines)
    - `changelog-format.md` - CHANGELOG.md structure, keep-a-changelog (~90 lines)
    - `release-workflow.md` - Git tagging, version bumps, release notes (~80 lines)
  - Update SKILL.md to ~150 lines with references section
  - **Acceptance**: SKILL.md <200 lines, 3 reference files created
  - **Files**: `skills/version-management/SKILL.md`, `references/*.md`

- [x] Task 5.7: Add atomic-commits references/ [parallel:F]
  - Current: 394 lines
  - Create `plugins/devloop/skills/atomic-commits/references/`:
    - `commit-sizing.md` - Size guidelines, grouping criteria, decision flow
    - `examples.md` - Good vs bad commit examples, task references
    - `parallel-tasks.md` - Parallel task handling, phase boundaries
  - Update SKILL.md to 104 lines with references section
  - **Result**: 406 → 104 lines (74% reduction), 3 reference files created

- [x] Task 5.8: Add file-locations references/ [parallel:F]
  - Current: 382 lines
  - Create `plugins/devloop/skills/file-locations/references/`:
    - `file-specs.md` - Detailed format for each file type, lifecycle, settings
    - `migration.md` - Migration from .claude/ to .devloop/, new project setup
    - `rationale.md` - Why files are tracked or not tracked
  - Update SKILL.md to 115 lines with references section
  - **Result**: 394 → 115 lines (71% reduction), 3 reference files created

- [x] Task 5.9: Extract bootstrap.md generation logic [parallel:E]
  - Current: 412 lines (bootstrap new projects from docs)
  - Create `templates/bootstrap/`:
    - `claudemd-template.md` - CLAUDE.md structure with stack-specific defaults
    - `initial-plan-template.md` - Plan structure and scaffolding tasks by stack
    - `examples.md` - Input handling, examples, best practices
  - Update command to reference templates
  - **Result**: 413 → 145 lines (65% reduction), 3 template files created

- [x] Task 5.10: Intelligent context clear suggestions
  - **Goal**: Detect when context is heavy and suggest fresh start
  - Created `scripts/suggest-fresh.sh`:
    - Analyzes plan.md metrics (tasks completed, plan size, blocked tasks)
    - Configurable thresholds (low: 3 tasks, normal: 5, high: 10)
    - JSON output support for programmatic use
    - Returns recommendation with confidence level and reasons
  - Integration with workflow-loop skill (context management section)
  - **Result**: Script created with multi-threshold support
  - **Files**: `scripts/suggest-fresh.sh`

---

## Progress Log (Phase 5)

- 2025-12-26: Phase 5 progress (Tasks 5.1-5.6 complete)
  - onboard.md: 492 → 209 lines (57% reduction), 6 templates created
  - ship.md: 463 → 188 lines (59% reduction), ship-validation.sh created
  - session-start.sh: 871 → 384 lines (56% reduction), 3 subscripts created
  - Created: archive-phase.sh, suggest-skills.sh utility scripts
  - version-management skill: 431 → 139 lines (68% reduction), 3 references
- 2025-12-27: **Phase 5 Complete** - All additional optimizations done
  - atomic-commits skill: 406 → 104 lines (74% reduction), 3 references
  - file-locations skill: 394 → 115 lines (71% reduction), 3 references
  - bootstrap.md: 413 → 145 lines (65% reduction), 3 templates
  - Created: suggest-fresh.sh for intelligent context clear suggestions

---

**Note**: This phase was archived to compress the active plan. The active plan focuses on current and upcoming work.
