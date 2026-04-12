# Changelog

All notable changes to the ctx plugin are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.3] - 2026-04-12

### Changed

- Removed hardcoded CLI syntax from using-ctx skill and primer
- Agents now use `ctx --agent-help` for command syntax instead
- Skill focuses on strategy (tiers, tagging, coordination) not syntax

## [1.2.2] - 2026-04-12

### Fixed

- Read cwd from Claude Code hook stdin payload instead of relying on shell cwd for project detection
- Use `git -C` to run git against the resolved directory, not the hook process cwd
- Fail closed when project detection fails: load zero nodes instead of every pinned node globally
- Version-gated `--fail-closed` flag (ctx >= 0.6.3); older binaries use sentinel project name fallback
- Support `CTX_PROJECT` env var override for explicit project scoping

## [1.2.1] - 2026-04-05

### Improved

- Stop injecting SKILL.md at session start (primer already covers it)
- Compress using-ctx skill for token efficiency
- Optimize hook injections and session-start scripts

## [1.2.0] - 2026-03-28

### Added

- Initial marketplace release
- Persistent memory via ctx graph database
- Session-start auto-injection hook
- Skills: setup, status, cleanup, recall, using-ctx
