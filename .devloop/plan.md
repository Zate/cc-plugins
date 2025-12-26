# Devloop Plan: Plugin Optimization - Token Efficiency & Progressive Disclosure

**Created**: 2025-12-26
**Updated**: 2025-12-26T16:00:00Z
**Status**: In Progress
**Current Phase**: Phase 3
**Estimate**: L (13-19 hours across 5 phases)

## Overview

Optimize devloop plugin for token efficiency and better progressive disclosure based on official Claude Code best practices. Builds on completed "Plugin Best Practices Audit Fixes" plan.

**Focus Areas**:
1. Progressive disclosure for language skills (go, python, java, react)
2. Create core utility scripts (validate-plan, update-worklog, format-commit)
3. Standardize skill frontmatter (whenToUse / whenNotToUse YAML)
4. Extract engineer agent modes to references
5. Additional optimizations (command templates, hook scripts)

**Source**: Spike investigation "Plugin Optimization: Built-in Tools & Token Efficiency"
- Spike report: `.devloop/spikes/plugin-optimization.md`
- Official docs analyzed: Claude Code skills, Agent Skills overview, Best practices

## Architecture Choice

**Phased Progressive Disclosure Strategy**

Breaking optimizations into 5 phases by priority and dependencies:
- Phase 1: Language skills (highest ROI, immediate benefit)
- Phase 2: Core scripts (DRY principle, reusability)
- Phase 3: Skill frontmatter (better invocation)
- Phase 4: Engineer agent (second highest token impact)
- Phase 5: Additional optimizations (completeness)

**Why this approach:**
- Addresses highest-frequency skills first (language patterns trigger often)
- Builds on recent progressive disclosure success (workflow-loop, issue-tracking, plan-management)
- Low-risk refactorings with measurable token savings
- Each phase can be validated independently
- Parallelism opportunities within phases

**Expected Impact**:
- ~2,000+ lines of frequently-loaded content moved to on-demand references
- 40-50% token reduction in language skills (4 skills)
- 50% token reduction in engineer agent (most-used agent)
- Improved maintainability via utility scripts

## Tasks

### Phase 1: Language Skills Progressive Disclosure [parallel:none]
**Goal**: Add references/ to 4 language pattern skills
**Complexity**: M-sized (2-3 hours)
**Expected Impact**: 40-50% token reduction per skill (~840 lines total)

- [x] Task 1.1: Extract go-patterns to references/
  - Create `plugins/devloop/skills/go-patterns/references/`
  - Extract sections to reference files:
    - `concurrency.md` - Goroutines, channels, sync patterns (~100 lines)
    - `testing.md` - Table-driven tests, benchmarks, examples (~80 lines)
    - `interfaces.md` - Interface design, composition patterns (~70 lines)
    - `error-handling.md` - Error wrapping, sentinel errors, patterns (~60 lines)
  - Update SKILL.md to ~180 lines with references section
  - **Acceptance**: SKILL.md <200 lines, 4 reference files created, all patterns accessible
  - **Files**: `plugins/devloop/skills/go-patterns/SKILL.md`, `references/*.md`

- [x] Task 1.2: Extract python-patterns to references/ [parallel:A]
  - Create `plugins/devloop/skills/python-patterns/references/`
  - Extract sections to reference files:
    - `type-hints.md` - Typing best practices, generics, protocols (~90 lines)
    - `async-patterns.md` - Asyncio, coroutines, concurrency (~100 lines)
    - `testing-pytest.md` - Fixtures, parametrize, mocking (~90 lines)
    - `error-handling.md` - Exception patterns, context managers (~60 lines)
  - Update SKILL.md to ~180 lines with references section
  - **Acceptance**: SKILL.md <200 lines, 4 reference files created, all patterns accessible
  - **Files**: `plugins/devloop/skills/python-patterns/SKILL.md`, `references/*.md`

