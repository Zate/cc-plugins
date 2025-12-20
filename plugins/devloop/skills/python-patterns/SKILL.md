---
name: python-patterns
description: Python-specific best practices including type hints, async patterns, testing with pytest, error handling, and common idioms. Use when working on Python codebases.
---

# Python Patterns

Idiomatic Python patterns and best practices. **Extends** `language-patterns-base` with Python-specific guidance.

**Python Version**: Targets Python 3.10+. Type syntax like `X | Y` requires 3.10+, `match` statements require 3.10+.

> For universal principles (AAA testing, separation of concerns, naming), see `Skill: language-patterns-base`.

## When NOT to Use This Skill

- **Non-Python code**: Use go-patterns, java-patterns, react-patterns instead
- **Python 2**: Legacy Python has different patterns
- **Jupyter notebooks**: Data science workflows have different conventions
- **MicroPython/CircuitPython**: Embedded Python has constraints
- **Quick scripts**: Don't over-engineer one-off automation

## Quick Reference

| Pattern | Use Case | Example |
|---------|----------|---------|
| Type hints | Function signatures | `def greet(name: str) -> str:` |
| Dataclasses | Data containers | `@dataclass class User:` |
| Context managers | Resource cleanup | `with open(f) as file:` |
| Async/await | Concurrent I/O | `async def fetch():` |
| Protocols | Structural typing | `class Readable(Protocol):` |

---

## Type Hints

### Basic Types
```python
from typing import Optional, List, Dict, Tuple, Union, Any

def greet(name: str) -> str:
    return f"Hello, {name}"

def get_user(user_id: int) -> Optional[User]:
    ...

def process_items(items: List[str]) -> Dict[str, int]:
    ...
```

### Generic Types (Python 3.9+)
```python
# Use built-in types directly
def process(items: list[str]) -> dict[str, int]:
    ...

# Union with |
def get_value(key: str) -> str | None:
    ...
```

### TypedDict
```python
from typing import TypedDict

class UserDict(TypedDict):
    id: int
    name: str
    email: str
    active: bool

def create_user(data: UserDict) -> User:
    ...
```

### Protocols (Structural Typing)
```python
from typing import Protocol

class Readable(Protocol):
    def read(self) -> str:
        ...

def process_readable(source: Readable) -> None:
    content = source.read()
    ...
```

### Type Aliases
```python
from typing import TypeAlias

UserId: TypeAlias = int
UserMap: TypeAlias = dict[UserId, User]
```

## Dataclasses

### Basic Dataclass
```python
from dataclasses import dataclass, field
from typing import Optional
from datetime import datetime

@dataclass
class User:
    id: int
    name: str
    email: str
    created_at: datetime = field(default_factory=datetime.now)
    roles: list[str] = field(default_factory=list)
    active: bool = True
```

### Frozen Dataclass (Immutable)
```python
@dataclass(frozen=True)
class Point:
    x: float
    y: float
```

### With Validation
```python
@dataclass
class User:
    email: str

    def __post_init__(self):
        if "@" not in self.email:
            raise ValueError("Invalid email")
```

## Pydantic Models

### Basic Model
```python
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime

class User(BaseModel):
    id: int
    name: str = Field(min_length=1, max_length=100)
    email: EmailStr
    created_at: datetime = Field(default_factory=datetime.now)

    class Config:
        frozen = True  # Immutable
```

### Validation
```python
from pydantic import BaseModel, validator, root_validator

class Order(BaseModel):
    quantity: int
    unit_price: float

    @validator('quantity')
    def quantity_positive(cls, v):
        if v <= 0:
            raise ValueError('must be positive')
        return v

    @root_validator
    def check_total(cls, values):
        if values.get('quantity', 0) * values.get('unit_price', 0) > 10000:
            raise ValueError('total exceeds limit')
        return values
```

## Async Patterns

### Basic Async
```python
import asyncio

async def fetch_user(user_id: int) -> User:
    # Async database call
    return await db.get_user(user_id)

async def main():
    user = await fetch_user(1)
```

### Concurrent Execution
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

### Async Context Manager
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

### Async Generator
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

## Error Handling

### Custom Exceptions
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
```

### Exception Handling
```python
# Specific exceptions first
try:
    user = get_user(id)
except NotFoundError:
    return None
except ValidationError as e:
    logger.warning(f"Validation failed: {e}")
    raise
except Exception as e:
    logger.exception("Unexpected error")
    raise AppError("Internal error") from e
```

### Context Manager for Cleanup
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
```

## Testing with Pytest

### Basic Tests
```python
import pytest

def test_user_creation():
    user = User(name="John", email="john@example.com")
    assert user.name == "John"
    assert user.email == "john@example.com"

def test_invalid_email():
    with pytest.raises(ValidationError) as exc_info:
        User(name="John", email="invalid")
    assert "email" in str(exc_info.value)
```

### Fixtures
```python
@pytest.fixture
def user():
    return User(name="Test", email="test@example.com")

@pytest.fixture
def db_session():
    session = create_session()
    yield session
    session.rollback()
    session.close()

def test_save_user(db_session, user):
    db_session.add(user)
    db_session.commit()
    assert user.id is not None
```

### Parametrized Tests
```python
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("world", "WORLD"),
    ("", ""),
])
def test_uppercase(input, expected):
    assert input.upper() == expected
```

### Mocking
```python
from unittest.mock import Mock, patch, AsyncMock

def test_with_mock():
    mock_service = Mock()
    mock_service.get_user.return_value = User(id=1, name="Test")

    result = process_user(mock_service, 1)

    mock_service.get_user.assert_called_once_with(1)

@patch('module.external_service')
def test_with_patch(mock_service):
    mock_service.call.return_value = "result"
    ...

# Async mock
async def test_async():
    mock = AsyncMock(return_value=User(id=1))
    result = await mock()
```

## Common Idioms

### List Comprehensions
```python
# Filter and transform
active_names = [u.name for u in users if u.active]

# Dict comprehension
user_map = {u.id: u for u in users}

# Set comprehension
unique_emails = {u.email for u in users}
```

### Walrus Operator (Python 3.8+)
```python
# Assign and use in expression
if (user := get_user(id)) is not None:
    process(user)

# In loops
while (line := file.readline()):
    process(line)
```

### Structural Pattern Matching (Python 3.10+)
```python
match command:
    case ["quit"]:
        sys.exit(0)
    case ["load", filename]:
        load_file(filename)
    case ["save", filename, *options]:
        save_file(filename, options)
    case _:
        print("Unknown command")
```

### Enum
```python
from enum import Enum, auto

class Status(Enum):
    PENDING = auto()
    ACTIVE = auto()
    COMPLETED = auto()
    CANCELLED = auto()

user.status = Status.ACTIVE
if user.status == Status.ACTIVE:
    ...
```

## Project Structure

```
myproject/
├── src/
│   └── myproject/
│       ├── __init__.py
│       ├── models/
│       ├── services/
│       ├── api/
│       └── utils/
├── tests/
│   ├── conftest.py
│   ├── unit/
│   └── integration/
├── pyproject.toml
├── requirements.txt
└── README.md
```

## Dependencies

### pyproject.toml (Modern)
```toml
[project]
name = "myproject"
version = "1.0.0"
dependencies = [
    "pydantic>=2.0",
    "httpx>=0.24",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "mypy>=1.0",
    "ruff>=0.1",
]
```

## See Also

- `Skill: language-patterns-base` - Universal principles
- `Skill: testing-strategies` - Comprehensive test strategies
- `Skill: api-design` - RESTful and GraphQL APIs
- `Skill: database-patterns` - SQLAlchemy patterns
