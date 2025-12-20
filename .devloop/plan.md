# Devloop Plan: Agent Consolidation v2.0

**Created**: 2025-12-20
**Updated**: 2025-12-20
**Status**: Active
**Current Phase**: Phase 1 Complete - Ready for Phase 2

## Overview

Implement the full architectural review recommendations: consolidate 18 agents into 12, apply XML prompt structure, add skill indexing, and automate log rotation.

**Review Reference**: `.claude/devloop-review-report.md`
**Spike Reference**: `.devloop/spikes/devloop-v2-consolidation.md`
**Prior Work**: Plugin Simplification v1.1 (Complete)

## Requirements

1. Reduce agent count from 18 to 12 via consolidation
2. Apply XML prompt structure to prevent agent drift
3. Create skill index for dynamic loading (28 skills)
4. Add worklog rotation script for context hygiene
5. Maintain backwards compatibility during transition

## Architecture

**Current State** (post v1.1):
- 18 agents with significant overlap
- 28 skills (language patterns consolidated)
- Commands reduced 50% via phase-templates
- Tool policies consolidated into single skill

**Target State** (v2.0):
- 12 agents (6 merged into 3 super-agents)
- Skill index for dynamic loading
- XML-structured core agent prompts
- Automated worklog maintenance

### Agent Consolidation Map

| To Delete | Merge Into |
|-----------|------------|
| code-architect.md | → engineer.md (NEW) |
| code-explorer.md | → engineer.md |
| refactor-analyzer.md | → engineer.md |
| test-generator.md | → qa-engineer.md (NEW) |
| test-runner.md | → qa-engineer.md |
| bug-catcher.md | → qa-engineer.md |
| issue-manager.md | → task-planner.md (ENHANCE) |
| requirements-gatherer.md | → task-planner.md |
| dod-validator.md | → task-planner.md |

## Tasks

### Phase 1: Agent Consolidation [parallel:partial]
**Goal**: Reduce agent count from 18 to 12 by merging overlapping agents

- [x] Task 1.1: Create engineer.md super-agent [parallel:A]
  - Acceptance: Merges code-architect, code-explorer, refactor-analyzer, git-manager
  - Files: `plugins/devloop/agents/engineer.md`
  - Notes: Created 280-line agent combining Explorer, Architect, Refactorer, Git modes

- [x] Task 1.2: Create qa-engineer.md super-agent [parallel:A]
  - Acceptance: Merges test-generator, test-runner, bug-catcher, qa-agent (merge into new qa-engineer.md, delete qa-agent.md)
  - Files: `plugins/devloop/agents/qa-engineer.md`
  - Notes: Created 290-line agent combining Generator, Runner, Bug Tracker, Validator modes

- [x] Task 1.3: Enhance task-planner.md [depends:1.1,1.2]
  - Acceptance: Absorbs issue-manager, requirements-gatherer, dod-validator
  - Files: `plugins/devloop/agents/task-planner.md`
  - Notes: Created 437-line agent with Planner, Requirements, Issue Manager, DoD Validator modes

- [x] Task 1.4: Update routing references [depends:1.3]
  - Acceptance: All commands, hooks, and docs reference new agents
  - Files: hooks/hooks.json, commands/devloop.md, skills/phase-templates/SKILL.md, docs/agents.md
  - Notes: Updated SubagentStop chaining, command phases, skill templates, rewrote agents.md for v2.0

- [x] Task 1.5: Delete merged agents [depends:1.4]
  - Acceptance: 11 old agent files removed (9 merged + git-manager + qa-agent)
  - Files: Deleted code-architect, code-explorer, refactor-analyzer, git-manager, test-generator, test-runner, bug-catcher, qa-agent, issue-manager, requirements-gatherer, dod-validator
  - Notes: 9 agents remain: engineer, qa-engineer, task-planner, code-reviewer, security-scanner, complexity-estimator, workflow-detector, doc-generator, summary-generator

### Phase 2: Prompt Hardening [parallel:none]
**Goal**: Apply XML structure to prevent agent drift

- [ ] Task 2.1: Create XML agent template
  - Acceptance: Template file with system_role, capabilities, workflow_enforcement sections
  - Files: `docs/templates/agent_prompt_structure.xml`
  - Notes: Follow structure from review report Section 3

- [ ] Task 2.2: Apply XML to engineer.md
  - Acceptance: Engineer agent uses XML structure with <thinking> enforcement
  - Files: `plugins/devloop/agents/engineer.md`
  - Notes: Test after conversion

- [ ] Task 2.3: Apply XML to qa-engineer.md
  - Acceptance: QA agent uses XML structure
  - Files: `plugins/devloop/agents/qa-engineer.md`
  - Notes: Test after conversion

- [ ] Task 2.4: Apply XML to task-planner.md
  - Acceptance: Task planner uses XML structure
  - Files: `plugins/devloop/agents/task-planner.md`
  - Notes: Test after conversion

- [ ] Task 2.5: Apply XML to code-reviewer.md
  - Acceptance: Code reviewer uses XML structure
  - Files: `plugins/devloop/agents/code-reviewer.md`
  - Notes: Test after conversion

### Phase 3: Skill Indexing [parallel:partial]
**Goal**: Enable dynamic skill loading to reduce token usage

- [ ] Task 3.1: Create skills INDEX.md [parallel:A]
  - Acceptance: Lists all 28 skills with 1-line summaries
  - Files: `plugins/devloop/skills/INDEX.md`
  - Notes: Categorize by type (language, workflow, domain)

- [ ] Task 3.2: Update SessionStart hook [parallel:A]
  - Acceptance: Hook loads INDEX.md instead of full skill list
  - Files: `plugins/devloop/hooks/session-start.sh`
  - Notes: Keep language detection, but use index for suggestions

- [ ] Task 3.3: Update task-planner to use index [depends:3.1]
  - Acceptance: Task planner reads INDEX.md first, loads specific skills on demand
  - Files: `plugins/devloop/agents/task-planner.md`
  - Notes: Add skill retrieval workflow

### Phase 4: Maintenance Automation [parallel:none]
**Goal**: Automate context hygiene

- [ ] Task 4.1: Create worklog rotation script
  - Acceptance: Script archives worklog when >500 lines
  - Files: `plugins/devloop/scripts/rotate-worklog.sh`
  - Notes: Archive to .devloop/archive/worklog-YYYY-MM-DD.md

- [ ] Task 4.2: Add rotation to SessionStart
  - Acceptance: Rotation runs automatically on session start
  - Files: `plugins/devloop/hooks/session-start.sh`
  - Notes: Only rotate if needed

- [ ] Task 4.3: Version bump to 2.0.0
  - Acceptance: Version updated, README documents major refactoring
  - Files: `plugins/devloop/.claude-plugin/plugin.json`, `plugins/devloop/README.md`
  - Notes: Document agent consolidation in changelog

## Progress Log

- 2025-12-20 22:00: Plan created from spike report and architectural review
- 2025-12-20 22:15: Completed Tasks 1.1, 1.2 - Created engineer.md (280 lines) and qa-engineer.md (290 lines) super-agents
- 2025-12-20 22:20: Completed Task 1.3 - Enhanced task-planner.md (437 lines) with 4 modes
- 2025-12-20 22:30: Completed Task 1.4 - Updated routing (hooks, commands, skills, docs)
- 2025-12-20 22:35: Completed Task 1.5 - Deleted 11 old agents (18 → 9)

## Notes

- Test each merged agent before deleting source agents
- Search codebase for all references before deletion
- XML structure should NOT break existing behavior
- Version 2.0.0 indicates breaking changes (agent renaming)
