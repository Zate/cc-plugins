# Creating an Issue (For Agents)

Step-by-step process for agents to create issues programmatically.

## 1. Initialize Directory

```bash
mkdir -p .devloop/issues
```

## 2. Determine Type

Analyze the input using smart routing keywords:

### Bug Keywords
- "bug", "broken", "doesn't work", "not working"
- "error", "crash", "exception", "fail"
- "fix", "wrong", "incorrect", "unexpected"

### Feature Keywords
- "add", "new", "implement", "create", "build"
- "feature", "enhancement", "request"
- "support", "enable", "allow"

### Task Keywords
- "refactor", "clean up", "improve", "optimize"
- "update", "upgrade", "migrate"
- "reorganize", "restructure"

### Chore Keywords
- "chore", "maintenance", "dependency"
- "bump", "upgrade dependency"
- "ci", "build system", "config"

### Spike Keywords
- "investigate", "explore", "research"
- "spike", "poc", "prototype"
- "evaluate", "assess"

### Routing Priority

If multiple types match, use this priority:
1. Explicit type mention ("this is a bug")
2. Bug keywords (issues are often bugs)
3. Feature keywords
4. Task keywords
5. Default to `task` if unclear

Always confirm detected type with user before creating.

## 3. Get Next ID

```bash
prefix="FEAT"  # Based on detected type
max_num=$(ls .devloop/issues/${prefix}-*.md 2>/dev/null | \
  sed "s/.*${prefix}-0*//" | sed 's/.md//' | \
  sort -n | tail -1)
next_num=$((${max_num:-0} + 1))
id=$(printf "${prefix}-%03d" $next_num)
```

## 4. Create Issue File

Use the frontmatter schema and file format from main SKILL.md.

## 5. Regenerate Views

After creating the issue file, regenerate all view files.

## Quick Issue Template

For agents to quickly log an issue:

```markdown
---
id: {PREFIX}-{NNN}
type: {bug|feature|task|chore|spike}
title: {one-line summary}
status: open
priority: {low|medium|high}
created: {ISO timestamp}
updated: {ISO timestamp}
reporter: agent:{agent-name}
labels: [{relevant, labels}]
related-files:
  - {file paths if known}
---

# {PREFIX}-{NNN}: {one-line summary}

## Description

{What this is about - 1-3 sentences}

## Context

- Discovered during: {what agent was doing}
- Related to: {feature area if applicable}
```
