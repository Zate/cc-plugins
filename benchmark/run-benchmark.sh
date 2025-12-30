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
    
    # Run Claude based on variant
    case "$VARIANT" in
        native)
            echo "Running: native Claude (no plugins)"
            claude -p \
                --settings '{"enabledPlugins":{}}' \
                --dangerously-skip-permissions \
                --output-format json \
                --max-budget-usd 50 \
                "$task_content" > "$result_file" 2>"$log_file" || true
            ;;
        baseline)
            echo "Running: devloop baseline (v2.4.x with full hooks)"
            # Use baseline branch
            cd /home/zate/projects/cc-plugins
            git stash --quiet 2>/dev/null || true
            git checkout devloop-v2.4-baseline --quiet
            cd "$project_dir"
            
            claude -p \
                --plugin-dir "$PLUGIN_DIR" \
                --settings "{\"enabledPlugins\":{\"devloop@local\":true}}" \
                --dangerously-skip-permissions \
                --output-format json \
                --max-budget-usd 50 \
                "/devloop:onboard then $task_content" > "$result_file" 2>"$log_file" || true
            
            # Restore main branch
            cd /home/zate/projects/cc-plugins
            git checkout main --quiet
            git stash pop --quiet 2>/dev/null || true
            ;;
        optimized)
            echo "Running: devloop optimized (v3.x)"
            claude -p \
                --plugin-dir "$PLUGIN_DIR" \
                --settings "{\"enabledPlugins\":{\"devloop@local\":true}}" \
                --dangerously-skip-permissions \
                --output-format json \
                --max-budget-usd 50 \
                "/devloop $task_content" > "$result_file" 2>"$log_file" || true
            ;;
        lite)
            echo "Running: devloop lite mode"
            claude -p \
                --plugin-dir "$PLUGIN_DIR" \
                --settings "{\"enabledPlugins\":{\"devloop@local\":true}}" \
                --dangerously-skip-permissions \
                --output-format json \
                --max-budget-usd 50 \
                "/devloop --quick $task_content" > "$result_file" 2>"$log_file" || true
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
    
    # Extract metrics from result if possible
    echo ""
    echo "--- Results ---"
    echo "Duration: ${duration}s"
    echo "Files created: $file_count"
    echo "Lines of JS: $loc"
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
