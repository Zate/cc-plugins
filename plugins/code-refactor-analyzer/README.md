# Code Refactor Analyzer Plugin

A comprehensive Claude Code plugin for analyzing codebases and identifying refactoring opportunities across multiple programming languages including Go, Python, TypeScript/React, and more.

## Overview

The Code Refactor Analyzer helps you identify technical debt, code quality issues, and refactoring opportunities in your codebase through **interactive analysis and user-vetted reporting**. It performs deep analysis and then works with you to decide which findings matter most, generating actionable reports you can hand off to developers.

### Key Features

- **Standardized Methodology**: Consistent analysis using pre-approved tools and patterns
- **No Permission Prompts**: Uses only approved commands - no interruptions
- **Interactive Vetting**: Review and approve findings before they go into reports
- **Multi-language support**: Go, Python, TypeScript/React, JavaScript, and more
- **Comprehensive analysis**: File-level, code-level, and architectural issues
- **User-controlled output**: You choose which categories and findings to include
- **Multiple report formats**: Single doc, split files, or ready-to-copy tickets
- **Specific and actionable**: Every item includes file paths, line numbers, and concrete steps
- **Handoff-ready**: Reports designed for delegation to other developers or agents
- **Reproducible**: Same codebase always produces consistent analysis

## Installation

### From Marketplace

If this marketplace is configured in your Claude Code:

```bash
/plugin install code-refactor-analyzer
```

### Manual Installation

```bash
/plugin install /path/to/cc-plugins/plugins/code-refactor-analyzer
```

### From Repository

```bash
# Add this marketplace
/plugin marketplace add YOUR_USERNAME/cc-plugins

# Install the plugin
/plugin install code-refactor-analyzer
```

## Components

This plugin provides three ways to trigger refactoring analysis:

### 1. Slash Command: `/analyze-refactor`

Quick and direct way to analyze your codebase:

```bash
# Analyze entire codebase
/analyze-refactor

# Analyze with specific focus
/analyze-refactor focus on React components
/analyze-refactor check the API layer
```

**Best for**: Immediate, on-demand analysis when planning refactoring work.

### 2. Skill: `refactor-analysis`

Automatically invoked when you discuss code quality:

```
"Can you check if my codebase needs refactoring?"
"What technical debt should we address?"
"Help me identify code quality issues"
```

**Best for**: Natural conversation about code quality and improvement opportunities.

### 3. Agent: `refactor-analyzer`

Specialized agent for deep codebase analysis. Claude automatically uses this agent when appropriate, or you can invoke it directly through the Task tool.

**Best for**: Comprehensive, systematic analysis requiring expert methodology.

## What Gets Analyzed

### File-Level Issues

- **Large files**: Files exceeding language-specific thresholds
  - Go: >500 lines (handlers/controllers >300)
  - Python: >500 lines
  - TypeScript/React: Components >300 lines
- **Poor organization**: Files with too many responsibilities
- **Naming inconsistencies**: Mixed conventions across codebase
- **Directory structure**: Over-crowded or too deeply nested directories

### Code-Level Issues

- **Complex functions**: >50 lines, high cyclomatic complexity
- **Code duplication**: Repeated logic across multiple files
- **Missing error handling**: Unchecked errors, swallowed exceptions
- **Poor separation of concerns**: Mixed responsibilities in single units
- **Inconsistent patterns**: Varying approaches to similar problems

### Language-Specific Analysis

#### Go
- Package organization and structure
- Error handling patterns and missing checks
- Interface design (size and necessity)
- Goroutine management and concurrency
- Context usage
- Global variables and init() usage

#### Python
- Module organization and size
- Type hints coverage (Python 3.5+)
- Class complexity and method count
- Import organization and circular dependencies
- Exception handling patterns
- Docstring coverage

#### TypeScript/React
- Component size and complexity
- Props drilling (>5 props indicates issue)
- Hook usage (multiple useState/useEffect)
- TypeScript type coverage (avoiding `any`)
- Component composition and hierarchy
- Business logic separation from UI
- State management patterns

### Architectural Issues

- Circular dependencies
- Tight coupling between modules
- Violation of separation of concerns
- Missing abstraction layers
- Inconsistent architectural patterns

## Output Format

The analyzer generates a comprehensive markdown report:

