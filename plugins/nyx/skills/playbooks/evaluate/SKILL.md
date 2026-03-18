---
name: evaluate
description: "Structured evaluation workflow. Define criteria, assess systematically, produce scored findings. Use for comparing options, reviewing quality, or assessing anything against standards."
user-invocable: true
argument-hint: "[subject to evaluate]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
---

# Evaluate Playbook

Structured evaluation. You don't start with opinions — you start with criteria.

## Phase 1: Framework (Facilitated Q&A)

Before any assessment:

1. "What are we evaluating?" — The subject, scope, and context
2. "Against what criteria?" — Define evaluation dimensions. If the domain is known (code quality, writing quality, product design, etc.), propose default criteria and let the user adjust.
3. "How are we scoring?" — Qualitative (strong/adequate/weak), quantitative (1-10), pass/fail, or custom
4. "What does 'good' look like?" — Establish the bar. Without this, ratings are meaningless.

Ask one at a time. If `$ARGUMENTS` provides the subject, start with criteria.

## Phase 2: Assessment

With framework defined:

1. If the evaluation is substantial, dispatch `nyx:evaluator` sub-agent with the subject and framework
2. For simpler evaluations, assess directly
3. For each criterion:
   - Examine the subject against the criterion
   - Gather specific evidence (quotes, measurements, observations)
   - Rate per the scoring model
   - Note anything surprising

Never rate without evidence. "Good" is not a rating — "Strong because [specific observation]" is.

## Phase 3: Synthesis

With per-criterion assessment complete:

1. Two-lane delivery:
   - **Executive summary**: 2-4 lines — overall assessment, top strength, top weakness, recommendation
   - **Full details**: Per-criterion breakdown with evidence
2. Highlight:
   - **Strengths**: Top 3 with evidence
   - **Weaknesses**: Top 3 with evidence
   - **Surprises**: Anything unexpected
   - **Gaps**: Criteria that couldn't be fully evaluated
3. Be honest. If something is poor, say it's poor. The purpose of evaluation is clarity, not comfort.

## Phase 4: Recommendations

Based on findings:

1. What actions should be taken? Prioritize by impact.
2. What's the most important thing to fix/improve/maintain?
3. If this is a comparison (multiple options), state the recommendation clearly with rationale.
4. If working in a dimension, log the evaluation decision to the decision log.
5. Suggest persisting key findings via ctx if they're reusable.

## When NOT to Use This Playbook
- Quick opinions ("what do you think of X?" — just answer)
- Binary decisions with obvious answers
- Evaluations with a single criterion (just assess it directly)
