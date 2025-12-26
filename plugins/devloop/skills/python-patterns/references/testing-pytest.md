# Python Testing with Pytest

Comprehensive guide to testing Python code with pytest.

## Basic Tests

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

## Assertion Patterns

### Basic Assertions

```python
# Equality
assert result == expected
assert result != unexpected

# Truthiness
assert value
assert not value

# Membership
assert item in collection
assert item not in collection

# Type checking
assert isinstance(obj, User)

# Approximate equality (floats)
assert result == pytest.approx(0.1 + 0.2)
```

### Advanced Assertions

```python
# Multiple assertions (all must pass)
assert all([
    user.is_active,
    user.email_verified,
    len(user.roles) > 0
])

# Any assertion (at least one must pass)
assert any([
    user.is_admin,
    user.is_moderator
])

# Dictionary assertions
assert result == {
    "id": pytest.approx(1),
    "name": "John",
    "status": "active"
}
```

## Fixtures

Fixtures provide reusable test setup and teardown:

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

### Fixture Scopes

```python
@pytest.fixture(scope="function")  # Default: new instance per test
def user_function():
    return User()

@pytest.fixture(scope="class")  # One instance per test class
def user_class():
    return User()

@pytest.fixture(scope="module")  # One instance per module
def db_module():
    return create_db()

@pytest.fixture(scope="session")  # One instance per test session
def app_session():
    return create_app()
```

### Fixture Dependencies

```python
@pytest.fixture
def database():
    db = create_database()
    yield db
    db.close()

@pytest.fixture
def user_repository(database):
    return UserRepository(database)

@pytest.fixture
def user_service(user_repository):
    return UserService(user_repository)

def test_create_user(user_service):
    user = user_service.create(name="John")
    assert user.id is not None
```

### Fixture Finalization

```python
@pytest.fixture
def resource():
    r = acquire_resource()
    yield r
    r.cleanup()  # Always runs, even if test fails

# Alternative with finalizer
@pytest.fixture
def resource_alt(request):
    r = acquire_resource()
    request.addfinalizer(r.cleanup)
    return r
```

## Parametrized Tests

Run the same test with different inputs:

```python
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("world", "WORLD"),
    ("", ""),
])
def test_uppercase(input, expected):
    assert input.upper() == expected

# Multiple parameters
@pytest.mark.parametrize("a,b,expected", [
    (1, 2, 3),
    (2, 3, 5),
    (10, 20, 30),
])
def test_addition(a, b, expected):
    assert a + b == expected

# Parametrize with IDs
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("world", "WORLD"),
], ids=["lowercase_hello", "lowercase_world"])
def test_with_ids(input, expected):
    assert input.upper() == expected
```

### Combining Parametrize

```python
@pytest.mark.parametrize("x", [1, 2])
@pytest.mark.parametrize("y", [3, 4])
def test_combinations(x, y):
    # Runs 4 times: (1,3), (1,4), (2,3), (2,4)
    assert x + y > 0
```

## Mocking

### Using unittest.mock

```python
from unittest.mock import Mock, patch, AsyncMock, MagicMock

def test_with_mock():
    mock_service = Mock()
    mock_service.get_user.return_value = User(id=1, name="Test")

    result = process_user(mock_service, 1)

    mock_service.get_user.assert_called_once_with(1)
    assert result.name == "Test"

# Patch decorator
@patch('module.external_service')
def test_with_patch(mock_service):
    mock_service.call.return_value = "result"
    result = my_function()
    assert result == "result"

# Patch multiple
@patch('module.service_a')
@patch('module.service_b')
def test_multiple_patches(mock_b, mock_a):
    # Note: patches are applied bottom-up
    ...

# Context manager
def test_with_context():
    with patch('module.external_service') as mock_service:
        mock_service.return_value = "result"
        result = my_function()
        assert result == "result"
```

### Mock Return Values

```python
# Simple return value
mock.method.return_value = "result"

# Side effects (different return each call)
mock.method.side_effect = [1, 2, 3]
assert mock.method() == 1
assert mock.method() == 2
assert mock.method() == 3

# Raise exception
mock.method.side_effect = ValueError("Error")

# Custom function
def custom_side_effect(arg):
    return arg * 2

mock.method.side_effect = custom_side_effect
```

