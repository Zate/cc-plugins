---
name: go-patterns
description: This skill should be used when working with Go code, implementing Go features, reviewing Go patterns, or when the user asks about 'Go idioms', 'goroutines', 'Go interfaces', 'Go error handling', 'Go testing'.
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

### Small, Focused Interfaces

```go
// Good: Small, focused interfaces
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

// Compose when needed
type ReadWriter interface {
    Reader
    Writer
}
```

### Accept Interfaces, Return Structs

```go
// Good: Accept interface for flexibility
func ProcessData(r io.Reader) error {
    // Can accept any Reader
}

// Good: Return concrete type
func NewService() *Service {
    return &Service{}
}
```

---

## Error Handling (Go-Specific)

### Wrapping with Context

```go
if err != nil {
    return fmt.Errorf("failed to process user %s: %w", userID, err)
}

// Check wrapped errors
if errors.Is(err, ErrNotFound) { /* handle */ }

// Extract error type
var validationErr *ValidationError
if errors.As(err, &validationErr) { /* handle */ }
```

### Sentinel Errors

```go
var (
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
)
```

### Custom Error Types

```go
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed on %s: %s", e.Field, e.Message)
}
```

---

## Concurrency Patterns

### Goroutines with WaitGroup

```go
func processItems(items []Item) error {
    var wg sync.WaitGroup
    errCh := make(chan error, len(items))

    for _, item := range items {
        wg.Add(1)
        go func(item Item) {  // Pass item to avoid closure issue
            defer wg.Done()
            if err := process(item); err != nil {
                errCh <- err
            }
        }(item)
    }

    wg.Wait()
    close(errCh)
    return errors.Join(slices.Collect(slices.Values(errCh))...)
}
```

### Worker Pool

```go
func workerPool(jobs <-chan Job, results chan<- Result, workers int) {
    var wg sync.WaitGroup
    for i := 0; i < workers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for job := range jobs {
                results <- process(job)
            }
        }()
    }
    wg.Wait()
    close(results)
}
```

### Context for Cancellation

```go
func longRunningOperation(ctx context.Context) error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        default:
            if done := doWorkChunk(); done {
                return nil
            }
        }
    }
}
```

---

## Testing Patterns

### Table-Driven Tests

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive", 2, 3, 5},
        {"negative", -2, -3, -5},
        {"mixed", -2, 3, 1},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            if got := Add(tt.a, tt.b); got != tt.expected {
                t.Errorf("Add(%d, %d) = %d; want %d", tt.a, tt.b, got, tt.expected)
            }
        })
    }
}
```

### Test Helpers with Cleanup

```go
func setupTestDB(t *testing.T) *sql.DB {
    t.Helper()
    db, err := sql.Open("sqlite3", ":memory:")
    if err != nil {
        t.Fatalf("failed to open db: %v", err)
    }
    t.Cleanup(func() { db.Close() })
    return db
}
```

### Interface Mocking

```go
type UserStore interface {
    GetUser(id string) (*User, error)
}

type mockUserStore struct {
    users map[string]*User
    err   error
}

func (m *mockUserStore) GetUser(id string) (*User, error) {
    if m.err != nil { return nil, m.err }
    user, ok := m.users[id]
    if !ok { return nil, ErrNotFound }
    return user, nil
}
```

### Race Detection

Run with `go test -race` to detect data races.

```go
func TestConcurrentAccess(t *testing.T) {
    counter := NewCounter()
    var wg sync.WaitGroup
    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            counter.Increment()
        }()
    }
    wg.Wait()
    if got := counter.Value(); got != 100 {
        t.Errorf("got %d, want 100", got)
    }
}
```

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

---

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

---

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

### Embedding for Composition

```go
type Logger struct {
    *log.Logger  // All methods available
    prefix string
}
```

---

## Anti-Patterns (Go-Specific)

### Goroutine Leaks

```go
// BAD: No way to stop
go func() { for { doWork() } }()

// GOOD: Context-controlled
go func() {
    for {
        select {
        case <-ctx.Done(): return
        default: doWork()
        }
    }
}()
```

### Closure Variable Capture (pre-Go 1.22)

```go
// BAD: Captures final value
for _, item := range items {
    go func() { process(item) }()  // Wrong!
}

// GOOD: Pass as parameter
for _, item := range items {
    go func(item Item) { process(item) }(item)
}
```

### Swallowing Errors

```go
// BAD
result, _ := dangerousOperation()

// GOOD
if err != nil {
    return fmt.Errorf("operation failed: %w", err)
}
```

### Interface Pollution

- Don't define interfaces until you have 2+ implementations
- Keep interfaces small (1-3 methods)
- Don't abuse `init()` - prefer explicit initialization

---

## See Also

- `Skill: language-patterns-base` - Universal principles
- `Skill: testing-strategies` - Comprehensive test strategies
- `Skill: architecture-patterns` - High-level design
