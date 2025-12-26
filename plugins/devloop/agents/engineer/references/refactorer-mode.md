# Refactorer Mode Reference

**Purpose**: Identify code quality issues, technical debt, improvements
**Token impact**: Loaded on-demand when Refactorer mode is active

## Analysis Workflow

### 1. Survey
- Detect languages and frameworks
- Map directory structure
- Identify codebase size and hotspots

### 2. Analysis (Parallel Where Possible)
- **File-level**: Large files, poor naming, structural issues
- **Code-level**: Complexity, duplication, coupling
- **Language-specific**: Idiom violations, anti-patterns

### 3. Categorize
- **Priority**: High (blockers), Medium (improvements), Low (nice-to-have)
- **Impact**: Business impact, maintainability, reliability
- **Complexity**: Effort to fix, risk of regression

### 4. Identify Quick Wins
- Less than 4 hours effort
- Clear solution with low risk
- No external dependencies

## Interactive Vetting

Present category summary, then vet with AskUserQuestion:

```yaml
Question: "Which refactoring items should we include?"
Header: "Items"
multiSelect: true
Options: [Items in priority order]
```

## Output Format

**CRITICAL**: Always use this structured format for refactoring reports.

```markdown
## Refactoring Analysis: [Component/Area]

### Codebase Health
- **Size**: 150 files, ~15K LOC
- **Language**: Go
- **Overall**: Moderate technical debt, well-structured but some hotspots

### Findings by Category

#### High Priority (3 items)
| File | Issue | Impact | Effort |
|------|-------|--------|--------|
| `services/user.go:50-300` | Function too large (250 lines) | Maintainability | 4h |
| `handlers/api.go` | Missing error handling in 8 methods | Reliability | 2h |
| `models/` | Duplicated validation logic across 5 files | DRY violation | 6h |

#### Medium Priority (5 items)
[Summary table...]

#### Low Priority (2 items)
[Summary table...]

### Quick Wins (< 4 hours, high impact)
1. **Extract validation to shared package** - `models/*.go`
   - Effort: 2h | Impact: High | Benefit: Removes duplication
2. **Add error handling to API handlers** - `handlers/api.go`
   - Effort: 2h | Impact: High | Benefit: Improves reliability

### Implementation Roadmap
**Phase 1: Quick Wins** (4h total)
- Task 1.1: Extract validation logic
- Task 1.2: Add error handling

**Phase 2: Structural Improvements** (10h total)
- Task 2.1: Split large service methods
- Task 2.2: Refactor duplicated code

### Recommendations
- Start with Quick Wins for immediate impact
- Phase 2 requires more testing, schedule accordingly
```

## Token Budget

**Max 1000 tokens** for refactoring reports.

If findings are extensive:
1. Show top 3-5 items per priority category
2. Summarize lower-priority items: "12 additional low-priority items (available on request)"
3. Focus on Quick Wins and high-impact changes

## Code Smell Detection

### Structural Smells

| Smell | Detection | Threshold |
|-------|-----------|-----------|
| God Class | Many methods, many fields | >20 methods OR >15 fields |
| Long Method | Line count | >50 lines (Go), >100 lines (Java) |
| Feature Envy | External calls > internal | Ratio > 3:1 |
| Data Clumps | Repeated parameter groups | Same 3+ params in 3+ methods |
| Primitive Obsession | Strings for typed data | IDs, emails, etc. as strings |

### Duplication Detection

```bash
# Find similar code blocks
Grep for repeated patterns:
- Same error handling blocks
- Similar validation logic
- Repeated data transformations
```

### Complexity Analysis

- **Cyclomatic Complexity**: Count decision points (if, for, switch)
- **Cognitive Complexity**: Nesting depth, breaks in linear flow
- **Coupling**: Count external dependencies per module

## Refactoring Patterns

### Extract Method
**When**: Code block has single responsibility, reused or complex
**How**:
1. Identify coherent block
2. Create new function with descriptive name
3. Replace block with function call
4. Pass required data as parameters

### Extract Interface
**When**: Multiple implementations needed, testing isolation required
**How**:
1. Define interface with used methods only
2. Update consumers to use interface type
3. Create implementations

### Replace Conditional with Polymorphism
**When**: Switch/if chains based on type
**How**:
1. Create interface for behavior
2. Implement per type
3. Use type dispatch

### Introduce Parameter Object
**When**: Same parameters passed together repeatedly
**How**:
1. Create struct/class for parameter group
2. Update method signatures
3. Migrate callers

## Risk Assessment

| Risk Level | Indicators | Mitigation |
|------------|------------|------------|
| Low | Single file, tests exist | Refactor directly |
| Medium | Multiple files, partial tests | Add tests first |
| High | No tests, external dependencies | Spike first, incremental changes |

## When to Escalate

Suggest Opus model when:
- Refactoring affects 5+ files
- No existing tests for affected code
- Security-sensitive code paths
- Complex dependency chains
