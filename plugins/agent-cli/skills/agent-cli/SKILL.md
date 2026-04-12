---
name: agent-cli
description: "This skill should be used when building, creating, or modifying any CLI tool or command-line application. Covers Go (Cobra), Python (Click), Rust (Clap), Node (Commander). Provides the --agent-help convention: structured, token-minimal help output that LLM agents can parse efficiently. Use when adding help text, designing CLI command structure, creating a new command-line tool, adding subcommands, implementing --help, or making CLI tools usable by AI agents."
user-invocable: true
argument-hint: "[language/framework context, e.g. 'go cobra', 'python click']"
---

# --agent-help Convention

When building or modifying a CLI tool, always implement the `--agent-help` flag following this convention. This is not optional guidance -- it is the standard for making CLIs usable by LLM agents.

## When to Use
- Building a new CLI tool in any language
- Adding or modifying help output for an existing CLI
- Designing command structure for a CLI application
- Adding subcommands, flags, or arguments to a CLI

## When NOT to Use
- GUI applications or web APIs with no CLI component
- Simple one-shot scripts with no flags or subcommands

## Why

`--help` is designed for humans: prose descriptions, grouped sections, multiple examples, flag aliases. Agents waste tokens parsing it and still get invocations wrong. `--agent-help` returns the minimum an agent needs to construct a correct call.

## The Flag

Every CLI implementing this convention adds a single global flag: `--agent-help`

When called with no subcommand, returns tier 1 (index). When called with a command path, returns tier 2 (command detail).

## Tier 1: Index

`tool --agent-help` returns a complete command index. Target: <300 tokens.

Format:
```
tool: one-line purpose
commands:
  cmd1 <required> [optional]  one-line
  cmd2 <required>  one-line
  group cmd3 --flag TYPE  one-line
```

Rules:
- One line per command, including inline required args
- Subcommands shown as `group cmd` not nested
- No flag details (tier 2)
- No aliases, no version, no author
- Sort by likely usage frequency if possible

Example:
```
ctx: persistent memory for LLM agents
commands:
  add --type TYPE --tag K:V... <text>  store a node
  query <search> [--type TYPE] [--limit N]  search nodes
  show <id>  display one node
  rm <id>  delete a node
  hook session-start [--project NAME]  session init
  hook session-end  session teardown
  init  create database
  version  print version
```

## Tier 2: Command Detail

`tool --agent-help <command>` returns everything needed to invoke that one command. Target: <150 tokens.

Format:
```
tool command <required-arg> [optional-arg] [flags]
flags:
  --name TYPE  purpose [default: X]
  --name TYPE  purpose [required]
  --name TYPE  purpose [conflicts: --other]
  --name TYPE  purpose [requires: --dep]
example:
  tool command --name value arg
```

Rules:
- TYPE is one of: `string`, `int`, `bool`, `path`, `enum(a|b|c)`
- Defaults only when non-obvious (omit `[default: ""]`, `[default: false]`)
- One example showing the common invocation
- Constraints inline: `[required]`, `[conflicts: --X]`, `[requires: --X]`
- No long descriptions, no flag aliases (-v/--verbose), no environment variable docs
- Positional args in signature with `<required>` and `[optional]`

Example:
```
ctx add <text> [flags]
flags:
  --type enum(decision|fact|pattern|observation)  node type [required]
  --tag string  key:value tag, repeatable
  --ttl string  auto-expire duration (e.g. 24h, 7d)
  --agent string  agent identity
example:
  ctx add --type fact --tag project:myapp --tag tier:pinned "the database uses postgres 15"
```

## Tier 3: Error Hints

When a command fails, the error message should include enough for an agent to self-correct without another help call.

Format:
```
error: what went wrong
hint: correct usage or value constraint
```

Rules:
- `error:` states what was wrong with the input
- `hint:` shows the fix or valid values, NOT "run --help"
- For enum violations, list valid values
- For missing flags, show the flag with its type

Examples:
```
error: --type is required
hint: --type enum(decision|fact|pattern|observation)
```
```
error: unknown command "ad"
hint: did you mean "add"? commands: add, query, show, rm, hook, init, version
```

## Bootstrap: The --help Breadcrumb

Agents that don't know about `--agent-help` will call `--help` first. Add one line at the bottom of your `--help` output so they discover it:

```
LLM agent? Use --agent-help for token-optimized usage.
```

This is the bridge. An agent sees it, switches to `--agent-help`, and gets the compact format from then on.

## Implementation Guidance

Adapt the examples below to the user's target language and framework:

$ARGUMENTS

### Go (Cobra)

Add a persistent flag on root and a `PersistentPreRun` that intercepts it:

```go
var agentHelp bool

func init() {
    rootCmd.PersistentFlags().BoolVar(&agentHelp, "agent-help", false, "Token-optimized help for LLM agents")
}

func agentHelpPreRun(cmd *cobra.Command, args []string) {
    if !agentHelp {
        return
    }
    if cmd == rootCmd {
        printAgentIndex()
    } else {
        printAgentCommand(cmd)
    }
    os.Exit(0)
}
```

For `printAgentCommand`, walk `cmd.Flags()` and emit the compact format. Don't reuse cobra's built-in help templates.

### Python (Click)

```python
@click.group()
@click.option('--agent-help', is_flag=True, hidden=True, help='Token-optimized help for LLM agents')
@click.pass_context
def cli(ctx, agent_help):
    if agent_help:
        if ctx.invoked_subcommand:
            print_agent_command(ctx.invoked_subcommand)
        else:
            print_agent_index()
        ctx.exit()
```

### Rust (Clap)

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long, global = true, hide = true)]
    agent_help: bool,
}
```

Intercept in main before dispatch. Walk `Command::get_subcommands()` and `get_arguments()` for the compact format.

### Node (Commander)

```js
program.option('--agent-help', 'Token-optimized help for LLM agents');
program.hook('preAction', (thisCommand) => {
  if (program.opts().agentHelp) {
    printAgentHelp(thisCommand);
    process.exit(0);
  }
});
```

### Adding the --help Breadcrumb

Append to your help template/epilog:

- **Cobra**: `rootCmd.SetHelpTemplate(cobra.CommandHelpTemplate + "\nLLM agent? Use --agent-help for token-optimized usage.\n")`
- **Click**: `@click.group(epilog="LLM agent? Use --agent-help for token-optimized usage.")`
- **Clap**: `#[command(after_help = "LLM agent? Use --agent-help for token-optimized usage.")]`

## Token Budget Reference

| Tier | Scope | Target | Max |
|------|-------|--------|-----|
| 1 | Whole CLI | <300 | 500 |
| 2 | One command | <150 | 250 |
| 3 | Error hint | <50 | 80 |

Worst case (unknown CLI, need one command): tier 1 + tier 2 = 2 calls, ~450 tokens.
Best case (know the command): tier 2 = 1 call, ~150 tokens.
