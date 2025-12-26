---
name: architecture-patterns
description: This skill should be used when designing feature architecture, making architectural decisions, choosing design patterns, or when the user asks about "architecture design", "design patterns", "layered architecture", "hexagonal architecture", "microservices", "SOLID principles", "service layer", "repository pattern".
whenToUse: |
  - Designing feature architecture for new functionality
  - Making architectural decisions (layered, hexagonal, microservices)
  - Choosing design patterns (Factory, Strategy, Observer, etc.)
  - Understanding SOLID principles application
  - Planning service layer or repository patterns
whenNotToUse: |
  - Simple CRUD - don't over-architect basic data operations
  - Prototypes/spikes - architecture decisions come after validation
  - Existing patterns - match codebase conventions instead
  - Micro-optimizations - architecture is about structure, not performance
  - Bug fixes - fix the bug, don't redesign architecture
---

# Architecture Patterns

Comprehensive guidance for making sound architectural decisions across different languages and frameworks.

## When NOT to Use This Skill

- **Simple CRUD**: Don't over-architect basic data operations
- **Prototypes/spikes**: Architecture decisions come after validation
- **Existing patterns**: Match codebase conventions, don't introduce new patterns
- **Micro-optimizations**: Architecture is about structure, not performance tuning
- **Bug fixes**: Fix the bug, don't redesign the architecture

## Quick Reference: Common Patterns

| Pattern | Use When | Avoid When |
|---------|----------|------------|
| **Repository** | Data access abstraction | Simple CRUD only |
| **Service Layer** | Business logic coordination | No business logic |
| **Factory** | Complex object creation | Simple constructors work |
| **Strategy** | Interchangeable algorithms | Single algorithm |
| **Observer** | Event-driven updates | Tight coupling acceptable |
| **Decorator** | Add behavior dynamically | Inheritance simpler |
| **Adapter** | Interface compatibility | Direct integration possible |

## Architectural Styles

### Layered Architecture
```
┌─────────────────────────────────────┐
│         Presentation Layer          │  UI, Controllers, API
├─────────────────────────────────────┤
│         Application Layer           │  Use Cases, Services
├─────────────────────────────────────┤
│          Domain Layer               │  Business Logic, Entities
├─────────────────────────────────────┤
│        Infrastructure Layer         │  Database, External APIs
└─────────────────────────────────────┘
```

**Use when**: Traditional applications, clear separation needed
**Avoid when**: Microservices, event-driven systems

### Hexagonal Architecture (Ports & Adapters)
```
              ┌─────────────┐
    Adapters  │             │  Adapters
   (Primary)  │   Domain    │  (Secondary)
  ──────────► │   Core      │ ◄──────────
   HTTP API   │             │   Database
   CLI        │  Business   │   Cache
   Events     │   Logic     │   External
              └─────────────┘
```

**Use when**: Need to swap implementations, testability is priority
**Avoid when**: Simple applications, premature abstraction

### Microservices
**Use when**:
- Team scaling needed
- Independent deployment required
- Different tech stacks per service

**Avoid when**:
- Small team
- Simple domain
- Premature optimization

## Language-Specific Patterns

### Go Patterns

**Interface-First Design**:
```go
// Define small, focused interfaces
type UserReader interface {
    GetUser(id string) (*User, error)
}

type UserWriter interface {
    SaveUser(user *User) error
}

// Compose interfaces as needed
type UserRepository interface {
    UserReader
    UserWriter
}
```

**Functional Options**:
```go
type ServerOption func(*Server)

func WithPort(port int) ServerOption {
    return func(s *Server) {
        s.port = port
    }
}

func NewServer(opts ...ServerOption) *Server {
    s := &Server{port: 8080} // defaults
    for _, opt := range opts {
        opt(s)
    }
    return s
}
```

