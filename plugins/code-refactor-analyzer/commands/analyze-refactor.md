---
description: Analyze codebase for refactoring opportunities and technical debt across Go, Python, TypeScript/React and other languages
---

# Analyze Refactor Command

Perform a comprehensive analysis of the codebase to identify refactoring opportunities, technical debt, code quality issues, and organizational problems.

## What This Command Does

This command triggers the `refactor-analyzer` agent to conduct a thorough examination of your codebase, analyzing:

- **File-level issues**: Large files, poor organization, inconsistent naming
- **Code-level issues**: Complex functions, code duplication, missing error handling
- **Language-specific issues**: Violations of best practices for Go, Python, TypeScript/React, and more
- **Architectural issues**: Poor separation of concerns, circular dependencies, tight coupling
- **Technical debt**: Accumulated issues that impact maintainability

The analysis produces a prioritized, actionable report with specific file references, code examples, and refactoring recommendations.

## Usage

```bash
# Analyze entire codebase
/analyze-refactor

# Analyze with specific focus areas (specify in natural language after command)
/analyze-refactor focus on the API layer
/analyze-refactor check React components only
/analyze-refactor analyze the Python backend
```

## How It Works

This command follows an interactive workflow:

### 1. Analysis Phase
The agent performs comprehensive codebase analysis using a standardized methodology:
- Uses only pre-approved tools (no permission prompts)
- Follows language-specific search patterns
- Categorizes findings into standard groups
- Ensures consistent, reproducible results

### 2. Category Summary
You'll receive a detailed summary showing what was found in each category:

```markdown
### 1. Test Coverage & Quality
**Priority:** Critical | **Items:** 3 | **Est. Effort:** 4-5 days
- No unit tests in transport layer (http.go, stdio.go)
- Missing integration tests for MCP client
- Config parsing has 0% coverage

### 2. Architectural Issues
**Priority:** High | **Items:** 4 | **Est. Effort:** 3-4 days
- Global state in cmd package
- Large transport files (566+ lines)
- Session ID confusion
- Missing context propagation

[etc...]
```

This gives you full visibility before making any decisions.

### 3. Interactive Vetting (Multi-Screen)
**This is where you have control.** The agent presents a multi-screen interface where you navigate horizontally through categories:

**Screen 1: Test Coverage** - Select which test-related items to include
**Screen 2: Architecture** - Select which architectural refactorings to include
**Screen 3: Code Quality** - Select which code quality items to include
**Screen 4: Quick Wins** - Select which quick wins to include
**Screen 5: Report Format** - Choose how to save the report

Each screen shows items with:
- Priority level (Critical/High/Medium/Low)
- Estimated effort (hours/days)
- Affected files
- Description of the issue

You can select multiple items per screen and navigate back/forward to review your selections.

### 4. Report Generation
Based on your selections, the agent generates one or more report documents:

**Option 1: Single Detailed Document** (`REFACTORING_REPORT.md`)
- Comprehensive report with all approved items
- Executive summary, roadmap, and metrics
- Best for sharing with team/stakeholders

**Option 2: Split Category Files** (`docs/refactoring/` directory)
- Separate file per category
- Index file linking everything together
- Best for large efforts with multiple workstreams

**Option 3: Actionable Tickets** (`REFACTORING_TICKETS.md`)
- Ready-to-copy tickets for GitHub Issues, Jira, etc.
- Each ticket is standalone and actionable
- Best for sprint planning

Each approved item includes:
- Specific file paths and line numbers
- Clear problem description
- Step-by-step solution
- Expected benefits and effort estimates
- Success criteria

## Analysis Scope

The analyzer examines:

### Language Support
- **Go**: Package organization, error handling, interface design, concurrency patterns
- **Python**: Module structure, type hints, class design, import organization
- **TypeScript/React**: Component architecture, hook usage, type safety, state management
- **JavaScript**: Modern patterns, async handling, module organization
- **And more**: The analyzer adapts to other languages using general principles

### Analysis Areas
- File size and complexity
- Code duplication
- Naming conventions
- Directory organization
- Separation of concerns
- Error handling patterns
- Testing coverage gaps
- Documentation quality

## Example Workflow

