---
name: stats
description: View token usage statistics and API limit tracking across all projects
allowed-tools: ["Bash", "Read"]
---

# Token Usage Statistics

Display devloop token usage statistics and API limits tracking.

## What to Show

Run the token tracker stats command to get usage information:

```bash
# Show overall statistics
${CLAUDE_PLUGIN_ROOT}/scripts/token-tracker.sh stats

# Show recent invocations
${CLAUDE_PLUGIN_ROOT}/scripts/token-tracker.sh recent 15

# Show current API usage
${CLAUDE_PLUGIN_ROOT}/scripts/fetch-api-usage.sh
```

## Output Format

Present the statistics in a clear, readable format:

### Overall Stats
- Total invocations tracked
- Total tokens used
- Breakdown by type (agent, skill, command)

### By Agent
- List top token-consuming agents
- Show call count and total tokens per agent

### By Project
- Token usage per project
- Useful for understanding which codebases are token-intensive

### Current API Limits
- 5-hour utilization %
- 7-day utilization %
- Opus limit (if applicable)

## Additional Commands

If the user wants more detail:
- `stats report [days]` - Generate detailed report for past N days
- `stats top [n]` - Show top N token consumers
- `stats export [json|csv]` - Export raw data for analysis

## Example Output

```
=== Devloop Token Usage Statistics ===

Total invocations: 45
Total tokens used: 892,340

By Type:
  agent: 28 calls, 756,000 tokens
  skill: 17 calls, 136,340 tokens

By Agent:
  engineer: 15 calls, 520,000 tokens
  code-reviewer: 8 calls, 180,000 tokens
  Explore: 5 calls, 56,000 tokens

By Project:
  cc-plugins: 30 calls, 650,000 tokens
  my-app: 15 calls, 242,340 tokens

Current API Usage:
  5-hour: 23%
  7-day: 67%
```
