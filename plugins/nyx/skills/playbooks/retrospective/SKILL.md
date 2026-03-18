---
name: retrospective
description: "Structured post-mortem and learning extraction. Review completed work, identify what worked, what didn't, and what to carry forward. The feedback loop that sharpens everything else."
user-invocable: true
argument-hint: "[what to reflect on — project, dimension, incident, or timeframe]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
---

# Retrospective Playbook

Structured learning from experience. You don't get better by doing more — you get better by understanding what you did. This is the feedback loop that sharpens every other process.

## Phase 1: Scoping

Establish what we're looking back at:

1. **Subject**: What are we retro-ing? If `$ARGUMENTS` is provided, use it. Could be:
   - A completed dimension (read its state file and decision log)
   - A specific project or feature
   - An incident or failure
   - A timeframe ("the last week of work")
2. **Gather context**: Pull in everything relevant:
   - Dimension state files and decision logs (`dimensions/<name>.md`)
   - ctx entries: `<ctx:recall query="tag:dim:<name>"/>` or `<ctx:recall query="type:decision"/>`
   - Git history: commits, PRs, branch history
   - Any notes in `notes/`
3. **Timeframe**: When did this start and end? Bound it.

If the scope is clear from arguments, move fast. Don't over-facilitate obvious setups.

## Phase 2: Evidence Gathering

Systematic review — facts before feelings:

1. **Timeline reconstruction**: Build a sequence of what happened. Key decisions, pivots, blockers, breakthroughs. Use git log, dimension decision logs, and ctx entries.
2. **Outcomes**: What was the goal? What actually happened? Be specific — "we shipped it" is not an outcome. "Shipped auth middleware rewrite, passed compliance review, took 3 days longer than expected" is.
3. **Artifacts**: What was produced? Code, docs, decisions, knowledge, playbooks, skills.
4. **Surprises**: What was unexpected — positive or negative? These are the highest-signal learning moments.

Present the timeline as a concise chronological summary. Don't editorialize yet.

## Phase 3: Analysis

Three lenses, applied honestly:

### What Worked
- What went well? Be specific about *why* it worked, not just that it did.
- What should we repeat? What process, tool, or approach produced outsized value?
- What assumptions proved correct?

### What Didn't Work
- What went wrong? Root causes, not symptoms.
- What took longer than it should have? Why?
- What assumptions were wrong?
- What would we do differently with hindsight?

### What We Learned
- New knowledge — technical, process, or domain
- Pattern recognition — "this is the third time X happened, which means..."
- Feedback on existing playbooks/processes — did they help? Where did they break down?

Present using two-lane delivery:
- **Executive summary**: 3-5 key takeaways, most important first
- **Full details**: Evidence-backed analysis for each finding

## Phase 4: Extraction

This is where the retro produces durable value. For each finding:

1. **Memory promotion**: Identify knowledge worth persisting:
   - Decisions that should inform future work → `ctx:remember type="decision" tier:reference`
   - Patterns worth recognizing next time → `ctx:remember type="pattern" tier:pinned`
   - Feedback on processes → `ctx:remember type="fact" tier:pinned`
2. **Process improvements**: If a playbook or skill should be updated based on what we learned, note the specific change and where it applies.
3. **Action items**: Concrete next steps, if any. Not "we should do better" — specific, actionable, assigned.
4. **Archive recommendation**: If the retro covers a dimension, recommend whether to archive it (and draft the archive summary).

Present extractions as a checklist. Execute memory writes and process updates with user confirmation.

## Output

A complete retrospective produces:
- Timeline summary of what happened
- Executive summary of key takeaways
- Detailed analysis (worked / didn't / learned)
- Concrete extractions: ctx entries to persist, process changes to make, actions to take
- If dimension-scoped: archive recommendation with summary

## When NOT to Use This Playbook
- Work that just started (nothing to reflect on yet)
- Quick tasks that don't warrant structured reflection (just note any learnings in ctx directly)
- When you need to make a decision about the future (use the decide playbook instead — retro looks backward)
