---
name: java-patterns
description: Java and Spring best practices including dependency injection, stream patterns, exception handling, testing, and common idioms. Use when working on Java codebases.
---

# Java Patterns

Modern Java and Spring patterns for building robust applications.

## Quick Reference

| Pattern | Use Case | Example |
|---------|----------|---------|
| Constructor injection | DI for required deps | `@RequiredArgsConstructor` |
| Builder | Complex object creation | `User.builder().name("John").build()` |
| Stream API | Collection transformations | `list.stream().filter().map().collect()` |
| Optional | Nullable value handling | `Optional.ofNullable(value)` |
| Records | Immutable data classes | `record User(String name, int age) {}` |

## Spring Dependency Injection

### Constructor Injection (Preferred)

```java
@Service
@RequiredArgsConstructor // Lombok generates constructor
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;

    // Business methods...
}
```

### Configuration Classes

```java
@Configuration
public class AppConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    @Profile("production")
    public EmailService productionEmailService() {
        return new SmtpEmailService();
    }

    @Bean
    @Profile("development")
    public EmailService developmentEmailService() {
        return new MockEmailService();
    }
}
```

## Stream API

### Common Operations

```java
// Filter and transform
List<String> names = users.stream()
    .filter(user -> user.isActive())
    .map(User::getName)
    .collect(Collectors.toList());

// Find first matching
Optional<User> admin = users.stream()
    .filter(user -> user.getRole() == Role.ADMIN)
    .findFirst();

// Group by
Map<Role, List<User>> byRole = users.stream()
    .collect(Collectors.groupingBy(User::getRole));

// Reduce
int totalAge = users.stream()
    .mapToInt(User::getAge)
    .sum();

// Parallel processing (for large datasets)
List<Result> results = items.parallelStream()
    .map(this::expensiveOperation)
    .collect(Collectors.toList());
```

### Stream Best Practices

```java
// Good: Readable chain
users.stream()
    .filter(User::isActive)
    .filter(user -> user.getAge() >= 18)
    .sorted(Comparator.comparing(User::getName))
    .limit(10)
    .collect(Collectors.toList());

// Bad: Complex inline logic
users.stream()
    .filter(u -> u.isActive() && u.getAge() >= 18 &&
                 u.getEmail() != null && u.getEmail().contains("@"))
    .collect(Collectors.toList());

// Good: Extract predicates
Predicate<User> isEligible = user ->
    user.isActive() && user.getAge() >= 18;
Predicate<User> hasValidEmail = user ->
    user.getEmail() != null && user.getEmail().contains("@");

users.stream()
    .filter(isEligible)
    .filter(hasValidEmail)
    .collect(Collectors.toList());
```

## Optional

### Proper Usage

```java
// Good: Return Optional for potentially absent values
public Optional<User> findById(Long id) {
    return Optional.ofNullable(repository.find(id));
}

// Good: Transform and handle
String email = findById(id)
    .map(User::getEmail)
    .orElse("no-email@example.com");

// Good: Throw if required
User user = findById(id)
    .orElseThrow(() -> new NotFoundException("User not found: " + id));

// Bad: Don't use Optional for fields
public class User {
    private Optional<String> nickname; // Don't do this
}

// Bad: Don't use Optional as parameter
public void process(Optional<User> user) { // Don't do this
}
```

## Exception Handling

### Custom Exceptions

```java
// Base exception for domain errors
public abstract class DomainException extends RuntimeException {
    protected DomainException(String message) {
        super(message);
    }

    protected DomainException(String message, Throwable cause) {
        super(message, cause);
    }
}

// Specific exception
public class UserNotFoundException extends DomainException {
    public UserNotFoundException(Long id) {
        super("User not found with id: " + id);
    }
}

// With additional context
public class ValidationException extends DomainException {
    private final Map<String, String> errors;

    public ValidationException(Map<String, String> errors) {
        super("Validation failed");
        this.errors = errors;
    }

    public Map<String, String> getErrors() {
        return errors;
    }
}
```

### Global Exception Handler

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(UserNotFoundException e) {
        return ResponseEntity
            .status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse(e.getMessage()));
    }

    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ErrorResponse> handleValidation(ValidationException e) {
        return ResponseEntity
            .status(HttpStatus.BAD_REQUEST)
            .body(new ErrorResponse("Validation failed", e.getErrors()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneric(Exception e) {
        log.error("Unexpected error", e);
        return ResponseEntity
            .status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(new ErrorResponse("An unexpected error occurred"));
    }
}
```

## Records (Java 14+)

```java
// Immutable data class
public record UserDTO(
    Long id,
    String name,
    String email,
    LocalDateTime createdAt
) {
    // Compact constructor for validation
    public UserDTO {
        Objects.requireNonNull(name, "name cannot be null");
        Objects.requireNonNull(email, "email cannot be null");
    }

    // Static factory method
    public static UserDTO from(User user) {
        return new UserDTO(
            user.getId(),
            user.getName(),
            user.getEmail(),
            user.getCreatedAt()
        );
    }
}
```

## Builder Pattern

```java
@Builder
@Getter
public class User {
    private final Long id;
    private final String name;
    private final String email;
    @Builder.Default
    private final boolean active = true;
    @Builder.Default
    private final LocalDateTime createdAt = LocalDateTime.now();
}

// Usage
User user = User.builder()
    .name("John Doe")
    .email("john@example.com")
    .build();
```

## Testing

### Unit Tests with JUnit 5

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository repository;

    @Mock
    private EmailService emailService;

    @InjectMocks
    private UserService service;

    @Test
    void createUser_withValidData_createsAndSendsEmail() {
        // Given
        CreateUserRequest request = new CreateUserRequest("john@example.com", "John");
        when(repository.save(any())).thenAnswer(inv -> {
            User user = inv.getArgument(0);
            return user.toBuilder().id(1L).build();
        });

        // When
        User result = service.createUser(request);

        // Then
        assertThat(result.getId()).isEqualTo(1L);
        assertThat(result.getName()).isEqualTo("John");
        verify(emailService).sendWelcomeEmail(result);
    }

    @Test
    void createUser_withDuplicateEmail_throwsException() {
        // Given
        when(repository.existsByEmail(any())).thenReturn(true);

        // When/Then
        assertThatThrownBy(() -> service.createUser(request))
            .isInstanceOf(DuplicateEmailException.class)
            .hasMessageContaining("already exists");
    }
}
```

### Integration Tests

```java
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class UserControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository repository;

    @Test
    void getUser_returnsUser() throws Exception {
        // Given
        User user = repository.save(User.builder()
            .name("John")
            .email("john@example.com")
            .build());

        // When/Then
        mockMvc.perform(get("/api/users/{id}", user.getId()))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.name").value("John"))
            .andExpect(jsonPath("$.email").value("john@example.com"));
    }
}
```

## Resource Management

### Try-with-Resources

```java
// Good: Automatic resource cleanup
try (var connection = dataSource.getConnection();
     var statement = connection.prepareStatement(sql);
     var resultSet = statement.executeQuery()) {

    while (resultSet.next()) {
        // Process results
    }
}
// Resources automatically closed
```

## Anti-Patterns to Avoid

- **Field injection**: Use constructor injection instead
- **Catching Exception/Throwable**: Catch specific exceptions
- **Returning null**: Use Optional or throw exception
- **Mutable return types**: Return immutable collections
- **God classes**: Keep classes focused

## See Also

- `references/spring-patterns.md` - Spring-specific patterns
- `references/streams.md` - Advanced stream operations
- `references/testing.md` - Testing strategies
