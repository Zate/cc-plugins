---
name: python-patterns
description: This skill should be used for Python idioms, type hints, async/await, pytest
whenToUse: Python code, type hints, async, pytest
whenNotToUse: Non-Python code
---

# Python Patterns

Idiomatic Python patterns for Python 3.10+.

## Type Hints

```python
def process(data: list[str]) -> dict[str, int]:
    return {item: len(item) for item in data}
```

## Dataclasses

```python
from dataclasses import dataclass

@dataclass
class User:
    name: str
    email: str
    active: bool = True
```

## Context Managers

```python
with open("file.txt") as f:
    content = f.read()
```

## Pytest

```python
import pytest

def test_add():
    assert add(2, 3) == 5

@pytest.fixture
def user():
    return User(name="test")
```

## Async/Await

```python
async def fetch_data(url: str) -> dict:
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.json()
```

## Error Handling

```python
try:
    result = risky_operation()
except ValueError as e:
    logger.error(f"Invalid value: {e}")
    raise
```
