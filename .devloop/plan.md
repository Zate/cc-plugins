# Devloop Plan: Component Polish v2.1

**Created**: 2025-12-21
**Updated**: 2025-12-22
**Status**: Active
**Current Phase**: Phase 6 - Plan Archival

## Overview

Comprehensive review and enhancement of all devloop components to improve:
- Agent invocation reliability and description quality (Phases 1-2)
- Command routing and XML prompt consistency (Phases 1-2)
- Plan archival and compression (Phase 6)
- Engineer agent capabilities and mode handling (Phases 7-8)
- Workflow loop enforcement and checkpoints (Phases 9-10)
- Context management and fresh start mechanism (Phase 10)
- Integration quality and documentation (Phase 11)

**Prior Work**: Agent Consolidation v2.0 (Complete), Agent Invocation Spike (Complete)
**Spike Reference**: `.devloop/spikes/agent-invocation-testing.md`

## Component Inventory

| Type | Count | Review Focus (Phases 1-6) | Enhancement Focus (Phases 7-11) |
|------|-------|---------------------------|----------------------------------|
| Agents | 9 | Descriptions, XML structure, delegation | Engineer capabilities, mode handling, output formats |
| Commands | 16 | Agent routing, Task invocation | Workflow loop, checkpoints, fresh start |
| Skills | 28 → 29 | When-to-use clarity | Add workflow-loop skill, enhance task-checkpoint |
| Hooks | 14 | Logging, validation | Fresh start detection, SubagentStop cleanup |
| Docs | N/A | N/A | AskUserQuestion standards, workflow patterns |

## Requirements

**Phases 1-2 (Complete):**
1. ✓ All agent descriptions clearly indicate invocation triggers
2. ✓ All commands explicitly route to agents via Task tool
3. Skills have specific "when to use" and "when NOT to use" (Phase 3 in progress)
4. ✓ Background execution patterns documented
5. ✓ XML prompt structure consistent across all agents
6. Hook logging for debugging (Phase 4 pending)

**Phases 7-11 (Planned):**
1. Engineer agent has missing skills (complexity-estimation, project-context, etc.)
2. Workflow loop enforces mandatory checkpoints
3. Fresh start mechanism enables context clearing with state preservation
4. AskUserQuestion patterns standardized across all commands
5. Worklog sync enforcement at every checkpoint
6. Spike findings can be applied to plans programmatically

## Tasks

### Phase 1: Agent Enhancement [parallel:partial]
**Goal**: Ensure all 9 agents have optimal descriptions, examples, and XML structure

- [x] Task 1.1: Review engineer.md [parallel:A]
  - Check description triggers invocation for exploration/architecture/git tasks ✓
  - Verify examples show `devloop:engineer` in assistant responses ✓
  - Ensure XML structure matches template ✓
  - Add background execution guidance ✓ (has delegation section)
  - Files: `plugins/devloop/agents/engineer.md`

- [x] Task 1.2: Review qa-engineer.md [parallel:A]
  - Check description triggers for testing/validation tasks ✓
  - Verify examples use `devloop:qa-engineer` ✓
  - Ensure XML structure complete ✓
  - Files: `plugins/devloop/agents/qa-engineer.md`

- [x] Task 1.3: Review task-planner.md [parallel:A]
  - Check description for planning/requirements/DoD triggers ✓
  - Verify examples use `devloop:task-planner` ✓
  - Ensure XML structure complete ✓
  - Files: `plugins/devloop/agents/task-planner.md`

- [x] Task 1.4: Review code-reviewer.md [parallel:B]
  - Check description triggers for review/audit tasks ✓
  - Verify examples use `devloop:code-reviewer` ✓
  - Ensure XML structure complete ✓
  - Files: `plugins/devloop/agents/code-reviewer.md`

- [x] Task 1.5: Review remaining 5 agents [parallel:B]
  - complexity-estimator ✓ (added XML structure, examples already correct)
  - security-scanner ✓ (fixed examples, added XML structure)
  - doc-generator ✓ (fixed examples, added XML structure)
  - summary-generator ✓ (fixed examples, added XML structure)
  - workflow-detector ✓ (fixed examples, added XML structure)
  - Files: `plugins/devloop/agents/*.md`

- [x] Task 1.6: Create agent description guidelines [depends:1.1-1.5]
  - Document best practices learned ✓
  - Add to docs/agents.md ✓ (added "Writing Agent Descriptions" section)
  - Files: `plugins/devloop/docs/agents.md`

### Phase 2: Command Agent Routing [parallel:partial]
**Goal**: All 16 commands explicitly route to appropriate agents

