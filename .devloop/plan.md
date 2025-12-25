# Devloop Plan: Plugin Best Practices Audit Fixes

**Created**: 2025-12-25
**Updated**: 2025-12-25 16:30
**Status**: In Progress
**Current Phase**: Phase 1
**Estimate**: L (7-10 hours)

## Overview

Address findings from comprehensive plugin audit comparing devloop plugin against plugin-dev best practices. Focuses on:
1. Agent description format compliance (third-person, integrated examples)
2. Skill description format compliance (trigger phrases, third-person)
3. Progressive disclosure (move large content to references/)
4. Command length reduction (continue.md is 1526 lines)
5. Minor improvements (color field, manifest description)

## Architecture Choice

**Incremental Refactoring with Validation**

Breaking fixes into phases by priority:
- Phase 1: High-priority fixes (agent/skill descriptions) - immediate impact on triggering
- Phase 2: Progressive disclosure (large skills) - token efficiency
- Phase 3: Command optimization (continue.md) - maintainability
- Phase 4: Minor polish - completeness

**Why this approach:**
- Addresses triggering issues first (highest user impact)
- Progressive disclosure second (token efficiency)
- Command refactoring third (complex, requires careful testing)
- Each phase can be validated independently

## Tasks

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

- [ ] Task 1.5: Fix workflow-detector.md description [parallel:A]
  - Apply same pattern as Task 1.1
  - Convert Examples → integrated `<example>` blocks
  - Acceptance: Matches plugin-dev format
  - Files: `plugins/devloop/agents/workflow-detector.md`

- [ ] Task 1.6: Fix complexity-estimator.md description [parallel:A]
  - Apply same pattern as Task 1.1
  - Convert Examples → integrated `<example>` blocks
  - Acceptance: Matches plugin-dev format
  - Files: `plugins/devloop/agents/complexity-estimator.md`

- [ ] Task 1.7: Fix task-planner.md description (if exists) [parallel:A]
  - Check if task-planner.md exists
  - Apply same pattern if needed
  - Acceptance: Matches plugin-dev format or confirmed correct
  - Files: `plugins/devloop/agents/task-planner.md`

- [ ] Task 1.8: Fix summary-generator.md description (if exists) [parallel:A]
  - Check if summary-generator.md exists
  - Apply same pattern if needed
  - Acceptance: Matches plugin-dev format or confirmed correct
  - Files: `plugins/devloop/agents/summary-generator.md`

- [ ] Task 1.9: Fix doc-generator.md description (if exists) [parallel:A]
  - Check if doc-generator.md exists
  - Apply same pattern if needed
  - Acceptance: Matches plugin-dev format or confirmed correct
  - Files: `plugins/devloop/agents/doc-generator.md`

### Phase 2: Skill Description Format Fixes [parallel:none]
**Goal**: Add trigger phrases to skill descriptions using third-person format
**Complexity**: M-sized (2-3 hours)
**Dependencies**: Phase 1 complete (establishes pattern)

- [ ] Task 2.1: Audit all skill descriptions
  - List all 28+ skills in plugins/devloop/skills/
  - Identify which need trigger phrase improvements
  - Create prioritized list (core skills first)
  - **How**: Run `find plugins/devloop/skills -name "SKILL.md" -exec head -10 {} \;`
  - Acceptance: Complete list with priority ratings
  - Files: Working notes (can be temp file)

- [ ] Task 2.2: Fix plan-management skill description
  - Current: "Central reference for devloop plan file..."
  - **New**: "This skill should be used when the user asks about 'plan format', 'update plan', 'plan location', '.devloop/plan.md', 'plan markers', 'task status', or needs guidance on plan file conventions and update procedures."
  - Add "When NOT to Use" section if missing
  - Acceptance: Clear trigger phrases, third-person format
  - Files: `plugins/devloop/skills/plan-management/SKILL.md`

- [ ] Task 2.3: Fix workflow-loop skill description
  - Current: "Standard patterns for multi-task workflows..."
  - **New**: "This skill should be used when the user asks to 'implement checkpoints', 'workflow loop', 'task completion pattern', 'mandate checkpoints', or needs patterns for multi-task workflows with decision points."
  - Add "When NOT to Use" section
  - Acceptance: Clear trigger phrases, third-person format
  - Files: `plugins/devloop/skills/workflow-loop/SKILL.md`

- [ ] Task 2.4: Fix go-patterns skill description
  - Current: "Go-specific best practices..."
  - **New**: "This skill should be used when working with Go code, implementing Go features, reviewing Go patterns, or when the user asks about 'Go idioms', 'goroutines', 'Go interfaces', 'Go error handling', 'Go testing'."
  - Verify "When NOT to Use" section exists (it does at line 14-19)
  - Acceptance: Clear trigger phrases
  - Files: `plugins/devloop/skills/go-patterns/SKILL.md`

- [ ] Task 2.5: Fix remaining high-priority skill descriptions [parallel:B]
  - Apply same pattern to: react-patterns, python-patterns, java-patterns
  - Add trigger phrases for: architecture-patterns, api-design, database-patterns
  - **How**: For each, rewrite description with "This skill should be used when..."
  - Acceptance: All major skills have trigger phrases
  - Files: Multiple skill SKILL.md files

