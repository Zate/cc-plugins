# Hook Schemas Reference
Source: `~/projects/claude-code/src/types/hooks.ts` (verified 2026-04-03)

## hookSpecificOutput — Valid Fields per Event

| Event | Valid hookSpecificOutput fields | Notes |
|---|---|---|
| `SessionStart` | `additionalContext`, `initialUserMessage`, `watchPaths` | — |
| `PreToolUse` | `permissionDecision` ("allow"/"deny"/"ask"), `permissionDecisionReason`, `updatedInput`, `additionalContext` | Use `permissionDecision` not top-level `decision` (deprecated) |
| `PostToolUse` | `additionalContext`, `updatedMCPToolOutput` | `updatedMCPToolOutput` **only works for MCP tools** — silently ignored for built-in tools (Bash, Read, Write, Edit, Grep, Glob) |
| `PostToolUseFailure` | `additionalContext` | — |
| `UserPromptSubmit` | `additionalContext` | — |
| `Setup` | `additionalContext` | — |
| `SubagentStart` | `additionalContext` | — |
| `PreCompact` | **NONE** | PreCompact has no hookSpecificOutput schema entry. Use plain stdout — it is captured by `executePreCompactHooks()` and merged into compaction `customInstructions`. |
| `PermissionRequest` | `decision` with `{behavior: "allow", updatedInput?, updatedPermissions?}` or `{behavior: "deny", message?, interrupt?}` | Complex structure — see source |
| `CwdChanged` | `watchPaths` | — |
| `FileChanged` | `watchPaths` | — |
| `WorktreeCreate` | `worktreePath` | — |

## Top-Level Hook Response Fields
Valid in all sync hook responses (from `syncHookResponseSchema`):
- `continue` (boolean) — whether Claude should continue
- `suppressOutput` (boolean) — hide stdout from transcript (default: false)
- `stopReason` (string) — message shown when `continue` is false
- `decision` ("approve" | "block") — **deprecated**, use `permissionDecision` in hookSpecificOutput
- `reason` (string) — **deprecated**
- `systemMessage` (string) — user-visible warning line
- `hookSpecificOutput` (object) — event-specific output, discriminated by `hookEventName`

## `if` Condition Syntax
Uses **permission-rule syntax**, NOT JavaScript expressions.

| ✅ Correct | ❌ Wrong |
|---|---|
| `"if": "Bash"` | `"if": "tool == 'Bash'"` |
| `"if": "Bash(git *)"` | `"if": "tool === 'Bash' && ..."` |
| `"if": "Write"` | `"if": "tool == 'Write' \|\| tool == 'Edit'"` |

The `if` field only applies to tool events: PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest.

## Hook Input Field Names (PostToolUse)
Input schema (`PostToolUseHookInput`):
- `tool_name` ✅
- `tool_input` ✅
- **`tool_response`** ✅ — the tool's output
- `tool_use_id` ✅
- ~~`tool_output`~~ ❌ — does not exist

## SessionStart Source Values
Valid `matcher` values (from `z.enum`):
- `startup`, `resume`, `clear`, `compact`

If your matcher is `"startup|compact|resume"` it is missing `clear` — sessions after `/clear` won't reinject context.

## Built-in Tools (not MCP)
These are built-in, NOT MCP tools. `updatedMCPToolOutput` is silently ignored for all of these:
`Bash`, `Read`, `Write`, `Edit`, `Grep`, `Glob`, `Agent`, `Skill`, `TodoWrite`, `TodoRead`, `AskUserQuestion`, `WebFetch`, `WebSearch`, `NotebookRead`, `NotebookEdit`