- [x] Task 2.1: Audit high-use commands [parallel:A]
  - continue.md ✓ (already enhanced with agent routing table)
  - spike.md ✓ (already enhanced with agent routing table)
  - devloop.md ✓ (verified agent routing throughout)
  - quick.md ✓ (command-driven by design, no complex agent routing needed)
  - Files: `plugins/devloop/commands/{continue,spike,devloop,quick}.md`

- [x] Task 2.2: Audit issue/bug commands [parallel:A]
  - bugs.md, bug.md, issues.md, new.md ✓
  - Fixed old "code-explorer" references to `devloop:engineer`
  - Added Agent Routing sections to bugs.md and issues.md
  - Files: `plugins/devloop/commands/{bugs,bug,issues,new}.md`

- [x] Task 2.3: Audit workflow commands [parallel:B]
  - review.md ✓ (already had proper routing)
  - ship.md ✓ (fixed old agent names: dod-validator, test-runner, git-manager)
  - analyze.md ✓ (fixed old refactor-analyzer reference)
  - Added Agent Routing sections
  - Files: `plugins/devloop/commands/{review,ship,analyze}.md`

- [x] Task 2.4: Audit setup commands [parallel:B]
  - bootstrap.md, onboard.md, golangci-setup.md, statusline.md, worklog.md ✓
  - Setup commands are command-driven, no agent routing needed
  - Files: `plugins/devloop/commands/*.md`

- [x] Task 2.5: Add background execution patterns [depends:2.1-2.4]
  - Patterns already documented in continue.md (run_in_background: true)
  - Parallel execution documented in phase-templates/SKILL.md
  - devloop.md and review.md show parallel agent patterns ✓
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

### Phase 6: Plan Archival [parallel:none]
**Goal**: Implement plan archival to compress large plans and integrate Progress Log with worklog
**Reference**: `.devloop/spikes/plan-archival.md` (Spike complete)

- [x] Task 6.1: Create `/devloop:archive` command
  - Detect completed phases (all tasks `[x]`) ✓
  - Archive to `.devloop/archive/{name}_{timestamp}.md` ✓
  - Extract Progress Log to worklog.md ✓
  - Compress active plan.md (keep metadata, overview, active phases, last 10 Progress Log entries) ✓
  - Files: `plugins/devloop/commands/archive.md` ✓

- [x] Task 6.2: Update `/devloop:continue` for archive references
  - Handle archived phase references gracefully ✓
  - Add "see archive" messaging when relevant ✓
  - Added archive awareness to Step 1 (find plan) ✓
  - Enhanced Step 2 with archive detection and status display ✓
  - Added archive recovery scenarios ✓
  - Added archive tips ✓
  - Files: `plugins/devloop/commands/continue.md` ✓

- [ ] Task 6.3: Update pre-commit hook for archive awareness
  - Archive-aware grep patterns
  - Skip archived headers in validation
  - Files: `plugins/devloop/hooks/pre-commit.sh`

- [ ] Task 6.4: Update plan-management skill
  - Document archive format
  - Add "when to archive" guidance
  - Files: `plugins/devloop/skills/plan-management/SKILL.md`

- [ ] Task 6.5: Test and validate archival workflow
  - Test on current plan (209 lines)
  - Verify compression works (target ~50% reduction)
  - Validate continue workflow with archived plans
  - Manual QA of archive files
  - Files: Testing on `.devloop/plan.md`

### Phase 7: Foundation - Skills & Patterns [parallel:partial]
**Goal**: Add missing skills and standardize patterns for engineer agent and workflow improvements
**Reference**: `.devloop/spikes/engineer-agent-improvements.md`, `.devloop/spikes/continue-improvements.md`

- [ ] Task 7.1: Add missing skills to engineer.md [parallel:A]
  - Add complexity-estimation skill
  - Add project-context skill
  - Add task-checkpoint skill
  - Add api-design skill
  - Add database-patterns skill
  - Add testing-strategies skill
  - Remove or clarify refactoring-analysis conflict
  - Files: `plugins/devloop/agents/engineer.md`

- [ ] Task 7.2: Create workflow-loop skill [parallel:A]
  - Document standard workflow loop pattern
  - Add checkpoint requirements
  - Define state transitions
  - Include error recovery patterns
  - Add context management thresholds
  - Files: `plugins/devloop/skills/workflow-loop/SKILL.md`

- [ ] Task 7.3: Create AskUserQuestion standards document [parallel:B]
  - When to ALWAYS ask vs NEVER ask
  - Question batching patterns
  - Standard checkpoint question format
  - Standard error question format
  - Token-conscious guidelines
  - Files: `plugins/devloop/docs/ask-user-question-standards.md`

### Phase 8: Engineer Agent Enhancements [parallel:partial]
**Goal**: Improve engineer agent prompts, modes, and capabilities
**Reference**: `.devloop/spikes/engineer-agent-improvements.md`