- [ ] Task 2.6: Add "When NOT to Use" sections to skills missing them
  - Review skills from Task 2.1 list
  - Add sections to: model-selection-guide, atomic-commits, worklog-management, api-design
  - **How**: Add after description frontmatter, before main content:
    ```markdown
    ## When NOT to Use This Skill
    - [Specific anti-pattern 1]
    - [Specific anti-pattern 2]
    ```
  - Acceptance: All skills have clear boundaries
  - Files: Multiple SKILL.md files

### Phase 3: Progressive Disclosure Improvements [parallel:none]
**Goal**: Apply progressive disclosure to large skills (move content to references/)
**Complexity**: M-sized (3-4 hours)
**Dependencies**: Phase 2 complete (ensures descriptions are clear)

- [ ] Task 3.1: Create references/ directory for workflow-loop skill
  - Current: 755 lines (~3,500 words) - TOO LARGE
  - **Target**: SKILL.md ~200 lines, rest in references/
  - **How**:
    1. Create `plugins/devloop/skills/workflow-loop/references/`
    2. Extract sections to new files:
       - `references/checkpoint-patterns.md` - Lines 119-238 (checkpoint sequence)
       - `references/state-transitions.md` - Lines 271-321 (transition table, diagram)
       - `references/error-recovery.md` - Lines 323-397 (recovery patterns)
       - `references/examples.md` - Lines 532-631 (good vs bad patterns)
    3. Keep in SKILL.md: Overview, core loop diagram, quick reference
    4. Add references section pointing to new files
  - Acceptance: SKILL.md <300 lines, detailed content in references/
  - Files: `plugins/devloop/skills/workflow-loop/SKILL.md`, `references/*.md`

- [ ] Task 3.2: Create references/ directory for plan-management skill
  - Current: 553 lines (~2,500 words) - SLIGHTLY LARGE
  - **Target**: SKILL.md ~250 lines, detailed content in references/
  - **How**:
    1. Create `plugins/devloop/skills/plan-management/references/`
    2. Extract sections:
       - `references/archive-format.md` - Archive format and procedures (lines 80-178)
       - `references/parallelism-guide.md` - Parallelism markers and guidelines (lines 198-293)
       - `references/enforcement-modes.md` - Advisory/strict mode details (lines 415-503)
    3. Keep in SKILL.md: Plan location, format, update rules, quick reference
  - Acceptance: SKILL.md <300 lines, references/ has detailed guides
  - Files: `plugins/devloop/skills/plan-management/SKILL.md`, `references/*.md`

- [ ] Task 3.3: Audit testing-strategies and other large skills
  - Check sizes of: testing-strategies, architecture-patterns, deployment-readiness
  - Apply same pattern if >400 lines
  - Create references/ directories as needed
  - Acceptance: No skill SKILL.md >400 lines
  - Files: Multiple skills

- [ ] Task 3.4: Update skills to reference new reference files
  - Add reference section to each skill that now has references/
  - Format:
    ```markdown
    ## Additional Resources

    ### Reference Files

    For detailed patterns, consult:
    - **`references/checkpoint-patterns.md`** - Complete checkpoint sequence
    - **`references/state-transitions.md`** - State diagrams and transition table
    ```
  - Acceptance: All references documented in SKILL.md
  - Files: Updated SKILL.md files

### Phase 4: Command Length Reduction [parallel:none]
**Goal**: Reduce continue.md from 1526 lines to ~400 lines by referencing skills
**Complexity**: L-sized (4-5 hours) - COMPLEX, REQUIRES CAREFUL TESTING
**Dependencies**: Phase 3 complete (references exist to point to)

- [ ] Task 4.1: Analyze continue.md content overlap
  - Identify sections that duplicate skill content
  - Map sections to skills:
    - Step 5a (checkpoint) → workflow-loop skill
    - Step 1a-1b (plan finding) → plan-management skill
    - Step 5b (completion detection) → plan-management skill
    - Context management → workflow-loop skill
  - Create mapping document
  - **How**: Read continue.md in sections, note which skills cover same content
  - Acceptance: Complete mapping of continue.md → skills
  - Files: `.devloop/continue-refactor-map.md` (working doc)

