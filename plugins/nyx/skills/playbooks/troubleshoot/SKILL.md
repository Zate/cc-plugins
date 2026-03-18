---
name: troubleshoot
description: "Systematic debugging and problem diagnosis. Reproduce, isolate, identify root cause, fix, and verify. Use when something is broken and you need to unfuck it methodically."
user-invocable: true
argument-hint: "[what's broken — error, symptom, or system]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent, WebSearch, WebFetch
---

# Troubleshoot Playbook

Systematic problem diagnosis. You don't guess — you observe, hypothesize, test, and confirm. The fastest path to a fix is understanding the problem, not throwing solutions at symptoms.

## Phase 1: Triage

Get oriented fast. Understand what's broken before touching anything.

1. **Symptom capture**: What's happening? If `$ARGUMENTS` is provided, use it as starting point.
   - Exact error messages, stack traces, unexpected behavior
   - When did it start? What changed? (Check git log, recent deploys, config changes)
   - How reproducible? Always, sometimes, once?
2. **Blast radius**: What's affected?
   - Single component or cascading failure?
   - Is anything still working that shouldn't be? (Sometimes what ISN'T broken is the best clue.)
   - Users/systems impacted?
3. **Severity check**: Does this need a hotfix-now approach or a methodical investigation?
   - **Critical**: System down, data at risk → Skip to emergency stabilization (Phase 2a)
   - **Standard**: Something's wrong, let's figure it out → Phase 2

If the user already has a clear picture of the symptom, don't slow them down with questions they've already answered. Read the room.

## Phase 2: Investigation

### Phase 2a: Emergency Stabilization (Critical only)

If severity is critical:
1. Can we revert? Check `git log` for recent changes. A revert is not a fix — it's buying time.
2. Can we isolate? Disable the broken component without taking down the rest.
3. Can we mitigate? Temporary workaround to stop the bleeding.
4. Document what you did and why — you'll need this later.
5. Then proceed to Phase 2b with the pressure off.

### Phase 2b: Systematic Diagnosis

Observe, don't assume:

1. **Reproduce**: Can you make it happen on demand?
   - Build a minimal reproduction case
   - If you can't reproduce, that's data — document the conditions where it was observed
2. **Isolate**: Narrow the search space
   - Binary search: which half of the system is the problem in?
   - Check boundaries: inputs, outputs, interfaces between components
   - Read the actual code in the suspected area — don't rely on assumptions about what it does
3. **Trace**: Follow the execution path
   - Logs: what happened right before the failure?
   - State: what does the data look like at each stage?
   - Dependencies: external services, config, environment
   - Use `Bash` to run diagnostic commands, check logs, test endpoints
4. **Hypothesize**: Based on evidence (not hunches), form 2-3 candidate explanations
   - For each: what would you expect to see if this hypothesis is correct?
   - What would you expect NOT to see?
   - Rank by likelihood

Present findings so far:
- **What we know**: Confirmed facts with evidence
- **What we suspect**: Ranked hypotheses with supporting/contradicting evidence
- **What we've ruled out**: Dead ends and why

## Phase 3: Root Cause

Test hypotheses systematically:

1. **Design a test** for the most likely hypothesis
   - What specific observation would confirm it?
   - What specific observation would disprove it?
2. **Run the test**: Execute, observe, record
3. **Iterate**: If confirmed → root cause identified. If disproved → next hypothesis. If inconclusive → refine the test.

When root cause is identified:
- State it clearly: "The problem is X because Y, which causes Z"
- Explain the causal chain — how does the root cause produce the symptoms?
- Identify contributing factors — was there a second thing that had to be true for this to fail?

**Do not skip this phase.** Fixing a symptom without understanding the cause creates the next bug.

## Phase 4: Fix and Verify

1. **Design the fix**: Address root cause, not symptoms
   - What's the minimal change that fixes this?
   - What could this fix break? (New blast radius assessment)
   - Is there a test that should exist to prevent regression?
2. **Implement**: Make the change
   - If code: make the edit, run tests, check for side effects
   - If config: change it, verify it took effect
   - If process: document the change and why
3. **Verify**: Prove it's fixed
   - Reproduce the original symptom — does it still occur? (It shouldn't.)
   - Run the broader test suite — did the fix break anything else?
   - Check the original blast radius — is everything healthy?
4. **Regression protection**: If applicable, add a test that catches this specific failure mode

## Phase 5: Knowledge Capture

Don't waste the pain:

1. **What caused this?** One-line root cause for memory
2. **How was it found?** The diagnostic path — especially any non-obvious steps
3. **How was it fixed?** The change and its rationale
4. **How do we prevent it?** Systematic prevention — test, lint rule, process change, monitoring
5. **Persist if durable**: If this is a pattern that could recur:
   - `ctx:remember type="observation"` for the root cause
   - `ctx:remember type="pattern"` if it reveals a broader pattern
   - Update relevant playbooks if the diagnostic process revealed a gap

## Output

A complete troubleshoot produces:
- Root cause statement with causal chain
- Fix implemented and verified
- Regression protection (test or documented prevention)
- Knowledge captured in ctx if the issue reveals a durable pattern

## When NOT to Use This Playbook
- Known issues with known fixes (just fix it)
- Configuration questions ("how do I set up X" is not troubleshooting)
- Feature requests disguised as bugs ("it doesn't do X" when X was never built)
- Problems you can solve by reading the error message (read it first, then decide if you need a process)
