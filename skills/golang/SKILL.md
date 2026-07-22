---
name: golang
description: Go development conventions, patterns, toolchain, and quality gates for Zate's projects. Load when working in any Go repo (has go.mod).
---

# Go Development Skill

Load this skill at session start when working in a Go project. It covers conventions, toolchain, testing, and quality gates that apply across all Go projects.

## Toolchain

- **Always respect the `go` and `toolchain` versions in `go.mod`.** Do not assume a version; read the file.
- New projects: target Go 1.24+.
- Multi-module repos: use a `go.work` file at the workspace root.
- Never introduce CGO. Pure Go only. For SQLite: `modernc.org/sqlite` (WAL mode) or `ncruces/go-sqlite3` (WASM).

## Build, Lint, and Test — the Standard Trio

**Always use `make` targets.** Every project must have these three:

```bash
make build   # go build ./...
make test    # go test ./...
make lint    # golangci-lint run
```

Run in this order before every commit:

```bash
make build && make test && make lint
```

All three must be green. No exceptions. CI enforces the same — do not merge a red pipeline.

## golangci-lint Configuration

The canonical `.golangci.yml` template ships with this skill at `assets/golangci.yml`. For a new project, copy it into the repo root as `.golangci.yml`:

```bash
cp "$SKILL_DIR/assets/golangci.yml" .golangci.yml   # $SKILL_DIR = this skill's directory
```

Key linters enabled:

| Category | Linters |
|---|---|
| Correctness | `errcheck`, `govet`, `staticcheck`, `ineffassign`, `unused`, `nilerr`, `nilnil` |
| Safety | `gosec`, `contextcheck`, `bodyclose`, `rowserrcheck`, `sqlclosecheck` |
| Style | `revive`, `godoclint`, `misspell`, `usestdlibvars`, `unconvert`, `unparam` |
| Performance | `prealloc`, `wastedassign`, `copyloopvar` |
| Logging | `sloglint` |
| Exhaustiveness | `exhaustive` |
| Complexity | `gocyclo` (max 15) |

**Revive limits (enforced):**
- Max file length: 350 lines (excluding comments and blank lines)
- Max function length: 50 statements / 80 lines

**Formatters:** `gofmt` + `goimports` (both enforced, not just style).

## Code Style

### Naming
- Exported symbols: `CamelCase` with godoc comment — no exceptions.
- Unexported: `lowerCamelCase`.
- Receiver names: short, type-derived (1-2 letters). Consistent across all methods on a type.
- Error types: `FooError`. Sentinel errors: `ErrFoo`. Error strings: lowercase, no punctuation.
- Test helpers: call `t.Helper()` as first line.

### File and Function Size
- Enforce the revive limits: 350 lines per file, 50 statements / 80 lines per function.
- One concern per file. If a file is growing toward the limit, split it.

### Godoc
Every exported function, type, method, and constant gets a godoc comment starting with the symbol name:

```go
// UserStore manages persistent user records.
type UserStore struct { ... }

// Get retrieves a user by ID. Returns ErrNotFound if the user does not exist.
func (s *UserStore) Get(ctx context.Context, id string) (*User, error) { ... }
```

## Interfaces

Follow these rules strictly — they prevent the most common Go design mistakes:

- **Interfaces belong with the consumer, not the producer.** Define the interface in the package that uses it.
- **Keep interfaces small:** 1-5 methods. If you need more, split the interface.
- **Accept interfaces, return concrete types.** Never return an interface from a constructor.
- **No `any` in public APIs.** Use typed parameters or generics where repetition genuinely warrants it.
- **Single-implementor interfaces** are valid and useful for testability — don't avoid them.

```go
// Good: interface defined in consumer package
type PageFetcher interface {
    Fetch(ctx context.Context, url string) (*Page, error)
}

// Bad: interface defined in producer package, returned from constructor
func NewFetcher() PageFetcher { ... } // don't do this
```

## Error Handling

- Wrap with `%w` for errors that callers may inspect: `fmt.Errorf("doing x: %w", err)`
- Use `errors.Is` / `errors.As` for inspection — never string-match error messages.
- Sentinel errors at package level: `var ErrNotFound = errors.New("not found")`
- Don't discard errors. `errcheck` will catch it, but catch it in review first.
- Don't wrap an error that's already wrapped at the same call site.
- Return early on error — avoid deeply nested `if err == nil` blocks.

