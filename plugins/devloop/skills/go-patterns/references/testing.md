# Go Testing Patterns

Comprehensive testing patterns for Go, including table-driven tests, mocking, benchmarks, and race detection.

## Table-Driven Tests

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
        {"zero", 0, 0, 0},
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

**Key Points**:
- Use `t.Run()` for subtests - provides isolation and clear output
- Name test cases descriptively
- Group related test cases together
- Each subtest runs independently

### Advanced Table-Driven Tests

```go
func TestUserService_CreateUser(t *testing.T) {
    tests := []struct {
        name    string
        input   CreateUserInput
        setup   func(*testing.T, *mockUserRepo)
        want    *User
        wantErr error
    }{
        {
            name:  "valid user",
            input: CreateUserInput{Email: "test@example.com"},
            setup: func(t *testing.T, repo *mockUserRepo) {
                repo.saveFunc = func(u *User) error { return nil }
            },
            want: &User{Email: "test@example.com"},
        },
        {
            name:  "duplicate email",
            input: CreateUserInput{Email: "duplicate@example.com"},
            setup: func(t *testing.T, repo *mockUserRepo) {
                repo.existsByEmailFunc = func(email string) bool { return true }
            },
            wantErr: ErrDuplicateEmail,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            repo := &mockUserRepo{}
            if tt.setup != nil {
                tt.setup(t, repo)
            }

            svc := NewUserService(repo)
            got, err := svc.CreateUser(tt.input)

            if !errors.Is(err, tt.wantErr) {
                t.Fatalf("CreateUser() error = %v, wantErr %v", err, tt.wantErr)
            }
            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("CreateUser() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

## Test Helpers

### Cleanup Pattern

```go
func setupTestDB(t *testing.T) *sql.DB {
    t.Helper()
    db, err := sql.Open("sqlite3", ":memory:")
    if err != nil {
        t.Fatalf("failed to open db: %v", err)
    }

    // Run migrations
    if err := runMigrations(db); err != nil {
        db.Close()
        t.Fatalf("failed to run migrations: %v", err)
    }

    t.Cleanup(func() {
        db.Close()
    })

    return db
}

// Usage
func TestUserRepository(t *testing.T) {
    db := setupTestDB(t)
    repo := NewUserRepository(db)

    // Test code - db automatically cleaned up
}
```

**Key Points**:
- Use `t.Helper()` to mark helper functions (improves error reporting)
- Use `t.Cleanup()` for automatic cleanup (runs even if test fails)
- Fail with `t.Fatalf()` in setup - no point continuing if setup fails

### Golden Files

```go
func TestRenderHTML(t *testing.T) {
    got := RenderHTML(testData)

    goldenPath := "testdata/output.golden"

    if *update {
        os.WriteFile(goldenPath, []byte(got), 0644)
    }

    want, err := os.ReadFile(goldenPath)
    if err != nil {
        t.Fatalf("failed to read golden file: %v", err)
    }

    if got != string(want) {
        t.Errorf("output mismatch\ngot:\n%s\nwant:\n%s", got, want)
    }
}

var update = flag.Bool("update", false, "update golden files")
```

## Interface Mocking

### Manual Mocks

```go
type UserStore interface {
    GetUser(id string) (*User, error)
    SaveUser(user *User) error
}

type mockUserStore struct {
    getUserFunc  func(id string) (*User, error)
    saveUserFunc func(user *User) error
}

func (m *mockUserStore) GetUser(id string) (*User, error) {
    if m.getUserFunc != nil {
        return m.getUserFunc(id)
    }
    return nil, errors.New("not implemented")
}

func (m *mockUserStore) SaveUser(user *User) error {
    if m.saveUserFunc != nil {
        return m.saveUserFunc(user)
    }
    return errors.New("not implemented")
}

