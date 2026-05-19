---
name: agent-help
description: >-
  Implement the agent-help convention in a CLI. Use when building or modifying
  a CLI that agents will invoke: add --agent-help for AHF-format invocation
  help and --agent-out for TOON-encoded runtime results with an AHF protocol
  envelope. agent-help conforming CLIs expose a direct agent-readable surface
  that MCP servers, skills, and plugins can also wrap.
license: Apache-2.0
metadata:
  version: "0.1"
  spec: "https://zate.github.io/agent-help/AHF-RFC.md"
  homepage: "https://github.com/Zate/agent-help"
compatibility: >-
  Language-agnostic. Works with any CLI framework (Cobra, Click, Clap,
  Commander, argparse, etc.). No runtime dependencies.
---

# agent-help CLI contract

When building or modifying a non-trivial CLI, implement agent-native surfaces.

Core surface:
- `--agent-help`: AHF invocation help for agents.

Recommended when commands emit structured results:
- `--agent-out`: runtime output using AHF protocol envelope + TOON result body.

Reference spec:
- [`references/REFERENCE.md`](references/REFERENCE.md) - quick-reference card
- [AHF RFC](https://zate.github.io/agent-help/AHF-RFC.md) - full AHF draft specification
- [agent-help examples](https://github.com/Zate/agent-help/tree/main/examples) - output examples
- [llms-full.txt](https://github.com/Zate/agent-help/blob/main/llms-full.txt) - pasteable implementation brief
- [TOON spec](https://github.com/toon-format/spec) - encoding for --agent-out result bodies

## Core rule

Do not make agents consume human `--help`, markdown tables, prose output, or JSON unless no agent-native surface exists. Humans get default output. Software gets `--json`. Agents get `--agent-help` and `--agent-out`.

## Flag placement

`--agent-help` is a trailing global flag.

Valid:
```text
tool --agent-help
tool subcmd --agent-help
tool group subcmd --agent-help
```

Invalid:
```text
tool --agent-help subcmd
tool --agent-help group subcmd
```

`--agent-out` should also be accepted as a global flag. Prefer trailing form:
```text
tool subcmd args --agent-out
```

## Discovery breadcrumb

Append a short pointer to normal human `--help` output, for example:

```text
LLM agent? Use --agent-help for token-optimized usage.
```

## AHF basics

AHF is dense text for LLM agents.

Rules:
- UTF-8 plain text; ASCII preferred.
- One record per line.
- First token = record type.
- Use `key=value` metadata.
- Quote only values with whitespace or reserved delimiters.
- Use `_` for null/unknown/not applicable.
- Use `|` for short lists inside one field.
- Include IDs and exact next commands needed for follow-up.
- No decorative headings, color, markdown tables, JSON, or prose paragraphs.

Common record prefixes:
```text
ah1   agent-help index
ah2   agent-help command detail
ok    successful runtime result
err   error
warn  warning
cmd   command entry
use   canonical invocation
arg   positional argument definition
flag  flag definition
ex    valid example invocation
hint  direct correction
next  exact continuation or recommended next command
```

Common types:
```text
str int num bool path url id ts date dur kv enum(a|b)
```

## Implement `--agent-help`

### AH1: index

Returned by `tool --agent-help`.

Format:
```text
ah1 <tool> :: <purpose>
cmd <command-signature> :: <purpose>
cmd <group> <command-signature> :: <purpose>
more? <tool> <cmd> --agent-help
```

Rules:
- One `cmd` line per invocable command.
- Flatten nested commands into command paths.
- Include required args inline.
- Include only highest-value optional flags.
- No aliases, author, version, prose, examples, or flag details.
- Sort by likely agent usage when known.
- Target <300 tokens.

Example:
```text
ah1 mem :: project memory for agents
cmd node add <text> --type TYPE [--tag K:V...] :: store node
cmd node list [--type TYPE] [--limit int] :: list nodes
cmd search query <search> [--type TYPE] [--limit int] :: search nodes
more? mem <cmd> --agent-help
```

### AH2: command detail

Returned by `tool subcmd --agent-help`.

Format:
```text
ah2 <tool> <command-path>
use <canonical invocation>
arg <name>:<type> <req|opt> :: <purpose>
flag --<name>:<type> <req|opt|repeat> [default=<value>] :: <purpose>
ex <valid example invocation>
```

Rules:
- Include required args and required flags.
- Include optional flags that materially change behavior.
- State defaults only when non-obvious.
- Use `repeat` for repeatable flags.
- Every `ex` should work as written; omit examples that may drift.
- Target <150 tokens.

Example:
```text
ah2 mem node add
use mem node add <text> --type TYPE [--tag K:V...]
arg text:str req :: node text
flag --type:enum(decision|fact|pattern|observation) req :: node type
flag --tag:kv repeat :: metadata
ex mem node add "postgres 15" --type fact --tag project:myapp
```

### AE1: invalid invocation error

Format:
```text
err <code> [key=value...]
hint <direct correction>
use <canonical invocation if useful>
```

Rules:
- Never respond only with `run --help`.
- For enum errors, list valid values.
- For missing flags, show exact flag and type.
- Include `use` when it prevents another help call.
- Target <50 tokens.

Example:
```text
err missing_flag flag=--type
hint --type enum(decision|fact|pattern|observation)
use mem node add <text> --type TYPE
```

## Implement `--agent-out`

Use AHF for the protocol envelope and TOON for structured runtime command results.

### Success list

```text
ok <kind> count=<n> more=<0|1>
nodes[#3]{id,type,tags,text}:
  n_102,fact,"project:billing|db",postgres 15 required
  n_088,decision,project:billing,migrate read model
  n_061,pattern,db|ops,use connection pool max 20
next <exact command if more=1>
```

Rules:
- Put stable identifiers first.
- Put status/action fields early.
- Use TOON for lists, objects, and other structured data.
- Include `next` when `more=1` or output is truncated.

### Single object

```text
ok <kind>
project[#2]{key,value}:
  name,agent-help
  status,draft
next inspect "<exact follow-up command>"
```

### Runtime error

```text
err <code> [key=value...]
hint <direct correction>
use <canonical command if useful>
```

## Accuracy checklist

Do:
- Derive `--agent-help` from the same command metadata used for dispatch when possible.
- Keep `--agent-help` and actual behavior synchronized.
- Test every AH1 `cmd` has AH2 output.
- Test every AH2 `ex` exits successfully or remove it.
- Test required args/flags in AH2 match actual validation.
- Keep AHF field names and order stable across releases when possible.
- Include exact continuation commands for pagination/truncation.
- Redact secrets and unnecessary personal data.

Avoid:
- Put `--agent-help` before subcommands.
- Hand-maintain stale command lists if framework metadata is available.
- Emit JSON for `--agent-help` or `--agent-out` unless user explicitly requested JSON.
- Emit markdown tables as agent output.
- Use long prose paragraphs in agent output.
- Tell an agent only to run `--help` after an error.

## Framework implementation hints

Cobra:
- Add hidden persistent/global bool flags `agent-help`, `agent-out`.
- Resolve current command after parsing.
- Print AH1 when current command is root; AH2 otherwise.
- Generate from `Command.Use`, args, flags, annotations.

Click:
- Add hidden eager global options.
- Use context command path to choose AH1 vs AH2.
- Generate from `Command.params`, argument metadata, option metadata.

Clap:
- Add hidden global args.
- Intercept after parse before command execution.
- Generate from `Command::get_subcommands()` and `get_arguments()`.

Commander:
- Add global options.
- Use preAction hooks.
- Generate from commands/options metadata.

Argparse/other:
- Add global flags.
- Generate from parser/subparser/action metadata.
- Avoid independent handwritten specs when metadata exists.

## Completion checklist

Before finishing CLI work:
- `tool --help` shows breadcrumb.
- `tool --agent-help` returns AH1.
- `tool subcmd --agent-help` returns AH2 for every command.
- Invalid invocations return AE1-style `err/hint/use`.
- Structured result commands support `--agent-out` or there is a documented reason not to.
- Tests cover help accuracy and at least one `--agent-out` runtime output.
