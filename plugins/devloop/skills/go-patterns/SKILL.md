---
name: go-patterns
description: This skill should be used when working with Go code, implementing Go features, reviewing Go patterns, or when the user asks about "Go idioms", "goroutines", "Go interfaces", "Go error handling", "Go testing".
whenToUse: |
  - Working with Go 1.21+ code
  - Implementing idiomatic Go patterns
  - Using goroutines, channels, and concurrency primitives
  - Error handling with wrapping and context
  - Testing with table-driven tests and benchmarks
whenNotToUse: |
  - Non-Go code - use python-patterns, java-patterns, react-patterns
  - Match existing style - follow codebase conventions even if not idiomatic
  - Performance-critical hot paths - profile first, optimize with benchmarks
  - CGo interop - C integration has different patterns and constraints
---

# Go Patterns

Idiomatic Go patterns and best practices. **Extends** `language-patterns-base` with Go-specific guidance.

**Go Version**: Targets Go 1.21+. Some features (iterators, range-over-func) require Go 1.22+.

> For universal principles (AAA testing, separation of concerns, naming), see `Skill: language-patterns-base`.

## When NOT to Use This Skill

- **Non-Go code**: Use python-patterns, java-patterns, react-patterns instead
- **Match existing style**: Follow codebase conventions even if not "idiomatic"
- **Performance-critical hot paths**: Profile first, optimize with benchmarks
- **CGo interop**: C integration has different patterns and constraints

## Quick Reference

| Pattern | Use Case | Example |
|---------|----------|---------|
| Table-driven tests | Multiple test cases | `[]struct{name, input, want}` |
| Functional options | Configurable constructors | `WithTimeout(5*time.Second)` |
| Interface composition | Small, focused interfaces | `io.ReadWriter` |
| Error wrapping | Adding context | `fmt.Errorf("failed: %w", err)` |
| Context propagation | Cancellation, deadlines | `ctx context.Context` |

---

## Interface Design

**Key Principle**: Accept interfaces, return structs. Keep interfaces small (1-3 methods).

```go
// Small, focused interfaces
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Compose when needed
type ReadWriter interface {
    Reader
    Writer
}

// Accept interface, return struct
func ProcessData(r io.Reader) error { /* ... */ }
func NewService() *Service { return &Service{} }
```

**For detailed patterns**, see [references/interfaces.md](references/interfaces.md)

---

## Error Handling

**Always wrap with context** using `%w` verb. Use `errors.Is` for sentinel errors, `errors.As` for custom types.

```go
// Wrap errors
if err != nil {
    return fmt.Errorf("failed to process user %s: %w", userID, err)
}

// Sentinel errors
var ErrNotFound = errors.New("not found")

// Check wrapped errors
if errors.Is(err, ErrNotFound) { /* handle */ }
```

**For detailed patterns**, see [references/error-handling.md](references/error-handling.md)

---

## Concurrency

**Always provide cancellation** via context. Use `sync.WaitGroup` for goroutine lifecycle.

```go
func longRunningOperation(ctx context.Context) error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        default:
            doWorkChunk()
        }
    }
}
```

**For detailed patterns**, see [references/concurrency.md](references/concurrency.md)

---

## Testing

**Use table-driven tests** for multiple cases. Run with `-race` to detect concurrency bugs.

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name string
        a, b, want int
    }{
        {"positive", 2, 3, 5},
        {"negative", -2, -3, -5},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            if got := Add(tt.a, tt.b); got != tt.want {
                t.Errorf("got %d, want %d", got, tt.want)
            }
        })
    }
}
```

**For detailed patterns**, see [references/testing.md](references/testing.md)

---

## Functional Options

```go
type Server struct {
    addr    string
    timeout time.Duration
}

type ServerOption func(*Server)

func WithAddr(addr string) ServerOption {
    return func(s *Server) { s.addr = addr }
}

func WithTimeout(d time.Duration) ServerOption {
    return func(s *Server) { s.timeout = d }
}

func NewServer(opts ...ServerOption) *Server {
    s := &Server{addr: ":8080", timeout: 30 * time.Second}
    for _, opt := range opts {
        opt(s)
    }
    return s
}
```

## Project Structure

```
myproject/
├── cmd/myapp/main.go     # Entry point
├── internal/             # Private packages
│   ├── service/          # Business logic
│   ├── repository/       # Data access
│   └── handler/          # HTTP handlers
├── pkg/                  # Public libraries
├── go.mod
└── Makefile
```

## Go Idioms

### Defer for Cleanup

```go
f, err := os.Open(path)
if err != nil { return nil, err }
defer f.Close()
```

### Zero Values Are Useful

```go
var buf bytes.Buffer  // Ready to use
var mu  sync.Mutex    // Ready to use
```

## References

For detailed patterns and advanced usage:

- **[references/concurrency.md](references/concurrency.md)** - Goroutines, channels, context, worker pools, race detection
- **[references/testing.md](references/testing.md)** - Table-driven tests, mocking, benchmarks, golden files
- **[references/interfaces.md](references/interfaces.md)** - Interface design, composition, embedding patterns
- **[references/error-handling.md](references/error-handling.md)** - Error wrapping, custom errors, sentinel errors, inspection

## See Also

- `Skill: language-patterns-base` - Universal principles
- `Skill: testing-strategies` - Comprehensive test strategies
- `Skill: architecture-patterns` - High-level design