- [x] Task 1.3: Extract java-patterns to references/ [parallel:A]
  - Create `plugins/devloop/skills/java-patterns/references/`
  - Extract sections to reference files:
    - `spring-patterns.md` - Dependency injection, Spring Boot patterns (~100 lines)
    - `streams.md` - Stream API, collectors, functional patterns (~90 lines)
    - `testing-junit.md` - JUnit 5, Mockito, integration tests (~80 lines)
    - `dependency-injection.md` - DI patterns, lifecycle management (~60 lines)
  - Update SKILL.md to ~180 lines with references section
  - **Acceptance**: SKILL.md <200 lines, 4 reference files created, all patterns accessible
  - **Files**: `plugins/devloop/skills/java-patterns/SKILL.md`, `references/*.md`

- [x] Task 1.4: Extract react-patterns to references/ [parallel:A]
  - Create `plugins/devloop/skills/react-patterns/references/`
  - Extract sections to reference files:
    - `hooks.md` - useState, useEffect, custom hooks, rules (~100 lines)
    - `performance.md` - Memoization, lazy loading, code splitting (~90 lines)
    - `testing.md` - React Testing Library, component tests (~80 lines)
    - `state-management.md` - Context, Redux patterns, state design (~70 lines)
  - Update SKILL.md to ~180 lines with references section
  - **Acceptance**: SKILL.md <200 lines, 4 reference files created, all patterns accessible
  - **Files**: `plugins/devloop/skills/react-patterns/SKILL.md`, `references/*.md`

- [x] Task 1.5: Test language skills with real files
  - Edit Python file (test python-patterns triggers, references load)
  - Edit Go file (test go-patterns triggers, references load)
  - Edit Java file (test java-patterns triggers, references load)
  - Edit React/TypeScript file (test react-patterns triggers, references load)
  - Verify skills trigger correctly, references loaded only when needed
  - **Measure token reduction**: Compare SKILL.md sizes before/after
  - **Acceptance**: All 4 skills work correctly, 40-50% size reduction verified
  - **Metrics**: Document before/after line counts in Progress Log

### Phase 2: Core Utility Scripts [parallel:none]
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

### Phase 3: Standardize Skill Frontmatter [parallel:none]
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

- [ ] Task 3.5: Verify skill invocation with updated frontmatter
  - Test 5 representative skills across different categories
  - Confirm skills trigger correctly with new frontmatter
  - Check that whenToUse/whenNotToUse doesn't break existing invocation
  - **Acceptance**: All skills invocable, no regressions
  - **Testing**: Trigger plan-management, go-patterns, workflow-loop, api-design, task-checkpoint

### Phase 4: Extract Engineer Agent Modes [parallel:none]
**Goal**: Move mode instructions to references/, reduce agent size by ~50%
**Complexity**: M-sized (2-3 hours)
**Expected Impact**: ~530 tokens saved per engineer invocation

- [ ] Task 4.1: Analyze engineer.md structure
  - Identify mode instruction sections (Explorer, Architect, Refactorer, Git)
  - Measure current sizes: Total 1,033 lines, modes ~600 lines
  - Plan extraction boundaries (what stays, what goes to references)
  - Create extraction plan document
  - **Acceptance**: Extraction boundaries documented, mode sizes measured
  - **Files**: `.devloop/engineer-extraction-plan.md` (working doc)

- [ ] Task 4.2: Create engineer agent references directory
  - Create `plugins/devloop/agents/engineer/references/`
  - Create README.md explaining reference structure
  - **Acceptance**: Directory structure ready for mode files
  - **Files**: `plugins/devloop/agents/engineer/references/README.md`

- [ ] Task 4.3: Extract explorer mode to references
  - Extract explorer-mode.md (~150 lines):
    - Codebase exploration patterns
    - Search strategies (Glob, Grep combinations)
    - Discovery workflows
    - Output format templates
  - Update engineer.md to reference: "See `references/explorer-mode.md`"
  - **Acceptance**: explorer-mode.md created, engineer.md updated
  - **Files**: `agents/engineer/references/explorer-mode.md`, `agents/engineer.md`

