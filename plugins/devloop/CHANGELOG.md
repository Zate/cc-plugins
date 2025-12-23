# Changelog

All notable changes to the devloop plugin are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2025-12-23

### Added - Workflow Loop & Fresh Start System

**Workflow Loop Pattern (Phase 7)**
- Added mandatory post-task checkpoint to `/devloop:continue` (Step 5a: MANDATORY Post-Agent Checkpoint)
  - Verify agent output (success/failure/partial) with detailed indicators
  - Update plan markers (`[ ]` → `[x]` or `[~]`) with documentation
  - Commit decision question with 4 options (commit now, continue working, fresh start, stop here)
  - Handle error/partial completion with dedicated recovery questions
  - Session metrics tracking (6 metrics: tasks/agents/duration/plan-size/tokens/background)
- Added loop completion detection (Step 5b: Loop Completion Detection, 271 lines)
  - Task counting with dependency checking (5 states: complete/partial/in_progress/blocked/empty)
  - Context-aware completion options (8 handlers: ship/review/add-more/end/finish-partials/ship-anyway/review-partials/mark-complete)
  - Auto-update plan status to "Review" or "Complete"
  - Edge case handling (empty plan, blocked tasks, archived phases)
- Added context management (Step 5c: Context Management, 313 lines)
  - Session metrics tracking with staleness thresholds (info/warning/critical)
  - Detection logic and warning presentation (advisory vs critical)
  - Refresh decision tree and suggestions by threshold
  - Background agent best practices (when to use, polling patterns, max limits)
- Standardized 11 checkpoint questions across 208 diff lines in `/devloop:continue`
  - Applied AskUserQuestion standards from comprehensive standards document
  - Fixed header length compliance (max 12 chars)
  - Applied token-efficient question text patterns
  - Added `Skill: task-checkpoint` references to checkpoints
  - Established 4 standard formats: checkpoint, error recovery, partial completion, loop completion

**Fresh Start Mechanism (Phase 8)**
- Added `/devloop:fresh` command (348 lines)
  - Gathers current plan state from `.devloop/plan.md`
  - Identifies last completed and next pending task
  - Generates quick summary with completion percentage
  - Writes state to `.devloop/next-action.json` with complete metadata
  - Presents continuation instructions for resuming
  - Supports `--dismiss` flag to clear saved state
  - Handles edge cases (no plan, existing state, plan complete)
- Enhanced `session-start.sh` with fresh start detection (+30 lines)
  - Checks for `.devloop/next-action.json` on startup
  - Parses saved state with jq + grep/sed fallback for reliability
  - Displays concise fresh start message (<10 lines) with plan/phase/summary/next task
  - Adds "dismiss" option to clear state
  - All 7 test cases passing
- Enhanced `/devloop:continue` with fresh start integration
  - Step 1a: Fresh start state detection with jq + fallback parsing
  - Step 2: Fresh start integration with dedicated display format
  - Step 9: Fresh Start Workflow comprehensive documentation (230 lines)
  - Includes state file format, lifecycle, error handling, 4 test cases
  - Reads and deletes `.devloop/next-action.json` after resuming
  - Added fresh start tip to Tips section

### Added - Skills & Documentation

**Foundation Skills (Phase 5)**
- Added `workflow-loop` skill (668 lines)
  - Documented standard loop with checkpoint enforcement
  - Defined state transitions and error recovery patterns
  - Added context management thresholds (6 metrics with severity levels)
  - Included good vs bad workflow examples
  - Integration with checkpoint patterns and fresh start mechanism
- Created AskUserQuestion standards document (`docs/ask-user-question-standards.md`, 1,008 lines)
  - When to ALWAYS ask vs NEVER ask with examples
  - Question batching patterns and decision trees
  - 4 standard question formats with templates (checkpoint, confirmation, selection, application)
  - Token efficiency guidelines (header limits, option descriptions)
  - Integration guide and anti-patterns
  - Used across all Phase 7-9 command updates

