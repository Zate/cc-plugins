# Agent Help Skill Plan

This document captures the plan to make `agent-help` the first cross-harness, Agent Skills-compatible skill shipped from this ecosystem.

## Goal

Ship a simple, elegant, highly cross-agent-compatible skill that helps agents implement the `agent-help` CLI convention in any CLI project.

The skill should support RovoDev, Claude Code, Pi, Codex, and other harnesses that understand the Agent Skills format.

## Source project

The canonical specification and primary skill source currently live in:

```text
~/projects/agent-help/
├── SKILL.md
├── AHF-RFC.md
├── README.md
├── FAQ.md
├── llms.txt
├── llms-full.txt
├── references/
├── examples/
└── site/
```

That repo is the source for:

- the concept
- the spec
- the website
- examples and references
- the canonical `agent-help` skill

## Relationship to `cc-plugins`

`cc-plugins` currently has an older Claude Code plugin:

```text
plugins/agent-cli/
├── .claude-plugin/plugin.json
├── README.md
└── skills/agent-cli/SKILL.md
```

That older plugin should be treated as the predecessor to `agent-help`.

Preferred direction:

1. Rename/reframe `agent-cli` as `agent-help`.
2. Make the Agent Skills-compatible `agent-help/SKILL.md` the canonical content.
3. Keep any Claude Code plugin packaging as an optional adapter/enhancement.
4. Avoid maintaining separate Claude/RovoDev/Codex/Pi copies manually.

## Naming

Use:

```text
agent-help
```

Avoid continuing the `agent-cli` name except as a deprecated compatibility bridge.

Rationale:

- `agent-help` names the user-facing CLI convention.
- It aligns with the `--agent-help` flag.
- It is broader than CLI implementation details and can include `--agent-out` guidance.

## Canonical skill shape

The portable skill should follow the Agent Skills spec:

```text
agent-help/
├── SKILL.md
├── references/
│   └── REFERENCE.md
├── examples/
└── assets/              # optional future templates/snippets
```

Required `SKILL.md` frontmatter:

```yaml
---
name: agent-help
description: >-
  Implement the agent-help convention in a CLI. Use when building or modifying
  a CLI that agents will invoke: add --agent-help for AHF-format invocation
  help and --agent-out for TOON-encoded runtime results with an AHF protocol
  envelope.
license: Apache-2.0
metadata:
  version: "0.1"
  spec: "https://zate.github.io/agent-help/AHF-RFC.md"
  homepage: "https://github.com/Zate/agent-help"
compatibility: >-
  Language-agnostic. Works with any CLI framework. No runtime dependencies.
---
```

## Skill design principles

The `agent-help` skill should be:

- **Harness-neutral**: no Claude-only tool assumptions.
- **Language-neutral**: works for Go/Cobra, Python/Click, Python/argparse, Rust/Clap, Node/Commander, and others.
- **Spec-driven**: references the AHF RFC and quick-reference material rather than duplicating every detail in `SKILL.md`.
- **Small enough to load**: keep the main `SKILL.md` concise; move deeper details to `references/`.
- **Implementation-oriented**: give agents concrete steps for modifying an existing CLI.
- **Validation-oriented**: tell agents how to test `--agent-help`, `--agent-out`, and error hints.

## Expected agent workflow

When invoked, the skill should guide an agent to:

1. Inspect the CLI framework and command structure.
2. Add the `--help` breadcrumb:

   ```text
   LLM agent? Use --agent-help for token-optimized usage.
   ```

3. Implement trailing global `--agent-help`:

   ```text
   tool --agent-help
   tool subcmd --agent-help
   tool group subcmd --agent-help
   ```

4. Emit AH1 index records for root help.
5. Emit AH2 command detail records for command-specific help.
6. Add AE1-style error hints for invalid invocations.
7. Add `--agent-out` for structured runtime results where useful.
8. Test outputs against the spec and examples.

## Distribution plan

### From the `agent-help` repo

Install directly from the local repo during development:

```bash
npx skills add ~/projects/agent-help \
  -g \
  -a rovodev \
  -a claude-code \
  -a codex \
  -a pi \
  --skill agent-help
```

Install from GitHub after publication:

```bash
npx skills add Zate/agent-help \
  -g \
  -a rovodev \
  -a claude-code \
  -a codex \
  -a pi \
  --skill agent-help
```

### From `cc-plugins`

After the portable skill is stable, choose one of these approaches:

