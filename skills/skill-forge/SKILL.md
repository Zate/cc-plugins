---
name: skill-forge
description: "Interactively create Rovo Dev skills, prompts, and hook guidance from the repo templates and source-verified conventions."
version: "1.1.0"
author: "Zate Berg"
allowed-tools:
  - open_files
  - expand_code_chunks
  - grep
  - bash
  - create_file
  - delete_file
  - move_file
  - find_and_replace_code
tags:
  - meta
  - tooling
---

# Skill Forge — Build Skills, Prompts, and Hook Guidance

Create reusable Rovo Dev capabilities in `rd-skills` using source-verified conventions. Forge can create standalone skills, installable prompts, and documentation or helper scripts for event hooks. It must teach the agent which mechanism fits the user's goal before generating files.

**When to use this skill:** When the user says "let's build a new skill," "create a skill," "forge a skill," "add a prompt," "make a reusable prompt," "create hook guidance," or asks how to package reusable Rovo Dev behavior in this repo.

**When NOT to use this skill:** For routine edits to an existing skill/prompt unless the user asks for Forge-style review; for simply installing skills/prompts (use `install.sh`); or in a repo that is not `rd-skills` and lacks the templates/catalog.

---

## Source-Verified Mental Model

Before creating anything, explain the three mechanisms and choose deliberately:

| Mechanism | Use when | How Rovo Dev uses it | rd-skills files |
|---|---|---|---|
| **Skill** | The agent needs reusable instructions, tool recommendations, reference docs, scripts, or a workflow it should load on demand. | Rovo Dev discovers `SKILL.md` files under user skills first (`~/.rovodev/skills`, `~/.agents/skills`), then project `.rovodev/skills`/`.agents/skills` from the cwd upward. Earlier paths win on duplicate names. The system prompt lists skill names/descriptions and agents load full instructions with `get_skill`. | `skills/<name>/SKILL.md`, `skills/<name>/README.md`, optional `references/`, `scripts/`, `assets/`. |
| **Prompt** | The user wants a short `!name` invocation that expands into text/context, often to load a skill with a scope or standard instruction. | Rovo Dev loads prompt manifests from built-ins, repo `.rovodev`, current `.rovodev`, then user `~/.rovodev`. `!prompt-name` expands inline into a `<context name="...">...</context>` block; nested prompts are expanded with cycle protection. | `prompts/prompts.yml` entry plus `prompts/<group>/<name>.md`. Installed to `~/.rovodev/prompts.yml` and `~/.rovodev/prompts/` by `install.sh`. |
| **Hook** | Behavior must run automatically at lifecycle/tool events without waiting for the model to choose a skill or prompt. | Event hooks are configured in Rovo Dev config as CLI commands for events like `on_complete`, `on_error`, `on_tool_permission`, `on_session_start`, `on_session_end`, `on_user_prompt`, `on_tool_start`, and `on_tool_end`. Hook commands receive JSON on stdin; `on_tool_start` may return JSON with `hook_specific_output.updated_args`. | This repo does not auto-install hooks yet. Create docs/helper scripts only when explicitly requested, and tell the user they must wire them into their Rovo Dev config. |

**Decision rule:**
- Default to a **skill** for agent behavior.
- Add a **prompt** when the desired UX is `!name` or when a standard invocation should load a skill with fixed instructions.
- Discuss a **hook** only when the user needs automatic enforcement or instrumentation at a Rovo Dev event.

---

## Process

### Phase 1: Classify the artifact

Ask one question first:

> "Do you want a skill, a `!prompt`, a hook/helper, or a skill plus prompt?"

If the user is unsure, recommend based on the decision rule above. Do not create a hook silently.

### Phase 2: Discovery (ask one question at a time)

For **all artifacts** ask:
1. **Name and purpose** — "What should we call it, and in one sentence what does it do?"
2. **Trigger/usage** — "What would someone say or do to use it? When should it not be used?"
3. **Workflow** — "Walk me through the behavior step by step."
4. **Examples** — "Give one or two realistic invocations and ideal outcomes."

