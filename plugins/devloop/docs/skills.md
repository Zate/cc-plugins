# Devloop Skills

This document provides comprehensive information about the 17 skills in the devloop plugin.

## Overview

Skills are domain knowledge modules that Claude automatically applies when relevant. Unlike agents (which are spawned explicitly), skills are invoked declaratively when their expertise is needed.

**Think of skills as**:
- **Reference guides** Claude consults
- **Pattern libraries** for specific domains
- **Best practices** automatically applied
- **Context enrichment** for decision-making

---

## Skill Invocation

Skills can be invoked in two ways:

### 1. Automatic (Preferred)
Skills are auto-loaded based on context:
```markdown
# In agent frontmatter
skills: go-patterns, architecture-patterns
```

When this agent runs, these skills are automatically available without explicit invocation.

### 2. Explicit
When deeper guidance is needed:
```markdown
Skill: architecture-patterns
```

This explicitly invokes the skill for consultation.

---

## Architecture & Design Skills

### architecture-patterns
Design patterns, SOLID principles, and architectural best practices across languages.

**When to Use**:
- Designing new features
- Making architectural decisions
- Choosing design patterns
- Structuring codebases

**When NOT to Use**:
- Language-specific patterns (use language skills)
- During implementation (patterns already chosen)
- For trivial features

**Key Topics**:
- Design patterns (Factory, Strategy, Observer, etc.)
- SOLID principles
- Clean Architecture
- Domain-Driven Design
- Event-driven architecture
- Microservices patterns

**Auto-loaded by**: code-architect, code-explorer

---

### api-design
REST API design, GraphQL patterns, API versioning, and best practices.

**When to Use**:
- Designing API endpoints
- API versioning decisions
- REST vs GraphQL choices
- API documentation

**When NOT to Use**:
- Internal function design (not public APIs)
- Database schemas (use database-patterns)
- UI components

**Key Topics**:
- RESTful design principles
- HTTP methods and status codes
- Endpoint naming conventions
- Request/response formats
- Error handling patterns
- API versioning strategies
- GraphQL schema design
- Authentication/authorization

**Auto-loaded by**: code-architect (when API work detected)

---

### database-patterns
Database design, schema optimization, query patterns, and migrations.

**When to Use**:
- Designing database schemas
- Optimizing queries
- Planning migrations
- Choosing indexes

**When NOT to Use**:
- ORM-specific questions (use language skills)
- NoSQL design (limited coverage)
- Database administration

**Key Topics**:
- Normalization principles
- Index strategies
- Query optimization
- Migration patterns
- Relationship modeling
- Transaction handling
- Connection pooling
- N+1 query prevention

**Auto-loaded by**: code-architect (when database work detected)

---

## Language-Specific Skills

### go-patterns
**Go Version**: 1.21+

Go idioms, error handling, concurrency patterns, and modern Go features.

**When to Use**:
- Go code implementation
- Go architecture decisions
- Goroutine management
- Error handling patterns

**When NOT to Use**:
- Other languages
- Go basics (developers should know)
- Simple operations

**Key Topics**:
- **Interfaces**: Accept interfaces, return concrete types
- **Error handling**: Error wrapping with %w, context in errors
- **Goroutines**: Context for cancellation, sync primitives
- **Generics** (Go 1.18+): Type parameters, constraints
- **Struct patterns**: Embedding, composition over inheritance
- **Testing**: Table-driven tests, t.Helper(), subtests
- **Modules**: go.mod management, vendoring

**Go Idioms**:
```go
// Error wrapping
if err != nil {
    return fmt.Errorf("failed to process: %w", err)
}

// Interface design (small, focused)
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Context propagation
func DoWork(ctx context.Context, data Data) error {
    // Always first parameter
}

// Mutex with defer
mu.Lock()
defer mu.Unlock()
```

**Auto-loaded by**: code-architect, code-reviewer, test-generator (when language is Go)

---

### react-patterns
**React Version**: 18+

React hooks, component patterns, state management, and performance optimization.

**When to Use**:
- React component design
- State management decisions
- Hook usage
- Performance optimization

**When NOT to Use**:
- Other frontend frameworks
- React basics
- CSS styling (separate concern)

