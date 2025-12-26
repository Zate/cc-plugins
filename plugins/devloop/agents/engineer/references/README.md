# Engineer Agent References

This directory contains detailed mode instructions for the devloop engineer agent. These files are loaded on-demand when the agent operates in a specific mode.

## Purpose

The engineer agent supports four operating modes:
- **Explorer** - Trace execution paths, map architecture, understand patterns
- **Architect** - Design features, make structural decisions, plan implementations
- **Refactorer** - Identify code quality issues, technical debt, improvements
- **Git** - Commits, branches, PRs, history management

To optimize token efficiency, detailed mode instructions are extracted to separate reference files. The main `engineer.md` contains mode detection and orchestration logic, while these references provide comprehensive workflow guidance.

## Files

| File | Mode | Description |
|------|------|-------------|
| `explorer-mode.md` | Explorer | Codebase exploration workflow, output format |
| `architect-mode.md` | Architect | Architecture design process, decision points |
| `refactorer-mode.md` | Refactorer | Code quality analysis, refactoring workflow |
| `git-mode.md` | Git | Version control operations, commit formats |

## Loading

References are loaded when:
1. Mode is detected from user request (via mode_detection logic)
2. Agent needs detailed workflow guidance for the selected mode
3. Output format templates are required

## Token Impact

- **Without references**: ~1,034 lines loaded every invocation
- **With references**: ~500 lines base + ~80-110 lines per mode on-demand
- **Savings**: ~50% reduction in average token usage
