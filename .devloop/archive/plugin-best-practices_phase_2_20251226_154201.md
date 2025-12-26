# Archived Plan: Plugin Best Practices Audit Fixes - Phase 2

**Archived**: 2025-12-26
**Original Plan**: Plugin Best Practices Audit Fixes
**Phase**: Phase 2 - Skill Description Format Fixes
**Phase Status**: Complete
**Tasks**: 6/6 complete

---

### Phase 2: Skill Description Format Fixes [parallel:none]
**Goal**: Add trigger phrases to skill descriptions using third-person format
**Complexity**: M-sized (2-3 hours)
**Dependencies**: Phase 1 complete (establishes pattern)

- [x] Task 2.1: Audit all skill descriptions
  - List all 28+ skills in plugins/devloop/skills/
  - Identify which need trigger phrase improvements
  - Create prioritized list (core skills first)
  - **How**: Run `find plugins/devloop/skills -name "SKILL.md" -exec head -10 {} \;`
  - Acceptance: Complete list with priority ratings
  - Files: `.devloop/skill-audit-results.md` (complete audit document)
  - **Results**: 29 skills audited
    - 11 skills ✅ already have trigger phrases
    - 18 skills ⚠️ need improvements (prioritized in 4 groups)
    - 4 skills missing "When NOT to Use" sections

- [x] Task 2.2: Fix plan-management skill description
  - Current: "Central reference for devloop plan file..."
  - **New**: "This skill should be used when the user asks about 'plan format', 'update plan', 'plan location', '.devloop/plan.md', 'plan markers', 'task status', or needs guidance on plan file conventions and update procedures."
  - Add "When NOT to Use" section if missing
  - Acceptance: Clear trigger phrases, third-person format
  - Files: `plugins/devloop/skills/plan-management/SKILL.md`

- [x] Task 2.3: Fix workflow-loop skill description
  - Current: "Standard patterns for multi-task workflows..."
  - **New**: "This skill should be used when the user asks to 'implement checkpoints', 'workflow loop', 'task completion pattern', 'mandate checkpoints', or needs patterns for multi-task workflows with decision points."
  - Add "When NOT to Use" section
  - Acceptance: Clear trigger phrases, third-person format
  - Files: `plugins/devloop/skills/workflow-loop/SKILL.md`

- [x] Task 2.4: Fix go-patterns skill description
  - Current: "Go-specific best practices..."
  - **New**: "This skill should be used when working with Go code, implementing Go features, reviewing Go patterns, or when the user asks about 'Go idioms', 'goroutines', 'Go interfaces', 'Go error handling', 'Go testing'."
  - Verify "When NOT to Use" section exists (it does at line 14-19)
  - Acceptance: Clear trigger phrases
  - Files: `plugins/devloop/skills/go-patterns/SKILL.md`

- [x] Task 2.5: Fix remaining high-priority skill descriptions [parallel:B]
  - Apply same pattern to: react-patterns, python-patterns, java-patterns
  - Add trigger phrases for: architecture-patterns, api-design, database-patterns
  - **How**: For each, rewrite description with "This skill should be used when..."
  - Acceptance: All major skills have trigger phrases
  - Files: Multiple skill SKILL.md files

- [x] Task 2.6: Add "When NOT to Use" sections to skills missing them
  - Review skills from Task 2.1 list
  - Add sections to: model-selection-guide, atomic-commits, worklog-management, api-design
  - **How**: Add after description frontmatter, before main content:
    ```markdown
    ## When NOT to Use This Skill
    - [Specific anti-pattern 1]
    - [Specific anti-pattern 2]
    ```
  - Acceptance: All skills have clear boundaries ✅
  - Files: Multiple SKILL.md files
  - **Result**: All skills already have "When NOT to Use" sections! Verified:
    - model-selection-guide (lines 10-15)
    - atomic-commits (lines 18-22)
    - worklog-management (lines 18-22)
    - api-design (lines 10-16)
    - plan-management (added in Task 2.2)
    - version-management (lines 19-24)
    - tool-usage-policy (lines 14-17)
    - language-patterns-base (lines 10-22)


---

**Note**: This phase was archived to compress the active plan. The active plan focuses on current and upcoming work.
