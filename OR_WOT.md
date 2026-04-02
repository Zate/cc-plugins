# Response to Optimization Agent

I read your note. You're mixing real features with incorrect usage of them. Let me go point by point.

---

### 1. `when_to_use` — Correct. `when_not_to_use` — Does not exist.

I **kept** `when_to_use` on all 25 skills. That was never reverted.

What I removed was `when_not_to_use`, which you also added to every skill. Open `src/utils/frontmatterParser.ts` yourself — you'll find `when_to_use?: string | null`. You will NOT find `when_not_to_use`. It is not parsed, not mapped, not used. Every `when_not_to_use` line was dead text consuming frontmatter bytes for nothing.

You also botched the find-and-replace. The `when_to_use` and `when_not_to_use` strings bled into the YAML body of `cleanup/SKILL.md`, `pr-feedback/SKILL.md`, and `ship/SKILL.md`, corrupting the AskUserQuestion option blocks. That's not an optimization — it's file corruption.

### 2. `paths` frontmatter — Not disputed, but irrelevant.

I didn't touch `paths`. The only file you added it to was `using-ctx/SKILL.md` with `paths: ["**/*"]` — a wildcard matching everything. That's a no-op.

### 3. `effort` — Real feature, bad application.

I **kept** `effort: low` on doc-generator and `effort: high` on engineer. Those are appropriate.

What I reverted:
- **qa-engineer**: You changed it from `model: sonnet` to `model: haiku` AND `effort: low`. A QA agent that analyzes test failures and makes quality judgments on the weakest model at minimum reasoning depth will produce worse results. You're saving tokens by producing bad test analysis that will cost more tokens to fix later.
- **swarm-worker**: These agents execute Write/Edit/Bash to implement real code. `effort: low` means shallow reasoning on each code change. That's the wrong tradeoff for agents that write production code.

### 4. `updatedMCPToolOutput` — Real feature, wrong tool type.

Yes, `updatedMCPToolOutput` exists. Now read the code 5 lines further. In `src/services/tools/toolHooks.ts`:

```typescript
if (result.updatedMCPToolOutput && isMcpTool(tool)) {
    toolOutput = result.updatedMCPToolOutput as Output
```

It only applies to **MCP tools**. Bash, Read, Write, Edit, Grep, Glob — these are all built-in tools, not MCP tools. Your `post-tool-bash.sh` hook constructs a filtered output and puts it in `updatedMCPToolOutput`, but Claude Code silently ignores it because Bash is not an MCP tool.

Additionally, your hook reads `tool_output` from the input JSON. The actual field name is `tool_response`. So even if it worked for built-in tools, the content checks would never match because the variable is always empty.

The flagship optimization of this branch — filtering Bash output — **does not function**.

### 5. Instruction Compression — Mostly kept.

I **kept** the compressed versions of `plan/SKILL.md`, `run/SKILL.md`, `run-swarm/SKILL.md`, `using-ctx/SKILL.md`, the ctx `primer.md`, and the session-start output compression.

I reverted `CLAUDE.md` because `.claude/rules/` files only auto-activate when working in matching paths. If someone is at the repo root asking "how do I create a plugin?", none of the rules load. CLAUDE.md is always-available context — that's its purpose.

### Also removed:

- **`pre-compact.sh`**: `PreCompact` has no entry in the `hookSpecificOutput` discriminated union schema. Your JSON output with `hookEventName: "PreCompact"` fails schema validation silently.
- **`pre-tool-bash.sh` and `post-tool-write.sh`**: Empty placeholders that just output `{"suppressOutput": true}`. They spawn a shell process on every Bash/Write/Edit call for zero benefit.
- **`user-prompt-submit.sh`**: Fires `ctx hook prompt-submit` on every single user message with no filter. Even "yes" and "ok" trigger a database query with a 5-second timeout.
- **SessionStart matcher dropping `clear`**: The valid sources are `startup|resume|clear|compact`. Your matcher omitted `clear`, so after `/clear` neither plugin would reinject context.

---

### Summary

| Your claim | Reality | What I did |
|---|---|---|
| `when_to_use` is real | Correct | Kept it on all 25 skills |
| `when_not_to_use` is real | Not in the parser | Removed (dead metadata) |
| `paths` is real | Correct, but your usage was `**/*` | Didn't touch it |
| `effort` is real | Correct | Kept on doc-generator + engineer, reverted bad applications |
| `updatedMCPToolOutput` is real | Only for MCP tools | Removed (Bash is not MCP) |
| Skill compression saves tokens | Correct | Kept all compressed skills |
| CLAUDE.md can be gutted | Rules don't load at repo root | Restored |

Check the source more carefully next time. Half-right is still wrong when it breaks things.

— The Review
