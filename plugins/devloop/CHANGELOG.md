# Changelog

All notable changes to the devloop plugin are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.10.0] - 2026-01-24

### Added - Unified devloop:run Command

New `/devloop:run` command that merges `devloop:continue` and `devloop:ralph` into a single autonomous execution workflow.

#### Features
- **Autonomous by Default**: Executes plan tasks without prompts (ralph behavior)
- **Interactive Mode**: `--interactive` flag for checkpoint prompts (old continue behavior)
- **Iteration Control**: `--max-iterations N` to override default 50 iteration limit
- **Auto-Commit at Phases**: Commits automatically when completing a phase (if `auto_commit: true`)
- **Smart State Detection**: Handles no plan, complete plan, and pending tasks appropriately

#### Migration Guide

| Old Command | New Equivalent |
|-------------|----------------|
| `/devloop:ralph` | `/devloop:run` (autonomous is default) |
| `/devloop:continue` | `/devloop:run --interactive` |
| `/devloop:ralph --max-iterations 100` | `/devloop:run --max-iterations 100` |

#### Deprecated Commands
- `/devloop:continue` - Still works, but prefer `/devloop:run --interactive`
- `/devloop:ralph` - Still works, but prefer `/devloop:run`

Both deprecated commands include deprecation notices and migration guidance.

#### Files Changed
- `commands/run.md` - New unified command
- `commands/continue.md` - Added deprecation notice and alias behavior
- `commands/ralph.md` - Added deprecation notice and alias behavior
- `README.md` - Updated workflow documentation
- `CHANGELOG.md` - Added this entry
- `.claude-plugin/plugin.json` - Version bump

**Why this change?** Reduces cognitive load by having a single command for plan execution. Users no longer need to choose between `continue` and `ralph` - just use `run`.

---

## [3.9.2] - 2026-01-17

### Changed - Documentation Overhaul

Comprehensive README update to improve new user onboarding and reflect all v3.x features.

#### New Sections
- **"Three Ways to Work"**: Visual comparison of manual, issue-driven, and automated workflows
- **"Quick Reference"**: Command cheatsheet for fast lookup
- **Enhanced opening hook**: Immediately explains value proposition

#### Updated Content
- Version badge updated to current version
- Commands badge: 10 → 15 (now includes issues, statusline, new)
- Agents badge: 6 → 7 (added statusline-setup)
- Command table: Added `/devloop:issues`, `/devloop:statusline`, `/devloop:new`
- Agent table: Added `devloop:statusline-setup`
- Philosophy section: Added "Why this matters" with concrete benefits

#### Files Changed
- `README.md` - Full documentation update
- `CHANGELOG.md` - Added this entry
- `.claude-plugin/plugin.json` - Version bump

**Note**: This is a patch release (docs only) per new versioning guidelines in CLAUDE.md.

---

## [3.8.0] - 2026-01-17

### Added - GitHub Issues Command

New `/devloop:issues` command to list and browse GitHub issues directly from Claude Code.

#### Features
- **gh CLI Integration**: Uses `gh issue list` as the primary method
- **GITHUB_TOKEN Fallback**: Falls back to curl + API when gh CLI unavailable
- **Graceful Error Handling**: Clear instructions for installing/authenticating gh CLI
- **Filtering Support**: `--state`, `--label`, `--assignee` options
- **Readable Output**: Formatted table with issue number, labels, title, assignee, and age

#### New Files
- `scripts/check-gh-setup.sh` - Detects gh CLI installation, authentication, and repo
- `scripts/list-issues.sh` - Fetches and formats issues with filtering
- `commands/issues.md` - Slash command for `/devloop:issues`

#### Usage Examples
```bash
# List open issues (default)
/devloop:issues

# List all issues
/devloop:issues --state all

# Filter by label
/devloop:issues --label bug

# Filter by assignee
/devloop:issues --assignee @me
```

#### Output Format
```
# Open Issues (12)

#42  [bug]        Login fails on Safari                          @alice   2d ago
#38  [feature]    Add dark mode                                  @bob     5d ago
```

#### Integration
- Works with `/devloop:from-issue` to provide issue picker
- Useful for discovering what needs work before starting a plan

---

## [3.7.0] - 2026-01-16

### Fixed - Critical AskUserQuestion Format

Fixed 23 instances of incorrect AskUserQuestion format across all commands and agents.

#### What Was Wrong
AskUserQuestion tool requires:
- `questions:` array wrapper
- `multiSelect:` field in each question

