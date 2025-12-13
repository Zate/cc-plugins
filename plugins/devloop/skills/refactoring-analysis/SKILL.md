# Code Refactoring Analysis Skill

This skill provides comprehensive codebase analysis to identify refactoring opportunities, technical debt, and code quality issues across multiple programming languages including Go, Python, TypeScript, and React.

## When to Use This Skill

Use this skill when:
- User asks about code quality, refactoring, or technical debt in their codebase
- User mentions that code is "messy", "complex", "hard to maintain", or "needs cleanup"
- User wants to identify opportunities to improve code organization or structure
- User is planning a refactoring effort and needs guidance on where to start
- User asks questions like "what should I refactor?", "how can I improve this codebase?", or "where is the technical debt?"
- User mentions files are too large, functions are too complex, or code is duplicated
- User wants to understand the health of their codebase before making major changes
- User is onboarding to a new codebase and wants to understand its quality

## When NOT to Use This Skill

Do not use this skill when:
- User is asking about a specific bug or error (use debugging approaches instead)
- User wants to add new features without refactoring existing code
- User is asking about performance optimization specifically (unless related to code structure)
- User wants to understand how existing code works (use code reading/exploration instead)
- The codebase is very small (< 10 files) and obviously well-organized
- User explicitly states they don't want refactoring suggestions

## How to Use This Skill

### Analysis Methodology

1. **Initial Codebase Survey**
   - Identify the programming languages used (Go, Python, TypeScript/React, etc.)
   - Map the directory structure and organization
   - Count files and assess overall project size
   - Identify configuration files and build systems

2. **File-Level Analysis**
   - Find large files (>500 lines for most languages, >300 for React components)
   - Identify files with inconsistent naming conventions
   - Look for files with too many responsibilities (God objects/modules)
   - Find deeply nested directory structures

3. **Code-Level Analysis**
   - Identify complex functions (high cyclomatic complexity, >50 lines)
   - Find code duplication patterns
   - Look for poor separation of concerns
   - Identify missing error handling
   - Find inconsistent coding styles

4. **Language-Specific Analysis**

   **For Go:**
   - Large functions (>50 lines)
   - Packages with too many files or responsibilities
   - Missing error handling or error shadowing
   - Inconsistent receiver naming
   - Global variables and init() abuse
   - Interface pollution (interfaces with >5 methods)

   **For Python:**
   - Modules >500 lines
   - Functions >50 lines
   - Classes with >10 methods
   - Deeply nested imports
   - Missing type hints (for Python 3.5+)
   - Circular dependencies
   - Over-use of `*args`, `**kwargs`

   **For TypeScript/React:**
   - Components >300 lines
   - Components with >5 props (prop drilling)
   - Excessive useState/useEffect hooks in single component
   - Missing TypeScript types (using `any`)
   - Deeply nested component trees
   - Business logic in components (should be in hooks/utilities)
   - Inline styles or scattered CSS

5. **Interactive Vetting with User**
   - Present high-level findings organized into categories
   - Use AskUserQuestion tool to let user select which categories to explore
   - For selected categories, present individual findings for approval
   - Present quick wins separately for user approval
   - Only include user-approved items in final report

6. **Generate Report Documents**
   - Ask user preferred format (single doc, split files, or tickets)
   - Create report file(s) containing only approved findings
   - Use Write tool to save reports to disk
   - Provide clear handoff instructions for implementation

### Workflow

**IMPORTANT: Always invoke the refactor-analyzer agent to perform the analysis. This agent follows a standardized methodology to ensure consistent, high-quality results.**

When this skill is triggered:

1. Invoke the `refactor-analyzer` agent using the Task tool
2. The agent will:
   - Use ONLY approved tools (Glob, Grep, Read, specific Bash commands)
   - Follow standardized search patterns for each language
   - Perform comprehensive codebase analysis
   - Categorize findings into standard categories
   - Present detailed category summary to user
   - Interactively vet findings with user using AskUserQuestion
   - Generate report document(s) with only approved items
   - Save reports to disk using Write tool

### Standardized Analysis

