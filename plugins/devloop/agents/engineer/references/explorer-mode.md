# Explorer Mode Reference

**Purpose**: Trace execution paths, map architecture, understand patterns
**Token impact**: Loaded on-demand when Explorer mode is active

## Analysis Approach

### 1. Feature Discovery
- Find entry points (APIs, UI components, CLI commands)
- Locate core implementation files
- Map feature boundaries

### 2. Code Flow Tracing
- Follow call chains from entry to output
- Trace data transformations
- Document state changes

### 3. Architecture Analysis
- Map abstraction layers
- Identify design patterns
- Note cross-cutting concerns

## Scope Clarification

For broad requests, use AskUserQuestion:

```yaml
Question: "How deep should I explore this feature?"
Header: "Depth"
Options:
- High-level overview (Recommended)
- Detailed analysis
- Exhaustive tracing
```

## Output Format

**CRITICAL**: Always use this structured format for exploration results.

```markdown
## [Feature/Component] Exploration Summary

### Entry Points
| File | Line | Description |
|------|------|-------------|
| path/to/file.go | 42 | Main HTTP handler for user creation |
| path/to/cli.go | 128 | CLI command entry point |

### Execution Flow
1. `file.go:42` → Receives HTTP request, validates input
2. `service.go:88` → Processes business logic, creates user entity
3. `repository.go:156` → Saves to database
4. `middleware.go:23` → Logs audit event
5. Returns response via `file.go:67`

### Key Components
- **UserHandler** (`handlers/user.go`): HTTP request handling, input validation
- **UserService** (`services/user.go`): Business logic, orchestration
- **UserRepository** (`repositories/user.go`): Database operations
- **AuditLogger** (`middleware/audit.go`): Cross-cutting concern for audit trails

### Architecture Insights
- **Pattern used**: Repository pattern with service layer
- **Design decision**: Middleware for cross-cutting concerns
- **Notable**: Service layer is stateless, can be parallelized
- **Dependency injection**: Via constructor pattern

### Essential Files for Understanding
1. `handlers/user.go:1-150` - Entry point and validation logic
2. `services/user.go:50-200` - Core business logic
3. `repositories/user.go:80-180` - Database interface

### Complexity Assessment
- **Scope**: 3 layers (handler → service → repository)
- **Files involved**: 5 files
- **Patterns**: Standard repository pattern, well-structured
```

## Token Budget

**Max 500 tokens** for exploration summaries.

If findings exceed token budget:
1. Prioritize most important entry points and flow
2. Summarize architecture insights concisely
3. Offer to elaborate: "I can provide more detail on [specific area] if needed."

## Search Patterns

### Finding Entry Points

```bash
# HTTP handlers
Grep: "func.*Handler" or "http.Handle"

# CLI commands
Grep: "cobra.Command" or "flag.Parse"

# API routes
Grep: "router.Handle" or ".GET(" or ".POST("
```

### Tracing Execution Flow

1. Start from entry point
2. Follow function calls using Grep for function names
3. Map data flow through parameters
4. Identify side effects (DB writes, external calls)

### Mapping Dependencies

- Check imports to understand module boundaries
- Look for interface definitions to find abstraction layers
- Trace dependency injection patterns

## Common Patterns to Identify

| Pattern | Indicators |
|---------|------------|
| Repository | `interface{}Repository`, database operations |
| Service Layer | `*Service` types, business logic orchestration |
| Middleware | `func(next http.Handler)`, request/response wrapping |
| Factory | `New*()` functions, object creation |
| Observer | Event channels, callback registrations |
| Strategy | Interface implementations, runtime selection |

## When to Escalate

Suggest Opus model when:
- Architecture spans 5+ modules
- Complex async/concurrency patterns found
- Security-sensitive code paths identified
- User requests "thorough" or "comprehensive" analysis
