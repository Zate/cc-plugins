# Portable Agent Skills Plan

This document captures the high-level plan for moving `cc-plugins` from a Claude Code plugin-first repository toward a harness-agnostic Agent Skills library that works across RovoDev, Claude Code, Pi, Codex, and other compatible agents.

## Goal

Maintain one canonical set of skills in one place, using the [Agent Skills specification](https://agentskills.io/specification.md), and install those skills into different agent harnesses instead of maintaining separate Claude/RovoDev/Codex/Pi copies.

## Guiding decisions

1. **Agent Skills is the canonical skill format**
   - Portable skills are directories containing `SKILL.md`.
   - `SKILL.md` uses YAML frontmatter with at least `name` and `description`.
   - Optional directories follow the spec: `scripts/`, `references/`, `assets/`.

2. **`vercel-labs/skills` is the practical installer**
   - Use `npx skills` to install or symlink skills into supported harness locations.
   - Target agents include RovoDev, Claude Code, Codex, Pi, and others as needed.

3. **Git repos are the source of truth**
   - Do not hand-edit installed copies under `~/.agents/skills`, `~/.claude/skills`, etc.
   - Keep public/general skills in a public repo.
   - Keep work/private skills in a private repo or local clone.

4. **Claude Code plugins become enhanced packaging**
   - Claude-specific plugins, hooks, agents, MCP/LSP config, and marketplace files may remain.
   - The reusable instruction content should move toward portable Agent Skills where possible.

## Target repo shape

Preferred long-term structure for this repo:

```text
cc-plugins/
├── skills/                         # portable Agent Skills source of truth
│   ├── code-review/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   ├── scripts/
│   │   └── assets/
│   └── release-notes/
│       └── SKILL.md
├── plugins/                        # Claude Code plugin packaging/enhancements
│   └── ...
├── docs/
└── tests/
```

Private/work-only skills should use the same layout in a separate private repository:

```text
work-agent-skills/
├── skills/
│   ├── work-jira-rollup/
│   │   └── SKILL.md
│   └── work-incident-review/
│       └── SKILL.md
└── README.md
```

## Install model

Install public skills from a local checkout:

```bash
npx skills add ~/projects/cc-plugins \
  -g \
  -a rovodev \
  -a claude-code \
  -a codex \
  -a pi \
  --skill '*'
```

Install public skills from GitHub:

```bash
npx skills add zberg/cc-plugins \
  -g \
  -a rovodev \
  -a claude-code \
  -a codex \
  -a pi \
  --skill '*'
```

Install work/private skills from a local clone:

```bash
npx skills add ~/projects/work-agent-skills \
  -g \
  -a rovodev \
  -a claude-code \
  -a codex \
  -a pi \
  --skill '*'
```

Installed locations are treated as generated/symlinked targets, for example:

```text
~/.agents/skills/       # universal/RovoDev-style agents
~/.claude/skills/       # Claude Code
~/.codex/skills/        # Codex
~/.pi/skills/           # Pi, if supported by installer/current environment
```

## Skill authoring rules

Portable skills should:

- Follow the Agent Skills spec exactly.
- Use lowercase kebab-case names.
- Keep `name` matching the parent directory name.
- Keep `SKILL.md` concise; move detailed material to `references/`.
- Use relative file references from the skill root.
- Avoid harness-specific tool names in core instructions where possible.
- Prefer generic capability language:
  - read files
  - search files
  - edit files
  - run shell commands
  - ask the user
  - track progress
  - delegate to workers/subagents if available
- Include fallback behavior for harnesses without advanced features.

Example portable phrasing:

```md
Read relevant files using the harness's file-reading capability. If the harness
has no dedicated file reader, use shell commands carefully.

If task tracking is available, create a visible checklist. Otherwise, maintain a
short checklist in the response.

If background workers or subagents are available, delegate independent discovery
work. Otherwise, perform the steps sequentially.
```

Avoid Claude-only phrasing in portable skills:

```md
Use the Read tool.
Use TodoWrite.
Spawn an Agent with context: fork.
Use ${CLAUDE_PLUGIN_ROOT}.
```

Claude-specific behavior can remain in Claude plugin packaging or Claude-only skills.

## Public vs work-only skills

Use separate repos rather than separate harness-specific copies:

| Skill type | Source | Distribution |
| --- | --- | --- |
| Public/general | GitHub repo, e.g. `cc-plugins` | `npx skills add zberg/cc-plugins ...` |
| Work/private | Private Bitbucket/Git repo or local clone | `npx skills add ~/projects/work-agent-skills ...` |

Naming guidance:

- Public skills should use general names: `code-review`, `release-notes`, `context-discovery`.
- Work skills should use explicit work names when useful: `work-jira-rollup`, `work-incident-review`, `twg-context`.
- Avoid name collisions between public and private repos.

## Migration phases

### Phase 1: Establish the standard

- Keep this plan as the repo-level direction.
- Add or reference the Agent Skills spec in contributor docs.
- Decide that new portable skills should be created under top-level `skills/`.
- Add validation notes and recommended install commands to README later.

### Phase 2: Pilot portable skills

Pick a small number of low-risk skills and convert or create them as Agent Skills.

Good candidates:

- `code-review`
- `release-notes`
- `context-discovery`
- `changelog`
- `issue-triage`

Avoid starting with `devloop`; it has more Claude-specific orchestration, hooks, state, and command behavior.

### Phase 3: Validate and install

For each portable skill:

```bash
skills-ref validate ./skills/<skill-name>
```

Then test installation:

```bash
npx skills add . -g -a rovodev -a claude-code -a codex -a pi --skill '<skill-name>'
```

Verify the target harnesses can discover and use the skill.

### Phase 4: Migrate existing RovoDev skills

For the existing `~/projects/rd-skills` setup:

1. Convert each skill to Agent Skills spec compliance.
2. Remove RovoDev-only assumptions where possible.
3. Replace the custom linker with `npx skills` installation.
4. Keep the repo/local folder as the source of truth.
5. Retire the dinky custom installer once confidence is high.

### Phase 5: Gradually extract from Claude plugins

For existing `plugins/*/skills/*` content:

1. Audit whether the skill is portable, adapter-required, or Claude-specific.
2. Move portable instruction content to top-level `skills/<name>/`.
3. Keep Claude-specific enhancements in `plugins/<plugin>/`.
4. Avoid duplicating content manually; prefer symlinks, generation, or clear ownership.

Possible classifications:

| Classification | Meaning |
| --- | --- |
| Portable | Works as plain Agent Skill with generic instructions. |
| Adapter-required | Mostly portable but needs harness-specific wrapper or install behavior. |
| Claude-specific | Depends on Claude hooks, plugin manifests, agents, MCP/LSP, or Claude-only workflow semantics. |

### Phase 6: Add automation

Potential future automation:

- CI validation for all `skills/*/SKILL.md` files.
- A script to list portable skills and install examples.
- A compatibility audit for existing Claude plugin skills.
- Optional generation/symlinking from portable skills into Claude plugin directories.

## Open questions

- Should top-level `skills/` be added immediately, or introduced with the first pilot skill?
- Should Claude plugin skill files be symlinks to top-level portable skills where possible?
- How strict should CI be initially: warning-only or blocking?
- Which private/work skills should remain local-only vs installable from private Git URLs?
- How should harness-specific guidance be represented: separate references, compatibility notes, or adapter directories?

## First pilot: agent-help

The first intended cross-harness pilot is `agent-help`, superseding the older Claude-oriented `agent-cli` plugin.

See [`docs/AGENT_HELP_SKILL_PLAN.md`](AGENT_HELP_SKILL_PLAN.md) for the focused plan.

## Near-term next steps

1. Use `agent-help` as the first pilot public skill.
2. Keep `~/projects/agent-help/SKILL.md` as the initial canonical source while the spec stabilizes.
3. Validate with `skills-ref`.
4. Install with `npx skills` into RovoDev, Claude Code, Codex, and Pi.
5. Decide whether `cc-plugins` should vendor `skills/agent-help/`, add Claude plugin packaging under `plugins/agent-help/`, or only reference the separate `agent-help` repo.
6. Repeat with one private/work skill from `rd-skills` or the future work skills repo.
