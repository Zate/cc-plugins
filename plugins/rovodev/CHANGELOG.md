# Changelog

All notable changes to the rovodev plugin will be documented in this file.

## [1.0.0] - 2026-01-09

### Added

- Initial release of rovodev plugin for Rovo Dev CLI
- Core workflow prompts:
  - `rovodev.md` - Main workflow entry point
  - `spike.md` - Time-boxed investigation
  - `continue.md` - Resume from plan or fresh start
  - `fresh.md` - Save state for context reset
  - `quick.md` - Fast fixes without planning overhead
  - `review.md` - Code review workflow
  - `ship.md` - Commit and PR workflow

- Specialized subagents:
  - `task-planner.md` - Planning, requirements, DoD validation
  - `engineer.md` - Code exploration, architecture, git ops
  - `reviewer.md` - Code review and quality assurance
  - `doc-generator.md` - Documentation generation

- Skills documentation:
  - `plan-management.md` - Working with .devloop/plan.md
  - `python-patterns.md` - Python best practices for Rovo Dev CLI
  - `git-workflows.md` - Git operations and conventions

- Helper scripts:
  - `check-plan-complete.sh` - Check plan completion status
  - `parse-local-config.sh` - Parse .devloop/local.md config

- Documentation:
  - `README.md` - Plugin overview
  - `INTEGRATION.md` - Integration guide for rovodev CLI
  - `CHANGELOG.md` - Version history

### Features

- Full spike → plan → execute workflow support
- Compatible with devloop plan format
- Project-specific context for Rovo Dev CLI (acra-python)
- Script automation for common tasks
- Conventional commit support
- Branch management
- PR creation workflows