**Key Topics**:
- **Hooks**: useState, useEffect, useCallback, useMemo
- **Component patterns**: Composition, render props, HOCs
- **State management**: Context, local state, external stores
- **Performance**: React.memo, useMemo, lazy loading
- **Accessibility**: ARIA, semantic HTML, keyboard nav
- **Testing**: React Testing Library patterns
- **TypeScript**: Component typing, prop types

**React Patterns**:
```typescript
// Custom hooks
function useLocalStorage(key: string, initialValue: string) {
  const [stored, setStored] = useState(() => {
    return localStorage.getItem(key) ?? initialValue;
  });
  // ...
}

// Memoization
const expensiveValue = useMemo(() => {
  return computeExpensiveValue(a, b);
}, [a, b]);

// Component composition
<Card>
  <Card.Header>Title</Card.Header>
  <Card.Body>Content</Card.Body>
</Card>
```

**Auto-loaded by**: code-architect, code-reviewer, test-generator (when React detected)

---

### java-patterns
**Java Version**: 17+

Spring framework, records, streams, dependency injection, and modern Java features.

**When to Use**:
- Java/Spring application design
- Dependency injection patterns
- Stream API usage
- Modern Java features

**When NOT to Use**:
- Legacy Java (<17)
- Other JVM languages (Kotlin, Scala)
- Simple Java basics

**Key Topics**:
- **Spring Framework**: Dependency injection, Spring Boot
- **Records** (Java 14+): Immutable data classes
- **Streams**: Functional operations, collectors
- **Pattern matching** (Java 16+): instanceof patterns
- **Sealed classes** (Java 17+): Restricted hierarchies
- **Virtual threads** (Java 21+): Lightweight concurrency
- **Testing**: JUnit 5, Mockito, Spring Test

**Java Patterns**:
```java
// Records for DTOs
public record UserDTO(String id, String name, String email) {}

// Stream processing
List<String> names = users.stream()
    .filter(user -> user.isActive())
    .map(User::getName)
    .collect(Collectors.toList());

// Dependency injection (Spring)
@Service
public class UserService {
    private final UserRepository repository;

    public UserService(UserRepository repository) {
        this.repository = repository;
    }
}
```

**Auto-loaded by**: code-architect, code-reviewer, test-generator (when Java detected)

---

### python-patterns
**Python Version**: 3.10+

Type hints, async/await, pytest patterns, and modern Python features.

**When to Use**:
- Python application design
- Type hint usage
- Async programming
- Testing patterns

**When NOT to Use**:
- Legacy Python (<3.10)
- Simple scripts
- Data science (different patterns)

**Key Topics**:
- **Type hints**: Function annotations, generics
- **Async/await**: Asyncio patterns, coroutines
- **Dataclasses**: Structured data with less boilerplate
- **Pattern matching** (3.10+): match/case statements
- **Context managers**: with statements, __enter__/__exit__
- **Pytest**: Fixtures, parametrize, mocking
- **Virtual environments**: venv, poetry, uv

**Python Patterns**:
```python
# Type hints
def process_user(user: User) -> Optional[Result]:
    ...

# Dataclasses
from dataclasses import dataclass

@dataclass
class User:
    id: str
    name: str
    email: str

# Pattern matching (3.10+)
match status:
    case "active":
        return activate_user()
    case "inactive":
        return deactivate_user()
    case _:
        raise ValueError("Unknown status")

# Async/await
async def fetch_data(url: str) -> dict:
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.json()
```

**Auto-loaded by**: code-architect, code-reviewer, test-generator (when Python detected)

---

## Quality & Testing Skills

### testing-strategies
Comprehensive test design, coverage strategies, and test pyramid principles.

**When to Use**:
- Planning test coverage
- Designing test suites
- Choosing test types
- Test architecture decisions

**When NOT to Use**:
- Writing specific tests (use test-generator)
- Running tests (use test-runner)
- Framework-specific syntax

**Key Topics**:
- **Test pyramid**: Unit → Integration → E2E ratios
- **Test types**: Unit, integration, E2E, smoke, regression
- **Coverage strategies**: What to test, what to skip
- **Test data**: Fixtures, factories, mocks
- **Flaky tests**: Prevention and debugging
- **TDD**: Red-Green-Refactor cycle
- **BDD**: Given-When-Then scenarios