1. **Reference-only**: `cc-plugins` points users to `Zate/agent-help`.
2. **Vendored copy**: `cc-plugins/skills/agent-help/` contains a copy of the canonical skill.
3. **Generated/synced copy**: a script syncs from `~/projects/agent-help/SKILL.md` into `cc-plugins`.
4. **Claude adapter only**: `plugins/agent-help/` contains Claude Code marketplace packaging that wraps the canonical skill.

Current repo decision: vendor a copy at `skills/agent-help/` so `cc-plugins` can be installed directly with `npx skills`, while treating `~/projects/agent-help` / `Zate/agent-help` as the upstream source for the specification and canonical project docs.

## Migration from `agent-cli`

Recommended staged migration:

### Stage 1: Deprecate conceptually

- [x] Document that `agent-cli` is superseded by `agent-help`.
- [x] Stop adding new features to `plugins/agent-cli`.

### Stage 2: Add new portable skill

- [x] Add `skills/agent-help/` as the portable skill copy in this repo.
- [x] Validate `skills/agent-help/` with `skills-ref`.
- [x] Verify `npx skills add . --list` discovers `agent-help`.
- [x] Test `npx skills add . --skill agent-help` in RovoDev, Claude Code, Codex, and Pi using a temporary `HOME`.

Verified command:

```bash
env HOME=/private/tmp/cc-plugins-skills-test \
  npx skills add . -g -a rovodev -a claude-code -a codex -a pi \
  --skill agent-help --copy -y
```

With `skills@1.5.7`, the installer wrote copied skills to `.rovodev/skills/agent-help`, `.claude/skills/agent-help`, `.agents/skills/agent-help`, and `.pi/agent/skills/agent-help` under the temporary `HOME`.

### Stage 3: Add optional Claude packaging

Potential new plugin path:

```text
plugins/agent-help/
├── .claude-plugin/plugin.json
├── README.md
└── skills/agent-help/SKILL.md
```

This should either wrap, symlink, or clearly mirror the canonical Agent Skills content.

Current implementation: `plugins/agent-help/` mirrors the portable skill body for Claude Code marketplace installation and adds Claude-only invocation frontmatter. Regenerate the adapter with `scripts/sync-portable-skill-adapter.sh agent-help`.

### Stage 4: Compatibility bridge

Options:

- Keep `agent-cli` as-is but mark deprecated.
- [x] Replace `agent-cli` content with a short forwarding skill telling agents to use `agent-help`.
- Remove `agent-cli` only in a future breaking marketplace release.

## Launch checklist for next week

### Spec and docs

- [ ] Finalize draft naming: AHF/AOF/agent-help terminology.
- [ ] Ensure `AHF-RFC.md` is internally consistent.
- [ ] Ensure `README.md` explains the problem, solution, examples, and install path.
- [ ] Ensure `FAQ.md` covers JSON, MCP, TOON, and why a CLI convention matters.
- [ ] Ensure `llms.txt` and `llms-full.txt` are current.

### Website

- [ ] Publish/verify the site.
- [ ] Ensure the spec URL in `SKILL.md` is correct.
- [ ] Add clear install instructions for agents.

### Skill

- [ ] Validate `SKILL.md` against the Agent Skills spec.
- [ ] Keep `SKILL.md` concise and move details into references.
- [ ] Include language/framework implementation guidance.
- [ ] Include explicit validation commands/examples.
- [ ] Install via `npx skills` into target harnesses.

### Cross-agent testing

- [ ] RovoDev can discover and use the skill.
- [ ] Claude Code can discover and use the skill.
- [ ] Codex can discover and use the skill.
- [ ] Pi can discover and use the skill.
- [ ] At least one real CLI gets `--agent-help` implemented by an agent using the skill.

### `cc-plugins`

- [x] Decide whether to add `skills/agent-help/` here or only link to `Zate/agent-help`.
- [x] Decide whether to create `plugins/agent-help/` as Claude marketplace packaging.
- [x] Decide how to deprecate `plugins/agent-cli/`.

## Open questions

- Is `AHF` the final name for invocation help and envelope records?
- Is `AOF` still the right term when `--agent-out` delegates body encoding to TOON?
- Should `--agent-help` be strictly trailing-only, or should some frameworks support prefix form for compatibility?
- Should `--agent-out` be required for conformance or only recommended?
- Should the skill include framework-specific snippets in `SKILL.md`, or move them to `references/`?
- Should `cc-plugins` vendor the skill or treat `agent-help` as a separate first-class repo?
