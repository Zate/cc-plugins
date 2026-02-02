---
name: using-ctx
description: "MANDATORY persistent memory system. Use BEFORE responding when you've made decisions, discovered preferences, found patterns, or completed debugging. Use when the user references past discussions or asks about what you remember."
whenToUse: "Any session where you make decisions, learn facts, debug issues, or establish conventions. This is automatic — ctx hooks manage the lifecycle."
whenNotToUse: "Trivial single-turn Q&A with no decisions or learnings. When the user explicitly says not to store something."
---

# ctx: Your Persistent Memory

You have persistent memory across conversations via `ctx`. Hooks automatically inject stored knowledge at session start and parse commands from your responses at session end.

## The Rule

BEFORE completing any response where you:
- Made or learned a **decision** → store as `type="decision"`
- Discovered a **preference** or convention → store as `type="fact"`
- Found a recurring **pattern** → store as `type="pattern"`
- Debugging revealed a **root cause** → store as `type="observation"`
- Had an idea worth revisiting → store as `type="hypothesis"`
- A question can't be answered now → store as `type="open-question"`

**This is not optional. You are a stateless AI. If you don't store it, it's gone.**

## How to Store

```xml
<ctx:remember type="decision" tags="tier:reference,project:myproject">
Chose SQLite over PostgreSQL for single-binary deployment requirement.
</ctx:remember>
```

Always include a `tier:` tag:
- `tier:pinned` — Always loaded (critical facts)
- `tier:reference` — Loaded by default (most knowledge)
- `tier:working` — Current task context (temporary)
- `tier:off-context` — Archived (not loaded)

## Other Commands

Recall (results injected on next prompt):
```xml
<ctx:recall query="type:decision AND tag:project:X"/>
```

Status check:
```xml
<ctx:status/>
```

Task boundaries:
```xml
<ctx:task name="feature-name" action="start"/>
<ctx:task name="feature-name" action="end"/>
```

Link nodes: `<ctx:link from="ID1" to="ID2" type="DEPENDS_ON"/>`
Summarize: `<ctx:summarize nodes="ID1,ID2">Summary here.</ctx:summarize>`
Supersede: `<ctx:supersede old="ID1" new="ID2"/>`
Expand: `<ctx:expand node="ID1"/>`

## Red Flags

| Thought | Reality |
|---------|---------|
| "This isn't important enough" | Future you has no memory of this session |
| "I'll remember naturally" | You won't. You're stateless. |
| "This is temporary" | Temporary facts become permanent gaps |
| "The user can just tell me again" | That's wasting their time |
| "I'm just exploring, nothing to store" | Exploration findings ARE knowledge |
| "I already stored something this session" | One fact doesn't cover a whole session |

## Rules

- Commands in code blocks are ignored — only bare commands in your response text are processed
- Commands are parsed on every user prompt (prompt-submit hook) and at session end (stop hook)
- `recall` and `status` results are injected on the next user prompt
- Use `project:X` tags for cross-project organization
