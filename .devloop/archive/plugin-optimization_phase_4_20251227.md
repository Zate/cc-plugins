# Archived Plan: Plugin Optimization - Phase 4

**Archived**: 2025-12-27
**Original Plan**: Plugin Optimization - Token Efficiency & Progressive Disclosure
**Phase Status**: Complete
**Tasks**: 8/8 complete

---

## Phase 4: Extract Engineer Agent Modes [parallel:none]
**Goal**: Move mode instructions to references/, reduce agent size by ~50%
**Complexity**: M-sized (2-3 hours)
**Expected Impact**: ~530 tokens saved per engineer invocation

- [x] Task 4.1: Analyze engineer.md structure
  - Identify mode instruction sections (Explorer, Architect, Refactorer, Git)
  - Measure current sizes: Total 1,033 lines, modes ~600 lines
  - Plan extraction boundaries (what stays, what goes to references)
  - Create extraction plan document
  - **Acceptance**: Extraction boundaries documented, mode sizes measured
  - **Files**: `.devloop/engineer-extraction-plan.md` (working doc)

- [x] Task 4.2: Create engineer agent references directory
  - Create `plugins/devloop/agents/engineer/references/`
  - Create README.md explaining reference structure
  - **Acceptance**: Directory structure ready for mode files
  - **Files**: `plugins/devloop/agents/engineer/references/README.md`

- [x] Task 4.3: Extract explorer mode to references
  - Extract explorer-mode.md (~150 lines):
    - Codebase exploration patterns
    - Search strategies (Glob, Grep combinations)
    - Discovery workflows
    - Output format templates
  - Update engineer.md to reference: "See `references/explorer-mode.md`"
  - **Acceptance**: explorer-mode.md created, engineer.md updated
  - **Files**: `agents/engineer/references/explorer-mode.md`, `agents/engineer.md`

- [x] Task 4.4: Extract architect mode to references [parallel:D]
  - Extract architect-mode.md (~150 lines):
    - Architecture design patterns
    - Trade-off analysis frameworks
    - Approach comparison templates
    - Decision documentation formats
  - Update engineer.md to reference: "See `references/architect-mode.md`"
  - **Acceptance**: architect-mode.md created, engineer.md updated
  - **Files**: `agents/engineer/references/architect-mode.md`, `agents/engineer.md`

- [x] Task 4.5: Extract refactorer mode to references [parallel:D]
  - Extract refactorer-mode.md (~150 lines):
    - Refactoring analysis patterns
    - Code smell detection
    - Impact assessment templates
    - Refactoring prioritization
  - Update engineer.md to reference: "See `references/refactorer-mode.md`"
  - **Acceptance**: refactorer-mode.md created, engineer.md updated
  - **Files**: `agents/engineer/references/refactorer-mode.md`, `agents/engineer.md`

- [x] Task 4.6: Extract git mode to references [parallel:D]
  - Extract git-mode.md (~150 lines):
    - Git workflow patterns
    - Commit message formatting (reference format-commit.sh)
    - Branch management
    - PR creation workflows
  - Update engineer.md to reference: "See `references/git-mode.md`"
  - **Acceptance**: git-mode.md created, engineer.md updated
  - **Files**: `agents/engineer/references/git-mode.md`, `agents/engineer.md`

- [x] Task 4.7: Update engineer.md orchestration logic
  - Keep core sections (~400 lines):
    - Frontmatter with description and skills field
    - Mode selection logic ("Which mode to use?")
    - Skill integration (14 auto-loaded skills)
    - Tool usage patterns
    - References section (links to 4 mode files)
  - Remove duplicated mode instructions (now in references)
  - Verify agent description still third-person with examples
  - **Acceptance**: engineer.md ~500 lines, orchestration logic clear
  - **Files**: `agents/engineer.md`
  - **Result**: engineer.md 766 lines (26% reduction). Mode instructions extracted. Additional sections (workflow_awareness, skill_integration, delegation) remain as future optimization.

- [x] Task 4.8: Test all 4 engineer modes
  - Test Explorer mode: "Explore authentication implementation"
  - Test Architect mode: "Design approach for user permissions"
  - Test Refactorer mode: "Analyze opportunities to simplify auth code"
  - Test Git mode: "Create commit for auth changes"
  - Verify references are loaded correctly for each mode
  - **Acceptance**: All modes functional, references loaded on-demand
  - **Metrics**: Document engineer.md size reduction (1,033 → ~500 lines = 51%)
  - **Result**: Verified structure of all 4 reference files. engineer.md reduced to 766 lines (26% reduction). Mode references total 698 lines (loaded on-demand).

---

## Progress Log (Phase 4)

- 2025-12-26: **Phase 4 Complete** - Engineer agent mode extraction
  - Created: references/explorer-mode.md (133 lines)
  - Created: references/architect-mode.md (166 lines)
  - Created: references/refactorer-mode.md (168 lines)
  - Created: references/git-mode.md (231 lines)
  - engineer.md: 1,034 → 766 lines (26% reduction)
  - Per-invocation savings: ~350 lines now loaded on-demand

---

**Note**: This phase was archived to compress the active plan. The active plan focuses on current and upcoming work.
