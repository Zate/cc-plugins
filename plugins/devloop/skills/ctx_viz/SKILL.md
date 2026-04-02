---
name: ctx_viz
description: "Visualize and analyze the current session context to identify bloat and optimize token usage."
when_to_use: "Context usage is high, sessions are slow, or you need to prune unnecessary data."
when_not_to_use: "Normal development work with low context usage."
---

# Context Visualizer (ctx_viz)

Use this skill to see exactly what is weighing down your current session.

## Analysis Steps

1. **Check Totals**: Read \`.claude/context-usage.json\` to see current token counts and percentages.
2. **Identify Bloat**: 
   - Search for the largest files read this session.
   - List active subagents and their individual context costs.
   - Check for redundant \`CLAUDE.md\` or skill injections.
3. **Prune**:
   - If a file is too large, use \`/compact\` with specific instructions to summarize it.
   - Use \`/devloop:fresh\` to restart the context while preserving only the plan state.
   - Manually clear unnecessary tool outputs if they are huge.

## Session Stats
\`\`\`bash
cat .claude/context-usage.json
\`\`\`

## Largest File Reads
\`\`\`bash
# List files read this session by size
grep -h "\"name\":\"Read\"" .claude/projects/*.jsonl | jq -r '.message.content[].input.file_path' | sort | uniq -c
\`\`\`

---
**Now**: Analyze the current context and provide a summary of bloat.