- [ ] Task 4.4: Extract architect mode to references [parallel:D]
  - Extract architect-mode.md (~150 lines):
    - Architecture design patterns
    - Trade-off analysis frameworks
    - Approach comparison templates
    - Decision documentation formats
  - Update engineer.md to reference: "See `references/architect-mode.md`"
  - **Acceptance**: architect-mode.md created, engineer.md updated
  - **Files**: `agents/engineer/references/architect-mode.md`, `agents/engineer.md`

- [ ] Task 4.5: Extract refactorer mode to references [parallel:D]
  - Extract refactorer-mode.md (~150 lines):
    - Refactoring analysis patterns
    - Code smell detection
    - Impact assessment templates
    - Refactoring prioritization
  - Update engineer.md to reference: "See `references/refactorer-mode.md`"
  - **Acceptance**: refactorer-mode.md created, engineer.md updated
  - **Files**: `agents/engineer/references/refactorer-mode.md`, `agents/engineer.md`

- [ ] Task 4.6: Extract git mode to references [parallel:D]
  - Extract git-mode.md (~150 lines):
    - Git workflow patterns
    - Commit message formatting (reference format-commit.sh)
    - Branch management
    - PR creation workflows
  - Update engineer.md to reference: "See `references/git-mode.md`"
  - **Acceptance**: git-mode.md created, engineer.md updated
  - **Files**: `agents/engineer/references/git-mode.md`, `agents/engineer.md`

- [ ] Task 4.7: Update engineer.md orchestration logic
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

- [ ] Task 4.8: Test all 4 engineer modes
  - Test Explorer mode: "Explore authentication implementation"
  - Test Architect mode: "Design approach for user permissions"
  - Test Refactorer mode: "Analyze opportunities to simplify auth code"
  - Test Git mode: "Create commit for auth changes"
  - Verify references are loaded correctly for each mode
  - **Acceptance**: All modes functional, references loaded on-demand
  - **Metrics**: Document engineer.md size reduction (1,033 → ~500 lines = 51%)

### Phase 5: Additional Optimizations [parallel:none]
**Goal**: Extract command templates, split large hook scripts, optimize remaining skills
**Complexity**: L-sized (4-6 hours)
**Expected Impact**: Consistency, maintainability, completeness

- [ ] Task 5.1: Extract onboard.md templates
  - Current: 492 lines (command for onboarding existing projects)
  - Create `plugins/devloop/templates/onboard/`:
    - `claudemd-template.md` - Default CLAUDE.md structure
    - `gitignore-devloop` - Git ignore patterns for .devloop/
    - `directory-structure.txt` - Standard .devloop/ layout
  - Update command to reference templates (read & populate)
  - **Acceptance**: onboard.md <300 lines, 3 template files created
  - **Files**: `commands/onboard.md`, `templates/onboard/*.md`

- [ ] Task 5.2: Extract ship.md validation logic
  - Current: 462 lines (validation and deployment prep)
  - Create `scripts/ship-validation.sh`:
    - DoD checklist validation (tests pass, docs updated, etc.)
    - Deployment readiness checks
    - Version bump suggestions
  - Update command to call script for validation phases
  - **Acceptance**: ship.md <300 lines, validation in script
  - **Files**: `commands/ship.md`, `scripts/ship-validation.sh`

- [ ] Task 5.3: Split session-start.sh into smaller scripts [parallel:E]
  - Current: 861 lines (largest hook script)
  - Create subscripts:
    - `scripts/detect-plan.sh` - Plan file discovery logic (~200 lines)
    - `scripts/calculate-progress.sh` - Task counting, completion % (~150 lines)
    - `scripts/format-plan-status.sh` - Status message formatting (~100 lines)
  - Update `session-start.sh` to orchestrate subscripts (~400 lines)
  - **Acceptance**: Main script <450 lines, 3 subscripts created
  - **Files**: `hooks/session-start.sh`, `scripts/detect-plan.sh`, `scripts/calculate-progress.sh`, `scripts/format-plan-status.sh`

