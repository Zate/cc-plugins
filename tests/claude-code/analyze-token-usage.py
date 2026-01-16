#!/usr/bin/env python3
"""
Analyze token usage from Claude Code session transcripts.
Breaks down usage by main session and individual subagents.

Adapted from superpowers for cc-plugins testing.

Usage:
    python3 analyze-token-usage.py <session-file.jsonl>
    python3 analyze-token-usage.py --json <session-file.jsonl>  # Output as JSON
"""

import json
import sys
from pathlib import Path
from collections import defaultdict
from typing import Dict, Any, Tuple
import argparse


def analyze_main_session(filepath: str) -> Tuple[Dict[str, Any], Dict[str, Dict[str, Any]]]:
    """Analyze a session file and return token usage broken down by agent."""
    main_usage = {
        'input_tokens': 0,
        'output_tokens': 0,
        'cache_creation': 0,
        'cache_read': 0,
        'messages': 0,
        'tool_calls': 0
    }

    # Track usage per subagent
    subagent_usage = defaultdict(lambda: {
        'input_tokens': 0,
        'output_tokens': 0,
        'cache_creation': 0,
        'cache_read': 0,
        'messages': 0,
        'description': None,
        'type': None
    })

    # Track skill invocations
    skill_invocations = []

    with open(filepath, 'r') as f:
        for line in f:
            try:
                data = json.loads(line)

                # Main session assistant messages
                if data.get('type') == 'assistant' and 'message' in data:
                    main_usage['messages'] += 1
                    msg = data['message']
                    msg_usage = msg.get('usage', {})
                    main_usage['input_tokens'] += msg_usage.get('input_tokens', 0)
                    main_usage['output_tokens'] += msg_usage.get('output_tokens', 0)
                    main_usage['cache_creation'] += msg_usage.get('cache_creation_input_tokens', 0)
                    main_usage['cache_read'] += msg_usage.get('cache_read_input_tokens', 0)

                    # Count tool calls
                    content = msg.get('content', [])
                    for block in content:
                        if block.get('type') == 'tool_use':
                            main_usage['tool_calls'] += 1
                            # Track skill invocations
                            if block.get('name') == 'Skill':
                                inp = block.get('input', {})
                                skill_invocations.append({
                                    'skill': inp.get('skill'),
                                    'args': inp.get('args')
                                })

                # Subagent tool results
                if data.get('type') == 'user' and 'toolUseResult' in data:
                    result = data['toolUseResult']
                    if 'usage' in result and 'agentId' in result:
                        agent_id = result['agentId']
                        usage = result['usage']

                        # Get description and type from result
                        if subagent_usage[agent_id]['description'] is None:
                            desc = result.get('description', '')
                            subagent_usage[agent_id]['description'] = desc[:60] if desc else f"agent-{agent_id}"
                            subagent_usage[agent_id]['type'] = result.get('subagent_type', 'unknown')

                        subagent_usage[agent_id]['messages'] += 1
                        subagent_usage[agent_id]['input_tokens'] += usage.get('input_tokens', 0)
                        subagent_usage[agent_id]['output_tokens'] += usage.get('output_tokens', 0)
                        subagent_usage[agent_id]['cache_creation'] += usage.get('cache_creation_input_tokens', 0)
                        subagent_usage[agent_id]['cache_read'] += usage.get('cache_read_input_tokens', 0)
            except json.JSONDecodeError:
                pass
            except Exception:
                pass

    return main_usage, dict(subagent_usage), skill_invocations


def format_tokens(n: int) -> str:
    """Format token count with thousands separators."""
    return f"{n:,}"


def calculate_cost(usage: Dict[str, int], input_cost_per_m: float = 3.0, output_cost_per_m: float = 15.0) -> float:
    """Calculate estimated cost in dollars.

    Default rates are for Claude Sonnet ($3/$15 per M tokens).
    For Opus, use input_cost_per_m=15.0, output_cost_per_m=75.0
    """
    total_input = usage['input_tokens'] + usage['cache_creation'] + usage['cache_read']
    input_cost = total_input * input_cost_per_m / 1_000_000
    output_cost = usage['output_tokens'] * output_cost_per_m / 1_000_000
    return input_cost + output_cost


def output_json(main_usage, subagent_usage, skill_invocations, total_usage, total_cost):
    """Output analysis as JSON for programmatic consumption."""
    result = {
        'main_session': main_usage,
        'subagents': subagent_usage,
        'skill_invocations': skill_invocations,
        'totals': {
            **total_usage,
            'estimated_cost_usd': round(total_cost, 4)
        }
    }
    print(json.dumps(result, indent=2))


