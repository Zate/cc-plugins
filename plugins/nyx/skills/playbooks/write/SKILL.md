---
name: write
description: "Phased writing workflow. Interview for brief, outline, draft, refine. Use for blog posts, articles, documentation, reports, or any substantial writing."
user-invocable: true
argument-hint: "[topic or title]"
allowed-tools: Read, Write, Edit, Glob, Grep, Agent
---

# Write Playbook

Structured writing workflow. Good writing starts with understanding what you're writing and why — not with a blank page.

## Phase 1: Brief (Facilitated Q&A)

Establish the brief before writing anything:

1. "What are we writing?" — Topic, type (blog post, report, documentation, article, etc.)
2. "Who's the audience?" — Technical level, context, what they already know
3. "What's the purpose?" — What should the reader know, feel, or do after reading?
4. "What tone?" — Formal/casual, energetic/measured, technical/accessible
5. "Any constraints?" — Word count, format, platform, deadline

If `$ARGUMENTS` provides a clear topic, use it to skip obvious questions. Ask one at a time.

Fill the writing brief template with answers.

## Phase 2: Outline

With brief in hand:

1. Propose a structure: sections, flow, key points per section
2. Each section should have a clear purpose — if you can't say what a section does for the reader, cut it
3. Present the outline for feedback
4. Iterate until the structure is locked

Don't start drafting until the outline is approved. Rewriting a bad outline is cheap. Rewriting a bad draft is expensive.

## Phase 3: Draft

With outline approved:

1. Dispatch `nyx:writer` sub-agent with the brief + approved outline
2. The sub-agent drafts the full content
3. Review the draft against the brief: Does it hit the targets?
4. If sections need more input, they'll be marked `[NEEDS INPUT: question]` — resolve these with the user

## Phase 4: Refine

With draft complete:

1. Read through for flow — does each section transition naturally to the next?
2. Cut filler — every sentence should earn its place
3. Check tone — does it match the brief?
4. Check purpose — will the reader come away with what we intended?
5. If the `blog-writer` plugin is available and this is a blog post, consider dispatching the `de-ai-writer` agent for a final pass

## Phase 5: Deliver

1. Present the final version
2. Ask: where should this go? (file, clipboard, specific location)
3. Write to the requested location
4. If working in a dimension, update the dimension state file

## When NOT to Use This Playbook
- Quick edits (just edit the file)
- Code documentation (use devloop or inline comments)
- Chat messages or short responses (just write them)