**Testing Principles**:
- Test behavior, not implementation
- One assertion per test (guideline)
- Arrange-Act-Assert pattern
- Fast, isolated, repeatable tests
- Test edge cases, not just happy path

**Auto-loaded by**: test-generator, test-runner, qa-agent

---

### security-checklist
OWASP Top 10, authentication, authorization, and data protection best practices.

**When to Use**:
- Security-sensitive code
- Authentication/authorization
- Data handling
- Input validation

**When NOT to Use**:
- For comprehensive security audit (use security-scanner)
- Infrastructure security (out of scope)
- Compliance requirements

**Key Topics**:
- **OWASP Top 10**: Injection, auth failures, sensitive data exposure
- **Authentication**: Password hashing, tokens, MFA
- **Authorization**: RBAC, ABAC, principle of least privilege
- **Input validation**: Sanitization, whitelisting
- **Cryptography**: Hashing, encryption, key management
- **Secure communication**: TLS, certificate pinning
- **Logging**: What to log, what NOT to log

**Security Checklist**:
- [ ] No hardcoded secrets
- [ ] Input validation on all user data
- [ ] SQL/command injection prevention
- [ ] XSS prevention
- [ ] CSRF protection
- [ ] Secure password storage (bcrypt, argon2)
- [ ] Proper error handling (no stack traces to users)

**Auto-loaded by**: security-scanner, code-reviewer

---

### deployment-readiness
Pre-deployment validation, production considerations, and release checklists.

**When to Use**:
- Before deploying to production
- Release preparation
- Production readiness checks
- Environment validation

**When NOT to Use**:
- During development
- For CI/CD configuration (different concern)
- Infrastructure setup

**Key Topics**:
- **Configuration**: Environment variables, secrets management
- **Monitoring**: Logging, metrics, alerting
- **Performance**: Load testing, resource limits
- **Rollback plan**: Versioning, rollback strategy
- **Health checks**: Endpoint availability, dependency checks
- **Documentation**: Deployment guide, runbooks
- **Communication**: Stakeholder notification, status pages

**Deployment Checklist**:
- [ ] All tests passing
- [ ] Build succeeds without warnings
- [ ] Configuration externalized
- [ ] Secrets not in code
- [ ] Database migrations tested
- [ ] Rollback plan documented
- [ ] Monitoring configured
- [ ] Health checks implemented

**Auto-loaded by**: qa-agent

---

## Workflow Skills

### workflow-selection
Guide for choosing the right development workflow (feature/bug/refactor/QA).

**When to Use**:
- Task type is ambiguous
- Routing decisions needed
- Workflow optimization
- Understanding workflow differences

**When NOT to Use**:
- Task type is obvious
- User specified workflow explicitly
- During active implementation

**Key Topics**:
- **Feature workflow**: 7-phase complete development
- **Bug fix workflow**: 5-phase streamlined
- **Refactor workflow**: 6-phase with extended analysis
- **QA workflow**: 5-phase test-focused
- **Mixed tasks**: Handling combined work types
- **Classification**: Keywords and indicators

**Decision Tree**:
```
Is this new functionality? → Feature workflow
Is something broken? → Bug fix workflow
Improving code without behavior change? → Refactor workflow
About testing/QA? → QA workflow
```

**Auto-loaded by**: workflow-detector

---

### model-selection-guide
Guidelines for choosing opus/sonnet/haiku based on task complexity and quality needs.

**When to Use**:
- Making model selection decisions
- Optimizing token budget
- Escalating/downgrading models
- Understanding cost/quality trade-offs

**When NOT to Use**:
- In agents (model pre-assigned)
- For trivial decisions
- When user specified model

**Key Topics**:
- **20/60/20 strategy**: Opus 20%, Sonnet 60%, Haiku 20%
- **Model characteristics**: Speed vs quality
- **Escalation rules**: When to upgrade
- **Thinking mode**: When to enable extended thinking
- **Token budgets**: Per-phase allocation
- **Cost optimization**: Parallel haiku vs single sonnet

**Model Selection**:
- **Haiku**: Classification, docs, tests, simple ops
- **Sonnet**: Exploration, design, implementation, most analysis
- **Opus**: Architecture (complex), review, security, debugging

