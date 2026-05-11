# Changelog

All notable changes to the ctx plugin are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-05-12

### Added

- **`--agent-out` flag** — all result commands now support `--agent-out` for dense AOF (Agent Output Format) output optimised for agent consumption: `recall`, `status`, `list`, `query`, `search`, `show`, `add`, `update`, `delete`, `link`, `unlink`, `edges`, `related`, `tag`, `untag`, `compose`, `accessed`, `trace`, `summarize`, and all `doc` subcommands
- **`ctx recall` command** — new explicit recall command that runs a memory query immediately and prints results in the current turn; supports `--inject` to also queue results for next prompt-submit injection, and `--agent-out` for AOF output
- **`ctx doc` subsystem** — import, decompose, search, and promote markdown documents as a separate node kind (invisible to memory queries); commands: `doc import`, `doc show`, `doc search`, `doc export`, `doc promote`, `doc mv`, `doc insert`, `doc remove`, `doc fork`, `doc split`, `doc inline`
- **MCP tools** — `ctx_doc_import`, `ctx_doc_show`, `ctx_doc_export`, `ctx_doc_search`, `ctx_doc_promote` exposed as MCP server tools
- **`ctx recall` pagination** — `list`, `search`, and `query` commands support `--limit` flag; AOF output includes `more=1` + `next` hint for continuation
- **Agent-help registry** — all commands now register AH1/AH2 metadata; `ctx --agent-help` emits spec-compliant index; `ctx <cmd> --agent-help` emits per-command detail

### Changed

- `using-ctx` skill expanded with Core Commands section, Recall vs Query guidance, `--agent-out` examples, full XML command reference, and `ctx doc` subsystem documentation
- `recall` skill updated to use `ctx recall` (not `ctx query`) with `--agent-out` and `--inject` examples
- `status` skill updated to use `ctx status --agent-out`
- README updated with Direct CLI section (recall, `--agent-out`, doc subsystem), Explicit Recall Command section, Agent-Optimised Output section, and clarified troubleshooting for XML vs CLI recall
- Bumped minimum required binary version to `0.7.0`

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
