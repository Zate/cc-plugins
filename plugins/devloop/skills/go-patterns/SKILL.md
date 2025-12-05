---
name: go-patterns
description: Go-specific best practices including interfaces, error handling, goroutines, channels, testing patterns, and common idioms. Use when working on Go codebases or making Go-specific design decisions.
---

# Go Patterns

Idiomatic Go patterns and best practices for writing clean, efficient Go code.

## Quick Reference

| Pattern | Use Case | Example |
|---------|----------|---------|
| Table-driven tests | Testing multiple cases | `[]struct{name, input, want}` |
| Functional options | Configurable constructors | `WithTimeout(5*time.Second)` |
| Interface composition | Small, focused interfaces | `io.ReadWriter` |
| Error wrapping | Adding context | `fmt.Errorf("failed: %w", err)` |
| Context propagation | Cancellation, deadlines | `ctx context.Context` |

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
// Good: Accept interface
func ProcessData(r io.Reader) error {
    // Can accept any Reader
}

// Good: Return concrete type
func NewService() *Service {
    return &Service{}
}
```

## Error Handling

### Wrapping Errors

```go
// Add context to errors
if err != nil {
    return fmt.Errorf("failed to process user %s: %w", userID, err)
}

// Check wrapped errors
if errors.Is(err, ErrNotFound) {
    // Handle not found
}

// Extract wrapped error type
var validationErr *ValidationError
if errors.As(err, &validationErr) {
    // Handle validation error
}
```

### Sentinel Errors

```go
// Define package-level errors
var (
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
    ErrInvalidInput = errors.New("invalid input")
)

// Usage
if err == ErrNotFound {
    // Handle not found
}
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

## Concurrency Patterns

### Goroutines with WaitGroup

```go
func processItems(items []Item) error {
    var wg sync.WaitGroup
    errCh := make(chan error, len(items))

    for _, item := range items {
        wg.Add(1)
        go func(item Item) {
            defer wg.Done()
            if err := process(item); err != nil {
                errCh <- err
            }
        }(item) // Pass item to avoid closure issue
    }

    wg.Wait()
    close(errCh)

    // Collect errors
    var errs []error
    for err := range errCh {
        errs = append(errs, err)
    }
    return errors.Join(errs...)
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
            // Do work
            if done := doWorkChunk(); done {
                return nil
            }
        }
    }
}
```

## Testing Patterns

### Table-Driven Tests

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -2, -3, -5},
        {"mixed", -2, 3, 1},
        {"zeros", 0, 0, 0},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Add(tt.a, tt.b)
            if got != tt.expected {
                t.Errorf("Add(%d, %d) = %d; want %d",
                    tt.a, tt.b, got, tt.expected)
            }
        })
    }
}
```

### Test Helpers

```go
// Helper function for test setup
func setupTestDB(t *testing.T) *sql.DB {
    t.Helper() // Marks as helper for better error reporting

    db, err := sql.Open("sqlite3", ":memory:")
    if err != nil {
        t.Fatalf("failed to open db: %v", err)
    }

    t.Cleanup(func() {
        db.Close()
    })

    return db
}
```

### Interface-Based Mocking

```go
// Define interface for dependency
type UserStore interface {
    GetUser(id string) (*User, error)
    SaveUser(user *User) error
}

// Mock implementation for tests
type mockUserStore struct {
    users map[string]*User
    err   error  // simulate errors
}

func newMockUserStore() *mockUserStore {
    return &mockUserStore{users: make(map[string]*User)}
}

func (m *mockUserStore) GetUser(id string) (*User, error) {
    if m.err != nil {
        return nil, m.err
    }
    user, ok := m.users[id]
    if !ok {
        return nil, ErrNotFound
    }
    return user, nil
}

func (m *mockUserStore) SaveUser(user *User) error {
    if m.err != nil {
        return m.err
    }
    m.users[user.ID] = user
    return nil
}

// Usage in tests
func TestUserService_GetUser(t *testing.T) {
    store := newMockUserStore()
    store.users["123"] = &User{ID: "123", Name: "Alice"}

    svc := NewUserService(store)
    user, err := svc.GetUser("123")

    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if user.Name != "Alice" {
        t.Errorf("got %s, want Alice", user.Name)
    }
}

// Test error conditions
func TestUserService_GetUser_NotFound(t *testing.T) {
    store := newMockUserStore()
    svc := NewUserService(store)

    _, err := svc.GetUser("nonexistent")
    if !errors.Is(err, ErrNotFound) {
        t.Errorf("got %v, want ErrNotFound", err)
    }
}
```

### Testing Concurrent Code

```go
// Test for race conditions - run with: go test -race
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

