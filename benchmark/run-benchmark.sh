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
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
PLUGIN_DIR="/home/zate/projects/cc-plugins/plugins/devloop"

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
    local result_file="$RESULTS_DIR/${VARIANT}-${TIMESTAMP}-run${iteration}.txt"
    
    echo ""
    echo "=== Run $iteration of $ITERATIONS ==="
    echo "Project dir: $project_dir"
    
    cd "$project_dir"
    git init --quiet
    mkdir -p test
    
    local start_time=$(date +%s.%N)
    local task_content
    task_content=$(cat "$TASK_FILE")
    
    local TIMEOUT=1800
    
    echo ""
    echo "Running Claude... (Ctrl-C to abort)"
    echo "----------------------------------------"
    
    # Run Claude - use text output, no pipes, direct to terminal + file
    # The key: no complex piping that causes buffering issues
    case "$VARIANT" in
        native)
            timeout "$TIMEOUT" claude -p "$task_content" \
                --dangerously-skip-permissions \
                --max-budget-usd 50 \
                --disallowedTools "AskUserQuestion" \
                --append-system-prompt "$NO_QUESTIONS_PROMPT" \
                --strict-mcp-config \
                --settings '{"enabledPlugins":{}}' \
                | tee "$result_file" || true
            ;;
        baseline)
            cd /home/zate/projects/cc-plugins
            git stash --quiet 2>/dev/null || true
            git checkout devloop-v2.4-baseline --quiet
            cd "$project_dir"
            
            timeout "$TIMEOUT" claude -p "/devloop:onboard then $task_content" \
                --dangerously-skip-permissions \
                --max-budget-usd 50 \
                --disallowedTools "AskUserQuestion" \
                --append-system-prompt "$NO_QUESTIONS_PROMPT" \
                --strict-mcp-config \
                --plugin-dir "$PLUGIN_DIR" \
                --settings '{"enabledPlugins":{"devloop@local":true}}' \
                | tee "$result_file" || true
            
            cd /home/zate/projects/cc-plugins
            git checkout main --quiet
            git stash pop --quiet 2>/dev/null || true
            ;;
        optimized)
            timeout "$TIMEOUT" claude -p "/devloop $task_content" \
                --dangerously-skip-permissions \
                --max-budget-usd 50 \
                --disallowedTools "AskUserQuestion" \
                --append-system-prompt "$NO_QUESTIONS_PROMPT" \
                --strict-mcp-config \
                --plugin-dir "$PLUGIN_DIR" \
                --settings '{"enabledPlugins":{"devloop@local":true}}' \
                | tee "$result_file" || true
            ;;
        lite)
            timeout "$TIMEOUT" claude -p "/devloop:quick $task_content" \
                --dangerously-skip-permissions \
                --max-budget-usd 50 \
                --disallowedTools "AskUserQuestion" \
                --append-system-prompt "$NO_QUESTIONS_PROMPT" \
                --strict-mcp-config \
                --plugin-dir "$PLUGIN_DIR" \
                --settings '{"enabledPlugins":{"devloop@local":true}}' \
                | tee "$result_file" || true
            ;;
        *)
            echo "Unknown variant: $VARIANT"
            exit 1
            ;;
    esac
    
    echo "----------------------------------------"
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    local file_count=$(find "$project_dir" -type f \( -name "*.js" -o -name "*.json" -o -name "*.md" \) ! -path "*node_modules*" ! -path "*.git*" 2>/dev/null | wc -l)
    local loc=$(find "$project_dir" -type f -name "*.js" ! -path "*node_modules*" 2>/dev/null -exec cat {} \; 2>/dev/null | wc -l || echo "0")
    
    local tests_pass="unknown"
    if [ -f "$project_dir/package.json" ]; then
        cd "$project_dir"
        npm test > /dev/null 2>&1 && tests_pass="true" || tests_pass="false"
    fi
    
    echo ""
    echo "=== Results ==="
    echo "Duration: ${duration}s"
    echo "Files: $file_count"
    echo "JS LOC: $loc"
    echo "Tests: $tests_pass"
    echo "Project: $project_dir"
}

for i in $(seq 1 $ITERATIONS); do
    run_single_benchmark "$i"
done

echo ""
echo "Done! Results in: $RESULTS_DIR"
