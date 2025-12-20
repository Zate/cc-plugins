# Devloop Plan: Component Polish v2.1

**Created**: 2025-12-21
**Updated**: 2025-12-21
**Status**: Active
**Current Phase**: Phase 1 - Agent Enhancement

## Overview

Comprehensive review of all devloop components to improve agent invocation reliability, description quality, XML prompt consistency, and background execution patterns.

**Prior Work**: Agent Consolidation v2.0 (Complete), Agent Invocation Spike (Complete)
**Spike Reference**: `.devloop/spikes/agent-invocation-testing.md`

## Component Inventory

| Type | Count | Review Focus |
|------|-------|--------------|
| Agents | 9 | Descriptions, examples, XML structure, delegation |
| Commands | 16 | Agent routing, explicit Task invocation |
| Skills | 28 | Descriptions, when-to-use, when-NOT-to-use |
| Hooks | 14 | Consistency, logging, validation |

## Requirements

1. All agent descriptions must clearly indicate invocation triggers
2. All commands must explicitly route to agents via Task tool
3. All skills must have specific "when to use" and "when NOT to use"
4. Background execution patterns documented where applicable
5. XML prompt structure consistent across all agents
6. Hook logging for debugging agent invocations

## Tasks

### Phase 1: Agent Enhancement [parallel:partial]
**Goal**: Ensure all 9 agents have optimal descriptions, examples, and XML structure

- [ ] Task 1.1: Review engineer.md [parallel:A]
  - Check description triggers invocation for exploration/architecture/git tasks
  - Verify examples show `devloop:engineer` in assistant responses
  - Ensure XML structure matches template
  - Add background execution guidance
  - Files: `plugins/devloop/agents/engineer.md`

- [ ] Task 1.2: Review qa-engineer.md [parallel:A]
  - Check description triggers for testing/validation tasks
  - Verify examples use `devloop:qa-engineer`
  - Ensure XML structure complete
  - Files: `plugins/devloop/agents/qa-engineer.md`

- [ ] Task 1.3: Review task-planner.md [parallel:A]
  - Check description for planning/requirements/DoD triggers
  - Verify examples use `devloop:task-planner`
  - Ensure XML structure complete
  - Files: `plugins/devloop/agents/task-planner.md`

- [ ] Task 1.4: Review code-reviewer.md [parallel:B]
  - Check description triggers for review/audit tasks
  - Verify examples use `devloop:code-reviewer`
  - Ensure XML structure complete
  - Files: `plugins/devloop/agents/code-reviewer.md`

- [ ] Task 1.5: Review remaining 5 agents [parallel:B]
  - complexity-estimator, security-scanner, doc-generator, summary-generator, workflow-detector
  - Apply same checks as above
  - Files: `plugins/devloop/agents/*.md`

- [ ] Task 1.6: Create agent description guidelines [depends:1.1-1.5]
  - Document best practices learned
  - Add to docs/agents.md
  - Files: `plugins/devloop/docs/agents.md`

### Phase 2: Command Agent Routing [parallel:partial]
**Goal**: All 16 commands explicitly route to appropriate agents

- [ ] Task 2.1: Audit high-use commands [parallel:A]
  - continue.md ✓ (already enhanced)
  - spike.md ✓ (already enhanced)
  - devloop.md (verify agent routing)
  - quick.md (add agent routing)
  - Files: `plugins/devloop/commands/{continue,spike,devloop,quick}.md`

- [ ] Task 2.2: Audit issue/bug commands [parallel:A]
  - bugs.md, bug.md, issues.md, new.md
  - Add agent routing to qa-engineer or task-planner
  - Files: `plugins/devloop/commands/{bugs,bug,issues,new}.md`

- [ ] Task 2.3: Audit workflow commands [parallel:B]
  - review.md, ship.md, analyze.md
  - Add explicit agent routing
  - Files: `plugins/devloop/commands/{review,ship,analyze}.md`

- [ ] Task 2.4: Audit setup commands [parallel:B]
  - bootstrap.md, onboard.md, golangci-setup.md, statusline.md, worklog.md
  - Determine if agent routing needed
  - Files: `plugins/devloop/commands/*.md`

