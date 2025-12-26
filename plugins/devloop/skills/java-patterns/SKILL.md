---
name: java-patterns
description: This skill should be used when working with Java/Spring code, implementing Java features, reviewing Java patterns, or when the user asks about "Spring dependency injection", "Java streams", "Java Optional", "Spring Boot", "JUnit", "Java records", "Lombok", "Java exception handling".
whenToUse: |
  - Working with Java 17+ code
  - Implementing Spring/Spring Boot patterns
  - Using dependency injection and IoC
  - Working with Stream API and functional patterns
  - Testing with JUnit 5 and Mockito
whenNotToUse: |
  - Non-Java code - use go-patterns, python-patterns, react-patterns
  - Legacy Java 8 - different patterns for older versions
  - Non-Spring projects - some patterns are Spring-specific
  - Android development - Android has its own conventions
  - Kotlin codebase - Kotlin has different idioms on JVM
---

# Java Patterns

Modern Java and Spring patterns. **Extends** `language-patterns-base` with Java-specific guidance.

**Java Version**: Targets Java 17+ LTS. Records require Java 16+, pattern matching requires Java 21+.

> For universal principles (AAA testing, separation of concerns, naming), see `Skill: language-patterns-base`.

## When NOT to Use This Skill

- **Non-Java code**: Use go-patterns, python-patterns, react-patterns instead
- **Legacy Java 8**: Different patterns for older Java versions
- **Non-Spring projects**: Some patterns are Spring-specific
- **Android development**: Android has its own conventions
- **Kotlin codebase**: Kotlin has different idioms even on JVM

## Quick Reference

| Pattern | Use Case | Example |
|---------|----------|---------|
| Constructor injection | DI for required deps | `@RequiredArgsConstructor` |
| Builder | Complex object creation | `User.builder().name("John").build()` |
| Stream API | Collection transformations | `list.stream().filter().map().collect()` |
| Optional | Nullable value handling | `Optional.ofNullable(value)` |
| Records | Immutable data classes | `record User(String name, int age) {}` |

## Core Patterns Overview

### Dependency Injection

```java
@Service
@RequiredArgsConstructor // Lombok generates constructor for final fields
public class UserService {
    private final UserRepository repository;
    private final EmailService emailService;
}
```

Use constructor injection (not field injection), make dependencies final.

> **See**: `references/dependency-injection.md` - qualifiers, circular dependencies, bean lifecycle
> **See**: `references/spring-patterns.md` - configuration, profiles, AOP, events

### Stream API

```java
// Filter, transform, group
List<String> names = users.stream().filter(User::isActive).map(User::getName).collect(toList());
Map<Role, List<User>> byRole = users.stream().collect(groupingBy(User::getRole));
Optional<User> admin = users.stream().filter(u -> u.getRole() == ADMIN).findFirst();
```

Use method references, extract complex predicates, prefer `mapToInt/Long/Double` for primitives.

> **See**: `references/streams.md` - collectors, reduce, parallel streams, custom collectors

### Optional

```java
// Return Optional from methods
public Optional<User> findById(Long id) {
    return Optional.ofNullable(repository.find(id));
}

// Transform and provide default
String email = findById(id)
    .map(User::getEmail)
    .orElse("no-email@example.com");

// Throw if missing
User user = findById(id)
    .orElseThrow(() -> new NotFoundException("User not found: " + id));
```

**Anti-patterns:**
- Don't use Optional for fields
- Don't use Optional as method parameters
- Don't call `get()` without checking `isPresent()`

### Records (Java 16+)

```java
// Immutable data class with validation
public record UserDTO(Long id, String name, String email) {
    public UserDTO {
        Objects.requireNonNull(name, "name cannot be null");
        Objects.requireNonNull(email, "email cannot be null");
    }
}
```

### Exception Handling

```java
// Custom exception
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(Long id) {
        super("User not found with id: " + id);
    }
}

// Global exception handler
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(UserNotFoundException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse(e.getMessage()));
    }
}
```

### Builder Pattern

```java
@Builder
public class User {
    private final String name;
    private final String email;
    @Builder.Default
    private final boolean active = true;
}

// Usage: User.builder().name("John").email("john@example.com").build()
```

## Testing

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    @Mock private UserRepository repository;
    @InjectMocks private UserService service;

    @Test
    void createUser_withValidData_savesUser() {
        when(repository.save(any())).thenReturn(savedUser);
        User result = service.createUser(request);
        assertThat(result.getId()).isNotNull();
        verify(repository).save(any());
    }
}
```

> **See**: `references/testing-junit.md` - Mockito, parameterized tests, Spring Test, integration tests

## Anti-Patterns to Avoid

- **Field injection**: Use constructor injection instead
- **Catching Exception/Throwable**: Catch specific exceptions
- **Returning null**: Use Optional or throw exception
- **Mutable return types**: Return immutable collections
- **God classes**: Keep classes focused
- **Optional fields**: Don't use Optional as fields
- **Complex streams**: Extract predicates for readability

## References

For detailed patterns and advanced topics, see:

- **`references/spring-patterns.md`** (~100 lines)
  - Spring Boot configuration and profiles
  - Bean scopes and lifecycle management
  - Aspect-Oriented Programming (AOP)
  - Event-driven patterns
  - Component scanning strategies

- **`references/streams.md`** (~90 lines)
  - Collectors (grouping, joining, summarizing)
  - Reduce operations and specialized streams
  - Parallel stream best practices
  - Custom collectors
  - Performance optimization tips

- **`references/testing-junit.md`** (~80 lines)
  - JUnit 5 lifecycle and assertions
  - Mockito stubbing and verification
  - Parameterized tests (CSV, Method, Enum sources)
  - Spring Boot test slices (@WebMvcTest, @DataJpaTest)
  - Integration testing with Testcontainers

- **`references/dependency-injection.md`** (~60 lines)
  - Constructor vs setter vs field injection
  - Qualifiers and @Primary
  - Conditional beans and profiles
  - Circular dependency solutions
  - Factory and strategy patterns with DI

## See Also

- `Skill: language-patterns-base` - Universal principles
- `Skill: testing-strategies` - Comprehensive test strategies
- `Skill: architecture-patterns` - High-level design