```markdown
# Code Refactoring Analysis Report

## Executive Summary
- Overall health score
- Critical, high, medium, and low priority issue counts
- Top 3 recommendations

## Critical Issues
[Immediate attention required]

## High Priority Refactoring Opportunities
[Most impactful changes]
- Specific file paths and line numbers
- Problem description and impact
- Recommended refactoring steps
- Expected benefits
- Estimated effort

## Medium/Low Priority Issues
[Future improvements]

## Quick Wins
[Easy refactorings with immediate value]

## Code Quality Metrics
- File size distribution
- Complexity hotspots
- Top largest files

## Refactoring Roadmap
- Phase 1: Quick wins (Week 1)
- Phase 2: Structural changes (Weeks 2-3)
- Phase 3: Improvements (Month 2)
- Phase 4: Long-term (Month 3+)

## Best Practices & Patterns
- What's working well
- Recommended patterns
- Anti-patterns to avoid
```

## Interactive Workflow

When you run `/analyze-refactor`, here's what happens:

### 1. Analysis Phase
The agent analyzes your codebase comprehensively (typically 2-5 minutes).

### 2. Initial Summary
You receive a brief overview:
```markdown
## Analysis Complete

I've analyzed mcp-cli and identified refactoring opportunities.

**Codebase Overview:**
- Files analyzed: 45 Go files
- Overall health: Needs Attention

**Findings Summary:**
- Critical issues: 1
- High priority: 7
- Quick wins: 8

**Top 3 Recommendations:**
1. Add unit tests (0% coverage in transport layer)
2. Fix global state in cmd package
3. Split large transport files

I've organized findings into 5 categories. Let's review them together.
```

### 3. Interactive Vetting (Multi-Screen)
The agent presents a multi-screen interface you navigate horizontally:

**Screen 1: Test Coverage**
Select which test items to include:
- ✓ Add unit tests for transport layer (High, 2-3 days)
- ✓ Add integration tests for MCP client (High, 2 days)
- ✗ Add config parsing tests (Medium, 4 hours)

**Screen 2: Architecture**
Select which architectural refactorings:
- ✓ Eliminate global state (High, 1 day)
- ✓ Split large files (Medium, 4-6 hours)
- ✗ Fix session ID naming (Medium, 2 hours)

**Screen 3: Code Quality**
Select quality improvements:
- ✓ Extract duplicate config logic (3 hours)
- ✓ Fix error handling (4 hours)

**Screen 4: Quick Wins**
Select quick wins to include:
- ✓ Fix YAML output (2 hours)
- ✓ Extract config detection (3 hours)

**Screen 5: Report Format**
Choose output format:
- ● Single detailed document
- ○ Split into category files
- ○ Actionable tickets format

Navigate forward/back through screens, select items as you go.

### 4. Report Generation
The agent creates `REFACTORING_REPORT.md` with only your approved findings, ready to hand off.

## Usage Examples

### Example 1: General Codebase Analysis

```bash
/analyze-refactor
```

The agent analyzes everything, then you interactively select which findings to include in the final report. Only approved items appear in the generated document.

### Example 2: Focused Analysis

```bash
/analyze-refactor focus on React components
```

The analysis focuses on React code, then you vet the findings interactively before report generation.

### Example 3: Handoff to Another Developer

After running the analysis and approving findings, you get a file like:

**REFACTORING_REPORT.md:**
```markdown
# Code Refactoring Analysis Report
**Project:** mcp-cli
**Date:** 2025-01-15
**Status:** User-Vetted

## Executive Summary

**User-Approved Priorities:**
- Critical items: 1
- High priority items: 5
- Quick wins: 6

**Estimated Total Effort:** 2 weeks

## Approved Refactoring Items

### Test Coverage: Add Unit Tests for Transport Layer

**Priority:** Critical | **Impact:** High | **Complexity:** Medium | **Effort:** 2-3 days

**Problem Description:**
The transport layer (http.go, stdio.go) has 0% test coverage, making refactoring
risky and bug detection difficult.

**Affected Files:**
- `internal/transport/http.go:1-566` - HTTP transport implementation
- `internal/transport/stdio.go:1-443` - Stdio transport implementation

**Recommended Solution:**
1. Create `internal/transport/http_test.go`
2. Test OAuth flow, session management, request/response handling
3. Create `internal/transport/stdio_test.go`
4. Test process lifecycle, message passing, error handling
5. Aim for >80% coverage in transport layer

**Expected Benefits:**
- Safe refactoring of transport layer
- Early bug detection
- Documentation through test cases
- Confidence for future changes

**Success Criteria:**
- [ ] http.go covered >80%
- [ ] stdio.go covered >80%
- [ ] All critical paths tested
- [ ] Tests run in CI

---

[... more approved items ...]

## Handoff Instructions

**For Developers:**
This report contains 11 user-vetted refactoring items. Each includes specific
file paths, step-by-step solutions, and success criteria.

**Recommended Approach:**
1. Start with Quick Wins (6 items, ~1 day total)
2. Address Critical item (test coverage)
3. Work through High Priority items

Ready for implementation.
```

