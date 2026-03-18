---
name: decide
description: "DACI-inspired decision framework. Structure a decision with factors, options, comparison, and recommendation. Use when facing a choice with trade-offs."
user-invocable: true
argument-hint: "[decision to make]"
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Decide Playbook

Structured decision-making. Define how you'll evaluate before you evaluate. This prevents the most common decision-making failure: picking the option that sounds best instead of the option that IS best.

## Phase 1: Framing

1. "What decision needs to be made?" — If `$ARGUMENTS` is provided, use it.
2. "Why now? What's the forcing function?" — Urgency shapes which trade-offs matter.
3. "Who's affected?" — Stakeholders, systems, users, teams.

Keep this phase short. 2-3 questions max.

## Phase 2: Decision Factors

**Define evaluation criteria BEFORE presenting options.** This prevents anchoring bias.

1. Propose criteria based on the decision context (cost, speed, quality, risk, maintainability, user impact, etc.)
2. Weight each factor: High / Medium / Low
3. Get explicit agreement on factors before proceeding

Example:
| Factor | Weight | Rationale |
|--------|--------|-----------|
| Implementation speed | High | Deadline in 2 weeks |
| Maintenance burden | Medium | Small team |
| User impact | High | Customer-facing |

## Phase 3: Options

Present 2-3 options:

1. **Prose first, then bullets.** Lead with 1-2 paragraphs explaining each option's mechanism and context. Follow with bullet-point trade-offs.
2. **Include an anchor.** At least one option the reader will likely reject — this provides contrast and shows you've considered alternatives.
3. **Composed options are valid.** If Option C = Option A + B, present the components first, then the composition.
4. **Don't hide the bad parts.** Every option has trade-offs. State them plainly.

## Phase 4: Comparison

1. Build a side-by-side comparison table using the Decision Factors as columns
2. Rate each option against each factor
3. State your recommendation with rationale
4. Acknowledge what you're saying no to — and why that's acceptable
5. Fill the TL;DR: recommendation, key trade-off, timeline

## Phase 5: Decision

1. Present the comparison and recommendation
2. Facilitate discussion — the user decides, not you
3. When a decision is made, fill in the Decision and Rationale sections of the template
4. If working in a dimension, log to the dimension's decision log
5. Persist via ctx: `<ctx:remember type="decision" tags="dim:<name>,tier:working">Decision: [what]. Rationale: [why]</ctx:remember>`

## Principles (from DACI patterns)
- Front-load for busy readers: TL;DR first
- Decision factors before options (prevents bias)
- Prose-first options, then summary bullets
- Comparison table after all options are presented
- Anchor options for contrast
- FAQs pre-empt predictable objections
- Tone: constructive but honest — the reader must understand what they're saying no to

## When NOT to Use This Playbook
- The decision is obvious (just decide)
- There's only one viable option (it's not a decision, it's a plan)
- The decision is purely emotional/preference-based (no framework will help)