### Enhanced - Engineer Agent Capabilities (Phase 6)

**Core Prompt Enhancements**
- Added model escalation guidance to `engineer.md`
  - When to recommend opus model (5+ files, security-sensitive, complex patterns)
  - Output format for escalation suggestions
- Added anti-pattern constraints section
  - Scope constraints (no implementation without approval, no skipping exploration)
  - Efficiency constraints (max 10 files in exploration, single skill per language)
- Added limitations/self-awareness section
  - Delegates to specialized agents (security-scanner, qa-engineer, doc-generator)
  - Clear boundaries of responsibilities

**Skill Integration Improvements**
- Added mode-specific skill workflows with invocation order
  - Explorer mode: tool-usage-policy → project-context → language patterns
  - Architect mode: architecture-patterns → language patterns → api-design/database-patterns → testing-strategies → complexity-estimation
  - Refactorer mode: built-in analysis → language patterns → complexity-estimation
  - Git mode: git-workflows (for complex operations only)
- Added 6 missing skills to engineer agent frontmatter
  - complexity-estimation, project-context, api-design, database-patterns, testing-strategies, refactoring-analysis
- Documented skill examples for each mode combination

**Mode Handling Enhancements**
- Added complexity-aware mode selection
  - Simple (proceed directly), Medium (standard workflow), Complex (enhanced workflow with checkpoints)
  - Complexity indicators and decision criteria
  - Example: "Add authentication" → High complexity → Invoke complexity-estimation, present OAuth vs JWT approaches
- Added multi-mode task patterns with 3 complete examples
  - Pattern: "Add [Feature] to [Component]" → Explorer → Architect → (Checkpoint) → Return architecture
  - Pattern: "Refactor and Commit" → Refactorer → Git
  - Pattern: "Trace [Feature] and Fix Issues" → Explorer → Refactorer → (Checkpoint) → Return findings
- Added cross-mode transition rules (when to switch modes, checkpoints when switching)

**Output Format Standards**
- Structured exploration output format (entry points table, execution flow, key components, architecture insights)
- Token-conscious output guidelines with max budgets per mode (Explorer: 500, Architect: 800, Refactorer: 1000, Git: 200)
- Consistent file reference format (`file:line` or `file:start-end`)
- Offer to elaborate pattern when exceeding token budget

**Delegation & Workflow Awareness**
- Enhanced delegation table with all 9 agents (code-reviewer, security-scanner, doc-generator, summary-generator, qa-engineer, task-planner, workflow-detector, complexity-estimator)
- Added when-to-delegate criteria and examples for each agent
- Added parallel execution awareness (when to parallelize, token cost considerations)
- Added plan synchronization checkpoint (recommendations for plan updates)
- Added task completion status reporting to parent workflow

### Enhanced - Integration & Refinements (Phase 9)

**Spike Plan Application**
- Added Phase 5b to `/devloop:spike` for programmatic plan application
  - Offer apply+start, apply-only, review, skip options
  - Show diff-style preview of changes
  - Auto-invoke `/devloop:continue` if "apply+start" selected
  - Edge case handling (no plan, conflicts, archived phases)
  - Integrates with AskUserQuestion standards (Format 4: Plan Application)

**Worklog Enforcement**
- Enhanced `task-checkpoint` skill with mandatory worklog sync (+224 lines, 285→509 total)
  - Added "Worklog Sync Requirements" section with mandatory triggers
  - Added entry states (pending/committed/grouped) documentation
  - Added Step 3: Mandatory Worklog Checkpoint with enforcement checks
  - Enhanced Step 6a with commit hash update workflow and format examples
  - Added "Session End Reconciliation" section with checklist, triggers, workflow
  - Documented enforcement behavior (advisory vs strict) for reconciliation
  - Integration with fresh start mechanism
  - Updated Quick Reference table with worklog checkpoints