All 11 files with AskUserQuestion now use the correct format.

#### Files Fixed
- `commands/archive.md` (2 instances)
- `commands/continue.md` (2 instances)
- `commands/devloop.md` (1 instance)
- `commands/from-issue.md` (4 instances)
- `commands/help.md` (2 instances)
- `commands/pr-feedback.md` (2 instances)
- `commands/quick.md` (1 instance)
- `commands/review.md` (2 instances)
- `commands/ship.md` (4 instances)
- `commands/spike.md` (2 instances)
- `agents/statusline-setup.md` (1 instance)

### Added - Testing Infrastructure

New test suite to prevent regressions.

- `tests/test-helpers.sh` - Shared test utilities (assert_contains, assert_count, etc.)
- `tests/test-askuserquestion-format.sh` - Validates AskUserQuestion format across all files
- `tests/test-commands.sh` - Command structure smoke tests
- `tests/run-tests.sh` - Test runner (`./run-tests.sh` runs all tests)

### Added - Plugin Dependency Validation

- `scripts/check-plugin.sh` - Generic plugin detection script
- `/devloop:ralph` now validates ralph-loop plugin is installed before starting

### Added - Superpowers Integration

Lightweight cross-references to complementary superpowers skills (when installed):

- `testing-strategies` → `superpowers:test-driven-development`
- `git-workflows` → `superpowers:using-git-worktrees`, `superpowers:finishing-a-development-branch`
- `architecture-patterns` → `superpowers:systematic-debugging`
- `skills/INDEX.md` - New "Superpowers Integration" section
- `commands/help.md` - Added optional superpowers info
- `commands/ship.md` - Tip about verification skill
- `skills/local-config/SKILL.md` - Settings to disable superpowers suggestions

### Changed

- Reduced help command topic options from 6 to 4 (AskUserQuestion limit)
- INDEX.md version updated to reflect integrations

---

## [3.6.2] - 2026-01-09

### Added - Statusline Setup Command

Restored statusline configuration capability with improved conflict handling.

#### New Command
- `/devloop:statusline` - Configure the devloop statusline in Claude Code settings

#### New Agent
- `statusline-setup` - Agent that safely configures statusline, detecting and handling existing configurations

#### SessionStart Enhancement
- Now checks if devloop statusline is configured
- Shows tip to run `/devloop:statusline` if not configured

#### What the Statusline Shows
- Model name (Opus/Sonnet/Haiku)
- Context window usage (progress bar + percentage)
- Session tokens (formatted as K/M)
- API limits (5h and 7d usage)
- Current directory and git branch
- Plan progress (X/Y tasks)
- Open bug count

#### Files Changed
- `agents/statusline-setup.md` - New agent for safe statusline configuration
- `commands/statusline.md` - New command to trigger setup
- `commands/help.md` - Added statusline to command reference and troubleshooting
- `hooks/session-start.sh` - Added statusline configuration check and hint

---

## [3.6.1] - 2026-01-08

### Changed - Command Frontmatter Modernization

Updated all command files to use Claude Code 2.1.0 YAML syntax.

#### YAML-Style allowed-tools
All commands now use YAML list format instead of JSON arrays:

```yaml
# Before (JSON array)
allowed-tools: ["Read", "Write", "Edit"]

# After (YAML list)
allowed-tools:
  - Read
  - Write
  - Edit
```

#### Wildcard Bash Permissions
Commands with script access now use wildcards for simpler maintenance:

```yaml
# Before (individual scripts)
allowed-tools:
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh:*)
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/archive-plan.sh:*)

# After (wildcard)
allowed-tools:
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
```

#### Files Updated
All 12 command files in `commands/` directory.

#### Investigation Notes
- **Command-scoped hooks**: Not supported in command frontmatter (hooks require hooks.json or settings.json)
- **context: fork**: Not supported in command frontmatter per current Claude Code docs

---

## [3.6.0] - 2026-01-08

### Added - Plan Archival with GitHub Issues Integration

Complete system for handling completed plans with optional GitHub Issues workflow.

#### New Commands
- `/devloop:archive` - Manually archive completed plan to `.devloop/archive/`
- `/devloop:from-issue 123` - Start work from a GitHub issue

#### New Script
- `scripts/archive-plan.sh` - Core archival logic with JSON output, issue metadata extraction

#### GitHub Issues Integration (Opt-in)
Enable in `.devloop/local.md`:
```yaml
---
github:
  link-issues: true           # Enable issue linking
  auto-close: ask             # ask | always | never
  comment-on-complete: true   # Post summary on completion
---
```

