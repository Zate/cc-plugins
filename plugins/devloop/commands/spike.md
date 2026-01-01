---
description: Technical spike/POC to explore feasibility before committing to implementation
argument-hint: What to explore
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "AskUserQuestion", "TodoWrite", "WebSearch", "WebFetch"]
---

# Spike - Technical Exploration

Time-boxed investigation to explore feasibility before committing to implementation. **You do the work directly.**

## Step 1: Define Scope

Initial request: $ARGUMENTS

Ask user what we're trying to learn:

```yaml
AskUserQuestion:
  question: "What's the primary question this spike should answer?"
  header: "Goal"
  options:
    - label: "Feasibility"
      description: "Can we do this at all?"
    - label: "Approach"
      description: "Which way is best?"
    - label: "Performance"
      description: "Is it fast enough?"
    - label: "Integration"
      description: "Does it work with X?"
```

Create a brief todo list for the investigation.

## Step 2: Research

**Do this directly. No agents needed.**

1. **Search codebase**: Use Grep/Glob to find similar patterns
2. **Read relevant files**: Understand existing implementation
3. **External research**: Use WebSearch/WebFetch for docs if needed

Document key findings as you go.

## Step 3: Prototype (Optional)

If needed, create throwaway POC code:

1. Use `spike/` or `experiments/` directory
2. Don't worry about production quality
3. Focus on answering the spike question

## Step 4: Evaluate

After investigation, assess:

- **Feasibility**: Can we do this? Yes/No/Partial
- **Complexity**: XS / S / M / L / XL
- **Risk**: Low / Medium / High
- **Recommended approach**: What's the best path forward?

## Step 5: Report

Write spike report to `.devloop/spikes/{topic}.md`:

```markdown
## Spike: [Topic]

**Question**: [What we investigated]
**Answer**: [What we learned]

### Findings
- [Key finding 1]
- [Key finding 2]

### Recommendation
[Proceed/Don't proceed] with [approach]

### Complexity: [Size] | Risk: [Level]
```

## Step 6: Next Steps

```yaml
AskUserQuestion:
  question: "Spike complete. How would you like to proceed?"
  header: "Next"
  options:
    - label: "Start work"
      description: "Begin implementation with /devloop:continue"
    - label: "Create plan"
      description: "Design full implementation plan"
    - label: "Defer"
      description: "Save findings for later"
```

---

## Best Practices

- Time-box: Don't exceed planned investigation time
- Document as you go
- Fail fast if not feasible
- Keep prototype code throwaway (don't commit to main)
