---
name: using-ctx
description: "MANDATORY persistent memory system for decisions, facts, patterns, and observations."
when_to_use: "Making decisions, learning facts, debugging issues, or establishing conventions."
paths: ["**/*"]
---

# ctx: Persistent Memory

You are stateless. Use \`ctx\` to persist knowledge across sessions.

## Store (ctx add)
Run via Bash BEFORE responding. Always include \`tier:\` and \`project:\` tags.
- **Pinned** (\`tier:pinned\`): Critical, loaded every session. (Facts, foundational decisions).
- **Working** (\`tier:working\`): Task-scoped, temporary. (Active debugging, current plan state).
- **Reference** (\`tier:reference\`): Durable but not always needed. (Past decisions, resolved issues).

\`\`\`bash
ctx add --type [decision|fact|pattern|observation|hypothesis] --tag tier:[pinned|working|reference] --tag project:NAME "content"
\`\`\`

## Retrieve (ctx query / show)
- **Search**: \`ctx query 'type:decision AND tag:project:X'\`
- **List**: \`ctx list --tag project:X --since 24h\`
- **Read**: \`ctx show <id>\`

## Coordination
- **MEMORY.md**: Use for short, project-specific reminders and release rules.
- **ctx**: Use for structured, typed knowledge (Decisions, Patterns, Observations).

**If you don't store it, it's gone.**
