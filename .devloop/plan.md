# Devloop Plan: Plugin Simplification v1.1

**Created**: 2025-12-19
**Updated**: 2025-12-19 13:00
**Status**: Active
**Current Phase**: 2

## Overview

Simplify the devloop plugin based on architecture spike findings. Target 40-50% reduction in total lines while maintaining functionality through hook-based automation, skill consolidation, and agent trimming.

**Spike Reference**: `.devloop/spikes/plugin-architecture-review.md`

## Requirements

1. Add hook-based smart routing for better UX
2. Reduce verbosity without losing functionality
3. Consolidate redundant components
4. Improve skill and agent invocation patterns
5. Maintain backwards compatibility

## Architecture

**Current State**:
- 59 components, ~18,800 lines
- Skills not being invoked deterministically
- Hooks underutilized (UserPromptSubmit, SubagentStop unused)
- Significant redundancy in language patterns and tool policies

**Target State**:
- ~45 components, ~10,000 lines
- Hook-based skill injection and smart routing
- Consolidated tool policies and language patterns
- Cleaner agent boundaries

## Tasks

### Phase 1: Quick Wins [parallel:partial]
**Goal**: High-impact, low-risk improvements
**Parallel Groups**:
- Group A: Tasks 1.1, 1.2 (independent consolidation)

- [x] Task 1.1: Add UserPromptSubmit hook for smart routing [parallel:A]
  - Acceptance: Hook detects task keywords and suggests appropriate command
  - Files: `plugins/devloop/hooks/hooks.json`
  - Notes: Added prompt hook that detects keywords and suggests devloop commands

- [x] Task 1.2: Create shared tool-usage-policy skill [parallel:A]
  - Acceptance: Single skill with tool usage guidance, agents reference it
  - Files: `plugins/devloop/skills/tool-usage-policy/SKILL.md`
  - Notes: Created 135-line skill with DO/DON'T patterns, tool selection table, parallelization strategy

- [x] Task 1.3: Remove deprecated bug-tracking skill [depends:1.2]
  - Acceptance: bug-tracking skill removed, references updated to issue-tracking
  - Files: Removed `plugins/devloop/skills/bug-tracking/`, updated 4 agents and 3 docs
  - Notes: Updated code-reviewer, bug-catcher, test-runner, dod-validator to use issue-tracking

- [x] Task 1.4: Trim refactor-analyzer agent [depends:1.2]
  - Acceptance: Agent reduced from 1,312 to 264 lines (80% reduction)
  - Files: `plugins/devloop/agents/refactor-analyzer.md`
  - Notes: References tool-usage-policy and refactoring-analysis skills, kept essential vetting and report templates

### Phase 2: Hook-Based Automation [parallel:partial]
**Goal**: Make skills and agents invoke more deterministically
**Parallel Groups**:
- Group A: Tasks 2.1, 2.2 (independent hook additions)

- [ ] Task 2.1: Add PreToolUse hook for language skill injection [parallel:A]
  - Acceptance: Editing .go files triggers go-patterns, .py triggers python-patterns
  - Files: `plugins/devloop/hooks/hooks.json`
  - Notes: Use prompt hook type to inject skill invocation hints

- [ ] Task 2.2: Add SubagentStop hook for agent chaining [parallel:A]
  - Acceptance: After code-explorer completes, suggest code-architect if designing
  - Files: `plugins/devloop/hooks/hooks.json`
  - Notes: Improves workflow continuity

- [ ] Task 2.3: Enhance SessionStart with skill preloading [depends:2.1]
  - Acceptance: Language skills listed in context based on detected stack
  - Files: `plugins/devloop/hooks/session-start.sh`
  - Notes: Add "Relevant skills: go-patterns, testing-strategies" to context

### Phase 3: Skill Consolidation [parallel:partial]
**Goal**: Reduce redundancy in language pattern skills
**Parallel Groups**:
- Group A: Tasks 3.1, 3.2 (independent skill work)

- [ ] Task 3.1: Create base language-patterns template [parallel:A]
  - Acceptance: Shared structure for all language skills
  - Files: `plugins/devloop/skills/language-patterns-base/SKILL.md`
  - Notes: Common sections: Error Handling, Testing, Project Structure, Anti-Patterns

- [ ] Task 3.2: Consolidate agent tool policies [parallel:A]
  - Acceptance: All 18 agents reference tool-usage-policy skill instead of inline policies
  - Files: All agent .md files
  - Notes: Each agent loses 50-100 lines

- [ ] Task 3.3: Refactor go-patterns to use base [depends:3.1]
  - Acceptance: go-patterns extends base, unique content only
  - Files: `plugins/devloop/skills/go-patterns/SKILL.md`
  - Notes: Target ~200 lines (down from 528)

- [ ] Task 3.4: Refactor python/java/react-patterns to use base [depends:3.3]
  - Acceptance: All language skills use base pattern
  - Files: `plugins/devloop/skills/{python,java,react}-patterns/SKILL.md`
  - Notes: Can be done in parallel per skill

### Phase 4: Command Optimization [parallel:none]
**Goal**: Reduce command verbosity through shared phase definitions

- [ ] Task 4.1: Create phase templates skill
  - Acceptance: Common phases (Discovery, Implementation, Review) defined once
  - Files: `plugins/devloop/skills/phase-templates/SKILL.md`
  - Notes: Commands reference phases instead of duplicating

- [ ] Task 4.2: Refactor devloop.md to use phase templates
  - Acceptance: devloop.md reduced from 533 to ~300 lines
  - Files: `plugins/devloop/commands/devloop.md`
  - Notes: Keep unique behavior, reference phases

- [ ] Task 4.3: Refactor continue.md to use phase templates
  - Acceptance: continue.md reduced from 533 to ~300 lines
  - Files: `plugins/devloop/commands/continue.md`
  - Notes: Significant overlap with devloop.md

- [ ] Task 4.4: Version bump to 1.13.0
  - Acceptance: Version updated, CHANGELOG documents simplification
  - Files: `plugins/devloop/.claude-plugin/plugin.json`, `plugins/devloop/README.md`
  - Notes: Minor version for non-breaking improvements

## Progress Log

- 2025-12-19 11:00: Plan created from spike report findings
- 2025-12-19 12:30: Completed Task 1.1 - Added UserPromptSubmit hook for smart command routing
- 2025-12-19 12:30: Completed Task 1.2 - Created tool-usage-policy skill (135 lines)
- 2025-12-19 12:35: Committed Tasks 1.1, 1.2 - 05f3883
- 2025-12-19 13:00: Completed Task 1.3 - Removed bug-tracking skill, updated 4 agents and 3 docs
- 2025-12-19 13:00: Completed Task 1.4 - Reduced refactor-analyzer from 1,312 to 264 lines (80% reduction)
- 2025-12-19 13:00: Phase 1 Complete! All 4 tasks done
- 2025-12-19 13:05: Committed Tasks 1.3, 1.4 - a7c5c95

## Notes

- Backwards compatibility is critical - don't break existing command/skill names
- Test each phase before proceeding to next
- Monitor token usage improvements after each phase
- Consider creating v2.0 plan for larger refactoring (agent merging, declarative commands)