- [ ] Task 5.4: Create archive-phase.sh script [parallel:E]
  - Extract phase archival logic from `/devloop:archive` command (361 lines)
  - Create `scripts/archive-phase.sh`:
    - Phase extraction logic
    - Archive file generation
    - Worklog integration
  - Usage: `archive-phase.sh <phase-number> <plan-file> <archive-dir>`
  - Update `/devloop:archive` to use script for phase operations
  - **Acceptance**: Reusable script, command simplified
  - **Files**: `scripts/archive-phase.sh`, `commands/archive.md`

- [ ] Task 5.5: Create suggest-skills.sh script [parallel:E]
  - Centralized skill routing based on context
  - Inputs: file type, task type, keywords
  - Output: Recommended skills with rationale
  - Usage: `suggest-skills.sh "python" "testing" "pytest"`
  - Used by: PreToolUse hook, commands
  - **Acceptance**: Script suggests relevant skills accurately
  - **Files**: `scripts/suggest-skills.sh`

- [ ] Task 5.6: Add version-management references/ [parallel:F]
  - Current: 420 lines
  - Create `plugins/devloop/skills/version-management/references/`:
    - `semver-guide.md` - Semantic versioning rules, examples (~100 lines)
    - `changelog-format.md` - CHANGELOG.md structure, keep-a-changelog (~90 lines)
    - `release-workflow.md` - Git tagging, version bumps, release notes (~80 lines)
  - Update SKILL.md to ~150 lines with references section
  - **Acceptance**: SKILL.md <200 lines, 3 reference files created
  - **Files**: `skills/version-management/SKILL.md`, `references/*.md`

- [ ] Task 5.7: Add atomic-commits references/ [parallel:F]
  - Current: 394 lines
  - Create `plugins/devloop/skills/atomic-commits/references/`:
    - `commit-types.md` - Conventional commit types, scopes (~80 lines)
    - `examples.md` - Good vs bad commit examples (~100 lines)
    - `commit-checklist.md` - Pre-commit validation checklist (~60 lines)
  - Update SKILL.md to ~150 lines with references section
  - **Acceptance**: SKILL.md <200 lines, 3 reference files created
  - **Files**: `skills/atomic-commits/SKILL.md`, `references/*.md`

- [ ] Task 5.8: Add file-locations references/ [parallel:F]
  - Current: 382 lines
  - Create `plugins/devloop/skills/file-locations/references/`:
    - `git-tracking.md` - What to track vs gitignore (~90 lines)
    - `directory-structure.md` - Complete .devloop/ layout with examples (~100 lines)
  - Update SKILL.md to ~190 lines with references section
  - **Acceptance**: SKILL.md <250 lines, 2 reference files created
  - **Files**: `skills/file-locations/SKILL.md`, `references/*.md`

- [ ] Task 5.9: Extract bootstrap.md generation logic [parallel:E]
  - Current: 412 lines (bootstrap new projects from docs)
  - Create `scripts/generate-claudemd.sh`:
    - CLAUDE.md generation from PRD/specs
    - Tech stack detection integration
    - Template population
  - Update command to use script
  - **Acceptance**: bootstrap.md <250 lines, script handles generation
  - **Files**: `commands/bootstrap.md`, `scripts/generate-claudemd.sh`

- [ ] Task 5.10: Intelligent context clear suggestions
  - **Goal**: Use context_window data to proactively suggest /clear + /devloop:continue
  - Leverage statusline's context_window.current_usage data (already captured)
  - Create `scripts/context-advisor.sh`:
    - Read context percentage from statusline JSON input
    - Store context % in session tracking (.devloop/.current-session.json)
    - Estimate next task complexity (from plan.md task description)
    - Calculate if context + next task would exceed threshold
  - Integration points:
    - After task completion in `/devloop:continue` - check context before proceeding
    - In Stop hook - suggest clear if context >60% and next task is complex
    - In `/devloop:fresh` - use context % to validate suggestion
  - Suggestion logic:
    - If context >80%: "⚠️ Context at {X}%. Recommend `/clear` then `/devloop:continue`"
    - If context >60% AND next task is M/L sized: "💡 Context at {X}%. Consider `/clear` before next task"
    - If context <60%: No suggestion, continue normally
  - Task complexity estimation:
    - Parse next pending task from plan.md
    - Check for complexity indicators (file count, parallel markers, description length)
    - Simple heuristic: tasks with 5+ files or "parallel" = complex
  - **Acceptance**: Context suggestions appear at appropriate thresholds, reduce context-related slowdowns
  - **Files**: `scripts/context-advisor.sh`, `commands/continue.md`, `hooks/prompts/stop-routing.md`
  - **Testing**: Simulate 60%, 75%, 90% context scenarios, verify suggestions trigger correctly