**Workflow:**
1. `/devloop:from-issue 123` fetches issue, creates plan with `**Issue**: #123` link
2. Work through tasks as normal
3. On completion, archive offers to post summary and close issue

#### Command Updates
- `continue.md` - Offers archival when plan completes (Step 4c)
- `ship.md` - Archive option in post-ship actions (Phase 5)
- `spike.md` - Archive old completed plan before starting new (Step 6)

#### Enhanced Session-Start
- Shows linked issue status (open/closed) if plan references a GitHub issue

#### Documentation Updates
- `local-config` skill - New `github.*` settings
- `plan-management` skill - Issue reference format, GitHub integration section
- `help.md` - Archive and from-issue commands
- `README.md` - New sections for GitHub Issues and Plan Management

#### Files Changed/Added
| File | Action |
|------|--------|
| `scripts/archive-plan.sh` | Created |
| `commands/archive.md` | Created |
| `commands/from-issue.md` | Created |
| `commands/continue.md` | Modified |
| `commands/ship.md` | Modified |
| `commands/spike.md` | Modified |
| `hooks/session-start.sh` | Modified |
| `scripts/parse-local-config.sh` | Modified |
| `skills/local-config/SKILL.md` | Modified |
| `skills/plan-management/SKILL.md` | Modified |

---

## [3.5.0] - 2026-01-08

### Added - Context Guard for Ralph Loop

Automatic context monitoring to prevent degradation during long automated sessions.

#### New Hook
- `hooks/context-guard.sh` - Stop hook that monitors context usage and gracefully exits ralph loop when threshold exceeded

#### How It Works
1. Statusline writes context % to `.claude/context-usage.json` on every update
2. Stop hook checks context usage when Claude tries to stop
3. If context >= threshold (default 70%) and ralph loop is active, removes ralph state file
4. Ralph-loop's hook then sees no state file and allows exit
5. User sees message to run `/devloop:fresh` then `/devloop:continue` to resume

#### Configuration
Override threshold in `.devloop/local.md`:
```yaml
---
context_threshold: 80  # Exit at 80% instead of default 70%
---
```

#### Files Changed
- `statusline/devloop-statusline.sh` - Now writes context usage JSON
- `hooks/context-guard.sh` - New Stop hook
- `hooks/hooks.json` - Added Stop hook configuration

---

## [3.4.2] - 2026-01-08

### Fixed - Task Counting in check-plan-complete.sh

Fixed script incorrectly counting markdown examples inside code blocks as tasks.

