---
name: architecture-patterns
description: This skill should be used for system design, design patterns, architectural decisions, SOLID principles, clean code structure, code organization, refactoring strategy, software architecture
whenToUse: Architecture design, design patterns, system structure, code organization, refactoring, clean code, SOLID, dependency injection, layered architecture
whenNotToUse: Simple implementations, established patterns, trivial changes
seeAlso:
  - skill: api-design
    when: designing service APIs
  - skill: database-patterns
    when: data layer architecture
  - skill: testing-strategies
    when: test architecture decisions
---

# Architecture Patterns

Common architectural patterns and design decisions.

## Layered Architecture

```
Presentation → Business Logic → Data Access → Database
```

## Clean Architecture

```
        Controllers
             ↓
        Use Cases
             ↓
         Entities
```

## Common Patterns

### Repository

```
interface UserRepository {
    findById(id): User
    save(user): void
}
```

### Service Layer

```
class UserService {
    constructor(repo: UserRepository)
    createUser(data): User
}
```

### Dependency Injection

- Pass dependencies via constructor
- Program to interfaces, not implementations
- Enables testing with mocks

## Design Principles

- **SOLID**: Single responsibility, Open/closed, Liskov, Interface segregation, Dependency inversion
- **DRY**: Don't repeat yourself
- **KISS**: Keep it simple
- **YAGNI**: You aren't gonna need it