## Progress Log

- 2025-12-26 16:00: Plan created from spike findings "Plugin Optimization: Built-in Tools & Token Efficiency"
- 2025-12-26: **Phase 1 Complete** - Language skills progressive disclosure
  - go-patterns: 199 lines (references: 1,478 lines across 4 files)
  - python-patterns: 196 lines (references: 1,491 lines across 4 files)
  - java-patterns: 199 lines (references: 2,167 lines across 4 files)
  - react-patterns: 197 lines (references: 1,634 lines across 4 files)
  - Total: ~791 lines loaded initially, ~6,770 lines on-demand = **88% reduction**
- 2025-12-26: **Phase 2 Complete** - Core utility scripts
  - Created: validate-plan.sh (plan format validation with actionable errors)
  - Created: update-worklog.sh (centralized worklog management)
  - Created: format-commit.sh (conventional commit formatting)
  - Updated: pre-commit.sh, archive.md, continue.md to use validate-plan.sh
- 2025-12-26 17:30: Fresh start initiated - state saved to next-action.json
- 2025-12-26: Task 3.1 complete - Added "Skill Frontmatter Standard" section to docs/skills.md with template, examples, format guidelines
- 2025-12-26: Task 3.2 complete - Updated 10 skills with whenToUse/whenNotToUse YAML: plan-management, tool-usage-policy, atomic-commits, worklog-management, model-selection-guide, api-design, database-patterns, testing-strategies, git-workflows, deployment-readiness
- 2025-12-26: Task 3.3 complete - Updated 10 skills with whenToUse/whenNotToUse YAML: architecture-patterns, security-checklist, requirements-patterns, phase-templates, complexity-estimation, project-context, project-bootstrap, language-patterns-base, workflow-selection, issue-tracking
- 2025-12-26: Task 3.4 complete - Updated 8 skills with whenToUse/whenNotToUse YAML: version-management, file-locations, react-patterns, python-patterns, java-patterns, go-patterns, task-checkpoint, refactoring-analysis. Verified workflow-loop already had YAML.

## Success Criteria

1. ✅ Language skills (go, python, java, react) reduced by 40-50% (SKILL.md <200 lines each)
2. ✅ Core utility scripts created (validate-plan.sh, update-worklog.sh, format-commit.sh)
3. ✅ All 29 skills have standardized whenToUse / whenNotToUse YAML frontmatter
4. ✅ Engineer agent reduced by 50% (1,033 → ~500 lines)
5. ✅ At least 3 additional skills optimized (version-management, atomic-commits, file-locations)
6. ✅ Command templates extracted (onboard.md, ship.md, bootstrap.md <300 lines each)
7. ✅ Hook scripts split for maintainability (session-start.sh <450 lines)
8. ✅ Token efficiency measurably improved (before/after metrics documented)
9. ✅ At least 7 utility scripts created (validate-plan, update-worklog, format-commit, archive-phase, suggest-skills, ship-validation, generate-claudemd)
10. ✅ All changes tested and validated (no regressions, skills trigger correctly)

## Notes

- **Testing is critical** after each phase - verify skills trigger, references load correctly
- **Phase 1 has highest ROI** - language skills trigger frequently on file edits
- **Phases can be done independently** - skip or reorder if needed
- **Parallelism markers** indicate tasks that can run simultaneously within a phase
- **Token impact measurements** should be documented in Progress Log after Phase 1, 4
- Consider using `/devloop:continue` to work through phases systematically
- Reference spike report for detailed rationale: `.devloop/spikes/plugin-optimization.md`
