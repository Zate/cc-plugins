# agent-help Quick Reference

Full spec: https://zate.github.io/agent-help/AHF-RFC.md
TOON spec: https://github.com/toon-format/spec

## AHF record prefixes

| Prefix | Meaning | Context |
|---|---|---|
| `ah1` | agent-help index | `--agent-help` on root |
| `ah2` | agent-help detail | `--agent-help` on subcommand |
| `ok` | success status line | `--agent-out` envelope |
| `err` | error status line | any |
| `warn` | non-fatal warning | `--agent-out` envelope, after `ok` |
| `cmd` | command entry | AH1 |
| `use` | canonical invocation | AH2 |
| `arg` | positional argument | AH2 |
| `flag` | flag definition | AH2 |
| `ex` | valid example | AH2 |
| `hint` | direct correction | after `err` |
| `next` | follow-up command | after `ok` or `err` |
| `more?` | pointer to AH2 detail; not a shell command | AH1 |

## Scalar types (used in arg/flag records)

| Type | Meaning |
|---|---|
| `str` | free text string |
| `int` | integer |
| `num` | float |
| `bool` | true / false |
| `path` | filesystem path |
| `url` | URL |
| `id` | opaque identifier |
| `ts` | Unix timestamp |
| `date` | ISO 8601 date |
| `dur` | duration string |
| `kv` | key:value pair |
| `enum(a\|b)` | one of listed values |

## Key rules

- One record per line; first token = record type
- `key=value` metadata on header lines
- Quote values that contain spaces or `|`
- Use `_` for null / unknown / not applicable
- Use `|` for short lists inside one field
- `--agent-help` is always trailing: `tool subcmd --agent-help` (valid)
- `tool --agent-help subcmd` is **invalid**
- `more?` is a pointer record, not a shell command

## AH1 shape

```text
ah1 <tool> :: <purpose>
cmd <sig> :: <purpose>
more? <tool> <cmd> --agent-help
```

## AH2 shape

```text
ah2 <tool> <command-path>
use <canonical invocation>
arg <name>:<type> <req|opt> :: <purpose>
flag --<name>:<type> <req|opt|repeat> [default=<val>] :: <purpose>
ex <valid example>
```

## --agent-out shape

```text
ok <kind> [count=<n>] [more=<0|1>]   # AHF status line
warn <code> [key=val...]             # AHF warning (optional)
<TOON result body>                   # TOON (see toon-format/spec)
next "<exact follow-up command>"     # AHF follow-up
```

## Error shape

```text
err <code> [key=value...]
hint <direct correction>
use <canonical invocation>
```

For complex errors, use a TOON body after `err` instead of `hint`/`use` lines.