### Async Mocking

```python
# Async mock
async def test_async():
    mock = AsyncMock(return_value=User(id=1))
    result = await mock()
    assert result.id == 1

# Mock async method
mock_service = Mock()
mock_service.get_user = AsyncMock(return_value=User(id=1))

result = await mock_service.get_user(1)
```

### Assertions on Mocks

```python
# Called
mock.method.assert_called()
mock.method.assert_called_once()

# Called with specific args
mock.method.assert_called_with(1, 2, key="value")
mock.method.assert_called_once_with(1, 2)

# Any call
mock.method.assert_any_call(1, 2)

# Call count
assert mock.method.call_count == 3

# Not called
mock.method.assert_not_called()

# Call arguments
assert mock.method.call_args == ((1, 2), {'key': 'value'})
```

## Test Organization

### conftest.py

Shared fixtures across test modules:

```python
# tests/conftest.py
import pytest

@pytest.fixture(scope="session")
def app():
    return create_app()

@pytest.fixture
def client(app):
    return app.test_client()

# Available to all test files in tests/
```

### Test Classes

```python
class TestUserService:
    """Group related tests together"""

    @pytest.fixture
    def service(self):
        return UserService()

    def test_create_user(self, service):
        user = service.create(name="John")
        assert user.id is not None

    def test_delete_user(self, service):
        service.delete(1)
        # Assertions...
```

## Markers

### Built-in Markers

```python
# Skip test
@pytest.mark.skip(reason="Not implemented yet")
def test_future_feature():
    ...

# Skip conditionally
@pytest.mark.skipif(sys.version_info < (3, 10), reason="Requires Python 3.10+")
def test_new_syntax():
    ...

# Expected to fail
@pytest.mark.xfail(reason="Known bug")
def test_broken_feature():
    ...

# Slow tests
@pytest.mark.slow
def test_expensive_operation():
    ...

# Run with: pytest -m slow
# Skip with: pytest -m "not slow"
```

### Custom Markers

```python
# pytest.ini or pyproject.toml
[tool.pytest.ini_options]
markers = [
    "slow: marks tests as slow",
    "integration: marks tests as integration tests",
    "unit: marks tests as unit tests"
]

# Usage
@pytest.mark.integration
def test_database_integration():
    ...

# Run: pytest -m integration
```

## Coverage

```bash
# Install
pip install pytest-cov

# Run with coverage
pytest --cov=myapp tests/

# HTML report
pytest --cov=myapp --cov-report=html tests/

# Fail if coverage below threshold
pytest --cov=myapp --cov-fail-under=80 tests/
```

## Best Practices

### DO
- Use descriptive test names
- One assertion per test (when possible)
- Use fixtures for setup/teardown
- Use parametrize for similar tests
- Mock external dependencies
- Test edge cases and errors

### DON'T
- Don't test implementation details
- Don't write tests that depend on each other
- Don't use sleep() (use proper async or mocks)
- Don't test third-party code
- Don't ignore failing tests

## Common Patterns

### AAA Pattern

```python
def test_user_creation():
    # Arrange
    data = {"name": "John", "email": "john@example.com"}

    # Act
    user = User(**data)

    # Assert
    assert user.name == "John"
```

### Testing Exceptions

```python
def test_raises_on_invalid_input():
    with pytest.raises(ValueError) as exc_info:
        process_data(invalid_data)

    assert "invalid" in str(exc_info.value)
```

### Testing Warnings

```python
def test_deprecation_warning():
    with pytest.warns(DeprecationWarning):
        deprecated_function()
```

## See Also

- [pytest documentation](https://docs.pytest.org/)
- [pytest-asyncio](https://pytest-asyncio.readthedocs.io/) - Async test support
- [pytest-mock](https://pytest-mock.readthedocs.io/) - Improved mocking
- [Skill: testing-strategies](../../testing-strategies/SKILL.md) - Overall test strategy
- Main skill: [SKILL.md](../SKILL.md)
