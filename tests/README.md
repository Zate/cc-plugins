# CC-Plugins Test Suite

Comprehensive testing framework for Claude Code plugins, adapted from the [superpowers](https://github.com/anthropics/superpowers) testing methodology.

## Quick Start

```bash
# Run fast tests (no Claude Code required)
./tests/run-tests.sh

# Run all tests including Claude Code integration
./tests/run-tests.sh --all

# Run with verbose output
./tests/run-tests.sh --all --verbose
```

## Test Categories

### 1. Fast Tests (No Dependencies)

Tests that validate plugin structure without invoking Claude Code:

- **Devloop Plugin Tests**: Command frontmatter validation, skill structure checks
- **Plugin Structure Tests**: Validate plugin.json, directory organization

```bash
./tests/run-tests.sh
```

### 2. Explicit Skill Request Tests

Tests that skills are correctly invoked when explicitly named by the user (e.g., "use the devloop skill"):

```bash
./tests/run-tests.sh --explicit-skills

# Or run individually
./tests/explicit-skill-requests/run-test.sh devloop:devloop prompts/devloop-explicit.txt 5
```

### 3. Skill Triggering Tests

Tests that skills auto-detect from context WITHOUT explicit mention of the skill name:

```bash
./tests/run-tests.sh --skill-triggering

# Or run individually
./tests/skill-triggering/run-test.sh devloop:devloop prompts/start-feature-work.txt 5
```

### 4. Integration Tests

Full workflow tests requiring Claude Code CLI:

```bash
./tests/run-tests.sh --integration
```

## Token Analysis

All integration tests save sessions as JSONL files to `/tmp/cc-plugins-tests/TIMESTAMP/`.

### Analyze All Sessions from a Test Run

```bash
# Analyze most recent test run
./tests/claude-code/analyze-all-sessions.sh

# List available test runs
./tests/claude-code/analyze-all-sessions.sh --list

# Output as JSON
./tests/claude-code/analyze-all-sessions.sh --json

# Analyze specific test run
./tests/claude-code/analyze-all-sessions.sh /tmp/cc-plugins-tests/20260116_181200
```

### Analyze Individual Sessions

```bash
python3 tests/claude-code/analyze-token-usage.py /path/to/session.jsonl

# Output as JSON for programmatic use
python3 tests/claude-code/analyze-token-usage.py --json /path/to/session.jsonl

# Use Opus pricing ($15/$75 per M instead of $3/$15)
python3 tests/claude-code/analyze-token-usage.py --opus /path/to/session.jsonl
```

Example output:
```
==============================================================================================================
TOKEN USAGE ANALYSIS
==============================================================================================================

Usage Breakdown:
--------------------------------------------------------------------------------------------------------------
Agent           Type         Description                    Msgs      Input     Output      Cache     Cost
--------------------------------------------------------------------------------------------------------------
main            coordinator  Main session                     12     45,234      8,123     32,456    $0.28
abc1234         Explore      Exploring codebase                3     12,456      2,345      8,123    $0.08
def5678         Plan         Planning implementation           2      8,234      3,456      4,567    $0.06
--------------------------------------------------------------------------------------------------------------

TOTALS:
  Total messages:         17
  Total tool calls:       28
  Input tokens:           65,924
  Output tokens:          13,924
  Cache creation tokens:  12,345
  Cache read tokens:      45,146

  Total input (incl cache): 123,415
  Total tokens:             137,339

  Estimated cost: $0.42
  (at $3/$15 per M tokens for input/output - Sonnet rates)
```

## Directory Structure

```
tests/
├── README.md                           # This file
├── run-tests.sh                        # Main test runner
├── claude-code/
│   ├── analyze-token-usage.py          # Token analysis tool
│   └── test-helpers.sh                 # Bash assertion library
├── explicit-skill-requests/
│   ├── run-test.sh                     # Test runner for explicit invocations
│   ├── run-all.sh                      # Run all explicit skill tests
│   └── prompts/                        # Test prompts that name skills
│       ├── devloop-explicit.txt
│       ├── continue-explicit.txt
│       └── ...
├── skill-triggering/
│   ├── run-test.sh                     # Test runner for auto-triggering
│   ├── run-all.sh                      # Run all triggering tests
│   └── prompts/                        # Test prompts that DON'T name skills
│       ├── start-feature-work.txt
│       ├── need-to-explore.txt
│       └── ...
└── e2e/                                # End-to-end workflow tests
    └── (future tests)
```

## Writing New Tests

### Adding an Explicit Skill Test

1. Create a prompt file in `explicit-skill-requests/prompts/`:
   ```
   Use the my-skill skill to do something.
   ```

2. Add the test to `explicit-skill-requests/run-all.sh`:
   ```bash
   TESTS=(
       ...
       "plugin:my-skill:prompts/my-skill-explicit.txt:5"
   )
   ```

### Adding a Skill Triggering Test

1. Create a prompt file in `skill-triggering/prompts/` that describes the task WITHOUT mentioning the skill:
   ```
   I need to understand how the authentication system works in this project
   before I make any changes. Can you help me investigate?
   ```

2. Add the test to `skill-triggering/run-all.sh`:
   ```bash
   TESTS=(
       ...
       "plugin:spike:prompts/investigate-auth.txt:5"
   )
   ```

### Using Test Helpers

The `test-helpers.sh` provides assertion functions:

```bash
source tests/claude-code/test-helpers.sh

# Run Claude and capture output
output=$(run_claude "Your prompt here" 60)

# Assertions
assert_contains "$output" "expected text" "Test name"
assert_not_contains "$output" "unexpected" "Test name"
assert_count "$output" "pattern" 3 "Test name"
assert_order "$output" "first" "second" "Test name"

# File assertions
assert_file_contains "path/to/file" "pattern" "Test name"
assert_skill_invoked "output.json" "skill-name" "Test name"

# Print summary
print_summary
```

## Test Output

Test results are saved to `/tmp/cc-plugins-tests/TIMESTAMP/`:

```
/tmp/cc-plugins-tests/20260116_181200/
├── explicit-skill-requests/
│   └── devloop___devloop/
│       ├── prompt.txt
│       └── claude-output.json
└── skill-triggering/
    └── devloop___devloop/
        ├── prompt.txt
        └── claude-output.json
```

Use `analyze-token-usage.py` on any `claude-output.json` file to see token breakdown.

## CI/CD Integration

For CI pipelines, use exit codes:

```bash
# Exit 0 on success, 1 on failure
./tests/run-tests.sh --all

# Machine-readable JSON output for token analysis
python3 tests/claude-code/analyze-token-usage.py --json session.jsonl > report.json
```

## Comparison with Superpowers

This test suite is adapted from the superpowers project with the following customizations:

| Feature | Superpowers | CC-Plugins |
|---------|-------------|------------|
| Token Analysis | ✅ | ✅ (adapted) |
| Explicit Skill Tests | ✅ | ✅ |
| Skill Triggering Tests | ✅ | ✅ |
| E2E Workflow Tests | ✅ | 🚧 (planned) |
| Plugin Structure Tests | ❌ | ✅ |
| Bash Test Helpers | ✅ | ✅ (extended) |

## Troubleshooting

### "Claude Code CLI not available"

Install Claude Code or add it to PATH:
```bash
# Check if installed
which claude

# If not, follow Claude Code installation instructions
```

### Tests hang or timeout

Increase the timeout in individual test scripts:
```bash
./tests/explicit-skill-requests/run-test.sh skill-name prompts/file.txt 10  # 10 turns max
```

### Flaky auto-triggering tests

Skill auto-detection depends on Claude's interpretation. If tests are flaky:
1. Make prompts more distinctive
2. Ensure prompts don't accidentally mention skill names
3. Consider the test informational rather than blocking
