# Common Plugin Mistakes
Sourced from the fix/optimize branch audit (2026-04-03). Each entry has symptom, cause, fix, and source citation.

---

## 1. `updatedMCPToolOutput` on Built-in Tools
**Symptom**: PostToolUse hook runs successfully but tool output is unchanged in context.  
**Cause**: `updatedMCPToolOutput` only applies when `isMcpTool(tool)` is true. Built-in tools (Bash, Read, Write, etc.) always return false.  
**Source**: `src/services/tools/toolHooks.ts` — `if (result.updatedMCPToolOutput && isMcpTool(tool))`  
**Fix**: Remove `updatedMCPToolOutput` from hooks targeting built-in tools. To reduce Bash output, teach the model to use quiet flags instead (see common mistake #3).

---

## 2. Wrong Input Field: `tool_output` vs `tool_response`
**Symptom**: Hook reads tool output but always gets an empty string.  
**Cause**: The PostToolUse input field is `tool_response`, not `tool_output`.  
**Source**: `src/entrypoints/sdk/coreSchemas.ts` — `PostToolUseHookInput` schema  
**Fix**: `TOOL_OUTPUT=$(echo "$INPUT" | jq -r '.tool_response // ""')`

---

## 3. Invalid `if` Condition Syntax
**Symptom**: Hook either never fires or fires on every tool call regardless of type.  
**Cause**: `if` uses permission-rule syntax, not JavaScript expressions.  
**Source**: `src/schemas/hooks.ts` — `IfConditionSchema` description  
**Fix**: `"if": "Bash"` not `"if": "tool == 'Bash'"`. For input matching: `"if": "Bash(npm *)"`

---

## 4. PreCompact with JSON hookSpecificOutput
**Symptom**: PreCompact hook runs but plan state is lost in the compaction summary.  
**Cause**: `PreCompact` has no entry in the `hookSpecificOutput` discriminated union. JSON output with `hookEventName: "PreCompact"` fails schema validation silently.  
**Source**: `src/types/hooks.ts` — no `z.literal('PreCompact')` in union  
**Fix**: Print plain text to stdout — `executePreCompactHooks()` captures stdout and merges it into compaction `customInstructions`. No JSON wrapper needed.

---

## 5. `when_not_to_use` Frontmatter Field
**Symptom**: No observable effect — field is silently ignored.  
**Cause**: Field does not exist in `FrontmatterData` type.  
**Source**: `src/utils/frontmatterParser.ts` — only `when_to_use` is defined  
**Fix**: Remove all `when_not_to_use` lines. If you need negative examples, put them in the skill body.

---

## 6. Find-and-Replace Frontmatter Corruption
**Symptom**: AskUserQuestion options render incorrectly or skill produces garbled YAML.  
**Cause**: A global find-and-replace for `when_to_use`/`when_not_to_use` injected those lines into the skill body, inside YAML code blocks.  
**Detection**: Look for `^when_to_use:` lines with a count > 1 in a single file — extras are in the body.  
**Fix**: Remove `when_to_use:` / `when_not_to_use:` lines outside the frontmatter fence (`---`).

---

## 7. SessionStart Matcher Missing `clear`
**Symptom**: After user runs `/clear`, the session-start hook doesn't fire and context isn't re-injected.  
**Cause**: Valid source values are `startup|resume|clear|compact`. Omitting `clear` means post-clear sessions get no hook.  
**Source**: `src/entrypoints/sdk/coreSchemas.ts` — `z.enum(['startup', 'resume', 'clear', 'compact'])`  
**Fix**: `"matcher": "startup|resume|clear|compact"`

---

## 8. Empty Placeholder Hooks
**Symptom**: Every Bash/Write/Edit call is slightly slower for no benefit.  
**Cause**: Hooks registered in hooks.json that just output `{"suppressOutput": true}` still spawn a shell process on every matching tool call.  
**Fix**: Delete placeholder scripts and remove their entries from hooks.json until they have real logic.

---

## 9. `paths: ["**/*"]` No-Op Wildcard
**Symptom**: Skill claims to be conditionally loaded but appears in listing unconditionally.  
**Cause**: `**/*` matches every file path — the skill immediately exits the conditional pool.  
**Source**: `src/skills/loadSkillsDir.ts` — `ignore().add(skill.paths)` gitignore-style matching  
**Fix**: Use specific globs: `["**/*.go", "go.mod"]`, `["**/*.py", "requirements.txt"]`, etc.

---

## 10. `effort: low` on Code-Writing Agents
**Symptom**: Agent produces shallower analysis, misses edge cases, writes lower-quality code.  
**Cause**: `effort: low` reduces reasoning depth. Appropriate for docs/summaries, wrong for agents that use Write/Edit/Bash to implement code.  
**Source**: `src/tools/AgentTool/runAgent.ts` — effort override applied before agent runs  
**Fix**: Remove `effort` field (inherits session default) or use `effort: medium`/`effort: high`. Only use `effort: low` for doc generators, summarizers, and labeling tasks.
