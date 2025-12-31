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
