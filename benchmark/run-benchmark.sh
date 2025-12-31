#!/bin/bash
# Benchmark runner for devloop plugin variants
# Usage: ./run-benchmark.sh <variant> [iterations]
# Variants: baseline, optimized, lite, native

set -euo pipefail

VARIANT="${1:-native}"
ITERATIONS="${2:-1}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"
TASK_FILE="$SCRIPT_DIR/task-fastify-api.md"
PROGRESS_PARSER="$SCRIPT_DIR/parse-progress.sh"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
PLUGIN_DIR="/home/zate/projects/cc-plugins/plugins/devloop"

# System prompt addition to prevent questions
NO_QUESTIONS_PROMPT="CRITICAL: Never use AskUserQuestion tool. Never ask for clarification. Make reasonable assumptions and proceed. Complete the entire task autonomously."

mkdir -p "$RESULTS_DIR"

echo "========================================"
echo "Devloop Benchmark Runner"
echo "========================================"
echo "Variant: $VARIANT"
echo "Iterations: $ITERATIONS"
echo "Timestamp: $TIMESTAMP"
echo "========================================"

run_single_benchmark() {
    local iteration=$1
    local project_dir=$(mktemp -d -t devloop-bench-XXXXXX)
    local result_file="$RESULTS_DIR/${VARIANT}-${TIMESTAMP}-run${iteration}.json"
    local log_file="$RESULTS_DIR/${VARIANT}-${TIMESTAMP}-run${iteration}.log"
    
    echo ""
    echo "=== Run $iteration of $ITERATIONS ==="
    echo "Project dir: $project_dir"
    echo "Result file: $result_file"
    
    cd "$project_dir"
    
    # Initialize basic structure
    git init --quiet
    mkdir -p test
    
    local start_time=$(date +%s.%N)
    local task_content
    task_content=$(cat "$TASK_FILE")
    
    # Timeout in seconds (30 minutes should be plenty)
    local TIMEOUT=1800
    
    # Clear result file
    > "$result_file"
    
    # Run Claude based on variant
    # NOTE: -p "prompt" must come first, then other flags after
    # Using stream-json for live progress, piped through parser
    case "$VARIANT" in
        native)
            echo "Running: native Claude (no plugins)"
            echo ""
            timeout "$TIMEOUT" claude -p "$task_content" \
                --dangerously-skip-permissions \
                --output-format stream-json \
                --max-budget-usd 50 \
                --disallowedTools "AskUserQuestion" \
                --append-system-prompt "$NO_QUESTIONS_PROMPT" \
                --strict-mcp-config \
                --settings '{"enabledPlugins":{}}' \
                2>"$log_file" | "$PROGRESS_PARSER" "$result_file" || true
            ;;
        baseline)
            echo "Running: devloop baseline (v2.4.x with full hooks)"
            echo ""
            # Use baseline branch
            cd /home/zate/projects/cc-plugins
            git stash --quiet 2>/dev/null || true
            git checkout devloop-v2.4-baseline --quiet
            cd "$project_dir"
            
            timeout "$TIMEOUT" claude -p "/devloop:onboard then $task_content" \
                --dangerously-skip-permissions \
                --output-format stream-json \
                --max-budget-usd 50 \
                --disallowedTools "AskUserQuestion" \
                --append-system-prompt "$NO_QUESTIONS_PROMPT" \
                --strict-mcp-config \
                --plugin-dir "$PLUGIN_DIR" \
                --settings "{\"enabledPlugins\":{\"devloop@local\":true}}" \
                2>"$log_file" | "$PROGRESS_PARSER" "$result_file" || true
            
            # Restore main branch
            cd /home/zate/projects/cc-plugins
            git checkout main --quiet
            git stash pop --quiet 2>/dev/null || true
            ;;
        optimized)
            echo "Running: devloop optimized (v3.x)"
            echo ""
            timeout "$TIMEOUT" claude -p "/devloop $task_content" \
                --dangerously-skip-permissions \
                --output-format stream-json \
                --max-budget-usd 50 \
                --disallowedTools "AskUserQuestion" \
                --append-system-prompt "$NO_QUESTIONS_PROMPT" \
                --strict-mcp-config \
                --plugin-dir "$PLUGIN_DIR" \
                --settings "{\"enabledPlugins\":{\"devloop@local\":true}}" \
                2>"$log_file" | "$PROGRESS_PARSER" "$result_file" || true
            ;;
        lite)
            echo "Running: devloop lite mode"
            echo ""
            timeout "$TIMEOUT" claude -p "/devloop:quick $task_content" \
                --dangerously-skip-permissions \
                --output-format stream-json \
                --max-budget-usd 50 \
                --disallowedTools "AskUserQuestion" \
                --append-system-prompt "$NO_QUESTIONS_PROMPT" \
                --strict-mcp-config \
                --plugin-dir "$PLUGIN_DIR" \
                --settings "{\"enabledPlugins\":{\"devloop@local\":true}}" \
                2>"$log_file" | "$PROGRESS_PARSER" "$result_file" || true
            ;;
        *)
            echo "Unknown variant: $VARIANT"
            exit 1
            ;;
    esac
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    # Count produced files
    local file_count=$(find "$project_dir" -type f \( -name "*.js" -o -name "*.json" -o -name "*.md" \) ! -path "*node_modules*" ! -path "*.git*" 2>/dev/null | wc -l)
    local loc=$(find "$project_dir" -type f -name "*.js" ! -path "*node_modules*" 2>/dev/null -exec cat {} \; 2>/dev/null | wc -l || echo "0")
    
    # Check if tests pass
    local tests_pass="unknown"
    if [ -f "$project_dir/package.json" ]; then
        cd "$project_dir"
        if npm test > /dev/null 2>&1; then
            tests_pass="true"
        else
            tests_pass="false"
        fi
    fi
    
    # Extract metrics from result if possible
    echo ""
    echo "--- Results ---"
    echo "Duration: ${duration}s"
    echo "Files created: $file_count"
    echo "Lines of JS: $loc"
    echo "Tests pass: $tests_pass"
    echo "Project: $project_dir"
    
    # Append summary to result file
    cat >> "$result_file" <<EOF

--- BENCHMARK METADATA ---
{
  "variant": "$VARIANT",
  "iteration": $iteration,
  "timestamp": "$TIMESTAMP",
  "duration_seconds": $duration,
  "files_created": $file_count,
  "lines_of_code": $loc,
  "tests_pass": "$tests_pass",
  "project_dir": "$project_dir"
}
EOF
    
    echo "Full output saved to: $result_file"
}

# Run benchmarks
for i in $(seq 1 $ITERATIONS); do
    run_single_benchmark "$i"
done

echo ""
echo "========================================"
echo "Benchmark Complete"
echo "========================================"
echo "Results directory: $RESULTS_DIR"
echo "Files:"
ls -la "$RESULTS_DIR"/${VARIANT}-${TIMESTAMP}* 2>/dev/null || echo "No results found"
