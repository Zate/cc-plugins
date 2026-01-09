# Spike - Time-boxed Investigation

Run a focused exploration with clear output. Time-boxed to 15-20 minutes of work.

## When to Use

- **Unknown territory**: "How does X work?", "Is Y feasible?"
- **Before big decisions**: Architecture choices, library selection
- **Risk reduction**: Validate assumptions before implementing

## Process

### Step 1: Define Scope (2 min)

Write spike goal to `.devloop/spikes/YYYY-MM-DD-[topic].md`:

```markdown
# Spike: [Topic]

**Date**: YYYY-MM-DD
**Time Budget**: 15-20 minutes
**Status**: In Progress

## Question

[What we're investigating]

## Success Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Findings

[Start investigation below]
```

### Step 2: Investigate (12-15 min)

Document as you go in the spike file:

```markdown
## Findings

### Discovery 1
- Location: `file.py:123`
- Details: ...

### Discovery 2
- Tried: ...
- Result: ...
```

**Focus on**:
- Entry points and key files
- Patterns and conventions
- Gotchas and edge cases
- Quick proof-of-concept if needed

**Avoid**:
- Perfect understanding of every detail
- Refactoring during exploration
- Going down every rabbit hole

### Step 3: Summarize (3-5 min)

Complete the spike report:

```markdown
## Recommendation

**Verdict**: Feasible / Not Feasible / Needs More Investigation

**Approach**: [Recommended implementation approach]

**Risks**: 
- Risk 1
- Risk 2

**Estimated Effort**: [S/M/L or time estimate]

## Next Steps

1. Action 1
2. Action 2
```

### Step 4: Decide

Ask user:
```
Spike complete. See .devloop/spikes/YYYY-MM-DD-[topic].md

Next actions:
1. Proceed with implementation → Run @rovodev
2. More investigation needed → Run another @spike
3. Blocked by [X] → Log issue
```

## Output Format

Save to `.devloop/spikes/YYYY-MM-DD-[topic-slug].md`

Keep it **scannable**:
- Use headers for structure
- Bullet points over paragraphs
- Code references with `file:line`
- Link to relevant docs/issues

## Example Spike Topics

- "Can we use library X for feature Y?"
- "How does authentication flow work?"
- "What's the best way to refactor module Z?"
- "Is it safe to upgrade dependency X?"

## Time Management

| Phase | Time | Focus |
|-------|------|-------|
| Scope | 2 min | Clear question & success criteria |
| Investigate | 12-15 min | Document discoveries |
| Summarize | 3-5 min | Recommendation & next steps |

**Hard stop at 20 minutes** - If incomplete, recommend:
1. Another spike with narrower scope
2. Break into multiple spikes
3. Escalate for pairing/expertise

## Integration with Plan

If spike leads to implementation:
1. Save spike to `.devloop/spikes/`
2. Run `@rovodev [feature]` to create plan
3. Reference spike in plan: "See spike: YYYY-MM-DD-[topic].md"

---

**What would you like to investigate?**
