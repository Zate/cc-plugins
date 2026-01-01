# Devloop Benchmark Suite

Benchmark tools for comparing devloop plugin variants against native Claude Code.

## ⚠️ Important: Run from a Regular Terminal

**Do NOT run these benchmarks from within a Claude Code session.**

Running `claude -p` from inside Claude causes conflicts with auth tokens and session management. Open a fresh terminal window and run the scripts there.

## Quick Start

```bash
# Run native Claude benchmark (baseline)
./run-benchmark.py native

# Run devloop v3.x (optimized)
./run-benchmark.py optimized

# Run multiple iterations
./run-benchmark.py native 3

# Compare all results
./run-benchmark.py --compare
```

The script uses `uv run` automatically - no setup needed.

## Variants

| Variant | Description |
|---------|-------------|
| `native` | Raw Claude Code, no plugins |
| `baseline` | Devloop v2.4.x from `devloop-v2.4-baseline` branch |
| `optimized` | Current devloop from `main` branch |
| `lite` | Devloop with `/devloop:quick` (minimal overhead) |

## Live Progress

The benchmark shows real-time progress:

```
📍 Turn 1
   🔧 Write... ✓
   🔧 Write... ✓
📍 Turn 2
   🔧 Bash... ✓
   🔧 Read... ✓
--------------------------------------------------

✅ Complete!
   ⏱️  Duration: 180.5s
   📄 Files: 5
   📝 LOC: 142
   🧪 Tests: true
   💰 Cost: $2.4532
   🔄 Turns: 8
```

## Results

Results are saved to `results/` directory:
- `{variant}-{timestamp}-run{n}.json` - Raw streaming JSON from Claude
- `{variant}-{timestamp}-run{n}-summary.json` - Parsed metrics

## Comparing Results

```bash
./run-benchmark.py --compare
```

Output:
```
Variant      Runs   Avg Time   Avg Cost     Tests Pass
------------------------------------------------------------
native       3        180.2s   $  2.4500     3/3
optimized    3        195.8s   $  2.8200     3/3

Variant      Time vs Native   Cost vs Native
---------------------------------------------
optimized      1.09x            1.15x
```

## Metrics Tracked

- **Duration**: Wall clock time (seconds)
- **Files created**: Count of .js, .json, .md files
- **Lines of code**: Total JS lines (excluding node_modules)
- **Tests pass**: Whether `npm test` succeeds
- **Cost**: Total USD from Claude API
- **Turns**: Number of conversation turns
- **Tokens**: Input and output token counts

## Standard Task

All benchmarks use `task-fastify-api.md`:
- Fastify REST API with user CRUD
- JSON file persistence
- Mocha tests with coverage
- README documentation

## Technical Details

### How Claude Code is Run Programmatically

The benchmark uses Claude Code's headless mode with these key flags:

```bash
claude -p "task..." \
  --output-format stream-json \    # Newline-delimited JSON for real-time streaming
  --dangerously-skip-permissions \ # No permission prompts (auto-approve tools)
  --disallowedTools AskUserQuestion \  # Prevent blocking on questions
  --max-budget-usd 50 \            # Safety limit on API cost
  --append-system-prompt "..."     # Instructions for autonomous operation
```

### Avoiding Hanging Issues

The script uses non-blocking I/O with `select()` to prevent pipe buffer deadlocks:

1. **Both stdout and stderr are piped** - but only stdout is needed
2. **select() polls both pipes** - prevents either buffer from filling and blocking
3. **Non-blocking reads** - uses `fcntl(O_NONBLOCK)` so reads never hang
4. **Activity timeout** - kills process if no output for 30 minutes

This is necessary because:
- Python's `for line in process.stdout` can buffer unexpectedly
- If stderr fills its 64KB buffer while you're blocked on stdout, the process deadlocks
- Claude's `stream-json` output may not flush line-by-line without careful handling

### JSON Output Structure

The `stream-json` format produces newline-delimited JSON:

```json
{"type": "assistant", "message": "..."}
{"type": "tool_use", "name": "Write", "input": {...}}
{"type": "tool_result", "is_error": false, "output": "..."}
{"type": "result", "total_cost_usd": 2.45, "num_turns": 8, "usage": {...}}
```

The final `result` message contains usage statistics.

### Troubleshooting

**Benchmark hangs immediately:**
- Run from a regular terminal, NOT inside Claude Code
- Check that `claude` command is in PATH

**No output captured (0-byte files):**
- Usually indicates pipe deadlock - the new script fixes this
- Check stderr output in results

**Timeout after 30 minutes:**
- Task may be too complex
- Check raw JSON output for partial progress
