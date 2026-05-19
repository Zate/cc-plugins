---
name: agent-cli
description: Deprecated compatibility bridge for the older agent-cli skill. Use when a user explicitly asks for agent-cli or older --agent-help CLI guidance; prefer the agent-help skill for new work.
user-invocable: true
argument-hint: "[language/framework context, e.g. 'go cobra', 'python click']"
---

# agent-cli compatibility bridge

`agent-cli` is superseded by `agent-help`.

For new CLI work, use the `agent-help` skill if it is available. It defines the current convention:

- `--agent-help` for AHF invocation help
- `--agent-out` for AHF envelope + TOON runtime results
- `err`/`hint`/`use` error responses for agent self-correction

If `agent-help` is not installed, implement the same user-facing behavior directly:

1. Add this breadcrumb to normal `--help` output:

   ```text
   LLM agent? Use --agent-help for token-optimized usage.
   ```

2. Implement trailing global `--agent-help`:

   ```text
   tool --agent-help
   tool subcmd --agent-help
   tool group subcmd --agent-help
   ```

3. Return an AH1 command index for `tool --agent-help`:

   ```text
   ah1 <tool> :: <purpose>
   cmd <command-signature> :: <purpose>
   more? <tool> <cmd> --agent-help
   ```

4. Return AH2 command detail for `tool subcmd --agent-help`:

   ```text
   ah2 <tool> <command-path>
   use <canonical invocation>
   arg <name>:<type> <req|opt> :: <purpose>
   flag --<name>:<type> <req|opt|repeat> [default=<value>] :: <purpose>
   ex <valid example invocation>
   ```

5. Return direct error hints for invalid invocations:

   ```text
   err <code> [key=value...]
   hint <direct correction>
   use <canonical invocation if useful>
   ```

6. For commands that emit structured runtime results, add `--agent-out` and return an AHF status envelope plus a TOON result body.

Prefer deriving `--agent-help` output from the CLI framework metadata used for dispatch. Before finishing, test that `--help` shows the breadcrumb, root `--agent-help` returns AH1, each command returns AH2, examples work, and invalid invocations include `err`/`hint`/`use`.