**Hook Cleanup**
- Removed `SubagentStop` hook from `hooks.json`
  - Rationale: Hook cannot detect agent modes (engineer:explore vs architect vs refactorer)
  - Only 2/7 chaining rules worked reliably (28% success rate)
  - User autonomy preferred for workflow decisions
  - Documented decision in hooks.json notes section

**Command Updates**
- Applied AskUserQuestion standards to `review.md` (2 questions)
- Applied AskUserQuestion standards to `ship.md` (8 questions)
- Added recommended markers to 9 total questions (7 in ship, 2 in review)
- All headers compliant (≤12 chars)
- Token-efficient format maintained

### Changed

- Updated README.md with workflow loop and fresh start sections
- Updated docs/agents.md with engineer agent improvements from Phase 6
- Updated CHANGELOG.md with comprehensive v2.1.0 entry

### Technical Details

**Line Counts**
- `/devloop:continue`: +584 lines (checkpoint, loop completion, context management)
- `/devloop:fresh`: 348 new lines
- `workflow-loop` skill: 668 new lines
- `ask-user-question-standards.md`: 1,008 new lines
- `task-checkpoint` skill: +224 lines (285→509)
- `engineer.md`: Enhanced with 6 new skills, mode handling, output standards, delegation
- Total additions: ~3,000+ lines of workflow infrastructure

**Integration Points**
- Workflow loop integrates with: continue.md, spike.md, fresh.md, summary.md, ship.md
- Fresh start integrates with: session-start.sh, continue.md, workflow-loop skill
- Task checkpoint integrates with: workflow-loop skill, continue.md checkpoints
- AskUserQuestion standards used in: continue.md (11), review.md (2), ship.md (8), spike.md (1)

**Enforcement Modes**
- Advisory mode (default): Warns when plan/worklog out of sync, allows override
- Strict mode: Blocks commits until plan updated, enforces worklog reconciliation
- Configure in `.devloop/local.md` with `enforcement: advisory|strict`

### Migration Notes

**From v2.0.x**
- No breaking changes
- Fresh start feature is opt-in (use `/devloop:fresh` when needed)
- Workflow loop checkpoints are now mandatory in `/devloop:continue`
- SubagentStop hook removed (was unreliable)
- Plan archival system from v2.0.3 works seamlessly with fresh start

**Recommended Workflow**
1. Use `/devloop:continue` for multi-task work (checkpoints now mandatory)
2. When context feels heavy (5+ tasks, 10+ agents, 2+ hours):
   - Select "Fresh start" option at checkpoint, OR
   - Run `/devloop:fresh` manually
3. Run `/clear` to reset conversation
4. Start new session (SessionStart detects saved state)
5. Run `/devloop:continue` to resume with fresh context

## [2.0.3] - 2025-12-23

### Fixed

- Fixed Task invocation logging hook JSON parsing
  - Added jq + grep/sed fallback for robust parsing
  - Properly extracts subagent_type, description, prompt from Task tool calls
  - Tested with multiple JSON scenarios

### Changed

- Reviewed all PreToolUse hooks for consistency
  - Identified complementary (not redundant) matchers
  - Documented improvement opportunities (logging, comments, prompts, conditions)

## [2.0.0] - 2025-12-21

### Changed - Agent Consolidation

**Major architectural refactoring for reduced token usage and improved agent coordination.**

- **Agent Consolidation**: Reduced from 18 agents to 9 super-agents
  - `engineer` - Combines code-explorer, code-architect, refactor-analyzer, git-manager (4 modes)
  - `qa-engineer` - Combines test-generator, test-runner, bug-catcher, qa-agent (4 modes)
  - `task-planner` - Enhanced to absorb issue-manager, requirements-gatherer, dod-validator (4 modes)
- **XML Prompt Structure**: Core agents now use XML structure to prevent drift
  - Added `<system_role>`, `<capabilities>`, `<workflow_enforcement>` sections
  - Consistent `<thinking>` blocks for complex decisions
  - Mode detection with explicit routing rules
