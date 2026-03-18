---
name: research
description: "Phased research workflow. Leads with questions, explores systematically, synthesizes findings. Use for any non-trivial research task."
user-invocable: true
argument-hint: "[topic or research question]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebSearch, WebFetch, Agent
---

# Research Playbook

Structured research workflow. You don't start by searching — you start by understanding what you're looking for.

## Phase 1: Scoping (Facilitated Q&A)

Before any research begins, establish:

1. **Research question**: What are we trying to learn? If `$ARGUMENTS` is provided, use it as the starting point but refine.
2. **Scope**: What's in? What's out? Where are the boundaries?
3. **Prior knowledge**: What do we already know? What assumptions are we making?
4. **Success criteria**: What would a good answer look like? What format is most useful?

Ask these one at a time. Don't batch questions.

If the user has a clear question and scope, move through this phase quickly. Don't slow people down with unnecessary ceremony.

## Phase 2: Exploration

With scope defined:

1. Identify sources: codebase (Grep/Glob), web (WebSearch/WebFetch), documentation (Read), existing knowledge (ctx recall)
2. Dispatch `nyx:researcher` sub-agent for deep exploration if the topic warrants it. For simpler research, explore directly.
3. If the topic has independent facets, explore them in parallel (multiple sub-agent dispatches).
4. For each source, capture: what was found, where, confidence level.

Don't go down rabbit holes. If a line of investigation isn't producing results after reasonable effort, note it as an open question and move on.

## Phase 3: Synthesis

With findings gathered:

1. Organize by theme, not by source
2. Identify patterns — what do multiple sources agree on?
3. Identify contradictions — where do sources disagree?
4. Identify gaps — what couldn't be answered?
5. Distill into key findings (most important first)

Present using two-lane delivery:
- **Executive summary**: 2-4 lines, what matters, what to decide
- **Full details**: evidence, reasoning, sources for each finding

## Phase 4: Output

1. Fill the research plan template with findings
2. Present to the user
3. Note open questions and recommended next steps
4. If working in a dimension, update the dimension state file with a research summary
5. If findings include durable knowledge, suggest persisting via ctx

## When NOT to Use This Playbook
- Quick factual lookups (just answer the question)
- Questions that can be answered by reading one file
- Opinions or discussions (just talk)
