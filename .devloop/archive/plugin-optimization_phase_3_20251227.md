# Archived Plan: Plugin Optimization - Phase 3

**Archived**: 2025-12-27
**Original Plan**: Plugin Optimization - Token Efficiency & Progressive Disclosure
**Phase Status**: Complete
**Tasks**: 5/5 complete

---

## Phase 3: Standardize Skill Frontmatter [parallel:none]
**Goal**: Add whenToUse / whenNotToUse YAML to all 29 skills
**Complexity**: M-sized (3-4 hours - ~30min per skill batch)
**Expected Impact**: Better skill invocation, clearer contracts, programmatic access

- [x] Task 3.1: Create standardized frontmatter template
  - Document required fields: name, description
  - Document optional fields: whenToUse, whenNotToUse, dependencies
  - Include examples from workflow-loop skill (already has whenToUse/whenNotToUse)
  - Format guidelines:
    - `description`: Third-person, <1024 chars, includes specific triggers
    - `whenToUse`: List of trigger scenarios (user asks, file type, workflow)
    - `whenNotToUse`: List of anti-patterns and boundaries
  - **Acceptance**: Template documented in `docs/skills.md` with examples
  - **Files**: `plugins/devloop/skills/INDEX.md` or `docs/skills.md`

- [x] Task 3.2: Update skills 1-10 with standardized frontmatter [parallel:C]
  - Batch: plan-management, tool-usage-policy, atomic-commits, worklog-management, model-selection-guide, api-design, database-patterns, testing-strategies, git-workflows, deployment-readiness
  - Convert markdown "When to Use" sections to YAML `whenToUse` field
  - Convert markdown "When NOT to Use" sections to YAML `whenNotToUse` field
  - Keep markdown sections for backward compatibility (Claude reads both)
  - **Acceptance**: 10 skills have standardized YAML frontmatter
  - **Files**: 10 SKILL.md files in `plugins/devloop/skills/`

- [x] Task 3.3: Update skills 11-20 with standardized frontmatter [parallel:C]
  - Batch: architecture-patterns, security-checklist, requirements-patterns, phase-templates, complexity-estimation, project-context, project-bootstrap, language-patterns-base, workflow-selection, issue-tracking
  - Apply same pattern as Task 3.2
  - **Acceptance**: 10 skills have standardized YAML frontmatter
  - **Files**: 10 SKILL.md files in `plugins/devloop/skills/`

- [x] Task 3.4: Update skills 21-29 with standardized frontmatter [parallel:C]
  - Batch: version-management, file-locations, react-patterns, python-patterns, java-patterns, go-patterns, task-checkpoint, workflow-loop (verify existing), refactoring-analysis
  - Apply same pattern as Task 3.2
  - Note: workflow-loop already has whenToUse/whenNotToUse, verify format
  - **Acceptance**: All 29 skills have standardized YAML frontmatter
  - **Files**: 9 SKILL.md files in `plugins/devloop/skills/`

- [x] Task 3.5: Verify skill invocation with updated frontmatter
  - Test 5 representative skills across different categories
  - Confirm skills trigger correctly with new frontmatter
  - Check that whenToUse/whenNotToUse doesn't break existing invocation
  - **Acceptance**: All skills invocable, no regressions
  - **Testing**: Trigger plan-management, go-patterns, workflow-loop, api-design, task-checkpoint

---

## Progress Log (Phase 3)

- 2025-12-26: Task 3.1 complete - Added "Skill Frontmatter Standard" section to docs/skills.md with template, examples, format guidelines
- 2025-12-26: Task 3.2 complete - Updated 10 skills with whenToUse/whenNotToUse YAML: plan-management, tool-usage-policy, atomic-commits, worklog-management, model-selection-guide, api-design, database-patterns, testing-strategies, git-workflows, deployment-readiness
- 2025-12-26: Task 3.3 complete - Updated 10 skills with whenToUse/whenNotToUse YAML: architecture-patterns, security-checklist, requirements-patterns, phase-templates, complexity-estimation, project-context, project-bootstrap, language-patterns-base, workflow-selection, issue-tracking
- 2025-12-26: Task 3.4 complete - Updated 8 skills with whenToUse/whenNotToUse YAML: version-management, file-locations, react-patterns, python-patterns, java-patterns, go-patterns, task-checkpoint, refactoring-analysis. Verified workflow-loop already had YAML.
- 2025-12-26: Task 3.5 complete - Verified 5 representative skills (plan-management, go-patterns, workflow-loop, api-design, task-checkpoint) have valid YAML frontmatter
- 2025-12-26: **Phase 3 Complete** - All 29 skills standardized with whenToUse/whenNotToUse YAML frontmatter

---

**Note**: This phase was archived to compress the active plan. The active plan focuses on current and upcoming work.