- [ ] Task 2.5: Add background execution patterns [depends:2.1-2.4]
  - Update commands that benefit from parallel agent execution
  - Document `run_in_background: true` usage
  - Files: Commands with parallel phases

### Phase 3: Skill Refinement [parallel:partial]
**Goal**: All 28 skills have clear invocation triggers

- [ ] Task 3.1: Audit pattern skills [parallel:A]
  - go-patterns, react-patterns, java-patterns, python-patterns
  - Ensure descriptions trigger on file type/context
  - Add clear "when NOT to use"
  - Files: `plugins/devloop/skills/*-patterns/SKILL.md`

- [ ] Task 3.2: Audit workflow skills [parallel:A]
  - phase-templates, plan-management, worklog-management, workflow-selection
  - Ensure descriptions match command triggers
  - Files: `plugins/devloop/skills/*/SKILL.md`

- [ ] Task 3.3: Audit quality skills [parallel:B]
  - testing-strategies, security-checklist, deployment-readiness, complexity-estimation
  - Ensure descriptions trigger in appropriate contexts
  - Files: `plugins/devloop/skills/*/SKILL.md`

- [ ] Task 3.4: Audit design skills [parallel:B]
  - architecture-patterns, api-design, database-patterns
  - Ensure descriptions trigger for design tasks
  - Files: `plugins/devloop/skills/*/SKILL.md`

- [ ] Task 3.5: Audit remaining skills [depends:3.1-3.4]
  - tool-usage-policy, model-selection-guide, issue-tracking, etc.
  - Apply same checks
  - Files: All remaining skills

- [ ] Task 3.6: Update skill INDEX.md [depends:3.5]
  - Ensure index reflects improved descriptions
  - Files: `plugins/devloop/skills/INDEX.md`

### Phase 4: Hook Integration [parallel:none]
**Goal**: Hooks support debugging and consistent behavior

- [ ] Task 4.1: Fix Task invocation logging hook
  - Debug stdin JSON format issue
  - Test in fresh session
  - Files: `plugins/devloop/hooks/log-task-invocation.sh`

- [ ] Task 4.2: Review PreToolUse hooks
  - Ensure consistent behavior
  - Add logging for debugging
  - Files: `plugins/devloop/hooks/hooks.json`

- [ ] Task 4.3: Review SubagentStop chaining
  - Verify agent chaining logic
  - Test transitions work correctly
  - Files: `plugins/devloop/hooks/hooks.json`

### Phase 5: Documentation & Testing [parallel:none]
**Goal**: Document changes and validate

- [ ] Task 5.1: Update README.md
  - Document agent invocation patterns
  - Add background execution examples
  - Files: `plugins/devloop/README.md`

- [ ] Task 5.2: Update docs/agents.md
  - Comprehensive agent reference
  - Invocation examples
  - Files: `plugins/devloop/docs/agents.md`

- [ ] Task 5.3: Create testing checklist
  - Manual validation steps
  - Expected agent invocations per command
  - Files: `plugins/devloop/docs/testing.md`

- [ ] Task 5.4: Version bump to 2.1.0
  - Update plugin.json
  - Update changelog
  - Files: `plugins/devloop/.claude-plugin/plugin.json`

## Progress Log

- 2025-12-21: Plan created from spike findings and user feedback
- 2025-12-21: continue.md and spike.md already enhanced with agent routing

## Notes

- Test agent invocations by watching status line for `devloop:agent-name`
- Use `~/.devloop-agent-invocations.log` for debugging (requires hook fix)
- Background execution: `run_in_background: true` + `TaskOutput` to collect
- XML template reference: `plugins/devloop/docs/templates/agent_prompt_structure.xml`

## Success Criteria

1. Running `/devloop:continue` shows appropriate agent in status bar
2. All commands route to specific agents based on task type
3. Skills are invoked automatically based on file context
4. Background parallel execution works for multi-agent phases
5. Hook logging captures all Task invocations
