# skills/

Reference copies of personal skills pulled in from `~/.agents/skills` and
`~/projects/rd-skills/skills` for safekeeping — not yet packaged as
Claude Code plugins.

These were originally written for Rovo Dev (Atlassian's internal agent CLI),
so they still contain Rovo-Dev-specific paths and framing (e.g.
`~/.rovodev/skills/...`, "Rovo Dev skills"). They're kept here as-is,
intentionally, as source material for rebuilding each one as an
agent-agnostic Claude Code skill/plugin later. Obviously Atlassian-internal
or sensitive details (internal wiki links, internal team names) have been
stripped or redacted; everything else was left intact.

| Skill | Source | Notes |
|-------|--------|-------|
| `goals/` | `~/.agents/skills/goals` | Repo-local `goals/` system for decomposing work into atomic, agent-executable goals. |
| `golang/` | `~/.agents/skills/golang` | Go conventions, toolchain, and quality gates. |
| `mdv/` | `~/.agents/skills/mdv` | Collaborative markdown/diagram viewport for human+agent co-editing. Depends on the external `mdv` app + MCP server. |
| `security-deep-dive/` | `~/.agents/skills/security-deep-dive` | Iterative-deepening security review skill (threat model, findings, decision brief). |
| `skill-forge/` | `~/.agents/skills/skill-forge` | Meta-skill for interactively creating Rovo Dev skills/prompts/hooks. Overlaps with this repo's own `plugin-dev:skill-development`/`skill-creator` — kept for reference, not installed as a plugin. |
| `systemigram/` | `~/.agents/skills/systemigram` | Generates systemigram SVGs (noun-phrase nodes, verb-phrase edges). Companion CLI in `scripts/systemigram.py`. |
| `docs/` | `~/projects/rd-skills/skills/docs` | Documentation/diagram style guide and editing process. Not a skill (no `SKILL.md`) — reference material to fold into the `diagrams`/`systemigram` skills later. Project-specific content (an internal identity-federation demo) was redacted; the general style-guide/editing-process content was left intact. |

`diagrams/` from `rd-skills/skills` was intentionally skipped — this repo's
existing [`plugins/diagrams`](../plugins/diagrams) plugin already covers SVG
generation plus Mermaid/Excalidraw/D2 with more scope than the simpler
SVG-only version in `rd-skills`.
