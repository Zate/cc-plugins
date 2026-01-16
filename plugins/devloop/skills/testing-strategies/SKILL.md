---
name: testing-strategies
description: This skill should be used for test coverage, test pyramid, unit/integration/E2E test design, TDD, BDD, mocking strategies, test doubles, test architecture
whenToUse: Designing tests, coverage strategy, test pyramid, TDD, BDD, mocking, test doubles, test organization, E2E testing, integration testing strategy
whenNotToUse: Simple test additions, established patterns, single test file edits
seeAlso:
  - skill: architecture-patterns
    when: test architecture decisions
  - skill: react-patterns
    when: React component testing
  - skill: python-patterns
    when: pytest patterns
  - skill: go-patterns
    when: Go table-driven tests
  - skill: superpowers:test-driven-development
    when: writing tests first, rigorous TDD discipline
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