#### Changes
- Added `filter_code_blocks()` function using awk to skip content between ``` markers
- Changed regex from `^- \[` to `^[[:space:]]*- \[[ x~!]\]` for precise task matching
- Supports indented tasks with `[[:space:]]*` prefix

**Before**: Counted `- [Finding]`, `- [Option A]` as tasks
**After**: Only counts actual task markers: `- [ ]`, `- [x]`, `- [~]`, `- [!]`

---

## [3.4.1] - 2026-01-08

### Enhanced - Spike Command Multi-Select

Enhanced `/devloop:spike` with multi-select exploration aspects and time budget.

#### New Features
- **Multi-select exploration aspects**: Feasibility, Approach comparison, Performance, Integration
- **Time budget question**: Quick (30 min), Standard (1-2 hr), Deep dive
- **Aspect-specific research guidance** in Step 2
- **Per-aspect evaluation** with verdicts and confidence levels in Step 4
- **Enhanced report template** with "Findings by Aspect" sections and summary matrix

#### Example
```yaml
AskUserQuestion:
  questions:
    - question: "What aspects should this spike explore?"
      header: "Explore"
      multiSelect: true
      options:
        - label: "Feasibility"
        - label: "Approach comparison"
        - label: "Performance"
        - label: "Integration"
    - question: "What's your time budget?"
      header: "Depth"
      options:
        - label: "Quick (30 min)"
        - label: "Standard (1-2 hr)"
        - label: "Deep dive"
```

---

## [3.4.0] - 2026-01-08

### Added - Ralph Loop Integration

Automated task execution with the ralph-loop plugin for hands-free plan completion.

#### New Command
- `/devloop:ralph` - Start automated task loop with ralph-loop integration

#### New Script
- `scripts/check-plan-complete.sh` - Check if all plan tasks are marked complete (returns JSON status)

#### Enhanced Commands
- `/devloop:continue` - Now outputs `<promise>ALL PLAN TASKS COMPLETE</promise>` when all tasks done and ralph-loop is active

#### New Help Topic
- "Automation" topic in `/devloop:help` - Explains ralph integration, flow diagram, and when to use

#### Documentation
- README updated with Ralph Loop Integration section
- Full documentation of promise mechanism and workflow

#### How It Works
1. `/devloop:ralph` creates ralph-loop state with completion promise
2. Claude works through plan tasks, marking each `[x]` when done
3. After each task, checks if all tasks complete
4. When complete, outputs `<promise>ALL PLAN TASKS COMPLETE</promise>`
5. Ralph's Stop hook detects promise and terminates loop

Requires ralph-loop plugin: `/plugin install ralph-loop`

---

## [3.3.0] - 2026-01-03

### Added - Git Workflow Integration

Comprehensive git workflow support with opt-in configuration via `.devloop/local.md`.

#### New Command
- `/devloop:pr-feedback` - Fetch and integrate PR review comments into the plan

#### New Skills
- `local-config` - Project settings via `.devloop/local.md` YAML frontmatter
- `pr-feedback` - Parsing and integrating PR review feedback into tasks

#### New Features
- **Branch-per-plan workflow**: Optional auto-creation of feature branches when starting plans
- **Smart commit strategy**: Choose between atomic commits (one per task) or squash
- **PR creation**: Auto-generate PR description from plan summary and completed tasks
- **PR status detection**: Session-start hook shows open PR and review status
- **Config parsing**: `scripts/parse-local-config.sh` parses YAML frontmatter with defaults

#### Enhanced Commands
- `/devloop:ship` - Now branch-aware with 5 phases: Pre-flight, Validation, Commit, PR, Post-ship
- `/devloop` - Offers feature branch creation when `git.auto-branch: true` in local.md

#### Updated Skills
- `git-workflows` - Added devloop integration section and trunk-based development guidance
- `atomic-commits` - Added plan-to-commit mapping and devloop integration
- `plan-management` - Added Branch and PR Feedback section formats

#### Configuration (`.devloop/local.md`)
```yaml
---
git:
  auto-branch: true           # Create branch when plan starts
  pr-on-complete: ask         # ask | always | never
commits:
  style: conventional         # conventional | simple
review:
  before-commit: ask          # ask | always | never
---
```

All git features are opt-in. Without `local.md`, devloop works exactly as before.

---

## [3.0.0] - 2025-12-30

### BREAKING - Radical Performance Optimization

**Major restructuring to address 10x cost and 4x time overhead vs native Claude Code.**

Based on controlled benchmarking (Fastify Users API task):
- devloop v2.4: 35 min, $30.82, 17M cache tokens, 12 subagents
- native Claude: 8 min, $3.02, 1.5M cache tokens, 4 subagents

#### Removed - Prompt Hooks (Biggest Win)

Eliminated all `type: "prompt"` hooks that were causing extra LLM calls:
- `UserPromptSubmit` - Command suggestion on every user message
- `PreToolUse` Write/Edit - File validation prompts (2 per write!)
- `PreToolUse` Bash - Command validation prompt
- `PostToolUse` Bash - Result analysis prompt
- `PostToolUse` Task - Agent completion assessment
- `Stop` - Routing prompt
- `Notification` - Error/milestone analysis

**Impact**: Saves 20-50+ LLM calls per session

#### Removed - Auto-Loaded Skills

Cleared `skills:` from all agent frontmatter. Skills now load on-demand only.

Agents affected:
- `engineer.md` (was loading 14 skills!)
- `task-planner.md`, `qa-engineer.md`, `code-reviewer.md`
- `security-scanner.md`, `doc-generator.md`, `summary-generator.md`
- `workflow-detector.md`, `complexity-estimator.md`

**Impact**: 60-80% reduction in cache tokens per agent spawn

#### Removed - Redundant Skills (10 deleted)

| Skill | Reason |
|-------|--------|
| `workflow-router` (22KB) | Complex routing logic, simplified |
| `refactoring-analysis` (14KB) | Rarely used |
| `phase-templates` (16KB) | Too heavyweight |
| `workflow-selection` (12KB) | Redundant |
| `requirements-patterns` | Rarely used |
| `deployment-readiness` | Rarely used |
| `model-selection-guide` | Can be inline |
| `worklog-management` (12KB) | Simplified |
| `tool-usage-policy` | Not needed |
| `project-bootstrap` | Rarely used |

**Remaining**: 19 skills (down from 29)

#### Changed - session-start.sh

Reduced from 428 lines to 108 lines:
- Removed worklog rotation, plan sync, framework detection
- Removed workflow state detection, migration checks
- Fast language detection only
- Minimal context output

#### Changed - /devloop Command

Reduced from 263 lines to 112 lines:
- Removed 12-phase workflow documentation
- Removed automatic subagent spawning instructions
- Added "you do the work directly" principle
- Simplified to: check → understand → plan → implement → checkpoint

#### Changed - hooks.json

Reduced from 185 lines to 60 lines:
- Kept: SessionStart, SessionEnd (command hooks)
- Kept: PreToolUse/PostToolUse for git commit (command hooks)
- Removed: All prompt hooks, Notification, Stop, Skill tracking, Task tracking

### Philosophy Change

**Old**: Heavy orchestration with agents, skills, hooks, routing
**New**: Lightweight entry, Claude does the work, skills on-demand

Key principles:
1. You (Claude) do the work directly - no subagents for routine tasks
2. Skills on demand - load only when needed
3. Minimal questions - one at a time
4. Fast iteration - ship working code

### Target Metrics (Post-Optimization)

| Metric | v2.4 | Target v3.0 |
|--------|------|-------------|
| Duration ratio | 4.4x | ≤2.0x |
| Cost ratio | 10.2x | ≤3.0x |
| Cache ratio | 12.0x | ≤3.0x |
| Subagent count | 12 | ≤6 |

### Migration

No action required. The simplified workflow is backward compatible.
Existing `.devloop/plan.md` files work unchanged.

---

## [2.4.0] - 2025-12-27

### Added - Structured State Management & Script-First Workflow

**Major architecture improvement: Dual-file state management with 86% reduction in workflow token usage.**

#### JSON State System

Introduced `plan-state.json` as a machine-readable companion to `plan.md`:

- **`sync-plan-state.sh`** (491 lines): Parses plan.md and generates structured JSON
  - Extracts all task markers (`[ ]`, `[x]`, `[~]`, `[!]`, `[-]`)
  - Builds dependency graph (`[depends:N.M]` markers)
  - Groups parallel tasks (`[parallel:X]` markers)
  - Tracks phase status and completion percentages

- **`validate-plan-state.sh`** (425 lines): Validates JSON state integrity
  - Schema version checking
  - Stats consistency validation
  - Plan file reference verification
  - Sync freshness detection with `--fix` auto-repair

- **Automatic sync triggers**:
  - Session-start hook syncs on every session
  - Pre-commit hook ensures state matches before commits
  - Manual sync via `sync-plan-state.sh`

#### Script-First Workflow Commands

Converted high-token commands to script-driven workflows:

| Script | Purpose | Token Savings |
|--------|---------|---------------|
| `fresh-start.sh` | Save state for context restart | ~2,000/invocation |
| `archive-interactive.sh` | Detect & archive phases | ~2,500/invocation |
| `create-issue.sh` | Create BUG/FEAT/TASK/SPIKE/CHORE | ~2,000/invocation |
| `list-issues.sh` | List issues with filtering | ~1,500/invocation |
| `update-issue.sh` | Update issue status/labels | ~1,000/invocation |
| `select-next-task.sh` | Find next task respecting deps | ~500/invocation |
| `show-plan-status.sh` | Render plan progress display | ~1,000/invocation |

**Command size reductions**:
- `fresh.md`: 359 → 45 lines (87.5% reduction)
- `archive.md`: 367 → 43 lines (88.3% reduction)
- `bugs.md`: 262 → 103 lines (60.7% reduction)

#### Token Usage Improvement

**Before (Agent-First)**:
- Typical 10-task session overhead: ~25,000 tokens

**After (Script-First)**:
- Typical 10-task session overhead: ~3,500 tokens
- **86% reduction** (exceeded 80% target)

#### Documentation & Testing

- **Migration guide**: `docs/migration-to-json-state.md`
  - Step-by-step instructions for existing plans
  - Troubleshooting and best practices

- **Unit tests**: `tests/sync-plan-state.bats`
  - 40+ BATS test cases
  - Covers all task markers, edge cases, metadata extraction

- **Updated skills**: `plan-management/SKILL.md`
  - Dual-file state management documentation
  - Sync triggers and validation guidance

### Technical Details

**New Scripts**: 9 scripts, ~3,567 lines total
**Schema**: `plan-state.json` with schema version 1.0.0
**Backward Compatible**: Falls back to markdown parsing if JSON missing
**Git Tracked**: `plan-state.json` is tracked for team visibility

### Files Added/Modified

- `scripts/sync-plan-state.sh` (491 lines) - Core parser
- `scripts/validate-plan-state.sh` (425 lines) - Validation
- `scripts/fresh-start.sh` (187 lines) - Fresh start logic
- `scripts/archive-interactive.sh` (298 lines) - Archive logic
- `scripts/create-issue.sh` (525 lines) - Issue creation
- `scripts/list-issues.sh` (503 lines) - Issue listing
- `scripts/update-issue.sh` (530 lines) - Issue updates
- `scripts/select-next-task.sh` (283 lines) - Task selection
- `scripts/show-plan-status.sh` (325 lines) - Status display
- `commands/fresh.md` (45 lines) - Simplified command
- `commands/archive.md` (43 lines) - Simplified command
- `commands/bugs.md` (103 lines) - Simplified command
- `docs/migration-to-json-state.md` (200 lines) - Migration guide
- `tests/sync-plan-state.bats` (390 lines) - Unit tests
- `skills/plan-management/SKILL.md` - Updated with dual-file docs

---

## [2.3.0] - 2025-12-27

### Added - Token Efficiency & Progressive Disclosure Optimization

**Major optimization effort to reduce token usage through progressive disclosure pattern across the entire plugin.**

#### Phase 1: Language Skills Progressive Disclosure

Applied progressive disclosure to 4 language pattern skills, reducing initial load while maintaining full access to detailed patterns:

| Skill | Before | After | Reduction | References |
|-------|--------|-------|-----------|------------|
| go-patterns | 791 lines | 199 lines | 75% | 4 files (concurrency, testing, interfaces, error-handling) |
| python-patterns | 787 lines | 196 lines | 75% | 4 files (type-hints, async-patterns, testing-pytest, error-handling) |
| java-patterns | 856 lines | 199 lines | 77% | 4 files (spring-patterns, streams, testing-junit, dependency-injection) |
| react-patterns | 831 lines | 197 lines | 76% | 4 files (hooks, performance, testing, state-management) |

**Total**: ~3,265 lines → ~791 lines initially loaded, ~6,770 lines available on-demand = **88% reduction**

#### Phase 2: Core Utility Scripts

Created 3 high-value reusable scripts to replace duplicated logic:

- **`scripts/validate-plan.sh`**: Plan format validation with actionable errors
  - Format validation (YAML frontmatter, section headers)
  - Task marker validation (`[ ]`, `[x]`, `[~]`, `[!]`, `[-]`)
  - Dependency checking and parallelism marker validation
  - Used by: pre-commit hook, archive command, continue command

- **`scripts/update-worklog.sh`**: Centralized worklog management
  - Append entries with timestamp and commit hash
  - Format dates consistently (ISO 8601)
  - Validate entry format before appending

- **`scripts/format-commit.sh`**: Conventional commit message formatting
  - Type detection (feat, fix, refactor, docs, test, chore)
  - Scope extraction from task description
  - Breaking change detection

#### Phase 3: Standardized Skill Frontmatter

Added `whenToUse` and `whenNotToUse` YAML fields to all 29 skills for better invocation and clearer contracts:

- Batch 1 (10 skills): plan-management, tool-usage-policy, atomic-commits, worklog-management, model-selection-guide, api-design, database-patterns, testing-strategies, git-workflows, deployment-readiness
- Batch 2 (10 skills): architecture-patterns, security-checklist, requirements-patterns, phase-templates, complexity-estimation, project-context, project-bootstrap, language-patterns-base, workflow-selection, issue-tracking
- Batch 3 (9 skills): version-management, file-locations, react-patterns, python-patterns, java-patterns, go-patterns, task-checkpoint, workflow-loop, refactoring-analysis

**All 29 skills now have standardized YAML frontmatter for programmatic access.**

#### Phase 4: Engineer Agent Mode Extraction

Extracted mode instructions from engineer.md to references/ for on-demand loading:

| Reference | Lines | Content |
|-----------|-------|---------|
| `explorer-mode.md` | 133 | Codebase exploration patterns, search strategies |
| `architect-mode.md` | 166 | Architecture design patterns, trade-off analysis |
| `refactorer-mode.md` | 168 | Refactoring analysis, code smell detection |
| `git-mode.md` | 231 | Git workflow patterns, commit formatting |

**engineer.md**: 1,034 → 766 lines (26% reduction), ~350 lines now loaded on-demand per mode

#### Phase 5: Additional Optimizations

**Command Optimizations**:

| Command | Before | After | Reduction |
|---------|--------|-------|-----------|
| onboard.md | 492 lines | 209 lines | 57% |
| ship.md | 463 lines | 188 lines | 59% |
| bootstrap.md | 413 lines | 145 lines | 65% |

**Hook Script Optimization**:
- `session-start.sh`: 871 → 384 lines (56% reduction)
- Created subscripts: `detect-plan.sh`, `calculate-progress.sh`, `format-plan-status.sh`

**Additional Skill Optimizations**:

| Skill | Before | After | Reduction |
|-------|--------|-------|-----------|
| version-management | 431 lines | 139 lines | 68% |
| atomic-commits | 406 lines | 104 lines | 74% |
| file-locations | 394 lines | 115 lines | 71% |

**New Utility Scripts**:
- `scripts/archive-phase.sh` - Phase extraction and archival
- `scripts/suggest-skills.sh` - Centralized skill routing based on context
- `scripts/ship-validation.sh` - DoD, test, and build validation
- `scripts/suggest-fresh.sh` - Intelligent context clear suggestions

**New Templates**:
- `templates/onboard/` - 6 template files for codebase onboarding
- `templates/bootstrap/` - 3 template files for project bootstrapping

### Summary

**Total Impact**:
- **10 new utility scripts** for reusable logic
- **40+ reference files** extracted from skills and agents
- **12+ template files** created for commands
- **~60% average token reduction** in loaded content
- **All 29 skills standardized** with YAML frontmatter
- **All 4 language skills** with progressive disclosure

**Architecture**:
- Progressive disclosure pattern consistently applied
- Main files contain quick references and orchestration
- Detailed content loaded on-demand via `references/` directories
- Utility scripts enable DRY principle across commands and hooks

---

## [2.2.1] - 2025-12-26

### Changed - Command Length Reduction (Progressive Disclosure)

**Continue Command Refactoring**
- Reduced `/devloop:continue` from 1,526 lines to 425 lines (72.0% reduction, 1,100 lines saved)
- Applied progressive disclosure pattern to reference existing skills instead of duplicating content
- Refactored sections:
  - **Context Management** (Step 5c): 293 lines → Reference to `Skill: workflow-loop`
  - **Post-Agent Checkpoint** (Step 5a): 230 lines → Reference to `Skill: task-checkpoint`
  - **Loop Completion Detection** (Step 5b): 226 lines → Reference to `Skill: plan-management`
  - **Agent Execution Templates**: Consolidated to single parameterized pattern
  - **Classification Keywords**: Merged into agent routing table
- Enhanced maintainability:
  - Single source of truth for checkpoint patterns in `task-checkpoint` skill
  - Single source of truth for context management in `workflow-loop` skill
  - Single source of truth for plan completion logic in `plan-management` skill
- All essential workflow steps preserved with skill references for detailed content
- Tested scenarios: resume from plan, fresh start, completion detection, error recovery, parallel tasks
- Backup created: `continue-v1-backup.md` (1,526 lines → 45KB)

**Benefits**
- **Reduced token usage**: 72% smaller command = faster loading, less context bloat
- **Better maintainability**: Skills can be updated independently without touching continue.md
- **Improved readability**: Command shows workflow structure, skills provide implementation details
- **Consistent patterns**: Checkpoint/context/completion logic centralized in skills
- **No functionality loss**: All features preserved, just reorganized

**Files Modified**
- `plugins/devloop/commands/continue.md` (1,526 → 425 lines)
- Created backup: `plugins/devloop/commands/continue-v1-backup.md`
- Analysis: `.devloop/continue-refactor-map.md` (473 lines, working document)

**Architecture**
- Progressive disclosure: Command orchestrates, skills provide detailed patterns
- Skill references: 11 total references to 3 core skills (workflow-loop, task-checkpoint, plan-management)
- Agent routing table: 11 agent types with classification keywords
- Pattern templates: Single parameterized template replaces 11 mode-specific examples

**Testing**
- All workflow steps verified intact (8 main steps)
- Skill references properly formatted (backtick syntax)
- Agent routing table complete (11 agent types mapped)
- Essential patterns present (AskUserQuestion, Task, subagent_type, CRITICAL markers)
- Test plan documented in `.devloop/test-plan.md`

---

## [2.2.0] - 2025-12-24

### Added - Hook-Based Fresh Start Loop Workflow (FEAT-005)

**Stop Hook with Plan-Aware Routing (Phase 1)**
- Implemented comprehensive Stop hook in `hooks.json` (lines 113-177, +64 lines)
  - Detects `.devloop/plan.md` and evaluates plan state (pending/complete/no plan)
  - Returns structured JSON with routing options: "Continue next task", "Fresh start", "Stop"
  - Detects uncommitted changes and suggests auto-commit workflow (lint → test → commit)
  - Handles edge cases: missing plan, corrupted plan, complete plan
  - Congratulatory message when all tasks complete, suggests `/devloop:ship`
- Documented 9 comprehensive hook test scenarios in `testing.md` (lines 663-1230, +568 lines)
  - Hook Tests 1-4, 7: Stop hook behaviors (pending tasks, no plan, complete plan, uncommitted changes, invalid plan)
  - Hook Tests 5-6, 8: Session start auto-resume, stale state detection, missing plan validation
  - Hook Test 9: End-to-end fresh start workflow with 5-step execution timeline
  - Updated Table of Contents with "Hook Testing" section

**Fresh Start Auto-Resume (Phase 2)**
- Extended `session-start.sh` for automatic resume (lines 498-775, +163 lines net)
  - Detects `.devloop/next-action.json` on session start
  - Validates state with `validate_fresh_start_state()` function (lines 498-557)
    - Timestamp age check (warns if >7 days old, skips auto-resume)
    - Plan existence validation (`.devloop/plan.md` must exist)
    - Escape hatch for invalid state (skips auto-resume, displays warning)
  - Auto-invokes `/devloop:continue` via CRITICAL instruction (no user prompt)
  - Displays "🔄 Fresh start detected - auto-resuming work..." message to user
  - Continue command (Step 1a) reads, validates, and deletes state file (single-use)

**Benefits**
- **Seamless development loop**: Stop → routing options → fresh start → auto-resume
- **No manual steps**: Fully automatic resume from fresh start state
- **Safety validation**: Stale state detection (>7 days), plan existence, graceful error handling
- **Enforces best practices**: Auto-commit suggestions when uncommitted changes detected
- **Clear user experience**: Consistent routing prompts, automatic transitions, no confusion
- **Fresh context enabled**: Supports context clearing with automatic resume on next session

**Architecture**
- Hook-based design (non-invasive, leverages existing infrastructure)
- Stop hook: Plan evaluation and routing (hooks.json)
- Fresh command: State persistence (`/devloop:fresh` from Phase 8)
- Session start hook: Auto-resume detection and validation (session-start.sh)
- Continue command: State file reading and cleanup (continue.md Step 1a)

**Files Modified**
- `plugins/devloop/hooks/hooks.json` (lines 113-177, +64 lines)
- `plugins/devloop/hooks/session-start.sh` (lines 498-775, +163 lines net)
- `plugins/devloop/docs/testing.md` (lines 663-1230, +568 lines)
- `.devloop/plan.md` (Tasks 1.2, 1.3, 2.1, 2.2, 2.3, 3.1, 3.2 marked complete)
- `.devloop/issues/FEAT-005.md` (status: done, Resolution section added)

**Commits**
- `2b8dd1d`: feat(devloop): implement Stop hook with plan-aware routing (FEAT-005 Task 1.2)
- `7773d73`: docs(devloop): document hook test scenarios (FEAT-005 Task 1.3)
- `a1f355b`: feat(devloop): add auto-resume on fresh start detection (FEAT-005 Task 2.1)
- `09c0092`: feat(devloop): add safety validation for fresh start auto-resume (FEAT-005 Task 2.2)
- `3a69e36`: docs(devloop): update auto-resume test documentation (FEAT-005 Task 2.3)

---

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

[3.5.0]: https://github.com/Zate/cc-plugins/compare/v3.4.2...v3.5.0
[3.4.2]: https://github.com/Zate/cc-plugins/compare/v3.4.1...v3.4.2
[3.4.1]: https://github.com/Zate/cc-plugins/compare/v3.4.0...v3.4.1
[3.4.0]: https://github.com/Zate/cc-plugins/compare/v3.3.0...v3.4.0
[3.3.0]: https://github.com/Zate/cc-plugins/compare/v3.0.0...v3.3.0
[3.0.0]: https://github.com/Zate/cc-plugins/compare/v2.4.0...v3.0.0
[2.4.0]: https://github.com/Zate/cc-plugins/compare/v2.3.0...v2.4.0
[2.3.0]: https://github.com/Zate/cc-plugins/compare/v2.2.1...v2.3.0
[2.2.1]: https://github.com/Zate/cc-plugins/compare/v2.1.0...v2.2.1
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
