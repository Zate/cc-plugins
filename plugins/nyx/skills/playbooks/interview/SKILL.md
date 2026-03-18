---
name: interview
description: "Facilitated discovery through structured questions. Use when you need to understand requirements, explore a problem space, or gather context before taking action."
user-invocable: true
argument-hint: "[topic to explore]"
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Interview Playbook

Facilitated discovery. The right questions save more time than fast answers to the wrong ones.

## Phase 1: Framing

Before asking questions:

1. "What are we trying to understand?" — If `$ARGUMENTS` is provided, use it. Otherwise ask.
2. "Who has the answers?" — The user? A codebase? External sources? Some combination?
3. "What should the output look like?" — A brief? A set of requirements? A decision? A summary?

This phase should take 1-3 questions max. Don't over-frame.

## Phase 2: Questions

The core of the interview:

1. **Ask one question at a time.** Never batch questions. Each answer informs the next question.
2. **Prefer multiple choice when possible.** "Which of these matters most: A, B, or C?" is easier to answer than "What matters?"
3. **Track state.** Mentally maintain: what's been learned, what's still unknown, what contradictions exist.
4. **Follow threads.** When an answer reveals something interesting, follow it before moving to the next topic.
5. **Know when to stop.** When you have enough to produce the requested output, stop asking. Don't ask questions for completeness if the answers won't change the output.
6. **Summarize periodically.** Every 4-5 questions, briefly recap: "So far I understand X, Y, Z. Still need to figure out A, B."

Question types to use:
- **Clarifying**: "When you say X, do you mean A or B?"
- **Prioritizing**: "Which of these is most important?"
- **Boundary-setting**: "What's explicitly NOT in scope?"
- **Challenging**: "What if we didn't do X? What breaks?"
- **Concrete**: "Can you give me an example of that?"

## Phase 3: Summary

With sufficient understanding:

1. Synthesize answers into a structured document matching the requested output format
2. Organize by topic, not by question order
3. Highlight:
   - **Decisions made** during the interview
   - **Key requirements** or findings
   - **Open items** — things that weren't resolved
   - **Assumptions** — things assumed but not confirmed
4. Present for review — the user should confirm the summary captures their intent
5. If working in a dimension, persist the summary to the dimension state

## When NOT to Use This Playbook
- You already have enough context (just do the work)
- The question has a factual answer (just look it up)
- The user wants an opinion, not an interview
