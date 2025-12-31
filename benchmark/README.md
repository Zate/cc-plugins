# Devloop Benchmark Suite

Benchmark tools for comparing devloop plugin variants against native Claude Code.

## ⚠️ Important: Run from a Regular Terminal

**Do NOT run these benchmarks from within a Claude Code session.**

Running `claude -p` from inside Claude causes conflicts with auth tokens and session management. Open a fresh terminal window and run the scripts there.

## Quick Start

```bash
# Make scripts executable
chmod +x *.sh

# Run native Claude benchmark (baseline comparison)
./run-benchmark.sh native

# Run devloop v2.4 baseline
./run-benchmark.sh baseline

# Run optimized devloop v3.x
./run-benchmark.sh optimized

# Run multiple iterations
./run-benchmark.sh native 3
```

## Variants

| Variant | Description |
|---------|-------------|
| `native` | Raw Claude Code, no plugins |
| `baseline` | Devloop v2.4.x from `devloop-v2.4-baseline` branch |
| `optimized` | Current devloop from `main` branch |
| `lite` | Devloop with `--quick` flag (minimal overhead) |

## Standard Task

All benchmarks use `task-fastify-api.md`:
- Fastify REST API with user CRUD
- JSON file persistence
- Mocha tests with coverage
- README documentation

## Results

Results are saved to `results/` directory:
- `{variant}-{timestamp}-run{n}.json` - Full Claude output
- `{variant}-{timestamp}-run{n}.log` - Stderr/debug output

## Metrics Tracked

- **Duration**: Wall clock time (seconds)
- **Files created**: Count of .js, .json, .md files
- **Lines of code**: Total JS lines (excluding node_modules)
- **Token usage**: From Claude response (input, output, cache)
- **Subagent count**: Number of Task tool invocations

## Extracting Detailed Metrics

```bash
# Find session ID from results
cat results/native-*.json | grep session_id

# Extract detailed metrics from Claude logs
./extract-metrics.sh <session-id> /path/to/project
```

## Comparing Results

After running benchmarks:

```bash
# Manual comparison
cat results/native-*.json | tail -20
cat results/optimized-*.json | tail -20
```

## Tips

1. **Clean state**: Each run creates a fresh temp directory
2. **Git branch switching**: Baseline variant switches branches temporarily
3. **Cost limits**: Max $50 per run (`--max-budget-usd 50`)
4. **Permissions**: Runs with `--dangerously-skip-permissions` for automation