- **Dynamic Skill Loading**: Skills now load on-demand instead of all at startup
  - Added `skills/INDEX.md` as lightweight catalog
  - SessionStart references index, specific skills loaded when needed
  - Reduces initial context by ~50%
- **Automatic Worklog Rotation**: Prevents context bloat from large worklogs
  - Archives worklog when exceeding 500 lines
  - Runs automatically on session start
  - Archived to `.devloop/archive/worklog-YYYY-MM-DD.md`
- Updated documentation and agents.md for v2.0 architecture

### Added - Plan Archival (Phase 6)

- Added `/devloop:archive` command
  - Detect completed phases (all tasks `[x]`)
  - Archive to `.devloop/archive/{name}_{timestamp}.md`
  - Extract Progress Log to worklog.md
  - Compress active plan.md (keep metadata, overview, active phases, last 10 Progress Log entries)
- Updated `/devloop:continue` for archive awareness
  - Handle archived phase references gracefully
  - Add "see archive" messaging when relevant
  - Archive detection and status display
  - Recovery scenarios for archived plans
- Updated pre-commit hook for archive awareness
  - Archive-aware grep patterns
  - Skip archived headers in validation
  - Detect archived plans via Progress Log check
  - Skip task count validation when plan compressed
- Updated `plan-management` skill with archival documentation
  - Document archive format, structure, and integration
  - Added "when to archive" guidance (>200 lines, 2+ complete phases)
  - Restoration instructions
  - Archive command added to "See Also" references

## [1.10.0] - 2024-12-15

### Added

- **Consistency & Enforcement System**: Plan and worklog synchronization with configurable enforcement
- Added worklog management (`devloop-worklog.md`) for completed work history with commits
- Added `file-locations` skill documenting all `.claude/` file locations and git tracking
- Added `worklog-management` skill for worklog format and update procedures
- Added `/devloop:worklog` command for viewing, syncing, and reconstructing worklog
- Added pre-commit hook to verify plan sync before commits
- Added post-commit hook to auto-update worklog after commits
- Added recovery flows in `/devloop:continue` for out-of-sync scenarios
- Added `.gitignore` template for devloop (`templates/gitignore-devloop`)
- Updated `devloop.local.md` template with enforcement settings
- Updated `task-checkpoint` skill with worklog integration
- Updated `summary-generator` to use worklog as source of truth
- Updated `plan-management` with enforcement hooks documentation
- Updated CLAUDE.md with `.claude/` directory structure guidance

## [1.9.0] - 2024-12-10

### Added

- **Unified Issue Tracking**: New system supporting bugs, features, tasks, chores, and spikes
- Added `/devloop:new` command with smart type detection from keywords
- Added `/devloop:issues` command for viewing and managing all issue types
- Added `issue-manager` agent for creating any issue type
- Added `issue-tracking` skill with full schema and view generation rules
- Type-prefixed IDs: BUG-001, FEAT-001, TASK-001, CHORE-001, SPIKE-001
- Auto-generated view files: index.md, bugs.md, features.md, backlog.md
- Updated `workflow-detector` to route issue tracking requests
- Migration support from `.devloop/issues/` to unified `.devloop/issues/`
- Backwards compatibility: `/devloop:bug` and `/devloop:bugs` still work

## [1.8.0] - 2024-12-05

### Added

- **Smart Parallel Task Execution**: Run independent tasks in parallel for faster development
- **Unified Plan Integration**: All commands and agents now consistently work from `.devloop/plan.md`
- Added parallelism markers: `[parallel:X]`, `[depends:N.M]`, `[background]`, `[sequential]`
- Updated `plan-management` skill with parallelism guidelines and token cost awareness
- Updated `/devloop:continue` to detect and spawn parallel task groups
- Updated `/devloop:spike` with mandatory plan integration and update recommendations
- Updated `/devloop:quick` to check for existing plans before starting
- Updated `/devloop` Phase 7 with parallel task detection
- Updated `task-planner` to generate parallelism annotations
- Updated `code-explorer`, `code-architect`, `code-reviewer` with plan update recommendations
- Updated `test-generator` with parallel execution awareness
- Updated `task-checkpoint` with parallel sibling detection
- Updated `atomic-commits` with parallel task grouping guidance

