# Python Patterns for Rovo Dev CLI

Python best practices and patterns specific to the Rovo Dev CLI project.

## Code Style

### Formatting
- **Tool**: ruff (line length: 120)
- **Import sorting**: ruff with isort rules
- **Linting**: pylint, ruff

### Checks
```bash
# Check formatting
uv run ruff format --check .
uv run ruff check --select I .

# Apply formatting
uv run ruff format .
```

## Import Guidelines

### Standard Pattern
```python
# Standard library
import os
import sys
from pathlib import Path
from typing import Optional, List, Dict, Any

# Third-party
import click
from pydantic import BaseModel

# Local
from acra.cli.utils import format_output
from acra.cli.config import load_config
```

**Rules**:
- Imports at the top of the file by default
- Only use local imports if there's a measured performance benefit
- Add a comment if using local imports for performance

### Avoid This
```python
# ❌ Don't do this without good reason
def my_function():
    import some_module  # Only if performance-critical and documented
    ...
```

### Do This Instead
```python
# ✅ Imports at top
import some_module

def my_function():
    some_module.function()
```

## Type Hints

### Use Type Hints for Public APIs

```python
# ✅ Good
def validate_config(config: dict[str, Any]) -> bool:
    """Validate configuration dictionary."""
    return "api_key" in config

# ✅ Good with Optional
def get_user(user_id: str) -> Optional[dict[str, Any]]:
    """Fetch user by ID."""
    return db.query(user_id)

# ✅ Good with Union (Python 3.10+)
def process_input(data: str | bytes) -> str:
    """Process string or bytes input."""
    if isinstance(data, bytes):
        return data.decode()
    return data
```

### Common Type Patterns

```python
from typing import Optional, List, Dict, Any, Callable

# Optional - may be None
def get_value(key: str) -> Optional[str]:
    ...

# Lists and Dicts
def process_items(items: List[str]) -> Dict[str, int]:
    ...

# Any for dynamic content
def parse_json(data: str) -> Dict[str, Any]:
    ...

# Callables
def retry(func: Callable[..., Any], attempts: int = 3) -> Any:
    ...
```

## Error Handling

### Specific Exceptions

```python
# ✅ Good - specific exceptions
try:
    config = load_config()
except FileNotFoundError:
    logger.error("Config file not found")
    raise
except json.JSONDecodeError as e:
    logger.error(f"Invalid JSON: {e}")
    raise ValueError("Config file is malformed") from e

# ❌ Avoid bare except
try:
    risky_operation()
except:  # Too broad
    pass
```

### Custom Exceptions

```python
class ConfigError(Exception):
    """Configuration-related errors."""
    pass

class AuthenticationError(Exception):
    """Authentication failures."""
    pass

# Usage
if not api_key:
    raise ConfigError("API key is required")
```

## Click Patterns

### Command Structure

```python
import click

@click.command()
@click.argument('message', nargs=-1)
@click.option('--shadow', is_flag=True, help='Enable shadow mode')
@click.option('--verbose', is_flag=True, help='Show verbose output')
def run(message: tuple[str, ...], shadow: bool, verbose: bool):
    """Run the Rovo Dev coding agent."""
    # Join message parts
    instruction = ' '.join(message)
    
    # Execute
    agent.run(instruction, shadow=shadow, verbose=verbose)
```

### Option Groups

```python
@click.group()
def cli():
    """Rovo Dev CLI."""
    pass

@cli.command()
def run():
    """Run the agent."""
    pass

@cli.command()
def config():
    """Configure Rovo Dev."""
    pass
```

## Pydantic Models

### Configuration Models

```python
from pydantic import BaseModel, Field, validator

class AgentConfig(BaseModel):
    """Agent configuration."""
    
    api_key: str = Field(..., description="API key for authentication")
    endpoint: str = Field(default="https://api.example.com")
    timeout: int = Field(default=30, ge=1, le=300)
    
    @validator('api_key')
    def validate_api_key(cls, v):
        if not v or len(v) < 10:
            raise ValueError("Invalid API key")
        return v

# Usage
config = AgentConfig(api_key="abc123...", timeout=60)
```

## File Operations

### Use pathlib

