# Architect Mode Reference

**Purpose**: Design features, make structural decisions, plan implementations
**Token impact**: Loaded on-demand when Architect mode is active

## Design Process

### 1. Pattern Analysis
- Extract existing patterns from codebase
- Review CLAUDE.md guidelines
- Identify conventions and standards

### 2. Architecture Design
- Make decisive architectural choices
- Ensure integration with existing code
- Consider scalability and maintainability

### 3. Implementation Blueprint
- Define specific files and components
- Map data flow between components
- Plan build sequence with dependencies

## Decision Points

For multiple valid approaches, use AskUserQuestion:

```yaml
Question: "Which approach do you prefer?"
Header: "Approach"
Options:
- [Option 1]: [Trade-offs]
- [Option 2]: [Trade-offs] (Recommended)
```

## Output Format

**CRITICAL**: Always use this structured format for architecture designs.

```markdown
## [Feature] Architecture Design

### Existing Patterns Found
- **Authentication**: JWT tokens via `middleware/auth.go:45`
- **Validation**: Struct tags + validator.v10 in `handlers/base.go:88`
- **Error handling**: Custom error types in `errors/types.go:12`

### Architecture Decision
**Chosen Approach**: Repository pattern with service layer
**Rationale**: Matches existing codebase patterns, separates concerns clearly
**Trade-offs**: More files but better testability and maintainability

### Component Design

#### 1. Handler Layer (`handlers/feature.go`)
**Responsibility**: HTTP request/response, input validation
**Key methods**:
- `CreateFeature(w http.ResponseWriter, r *http.Request)` - Entry point
- `validateInput(data FeatureInput) error` - Validation logic

#### 2. Service Layer (`services/feature.go`)
**Responsibility**: Business logic, orchestration
**Key methods**:
- `Create(ctx context.Context, input FeatureDTO) (*Feature, error)` - Core logic
- `validateBusinessRules(input FeatureDTO) error` - Business validation

#### 3. Repository Layer (`repositories/feature.go`)
**Responsibility**: Database operations
**Key methods**:
- `Save(ctx context.Context, feature *Feature) error` - Persistence

### Data Flow
1. HTTP Request → `handlers/feature.go:CreateFeature`
2. Validation → `handlers/feature.go:validateInput`
3. DTO conversion → `services/feature.go:Create`
4. Business logic → Service layer processing
5. Persistence → `repositories/feature.go:Save`
6. Response → Handler returns JSON

### Implementation Map

**Files to create:**
- `handlers/feature.go` (~150 lines)
- `services/feature.go` (~200 lines)
- `repositories/feature.go` (~100 lines)
- `models/feature.go` (~50 lines)
- `handlers/feature_test.go`, `services/feature_test.go`, `repositories/feature_test.go`

**Files to modify:**
- `routes/routes.go:78` - Add new route registration

### Build Sequence

**Phase 1: Foundation** [parallel:none]
- Task 1.1: Create model types in `models/feature.go`

**Phase 2: Core Layers** [parallel:partial]
- Task 2.1: Implement repository layer [parallel:A]
- Task 2.2: Implement service layer [parallel:A]
- Task 2.3: Implement handler layer [depends:2.1,2.2]

**Phase 3: Integration** [parallel:none]
- Task 3.1: Wire up routing
- Task 3.2: Add tests
```

## Token Budget

**Max 800 tokens** per architecture proposal.

If design is complex:
1. Summarize component responsibilities concisely
2. Show 2-3 key methods per component (not all)
3. Offer to elaborate: "I can provide detailed method signatures for [component] if needed."

## Parallelization Analysis

### Mark Parallel When
- Independent files with no shared modifications
- No data dependencies
- Different concerns (e.g., handler vs repository)

### Mark Sequential When
- Same file modified by multiple tasks
- One task generates code another uses
- Shared state or configuration changes
- Database migrations before code using new schema

## Design Patterns by Language

### Go
- Repository pattern with interfaces
- Functional options for configuration
- Context for cancellation and values

### TypeScript/React
- Hooks for shared logic
- Context for dependency injection
- Compound components for flexibility

### Java/Spring
- Spring annotations for DI
- Bean lifecycle management
- Aspect-oriented for cross-cutting

### Python
- Dependency injection via constructors
- Context managers for resources
- Abstract base classes for contracts

## Common Architectural Choices

| Decision | Options | When to Use |
|----------|---------|-------------|
| State Management | Local vs Global | Global for shared state, local for isolation |
| Communication | Sync vs Async | Async for I/O-bound, sync for CPU-bound |
| Storage | SQL vs NoSQL | SQL for relations, NoSQL for flexibility |
| Caching | In-memory vs Distributed | Distributed for multiple instances |
| Auth | Session vs Token | Token for stateless, session for stateful |

## When to Escalate

Suggest Opus model when:
- Architecture affects 5+ files or 3+ systems
- Security-sensitive design (auth, crypto, payment)
- Complex async/concurrency requirements
- User explicitly asks for "thorough" or "comprehensive" analysis
