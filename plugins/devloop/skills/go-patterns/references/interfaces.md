# Go Interface Design Patterns

Comprehensive patterns for designing small, focused interfaces and using composition effectively in Go.

## Small, Focused Interfaces

### Single-Method Interfaces

```go
// Good: Small, focused interfaces
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

type Closer interface {
    Close() error
}

// Compose when needed
type ReadWriter interface {
    Reader
    Writer
}

type ReadWriteCloser interface {
    Reader
    Writer
    Closer
}
```

**Key Points**:
- Prefer 1-3 methods per interface
- Name single-method interfaces with "-er" suffix (Reader, Writer, Closer)
- Compose small interfaces into larger ones
- Define interfaces where they're used, not where they're implemented

### Interface Composition

```go
// Domain-specific interfaces
type UserReader interface {
    GetUser(id string) (*User, error)
    ListUsers() ([]*User, error)
}

type UserWriter interface {
    CreateUser(user *User) error
    UpdateUser(user *User) error
    DeleteUser(id string) error
}

// Composed interface for full access
type UserRepository interface {
    UserReader
    UserWriter
}

// Usage: Accept smallest interface needed
func DisplayUser(id string, reader UserReader) {
    user, _ := reader.GetUser(id)
    fmt.Println(user)
}

func CreateAndDisplay(user *User, repo UserRepository) {
    repo.CreateUser(user)
    DisplayUser(user.ID, repo)  // Passes UserRepository as UserReader
}
```

## Accept Interfaces, Return Structs

```go
// Good: Accept interface for flexibility
func ProcessData(r io.Reader) error {
    // Can accept *os.File, *bytes.Buffer, *strings.Reader, etc.
    data, err := io.ReadAll(r)
    if err != nil {
        return err
    }
    // Process data
    return nil
}

// Good: Return concrete type
func NewService(repo UserRepository) *UserService {
    return &UserService{repo: repo}
}

// Avoid: Returning interface unless necessary
func NewCache() Cache {  // Only if multiple implementations exist
    return &MemoryCache{}
}
```

**Why?**
- Accepting interfaces: Callers can pass any implementation
- Returning structs: Allows future method additions without breaking compatibility

## Interface Satisfaction

### Implicit Implementation

```go
type Shape interface {
    Area() float64
}

// Circle implicitly satisfies Shape
type Circle struct {
    Radius float64
}

func (c Circle) Area() float64 {
    return math.Pi * c.Radius * c.Radius
}

// Compile-time check that Circle implements Shape
var _ Shape = Circle{}
var _ Shape = (*Circle)(nil)  // For pointer receivers
```

### Type Assertions and Type Switches

```go
func Describe(i interface{}) {
    switch v := i.(type) {
    case int:
        fmt.Printf("Integer: %d\n", v)
    case string:
        fmt.Printf("String: %s\n", v)
    case Shape:
        fmt.Printf("Shape with area: %f\n", v.Area())
    default:
        fmt.Printf("Unknown type: %T\n", v)
    }
}

// Type assertion with check
func PrintArea(i interface{}) {
    if shape, ok := i.(Shape); ok {
        fmt.Printf("Area: %f\n", shape.Area())
    } else {
        fmt.Println("Not a shape")
    }
}
```

## Embedding for Composition

### Struct Embedding

```go
type Logger struct {
    *log.Logger  // Embedded logger
    prefix string
}

func NewLogger(prefix string) *Logger {
    return &Logger{
        Logger: log.New(os.Stdout, prefix, log.LstdFlags),
        prefix: prefix,
    }
}

// All methods of log.Logger are available on Logger
func (l *Logger) LogWithContext(ctx context.Context, msg string) {
    l.Printf("[%s] %s", l.prefix, msg)  // Uses embedded Logger.Printf
}
```

### Interface Embedding (Delegation)

```go
// Base implementation
type BaseRepository struct {
    db *sql.DB
}

func (r *BaseRepository) Begin() (*sql.Tx, error) {
    return r.db.Begin()
}

// Specialized repository embeds base
type UserRepository struct {
    *BaseRepository  // Inherits Begin() method
}

func (r *UserRepository) GetUser(id string) (*User, error) {
    // Can use r.Begin() from embedded BaseRepository
    return nil, nil
}
```