**Thinking Mode**: Enable for complexity >7/10, architectural decisions, security analysis.

**Auto-loaded by**: None (consulted by commands)

---

### complexity-estimation
Framework for T-shirt sizing, risk assessment, and spike recommendations.

**When to Use**:
- Estimating task effort
- Risk identification
- Spike decisions
- Setting expectations

**When NOT to Use**:
- After implementation started
- For trivial tasks
- When complexity is obvious

**Key Topics**:
- **T-shirt sizes**: XS/S/M/L/XL scoring
- **Complexity factors**: Files, concepts, integration, data, tests, risk, uncertainty
- **Scoring system**: 1-5 per factor, total determines size
- **Risk categories**: Technical, integration, data, timeline, security
- **Spike threshold**: Score ≥25 or any factor = 5

**Complexity Factors** (1-5 each):
1. Files touched
2. New concepts needed
3. Integration points
4. Data changes
5. Testing complexity
6. Regression risk
7. Uncertainty level

**Size Mapping**:
- **XS** (7-10): Single file, clear pattern
- **S** (11-15): Few files, existing patterns
- **M** (16-22): Multiple components, some new patterns
- **L** (23-28): Cross-cutting changes, new architecture
- **XL** (29-35): Major feature, significant unknowns

**Auto-loaded by**: complexity-estimator

---

### requirements-patterns
Techniques for gathering requirements, writing user stories, and defining acceptance criteria.

**When to Use**:
- Clarifying vague requests
- Writing user stories
- Defining acceptance criteria
- Scope definition

**When NOT to Use**:
- Requirements already clear
- During implementation
- For trivial features

**Key Topics**:
- **User stories**: As a [role], I want [goal], so that [benefit]
- **Acceptance criteria**: Given-When-Then format
- **Scope boundaries**: In scope vs out of scope
- **Edge cases**: Error scenarios, limits, constraints
- **Non-functional requirements**: Performance, security, accessibility
- **Questioning techniques**: Open-ended, clarifying, probing

**User Story Template**:
```markdown
As a [user type]
I want to [action]
So that [benefit]

Acceptance Criteria:
- Given [context], when [action], then [outcome]
- Given [context], when [action], then [outcome]
```

**Auto-loaded by**: requirements-gatherer

---

### git-workflows
Git branching strategies, commit conventions, and release management.

**When to Use**:
- Git workflow decisions
- Branching strategies
- Commit message format
- Release planning

**When NOT to Use**:
- For git operations (use git-manager)
- Simple commits
- During implementation

**Key Topics**:
- **Branching strategies**: Git Flow, GitHub Flow, trunk-based
- **Conventional commits**: Type, scope, description format
- **Branch naming**: feature/, fix/, hotfix/, release/
- **PR best practices**: Title, description, size
- **Semantic versioning**: MAJOR.MINOR.PATCH
- **Release process**: Tags, changelogs, notes

**Conventional Commit Format**:
```
<type>(<scope>): <description>

[body]

[footer]
```

**Types**: feat, fix, docs, style, refactor, perf, test, chore, ci

**Auto-loaded by**: git-manager

---

### plan-management
Central reference for devloop plan file location, format, and update procedures.

**When to Use**:
- Working with devloop plans
- Understanding plan format
- Plan update rules
- Agent responsibilities

**When NOT to Use**:
- Quick tasks without plans
- Bug fixes (use bug tracking)
- Exploratory spikes

**Key Topics**:
- **Plan location**: `.claude/devloop-plan.md` (canonical)
- **Plan format**: Markdown with frontmatter
- **Task markers**: [ ] pending, [x] complete, [~] in progress
- **Update rules**: When to mark tasks, update status
- **Agent permissions**: Who can read, who can update
- **Progress log**: Timestamped event history

**Plan File Location**: `.claude/devloop-plan.md`

**Task Markers**:
- `- [ ]` Pending
- `- [x]` Complete
- `- [~]` In progress
- `- [-]` Skipped
- `- [!]` Blocked

**Auto-loaded by**: All agents that interact with plans

---

### bug-tracking
Bug report format, storage location, and bug management workflows.