### Initial Summary
```markdown
## Analysis Complete

I've analyzed mcp-cli and identified refactoring opportunities.

**Codebase Overview:**
- Files analyzed: 45 Go files
- Overall health: Needs Attention
- Project type: CLI tool with multiple transports

**Findings Summary:**
- Critical issues: 1 (test coverage)
- High priority: 7
- Medium priority: 12
- Quick wins: 8

**Top 3 Recommendations:**
1. Add unit tests (0% coverage in transport layer)
2. Fix global state in cmd package
3. Split large transport files (566+ lines)

**What's Working Well:**
- Excellent structured logging with zerolog
- Good use of interfaces and contexts
- Security-conscious credential handling

I've organized findings into 5 categories. Let's review them together to determine what should be included in the final report.
```

### Interactive Vetting (Multi-Screen Example)

The agent presents all questions at once in a multi-screen interface:

**← Screen 1/5: Test Coverage →**
Which test coverage items should we include in the report?
- [x] Add unit tests for transport layer (High, 2-3 days)
      Files: http.go, stdio.go - Currently 0% coverage
- [x] Add integration tests for MCP client (High, 2 days)
      End-to-end flows are untested
- [ ] Add config parsing tests (Medium, 4 hours)
      Missing validation test cases

**← Screen 2/5: Architecture →**
Which architectural issues should we include in the report?
- [x] Eliminate global state in cmd package (High, 1 day)
      currentClient, currentTransport make testing difficult
- [x] Split large transport files (Medium, 4-6 hours)
      http.go (566 lines), stdio.go (443 lines)
- [ ] Fix session ID confusion (Medium, 2 hours)
      Two sessionID fields with unclear purpose

**← Screen 3/5: Code Quality →**
Which code quality items should we include in the report?
- [x] Extract duplicate config loading (Medium, 3 hours)
      Same logic in connect.go, list.go, server.go
- [x] Fix stdio error handling (Medium, 4 hours)
      Error channel handling is fragile

**← Screen 4/5: Quick Wins →**
Which quick wins (< 1 day) should we include?
- [x] Fix YAML output format (2 hours)
      yaml.go:45 - Currently just outputs JSON
- [x] Extract config format detection (3 hours)
      Duplicated across multiple files
- [ ] Add constants for magic strings (1 hour)
      Replace hardcoded strings in http.go

**← Screen 5/5: Report Format →**
How should we save the refactoring report?
- (•) Single document (REFACTORING_REPORT.md)
      Best for sharing with team or stakeholders
- ( ) Split by category (docs/refactoring/*.md)
      Best for large efforts with multiple workstreams
- ( ) Issue tickets (REFACTORING_TICKETS.md)
      Ready-to-copy format for GitHub/Jira
- ( ) All formats
      Generate all three report types

You navigate horizontally through these screens, selecting items as you go.

### Generated Report
After your selections, a file like `REFACTORING_REPORT.md` is created with only the approved items, ready to hand off to developers or use for planning.

## When to Use This Command

Use `/analyze-refactor` when:
- Starting work on an unfamiliar codebase
- Planning a refactoring effort
- Code reviews reveal recurring quality issues
- Onboarding new team members (to document tech debt)
- Before major feature additions (to clean up first)
- Technical debt is impacting velocity
- After rapid prototyping phase (to clean up)

## Tips for Best Results

1. **Run from project root**: Ensure you're in the root directory of your project
2. **Clean working directory**: Commit or stash changes first for clarity
3. **Be specific if needed**: Mention focus areas if you want targeted analysis
4. **Review thoroughly**: Read the full report, not just the summary
5. **Start small**: Begin with quick wins to build momentum
6. **Track progress**: Create issues/tickets from recommendations

## Following Up

After receiving the analysis:

1. **Prioritize**: Discuss recommendations with your team
2. **Plan**: Use the roadmap as a starting point for sprint planning
3. **Implement**: Tackle quick wins first for immediate improvement
4. **Track**: Create GitHub issues or tasks for larger refactorings
5. **Measure**: Run analysis again after changes to see improvement

## Integration with Other Tools

This command works well with:
- `/test` - Run tests after refactoring
- `/commit` - Commit refactored code
- Code review processes - Use report to guide reviews
- Issue tracking - Convert recommendations to tickets

## Notes

- Analysis is non-invasive (read-only)
- No code is modified by this command
- Analysis time varies with codebase size (typically 2-10 minutes)
- Results are deterministic - same code produces same analysis
- Agent can analyze projects of any size, but may focus on most critical issues for very large codebases

---

Invoke the refactor-analyzer agent to perform a comprehensive codebase analysis following the methodology defined in the agent specification. Focus on providing specific, actionable, prioritized recommendations with clear file references and concrete next steps.