## Interface Design Patterns

### Option Pattern with Interfaces

```go
type Server interface {
    Start() error
    Stop() error
}

type server struct {
    addr    string
    timeout time.Duration
}

type ServerOption func(*server)

func WithAddr(addr string) ServerOption {
    return func(s *server) { s.addr = addr }
}

func WithTimeout(d time.Duration) ServerOption {
    return func(s *server) { s.timeout = d }
}

func NewServer(opts ...ServerOption) Server {
    s := &server{
        addr:    ":8080",
        timeout: 30 * time.Second,
    }
    for _, opt := range opts {
        opt(s)
    }
    return s
}
```

### Strategy Pattern

```go
type PaymentProcessor interface {
    ProcessPayment(amount float64) error
}

type CreditCardProcessor struct{}
func (p *CreditCardProcessor) ProcessPayment(amount float64) error {
    fmt.Printf("Processing credit card payment: $%.2f\n", amount)
    return nil
}

type PayPalProcessor struct{}
func (p *PayPalProcessor) ProcessPayment(amount float64) error {
    fmt.Printf("Processing PayPal payment: $%.2f\n", amount)
    return nil
}

type PaymentService struct {
    processor PaymentProcessor
}

func (s *PaymentService) Pay(amount float64) error {
    return s.processor.ProcessPayment(amount)
}

// Usage
creditCard := &PaymentService{processor: &CreditCardProcessor{}}
creditCard.Pay(100.0)

paypal := &PaymentService{processor: &PayPalProcessor{}}
paypal.Pay(50.0)
```

## Anti-Patterns

### Interface Pollution

```go
// BAD: Interface with too many methods
type UserService interface {
    CreateUser(*User) error
    UpdateUser(*User) error
    DeleteUser(string) error
    GetUser(string) (*User, error)
    ListUsers() ([]*User, error)
    ValidateUser(*User) error
    SendWelcomeEmail(*User) error
    ResetPassword(string) error
}

// GOOD: Split into focused interfaces
type UserReader interface {
    GetUser(id string) (*User, error)
    ListUsers() ([]*User, error)
}

type UserWriter interface {
    CreateUser(*User) error
    UpdateUser(*User) error
    DeleteUser(string) error
}

type UserValidator interface {
    ValidateUser(*User) error
}
```

### Premature Interface Definition

```go
// BAD: Define interface before you have 2+ implementations
type UserRepository interface {
    GetUser(id string) (*User, error)
}

type PostgresUserRepository struct {
    // Only implementation
}

// GOOD: Start with concrete type, extract interface when needed
type UserRepository struct {
    db *sql.DB
}

func (r *UserRepository) GetUser(id string) (*User, error) {
    // Implementation
    return nil, nil
}

// Later, when you add MySQL implementation, extract interface
```

### Fat Interfaces in Dependencies

```go
// BAD: Accepting large interface when only using part of it
func SendNotification(db *sql.DB, userID string) error {
    // Only needs to read users, but accepts full database
}

// GOOD: Define minimal interface for needs
type UserGetter interface {
    GetUser(id string) (*User, error)
}

func SendNotification(userGetter UserGetter, userID string) error {
    user, err := userGetter.GetUser(userID)
    // ...
}
```

## Best Practices

1. **Keep interfaces small** - 1-3 methods is ideal
2. **Define interfaces at usage site** - Not next to implementation
3. **Name single-method interfaces with -er** - Reader, Writer, Closer
4. **Accept interfaces, return structs** - Maximum flexibility
5. **Don't define interfaces until you need them** - Wait for 2+ implementations
6. **Use embedding for composition** - Prefer composition over inheritance
7. **Compile-time interface checks** - `var _ Interface = (*Type)(nil)`

## See Also

- [Effective Go - Interfaces](https://go.dev/doc/effective_go#interfaces)
- `Skill: architecture-patterns` - High-level design patterns
- `references/error-handling.md` - Error interface patterns
