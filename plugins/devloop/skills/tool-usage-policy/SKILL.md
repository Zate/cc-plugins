---
name: tool-usage-policy
description: This skill should be used when planning "file operations", "tool selection", "search strategy", or when the user needs guidance on which built-in tools to use. Consolidated guidance that prevents permission prompts and ensures efficient parallel execution.
whenToUse: |
  - Starting file discovery or search operations
  - Planning multi-step analysis workflows
  - Before using Bash for file operations
  - Choosing between Glob, Grep, Read, Edit tools
  - Setting up parallel tool execution
whenNotToUse: |
  - Simple git commands (git status, git log)
  - Project build/test commands (npm test, go build)
  - When tool choice is obvious from context
  - System administration commands
---

# Tool Usage Policy

**Purpose**: Standardize tool usage for consistent, efficient, permission-free operations.

## When to Use This Skill

- Starting file discovery or search operations
- Planning multi-step analysis workflows
- Before using Bash for file operations

## When NOT to Use This Skill

- Simple git commands (`git status`)
- Project build/test commands (`npm test`)

---

## Tool Selection Reference

| Use Case | Tool | NOT These |
|----------|------|-----------|
| File discovery | **Glob** | find, ls |
| Content search | **Grep** | grep, rg |
| Read files | **Read** | cat, head, tail |
| Edit files | **Edit** | sed, awk |
| Write files | **Write** | echo >, cat <<EOF |

---

## Approved Tools

### Glob - File Pattern Matching
Finding files (`**/*.go`, `**/*.py`, `**/package.json`)

### Grep - Content Search
Finding patterns, functions, TODOs

**Output modes**: `files_with_matches`, `content` (with -A/-B/-C), `count`

**Examples**:
```
Grep: "func \w+\(" --glob "*.go" --output_mode content
Grep: "TODO" --glob "*.py" -i --output_mode files_with_matches
```

### Read - File Content
Examining specific files

### Edit - File Modification
String replacements, renaming variables

### Write - File Creation
Reports, new files

### Bash - Approved Commands Only

```bash
# File counting
find . -type f -name "*.go" | wc -l

# Directory structure
find . -type d -maxdepth 3

# File size analysis
find . -name "*.go" -not -path "*/vendor/*" -exec wc -l {} + | sort -rn | head -20

# Line counting
wc -l /path/to/file
```

---

## DO Guidelines

```
✅ Use Glob for file discovery, run in parallel
Glob: **/*.go
Glob: **/*.py

✅ Use Grep for content search, run in parallel
Grep: "TODO" --glob "*.go" -i
Grep: "FIXME" --glob "*.go" -i

✅ Use Read for files, run in parallel
Read: /path/to/file1.go
Read: /path/to/file2.py
```

---

## DON'T Guidelines

```
❌ DON'T use find when Glob works
❌ DON'T use bash grep
❌ DON'T use cat/head/tail
❌ DON'T use sed/awk
❌ DON'T use echo/heredoc
❌ DON'T request permission for approved tools
```

---

## Parallelization

**Parallelize**:
- Multiple Glob/Grep searches for different patterns
- Multiple Read operations on independent files
- Initial discovery phase

**Don't Parallelize**:
- Operations depending on previous results
- Writing to same file
- Sequential analysis steps

---

## Why This Matters

- **No Permission Prompts** - Tools run autonomously
- **Consistent Results** - Same tool = same output
- **Efficient Execution** - Optimized & parallel
- **Proper Error Handling** - Structured errors

---

## See Also

- `Agent: refactor-analyzer` - Primary consumer
- `Skill: go-patterns`, `python-patterns`, `react-patterns`
