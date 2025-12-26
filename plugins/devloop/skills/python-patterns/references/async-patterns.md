# Python Async Patterns

Comprehensive guide to asynchronous programming in Python with asyncio.

## When to Use Async

**DO use async for**:
- I/O-bound operations (network, files, database)
- Concurrent API calls
- WebSocket connections
- Long-running I/O tasks

**DON'T use async for**:
- CPU-bound operations (use multiprocessing instead)
- Synchronous libraries (they'll block the event loop)
- Simple scripts where sync is clearer

## Basic Async

```python
import asyncio

async def fetch_user(user_id: int) -> User:
    # Async database call
    return await db.get_user(user_id)

async def main():
    user = await fetch_user(1)
    print(user)

# Run the async function
asyncio.run(main())
```

## Concurrent Execution

### Using asyncio.gather

```python
# Run multiple coroutines concurrently
async def fetch_all_users(ids: list[int]) -> list[User]:
    tasks = [fetch_user(id) for id in ids]
    return await asyncio.gather(*tasks)

# With error handling
results = await asyncio.gather(*tasks, return_exceptions=True)
for result in results:
    if isinstance(result, Exception):
        handle_error(result)
```

### Using asyncio.create_task

```python
async def main():
    # Start tasks immediately (don't wait for await)
    task1 = asyncio.create_task(fetch_user(1))
    task2 = asyncio.create_task(fetch_user(2))

    # Do other work here
    ...

    # Wait for both tasks to complete
    user1 = await task1
    user2 = await task2
```

### Using asyncio.as_completed

```python
async def process_as_completed(ids: list[int]):
    tasks = [fetch_user(id) for id in ids]

    for coro in asyncio.as_completed(tasks):
        user = await coro
        process(user)  # Process results as they arrive
```

## Async Context Manager

Async context managers handle async resource cleanup:

```python
from contextlib import asynccontextmanager

@asynccontextmanager
async def get_connection():
    conn = await create_connection()
    try:
        yield conn
    finally:
        await conn.close()

async def query_db():
    async with get_connection() as conn:
        return await conn.execute("SELECT ...")
```

### Database Example

```python
class DatabaseSession:
    async def __aenter__(self):
        self.conn = await db_pool.acquire()
        return self.conn

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if exc_type:
            await self.conn.rollback()
        else:
            await self.conn.commit()
        await db_pool.release(self.conn)

# Usage
async with DatabaseSession() as session:
    await session.execute("INSERT ...")
```

## Async Generator

Async generators yield values asynchronously:

```python
async def fetch_pages(url: str):
    page = 1
    while True:
        data = await fetch_page(url, page)
        if not data:
            break
        yield data
        page += 1

async for page in fetch_pages(url):
    process(page)
```

### Practical Example: Streaming API

```python
async def stream_log_entries(start_time: datetime):
    """Stream log entries as they become available"""
    last_id = None
    while True:
        entries = await fetch_logs(after=last_id, since=start_time)
        for entry in entries:
            yield entry
            last_id = entry.id
        await asyncio.sleep(1)  # Poll every second

# Usage
async for log in stream_log_entries(datetime.now()):
    print(log)
```

## Synchronization Primitives

### asyncio.Lock

```python
lock = asyncio.Lock()

async def critical_section():
    async with lock:
        # Only one coroutine can execute this at a time
        await shared_resource.update()
```

### asyncio.Semaphore

Limit concurrent operations:

```python
# Allow max 5 concurrent requests
semaphore = asyncio.Semaphore(5)

async def fetch_with_limit(url: str):
    async with semaphore:
        return await fetch(url)

# All requests will respect the 5-concurrent limit
tasks = [fetch_with_limit(url) for url in urls]
results = await asyncio.gather(*tasks)
```

### asyncio.Event

Signal between coroutines:

```python
event = asyncio.Event()

async def waiter():
    print("Waiting for event...")
    await event.wait()
    print("Event received!")

async def setter():
    await asyncio.sleep(2)
    event.set()

await asyncio.gather(waiter(), setter())
```

## Async Queue

Producer-consumer pattern:

```python
from asyncio import Queue

async def producer(queue: Queue):
    for i in range(10):
        await queue.put(i)
        await asyncio.sleep(0.1)
    await queue.put(None)  # Sentinel

async def consumer(queue: Queue):
    while True:
        item = await queue.get()
        if item is None:
            break
        await process(item)
        queue.task_done()

queue = Queue()
await asyncio.gather(
    producer(queue),
    consumer(queue),
)
```

## Timeouts

### Using asyncio.wait_for

```python
try:
    result = await asyncio.wait_for(fetch_user(1), timeout=5.0)
except asyncio.TimeoutError:
    print("Request timed out")
```

### Using asyncio.wait

```python
tasks = [fetch_user(id) for id in ids]

# Wait for first task to complete
done, pending = await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)

# Wait for all with timeout
done, pending = await asyncio.wait(tasks, timeout=10.0)
for task in pending:
    task.cancel()
```

## Running Sync Code in Async

### Using run_in_executor

```python
import asyncio
from concurrent.futures import ThreadPoolExecutor

async def async_wrapper():
    loop = asyncio.get_event_loop()

    # Run blocking I/O in thread pool
    result = await loop.run_in_executor(
        None,  # Use default executor
        blocking_io_function,
        arg1,
        arg2
    )

    # Run CPU-bound work in process pool
    with ProcessPoolExecutor() as pool:
        result = await loop.run_in_executor(
            pool,
            cpu_intensive_function,
            data
        )
```

## Error Handling

```python
async def safe_fetch(url: str) -> str | None:
    try:
        return await fetch(url)
    except asyncio.TimeoutError:
        logger.warning(f"Timeout fetching {url}")
        return None
    except aiohttp.ClientError as e:
        logger.error(f"Client error: {e}")
        return None
    except Exception as e:
        logger.exception(f"Unexpected error fetching {url}")
        raise

# Handle errors in gather
results = await asyncio.gather(*tasks, return_exceptions=True)
for i, result in enumerate(results):
    if isinstance(result, Exception):
        logger.error(f"Task {i} failed: {result}")
```

## Testing Async Code

### Using pytest-asyncio

```python
import pytest

@pytest.mark.asyncio
async def test_fetch_user():
    user = await fetch_user(1)
    assert user.id == 1

@pytest.fixture
async def async_client():
    client = AsyncClient()
    await client.connect()
    yield client
    await client.close()

@pytest.mark.asyncio
async def test_with_fixture(async_client):
    result = await async_client.get("/users")
    assert result.status == 200
```

## Best Practices

### DO
- Use `asyncio.run()` for the top-level entry point
- Use `asyncio.create_task()` to run tasks concurrently
- Use `async with` for async context managers
- Handle `asyncio.CancelledError` for graceful shutdown
- Use semaphores to limit concurrency

### DON'T
- Don't use blocking I/O in async functions (use `run_in_executor`)
- Don't forget `await` (code won't run without it)
- Don't mix sync and async without careful consideration
- Don't create too many concurrent tasks (use semaphores)

## Common Pitfalls

### Forgetting await

```python
# Wrong - returns coroutine, doesn't execute
result = fetch_user(1)

# Correct
result = await fetch_user(1)
```

### Blocking the Event Loop

```python
# Wrong - blocks event loop
async def bad():
    time.sleep(10)  # Blocks!

# Correct
async def good():
    await asyncio.sleep(10)
```

### Creating Tasks Without Awaiting

```python
# Wrong - task may not complete
asyncio.create_task(background_task())

# Correct - ensure task completes
task = asyncio.create_task(background_task())
await task

# Or for fire-and-forget (with exception handling)
task = asyncio.create_task(background_task())
task.add_done_callback(lambda t: t.result() if not t.cancelled() else None)
```

## See Also

- [asyncio documentation](https://docs.python.org/3/library/asyncio.html)
- [aiohttp](https://docs.aiohttp.org/) - Async HTTP client/server
- [httpx](https://www.python-httpx.org/) - Async HTTP client
- Main skill: [SKILL.md](../SKILL.md)
