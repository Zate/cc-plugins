# Python Error Handling

Comprehensive guide to exception handling and error patterns in Python.

## Custom Exceptions

### Exception Hierarchy

Build a clear exception hierarchy for your application:

```python
class AppError(Exception):
    """Base exception for application"""
    pass

class NotFoundError(AppError):
    """Resource not found"""
    def __init__(self, resource: str, id: int):
        self.resource = resource
        self.id = id
        super().__init__(f"{resource} with id {id} not found")

class ValidationError(AppError):
    """Validation failed"""
    def __init__(self, field: str, message: str):
        self.field = field
        self.message = message
        super().__init__(f"{field}: {message}")

class AuthenticationError(AppError):
    """Authentication failed"""
    pass

class AuthorizationError(AppError):
    """Authorization failed"""
    def __init__(self, action: str, resource: str):
        self.action = action
        self.resource = resource
        super().__init__(f"Not authorized to {action} {resource}")
```

### Exception with Context

```python
class DatabaseError(AppError):
    """Database operation failed"""
    def __init__(self, message: str, query: str | None = None):
        self.query = query
        super().__init__(message)

    def __str__(self):
        msg = super().__str__()
        if self.query:
            return f"{msg}\nQuery: {self.query}"
        return msg

# Usage
try:
    execute_query(sql)
except Exception as e:
    raise DatabaseError("Query failed", query=sql) from e
```

## Exception Handling

### Specific Exceptions First

```python
# Good: Specific to general
try:
    user = get_user(id)
except NotFoundError:
    return None
except ValidationError as e:
    logger.warning(f"Validation failed: {e}")
    raise
except DatabaseError as e:
    logger.error(f"Database error: {e}")
    return None
except Exception as e:
    logger.exception("Unexpected error")
    raise AppError("Internal error") from e
```

### Exception Chaining

Preserve the original exception with `from`:

```python
try:
    result = external_api.call()
except requests.RequestException as e:
    raise APIError("External API failed") from e

# The original exception is preserved in __cause__
except APIError as e:
    print(e.__cause__)  # Original RequestException
```

### Suppressing Context

Use `from None` to hide the original exception:

```python
try:
    value = data['key']
except KeyError:
    # Hide the KeyError, raise our own
    raise ValidationError("Missing required field: key") from None
```

## Context Managers

Context managers ensure proper cleanup with `with` statements:

### Basic Context Manager

```python
from contextlib import contextmanager

@contextmanager
def transaction():
    conn = get_connection()
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

# Usage
with transaction() as conn:
    conn.execute("INSERT ...")
    conn.execute("UPDATE ...")
# Automatic commit/rollback/close
```

### Class-Based Context Manager

```python
class DatabaseTransaction:
    def __enter__(self):
        self.conn = get_connection()
        return self.conn

    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type:
            self.conn.rollback()
        else:
            self.conn.commit()
        self.conn.close()
        return False  # Don't suppress exceptions

# Usage
with DatabaseTransaction() as conn:
    conn.execute("INSERT ...")
```

### Multiple Context Managers

```python
# Good: Multiple with statements
with open('input.txt') as infile:
    with open('output.txt', 'w') as outfile:
        outfile.write(infile.read())

# Better: Single with statement
with open('input.txt') as infile, open('output.txt', 'w') as outfile:
    outfile.write(infile.read())
```

## Error Recovery Patterns

### Retry with Exponential Backoff

```python
import time
from typing import TypeVar, Callable

T = TypeVar('T')

def retry_with_backoff(
    func: Callable[[], T],
    max_attempts: int = 3,
    base_delay: float = 1.0
) -> T:
    """Retry a function with exponential backoff"""
    for attempt in range(max_attempts):
        try:
            return func()
        except Exception as e:
            if attempt == max_attempts - 1:
                raise
            delay = base_delay * (2 ** attempt)
            logger.warning(f"Attempt {attempt + 1} failed, retrying in {delay}s: {e}")
            time.sleep(delay)

# Usage
result = retry_with_backoff(lambda: api.fetch_data())
```

### Fallback Pattern

```python
def get_user(user_id: int) -> User:
    """Get user with fallback to cache"""
    try:
        return db.get_user(user_id)
    except DatabaseError:
        logger.warning(f"Database unavailable, using cache for user {user_id}")
        return cache.get_user(user_id)
```

### Circuit Breaker

