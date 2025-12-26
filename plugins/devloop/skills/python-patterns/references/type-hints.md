# Python Type Hints

Complete guide to Python type hints and static typing patterns.

## Basic Types

```python
from typing import Optional, List, Dict, Tuple, Union, Any

def greet(name: str) -> str:
    return f"Hello, {name}"

def get_user(user_id: int) -> Optional[User]:
    ...

def process_items(items: List[str]) -> Dict[str, int]:
    ...
```

## Generic Types (Python 3.9+)

```python
# Use built-in types directly
def process(items: list[str]) -> dict[str, int]:
    ...

# Union with |
def get_value(key: str) -> str | None:
    ...
```

## TypedDict

Typed dictionaries provide type hints for dictionary structures:

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

### Optional Fields

```python
from typing import TypedDict, NotRequired

class UserDict(TypedDict):
    id: int
    name: str
    email: str
    phone: NotRequired[str]  # Optional field
```

## Protocols (Structural Typing)

Protocols enable structural subtyping (duck typing with type hints):

```python
from typing import Protocol

class Readable(Protocol):
    def read(self) -> str:
        ...

def process_readable(source: Readable) -> None:
    content = source.read()
    ...

# Any object with a read() method satisfies this protocol
class FileReader:
    def read(self) -> str:
        return "content"

class StringReader:
    def read(self) -> str:
        return "data"

# Both work with process_readable
process_readable(FileReader())
process_readable(StringReader())
```

## Type Aliases

Create readable aliases for complex types:

```python
from typing import TypeAlias

UserId: TypeAlias = int
UserMap: TypeAlias = dict[UserId, User]
JsonDict: TypeAlias = dict[str, Any]

def get_users() -> UserMap:
    ...
```

## Advanced Type Patterns

### Callable Types

```python
from typing import Callable

def apply_operation(value: int, operation: Callable[[int], int]) -> int:
    return operation(value)

# Usage
apply_operation(5, lambda x: x * 2)
```

### Generic Classes

```python
from typing import Generic, TypeVar

T = TypeVar('T')

class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()

# Usage
int_stack: Stack[int] = Stack()
int_stack.push(42)
```

### Literal Types

```python
from typing import Literal

def set_status(status: Literal["pending", "active", "completed"]) -> None:
    ...

# Valid
set_status("pending")

# Type error
set_status("invalid")  # Type checker will catch this
```

## Type Checking Tools

### Mypy

```bash
# Install
pip install mypy

# Run type checker
mypy src/

# Configuration in mypy.ini or pyproject.toml
[tool.mypy]
python_version = "3.10"
strict = true
warn_return_any = true
warn_unused_configs = true
```

### Pyright/Pylance

Used by VS Code's Pylance extension:

```json
// pyrightconfig.json
{
  "pythonVersion": "3.10",
  "typeCheckingMode": "strict"
}
```

## Best Practices

### DO
- Use type hints for public APIs
- Use `Optional[T]` for nullable values (or `T | None` in Python 3.10+)
- Use Protocol for structural typing
- Use TypeAlias for complex types
- Run type checker in CI/CD

### DON'T
- Don't use `Any` unless absolutely necessary
- Don't use `type: ignore` without a comment explaining why
- Don't mix `typing.List` and `list` in the same file
- Don't over-engineer with complex generics for simple cases

## See Also

- [PEP 484 - Type Hints](https://www.python.org/dev/peps/pep-0484/)
- [Mypy Documentation](https://mypy.readthedocs.io/)
- Main skill: [SKILL.md](../SKILL.md)
