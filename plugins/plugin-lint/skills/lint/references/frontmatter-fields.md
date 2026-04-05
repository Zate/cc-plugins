# Frontmatter Fields Reference
Source: `~/projects/claude-code/src/utils/frontmatterParser.ts` (verified 2026-04-03)

## Valid SKILL.md Frontmatter Fields

| Field | Type | Notes |
|---|---|---|
| `name` | string | Skill identifier (kebab-case) |
| `description` | string | Primary trigger mechanism — include when AND what. Required for plugin skills to appear in model listing. |
| `when_to_use` | string | Appended to description in skill listing. Required for plugin/MCP skills to appear in listing (along with description). |
| `argument-hint` | string | Shown in autocomplete |
| `allowed-tools` | string[] | Restrict which tools the skill can use |
| `model` | string | Override model for this skill invocation |
| `effort` | string | Override effort level: `"low"`, `"medium"`, `"high"` |
| `context` | string | `"fork"` isolates in separate context |
| `agent` | string | Agent type to use (e.g., `"Explore"`) |
| `hooks` | object | Inline hook definitions |
| `user-invocable` | boolean | Whether user can invoke via `/skillname` |
| `disable-model-invocation` | boolean | Prevents model from auto-invoking |
| `paths` | string \| string[] | Gitignore-style globs — skill enters conditional pool until a matching file is touched. Affects BOTH model and user invocation. |
| `once` | boolean | Run only once per session |

### ❌ Fields That Do NOT Exist
- `when_not_to_use` — not in parser, not mapped, dead metadata
- `whenToUse` — internal camelCase property, not a frontmatter key
- `whenNotToUse` — not a frontmatter key
- `tags` — not a skill frontmatter field

## Valid Agent .md Frontmatter Fields

| Field | Type | Notes |
|---|---|---|
| `name` | string | Agent identifier |
| `description` | string | When to invoke — also used as `whenToUse` |
| `tools` | string | Comma-separated tool names |
| `disallowedTools` | string | Comma-separated tools to block |
| `model` | string | Model to use |
| `effort` | string | `"low"`, `"medium"`, `"high"` — overrides session default |
| `permissionMode` | string | Permission level |
| `maxTurns` | number | Max turns before stopping |
| `skills` | string[] | Skills available to agent |
| `mcpServers` | string[] | MCP servers available |
| `hooks` | object | Inline hooks |
| `memory` | string | `"user"`, `"project"`, `"local"` |
| `background` | boolean | Run as background agent |
| `isolation` | string | `"worktree"` for isolated git worktree |
| `color` | string | UI color |

## `paths` Gotcha
`paths: ["**/*"]` is a no-op wildcard — every file matches, so the skill is always unconditional. Defeats the purpose of conditional loading.

Good examples:
- `paths: ["**/*.go", "go.mod", "go.sum"]`
- `paths: ["**/*.{ts,tsx,js,jsx}", "package.json"]`
- `paths: ["**/*.py", "requirements.txt", "pyproject.toml"]`
- `paths: ["**/*.{java,kt}", "pom.xml", "build.gradle"]`

## Skill Listing Requirement
For a plugin/MCP skill to appear in the model's skill listing, it must have EITHER:
- A `description` with `hasUserSpecifiedDescription: true` (non-empty description in frontmatter), OR
- A `when_to_use` value

Skills from `commands/` (legacy) always appear. Bundled skills always appear.
