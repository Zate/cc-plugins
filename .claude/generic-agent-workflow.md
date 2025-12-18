# Devloop Plan: Generic Agent Integration Documentation

**Created**: 2025-12-17
**Updated**: 2025-12-17 15:00
**Status**: Planning
**Current Phase**: Ready for Implementation

## Overview

Create comprehensive documentation enabling generic AI coding agents (Cursor, Aider, Gemini, etc.) to follow devloop methodology without requiring Claude Code plugin. Uses lightweight entry point with file references to minimize duplication and maintenance burden.

## Requirements

From spike report (`.claude/generic-agent-integration-spike-report.md`):
- Single universal guide document
- Minimal duplication (reference plugin files)
- Complete plan format specification (inline)
- Core workflows via file references
- Best practices and integration guidance (inline)
- Agent-specific configuration examples

## Architecture

**Single Entry Point Design**:
- Location: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`
- Inline content: Quick start, principles, plan format, best practices, integration
- Referenced content: Detailed workflows point to `../commands/*.md` files
- Size target: ~300-400 lines (vs 650 in prototype)

## Tasks

### Phase 1: Core Documentation  [parallel:none]
**Goal**: Create the entry point document with inline essentials

- [ ] Task 1.1: Create DEVLOOP_FOR_GENERIC_AGENTS.md with structure
  - Acceptance: File exists with all section headers
  - Files: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`
  - Testing: File is readable and well-structured

- [ ] Task 1.2: Write Quick Start section
  - Acceptance: Clear prerequisites, entry points by task type
  - Files: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`

- [ ] Task 1.3: Write Core Principles section
  - Acceptance: Brief, actionable principles for agents
  - Files: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`

- [ ] Task 1.4: Write complete Plan File Format section
  - Acceptance: Full format spec, all markers documented, link to plan-management skill
  - Files: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`

### Phase 2: Workflow References  [parallel:full]
**Goal**: Create workflow sections with file references

- [ ] Task 2.1: Create Full Workflow section  [parallel:A]
  - Acceptance: Clear instructions to read ../commands/devloop.md
  - Files: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`

- [ ] Task 2.2: Create Quick Workflow section  [parallel:A]
  - Acceptance: Reference to ../commands/quick.md with context
  - Files: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`

- [ ] Task 2.3: Create Spike Workflow section  [parallel:A]
  - Acceptance: Reference to ../commands/spike.md
  - Files: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`

- [ ] Task 2.4: Create Continue Workflow section  [parallel:A]
  - Acceptance: Reference to ../commands/continue.md
  - Files: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`

- [ ] Task 2.5: Create Review Workflow section  [parallel:A]
  - Acceptance: Reference to ../commands/review.md
  - Files: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`

### Phase 3: Best Practices & Integration  [parallel:partial]
**Goal**: Add guidance for using devloop effectively

- [ ] Task 3.1: Write Best Practices section  [parallel:B]
  - Acceptance: Context management, task management, quality standards, communication
  - Files: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`

- [ ] Task 3.2: Write Integration section  [parallel:B]
  - Acceptance: Examples for .cursorrules, .aider.conf, generic agents
  - Files: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`

- [ ] Task 3.3: Write Reference Tables section  [parallel:B]
  - Acceptance: Command quick reference, file locations table
  - Files: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`

- [ ] Task 3.4: Write Troubleshooting section
  - Acceptance: Common issues and solutions
  - Files: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`
  - Depends: 3.1, 3.2, 3.3

### Phase 4: Integration & Polish  [parallel:none]
**Goal**: Integrate with plugin and finalize

- [ ] Task 4.1: Update main README with link
  - Acceptance: README links to new doc with clear description
  - Files: `plugins/devloop/README.md`

- [ ] Task 4.2: Update CHANGELOG
  - Acceptance: Entry for v1.9.0 with generic agent documentation
  - Files: `plugins/devloop/CHANGELOG.md`

- [ ] Task 4.3: Update plugin version
  - Acceptance: Version bumped from 1.8.0 to 1.9.0
  - Files: `plugins/devloop/.claude-plugin/plugin.json`

- [ ] Task 4.4: Review and polish documentation
  - Acceptance: Spelling, grammar, formatting, consistency checked
  - Files: `plugins/devloop/docs/DEVLOOP_FOR_GENERIC_AGENTS.md`

### Phase 5: Testing  [parallel:none]
**Goal**: Validate documentation works

- [ ] Task 5.1: Manual review of all sections
  - Acceptance: All sections complete, links work, examples clear
  - Testing: Read through entire document

- [ ] Task 5.2: Verify file references
  - Acceptance: All ../commands/*.md and ../skills/*.md paths are correct
  - Testing: Check relative paths resolve correctly

## Progress Log
- 2025-12-17 15:00: Plan created from spike findings
- 2025-12-17 15:05: Plan saved, ready for `/devloop:continue` when ready to implement
