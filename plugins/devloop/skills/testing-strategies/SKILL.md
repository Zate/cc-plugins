---
name: testing-strategies
description: This skill should be used for test coverage, test pyramid, unit/integration/E2E test design, TDD, BDD, mocking strategies, test doubles, test architecture
whenToUse: Test architecture, coverage strategy, TDD, mocking patterns
whenNotToUse: Quick fixes that do not need new tests, documentation
---

# Testing Strategies

Comprehensive test design for deployment readiness.

## Test Pyramid

```
    /  E2E  \       Few, slow, expensive
   /  Integ  \      Some, medium
  /   Unit    \     Many, fast, cheap
```

## Coverage Guidelines

| Level | Coverage | Focus |
|-------|----------|-------|
| Unit | 80%+ | Business logic |
| Integration | Key paths | APIs, DB |
| E2E | Critical flows | User journeys |

## Unit Test Patterns

- Test one thing per test
- Clear arrange/act/assert
- Mock external dependencies
- Fast execution (<1s each)

## Integration Test Patterns

- Test real dependencies
- Use test databases
- Clean up after tests
- Cover API contracts

## E2E Test Patterns

- Critical user journeys only
- Stable selectors
- Retry flaky network calls
- Parallel where possible