// Usage
func TestUserService(t *testing.T) {
    store := &mockUserStore{
        getUserFunc: func(id string) (*User, error) {
            return &User{ID: id, Name: "Test"}, nil
        },
    }

    svc := NewUserService(store)
    user, err := svc.GetUser("123")

    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if user.Name != "Test" {
        t.Errorf("got name %q, want %q", user.Name, "Test")
    }
}
```

### Mock Verification

```go
type mockUserStore struct {
    getUserCalls []string
    saveUserCalls []*User
}

func (m *mockUserStore) GetUser(id string) (*User, error) {
    m.getUserCalls = append(m.getUserCalls, id)
    return &User{ID: id}, nil
}

func TestUserService_GetUserCalled(t *testing.T) {
    store := &mockUserStore{}
    svc := NewUserService(store)

    svc.GetUser("123")

    if len(store.getUserCalls) != 1 {
        t.Fatalf("GetUser called %d times, want 1", len(store.getUserCalls))
    }
    if store.getUserCalls[0] != "123" {
        t.Errorf("GetUser called with %q, want %q", store.getUserCalls[0], "123")
    }
}
```

## Race Detection

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

**Run with race detector**:
```bash
go test -race
go test -race -run TestConcurrentAccess
```

**Key Points**:
- Race detector adds overhead (~10x slower)
- Use in CI/CD for comprehensive checks
- Not guaranteed to find all races (depends on execution)

## Benchmarks

```go
func BenchmarkAdd(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Add(2, 3)
    }
}

func BenchmarkAddWithSetup(b *testing.B) {
    // Setup code (not measured)
    data := prepareTestData()

    b.ResetTimer()  // Reset timer after setup

    for i := 0; i < b.N; i++ {
        Add(data.a, data.b)
    }
}

func BenchmarkStringConcat(b *testing.B) {
    strs := []string{"hello", "world", "foo", "bar"}

    b.Run("strings.Builder", func(b *testing.B) {
        for i := 0; i < b.N; i++ {
            var sb strings.Builder
            for _, s := range strs {
                sb.WriteString(s)
            }
            _ = sb.String()
        }
    })

    b.Run("naive", func(b *testing.B) {
        for i := 0; i < b.N; i++ {
            result := ""
            for _, s := range strs {
                result += s
            }
            _ = result
        }
    })
}
```

**Run benchmarks**:
```bash
go test -bench=.
go test -bench=BenchmarkAdd -benchmem  # Include memory stats
go test -bench=. -cpuprofile=cpu.prof  # Generate CPU profile
```

## Test Organization

### File Structure
```
mypackage/
├── user.go
├── user_test.go         # Tests for user.go
├── user_internal_test.go # Tests using package internals
└── testdata/            # Test fixtures
    ├── input.json
    └── output.golden
```

### Package Naming
```go
// user_test.go - Black box tests (external API only)
package mypackage_test

import (
    "testing"
    "mypackage"
)

// user_internal_test.go - White box tests (access internals)
package mypackage

import "testing"
```

### Test Fixture Organization
```
testdata/
├── users/
│   ├── valid.json
│   ├── invalid.json
│   └── empty.json
└── golden/
    ├── output1.golden
    └── output2.golden
```

## Testing Best Practices

1. **Test behavior, not implementation** - Tests should survive refactoring
2. **Use table-driven tests for multiple cases** - Easier to add cases
3. **Name tests descriptively** - `TestUserService_CreateUser_WithDuplicateEmail`
4. **Prefer t.Errorf over t.Fatalf** - See all failures, not just first
5. **Use testdata/ for fixtures** - Keep test files clean
6. **Mock at service boundaries** - Don't mock everything
7. **Run tests with race detector in CI** - Catch concurrency bugs
8. **Benchmark critical paths** - Prevent performance regressions

## See Also

- [Testing package documentation](https://pkg.go.dev/testing)
- `Skill: testing-strategies` - General test strategies
- `references/concurrency.md` - Testing concurrent code