- [ ] Task 8.1: Add core prompt enhancements to engineer.md [parallel:A]
  - Add model escalation guidance (when to suggest opus)
  - Add anti-pattern constraints section
  - Add limitations/self-awareness section
  - Files: `plugins/devloop/agents/engineer.md`

- [ ] Task 8.2: Improve skill integration in engineer.md [parallel:A]
  - Add skill workflow section (which skills in which modes)
  - Document skill invocation order per mode
  - Add examples of skill combinations
  - Files: `plugins/devloop/agents/engineer.md`

- [ ] Task 8.3: Enhance mode handling in engineer.md [parallel:B]
  - Add complexity-aware mode selection
  - Add cross-mode task awareness
  - Document multi-mode workflows
  - Files: `plugins/devloop/agents/engineer.md`

- [ ] Task 8.4: Add output format standards to engineer.md [parallel:B]
  - Structured exploration output format (tables, flow, components)
  - Token-conscious output guidelines
  - Consistent file reference format (file:line)
  - Files: `plugins/devloop/agents/engineer.md`

- [ ] Task 8.5: Enhance delegation in engineer.md [parallel:C]
  - Expand delegation table (all 9 agents)
  - Add when-to-delegate criteria
  - Document delegation vs direct execution
  - Files: `plugins/devloop/agents/engineer.md`

- [ ] Task 8.6: Add workflow awareness to engineer.md [parallel:C]
  - Parallel execution awareness
  - Plan synchronization checkpoint
  - Task completion status reporting
  - Files: `plugins/devloop/agents/engineer.md`

### Phase 9: Workflow Loop Core Improvements [parallel:none]
**Goal**: Fix workflow loop with mandatory checkpoints and completion detection
**Reference**: `.devloop/spikes/continue-improvements.md`
**Dependencies**: Phase 7 must be complete (workflow-loop skill, AskUserQuestion standards)

- [ ] Task 9.1: Add mandatory post-task checkpoint to continue.md
  - Add Step 5a: MANDATORY Post-Agent Checkpoint
  - Verify agent output (success/failure/partial)
  - Update plan markers ([ ] → [x] or [~])
  - Add commit decision question
  - Add "Fresh start" option to checkpoint
  - Handle error/partial completion
  - Files: `plugins/devloop/commands/continue.md`

- [ ] Task 9.2: Add loop completion detection to continue.md [depends:9.1]
  - Count remaining tasks after each checkpoint
  - Detect when all tasks complete
  - Present completion options (ship/review/add more/end)
  - Auto-update plan status to "Review"
  - Files: `plugins/devloop/commands/continue.md`

- [ ] Task 9.3: Add context management to continue.md [depends:9.1]
  - Context staleness detection thresholds
  - Track session metrics (tasks, agents, duration)
  - Suggest refresh when thresholds exceeded
  - Document background agent pattern
  - Files: `plugins/devloop/commands/continue.md`

- [ ] Task 9.4: Standardize checkpoint questions in continue.md [depends:9.1]
  - Apply AskUserQuestion standards from Task 7.3
  - Use standard checkpoint question format
  - Use standard error question format
  - Batch related questions
  - Files: `plugins/devloop/commands/continue.md`

### Phase 10: Fresh Start Mechanism [parallel:partial]
**Goal**: Enable context clearing with state preservation
**Reference**: `.devloop/spikes/continue-improvements.md`
**Dependencies**: Phase 9 Task 9.1 (checkpoint must exist first)

- [ ] Task 10.1: Create /devloop:fresh command [parallel:A]
  - Gather current plan state
  - Identify last completed and next pending task
  - Generate quick summary
  - Write state to `.devloop/next-action.json`
  - Present continuation instructions
  - Files: `plugins/devloop/commands/fresh.md`

- [ ] Task 10.2: Add fresh start detection to session-start.sh [parallel:B]
  - Check for `.devloop/next-action.json` on startup
  - Parse saved state (with and without jq)
  - Display fresh start message with next task
  - Add "dismiss" option to clear state
  - Files: `plugins/devloop/hooks/session-start.sh`

- [ ] Task 10.3: Add state file cleanup to continue.md [depends:10.1,10.2]
  - Read `.devloop/next-action.json` at start if exists
  - Use saved state to identify next task
  - Delete state file after reading
  - Document fresh start workflow
  - Files: `plugins/devloop/commands/continue.md`

- [ ] Task 10.4: Test fresh start workflow [depends:10.1,10.2,10.3]
  - Test /devloop:fresh saves state correctly
  - Test SessionStart detects state and displays message
  - Test /devloop:continue reads and clears state
  - Test dismiss clears state
  - Files: Manual testing