```go
// Good
if err := store.Save(ctx, record); err != nil {
    return fmt.Errorf("saving record %s: %w", record.ID, err)
}

// Bad
err := store.Save(ctx, record)
if err == nil {
    // ... deeply nested happy path
}
```

## Concurrency

- `context.Context` is **always the first parameter** on anything that does I/O, blocks, or starts a goroutine.
- Every goroutine has a known stop condition: context cancellation or a closed channel. No fire-and-forget.
- Prefer `sync.WaitGroup` + channel patterns for simple fan-out. Use worker pool libraries (`pond`) for bounded concurrency.
- Collect results from pools with a mutex, not a results channel — simpler and less error-prone at scale.
- `sloglint` enforces correct `slog` usage; don't work around it.

```go
// Good: context-first, known stop
func (w *Worker) Run(ctx context.Context) error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        case job := <-w.queue:
            w.process(ctx, job)
        }
    }
}
```

## Logging

Use `log/slog` (stdlib). No third-party logging libraries unless the project already uses one.

```go
slog.Info("processing job", "id", job.ID, "queue", queue.Name)
slog.Error("failed to save", "err", err, "id", record.ID)
```

- Structured key-value pairs only. No `fmt.Sprintf` in log messages.
- Use `slog.With(...)` to build a logger with shared fields rather than repeating keys.
- `sloglint` is enabled — it will catch incorrect arg counts and non-string keys.

## HTTP

- Preferred router: **Echo** (`github.com/labstack/echo/v4`).
- Always set timeouts on HTTP clients and servers — never use the zero-value `http.Client{}`.
- Use `httptest.NewServer` in tests, never real network calls.

```go
// Always set timeouts
client := &http.Client{Timeout: 10 * time.Second}

// Echo handler pattern
func (h *Handler) GetUser(c echo.Context) error {
    id := c.Param("id")
    user, err := h.store.Get(c.Request().Context(), id)
    if err != nil {
        return echo.NewHTTPError(http.StatusNotFound, err.Error())
    }
    return c.JSON(http.StatusOK, user)
}
```

## Generics

Use sparingly. Valid reasons:
- Eliminating genuine repetition (same logic over multiple types, not just 2 callers).
- KISS: if the generic version is harder to read than two concrete functions, write two functions.
- Avoid generics in public APIs unless the type constraint is the entire point.

```go
// Good: genuine repetition eliminated
func Map[T, U any](s []T, f func(T) U) []U {
    result := make([]U, len(s))
    for i, v := range s {
        result[i] = f(v)
    }
    return result
}

// Bad: premature generalisation, one concrete caller
func Process[T Doer](t T) { t.Do() } // just use the interface
```

## Testing

Follow TDD: write the test first, watch it fail, then implement.

- **Table-driven tests** for anything with multiple input cases:

```go
func TestValidate(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        wantErr bool
    }{
        {"valid", "foo@example.com", false},
        {"empty", "", true},
        {"no at", "notanemail", true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := Validate(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("Validate(%q) error = %v, wantErr %v", tt.input, err, tt.wantErr)
            }
        })
    }
}
```

- **Isolation tools:** `httptest.NewServer` for HTTP, `t.TempDir()` for filesystem, interface mocks for dependencies.
- **`testify`** for assertions (`require.NoError`, `assert.Equal`) — consistent across projects.
- Test contracts and observable behaviour, not implementation internals.
- Call `t.Helper()` as the first line of any test helper function.
- Fuzz tests where input parsing is complex (see `internal/query/` in Memdown as a reference).

## Design Patterns

Apply canonical Go patterns — don't reach for patterns from other languages:

- **Functional options** for configurable constructors with many optional fields.
- **Table-driven dispatch** over large switch statements.
- **Repository pattern** for storage (define a `Store` interface in the domain package; inject it).
- **Middleware chains** for HTTP (Echo middleware, or `http.Handler` wrapping).
- **Options pattern** over config structs where zero-values are ambiguous.
- Avoid inheritance-style embedding for behaviour — prefer explicit delegation.
- Avoid global state. Pass dependencies explicitly.

## Quick Reference

```bash
# Standard validation before commit
make build && make test && make lint

# Run a specific test
go test -v -run TestFoo ./internal/store/

# Check coverage
go test -cover ./...

# Run linter on changed files only
golangci-lint run --new-from-rev HEAD~1

# Format (both required)
gofmt -w .
goimports -w .

# Tidy modules
go mod tidy

# Workspace (multi-module)
go work sync
```