The agent uses pre-defined search patterns and approved commands to ensure:
- **Consistency**: Same analysis approach every time
- **No interruptions**: No permission prompts for tool usage
- **Reproducibility**: Rerunning analysis on same code produces same results
- **Quality**: Every finding includes file paths, line numbers, and actionable steps

### Report Formats Available

The agent can generate three types of reports based on user preference:

1. **Single Detailed Document** (`REFACTORING_REPORT.md`)
   - Comprehensive report with all approved items
   - Executive summary and roadmap
   - Best for sharing with team or stakeholders

2. **Split Category Files** (`docs/refactoring/` directory)
   - Separate file for each category (test coverage, architecture, etc.)
   - Index file linking to all categories
   - Best for large refactoring efforts with multiple workstreams

3. **Actionable Tickets** (`REFACTORING_TICKETS.md`)
   - Ready-to-copy tickets for issue trackers
   - Formatted for GitHub Issues, Jira, etc.
   - Best for team planning and sprint organization

All reports include:
- Specific file paths and line numbers
- Clear problem descriptions
- Step-by-step solutions
- Expected benefits and effort estimates
- Success criteria
- Handoff instructions

## Best Practices

### Analysis Principles
- **Be specific:** Always provide file paths and line numbers
- **Be actionable:** Every issue should have clear next steps
- **Prioritize impact:** Focus on changes that improve maintainability most
- **Consider context:** Don't suggest refactorings that break working code without good reason
- **Balance scope:** Don't overwhelm with too many issues; focus on the most impactful
- **Respect conventions:** If the codebase has established patterns, acknowledge them

### Tool Usage
- Use `Glob` to find files by pattern (e.g., `**/*.go`, `**/*.py`, `**/*.tsx`)
- Use `Grep` to search for code patterns (e.g., duplicate code, missing error handling)
- Use `Read` to examine specific files in detail
- Use `Bash` for file statistics (line counts, directory structure) when needed
- Analyze multiple files in parallel when possible for efficiency

### Communication
- Start with a high-level summary before diving into details
- Use clear, non-judgmental language (avoid "bad code", use "opportunities for improvement")
- Explain *why* each refactoring matters, not just *what* to change
- Provide examples of better approaches when suggesting changes
- Be encouraging - recognize what's working well too

## Examples

### Example 1: Large File Analysis

**User:** "My codebase is getting hard to work with, can you help identify what needs refactoring?"

**Response:**
```
I'll analyze your codebase for refactoring opportunities. Let me start by surveying the project structure and identifying key areas for improvement.

[Runs analysis using Glob, Grep, and Read tools]

# Code Refactoring Analysis Report

## Executive Summary
- Total files analyzed: 47 Go files, 23 Python files, 18 TypeScript/React files
- Overall health: Needs Attention
- Critical issues: 2
- High priority issues: 5
- Medium priority issues: 8

## High Priority Refactoring Opportunities

### 1. Oversized Handler File - API Layer
**Impact:** High | **Complexity:** Medium | **Files Affected:** 1

**Description:**
The file `internal/api/handlers.go` contains 1,247 lines with 23 HTTP handlers. This violates the Single Responsibility Principle and makes the code difficult to navigate and test.

**Affected Files:**
- `internal/api/handlers.go:1-1247` - All HTTP handlers in single file

**Recommended Actions:**
1. Create separate files for each resource domain (users, products, orders)
2. Move handlers to: `internal/api/users.go`, `internal/api/products.go`, `internal/api/orders.go`
3. Create shared middleware in `internal/api/middleware.go`

**Expected Benefits:**
- Easier code navigation and maintenance
- Better testability with focused test files
- Reduced merge conflicts
- Clearer ownership and responsibility

[... continues with more issues]
```

### Example 2: React Component Complexity

**User:** "Our React app is getting slow and hard to work with"

