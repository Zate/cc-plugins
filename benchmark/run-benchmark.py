#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
Devloop Benchmark Runner

Usage:
    ./run-benchmark.py native           # Run native Claude (no plugins)
    ./run-benchmark.py optimized        # Run devloop v3.x
    ./run-benchmark.py baseline         # Run devloop v2.4.x
    ./run-benchmark.py native 3         # Run 3 iterations
    ./run-benchmark.py --compare        # Compare all results
"""

import subprocess
import sys
import os
import json
import time
import signal
import tempfile
import shutil
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, asdict
from typing import Optional

# Paths
SCRIPT_DIR = Path(__file__).parent.resolve()
RESULTS_DIR = SCRIPT_DIR / "results"
TASK_FILE = SCRIPT_DIR / "task-fastify-api.md"
PLUGIN_DIR = Path("/home/zate/projects/cc-plugins/plugins/devloop")

NO_QUESTIONS_PROMPT = (
    "CRITICAL: Never use AskUserQuestion tool. Never ask for clarification. "
    "Make reasonable assumptions and proceed. Complete the entire task autonomously."
)


@dataclass
class BenchmarkResult:
    variant: str
    iteration: int
    timestamp: str
    duration_seconds: float
    files_created: int
    lines_of_code: int
    tests_pass: str
    project_dir: str
    # From Claude's output
    total_cost_usd: Optional[float] = None
    total_input_tokens: Optional[int] = None
    total_output_tokens: Optional[int] = None
    num_turns: Optional[int] = None


class BenchmarkRunner:
    def __init__(self, variant: str, iterations: int = 1):
        self.variant = variant
        self.iterations = iterations
        self.timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        self.interrupted = False
        
        # Handle Ctrl-C gracefully
        signal.signal(signal.SIGINT, self._handle_interrupt)
        signal.signal(signal.SIGTERM, self._handle_interrupt)
    
    def _handle_interrupt(self, signum, frame):
        print("\n\n⚠️  Interrupted! Cleaning up...")
        self.interrupted = True
    
    def run(self):
        RESULTS_DIR.mkdir(exist_ok=True)
        
        print("=" * 50)
        print("Devloop Benchmark Runner")
        print("=" * 50)
        print(f"Variant:    {self.variant}")
        print(f"Iterations: {self.iterations}")
        print(f"Timestamp:  {self.timestamp}")
        print("=" * 50)
        
        results = []
        for i in range(1, self.iterations + 1):
            if self.interrupted:
                break
            result = self._run_single(i)
            if result:
                results.append(result)
                self._save_result(result)
        
        if results:
            self._print_summary(results)
        
        return results
    
    def _run_single(self, iteration: int) -> Optional[BenchmarkResult]:
        # Create temp project directory
        project_dir = tempfile.mkdtemp(prefix="devloop-bench-")
        result_file = RESULTS_DIR / f"{self.variant}-{self.timestamp}-run{iteration}.json"
        
        print(f"\n{'=' * 50}")
        print(f"Run {iteration} of {self.iterations}")
        print(f"{'=' * 50}")
        print(f"📁 Project: {project_dir}")
        
        # Initialize git repo
        subprocess.run(["git", "init", "--quiet"], cwd=project_dir, check=True)
        Path(project_dir, "test").mkdir()
        
        # Load task
        task_content = TASK_FILE.read_text()
        
        # Build command based on variant
        cmd = self._build_command(task_content)
        
        print(f"🚀 Running: {self.variant}")
        print("-" * 50)
        
        start_time = time.time()
        claude_stats = self._run_claude(cmd, project_dir, result_file)
        duration = time.time() - start_time
        
        if self.interrupted:
            return None
        
        print("-" * 50)
        
        # Collect metrics
        files = list(Path(project_dir).rglob("*.js")) + \
                list(Path(project_dir).rglob("*.json")) + \
                list(Path(project_dir).rglob("*.md"))
        files = [f for f in files if "node_modules" not in str(f) and ".git" not in str(f)]
        
        loc = 0
        for f in Path(project_dir).rglob("*.js"):
            if "node_modules" not in str(f):
                try:
                    loc += len(f.read_text().splitlines())
                except:
                    pass
        
        # Check if tests pass
        tests_pass = "unknown"
        if Path(project_dir, "package.json").exists():
            try:
                result = subprocess.run(
                    ["npm", "test"],
                    cwd=project_dir,
                    capture_output=True,
                    timeout=60
                )
                tests_pass = "true" if result.returncode == 0 else "false"
            except:
                tests_pass = "error"
        
        result = BenchmarkResult(
            variant=self.variant,
            iteration=iteration,
            timestamp=self.timestamp,
            duration_seconds=round(duration, 2),
            files_created=len(files),
            lines_of_code=loc,
            tests_pass=tests_pass,
            project_dir=project_dir,
            **claude_stats
        )
        
        print(f"\n✅ Complete!")
        print(f"   ⏱️  Duration: {duration:.1f}s")
        print(f"   📄 Files: {len(files)}")
        print(f"   📝 LOC: {loc}")
        print(f"   🧪 Tests: {tests_pass}")
        if claude_stats.get("total_cost_usd"):
            print(f"   💰 Cost: ${claude_stats['total_cost_usd']:.4f}")
        if claude_stats.get("num_turns"):
            print(f"   🔄 Turns: {claude_stats['num_turns']}")
        
        return result
    
    def _build_command(self, task_content: str) -> list[str]:
        base_flags = [
            "--dangerously-skip-permissions",
            "--output-format", "stream-json",
            "--max-budget-usd", "50",
            "--disallowedTools", "AskUserQuestion",
            "--append-system-prompt", NO_QUESTIONS_PROMPT,
            "--strict-mcp-config",
        ]
        
        if self.variant == "native":
            return [
                "claude", "-p", task_content,
                *base_flags,
                "--settings", '{"enabledPlugins":{}}',
            ]
        elif self.variant == "optimized":
            return [
                "claude", "-p", f"/devloop {task_content}",
                *base_flags,
                "--plugin-dir", str(PLUGIN_DIR),
                "--settings", '{"enabledPlugins":{"devloop@local":true}}',
            ]
        elif self.variant == "baseline":
            return [
                "claude", "-p", f"/devloop:onboard then {task_content}",
                *base_flags,
                "--plugin-dir", str(PLUGIN_DIR),
                "--settings", '{"enabledPlugins":{"devloop@local":true}}',
            ]
        elif self.variant == "lite":
            return [
                "claude", "-p", f"/devloop:quick {task_content}",
                *base_flags,
                "--plugin-dir", str(PLUGIN_DIR),
                "--settings", '{"enabledPlugins":{"devloop@local":true}}',
            ]
        else:
            raise ValueError(f"Unknown variant: {self.variant}")
    
    def _run_claude(self, cmd: list[str], cwd: str, result_file: Path) -> dict:
        """Run Claude and stream output with progress indicators."""
        stats = {}
        turn_count = 0
        current_tool = None
        
        with open(result_file, "w") as f:
            process = subprocess.Popen(
                cmd,
                cwd=cwd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1,  # Line buffered
            )
            
            try:
                for line in process.stdout:
                    # Save raw line
                    f.write(line)
                    f.flush()
                    
                    # Parse for progress
                    line = line.strip()
                    if not line:
                        continue
                    
                    try:
                        data = json.loads(line)
                        msg_type = data.get("type")
                        
                        if msg_type == "assistant":
                            turn_count += 1
                            print(f"\n📍 Turn {turn_count}")
                        
                        elif msg_type == "tool_use":
                            current_tool = data.get("name", "unknown")
                            print(f"   🔧 {current_tool}...", end="", flush=True)
                        
                        elif msg_type == "tool_result":
                            is_error = data.get("is_error", False)
                            if is_error:
                                print(f" ❌")
                            else:
                                print(f" ✓")
                            current_tool = None
                        
                        elif msg_type == "result":
                            # Extract final stats
                            stats["total_cost_usd"] = data.get("total_cost_usd")
                            stats["num_turns"] = data.get("num_turns")
                            usage = data.get("usage", {})
                            stats["total_input_tokens"] = usage.get("input_tokens")
                            stats["total_output_tokens"] = usage.get("output_tokens")
                    
                    except json.JSONDecodeError:
                        # Not JSON, just print it
                        if line and not line.startswith("{"):
                            print(f"   {line[:80]}")
                
                process.wait(timeout=1800)
                
            except subprocess.TimeoutExpired:
                print("\n⚠️  Timeout!")
                process.kill()
            except Exception as e:
                print(f"\n⚠️  Error: {e}")
                process.kill()
        
        return stats
    
    def _save_result(self, result: BenchmarkResult):
        """Save result as JSON."""
        result_file = RESULTS_DIR / f"{result.variant}-{result.timestamp}-run{result.iteration}-summary.json"
        with open(result_file, "w") as f:
            json.dump(asdict(result), f, indent=2)
        print(f"   💾 Saved: {result_file.name}")
    
    def _print_summary(self, results: list[BenchmarkResult]):
        """Print summary of all runs."""
        print(f"\n{'=' * 50}")
        print("Summary")
        print(f"{'=' * 50}")
        
        durations = [r.duration_seconds for r in results]
        costs = [r.total_cost_usd for r in results if r.total_cost_usd]
        
        print(f"Runs: {len(results)}")
        print(f"Avg Duration: {sum(durations)/len(durations):.1f}s")
        if costs:
            print(f"Avg Cost: ${sum(costs)/len(costs):.4f}")
        print(f"Results: {RESULTS_DIR}")


def compare_results():
    """Compare all benchmark results."""
    print("=" * 60)
    print("Benchmark Comparison")
    print("=" * 60)
    
    # Find all summary files
    summaries = list(RESULTS_DIR.glob("*-summary.json"))
    if not summaries:
        print("No results found. Run some benchmarks first.")
        return
    
    # Group by variant
    by_variant: dict[str, list[dict]] = {}
    for f in summaries:
        data = json.loads(f.read_text())
        variant = data["variant"]
        if variant not in by_variant:
            by_variant[variant] = []
        by_variant[variant].append(data)
    
    # Print comparison table
    print(f"\n{'Variant':<12} {'Runs':<6} {'Avg Time':<10} {'Avg Cost':<12} {'Tests Pass':<12}")
    print("-" * 60)
    
    for variant, runs in sorted(by_variant.items()):
        avg_time = sum(r["duration_seconds"] for r in runs) / len(runs)
        costs = [r["total_cost_usd"] for r in runs if r.get("total_cost_usd")]
        avg_cost = sum(costs) / len(costs) if costs else 0
        tests = sum(1 for r in runs if r["tests_pass"] == "true")
        
        print(f"{variant:<12} {len(runs):<6} {avg_time:>7.1f}s   ${avg_cost:>8.4f}     {tests}/{len(runs)}")
    
    # Calculate ratios if we have native baseline
    if "native" in by_variant and len(by_variant) > 1:
        native_avg = sum(r["duration_seconds"] for r in by_variant["native"]) / len(by_variant["native"])
        native_costs = [r["total_cost_usd"] for r in by_variant["native"] if r.get("total_cost_usd")]
        native_cost = sum(native_costs) / len(native_costs) if native_costs else 0
        
        print(f"\n{'Variant':<12} {'Time vs Native':<16} {'Cost vs Native':<16}")
        print("-" * 45)
        
        for variant, runs in sorted(by_variant.items()):
            if variant == "native":
                continue
            avg_time = sum(r["duration_seconds"] for r in runs) / len(runs)
            costs = [r["total_cost_usd"] for r in runs if r.get("total_cost_usd")]
            avg_cost = sum(costs) / len(costs) if costs else 0
            
            time_ratio = avg_time / native_avg if native_avg else 0
            cost_ratio = avg_cost / native_cost if native_cost else 0
            
            print(f"{variant:<12} {time_ratio:>6.2f}x          {cost_ratio:>6.2f}x")


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    
    if sys.argv[1] == "--compare":
        compare_results()
        return
    
    variant = sys.argv[1]
    iterations = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    
    if variant not in ["native", "optimized", "baseline", "lite"]:
        print(f"Unknown variant: {variant}")
        print("Valid variants: native, optimized, baseline, lite")
        sys.exit(1)
    
    runner = BenchmarkRunner(variant, iterations)
    runner.run()


if __name__ == "__main__":
    main()
