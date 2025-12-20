# Devloop Plan: Plugin Simplification v1.1

**Created**: 2025-12-19
**Updated**: 2025-12-20 17:00
**Status**: Complete
**Current Phase**: Done

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

- [x] Task 2.1: Add PreToolUse hook for language skill injection [parallel:A]
  - Acceptance: Editing .go files triggers go-patterns, .py triggers python-patterns
  - Files: `plugins/devloop/hooks/hooks.json`
  - Notes: Added Write|Edit matcher that suggests language-specific skills based on file extension

- [x] Task 2.2: Add SubagentStop hook for agent chaining [parallel:A]
  - Acceptance: After code-explorer completes, suggest code-architect if designing
  - Files: `plugins/devloop/hooks/hooks.json`
  - Notes: Added SubagentStop event with agent chaining rules for workflow continuity

- [x] Task 2.3: Enhance SessionStart with skill preloading [depends:2.1]
  - Acceptance: Language skills listed in context based on detected stack
  - Files: `plugins/devloop/hooks/session-start.sh`
  - Notes: Added get_relevant_skills function that maps language/framework/project-type to skills

### Phase 3: Skill Consolidation [parallel:partial]
**Goal**: Reduce redundancy in language pattern skills
**Parallel Groups**:
- Group A: Tasks 3.1, 3.2 (independent skill work)

- [x] Task 3.1: Create base language-patterns template [parallel:A]
  - Acceptance: Shared structure for all language skills
  - Files: `plugins/devloop/skills/language-patterns-base/SKILL.md`
  - Notes: Created 240-line base template with universal sections: Error Handling, Testing, Project Structure, Anti-Patterns, Code Style

- [x] Task 3.2: Consolidate agent tool policies [parallel:A]
  - Acceptance: All 18 agents reference tool-usage-policy skill instead of inline policies
  - Files: All agent .md files (17 updated, 1 already done)
  - Notes: All 17 agents now reference tool-usage-policy skill, removed inline Efficiency sections

- [x] Task 3.3: Refactor go-patterns to use base [depends:3.1]
  - Acceptance: go-patterns extends base, unique content only
  - Files: `plugins/devloop/skills/go-patterns/SKILL.md`
  - Notes: Reduced from 529 to 388 lines (27% reduction), references base for universal principles

- [x] Task 3.4: Refactor python/java/react-patterns to use base [depends:3.3]
  - Acceptance: All language skills use base pattern
  - Files: `plugins/devloop/skills/{python,java,react}-patterns/SKILL.md`
  - Notes: Added "Extends" headers, base references, updated See Also sections, added Quick Reference to python-patterns

### Phase 4: Command Optimization [parallel:none]
**Goal**: Reduce command verbosity through shared phase definitions

- [x] Task 4.1: Create phase templates skill
  - Acceptance: Common phases (Discovery, Implementation, Review) defined once
  - Files: `plugins/devloop/skills/phase-templates/SKILL.md`
  - Notes: Created 460-line skill with all workflow phases, checkpoints, and recovery templates

- [x] Task 4.2: Refactor devloop.md to use phase templates
  - Acceptance: devloop.md reduced from 533 to ~300 lines
  - Files: `plugins/devloop/commands/devloop.md`
  - Notes: Reduced from 534 to 262 lines (51% reduction), references phase-templates skill

- [x] Task 4.3: Refactor continue.md to use phase templates
  - Acceptance: continue.md reduced from 533 to ~300 lines
  - Files: `plugins/devloop/commands/continue.md`
  - Notes: Reduced from 534 to 228 lines (57% reduction), references phase-templates skill

- [x] Task 4.4: Version bump to 1.13.0
  - Acceptance: Version updated, CHANGELOG documents simplification
  - Files: `plugins/devloop/.claude-plugin/plugin.json`, `plugins/devloop/README.md`
  - Notes: Updated version to 1.13.0, skill count to 27, updated description

## Progress Log

- 2025-12-19 11:00: Plan created from spike report findings
- 2025-12-19 12:30: Completed Task 1.1 - Added UserPromptSubmit hook for smart command routing
- 2025-12-19 12:30: Completed Task 1.2 - Created tool-usage-policy skill (135 lines)
- 2025-12-19 12:35: Committed Tasks 1.1, 1.2 - 05f3883
- 2025-12-19 13:00: Completed Task 1.3 - Removed bug-tracking skill, updated 4 agents and 3 docs
- 2025-12-19 13:00: Completed Task 1.4 - Reduced refactor-analyzer from 1,312 to 264 lines (80% reduction)
- 2025-12-19 13:00: Phase 1 Complete! All 4 tasks done
- 2025-12-19 13:05: Committed Tasks 1.3, 1.4 - a7c5c95
- 2025-12-20 10:30: Completed Task 2.1 - Added PreToolUse hook for language skill injection (.go/.py/.java/.tsx)
- 2025-12-20 10:30: Completed Task 2.2 - Added SubagentStop hook for agent chaining workflow
- 2025-12-20 10:35: Committed Tasks 2.1, 2.2 - 692e651
- 2025-12-20 12:15: Completed Task 2.3 - Added skill preloading to SessionStart hook
- 2025-12-20 12:15: Phase 2 Complete! All 3 tasks done
- 2025-12-20 12:20: Committed Task 2.3 - 939b20c
- 2025-12-20 14:30: Completed Task 3.1 - Created language-patterns-base skill (240 lines)
- 2025-12-20 14:30: Completed Task 3.2 - Updated all 17 agents to reference tool-usage-policy
- 2025-12-20 14:35: Committed Tasks 3.1, 3.2 - 7cd7d65
- 2025-12-20 15:45: Completed Task 3.3 - Refactored go-patterns to extend base (529→388 lines, 27% reduction)
- 2025-12-20 15:50: Committed Task 3.3 - 5f5bd7c
- 2025-12-20 16:15: Completed Task 3.4 - Refactored python/java/react-patterns to extend base
- 2025-12-20 16:20: Committed Task 3.4 - 59ef49e
- 2025-12-20 16:20: Phase 3 Complete! All 4 tasks done
- 2025-12-20 16:45: Completed Task 4.1 - Created phase-templates skill (460 lines)
- 2025-12-20 16:50: Completed Task 4.2 - Refactored devloop.md (534→262 lines, 51% reduction)
- 2025-12-20 16:55: Completed Task 4.3 - Refactored continue.md (534→228 lines, 57% reduction)
- 2025-12-20 17:00: Completed Task 4.4 - Version bump to 1.13.0
- 2025-12-20 17:00: Phase 4 Complete! All tasks done
- 2025-12-20 17:05: Committed Phase 4 - 10d32c9
- 2025-12-20 17:05: Plan Complete! 🎉

## Notes

- Backwards compatibility is critical - don't break existing command/skill names
- Test each phase before proceeding to next
- Monitor token usage improvements after each phase
- Consider creating v2.0 plan for larger refactoring (agent merging, declarative commands)