### Phase 11: Integration & Refinements [parallel:partial]
**Goal**: Complete spike integration, worklog enforcement, and cleanup
**Reference**: Both spike reports

- [ ] Task 11.1: Add Phase 5b to spike.md for plan application [parallel:A]
  - Add plan update application step
  - Offer apply+start, apply-only, review options
  - Show diff-style preview of changes
  - Auto-invoke /devloop:continue if "apply+start"
  - Files: `plugins/devloop/commands/spike.md`

- [ ] Task 11.2: Enhance task-checkpoint skill [parallel:A]
  - Add mandatory worklog sync (every task completion)
  - Add worklog reconciliation (at session end)
  - Document worklog format for committed vs pending tasks
  - Files: `plugins/devloop/skills/task-checkpoint/SKILL.md`

- [ ] Task 11.3: Clean up SubagentStop hook [parallel:B]
  - Option 1: Remove hook (recommended - adds noise)
  - Option 2: Make it output structured recommendation
  - Document decision in hooks.json
  - Files: `plugins/devloop/hooks/hooks.json`

- [ ] Task 11.4: Update remaining commands with standards [parallel:C]
  - Apply AskUserQuestion standards to devloop.md
  - Apply AskUserQuestion standards to review.md
  - Apply AskUserQuestion standards to ship.md
  - Ensure checkpoint pattern consistency
  - Files: `plugins/devloop/commands/{devloop,review,ship}.md`

- [ ] Task 11.5: Update documentation [depends:11.1-11.4]
  - Document workflow loop in README.md
  - Document fresh start feature in README.md
  - Add engineer agent improvements to docs/agents.md
  - Update CHANGELOG.md with all Phase 7-11 changes
  - Files: `plugins/devloop/README.md`, `plugins/devloop/docs/agents.md`

- [ ] Task 11.6: Integration testing [depends:11.5]
  - Test complete workflow loop (plan → work → checkpoint → commit → continue)
  - Test fresh start full cycle
  - Test spike → plan application
  - Test worklog sync enforcement
  - Verify all AskUserQuestion patterns consistent
  - Files: Manual testing

## Progress Log

- 2025-12-21: Plan created from spike findings and user feedback
- 2025-12-21: continue.md and spike.md already enhanced with agent routing
- 2025-12-21: Tasks 1.1-1.3 complete - engineer, qa-engineer, task-planner agents reviewed. All already conform to v2.0 standards with proper descriptions, examples showing explicit agent invocation, complete XML structure, and delegation patterns.
- 2025-12-21: Tasks 1.4-1.5 complete - code-reviewer already had XML structure. Fixed examples and added XML structure to 5 agents: complexity-estimator, security-scanner, doc-generator, summary-generator, workflow-detector.
- 2025-12-21: Committed Tasks 1.4-1.5 - 04a49c1 (feat: add XML structure to remaining 5 agents)
- 2025-12-21: Task 1.6 complete - Added "Writing Agent Descriptions" section to docs/agents.md with guidelines for descriptions, examples, XML structure, model selection, and color coding.
- 2025-12-21: Phase 1 complete - All 6 tasks done. Moving to Phase 2.
- 2025-12-21: Phase 2 Tasks 2.1-2.5 complete - Audited all 16 commands. Fixed old agent references (code-explorer, dod-validator, test-runner, git-manager, refactor-analyzer). Added Agent Routing sections to bugs.md, issues.md, ship.md, analyze.md.
- 2025-12-21: Phase 2 complete - All 5 tasks done. Moving to Phase 3.
- 2025-12-22: Completed spike on plan archival - Validated feasibility (52% size reduction), identified approach (phase-based archival), assessed complexity (Medium). Spike report: `.devloop/spikes/plan-archival.md`
- 2025-12-22: Added Phase 6 to plan - Plan Archival (5 tasks). Moving to implementation of Task 6.1.
- 2025-12-22: Task 6.1 complete - Created `/devloop:archive` command with phase detection, archive file creation, Progress Log extraction, and plan compression logic. File: `plugins/devloop/commands/archive.md`
- 2025-12-22: Reviewed spike reports for engineer agent and continue command improvements. Added Phases 7-11 (31 tasks total): Phase 7 (Foundation - skills & patterns, 3 tasks), Phase 8 (Engineer enhancements, 6 tasks), Phase 9 (Workflow loop, 4 tasks), Phase 10 (Fresh start, 4 tasks), Phase 11 (Integration, 6 tasks). References: `.devloop/spikes/engineer-agent-improvements.md`, `.devloop/spikes/continue-improvements.md`
- 2025-12-23: Task 6.2 complete - Updated `/devloop:continue` with archive awareness. Added archive detection to Step 1, enhanced Step 2 with archive status display, added recovery scenarios for large plans and missing phases, and added archive tips.

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
