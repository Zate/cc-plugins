# Go Error Handling Patterns

Comprehensive error handling patterns including wrapping, custom errors, sentinel errors, and error inspection.

## Error Wrapping with Context

### Basic Wrapping

```go
func processUser(id string) error {
    user, err := fetchUser(id)
    if err != nil {
        return fmt.Errorf("failed to process user %s: %w", id, err)
    }

    if err := validateUser(user); err != nil {
        return fmt.Errorf("user validation failed: %w", err)
    }

    return nil
}
```

**Key Points**:
- Use `%w` verb to wrap errors (preserves error chain)
- Add context to errors as they bubble up
- Don't just wrap blindly - add meaningful context

### Multi-Level Wrapping

```go
// Level 1: Database layer
func (r *Repository) GetUser(id string) (*User, error) {
    row := r.db.QueryRow("SELECT * FROM users WHERE id = ?", id)
    var user User
    if err := row.Scan(&user.ID, &user.Name); err != nil {
        if err == sql.ErrNoRows {
            return nil, fmt.Errorf("user not found: %w", ErrNotFound)
        }
        return nil, fmt.Errorf("database scan failed: %w", err)
    }
    return &user, nil
}

// Level 2: Service layer
func (s *Service) GetUser(id string) (*User, error) {
    user, err := s.repo.GetUser(id)
    if err != nil {
        return nil, fmt.Errorf("failed to get user from repository: %w", err)
    }
    return user, nil
}

// Level 3: Handler layer
func (h *Handler) GetUserHandler(w http.ResponseWriter, r *http.Request) {
    id := r.URL.Query().Get("id")
    user, err := h.service.GetUser(id)
    if err != nil {
        if errors.Is(err, ErrNotFound) {
            http.Error(w, "User not found", http.StatusNotFound)
            return
        }
        http.Error(w, "Internal server error", http.StatusInternalServerError)
        return
    }
    json.NewEncoder(w).Encode(user)
}
```

## Sentinel Errors

### Definition and Usage

```go
var (
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
    ErrInvalidInput = errors.New("invalid input")
    ErrConflict     = errors.New("resource conflict")
)

// Usage
func GetUser(id string) (*User, error) {
    if id == "" {
        return nil, fmt.Errorf("user id is empty: %w", ErrInvalidInput)
    }

    user := findUser(id)
    if user == nil {
        return nil, fmt.Errorf("user %s: %w", id, ErrNotFound)
    }

    return user, nil
}

// Checking
user, err := GetUser("123")
if errors.Is(err, ErrNotFound) {
    // Handle not found
}
```

**Key Points**:
- Declare sentinel errors as package-level variables
- Prefix with `Err` (e.g., `ErrNotFound`)
- Use `errors.Is()` to check for sentinel errors in wrapped chains
- Wrap sentinel errors with context: `fmt.Errorf("context: %w", ErrNotFound)`

## Custom Error Types

### Basic Custom Error

```go
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed on %s: %s", e.Field, e.Message)
}

// Usage
func ValidateUser(user *User) error {
    if user.Email == "" {
        return &ValidationError{
            Field:   "email",
            Message: "email is required",
        }
    }
    return nil
}

// Checking
if err := ValidateUser(user); err != nil {
    var validationErr *ValidationError
    if errors.As(err, &validationErr) {
        fmt.Printf("Invalid field: %s\n", validationErr.Field)
    }
}
```

### Custom Error with Wrapping

```go
type DatabaseError struct {
    Operation string
    Err       error
}

func (e *DatabaseError) Error() string {
    return fmt.Sprintf("database %s failed: %v", e.Operation, e.Err)
}

func (e *DatabaseError) Unwrap() error {
    return e.Err
}

// Usage
func (r *Repository) SaveUser(user *User) error {
    _, err := r.db.Exec("INSERT INTO users ...", user.ID, user.Name)
    if err != nil {
        return &DatabaseError{
            Operation: "insert user",
            Err:       err,
        }
    }
    return nil
}
```

### Multi-Error Type

```go
type ValidationErrors struct {
    Errors map[string]string
}

func (e *ValidationErrors) Error() string {
    var msgs []string
    for field, msg := range e.Errors {
        msgs = append(msgs, fmt.Sprintf("%s: %s", field, msg))
    }
    return fmt.Sprintf("validation errors: %s", strings.Join(msgs, ", "))
}

func (e *ValidationErrors) Add(field, message string) {
    if e.Errors == nil {
        e.Errors = make(map[string]string)
    }
    e.Errors[field] = message
}

// Usage
func ValidateUser(user *User) error {
    errs := &ValidationErrors{}

    if user.Email == "" {
        errs.Add("email", "required")
    }
    if user.Name == "" {
        errs.Add("name", "required")
    }

    if len(errs.Errors) > 0 {
        return errs
    }
    return nil
}
```

