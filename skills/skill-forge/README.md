# Skill Forge

> Meta-skill: interactively create Rovo Dev skills, prompts, and hook guidance using rd-skills conventions.

## Overview

Skill Forge is the skill-building skill. It now starts by helping the agent choose the right Rovo Dev mechanism:

- **Skill** — reusable agent instructions loaded with `get_skill`.
- **Prompt** — a `!name` shortcut that expands into reusable prompt text/context.
- **Hook** — automatic command execution at Rovo Dev lifecycle/tool events, configured outside the current installer.

Forge is based on Rovo Dev source behavior rather than guesses: user skills take precedence over project skills, prompt content expands from `prompts.yml`, and hooks are config-driven CLI commands.

## Installation

```bash
# From the rd-skills repo root:
./install.sh --install skill-forge
```

The global install from this repo is authoritative. Do not keep a duplicate project-local `.rovodev/skills/skill-forge` in this repo unless you are deliberately testing project-scope precedence.

## Usage

### Example prompts

- "Let's build a new skill"
- "Create a reusable prompt for release notes"
- "Should this be a skill, prompt, or hook?"
- "Forge a skill plus prompt for security reviews"

### What happens

1. **Classify** — Forge asks whether the artifact should be a skill, prompt, hook/helper, or combination.
2. **Discover** — It asks focused questions about name, triggers, anti-triggers, workflow, examples, tools, and supporting files.
3. **Generate** — It creates the right files:
   - `skills/<name>/SKILL.md` and `README.md` for skills.
   - `prompts/<group>/<name>.md` plus `prompts/prompts.yml` entries for prompts.
   - Hook docs/helper scripts only when explicitly requested.
4. **Review/install** — It updates catalogs and offers `./install.sh --install <name>` for skills/prompts.

## What it enforces

- Correct mechanism selection: skill vs prompt vs hook.
- Kebab-case names and matching skill frontmatter.
- Specific descriptions and triggers for skill discovery.
- Prompt manifest entries pointing to real content files.
- Hook guidance that names real Rovo Dev events and explains config requirements.
- No project-local duplicate skill installs unless explicitly requested.

## Limitations

- Works best within the `rd-skills` repo because it depends on the templates, installer, and catalog.
- Hook installation is not automated by `install.sh` today; Forge can create guidance/helpers but users must wire hooks into their Rovo Dev config.
- Generated skills/prompts still need real-session testing before merging.

## Changelog

### v1.1.0
- Added source-verified guidance for choosing and creating skills, prompts, and hooks.
- Switched installation guidance to `install.sh` and discouraged repo-local duplicate skill symlinks.

### v1.0.0
- Initial release with interactive discovery flow and template generation.