```python
from pathlib import Path

# ✅ Good
config_path = Path.home() / ".rovodev" / "config.yml"
if config_path.exists():
    content = config_path.read_text()

# ❌ Avoid os.path for new code
import os
config_path = os.path.join(os.path.expanduser("~"), ".rovodev", "config.yml")
if os.path.exists(config_path):
    with open(config_path) as f:
        content = f.read()
```

### Context Managers

```python
# ✅ Good - automatic cleanup
with open(file_path) as f:
    content = f.read()

# ✅ Good - custom context manager
from contextlib import contextmanager

@contextmanager
def temp_directory():
    import tempfile
    import shutil
    
    temp_dir = tempfile.mkdtemp()
    try:
        yield Path(temp_dir)
    finally:
        shutil.rmtree(temp_dir)

# Usage
with temp_directory() as tmp:
    # Work with temporary directory
    (tmp / "file.txt").write_text("content")
```

## Testing Patterns

### Pytest Structure

```python
import pytest
from acra.cli.auth import validate_token

def test_validate_token_with_valid_token():
    """Test token validation with a valid token."""
    token = "valid.jwt.token"
    
    result = validate_token(token)
    
    assert result is True

def test_validate_token_with_invalid_token():
    """Test token validation with an invalid token."""
    token = "invalid"
    
    result = validate_token(token)
    
    assert result is False

def test_validate_token_with_none():
    """Test token validation raises error for None."""
    with pytest.raises(ValueError, match="Token cannot be None"):
        validate_token(None)
```

### Fixtures

```python
# conftest.py
import pytest
from pathlib import Path

@pytest.fixture
def temp_config(tmp_path):
    """Create temporary config file."""
    config_path = tmp_path / "config.yml"
    config_path.write_text("api_key: test123\n")
    return config_path

# test file
def test_load_config(temp_config):
    """Test config loading."""
    config = load_config(temp_config)
    assert config["api_key"] == "test123"
```

### Parametrized Tests

```python
@pytest.mark.parametrize("input,expected", [
    ("test@example.com", True),
    ("invalid-email", False),
    ("", False),
    (None, False),
])
def test_validate_email(input, expected):
    """Test email validation with various inputs."""
    result = validate_email(input)
    assert result == expected
```

## Logging

```python
import logging

logger = logging.getLogger(__name__)

def process_request(data: dict) -> dict:
    """Process incoming request."""
    logger.debug(f"Processing request: {data}")
    
    try:
        result = expensive_operation(data)
        logger.info("Request processed successfully")
        return result
    except Exception as e:
        logger.error(f"Failed to process request: {e}", exc_info=True)
        raise
```

## Common Pitfalls

### Mutable Default Arguments

```python
# ❌ Wrong - mutable default
def add_item(item, items=[]):
    items.append(item)
    return items

# ✅ Correct
def add_item(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

### None Comparisons

```python
# ❌ Wrong
if value == None:
    pass

# ✅ Correct
if value is None:
    pass

# ❌ Wrong
if is_valid == True:
    pass

# ✅ Correct
if is_valid:
    pass
```

### String Checks

```python
# ❌ Wrong
if not "key" in config:
    pass

# ✅ Correct
if "key" not in config:
    pass
```

## Documentation

### Docstring Format

```python
def complex_function(param1: str, param2: int, param3: Optional[bool] = None) -> Dict[str, Any]:
    """Brief one-line description.
    
    More detailed explanation if needed. Can span multiple lines
    and include implementation details.
    
    Args:
        param1: Description of param1
        param2: Description of param2
        param3: Description of param3. Defaults to None.
        
    Returns:
        Dictionary containing the results with keys:
        - 'status': Operation status
        - 'data': Result data
        
    Raises:
        ValueError: If param1 is empty
        RuntimeError: If operation fails
        
    Example:
        >>> result = complex_function("test", 42)
        >>> result['status']
        'success'
    """
    pass
```

## Package-Specific Commands

```bash
# Build specific package
uv build --package atlassian-cli-rovodev

# Run tests for specific package
uv run --package atlassian-code-nautilus pytest

# Run script from specific package
uv run --package atlassian-cli-rovodev python -m acra.cli.main
```
