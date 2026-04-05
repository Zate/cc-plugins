# qx — Query Execute

Smart bash execution with LLM-filtered output. Runs shell commands and returns only the information you actually need, keeping your context window lean.

## What It Does

`qx` is a skill that sits between you and raw bash output. Instead of dumping the full result of a command into your conversation context, it runs the command in a Haiku sub-agent, extracts only the relevant bits, and returns a distilled answer.

```
Raw Bash:  git log --oneline -100  →  100 lines enter your context
qx:        git log --oneline -100  →  "3 commits touched auth" enters your context
```

## How It Works

qx uses XML tags to cleanly separate the command from the extraction instruction:

```xml
<command>the bash command to run</command>
<extract>what information to pull from the output</extract>
```

This design means **any bash command works verbatim** — pipes, quotes, URLs, special characters, heredocs — nothing needs escaping because the command is structurally separated from the instruction, not delimited by an in-band character.

### Examples

```xml
<!-- Simple listing with filter -->
<command>docker ps -a</command>
<extract>names and ports of running containers</extract>

<!-- Complex command with nested quotes -->
<command>docker exec mydb psql -c "SELECT * FROM users WHERE role='admin'"</command>
<extract>count of admin users and their email addresses</extract>

<!-- Pipes and sorting -->
<command>find . -name "*.ts" -exec wc -l {} + | sort -rn</command>
<extract>top 5 largest TypeScript files</extract>

<!-- URLs with // in them (no collision) -->
<command>curl -s https://api.example.com/v2/status</command>
<extract>response code and any error messages</extract>

<!-- No extract tag = concise summary -->
<command>kubectl get pods -A</command>
```

## Primary Use: Agent-Invoked

qx is designed primarily for **model invocation** — Claude decides when to use it and constructs the XML call automatically. You don't need to type the XML yourself. Just tell Claude what you need:

> "What Python processes are using the most memory?"

Claude will decide whether qx is appropriate (large expected output, only a fraction needed) and invoke it, or use raw Bash if the output would be small.

### Manual Invocation

You can also invoke it directly:

```
/qx <command>ps aux</command><extract>python processes sorted by memory</extract>
```

But the typical workflow is just talking to Claude and letting it pick the right tool.

## When It Helps

qx is valuable when:
- Command output is **large relative to what you need** — logs, listings, status dumps
- You'd normally chain `grep | awk | head` to narrow output
- You want to **ask a question** that a shell command can answer
- You're working in a **long session** and context efficiency matters

## When NOT to Use It

> **Important**: qx has a fixed overhead cost of ~27k tokens per invocation (sub-agent system prompt and tool scaffolding). It only saves context when the raw output would be significantly larger than this overhead.

**The rule of thumb**: If the command produces **under 50 lines of output**, or you need **most of the output**, use regular Bash. qx saves nothing in those cases and costs more.

Specifically, don't use qx for:

| Scenario | Why | Use Instead |
|----------|-----|-------------|
| Side-effect commands (`npm install`, `git push`) | Need full output to verify success | Bash |
| Build/test output | Need every line for debugging | Bash |
| Small output (`pwd`, `whoami`, `git status`) | Raw output is already small | Bash |
| You need 80%+ of the output | Nothing to filter out | Bash |
| Error debugging | Need complete error context | Bash |

## Cost Model

```
Raw Bash cost:     output_tokens (enter parent context directly)
qx cost:           ~27k overhead + haiku_tokens (only distilled result enters parent context)

Break-even:        when raw output would be >> 27k tokens
                   (~50+ lines where you need a fraction)

Sweet spot:        commands producing 100+ lines where you need <10 lines
```

## Why XML Tags?

Bash commands can contain anything — pipes, quotes, URLs with `//`, semicolons, heredocs, nested subshells. Any in-band separator (`//`, `---`, `|||`) will eventually collide with a real command. XML tags provide structural separation:

- `<command>` wraps the bash command verbatim — no escaping needed
- `<extract>` wraps the extraction instruction
- No ambiguity, no collision, and LLMs handle XML naturally

## Installation

```bash
/plugin install /path/to/cc-plugins/plugins/qx
# or via marketplace
/plugin marketplace add Zate/cc-plugins
```