**Package Structure**:
```
myapp/
├── cmd/
│   └── myapp/main.go       # Entry point, minimal logic
├── internal/               # Private packages
│   ├── domain/             # Business entities, interfaces
│   ├── service/            # Business logic implementation
│   ├── repository/         # Data access (implements domain interfaces)
│   └── handler/            # HTTP/gRPC handlers
├── pkg/                    # Public libraries (use sparingly)
└── go.mod
```

**Middleware Composition** (for web frameworks):
```go
// Middleware signature
type Middleware func(http.Handler) http.Handler

// Compose middleware
func Chain(middlewares ...Middleware) Middleware {
    return func(final http.Handler) http.Handler {
        for i := len(middlewares) - 1; i >= 0; i-- {
            final = middlewares[i](final)
        }
        return final
    }
}

// Usage
handler := Chain(
    LoggingMiddleware,
    AuthMiddleware,
    RateLimitMiddleware,
)(finalHandler)
```

**Dependency Injection via Constructor**:
```go
// Service with explicit dependencies
type UserService struct {
    repo   UserRepository  // interface, not concrete
    logger *slog.Logger
    cache  Cache
}

func NewUserService(repo UserRepository, logger *slog.Logger, cache Cache) *UserService {
    return &UserService{repo: repo, logger: logger, cache: cache}
}

// Wire dependencies in main.go or using wire/fx
func main() {
    db := postgres.NewDB(...)
    repo := postgres.NewUserRepository(db)
    cache := redis.NewCache(...)
    logger := slog.Default()

    svc := NewUserService(repo, logger, cache)
}
```

### TypeScript/React Patterns

**Component Composition**:
```typescript
// Compound components
<Tabs>
  <Tabs.List>
    <Tabs.Tab>One</Tabs.Tab>
    <Tabs.Tab>Two</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panels>
    <Tabs.Panel>Content 1</Tabs.Panel>
    <Tabs.Panel>Content 2</Tabs.Panel>
  </Tabs.Panels>
</Tabs>
```

**Custom Hooks for Logic Reuse**:
```typescript
function useUser(id: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetchUser(id)
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [id]);

  return { user, loading, error };
}
```

### Java/Spring Patterns

**Dependency Injection**:
```java
@Service
public class UserService {
    private final UserRepository repository;
    private final EmailService emailService;

    // Constructor injection (preferred)
    public UserService(UserRepository repository,
                       EmailService emailService) {
        this.repository = repository;
        this.emailService = emailService;
    }
}
```

**Builder Pattern**:
```java
User user = User.builder()
    .name("John")
    .email("john@example.com")
    .role(Role.ADMIN)
    .build();
```

## Decision Framework

### When Choosing Architecture

1. **Start with requirements**
   - What are the scale requirements?
   - How will the team grow?
   - What's the deployment model?

2. **Consider constraints**
   - Existing infrastructure
   - Team expertise
   - Time constraints

3. **Prefer simplicity**
   - Start with monolith, extract services later
   - Add patterns only when needed
   - Avoid premature abstraction

### Red Flags to Watch For

- **Over-engineering**: Adding abstractions "just in case"
- **Pattern overload**: Using patterns for pattern's sake
- **Premature optimization**: Microservices for a small app
- **Ignoring context**: Copying patterns without understanding

## SOLID Principles

| Principle | Meaning | Example |
|-----------|---------|---------|
| **S**ingle Responsibility | One reason to change | Separate User from UserValidator |
| **O**pen/Closed | Open for extension, closed for modification | Use interfaces, not concrete types |
| **L**iskov Substitution | Subtypes must be substitutable | Don't violate parent contracts |
| **I**nterface Segregation | Small, focused interfaces | Split IUserService into IUserReader, IUserWriter |
| **D**ependency Inversion | Depend on abstractions | Inject interfaces, not implementations |

## See Also

- `references/go-patterns.md` - Go-specific patterns in depth
- `references/react-patterns.md` - React component patterns
- `references/java-patterns.md` - Java/Spring patterns
- `references/anti-patterns.md` - What to avoid
