---
name: lint
description: "Lint and audit a Claude Code plugin, skill, or hook for correctness, token efficiency, and quality. Runs static analysis against verified Claude Code internals, then delegates to skill-creator for description optimization and eval benchmarking. Use when reviewing plugin changes, writing new hooks/skills, debugging a hook that silently does nothing, or before merging to main."
when_to_use: "Before merging plugin changes, after writing a new skill or hook, debugging unexpected hook behavior, validating a whole plugin directory, or running pre-commit quality checks."
argument-hint: "[path-to-plugin|skill-dir|hooks-dir] [--static-only] [--fix]"
context: fork
user-invocable: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
  - Agent
  - Skill
  - TaskCreate
  - TaskUpdate
  - TaskList
---

# plugin-lint

Orchestrated quality audit for Claude Code plugins. Runs static correctness checks first (the unique value), then delegates to existing tools for depth.

**Flags:**
- (default): Full lint — static analysis + skill-creator description optimization
- `--static-only`: Skip description optimization, faster pass
- `--fix`: Auto-apply all HIGH severity fixes without prompting

---

## Phase 1: Discover Target

Parse `$ARGUMENTS`. Extract path and flags.

**Target resolution:**
- No path → use current working directory
- Path ends in `SKILL.md` → single skill file
- Path contains `hooks/` or ends in `hooks.json` → hooks audit only
- Path contains `.claude-plugin/` or has `plugin.json` → whole plugin
- Otherwise → try as plugin root, skill dir, or hooks dir in that order

**Enumerate components (silent):**
```bash
find "$TARGET" -name "SKILL.md" 2>/dev/null
find "$TARGET" -name "hooks.json" 2>/dev/null
find "$TARGET" -name "*.sh" -path "*/hooks/*" 2>/dev/null
find "$TARGET" -name "*.md" -path "*/agents/*" 2>/dev/null
find "$TARGET" -name "plugin.json" 2>/dev/null
```

Store discovered files. Note counts: N skills, M hooks, P agents.

---

## Phase 2: Static Correctness Audit

Read all three reference files before starting:
- `${CLAUDE_SKILL_DIR}/references/hook-schemas.md`
- `${CLAUDE_SKILL_DIR}/references/frontmatter-fields.md`
- `${CLAUDE_SKILL_DIR}/references/common-mistakes.md`

Collect findings as a list. Each finding: `{severity, file, line, issue, fix}`.

### 2a. Audit hooks.json files

For each `hooks.json` found:

**`if` condition syntax:**
```bash
grep -n '"if"' "$HOOKS_JSON"
```
Flag any value containing `==`, `===`, `||`, `&&`, `!=` — these are JS expressions, not permission-rule syntax. Correct form: `"Bash"`, `"Bash(git *)"`, `"Write"`.

**hookSpecificOutput event names:**
```bash
grep -n '"hookEventName"' "$HOOKS_JSON"
```
Cross-reference against the valid-events table in `hook-schemas.md`. Flag `"PreCompact"` — it has no schema entry. Flag any unknown event name.

**SessionStart matcher:**
```bash
grep -n '"matcher"' "$HOOKS_JSON"
```
If the hook event is `SessionStart` and the matcher doesn't include `clear`, flag as MEDIUM.

**updatedMCPToolOutput on built-in tools:**
For each PostToolUse hook, check if the hook script references `updatedMCPToolOutput`. If so, also check the `if` condition — if it targets a built-in tool (Bash, Read, Write, Edit, Grep, Glob), flag HIGH.

### 2b. Audit hook shell scripts

For each `.sh` in `hooks/`:

**Wrong input field name:**
```bash
grep -n 'tool_output' "$SCRIPT"
```
Flag any `tool_output` reference — correct field is `tool_response`.

**JSON PreCompact output:**
```bash
grep -n 'hookEventName.*PreCompact' "$SCRIPT"
```
Flag — PreCompact must use plain stdout, not JSON hookSpecificOutput.

**Placeholder scripts:**
If script has fewer than 5 non-comment lines and only outputs `suppressOutput: true`, flag as LOW (dead weight — spawns process for nothing).

### 2c. Audit SKILL.md files

For each `SKILL.md` found:

**Extract frontmatter** (between first and second `---`):
```bash
awk 'BEGIN{f=0} /^---/{f++; next} f==1{print}' "$SKILL"
```

**Unknown frontmatter keys:**
Compare all keys against the valid list in `frontmatter-fields.md`. Flag anything not in the list as MEDIUM.

**Nonexistent fields:**
Flag `when_not_to_use` as HIGH (not in parser, dead metadata).

**Missing `when_to_use`:**
If skill has a description but no `when_to_use`, flag as LOW (skill may not appear in model listing).

