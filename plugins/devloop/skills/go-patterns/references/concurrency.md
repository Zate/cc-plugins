# Go Concurrency Patterns

Detailed patterns for goroutines, channels, context, and synchronization primitives.

## Goroutines with WaitGroup

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

**Key Points**:
- Always pass loop variables to goroutine function (pre-Go 1.22)
- Use buffered error channel to avoid blocking
- `defer wg.Done()` ensures WaitGroup is decremented even on panic
- Close error channel after Wait() returns

## Worker Pool

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

// Usage
jobs := make(chan Job, 100)
results := make(chan Result, 100)

go workerPool(jobs, results, 10)

// Send jobs
for _, job := range jobList {
    jobs <- job
}
close(jobs)

// Consume results
for result := range results {
    handleResult(result)
}
```

**Key Points**:
- Fixed number of worker goroutines
- Jobs channel receives work
- Results channel sends output
- Close jobs channel when done sending
- Workers close results channel when all done

## Context for Cancellation

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

// Usage with timeout
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

if err := longRunningOperation(ctx); err != nil {
    if errors.Is(err, context.DeadlineExceeded) {
        // Timeout occurred
    }
}
```

**Key Points**:
- Always accept `context.Context` as first parameter
- Check `ctx.Done()` periodically
- Return `ctx.Err()` to preserve cancellation reason
- Always call `cancel()` to release resources

## Channel Patterns

### Fan-Out (Distribute Work)
```go
func fanOut(in <-chan int, workers int) []<-chan int {
    outs := make([]<-chan int, workers)
    for i := 0; i < workers; i++ {
        out := make(chan int)
        outs[i] = out
        go func(ch chan<- int) {
            for val := range in {
                ch <- val
            }
            close(ch)
        }(out)
    }
    return outs
}
```

### Fan-In (Merge Results)
```go
func fanIn(channels ...<-chan int) <-chan int {
    out := make(chan int)
    var wg sync.WaitGroup

    for _, ch := range channels {
        wg.Add(1)
        go func(c <-chan int) {
            defer wg.Done()
            for val := range c {
                out <- val
            }
        }(ch)
    }

    go func() {
        wg.Wait()
        close(out)
    }()

    return out
}
```

### Pipeline Pattern
```go
func generator(nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        for _, n := range nums {
            out <- n
        }
        close(out)
    }()
    return out
}

func square(in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        for n := range in {
            out <- n * n
        }
        close(out)
    }()
    return out
}

// Usage
nums := generator(2, 3, 4)
squared := square(nums)
for result := range squared {
    fmt.Println(result)
}
```

## Mutex and Sync Primitives

### Mutex for Shared State
```go
type Counter struct {
    mu    sync.Mutex
    value int
}

func (c *Counter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.value++
}

func (c *Counter) Value() int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.value
}
```

### RWMutex for Read-Heavy Workloads
```go
type Cache struct {
    mu    sync.RWMutex
    items map[string]string
}

func (c *Cache) Get(key string) (string, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    val, ok := c.items[key]
    return val, ok
}

func (c *Cache) Set(key, value string) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.items[key] = value
}
```

### Once for Initialization
```go
var (
    instance *Singleton
    once     sync.Once
)

func GetInstance() *Singleton {
    once.Do(func() {
        instance = &Singleton{}
    })
    return instance
}
```

## Anti-Patterns

### Goroutine Leaks
```go
// BAD: No way to stop
go func() {
    for {
        doWork()
    }
}()

// GOOD: Context-controlled
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
```

### Closure Variable Capture (pre-Go 1.22)
```go
// BAD: Captures final value
for _, item := range items {
    go func() {
        process(item)  // All goroutines see last item!
    }()
}

// GOOD: Pass as parameter
for _, item := range items {
    go func(item Item) {
        process(item)
    }(item)
}

// GOOD (Go 1.22+): Loop variable per iteration
for _, item := range items {
    go func() {
        process(item)  // Each iteration gets own item
    }()
}
```

### Unbuffered Channel Deadlock
```go
// BAD: Will deadlock
ch := make(chan int)
ch <- 42  // Blocks forever, no receiver

// GOOD: Use buffered or goroutine
ch := make(chan int, 1)
ch <- 42  // Doesn't block

// Or send in goroutine
ch := make(chan int)
go func() {
    ch <- 42
}()
result := <-ch
```

## Best Practices

1. **Start goroutines only when needed** - Don't spawn thousands unnecessarily
2. **Always provide a way to stop goroutines** - Use context or done channel
3. **Avoid sharing memory** - Communicate via channels when possible
4. **Use buffered channels for known capacity** - Prevent blocking
5. **Close channels from sender side** - Receiver should never close
6. **Check for closed channels** - Use `val, ok := <-ch` pattern
7. **Use sync.WaitGroup for goroutine lifecycle** - Know when all complete
8. **Prefer timeouts over infinite waits** - Use context.WithTimeout

## See Also

- [Effective Go - Concurrency](https://go.dev/doc/effective_go#concurrency)
- `Skill: testing-strategies` - Testing concurrent code
- `references/testing.md` - Race detection patterns
