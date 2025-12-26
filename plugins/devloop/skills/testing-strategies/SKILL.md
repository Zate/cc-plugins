---
name: testing-strategies
description: This skill should be used when the user asks about "test coverage", "test pyramid", "unit tests", "integration tests", "E2E tests", or needs to design comprehensive test strategies for deployment readiness.
whenToUse: |
  - Planning test coverage for a feature
  - Designing test strategies (unit, integration, E2E)
  - Understanding the test pyramid
  - Deciding what to test vs what to skip
  - Ensuring deployment readiness through testing
whenNotToUse: |
  - Prototype/spike code - throwaway code doesn't need tests
  - Config changes - environment variables don't need unit tests
  - Pure refactoring - existing tests should cover it
  - Third-party code - don't test dependencies
  - Generated code - tested by the generator
---

# Testing Strategies

Comprehensive guidance for designing and implementing effective test strategies.

## When NOT to Use This Skill

- **Prototype/spike code**: Throwaway code doesn't need tests
- **Config changes**: Environment variables, feature flags don't need unit tests
- **Pure refactoring**: Existing tests should cover refactored code
- **Third-party code**: Don't write tests for dependencies
- **Generated code**: Auto-generated code is tested by the generator

## Quick Reference: Test Pyramid

```
        /\
       /  \     E2E Tests (10%)
      /----\    - User journeys
     /      \   - Critical paths
    /--------\  Integration Tests (20%)
   /          \ - Component interactions
  /------------\- API contracts
 /              \ Unit Tests (70%)
/----------------\- Functions/methods
                  - Edge cases
                  - Error handling
```

## When to Use This Skill

Invoke this skill when:
- Planning test coverage for new features
- Generating tests for existing code
- Evaluating test quality
- Designing deployment validation tests

## Test Types by Purpose

### Unit Tests
**What**: Test individual functions/methods in isolation
**When**: Always - foundational layer
**Coverage target**: 70-80% of test suite

**Characteristics**:
- Fast execution (<100ms each)
- No external dependencies
- Isolated with mocks/stubs
- Test single behavior per test

### Integration Tests
**What**: Test component interactions
**When**: APIs, database operations, service calls
**Coverage target**: 15-25% of test suite

**Characteristics**:
- May use test databases
- Test real interactions
- Slower than unit tests
- Verify contracts

### End-to-End Tests
**What**: Test complete user journeys
**When**: Critical paths, happy paths
**Coverage target**: 5-10% of test suite

**Characteristics**:
- Slowest to run
- Most brittle
- Highest confidence
- Simulate real users

### Deployment Tests
**What**: Validate production readiness
**When**: Pre-deployment, post-deployment
**Types**:
- Smoke tests (basic functionality)
- Health checks (system status)
- Canary tests (gradual rollout)

## Framework-Specific Patterns

### Jest (TypeScript/JavaScript)

```typescript
describe('UserService', () => {
  // Setup
  beforeEach(() => {
    jest.clearAllMocks();
  });

  // Group related tests
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      const result = await userService.createUser(validData);
      expect(result).toMatchObject({ id: expect.any(String) });
    });

    it('should throw on duplicate email', async () => {
      await expect(userService.createUser(duplicateEmail))
        .rejects.toThrow('Email already exists');
    });
  });
});
```

### Go Test

```go
func TestUserService_CreateUser(t *testing.T) {
    tests := []struct {
        name    string
        input   CreateUserInput
        want    *User
        wantErr bool
    }{
        {
            name:  "valid user",
            input: validInput,
            want:  expectedUser,
        },
        {
            name:    "duplicate email",
            input:   duplicateEmail,
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := svc.CreateUser(tt.input)
            if (err != nil) != tt.wantErr {
                t.Fatalf("error = %v, wantErr %v", err, tt.wantErr)
            }
            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("got %v, want %v", got, tt.want)
            }
        })
    }
}
```

### JUnit (Java)

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository repository;

    @InjectMocks
    private UserService service;

    @Test
    void createUser_withValidData_returnsUser() {
        when(repository.save(any())).thenReturn(expectedUser);

        User result = service.createUser(validData);

        assertThat(result).isNotNull();
        assertThat(result.getEmail()).isEqualTo(validData.getEmail());
    }

    @Test
    void createUser_withDuplicateEmail_throwsException() {
        when(repository.existsByEmail(any())).thenReturn(true);

        assertThrows(DuplicateEmailException.class,
            () -> service.createUser(duplicateEmail));
    }
}
```

### Pytest (Python)

```python
import pytest
from myapp.services import UserService

class TestUserService:
    @pytest.fixture
    def service(self, mocker):
        repo = mocker.Mock()
        return UserService(repo)

    def test_create_user_valid_data(self, service):
        result = service.create_user(valid_data)
        assert result.id is not None
        assert result.email == valid_data['email']

    def test_create_user_duplicate_email_raises(self, service):
        service.repo.exists_by_email.return_value = True
        with pytest.raises(DuplicateEmailError):
            service.create_user(duplicate_email)
```

## What to Test

### Always Test
- Public API / exported functions
- Business logic and calculations
- Error handling and edge cases
- State transitions
- Validation rules

### Consider Testing
- Complex private methods (via public interface)
- Integration points
- Configuration handling
- Logging (for critical paths)

### Avoid Testing
- Framework code
- Simple getters/setters
- Third-party libraries
- Implementation details

## Test Naming Conventions

### Descriptive Names
```
// Good
shouldReturnUserWhenValidIdProvided()
shouldThrowNotFoundExceptionWhenUserDoesNotExist()
createsOrderWithCorrectTotalWhenDiscountApplied()

// Bad
testGetUser()
test1()
userTest()
```

### Pattern: Should_ExpectedBehavior_When_Condition
```
should_returnUser_when_validIdProvided
should_throwException_when_userNotFound
should_applyDiscount_when_couponValid
```

## Coverage Strategy

### Focus on Value, Not Percentage
- 100% coverage ≠ bug-free code
- Focus on critical paths first
- Test behavior, not implementation

### Coverage Priorities
1. **Critical business logic** - Must have high coverage
2. **Error handling** - Test all error paths
3. **Edge cases** - Boundaries, nulls, empty
4. **Happy paths** - Basic functionality
5. **Rare paths** - Nice to have

## See Also

- `references/test-pyramid.md` - Detailed pyramid explanation
- `references/mocking-patterns.md` - How to mock effectively
- `references/deployment-tests.md` - Smoke and health checks
