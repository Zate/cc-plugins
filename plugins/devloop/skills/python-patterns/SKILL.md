---
name: python-patterns
description: This skill should be used when working with Python code, implementing Python features, reviewing Python patterns, or when the user asks about "Python type hints", "async/await", "pytest", "Python dataclasses", "Pydantic", "Python idioms", "asyncio", "Python error handling".
whenToUse: |
  - Working with Python 3.10+ code
  - Implementing type hints and type safety
  - Using async/await patterns with asyncio
  - Testing with pytest (fixtures, parametrize, mocking)
  - Understanding dataclasses, Pydantic, context managers
whenNotToUse: |
  - Non-Python code - use go-patterns, java-patterns, react-patterns
  - Python 2 - legacy Python has different patterns
  - Jupyter notebooks - data science has different conventions
  - MicroPython/CircuitPython - embedded Python has constraints
  - Quick scripts - don't over-engineer one-off automation
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

## Reference Files

For detailed patterns, see these reference files:

- [type-hints.md](references/type-hints.md) - Type hints, protocols, generics, TypedDict (~90 lines)
- [async-patterns.md](references/async-patterns.md) - Asyncio, coroutines, concurrent execution, async context managers (~100 lines)
- [testing-pytest.md](references/testing-pytest.md) - Pytest fixtures, parametrize, mocking, coverage (~90 lines)
- [error-handling.md](references/error-handling.md) - Custom exceptions, context managers, error recovery patterns (~60 lines)

## See Also

- `Skill: language-patterns-base` - Universal principles
- `Skill: testing-strategies` - Comprehensive test strategies
- `Skill: api-design` - RESTful and GraphQL APIs
- `Skill: database-patterns` - SQLAlchemy patterns