You can now hand this document to another developer or agent who will implement the approved changes.

## Best Practices

### When to Run Analysis

- **Starting new work**: Understand codebase health before diving in
- **Planning refactoring**: Get systematic view of improvement opportunities
- **Code review prep**: Identify recurring quality issues
- **Onboarding**: Document technical debt for new team members
- **Pre-feature work**: Clean up before adding complexity
- **Sprint planning**: Use roadmap for backlog items

### How to Use Results

1. **During analysis**: Use the interactive vetting to focus on what matters
2. **Select strategically**: Approve items that align with current priorities
3. **Choose format wisely**:
   - Single doc for stakeholder sharing
   - Split files for multi-team efforts
   - Tickets for sprint planning
4. **Hand off clearly**: The generated reports are designed for delegation
5. **Track progress**: Check off completed items in the report
6. **Re-analyze**: Run again after Phase 1 to see improvements

### Tips for Success

- **Be selective during vetting**: You don't have to include everything
- **Focus on impact**: Choose items that provide most value
- **Consider capacity**: Approve what your team can actually tackle
- **Use the right format**: Tickets format works great with issue trackers
- **Iterate**: Start with a subset, complete it, then run analysis again
- **Delegate effectively**: The reports are designed for handoff to other developers or agents

## Configuration

This plugin works out of the box with no configuration required. It adapts to your codebase structure and languages automatically.

### Customization

You control the output through interactive vetting:
- Select which categories to include
- Approve/reject individual findings
- Choose report format
- Focus analysis by mentioning specific areas:

```bash
/analyze-refactor focus on error handling
/analyze-refactor check for code duplication
/analyze-refactor analyze test organization
```

## Analysis Metrics

The plugin uses these thresholds to identify issues:

### File Size
- **Go**: >500 lines (>300 for handlers/controllers)
- **Python**: >500 lines (>100 for classes)
- **TypeScript/React**: >300 lines (components), >500 (utilities)
- **Any language**: >1000 lines is critical

### Function Complexity
- **Lines**: >50 needs review, >100 is critical
- **Cyclomatic Complexity**: >10 needs review, >20 is critical
- **Nesting Depth**: >4 levels needs review
- **Parameters**: >5 parameters suggests refactoring

### Code Duplication
- Identical blocks >10 lines in multiple locations
- Similar patterns repeated 3+ times
- Copy-pasted functions with minor variations

### Organization
- >10 files in single directory without subdirectories
- >5 levels of directory nesting
- Inconsistent naming conventions
- Missing separation of concerns

## Troubleshooting

### Too many findings to review
**Solution**: During vetting, select only the high-priority categories. You can always run analysis again later for other areas.

### Want different items in report
**Solution**: The analysis is repeatable. Run it again and make different selections during vetting.

### Need to share findings with non-technical stakeholders
**Solution**: Choose the "Single detailed document" format - it includes executive summary and clear explanations.

### Want to create GitHub Issues quickly
**Solution**: Choose the "Actionable tickets" format - each section is ready to copy into an issue.

### Analysis takes too long
**Solution**: For very large codebases (>100k lines), specify focus areas when invoking: `/analyze-refactor focus on [specific area]`

## Contributing

Found a bug or have a suggestion? Please contribute:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Ideas for Enhancements

- Additional language support (Rust, Java, C#, etc.)
- Integration with code quality tools (ESLint, Pylint, golangci-lint)
- Custom threshold configuration
- Export to different formats (JSON, HTML, PDF)
- Trend analysis across multiple runs
- Team collaboration features

## License

MIT License - see LICENSE file for details

## Support

- **Issues**: [GitHub Issues](https://github.com/YOUR_USERNAME/cc-plugins/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YOUR_USERNAME/cc-plugins/discussions)
- **Documentation**: [Plugin Docs](https://code.claude.com/docs/en/plugins.md)

## Related Resources

- [Refactoring: Improving the Design of Existing Code](https://martinfowler.com/books/refactoring.html) by Martin Fowler
- [Clean Code](https://www.oreilly.com/library/view/clean-code-a/9780136083238/) by Robert C. Martin
- [Effective Go](https://go.dev/doc/effective_go)
- [Python Code Quality Authority](https://pycqa.org/)
- [React Best Practices](https://react.dev/learn/thinking-in-react)

---

**Built with Claude Code** | **Version 1.0.0**
