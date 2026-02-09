---
description: Fetch and integrate PR review feedback into devloop plan
argument-hint: Optional PR number
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - TaskList
---

# PR Feedback - Integrate Review Comments

Fetch PR review feedback and add actionable items to the plan. **You do the work directly.**

## Step 1: Identify PR

**If PR number provided:** Use `$ARGUMENTS`

**Otherwise, detect from current branch:**

```bash
gh pr view --json number,title,state,reviewDecision
```

If no PR found for current branch, inform user and exit.

## Step 2: Fetch Feedback

**Get PR details:**

```bash
gh pr view --json number,title,body,reviews,reviewDecision,comments
```

**Get inline code comments:**

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments --jq '.[] | {path, line, body, user: .user.login}'
```

## Step 3: Parse Comments

**Categorize each comment:**

| Pattern | Category |
|---------|----------|
| Review state = CHANGES_REQUESTED | Blocker |
| "must", "need to", "please fix" | Blocker |
| "should", "consider", "might" | Suggestion |
| "why", "what if", "?$" | Question |
| "nit", "minor", "optional" | Nitpick |

**Extract actionable items:**

For each comment/review body:
1. Check if it requests action
2. Summarize the request
3. Note the author
4. Track file/line if inline comment

## Step 4: Present Findings

**Display to user:**

```markdown
## PR #123 Feedback

**Status**: CHANGES_REQUESTED by @reviewer

### Blockers (must address)
1. Fix null handling in parseConfig (src/config.ts:42)
2. Add tests for edge cases

### Suggestions
3. Consider caching the parsed config

### Questions (respond or address)
4. Why not use the existing parser?

### Nitpicks (optional)
5. Rename variable for clarity
```

**Ask which to add to plan:**

```yaml
AskUserQuestion:
  questions:
    - question: "Which feedback items should be added to the plan?"
      header: "Select"
      multiSelect: true
      options:
        - label: "All blockers"
          description: "Add items 1-2"
        - label: "Blockers + suggestions"
          description: "Add items 1-3"
        - label: "All items"
          description: "Add everything"
        - label: "Select individually"
          description: "Choose specific items"
```

## Step 5: Update Plan

**Add PR Feedback section to `.devloop/plan.md`:**

```markdown
---

## PR Feedback

PR #123 - @reviewer (CHANGES_REQUESTED)

### Blockers
- [ ] [PR-123-1] Fix null handling in parseConfig
- [ ] [PR-123-2] Add tests for edge cases

### Suggestions
- [ ] [PR-123-3] Consider caching config

---
```

**Add Progress Log entry:**

```markdown
- YYYY-MM-DD: Added N PR feedback items from review
```

## Step 6: Next Steps

```yaml
AskUserQuestion:
  questions:
    - question: "Feedback added to plan. What next?"
      header: "Action"
      multiSelect: false
      options:
        - label: "Start fixing"
          description: "Work on first blocker"
        - label: "Respond first"
          description: "Reply to questions"
        - label: "Review plan"
          description: "See updated plan"
```

---

## Handling Responses

**For questions that need responses (not code changes):**

```bash
gh pr comment {number} --body "Re: [question]

[Your response]"
```

**After addressing feedback:**

```bash
gh pr comment {number} --body "Addressed feedback:
- [x] Fixed null handling
- [x] Added edge case tests

Ready for re-review."
```

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `gh pr view` | Get PR details |
| `gh pr view --comments` | See all comments |
| `gh api .../comments` | Get inline comments |
| `gh pr comment` | Reply to PR |

---

## Example Output

```
Fetching PR #42 feedback...

Found 5 comments from review by @alice:

BLOCKERS (2):
  1. [src/parser.ts:15] Handle null input
  2. [src/parser.ts:42] Add input validation

SUGGESTIONS (1):
  3. Consider using zod for validation

QUESTIONS (1):
  4. Why a custom parser vs. existing library?

Added 4 items to plan under "PR Feedback" section.
```