- [ ] Task 4.2: Create streamlined continue.md structure
  - **New structure** (~400 lines):
    ```markdown
    # Continue from Plan

    ## Step 1: Find and Read Plan
    See `Skill: plan-management` for plan discovery details.
    [Minimal implementation - 50 lines]

    ## Step 2: Parse and Present Status
    [Keep as-is - essential - 100 lines]

    ## Step 3: Classify Next Task
    [Keep as-is - essential - 50 lines]

    ## Step 4: Present Options
    [Keep as-is - essential - 50 lines]

    ## Step 5: Execute with Agent
    [Keep as-is - essential - 100 lines]

    ## Step 5a: MANDATORY Checkpoint
    See `Skill: workflow-loop` for checkpoint details.
    See `Skill: task-checkpoint` for checkpoint verification.
    [Minimal implementation - 50 lines]

    ## Step 5b: Loop Completion Detection
    See `Skill: plan-management` for completion patterns.
    [Minimal implementation - 50 lines]

    ## References
    - `Skill: workflow-loop` - Checkpoint patterns
    - `Skill: plan-management` - Plan format and updates
    - `Skill: task-checkpoint` - Task completion verification
    ```
  - **How**:
    1. Create new file `continue-v2.md`
    2. Copy essential sections (Steps 2-5)
    3. Replace detailed sections with skill references
    4. Add skill invocations where needed
  - Acceptance: New version <500 lines, references skills appropriately
  - Files: `plugins/devloop/commands/continue-v2.md`

- [ ] Task 4.3: Test streamlined continue.md
  - Backup original: `mv continue.md continue-v1-backup.md`
  - Deploy new version: `mv continue-v2.md continue.md`
  - Test scenarios:
    1. Resume from plan with pending tasks
    2. Resume from fresh start (next-action.json)
    3. Complete all tasks → routing
    4. Error recovery
    5. Parallel task detection
  - **How**: Run `/devloop:continue` with test plan in place
  - Acceptance: All scenarios work correctly
  - Files: `plugins/devloop/commands/continue.md`

- [ ] Task 4.4: Document continue.md refactoring
  - Add note to CHANGELOG.md
  - Update testing.md with new structure
  - Document skill dependencies
  - Acceptance: Changes documented
  - Files: `CHANGELOG.md`, `docs/testing.md`

### Phase 5: Minor Polish [parallel:none]
**Goal**: Fix small issues for completeness
**Complexity**: XS-sized (1 hour)
**Dependencies**: None (can run anytime)

- [ ] Task 5.1: Shorten plugin.json description
  - Current: 348 characters (too long, reads like changelog)
  - **New**: "Complete feature development workflow with intelligent agents, plan management, and context optimization. Includes spike exploration, issue tracking, code review, and git integration." (~180 chars)
  - Acceptance: Description <200 chars, user-focused
  - Files: `plugins/devloop/.claude-plugin/plugin.json`

- [ ] Task 5.2: Verify skills INDEX.md is current
  - Compare INDEX.md to actual skills/ directory
  - Add any missing skills
  - Remove any deleted skills
  - Acceptance: INDEX.md matches reality
  - Files: `plugins/devloop/skills/INDEX.md`

- [ ] Task 5.3: Document 'skills' field in agent frontmatter
  - Check if this is standard or devloop-specific
  - If custom: document in agents.md
  - If standard: verify it works as expected
  - Acceptance: Feature documented or verified
  - Files: `plugins/devloop/docs/agents.md`

- [ ] Task 5.4: Consider hook prompt extraction
  - Review hooks.json for very long inline prompts
  - Extract Stop hook prompt (50+ lines) to separate file if beneficial
  - **Decision point**: If extraction makes sense, do it; else skip
  - Acceptance: Decision documented, improvements made if applicable
  - Files: `plugins/devloop/hooks/hooks.json` or new prompt files

## Progress Log

- 2025-12-25 12:00: Plan created from plugin audit findings
- 2025-12-25 15:30: Completed Task 1.1 - Fixed engineer.md description format (third-person, integrated examples, color changed to blue)
- 2025-12-25 15:45: Completed Task 1.2 - Fixed code-reviewer.md description format (third-person, integrated examples, added third example for PR/commit scenario)
- 2025-12-25 16:00: Completed Task 1.3 - Fixed qa-engineer.md description format (third-person, integrated 4 examples: test generation, test execution, bug tracking, deployment validation)
- 2025-12-25 16:15: Fresh start initiated - state saved to next-action.json
- 2025-12-25 16:30: Completed Task 1.4 - Fixed security-scanner.md description format (third-person, integrated 3 examples covering input handling, auth code, and pre-deployment security checks)

## Success Criteria

1. ✓ All agent descriptions use third-person format with integrated `<example>` blocks
2. ✓ All skill descriptions have clear trigger phrases ("This skill should be used when...")
3. ✓ All skills have "When NOT to Use" sections
4. ✓ No skill SKILL.md exceeds 400 lines (detailed content in references/)
5. ✓ continue.md reduced from 1526 lines to <500 lines
6. ✓ continue.md references skills instead of duplicating content
7. ✓ All tests pass after continue.md refactoring
8. ✓ Plugin.json description shortened and user-focused
9. ✓ Skills INDEX.md is current
10. ✓ All changes documented in CHANGELOG.md

## Notes

- **Testing is critical** for Phase 4 (continue.md refactoring) - this is a high-risk change
- **Phases 1-2 can be parallelized** at the task level (agent/skill fixes are independent)
- **Phase 3 benefits from Phase 2** being complete (ensures descriptions are good before extracting content)
- **Phase 5 is independent** and can be done anytime
- Consider using `/devloop:quick` for individual tasks in Phases 1-2 (many are simple edits)