For **skills**, also ask:
- Which tools it should recommend. Use only real tool names. Common defaults:
  - `open_files`, `expand_code_chunks`, `grep` for reading code.
  - `bash` for commands/tests.
  - `create_file`, `find_and_replace_code`, `move_file`, `delete_file` for edits.
  - MCP compressed tools only if the skill truly needs them.
- Whether it needs `references/`, `scripts/`, or `assets/`. Rovo Dev surfaces only those special subdirectories.

For **prompts**, also ask:
- Whether it should load an existing skill, wrap a workflow, or provide standalone context.
- Which group directory to use under `prompts/` (default from the prompt family, e.g. `security/` or `dl/`).

For **hooks**, also ask:
- Event name (`on_complete`, `on_error`, `on_tool_permission`, `on_session_start`, `on_session_end`, `on_user_prompt`, `on_tool_start`, `on_tool_end`).
- Command/script to run and whether it needs stdin JSON, stdout JSON, or only logging/side effects.
- Whether it is advisory or blocking.

### Phase 3: Generate

#### Skills

1. Read `skills/_template/SKILL.md` and `skills/_template/README.md`.
2. Create:
   - `skills/<skill-name>/SKILL.md`
   - `skills/<skill-name>/README.md`
   - Optional `references/`, `scripts/`, `assets/` only when needed.
3. Frontmatter requirements:
   - `name` must be kebab-case and match the directory.
   - `description` must be one concise sentence; this is what appears in the available skills list and drives agent selection.
   - `allowed-tools` should list recommended tools, not imaginary permissions.
   - Extra fields may exist, but Rovo Dev only interprets the known fields (`name`, `description`, `allowed-tools`, `license`, `compatibility`, `metadata`, `disable-model-invocation`).
4. Body requirements:
   - Explicit "When to use" and "When NOT to use" sections.
   - Actionable instructions with ordering/gates.
   - Examples and anti-patterns.
   - Reference file notes if present.

#### Prompts

1. Create `prompts/<group>/<prompt-name>.md`.
2. Add an entry to `prompts/prompts.yml`:

   ```yaml
   - name: <prompt-name>
     description: "<one-line description>"
     content_file: <group>/<prompt-name>.md
   ```

3. Prompt content should be direct instructions. If it should use a skill, say: `Load the \`<skill-name>\` skill with the get_skill tool, then ...`. Do not put fake tool calls in code fences.
4. Keep prompt names kebab-case. Users invoke them as `!<prompt-name>`.

#### Hooks

1. Do not add hooks to `prompts/prompts.yml` or `skills/`.
2. If requested, create a helper script in an appropriate repo script directory and a README/config snippet only if the user asks for files.
3. Document the event, stdin payload expectations, exit behavior, and any JSON stdout contract.
4. State clearly that hook installation requires user config changes; `install.sh` currently manages skills and prompts, not hooks.

### Phase 4: Review, install, and catalog

1. Show a concise summary of created/updated files.
2. Update README catalog entries for new user-facing skills/prompts.
3. For skills/prompts, offer to run `./install.sh --install <name>`. Prefer the installer over manual symlinks/copies.
4. Do not create project-local `.rovodev/skills/<name>` duplicates in this repo unless the user explicitly asks; the global install from this repo is authoritative.

---

## Quality Checklist

Before finishing, verify:

- [ ] Artifact type is correct: skill vs prompt vs hook.
- [ ] Skill directory and frontmatter `name` match exactly.
- [ ] Skill description is specific enough for the available-skills list.
- [ ] Prompt manifest points to an existing content file.
- [ ] Prompt content uses direct instructions, not fake tool-call code blocks.
- [ ] Hook guidance names a real event and config contract.
- [ ] README/catalog updated for new user-facing artifacts.
- [ ] No placeholder text remains.
- [ ] No local `.rovodev/skills/` duplicate was created accidentally.

---

## Anti-Patterns

- **Do not** create a skill when a tiny `!prompt` wrapper is enough.
- **Do not** create a prompt when the agent needs substantial reusable instructions; create a skill and optionally a prompt that loads it.
- **Do not** imply hooks are installed by the rd-skills installer today.
- **Do not** use non-existent tool names in `allowed-tools`.
- **Do not** create vague, catch-all triggers.
- **Do not** skip README/catalog updates for user-facing additions.
