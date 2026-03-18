---
name: forge
description: "Create new playbooks, skills, and templates. Nyx's self-extension capability — build reusable processes from patterns you encounter."
user-invocable: true
argument-hint: "[playbook|skill|template] [name]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Forge

Build new playbooks, skills, and templates. This is how you extend yourself — when you encounter a workflow you'll need to repeat, forge it into something reusable.

## Parse Arguments

Check `$ARGUMENTS`:
- If starts with "playbook" → Forge Playbook flow
- If starts with "skill" → Forge Skill flow
- If starts with "template" → Forge Template flow
- If empty or unclear → Ask: "What do you want to build? A playbook (structured workflow), a skill (knowledge/capability), or a template (document scaffold)?"

## Forge Playbook

Interactive facilitation — ask one question at a time:

1. "What does this playbook do? What recurring workflow does it capture?"
2. "When should it be triggered? What phrase or situation kicks it off?"
3. "What are the phases? Walk me through the steps — each phase should produce something tangible."
   - For each phase: "What does this phase produce? What's the artifact?"
4. "What should the playbook NOT be used for? Any exclusions?"

Once you have answers:
1. Read the playbook template from `${CLAUDE_PLUGIN_ROOT}/templates/playbook-template.md`
2. Fill in the template with the user's answers
3. Present the draft for review
4. Ask: "Where should this live?"
   - **Plugin-local**: `${CLAUDE_PLUGIN_ROOT}/skills/playbooks/<name>/SKILL.md` — available when nyx is installed
   - **User-local**: `~/.claude/skills/<name>/SKILL.md` — available in all sessions regardless of plugin
5. Write to chosen location
6. Confirm with file path

## Forge Skill

1. "What capability does this skill provide?"
2. "When should it be invoked? What triggers it?"
3. "When should it NOT be invoked?"
4. "What tools does it need?" (suggest based on description)
5. "Should it be user-invocable (slash command) or model-invoked only?"

Build the skill with proper frontmatter:
```yaml
---
name: <name>
description: "<description>"
user-invocable: <true|false>
argument-hint: "<hint if user-invocable>"
allowed-tools: <tools>
---
```

Write a focused body with: purpose, when to use, process, output format.

Ask plugin-local vs user-local, write, confirm.

## Forge Template

1. "What is this template for? What kind of document does it scaffold?"
2. "What sections does it need?"
3. "What fields are variable? (These become `{{placeholders}}`)"

Build the template with YAML frontmatter for metadata and `{{placeholder}}` syntax for variable content.

Write to `${CLAUDE_PLUGIN_ROOT}/templates/<name>.md` (or user-specified path).

## Principles

- Ask questions one at a time, not in batches
- Every playbook phase must produce a tangible artifact
- Don't over-engineer. A 3-phase playbook beats a 10-phase playbook.
- If the user already knows what they want, don't slow them down with unnecessary questions — adapt the flow
- Name things clearly. The name should tell you what it does.
