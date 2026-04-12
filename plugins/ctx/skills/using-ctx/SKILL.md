---
name: using-ctx
description: "MANDATORY persistent memory system for decisions, facts, patterns, and observations."
when_to_use: "Making decisions, learning facts, debugging issues, or establishing conventions."
paths: ["**/*"]
---

# ctx: Persistent Memory

You are stateless. Use `ctx` to persist knowledge across sessions.

For command syntax: `ctx --agent-help` (index) or `ctx --agent-help <command>` (detail).

## When to Store
Run via Bash BEFORE responding. Store when you learn something that would be useful in a future session.

## Tagging Convention
Always include `tier:` and `project:` tags on every node.
- **tier:pinned**: Critical, loaded every session. Facts, foundational decisions.
- **tier:working**: Task-scoped, temporary. Active debugging, current plan state.
- **tier:reference**: Durable but not always loaded. Past decisions, resolved issues.
- **project:NAME**: Scope to current project (`basename` of git root, lowercase).

## Coordination with MEMORY.md
- **MEMORY.md**: Short project-specific reminders, release rules, user preferences.
- **ctx**: Structured, typed knowledge (decisions, patterns, observations, facts).
- Don't duplicate across both. Check before writing.

**If you don't store it, it's gone.**
