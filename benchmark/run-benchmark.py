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
import shlex
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, asdict, field
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
class ClaudeCommand:
    """Builder for Claude CLI commands with proper shell escaping."""

    prompt: str
    output_file: Path
    cwd: Path

    # Flags
    verbose: bool = True
    output_format: str = "stream-json"
    dangerously_skip_permissions: bool = True
    max_budget_usd: int = 50
    strict_mcp_config: bool = True

    # Optional settings
    disallowed_tools: list[str] = field(default_factory=list)
    append_system_prompt: Optional[str] = None
    plugin_dir: Optional[Path] = None
    # Note: --settings flag causes hangs, avoid using it

    def _prompt_file(self) -> Path:
        """Path to temp file for prompt (avoids shell escaping issues)."""
        return self.cwd / ".claude-prompt.txt"

    def build_args(self) -> list[str]:
        """Build argument list (for display/logging)."""
        args = ["claude", "-p", "<prompt>"]

        if self.dangerously_skip_permissions:
            args.append("--dangerously-skip-permissions")
        if self.verbose:
            args.append("--verbose")
        if self.output_format:
            args.extend(["--output-format", self.output_format])
        if self.max_budget_usd:
            args.extend(["--max-budget-usd", str(self.max_budget_usd)])
        if self.strict_mcp_config:
            args.append("--strict-mcp-config")
        if self.disallowed_tools:
            args.extend(["--disallowedTools", ",".join(self.disallowed_tools)])
        if self.append_system_prompt:
            args.extend(["--append-system-prompt", self.append_system_prompt])
        if self.plugin_dir:
            args.extend(["--plugin-dir", str(self.plugin_dir)])

        return args

    def to_shell_command(self) -> str:
        """Build properly escaped shell command."""
        parts = ["claude", "-p", f'"$(cat {shlex.quote(str(self._prompt_file()))})"']

        if self.dangerously_skip_permissions:
            parts.append("--dangerously-skip-permissions")
        if self.verbose:
            parts.append("--verbose")
        if self.output_format:
            parts.extend(["--output-format", shlex.quote(self.output_format)])
        if self.max_budget_usd:
            parts.extend(["--max-budget-usd", str(self.max_budget_usd)])
        if self.strict_mcp_config:
            parts.append("--strict-mcp-config")
        if self.disallowed_tools:
            parts.extend(["--disallowedTools", shlex.quote(",".join(self.disallowed_tools))])
        if self.append_system_prompt:
            parts.extend(["--append-system-prompt", shlex.quote(self.append_system_prompt)])
        if self.plugin_dir:
            parts.extend(["--plugin-dir", shlex.quote(str(self.plugin_dir))])

        # Add redirects
        parts.append("< /dev/null")
        parts.append(f"> {shlex.quote(str(self.output_file))}")
        parts.append("2>&1")

        return " ".join(parts)

    def prepare(self) -> None:
        """Write prompt to temp file before execution."""
        self._prompt_file().write_text(self.prompt)

    def cleanup(self) -> None:
        """Remove temp files after execution."""
        prompt_file = self._prompt_file()
        if prompt_file.exists():
            prompt_file.unlink()


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
        project_dir = Path(tempfile.mkdtemp(prefix="devloop-bench-"))
        result_file = RESULTS_DIR / f"{self.variant}-{self.timestamp}-run{iteration}.json"

        print(f"\n{'=' * 50}")
        print(f"Run {iteration} of {self.iterations}")
        print(f"{'=' * 50}")
        print(f"📁 Project: {project_dir}")

        # Initialize git repo
        subprocess.run(["git", "init", "--quiet"], cwd=project_dir, check=True)
        (project_dir / "test").mkdir()

        # Load task and build command
        task_content = TASK_FILE.read_text()
        cmd = self._build_command(task_content, project_dir, result_file)

        print(f"🚀 Running: {self.variant}")
        print(f"📋 Args: {' '.join(cmd.build_args()[3:])}")
        print("-" * 50)

        start_time = time.time()
        claude_stats = self._run_claude(cmd)
        duration = time.time() - start_time

        if self.interrupted:
            return None

        print("-" * 50)

        # Collect metrics
        files = list(project_dir.rglob("*.js")) + \
                list(project_dir.rglob("*.json")) + \
                list(project_dir.rglob("*.md"))
        files = [f for f in files if "node_modules" not in str(f) and ".git" not in str(f)]

        loc = 0
        for f in project_dir.rglob("*.js"):
            if "node_modules" not in str(f):
                try:
                    loc += len(f.read_text().splitlines())
                except:
                    pass

        # Check if tests pass
        tests_pass = "unknown"
        if (project_dir / "package.json").exists():
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
            project_dir=str(project_dir),
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

    def _build_command(self, task_content: str, cwd: Path, output_file: Path) -> ClaudeCommand:
        """Build ClaudeCommand for the given variant."""
        base_kwargs = {
            "cwd": cwd,
            "output_file": output_file,
            # Don't block AskUserQuestion - rely on system prompt instead
            # Blocking it causes devloop commands to exit immediately
            "append_system_prompt": NO_QUESTIONS_PROMPT,
        }

        if self.variant == "native":
            # No plugin_dir = no plugins loaded (but global plugins still active)
            return ClaudeCommand(
                prompt=task_content,
                **base_kwargs,
            )
        elif self.variant == "optimized":
            # Use plain prompt with devloop plugin loaded
            # Slash commands don't work in -p mode, so just describe the task
            # and let Claude use the devloop skills/agents naturally
            return ClaudeCommand(
                prompt=f"Use the devloop workflow to complete this task:\n\n{task_content}",
                plugin_dir=PLUGIN_DIR,
                **base_kwargs,
            )
        elif self.variant == "baseline":
            # Also just load devloop and let it work naturally
            return ClaudeCommand(
                prompt=f"First run the devloop onboard workflow to understand the project, then complete this task:\n\n{task_content}",
                plugin_dir=PLUGIN_DIR,
                **base_kwargs,
            )
        elif self.variant == "lite":
            # Quick variant - use the quick implementation skill
            return ClaudeCommand(
                prompt=f"Use the devloop quick implementation workflow for this task:\n\n{task_content}",
                plugin_dir=PLUGIN_DIR,
                **base_kwargs,
            )
        else:
            raise ValueError(f"Unknown variant: {self.variant}")

    def _run_claude(self, cmd: ClaudeCommand) -> dict:
        """Run Claude and stream output with progress indicators."""
        stats = {}
        turn_count = 0

        print("🔄 Starting Claude...", flush=True)

        # Prepare the command (write prompt to temp file)
        cmd.prepare()

        try:
            # Build and run shell command
            shell_cmd = cmd.to_shell_command()
            print(f"   📝 Output: {cmd.output_file}", flush=True)

            process = subprocess.Popen(
                shell_cmd,
                shell=True,
                cwd=cmd.cwd,
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )

            print(f"   PID: {process.pid}", flush=True)

            # Tail the output file for progress
            last_size = 0
            last_activity = time.time()
            timeout_seconds = 1800  # 30 minutes
            processed_lines = 0

            while process.poll() is None:
                # Check for interrupt
                if self.interrupted:
                    process.terminate()
                    break

                # Check timeout
                if time.time() - last_activity > timeout_seconds:
                    print(f"\n⚠️  Timeout after {timeout_seconds}s")
                    process.kill()
                    break

                # Check for new content
                if cmd.output_file.exists():
                    current_size = cmd.output_file.stat().st_size
                    if current_size > last_size:
                        last_activity = time.time()
                        last_size = current_size

                        # Read and process new lines
                        with open(cmd.output_file, "r") as f:
                            lines = f.readlines()
                            for line in lines[processed_lines:]:
                                processed_lines += 1
                                line = line.strip()
                                if not line:
                                    continue

                                try:
                                    data = json.loads(line)
                                    msg_type = data.get("type")

                                    if msg_type == "system":
                                        print(f"   ✓ Initialized", flush=True)

                                    elif msg_type == "assistant":
                                        turn_count += 1
                                        # Extract tool uses from message content
                                        message = data.get("message", {})
                                        content = message.get("content", [])
                                        tools_used = []
                                        for item in content:
                                            if isinstance(item, dict):
                                                if item.get("type") == "tool_use":
                                                    tools_used.append(item.get("name", "?"))
                                                elif item.get("type") == "text":
                                                    # Show brief text if no tools
                                                    pass
                                        if tools_used:
                                            print(f"\n📍 Turn {turn_count}: 🔧 {', '.join(tools_used)}", flush=True)
                                        else:
                                            print(f"\n📍 Turn {turn_count}", flush=True)

                                    elif msg_type == "user":
                                        # Tool results come as user messages
                                        message = data.get("message", {})
                                        content = message.get("content", [])
                                        for item in content:
                                            if isinstance(item, dict) and item.get("type") == "tool_result":
                                                is_error = item.get("is_error", False)
                                                tool_id = item.get("tool_use_id", "")[:8]
                                                result_preview = str(item.get("content", ""))[:40]
                                                if is_error:
                                                    print(f"   ❌ {result_preview}...", flush=True)
                                                else:
                                                    print(f"   ✓ {result_preview}...", flush=True)

                                    elif msg_type == "result":
                                        stats["total_cost_usd"] = data.get("total_cost_usd")
                                        stats["num_turns"] = data.get("num_turns")
                                        usage = data.get("usage", {})
                                        stats["total_input_tokens"] = usage.get("input_tokens")
                                        stats["total_output_tokens"] = usage.get("output_tokens")

                                except json.JSONDecodeError:
                                    if "error" in line.lower():
                                        print(f"   ⚠️  {line[:60]}", flush=True)

                time.sleep(0.5)  # Poll every 500ms

            # Process any remaining lines after exit
            process.wait()
            if cmd.output_file.exists():
                with open(cmd.output_file, "r") as f:
                    for line in f.readlines()[processed_lines:]:
                        line = line.strip()
                        if line:
                            try:
                                data = json.loads(line)
                                if data.get("type") == "result":
                                    stats["total_cost_usd"] = data.get("total_cost_usd")
                                    stats["num_turns"] = data.get("num_turns")
                                    usage = data.get("usage", {})
                                    stats["total_input_tokens"] = usage.get("input_tokens")
                                    stats["total_output_tokens"] = usage.get("output_tokens")
                            except:
                                pass

        except Exception as e:
            print(f"\n⚠️  Error: {e}")
        finally:
            cmd.cleanup()

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
