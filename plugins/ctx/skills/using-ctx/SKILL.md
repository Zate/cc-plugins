---
name: using-ctx
description: "MANDATORY persistent memory system. Use BEFORE responding when you've made decisions, discovered preferences, found patterns, or completed debugging. Use when the user references past discussions or asks about what you remember."
whenToUse: "Any session where you make decisions, learn facts, debug issues, or establish conventions. This is automatic -- ctx hooks manage the lifecycle."
whenNotToUse: "Trivial single-turn Q&A with no decisions or learnings. When the user explicitly says not to store something."
---

# ctx: Your Persistent Memory

You have persistent memory across conversations via `ctx`. Hooks automatically inject stored knowledge at session start and parse commands from your responses at session end.

## The Rule

BEFORE completing any response where you:
- Made or learned a **decision** --> store as `type="decision"`
- Discovered a **preference** or convention --> store as `type="fact"`
- Found a recurring **pattern** --> store as `type="pattern"`
- Debugging revealed a **root cause** --> store as `type="observation"`
- Had an idea worth revisiting --> store as `type="hypothesis"`
- A question can't be answered now --> store as `type="open-question"`

**This is not optional. You are a stateless AI. If you don't store it, it's gone.**

## How to Store

Always include a `tier:` tag. **Key question:** Every session? --> `pinned`. Someday? --> `reference`. This task? --> `working`.

```xml
<!-- Pinned: critical, needed every session -->
<ctx:remember type="fact" tags="tier:pinned,project:myproject">
Always run tests before committing. User preference.
</ctx:remember>

<!-- Working: task-scoped, temporary -->
<ctx:remember type="observation" tags="tier:working,project:myproject">
Auth bug seems related to token refresh timing.
</ctx:remember>

<!-- Reference: durable but not needed every session -->
<ctx:remember type="decision" tags="tier:reference,project:myproject">
Chose PostgreSQL for multi-tenant concurrent write access.
</ctx:remember>
```

### Tiers

| Tier | Auto-Loaded? | Use For | Examples |
|------|-------------|---------|----------|
| `tier:pinned` | Yes | Critical facts, foundational decisions, active conventions | "Always test code", "Uses Three.js + vanilla TS" |
| `tier:reference` | No (use recall) | Durable knowledge, past decisions, resolved issues | "Chose PostgreSQL for multi-tenant" |
| `tier:working` | Yes | Current task context, debugging, scratch | "Token refresh fails on expired tokens" |
| `tier:off-context` | No | Archived, rarely needed | Completed task logs, old debugging |

### Type --> Tier Quick Guide

| When you hear/think... | Type | Tier |
|------------------------|------|------|
| "Please remember: always test our code" | `fact` | `pinned` |
| "We're using Three.js with vanilla TS" | `decision` | `pinned` |
| "This codebase uses InstancedMesh for geometry" | `pattern` | `pinned` |
| "We chose PostgreSQL for multi-tenant" | `decision` | `reference` |
| "The 404 was caused by missing PBR textures" (resolved) | `observation` | `reference` |
| "Debugging: token refresh fails on expired tokens" (in-progress) | `observation` | `working` |
| "Maybe the race is in cache invalidation" | `hypothesis` | `working` |

## Other Commands

Recall (results injected on next prompt - use to access reference knowledge):
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

## Starting a Task

At the start of a task, recall relevant reference knowledge:
```xml
<ctx:recall query="type:decision AND tag:project:myproject"/>
```

This brings in past decisions without them cluttering every session.

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

- Commands in code blocks are ignored - only bare commands in your response text are processed
- Commands are parsed on every user prompt (prompt-submit hook) and at session end (stop hook)
- `recall` and `status` results are injected on the next user prompt
- Use `project:X` tags for cross-project organization

## Coordination with MEMORY.md

Claude Code has a built-in auto memory system (`MEMORY.md` in `~/.claude/projects/<project>/memory/`) that loads project-scoped notes into every conversation's system prompt. ctx is a separate structured knowledge graph. Both are loaded at session start, so duplicated content wastes context tokens.

**Division of labor:**
- **MEMORY.md**: Concise project-level notes -- release rules, gotchas, conventions, short reminders. File-based, project-scoped, always loaded (first 200 lines).
- **ctx**: Detailed typed knowledge -- decisions, patterns, observations, hypotheses. Structured, cross-project, tiered, queryable.

**When you write to MEMORY.md, you MUST also evaluate ctx:**
1. Is this knowledge already in ctx? If so, do NOT duplicate it in MEMORY.md -- keep it in one place only.
2. Does this belong in ctx instead? If it's a decision, pattern, observation, or cross-project knowledge, store it in ctx and keep only a brief reference (or nothing) in MEMORY.md.
3. Does an existing ctx node need updating or removing? If the MEMORY.md change supersedes something in ctx, update or remove the ctx node.
4. Take action -- don't just consider, actually emit the ctx commands (remember/supersede/summarize) in the same response.

**When you store in ctx, check MEMORY.md too:** If the same fact exists in MEMORY.md, remove it from MEMORY.md to avoid duplication. ctx is authoritative (structured and versioned).