**Response:**
```
I'll analyze your React application for structural issues and refactoring opportunities.

[Runs analysis]

### 2. Complex Dashboard Component - Frontend
**Impact:** High | **Complexity:** Hard | **Files Affected:** 1

**Description:**
`src/components/Dashboard.tsx` is 647 lines with 8 useState hooks, 6 useEffect hooks, and handles multiple concerns (data fetching, filtering, sorting, rendering).

**Affected Files:**
- `src/components/Dashboard.tsx:1-647` - Entire component

**Recommended Actions:**
1. Extract data fetching logic to custom hook: `useDashboardData()`
2. Extract filter logic to: `useFilters()`
3. Split into smaller components:
   - `DashboardHeader.tsx` (lines 45-120)
   - `DashboardFilters.tsx` (lines 121-210)
   - `DashboardGrid.tsx` (lines 211-450)
   - `DashboardSummary.tsx` (lines 451-550)
4. Move business logic to `utils/dashboardHelpers.ts`

**Expected Benefits:**
- Improved performance through better memoization opportunities
- Easier testing of individual components
- Reduced re-renders
- Better code reusability

[... continues]
```

### Example 3: Python Module Organization

**User:** "Can you check if my Python project needs refactoring?"

**Response:**
```
I'll analyze your Python project structure and identify refactoring opportunities.

[Runs analysis]

### 1. Monolithic Utils Module - Core Library
**Impact:** High | **Complexity:** Easy | **Files Affected:** 1

**Description:**
`src/utils.py` contains 892 lines with 47 functions covering unrelated concerns (string manipulation, date handling, file I/O, API helpers, validation).

**Affected Files:**
- `src/utils.py:1-892` - All utility functions

**Recommended Actions:**
1. Create focused modules:
   - `src/utils/strings.py` - String manipulation (functions: normalize_text, slugify, etc.)
   - `src/utils/dates.py` - Date/time handling (functions: parse_date, format_timestamp, etc.)
   - `src/utils/files.py` - File operations (functions: read_json, write_csv, etc.)
   - `src/utils/validators.py` - Validation logic (functions: validate_email, check_phone, etc.)
   - `src/utils/api.py` - API helpers (functions: build_request, parse_response, etc.)
2. Update imports throughout codebase
3. Add `__init__.py` to re-export commonly used functions

**Expected Benefits:**
- Clearer organization and discoverability
- Easier to test individual modules
- Reduced cognitive load when reading code
- Better IDE autocomplete support

[... continues]
```

## Tools and Integration

This skill leverages the following Claude Code tools:
- **Glob**: Finding files by pattern across the codebase
- **Grep**: Searching for code patterns and potential issues
- **Read**: Detailed examination of flagged files
- **Bash**: Running analysis commands (line counts, file stats, language-specific linters)
- **Task**: Delegating to specialized agents for deeper analysis if needed

## Metrics and Thresholds

Use these guidelines when identifying issues:

### File Size Thresholds
- **Go**: >500 lines (handlers/controllers >300 lines)
- **Python**: >500 lines (modules), >100 lines (classes)
- **TypeScript/React**: >300 lines (components), >500 lines (utilities)
- **General**: >1000 lines is always concerning

### Function/Method Complexity
- **Lines**: >50 lines warrants review, >100 lines is critical
- **Cyclomatic Complexity**: >10 warrants review, >20 is critical
- **Nesting Depth**: >4 levels warrants review
- **Parameters**: >5 parameters suggests refactoring needed

### Code Duplication
- Identical code blocks >10 lines in multiple locations
- Similar logic patterns repeated 3+ times
- Copy-pasted functions with minor variations

### Organizational Issues
- >10 files in a single directory without subdirectories
- Directories nested >5 levels deep
- Inconsistent naming conventions across the codebase
- Missing separation between business logic and infrastructure

## References

- [Refactoring: Improving the Design of Existing Code](https://martinfowler.com/books/refactoring.html) by Martin Fowler
- [Clean Code](https://www.oreilly.com/library/view/clean-code-a/9780136083238/) by Robert C. Martin
- [Effective Go](https://go.dev/doc/effective_go)
- [Python Code Quality Authority](https://pycqa.org/)
- [React Best Practices](https://react.dev/learn/thinking-in-react)