```python
from datetime import datetime, timedelta

class CircuitBreaker:
    def __init__(self, failure_threshold: int = 5, timeout: float = 60.0):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failures = 0
        self.last_failure_time = None
        self.state = "closed"  # closed, open, half_open

    def call(self, func, *args, **kwargs):
        if self.state == "open":
            if datetime.now() - self.last_failure_time > timedelta(seconds=self.timeout):
                self.state = "half_open"
            else:
                raise Exception("Circuit breaker is open")

        try:
            result = func(*args, **kwargs)
            if self.state == "half_open":
                self.state = "closed"
                self.failures = 0
            return result
        except Exception as e:
            self.failures += 1
            self.last_failure_time = datetime.now()
            if self.failures >= self.failure_threshold:
                self.state = "open"
            raise

# Usage
breaker = CircuitBreaker()
result = breaker.call(api.fetch_data)
```

## Validation Patterns

### Early Return

```python
def process_user(user_data: dict) -> User:
    # Validate early, return/raise early
    if not user_data.get('email'):
        raise ValidationError('email', 'Required field')

    if not user_data.get('name'):
        raise ValidationError('name', 'Required field')

    if len(user_data['name']) < 2:
        raise ValidationError('name', 'Must be at least 2 characters')

    # Now process with confidence
    return User(**user_data)
```

### Validation with Result Type

```python
from dataclasses import dataclass
from typing import Generic, TypeVar

T = TypeVar('T')
E = TypeVar('E')

@dataclass
class Ok(Generic[T]):
    value: T

@dataclass
class Err(Generic[E]):
    error: E

Result = Ok[T] | Err[E]

def validate_email(email: str) -> Result[str, str]:
    if '@' not in email:
        return Err("Invalid email format")
    return Ok(email)

# Usage
match validate_email(user_email):
    case Ok(email):
        process_email(email)
    case Err(error):
        handle_error(error)
```

## Logging Exceptions

### Basic Exception Logging

```python
import logging

logger = logging.getLogger(__name__)

try:
    risky_operation()
except Exception as e:
    # Logs exception with full traceback
    logger.exception("Operation failed")
    raise

# Or with different levels
try:
    risky_operation()
except ValidationError as e:
    logger.warning(f"Validation failed: {e}")
except Exception as e:
    logger.error(f"Unexpected error: {e}", exc_info=True)
```

### Structured Logging

```python
import structlog

logger = structlog.get_logger()

try:
    process_order(order_id)
except Exception as e:
    logger.error(
        "order_processing_failed",
        order_id=order_id,
        error=str(e),
        error_type=type(e).__name__,
        exc_info=True
    )
    raise
```

## Exception Groups (Python 3.11+)

Handle multiple exceptions at once:

```python
try:
    raise ExceptionGroup("Multiple errors", [
        ValueError("Invalid value"),
        TypeError("Wrong type"),
    ])
except* ValueError as eg:
    print(f"Caught {len(eg.exceptions)} ValueErrors")
except* TypeError as eg:
    print(f"Caught {len(eg.exceptions)} TypeErrors")
```

## Best Practices

### DO
- Use specific exception types
- Provide useful error messages
- Log exceptions with context
- Use context managers for resources
- Chain exceptions with `from`
- Clean up resources in `finally`

### DON'T
- Don't use bare `except:` (use `except Exception:`)
- Don't catch exceptions you can't handle
- Don't ignore exceptions silently
- Don't use exceptions for control flow
- Don't create exception instances unnecessarily

## Anti-Patterns

### Bare Except

```python
# Bad: Catches everything, including KeyboardInterrupt
try:
    risky_operation()
except:
    pass

# Good: Catch specific exceptions
try:
    risky_operation()
except ValueError:
    handle_value_error()
```

### Swallowing Exceptions

```python
# Bad: Error is hidden
try:
    important_operation()
except Exception:
    pass

# Good: Log or re-raise
try:
    important_operation()
except Exception as e:
    logger.error(f"Operation failed: {e}")
    raise
```

### Exception as Control Flow

```python
# Bad: Using exceptions for normal flow
try:
    value = cache[key]
except KeyError:
    value = compute_value(key)
    cache[key] = value

# Good: Use conditional
if key in cache:
    value = cache[key]
else:
    value = compute_value(key)
    cache[key] = value
```

## See Also

- [PEP 3134 - Exception Chaining](https://www.python.org/dev/peps/pep-3134/)
- [contextlib documentation](https://docs.python.org/3/library/contextlib.html)
- Main skill: [SKILL.md](../SKILL.md)