def output_table(main_usage, subagent_usage, skill_invocations, total_usage, total_cost):
    """Output analysis as formatted table."""
    print("=" * 110)
    print("TOKEN USAGE ANALYSIS")
    print("=" * 110)
    print()

    # Print breakdown
    print("Usage Breakdown:")
    print("-" * 110)
    print(f"{'Agent':<15} {'Type':<12} {'Description':<30} {'Msgs':>5} {'Input':>12} {'Output':>10} {'Cache':>10} {'Cost':>8}")
    print("-" * 110)

    # Main session
    cost = calculate_cost(main_usage)
    print(f"{'main':<15} {'coordinator':<12} {'Main session':<30} "
          f"{main_usage['messages']:>5} "
          f"{format_tokens(main_usage['input_tokens']):>12} "
          f"{format_tokens(main_usage['output_tokens']):>10} "
          f"{format_tokens(main_usage['cache_read']):>10} "
          f"${cost:>7.2f}")

    # Subagents (sorted by agent ID)
    for agent_id in sorted(subagent_usage.keys()):
        usage = subagent_usage[agent_id]
        cost = calculate_cost(usage)
        desc = usage['description'] or f"agent-{agent_id}"
        agent_type = usage.get('type', 'unknown') or 'unknown'
        print(f"{agent_id:<15} {agent_type:<12} {desc:<30} "
              f"{usage['messages']:>5} "
              f"{format_tokens(usage['input_tokens']):>12} "
              f"{format_tokens(usage['output_tokens']):>10} "
              f"{format_tokens(usage['cache_read']):>10} "
              f"${cost:>7.2f}")

    print("-" * 110)

    # Skill invocations
    if skill_invocations:
        print()
        print("Skill Invocations:")
        print("-" * 50)
        for inv in skill_invocations:
            args_str = f" (args: {inv['args']})" if inv.get('args') else ""
            print(f"  - {inv['skill']}{args_str}")
        print("-" * 50)

    # Calculate totals
    total_input = total_usage['input_tokens'] + total_usage['cache_creation'] + total_usage['cache_read']
    total_tokens = total_input + total_usage['output_tokens']

    print()
    print("TOTALS:")
    print(f"  Total messages:         {format_tokens(total_usage['messages'])}")
    print(f"  Total tool calls:       {format_tokens(total_usage.get('tool_calls', 0))}")
    print(f"  Input tokens:           {format_tokens(total_usage['input_tokens'])}")
    print(f"  Output tokens:          {format_tokens(total_usage['output_tokens'])}")
    print(f"  Cache creation tokens:  {format_tokens(total_usage['cache_creation'])}")
    print(f"  Cache read tokens:      {format_tokens(total_usage['cache_read'])}")
    print()
    print(f"  Total input (incl cache): {format_tokens(total_input)}")
    print(f"  Total tokens:             {format_tokens(total_tokens)}")
    print()
    print(f"  Estimated cost: ${total_cost:.2f}")
    print("  (at $3/$15 per M tokens for input/output - Sonnet rates)")
    print()
    print("=" * 110)


def main():
    parser = argparse.ArgumentParser(description='Analyze Claude Code session token usage')
    parser.add_argument('session_file', help='Path to session JSONL file')
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--opus', action='store_true', help='Use Opus pricing ($15/$75 per M)')
    args = parser.parse_args()

    if not Path(args.session_file).exists():
        print(f"Error: Session file not found: {args.session_file}", file=sys.stderr)
        sys.exit(1)

    # Analyze the session
    main_usage, subagent_usage, skill_invocations = analyze_main_session(args.session_file)

    # Calculate totals
    total_usage = {
        'input_tokens': main_usage['input_tokens'],
        'output_tokens': main_usage['output_tokens'],
        'cache_creation': main_usage['cache_creation'],
        'cache_read': main_usage['cache_read'],
        'messages': main_usage['messages'],
        'tool_calls': main_usage.get('tool_calls', 0)
    }

    for usage in subagent_usage.values():
        total_usage['input_tokens'] += usage['input_tokens']
        total_usage['output_tokens'] += usage['output_tokens']
        total_usage['cache_creation'] += usage['cache_creation']
        total_usage['cache_read'] += usage['cache_read']
        total_usage['messages'] += usage['messages']

    # Calculate cost
    if args.opus:
        total_cost = calculate_cost(total_usage, input_cost_per_m=15.0, output_cost_per_m=75.0)
    else:
        total_cost = calculate_cost(total_usage)

    # Output
    if args.json:
        output_json(main_usage, subagent_usage, skill_invocations, total_usage, total_cost)
    else:
        output_table(main_usage, subagent_usage, skill_invocations, total_usage, total_cost)


if __name__ == '__main__':
    main()