**When to Use**:
- Creating bug reports
- Managing bug tracker
- Understanding bug format
- Bug workflow decisions

**When NOT to Use**:
- For feature requests
- Critical bugs (fix immediately)
- During active bug fixing

**Key Topics**:
- **Bug location**: `.claude/bugs/BUG-NNN.md`
- **Bug format**: Frontmatter with title, status, priority
- **Bug lifecycle**: open → in-progress → fixed/wont-fix
- **Priority levels**: low, medium, high
- **Tags**: ui, api, formatting, logic, performance, docs
- **Index management**: `.claude/bugs/index.md`

**Bug File Format**:
```markdown
---
id: BUG-NNN
title: Brief description
status: open | in-progress | fixed | wont-fix
priority: low | medium | high
created: ISO timestamp
updated: ISO timestamp
reporter: agent-name or "user"
tags: [ui, api, etc.]
related-files:
  - file/path.ts
---

# BUG-NNN: Title

## Description
[What's wrong]

## Context
- Discovered during: [context]
- Blocking: no

## Suggested Fix
[If provided]
```

**Auto-loaded by**: bug-catcher, test-runner, code-reviewer

---

## Skill Comparison Table

### By Category

| Category | Skills | Auto-invoked | Explicit-only |
|----------|--------|--------------|---------------|
| **Architecture** | architecture-patterns, api-design, database-patterns | ✅ | ❌ |
| **Languages** | go-patterns, react-patterns, java-patterns, python-patterns | ✅ | ❌ |
| **Quality** | testing-strategies, security-checklist, deployment-readiness | ✅ | ❌ |
| **Workflow** | workflow-selection, model-selection-guide, complexity-estimation, requirements-patterns, git-workflows, plan-management, bug-tracking | ❌ | ✅ |

### By Frequency of Use

| Frequency | Skills |
|-----------|--------|
| **Very High** (used in most features) | architecture-patterns, testing-strategies, plan-management |
| **High** (used when language matches) | go-patterns, react-patterns, java-patterns, python-patterns |
| **Medium** (used in specific phases) | api-design, database-patterns, git-workflows, complexity-estimation |
| **Low** (consulted when needed) | workflow-selection, model-selection-guide, requirements-patterns, bug-tracking |
| **Situational** | security-checklist, deployment-readiness |

### By Version Requirements

| Skill | Min Version | Notes |
|-------|-------------|-------|
| go-patterns | Go 1.21+ | Includes generics |
| react-patterns | React 18+ | Modern hooks |
| java-patterns | Java 17+ | Records, sealed classes |
| python-patterns | Python 3.10+ | Pattern matching |
| Others | N/A | Language-agnostic |

---

## Usage Examples

### Explicit Invocation
```markdown
# In a command or agent
Skill: architecture-patterns
```

### Auto-loading (Agent Frontmatter)
```markdown
---
name: code-architect
skills: architecture-patterns, go-patterns, react-patterns
---
```

### Conditional Invocation
```markdown
# Only invoke if database work detected
if database_changes_detected:
    Skill: database-patterns
```

---

## Best Practices

### When to Invoke Skills
- **Architecture phase**: architecture-patterns, language-specific
- **Planning phase**: testing-strategies
- **Review phase**: security-checklist
- **Pre-deployment**: deployment-readiness
- **When uncertain**: Consult relevant skill

### When NOT to Invoke Skills
- Don't invoke for obvious decisions
- Don't chain multiple skills unnecessarily
- Don't invoke during simple operations
- Trust auto-loading in agents

### Skill Composition
Skills can be combined:
```markdown
Skill: architecture-patterns
Skill: go-patterns
```

But prefer auto-loading via agent frontmatter.

---

## Creating New Skills

Skills are stored in `plugins/devloop/skills/<skill-name>/SKILL.md`.

**Minimum structure**:
```markdown
---
name: skill-name
description: What this skill provides
---

# Skill Name

Detailed guidance for the skill topic.

## When NOT to Use This Skill

[Important: prevents over-use]

## Key Topics

[Main concepts covered]
```

---

## Related Documentation

- [Agents](agents.md) - Agents that invoke skills
- [Commands](commands.md) - Commands that reference skills
- [Workflow](workflow.md) - When skills are used in the workflow