// Test goroutine cleanup
func TestWorker_Shutdown(t *testing.T) {
    ctx, cancel := context.WithCancel(context.Background())
    done := make(chan struct{})

    go func() {
        Worker(ctx)
        close(done)
    }()

    cancel() // Signal shutdown

    select {
    case <-done:
        // Worker exited cleanly
    case <-time.After(time.Second):
        t.Fatal("worker did not shut down in time")
    }
}

// Test channel behavior
func TestProducer(t *testing.T) {
    ch := make(chan int, 10)
    ctx, cancel := context.WithTimeout(context.Background(), time.Second)
    defer cancel()

    go Producer(ctx, ch)

    var received []int
    for val := range ch {
        received = append(received, val)
    }

    if len(received) == 0 {
        t.Error("expected to receive values")
    }
}
```

## Functional Options

```go
type Server struct {
    addr    string
    timeout time.Duration
    logger  *log.Logger
}

type ServerOption func(*Server)

func WithAddr(addr string) ServerOption {
    return func(s *Server) {
        s.addr = addr
    }
}

func WithTimeout(d time.Duration) ServerOption {
    return func(s *Server) {
        s.timeout = d
    }
}

func NewServer(opts ...ServerOption) *Server {
    s := &Server{
        addr:    ":8080",           // defaults
        timeout: 30 * time.Second,
    }
    for _, opt := range opts {
        opt(s)
    }
    return s
}

// Usage
server := NewServer(
    WithAddr(":3000"),
    WithTimeout(5 * time.Second),
)
```

## Project Structure

```
myproject/
├── cmd/
│   └── myapp/
│       └── main.go          # Entry point
├── internal/
│   ├── service/             # Business logic
│   ├── repository/          # Data access
│   └── handler/             # HTTP handlers
├── pkg/                     # Public libraries
├── go.mod
├── go.sum
└── Makefile
```

## Common Idioms

### Defer for Cleanup

```go
func readFile(path string) ([]byte, error) {
    f, err := os.Open(path)
    if err != nil {
        return nil, err
    }
    defer f.Close() // Always close

    return io.ReadAll(f)
}
```

### Zero Values Are Useful

```go
var (
    buf bytes.Buffer  // Ready to use, no initialization needed
    mu  sync.Mutex    // Ready to use
    wg  sync.WaitGroup
)
```

### Embedding for Composition

```go
type Logger struct {
    *log.Logger  // Embedded, all methods available
    prefix string
}
```

## Anti-Patterns to Avoid

### Critical Anti-Patterns
- **Ignoring errors**: Always handle or explicitly ignore with `_ = fn()` comment
- **Goroutine leaks**: Always ensure goroutines can exit (use context, done channels)
- **Shared mutable state without sync**: Race conditions - use mutexes or channels
- **Panic for normal errors**: Use error returns; panic only for programmer errors

### Code Quality Anti-Patterns
- **Naked returns in long functions**: Hard to read, use explicit returns
- **Interface pollution**: Don't define interfaces until you have 2+ implementations
- **Accepting concrete types**: Accept interfaces for flexibility, return concrete types
- **Large interfaces**: Keep interfaces small (1-3 methods), compose when needed
- **init() abuse**: Avoid side effects in init(); prefer explicit initialization

### Concurrency Anti-Patterns
```go
// BAD: Goroutine leak - no way to stop
func bad() {
    go func() {
        for {
            doWork() // runs forever
        }
    }()
}

// GOOD: Stoppable goroutine
func good(ctx context.Context) {
    go func() {
        for {
            select {
            case <-ctx.Done():
                return
            default:
                doWork()
            }
        }
    }()
}

// BAD: Closure captures loop variable (pre-Go 1.22)
for _, item := range items {
    go func() {
        process(item) // captures final value only!
    }()
}

// GOOD: Pass as parameter
for _, item := range items {
    go func(item Item) {
        process(item)
    }(item)
}
```

### Error Handling Anti-Patterns
```go
// BAD: Swallowing errors
result, _ := dangerousOperation()

// BAD: Returning error without context
if err != nil {
    return err
}

// GOOD: Wrap with context
if err != nil {
    return fmt.Errorf("failed to process user %s: %w", userID, err)
}
```

## See Also

- `references/interfaces.md` - Interface design in depth
- `references/concurrency.md` - Goroutine patterns
- `references/testing.md` - Advanced testing patterns