**No-op paths glob:**
If `paths` is set and includes `**/*` or `**`, flag as LOW.

**Body length:**
```bash
wc -l < "$SKILL"
```
Warn at 400 lines, flag at 600 lines.

**Body corruption — frontmatter keys leaking into body:**
```bash
# Count when_to_use occurrences total
grep -c '^when_to_use:' "$SKILL" 2>/dev/null || echo 0
```
If count > 1: lines outside the frontmatter fence. Flag HIGH — indicates find-and-replace corruption.

**AskUserQuestion block integrity:**
```bash
grep -n 'AskUserQuestion\|options:\|- label:' "$SKILL"
```
If `AskUserQuestion` block exists, verify each `- label:` is immediately followed by valid indented content (not a stray `when_to_use:` line).

### 2d. Audit agent .md files

For each agent `.md` in `agents/`:

**Extract frontmatter**, check valid fields.

**effort: low with code tools:**
If `effort: low` and `tools:` includes `Write`, `Edit`, or `Bash` → flag MEDIUM.

**Model quality mismatch:**
If `model: haiku` and tools include `Write`/`Edit`/`Bash` → flag MEDIUM.

---

## Phase 3: CC Source Verification (optional deep check)

Check if source is available:
```bash
ls ~/projects/claude-code/src/types/hooks.ts 2>/dev/null && echo "available"
```

If available, cross-reference:
```bash
grep -n 'z.literal' ~/projects/claude-code/src/types/hooks.ts | grep -v '//'
```
Compare against hookSpecificOutput event names found in target's hooks. Cite actual source line numbers in findings. Upgrade confidence of all schema findings from "reference says" to "source-verified at line N".

If not available, note "source not present — findings based on reference docs only."

---

## Phase 4: Description Quality Delegation

Skip if `--static-only` flag is set.

For each SKILL.md with a non-empty `description`:

Invoke skill-creator's description optimization. Spawn as background Agent tasks (parallel if multiple skills):

```
Agent task prompt:
"Use the skill-creator skill to run description optimization on this skill.
Skill path: <path>
Current description: <description>
Run the description optimization loop (not full evals — just the trigger optimization).
Find the skill-creator scripts at: ~/.claude/plugins/cache/claude-plugins-official/skill-creator/unknown/skills/skill-creator/
Report: original score, best score, and the improved description if score improved by >0.05."
```

Collect results as each task completes. Note: skill-creator needs the `claude` CLI available for `run_loop.py`.

If `claude` CLI is not found or skill-creator scripts are absent, skip this phase and note why.

---

## Phase 5: Synthesize and Report

Present unified report:

```
## plugin-lint Report: <target path>
Checked: <N> skills, <M> hooks.json, <P> hook scripts, <Q> agents
Source verification: [available / not available]

### 🔴 HIGH — Must Fix (<count>)
<file>:<line>  <issue>
  → Fix: <specific correction>

### 🟡 MEDIUM — Should Fix (<count>)
...

### 🟢 LOW — Consider (<count>)
...

### ✅ Clean
<files with no issues>

### Description Optimization Results
<skill-name>: <old-score> → <new-score>
  New description: "<improved text>"
<skill-name>: <score> — no improvement found
[skipped — --static-only]
```

If zero findings and no description improvements: "All checks passed. No issues found."

Then — unless `--fix` was passed:

```yaml
AskUserQuestion:
  question: "Found <N> issues. How would you like to proceed?"
  header: "plugin-lint"
  multiSelect: false
  options:
    - label: "Apply all HIGH fixes"
      description: "Auto-fix the <count> HIGH severity issues"
    - label: "Walk me through each issue"
      description: "Review and approve fixes one by one"
    - label: "Apply description improvements"
      description: "Update descriptions with optimized versions"
    - label: "Just the report"
      description: "No changes — report only"
```

If `--fix`: apply all HIGH fixes automatically, then show report.

### Applying Fixes

For each HIGH finding, apply the specific correction:
- Bad `if` syntax → rewrite the `"if"` value in hooks.json
- `when_not_to_use` frontmatter → remove the line
- Body corruption (extra `when_to_use:` lines) → remove all occurrences after the frontmatter close
- Wrong `tool_output` field → replace with `tool_response` in the script
- PreCompact JSON → rewrite script to output plain text

After applying fixes, re-run Phase 2 on modified files to confirm clean.

---

## Reference Files

Load on demand — do not load all at once:
- `references/hook-schemas.md` — hook event schemas, `if` syntax, input fields
- `references/frontmatter-fields.md` — valid frontmatter keys for skills and agents
- `references/common-mistakes.md` — top 10 failure patterns with source citations