## [1.7.0] - 2024-11-28

### Added

- **Task Completion Enforcement**: New checkpoint system ensures tasks are properly completed
- Added `task-checkpoint` skill for task completion verification
- Added `atomic-commits` skill for commit strategy guidance
- Added `version-management` skill for semantic versioning and CHANGELOG
- Updated `/devloop:continue` with task and phase completion checkpoints
- Updated `/devloop:ship` with version bumping and CHANGELOG generation
- Updated `/devloop:bootstrap` to include devloop workflow in generated CLAUDE.md
- Enhanced `git-manager` agent with task-linked commits
- Enhanced `summary-generator` agent with commit tracking
- Enhanced `dod-validator` agent with commit verification
- Updated `plan-management` skill with enforcement configuration
- Support for per-project enforcement modes (advisory/strict)
- Auto-detection of version bumps from conventional commits

## [1.6.0] - 2024-11-15

### Added

- Added `/devloop:analyze` command for codebase refactoring analysis
- Added `refactor-analyzer` agent for identifying technical debt
- Added `refactoring-analysis` skill with analysis methodology
- Analysis findings can be converted directly to devloop plan tasks
- Merged functionality from retired `code-refactor-analyzer` plugin

## [1.5.0] - 2024-11-01

### Added

- Added `/devloop:bootstrap` command for greenfield projects
- Added `project-bootstrap` skill for CLAUDE.md best practices
- Now supports starting projects from PRD/specs before any code exists
- Comprehensive documentation in `docs/` directory

## [1.4.0] - 2024-10-20

### Added

- Added statusline integration (`/devloop:statusline`)

### Fixed

- Fixed JSON injection vulnerability in session-start hook

### Changed

- Optimized language detection performance
- Updated test-generator, test-runner, doc-generator to sonnet
- Added "When NOT to Use" sections to all 17 skills
- Added version notes to language-specific skills
- Clarified qa-agent vs dod-validator responsibilities

## [1.3.0] - 2024-10-10

### Added

- Added bug tracking system (`/devloop:bug`, `/devloop:bugs`)
- Added bug-catcher agent
- Added issue-tracking skill (unified bug/feature/task tracking)

## [1.2.0] - 2024-10-01

### Added

- Added memory integration agents
- Added summary-generator agent
- Enhanced plan management

## [1.0.0] - 2024-09-15

### Added

- Initial release
- 12-phase workflow
- Core agents and skills
- SessionStart hook

[2.1.0]: https://github.com/Zate/cc-plugins/compare/v2.0.3...v2.1.0
[2.0.3]: https://github.com/Zate/cc-plugins/compare/v2.0.0...v2.0.3
[2.0.0]: https://github.com/Zate/cc-plugins/compare/v1.10.0...v2.0.0
[1.10.0]: https://github.com/Zate/cc-plugins/compare/v1.9.0...v1.10.0
[1.9.0]: https://github.com/Zate/cc-plugins/compare/v1.8.0...v1.9.0
[1.8.0]: https://github.com/Zate/cc-plugins/compare/v1.7.0...v1.8.0
[1.7.0]: https://github.com/Zate/cc-plugins/compare/v1.6.0...v1.7.0
[1.6.0]: https://github.com/Zate/cc-plugins/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/Zate/cc-plugins/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/Zate/cc-plugins/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/Zate/cc-plugins/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/Zate/cc-plugins/compare/v1.0.0...v1.2.0
[1.0.0]: https://github.com/Zate/cc-plugins/releases/tag/v1.0.0
