# AskUserQuestion Standards

**Purpose**: Establish consistent patterns for asking users questions across all devloop commands, focusing on user experience (UX), token efficiency, and workflow clarity.

**Document Version**: 1.0
**Last Updated**: 2024-12-23

---

## Table of Contents

1. [Overview](#overview)
2. [When to ALWAYS Ask](#when-to-always-ask)
3. [When to NEVER Ask](#when-to-never-ask)
4. [Question Batching Patterns](#question-batching-patterns)
5. [Standard Question Formats](#standard-question-formats)
6. [Token Efficiency Guidelines](#token-efficiency-guidelines)
7. [Decision Trees](#decision-trees)
8. [Common Patterns](#common-patterns)
9. [Anti-Patterns](#anti-patterns)

---

## Overview

### Why This Matters

**AskUserQuestion** serves critical functions in devloop workflows:

1. **Enforces explicit checkpoints** - Ensures users approve significant decisions
2. **Prevents silent failures** - Makes workflow state visible
3. **Enables parallelization** - Background agents need clear exit criteria
4. **Reduces rework** - Catch direction issues early before extensive work
5. **Manages token cost** - Batch questions, avoid redundant questions

### Core Principles

| Principle | Meaning |
|-----------|---------|
| **Ask early, ask once** | Batch related questions, avoid follow-ups in same session |
| **Make it clear** | Options should be self-explanatory; avoid jargon |
| **Minimize load** | Users should rarely see more than 4 options |
| **Default to recommended** | Always highlight the recommended option |
| **Respect context** | Don't ask what's already decided |

---

## When to ALWAYS Ask

### 1. Before Significant Work (>5 minutes expected)

**Pattern**: Architectural / Implementation Decisions

**Example**: Which auth approach?
```yaml
AskUserQuestion:
  question: "Your app needs authentication. Which approach?"
  header: "Auth Approach"
  options:
    - label: "JWT tokens"
      description: "Stateless, good for APIs and SPAs"
    - label: "Session-based"
      description: "Stateful, traditional, good for server-rendered apps"
    - label: "OAuth2"
      description: "Delegate to provider (Google/GitHub), best for user choice"
```

**Why**: Work is substantial enough that wrong direction = major rework

**When NOT to ask**: If user explicitly stated preference earlier ("use JWT"), don't ask again

---

### 2. After Task Completion (Mandatory Checkpoint)

**Critical**: This is the ONLY place AskUserQuestion is MANDATORY in the loop

**Pattern**: Post-Task Checkpoint

```yaml
AskUserQuestion:
  question: "Task 2.1 complete (AuthService implemented). What's next?"
  header: "Checkpoint"
  options:
    - label: "Continue to next task"
      description: "Proceed to Task 2.2 in current context"
    - label: "Commit first"
      description: "Save this work, then continue"
    - label: "Fresh start"
      description: "Clear context, resume in new session"
    - label: "Stop here"
      description: "Generate summary, end session"
```

**Why**: Ensures explicit approval before continuing; allows context refresh decision

**Applies to**: Every agent invocation completion (work, test, review, etc.)

---

### 3. On Error or Ambiguity

**Pattern**: Error Recovery

```yaml
AskUserQuestion:
  question: "Task failed: Database migration syntax error. How should we proceed?"
  header: "Error Recovery"
  options:
    - label: "Retry"
      description: "Fix and try again with adjusted approach"
    - label: "Skip"
      description: "Mark blocked, move to next task"
    - label: "Investigate"
      description: "Show full error output for manual review"
    - label: "Abort"
      description: "Stop workflow, save state"
```

**Why**: Prevents silent failure or incorrect recovery

**Includes**: Clarification requests, missing information, ambiguous requirements

---

### 4. At Workflow Boundaries

**Pattern**: Phase Transitions / Major Mode Changes

**Example**: Spike → Plan transition
```yaml
AskUserQuestion:
  question: "Spike analysis complete. Findings suggest new architecture. Proceed?"
  header: "Proceed"
  options:
    - label: "Apply findings to plan"
      description: "Update plan with recommendations and begin work"
    - label: "Review first"
      description: "Show specific changes before applying"
    - label: "Continue as-is"
      description: "Proceed with original plan"
    - label: "Request more analysis"
      description: "Ask spike to investigate specific area"
```

**Why**: Major transitions benefit from explicit approval

**Applies to**: Spike → Plan, Plan → Work, Work → Review, Review → Ship

---

## When to NEVER Ask

### 1. Trivial Decisions

**Pattern**: Operational Choices with No Real Impact

❌ **DON'T ask:**
```yaml
AskUserQuestion:
  question: "Which file should I read first?"
  options:
    - "models/user.go"
    - "models/product.go"
```

**Why**: No meaningful difference; wastes context on micro-optimization

✅ **DO instead**: Use sensible defaults (alphabetical, dependency order, etc.)

---

### 2. Already Decided Earlier

**Pattern**: Redundant Questions

❌ **DON'T ask (second time):**
```yaml
AskUserQuestion:
  question: "Should we use TypeScript?"
  options:
    - "Yes"
    - "No"
```

If user said "The project is TypeScript" in the initial prompt, don't re-ask

✅ **DO instead**: Reference the earlier decision
```
Based on your requirement to use TypeScript, I'll implement this in TS.
```

---

### 3. During Agent Execution

❌ **DON'T ask mid-task:**
```
Agent starts implementing UserService
[10 minutes later]
AskUserQuestion: "Keep going or stop?"
```

**Why**: Interrupts focused work; agent loses context

✅ **DO instead**: Ask at checkpoint (after agent completes)

**Exception**: If agent explicitly marks itself blocked waiting for input, that's acceptable

---

### 4. Standard Conventions

❌ **DON'T ask:**
```yaml
AskUserQuestion:
  question: "File naming convention?"
  options:
    - "camelCase"
    - "snake_case"
    - "kebab-case"
```

**Why**: Use language/project conventions (Go: snake_case, JS: camelCase, etc.)

✅ **DO instead**: Follow existing codebase pattern

---

### 5. Minor Formatting Choices

❌ **DON'T ask:**
```yaml
AskUserQuestion:
  question: "Comment style?"
  options:
    - "// Single line"
    - "/* Multi-line */"
```

✅ **DO instead**: Match existing code

---

## Question Batching Patterns

### Rule: Batch Related Questions

**DO batch**:
```yaml
AskUserQuestion:
  question: "Two related decisions needed"
  header: "Configuration"
  options:
    - label: "JWT with 24h expiry"
      description: "Short-lived access tokens + refresh"
    - label: "JWT with 90d expiry"
      description: "Long-lived tokens, simpler flow"
    - label: "Session-based with cookies"
      description: "Traditional approach, server state required"
```

**Benefit**: One question instead of three; user sees the trade-offs together

---

### Anti-Pattern: Sequential Questions

❌ **DON'T do this**:
```
AskUserQuestion: "Use JWT?"
[User answers]
AskUserQuestion: "Expiry duration?"
[User answers]
AskUserQuestion: "Include refresh tokens?"
[User answers]
```

**Why**: Multiple round-trips; user interruption; token waste

✅ **DO instead**: Combine into one question with options covering all variants

---

### Batching Decision Tree

```
┌─────────────────────────────┐
│ Related decisions ahead?     │
├─────────────────────────────┤
│ YES: 2-3 related choices    │ → Batch in ONE question
│ YES: 4+ choices             │ → Batch into 2 questions
│ NO: Single decision         │ → Single question
│ NO: Sequence of unrelated   │ → Ask ONE, then when next decision
│      decisions              │    arises, ask that one
└─────────────────────────────┘
```

### Token Cost Considerations

| Pattern | Cost | When to Use |
|---------|------|------------|
| 1 question, 2 options | Low | Default choice |
| 1 question, 4 options | Low | Batch related decisions |
| 1 question, 6+ options | Medium | Only if user expects comprehensive list |
| 2 questions in series | Medium | Necessary when decisions are truly sequential |
| 3+ questions in series | High | Avoid unless absolutely necessary |

---

## Standard Question Formats

### Format 1: Standard Checkpoint (MANDATORY)

**Used after**: Every agent task completion

**Context-Aware Pattern**: Check context usage before presenting checkpoint to provide appropriate recommendation.

**Get context usage**:
```bash
claude --json | scripts/get-context-usage.sh
```
This returns a percentage (0-100). Use it to conditionally recommend options:
- **Context < 50%**: Recommend "Continue to next task"
- **Context >= 50%**: Recommend "Fresh start"

**Template**:
```yaml
AskUserQuestion:
  question: "Task {X.Y} complete. How should we proceed?"
  header: "Checkpoint"
  options:
    # Conditional recommendation based on context usage
    - label: "Continue to next task"
      description: "Move to next pending task {context < 50% ? '(Recommended)' : ''}"
    - label: "Commit now"
      description: "Create atomic commit for this work first"
    - label: "Fresh start"
      description: "Save state, clear context, resume in new session {context >= 50% ? '(Recommended)' : ''}"
    - label: "Stop here"
      description: "Generate summary and end session"
```

**When to Use "(Recommended)" Qualifier**:
| Context Usage | Recommend Option | Rationale |
|---------------|------------------|-----------|
| < 50% | "Continue to next task" | Plenty of context available, keep working |
| >= 50% | "Fresh start" | Context getting heavy, avoid slowdown |

**Good Example (Low Context)**:
```yaml
AskUserQuestion:
  question: "Task 1.1 complete: Created User model with validation. What's next?"
  header: "Checkpoint"
  options:
    - label: "Continue to next task"
      description: "Move to next pending task (Recommended)"  # Context at 35%
    - label: "Commit now"
      description: "Create atomic commit for this work first"
    - label: "Fresh start"
      description: "Save state, clear context, resume in new session"
    - label: "Stop here"
      description: "Generate summary and end session"
```

**Good Example (High Context)**:
```yaml
AskUserQuestion:
  question: "Task 3.4 complete: Added integration tests. What's next?"
  header: "Checkpoint"
  options:
    - label: "Continue to next task"
      description: "Move to next pending task"
    - label: "Commit now"
      description: "Create atomic commit for this work first"
    - label: "Fresh start"
      description: "Save state, clear context, resume in new session (Recommended)"  # Context at 67%
    - label: "Stop here"
      description: "Generate summary and end session"
```

**Bad Example**:
```yaml
AskUserQuestion:
  question: "Done. Continue?"
  header: "Next"
  options:
    - "Yes"
    - "No"
```

---

### Format 2: Decision Question (Before Major Work)

**Used before**: Architectural/implementation choices, significant decisions

**Template**:
```yaml
AskUserQuestion:
  question: "[DECISION NEEDED]. [Trade-offs summary]"
  header: "[Decision Category]"
  options:
    - label: "[Approach 1]"
      description: "[Why it's good], [Drawback]"
    - label: "[Approach 2]"
      description: "[Why it's good], [Drawback]"
```

**Good Example**:
```yaml
AskUserQuestion:
  question: "Need to store user sessions. Session-based or JWT?"
  header: "Session Management"
  options:
    - label: "Session-based (Redis)"
      description: "Stateful, easy to revoke, requires server state"
    - label: "JWT tokens"
      description: "Stateless, scalable, revocation requires token list"
```

**Recommended Answer**:
- Indicate which is recommended: "Recommended: JWT tokens (stateless)"
- Or structure options with recommended first

---

### Format 3: Error Recovery Question

**Used on**: Errors, failures, ambiguity

**Template**:
```yaml
AskUserQuestion:
  question: "[ERROR DESCRIPTION]. How should we proceed?"
  header: "Error Recovery"
  options:
    - label: "Retry"
      description: "Attempt again with [specific adjustment]"
    - label: "Skip"
      description: "Move to next task, mark this as blocked"
    - label: "Investigate"
      description: "Show error details for manual review"
    - label: "Abort"
      description: "Stop workflow, save state"
```

**Good Example**:
```yaml
AskUserQuestion:
  question: "Test suite failing on 3 tests (race conditions in cache layer). How should we proceed?"
  header: "Error Recovery"
  options:
    - label: "Retry with mutex"
      description: "Add synchronization to cache access"
    - label: "Skip cache tests"
      description: "Mark cache layer as incomplete, move to integration tests"
    - label: "Review race conditions"
      description: "Show failing tests in detail"
    - label: "Abort"
      description: "Stop and save state"
```

---

### Format 4: Plan Application Question

**Used for**: Spike findings, plan updates, significant changes

**Template**:
```yaml
AskUserQuestion:
  question: "[RECOMMENDATION]. [Summary of changes]"
  header: "[Action]"
  options:
    - label: "Apply and start"
      description: "Make changes and begin work"
    - label: "Apply only"
      description: "Make changes, review before starting"
    - label: "Review first"
      description: "Show specific changes before committing"
    - label: "Continue without"
      description: "Keep current plan, proceed as-is"
```

**Good Example**:
```yaml
AskUserQuestion:
  question: "Spike identified 3 additional tests needed. Apply recommendations and begin work?"
  header: "Apply"
  options:
    - label: "Apply and start"
      description: "Add tests to plan (Tasks 3.4, 3.5, 3.6) and begin implementing"
    - label: "Review first"
      description: "Show me the test recommendations before applying"
    - label: "Continue without"
      description: "Skip these tests, proceed with current plan"
```

---

## Token Efficiency Guidelines

### Rule 1: Minimize Options

| Options | Tokens | Use When |
|---------|--------|----------|
| 2 | Minimal | Binary decisions (yes/no, proceed/stop) |
| 3 | Low | Decision with one clear primary + alternatives |
| 4 | Low | Standard checkpoint (continue/commit/fresh/stop) |
| 5-6 | Medium | Comprehensive choice (architectures, approaches) |
| 7+ | High | Avoid unless unavoidable (e.g., language selection) |

**Rule**: Keep to 2-4 options. If you need more, reconsider whether to batch or ask sequentially.

---

### Rule 2: Description Brevity

**Keep descriptions short** (1 short sentence + optional detail):

❌ **Too long**:
```yaml
- label: "JWT"
  description: "JSON Web Tokens are a method for representing claims
               to be transferred between two parties. The claims
               in a JWT are encoded as a JSON object that is used as
               the payload of a JSON Web Signature (JWS) structure..."
```

✅ **Good**:
```yaml
- label: "JWT"
  description: "Stateless tokens, good for APIs and distributed systems"
```

---

### Rule 3: Avoid Redundant Context

If you just explained the decision above the question, don't repeat in descriptions:

❌ **Redundant**:
```yaml
question: "Authentication approach (session-based stores user
          on server, JWT is stateless)?"
options:
  - label: "Session"
    description: "Stores user on server" # Repeated!
  - label: "JWT"
    description: "Stateless approach" # Repeated!
```

✅ **Good**:
```yaml
question: "Authentication approach?"
header: "Auth"
options:
  - label: "Session"
    description: "Server-managed, easier revocation"
  - label: "JWT"
    description: "Scalable, stateless, revocation complex"
```

---

### Rule 4: Don't Ask What's Free

Some questions cost more tokens for less value:

❌ **Don't ask**:
```
"Should we add comments?" (almost always yes)
"Should we handle errors?" (always yes)
"Should we write tests?" (depends on context, but devloop always does)
```

✅ **Instead**: State it as a given
```
"I'll implement UserService with comprehensive error handling and tests."
```

---

## Decision Trees

### When Should I Ask a Question?

```
START: Considering asking a question
  │
  ├─→ Is this already decided in this session?
  │    YES → DON'T ASK (reference earlier decision)
  │    NO  → Continue
  │
  ├─→ Is this work trivial (<5 minutes)?
  │    YES → DON'T ASK (just do it, use sensible default)
  │    NO  → Continue
  │
  ├─→ Does wrong direction cause significant rework?
  │    YES → ASK (get direction right early)
  │    NO  → Continue
  │
  ├─→ Is the user waiting for me?
  │    YES → ASK (user is blocked waiting for decision)
  │    NO  → Can continue, but checkpoint is better
  │
  ├─→ Is this a standard convention?
  │    YES → DON'T ASK (follow convention)
  │    NO  → ASK
  │
  └─→ RESULT: ASK THIS QUESTION
```

---

### How Should I Structure This Question?

```
START: Planning the question structure
  │
  ├─→ How many independent decisions needed?
  │    1  → Single question
  │    2-3 (related) → Batch in one question with options covering variants
  │    3+ (related) → Consider two focused questions
  │    3+ (unrelated) → Ask first decision now, others when they arise
  │
  ├─→ Is this a checkpoint (after task completion)?
  │    YES → Use Format 1 (Standard Checkpoint)
  │    NO  → Continue
  │
  ├─→ Is this about recovery from error?
  │    YES → Use Format 3 (Error Recovery)
  │    NO  → Continue
  │
  ├─→ Is this about applying recommendations?
  │    YES → Use Format 4 (Plan Application)
  │    NO  → Continue
  │
  ├─→ Is this a major decision before work?
  │    YES → Use Format 2 (Decision)
  │    NO  → Continue
  │
  └─→ How many options are necessary?
       2-4 → Good, proceed
       5-6 → Acceptable if comprehensive
       7+  → Consider two questions instead
```

---

## Common Patterns

### Pattern 1: Checkpoint Loop (MANDATORY)

**Every agent task completion requires this**:

```yaml
# Step 1: Agent executes task (autonomous)

# Step 2: MANDATORY checkpoint
AskUserQuestion:
  question: "Task 2.1 complete: [Summary of work]. What's next?"
  header: "Checkpoint"
  options:
    - label: "Continue"
      description: "Proceed to next task in current context"
    - label: "Commit first"
      description: "Create atomic commit, then continue"
    - label: "Fresh start"
      description: "Clear context, save state, resume in new session"
    - label: "Stop here"
      description: "Generate summary and end session"

# Step 3: Handle response
# - Continue → Loop back to Step 1 with next task
# - Commit → Launch git mode, update plan, then continue
# - Fresh start → Save state to .devloop/next-action.json, suggest /clear
# - Stop → Generate summary, end workflow
```

### Pattern 2: Pre-Work Decision

**Before starting substantial work** (>30 minutes expected):

```yaml
# Phase N: Architecture Decision

AskUserQuestion:
  question: "We need to implement user authentication. Which approach?"
  header: "Auth Architecture"
  options:
    - label: "JWT with refresh tokens"
      description: "Stateless, good for distributed systems"
    - label: "Session-based (Redis)"
      description: "Stateful, simpler revocation"
    - label: "OAuth2"
      description: "Delegate to Google/GitHub"

# Once decided, update plan with specific tasks for that approach
# Don't ask again in this session
```

### Pattern 3: Conditional Batching

**When user chooses a direction, batch follow-up decisions:**

```yaml
# User chose "JWT with refresh tokens"

AskUserQuestion:
  question: "JWT approach selected. Two implementation details:"
  header: "JWT Details"
  options:
    - label: "24-hour access tokens"
      description: "Short-lived, 7-day refresh tokens"
    - label: "7-day access tokens"
      description: "Longer-lived, 30-day refresh tokens"
    - label: "Hybrid: 1-day access, rolling refresh"
      description: "Frequent refresh, good for security"
```

These options batch two decisions:
1. Access token lifetime
2. Refresh token approach

---

### Pattern 4: Error with Retry Options

**When work fails or errors occur**:

```yaml
# Implementation task failed with specific error

AskUserQuestion:
  question: "Database migration syntax error (PostgreSQL 11 doesn't support GENERATED ALWAYS). How to proceed?"
  header: "Error Recovery"
  options:
    - label: "Retry with computed column"
      description: "Use GENERATED AS instead of GENERATED ALWAYS"
    - label: "Skip migration"
      description: "Mark feature as requiring manual migration script"
    - label: "Show error details"
      description: "Display full error output for investigation"
    - label: "Stop workflow"
      description: "Save state and end session"
```

---

### Pattern 5: Fresh Start Detection

**When context has become heavy** (5+ tasks, 10+ agent calls):

```yaml
# After Task 5 completion

AskUserQuestion:
  question: "We've completed 5 tasks and this context is getting heavy. Would a fresh start help?"
  header: "Context"
  options:
    - label: "Yes, fresh start"
      description: "Save state and clear context for next session"
    - label: "No, continue"
      description: "Keep working in current context"
    - label: "Compact only"
      description: "Summarize context without full clear (if available)"
```

---

## Anti-Patterns

### Anti-Pattern 1: Analysis Paralysis

❌ **DON'T ask when you can decide**:

```yaml
# If we're 80% confident on the right answer, don't ask
AskUserQuestion:
  question: "Should we add error handling?"
  options:
    - "Yes"
    - "No"
```

✅ **Instead**: Just do it
```
I'll implement comprehensive error handling with logging.
```

---

### Anti-Pattern 2: Too Many Options

❌ **DON'T overwhelm**:

```yaml
AskUserQuestion:
  question: "Which language?"
  options:
    - "Go"
    - "Python"
    - "Rust"
    - "C++"
    - "Java"
    - "C#"
    - "TypeScript"
    - "PHP"
```

✅ **Instead**: If there's genuine ambiguity, narrow context
```
Your codebase is TypeScript/Node. Continue in TypeScript?
options: [Yes, Go to Go, Python needed]
```

---

### Anti-Pattern 3: Asking Twice for Same Decision

❌ **DON'T repeat questions**:

Session start:
```
User: I want to build this in TypeScript with React
```

5 tasks later:
```
AskUserQuestion: "Use TypeScript?"
```

✅ **Instead**: Reference the earlier decision
```
We're continuing the TypeScript/React implementation...
```

---

### Anti-Pattern 4: Questions During Execution

❌ **DON'T interrupt agent work**:

```
// Agent is implementing UserService
// 10 minutes into implementation
AskUserQuestion: "Keep going or stop?"
```

✅ **Instead**: Ask at checkpoint (after completion)
```
// Agent completes UserService
AskUserQuestion: "Task complete. Checkpoint: commit/continue/fresh/stop?"
```

**Exception**: If agent is explicitly blocked and marking itself waiting for input

---

### Anti-Pattern 5: Hiding Recommendations

❌ **DON'T bury the recommendation**:

```yaml
options:
  - label: "Approach A"
    description: "Some description"
  - label: "Approach B (RECOMMENDED)"  # Weak recommendation
    description: "Some description"
```

✅ **DO make it clear**:
```yaml
question: "Cache strategy? (Recommended: Redis for simplicity)"
options:
  - label: "Redis (Recommended)"
    description: "Simple, fast, good for most cases"
  - label: "In-memory"
    description: "Faster but limited to single server"
  - label: "Database caching"
    description: "Persistent, complex"
```

Or structure options by strength:
```yaml
options:
  - label: "JWT tokens"
    description: "[Best for your use case] Stateless, scalable"
  - label: "Session-based"
    description: "[Also viable] Simpler revocation"
```

---

## Integration with Commands

### Commands That Use Checkpoints

```
✓ /devloop (after each phase)
✓ /devloop:continue (after each agent execution)
✓ /devloop:spike (before and after major phases)
✓ /devloop:quick (after task completion)
✓ /devloop:review (offer to commit or continue)
✓ /devloop:ship (final validation checkpoint)
```

### Commands That Ask for Decisions

```
✓ /devloop (Phase 1: Discovery decisions)
✓ /devloop:spike (Phase 2: Investigation directions)
✓ /devloop:architect (Architecture decisions)
✓ Commands launching agents in parallel (which agents to spawn)
```

### Commands That Rarely Ask

```
✓ /devloop:quick (one focused task, minimal decisions)
✓ /devloop:summarize (reviewing output, no critical decisions)
```

---

## Enforcement

### Recommended Pattern: Mandatory Checkpoints

All task completion paths SHOULD use the checkpoint pattern:

```
Task execution
  ↓
[MANDATORY: Checkpoint question]
  ↓
User decision (continue/commit/fresh/stop)
  ↓
Resume or end workflow
```

**Checkpoints should:**
- Always include 4 options: continue/commit/fresh/stop
- Include brief summary of completed work
- Respect earlier decisions in session

**Checkpoints should NOT:**
- Ask about already-decided architecture
- Ask about trivial formatting
- Ask more than 4 questions at once
- Ask about work that hasn't started

---

## Examples by Workflow

### Full /devloop Feature Workflow

```
Phase 1: Discovery
  → Ask: Confirm requirements / ask clarification questions

Phase 5: Architecture
  → Ask: Confirm architectural approach before implementation

Phase 6: Plan
  → Plan generated, user reviews
  → Ask: Approve plan or request modifications

Phase 7: Implement (calls /devloop:continue)
  → Task 1 complete → [CHECKPOINT]
  → Task 2 complete → [CHECKPOINT]
  → Task 3 complete → [CHECKPOINT]
  → [Loop completion detected]
  → Ask: All tasks complete - commit/review/stop?

Phase 10: Validation
  → Validation complete
  → Ask: Any issues? Ready to ship?

Phase 12: Summary
  → Generated summary, no question needed
```

### /devloop:continue Workflow

```
Step 1: Read plan
Step 2: Find next pending task
Step 3: Launch agent for task
Step 4: Agent completes
Step 5: [MANDATORY CHECKPOINT]
  AskUserQuestion: "Task X.Y complete. What's next?"
  Options: continue/commit/fresh/stop
Step 6: Handle response
  - Continue → Loop to Step 3 with next task
  - Commit → Save work, then loop
  - Fresh → Save state, suggest /clear
  - Stop → End workflow
```

---

## Summary

### Quick Reference: Decision Flowchart

**Should I ask?**
```
significant work?      → YES → Ask for direction
already decided?       → YES → Don't ask
error/ambiguity?       → YES → Ask recovery options
checkpoint (after task)? → YES → Ask (always)
trivial choice?        → NO  → Don't ask (use default)
convention-based?      → NO  → Don't ask (follow convention)
```

**How should I ask?**
```
related decisions?     → YES → Batch into one question
4+ independent choices? → YES → Ask sequentially
checkpoint?            → YES → Use Format 1 (continue/commit/fresh/stop)
error?                 → YES → Use Format 3 (retry/skip/investigate/abort)
recommendation?        → YES → Use Format 4 (apply/review/continue-without)
decision before work?  → YES → Use Format 2 (options with trade-offs)
```

### Key Takeaways

1. **Mandatory**: Always ask checkpoints after task completion
2. **Batch**: Combine related decisions to minimize questions
3. **Clarity**: Keep descriptions short and options clear
4. **Respect**: Don't re-ask what's already decided
5. **Token-conscious**: Minimize options, avoid redundancy
6. **Timely**: Ask before work starts (not during, not after)

---

## References

**Related Documentation**:
- [Workflow Reference](workflow.md) - 12-phase feature workflow
- [Commands Reference](commands.md) - Individual command patterns
- [Skill: workflow-loop](../skills/workflow-loop/SKILL.md) - Loop patterns and state transitions

**Spike Report**:
- [Continue Command Improvements](../.devloop/spikes/continue-improvements.md) - Source analysis for these standards
