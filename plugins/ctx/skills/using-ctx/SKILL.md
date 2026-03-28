---
name: using-ctx
description: "MANDATORY persistent memory system. Use BEFORE responding when you've made decisions, discovered preferences, found patterns, or completed debugging. Use when the user references past discussions or asks about what you remember."
whenToUse: "Any session where you make decisions, learn facts, debug issues, or establish conventions."
whenNotToUse: "Trivial single-turn Q&A with no decisions or learnings. When the user explicitly says not to store something."
---

# ctx: Your Persistent Memory

You have persistent memory across conversations via `ctx`. Stored knowledge is automatically injected at session start. You store and retrieve knowledge by calling the `ctx` binary directly via Bash.

## The Rule

BEFORE completing any response where you:
- Made or learned a **decision** --> store as `type decision`
- Discovered a **preference** or convention --> store as `type fact`
- Found a recurring **pattern** --> store as `type pattern`
- Debugging revealed a **root cause** --> store as `type observation`
- Had an idea worth revisiting --> store as `type hypothesis`
- A question can't be answered now --> store as `type open-question`

**This is not optional. You are a stateless AI. If you don't store it, it's gone.**

## How to Store (ctx add)

Use the `ctx add` command via Bash. Always include a `tier:` tag.

**Key question:** Every session? --> `tier:pinned`. Someday? --> `tier:reference`. This task? --> `tier:working`.

```bash
# Pinned: critical, needed every session
ctx add --type fact --tag tier:pinned --tag project:myproject "Always run tests before committing."

# Working: task-scoped, temporary
ctx add --type observation --tag tier:working --tag project:myproject "Auth bug seems related to token refresh timing."

# Reference: durable but not needed every session
ctx add --type decision --tag tier:reference --tag project:myproject "Chose PostgreSQL for multi-tenant concurrent write access."
```

The command returns the created node ID, which you can use for linking.

### Tiers

| Tier | Auto-Loaded? | Use For | Examples |
|------|-------------|---------|----------|
| `tier:pinned` | Yes | Critical facts, foundational decisions, active conventions | "Always test code", "Uses Three.js + vanilla TS" |
| `tier:reference` | No (use query) | Durable knowledge, past decisions, resolved issues | "Chose PostgreSQL for multi-tenant" |
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

## How to Query (ctx query / ctx list)

```bash
# Find all decisions for a project
ctx query 'type:decision AND tag:project:myproject'

# Find all pinned nodes
ctx query 'tag:tier:pinned'

# List recent nodes
ctx list --since 24h

# List by type
ctx list --type observation

# List by tag
ctx list --tag project:myproject

# Full-text search
ctx query 'content:authentication'
```

## How to Read a Specific Node

```bash
# Show full node content by short ID prefix
ctx show 01KMSE4R
```

## How to Compose Context

```bash
# Compose specific nodes for subagent injection
ctx compose --ids "01KM1,01KM3" --format markdown

# Compose by query with token budget
ctx compose --query "tag:tier:pinned AND tag:project:myproject" --budget 5000
```

## Managing Nodes

```bash
# Add a tag
ctx tag 01KMSE4R tier:reference

# Remove a tag
ctx untag 01KMSE4R tier:working

# Supersede an old node with new content
ctx add --type decision --tag tier:pinned "New decision replacing old one."
# Then link them:
ctx link <new-id> <old-id> --type SUPERSEDES

# Check status
ctx status
```

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

- Use `ctx add` via Bash for writes -- this is immediate and reliable
- Use `ctx query` or `ctx list` for reads during a session
- Session-start hook automatically injects pinned + working nodes
- Use `project:X` tags for cross-project organization
- Always include a `tier:` tag on every node

## Coordination with MEMORY.md

Claude Code has a built-in auto memory system (`MEMORY.md` in `~/.claude/projects/<project>/memory/`). ctx is a separate structured knowledge graph.

**Division of labor:**
- **MEMORY.md**: Concise project-level notes -- release rules, gotchas, conventions, short reminders. File-based, project-scoped, always loaded (first 200 lines).
- **ctx**: Detailed typed knowledge -- decisions, patterns, observations, hypotheses. Structured, cross-project, tiered, queryable.

**Avoid duplication** between the two systems. If it's a decision, pattern, or observation, prefer ctx. If it's a quick one-line project convention, prefer MEMORY.md.