## Error Inspection

### errors.Is (Sentinel Errors)

```go
var ErrNotFound = errors.New("not found")

func GetUser(id string) error {
    return fmt.Errorf("failed to find user %s: %w", id, ErrNotFound)
}

// Check if error is or wraps ErrNotFound
err := GetUser("123")
if errors.Is(err, ErrNotFound) {
    fmt.Println("User not found")
}
```

### errors.As (Custom Error Types)

```go
type TemporaryError interface {
    Temporary() bool
}

type NetworkError struct {
    temporary bool
}

func (e *NetworkError) Error() string {
    return "network error"
}

func (e *NetworkError) Temporary() bool {
    return e.temporary
}

// Check if error is a specific type
err := doNetworkCall()
var netErr *NetworkError
if errors.As(err, &netErr) {
    if netErr.Temporary() {
        // Retry
    }
}
```

### Custom Is/As Methods

```go
type StatusError struct {
    Code    int
    Message string
}

func (e *StatusError) Error() string {
    return fmt.Sprintf("status %d: %s", e.Code, e.Message)
}

func (e *StatusError) Is(target error) bool {
    t, ok := target.(*StatusError)
    if !ok {
        return false
    }
    return e.Code == t.Code
}

// Usage
var ErrNotFound = &StatusError{Code: 404, Message: "not found"}

err := &StatusError{Code: 404, Message: "user not found"}
if errors.Is(err, ErrNotFound) {
    // Matches because Code is 404
}
```

## Error Handling Patterns

### Defer for Error Context

```go
func processFile(path string) (err error) {
    defer func() {
        if err != nil {
            err = fmt.Errorf("failed to process file %s: %w", path, err)
        }
    }()

    f, err := os.Open(path)
    if err != nil {
        return err
    }
    defer f.Close()

    // Process file
    return nil
}
```

### Error Accumulation

```go
import "errors"

func processAll(items []Item) error {
    var errs []error

    for _, item := range items {
        if err := process(item); err != nil {
            errs = append(errs, fmt.Errorf("item %s: %w", item.ID, err))
        }
    }

    return errors.Join(errs...)  // Go 1.20+
}
```

### Panic Recovery

```go
func safeHandler(w http.ResponseWriter, r *http.Request) {
    defer func() {
        if r := recover(); r != nil {
            log.Printf("panic recovered: %v\n%s", r, debug.Stack())
            http.Error(w, "Internal server error", 500)
        }
    }()

    // Handler code that might panic
    riskyOperation()
}
```

## Anti-Patterns

### Swallowing Errors

```go
// BAD: Silent failure
result, _ := dangerousOperation()

// BAD: Logging but not returning
if err != nil {
    log.Println(err)
    return nil  // Error swallowed
}

// GOOD: Return error
if err != nil {
    return fmt.Errorf("operation failed: %w", err)
}

// GOOD: Log and return
if err != nil {
    log.Printf("operation failed: %v", err)
    return fmt.Errorf("operation failed: %w", err)
}
```

### Generic Error Messages

```go
// BAD: No context
return errors.New("error")

// BAD: Too vague
return errors.New("failed")

// GOOD: Specific context
return fmt.Errorf("failed to connect to database %s: %w", dbHost, err)
```

### Over-Wrapping

```go
// BAD: Wrapping at every layer with same info
// Layer 1
return fmt.Errorf("error: %w", err)
// Layer 2
return fmt.Errorf("error: %w", err)
// Layer 3
return fmt.Errorf("error: %w", err)

// GOOD: Add context at each layer
// Layer 1 (repository)
return fmt.Errorf("database query failed: %w", err)
// Layer 2 (service)
return fmt.Errorf("failed to get user %s: %w", id, err)
// Layer 3 (handler)
return fmt.Errorf("request processing failed: %w", err)
```

## Best Practices

1. **Always handle errors** - Don't use `_` unless you have a good reason
2. **Wrap with context** - Use `fmt.Errorf("context: %w", err)`
3. **Check errors with `errors.Is`** - For sentinel errors
4. **Extract errors with `errors.As`** - For custom error types
5. **Create custom errors for domain logic** - When you need metadata
6. **Return early** - Handle errors at the point they occur
7. **Don't panic for expected errors** - Reserve panic for truly exceptional cases
8. **Add stack traces for debugging** - Use libraries like pkg/errors if needed

## See Also

- [Go Blog - Error Handling](https://go.dev/blog/go1.13-errors)
- [Go Blog - Defer, Panic, Recover](https://go.dev/blog/defer-panic-and-recover)
- `Skill: api-design` - Error responses in APIs
- `references/testing.md` - Testing error conditions
