# JUnit 5 and Testing Patterns

Comprehensive guide to testing Java applications with JUnit 5, Mockito, and Spring Test.

## JUnit 5 Basics

### Test Structure

```java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class CalculatorTest {

    @Test
    void add_withPositiveNumbers_returnsSum() {
        // Arrange
        Calculator calc = new Calculator();

        // Act
        int result = calc.add(2, 3);

        // Assert
        assertEquals(5, result);
    }

    @Test
    void divide_byZero_throwsException() {
        Calculator calc = new Calculator();

        assertThrows(ArithmeticException.class, () -> {
            calc.divide(10, 0);
        });
    }
}
```

### Lifecycle Annotations

```java
import org.junit.jupiter.api.*;

class UserServiceTest {

    @BeforeAll
    static void beforeAll() {
        // Runs once before all tests
        System.out.println("Starting test suite");
    }

    @AfterAll
    static void afterAll() {
        // Runs once after all tests
        System.out.println("Finishing test suite");
    }

    @BeforeEach
    void setUp() {
        // Runs before each test
        System.out.println("Setting up test");
    }

    @AfterEach
    void tearDown() {
        // Runs after each test
        System.out.println("Tearing down test");
    }

    @Test
    void testSomething() {
        // Test code
    }
}
```

### Assertions

```java
import static org.junit.jupiter.api.Assertions.*;

@Test
void testAssertions() {
    // Basic assertions
    assertEquals(expected, actual);
    assertNotEquals(unexpected, actual);
    assertTrue(condition);
    assertFalse(condition);
    assertNull(object);
    assertNotNull(object);
    assertSame(expected, actual); // Reference equality
    assertNotSame(unexpected, actual);

    // Array assertions
    assertArrayEquals(expectedArray, actualArray);

    // Collection assertions
    assertIterableEquals(expectedList, actualList);

    // Assertions with messages
    assertEquals(expected, actual, "Custom error message");
    assertEquals(expected, actual, () -> "Lazy message: " + expensiveOperation());

    // Multiple assertions
    assertAll(
        () -> assertEquals("John", user.getName()),
        () -> assertEquals("john@example.com", user.getEmail()),
        () -> assertTrue(user.isActive())
    );

    // Exception assertions
    Exception exception = assertThrows(IllegalArgumentException.class, () -> {
        service.doSomething(invalidInput);
    });
    assertEquals("Invalid input", exception.getMessage());

    // Timeout assertions
    assertTimeout(Duration.ofSeconds(1), () -> {
        service.slowOperation();
    });
}
```

### AssertJ Fluent Assertions

```java
import static org.assertj.core.api.Assertions.*;

@Test
void testWithAssertJ() {
    // More readable assertions
    assertThat(user.getName()).isEqualTo("John");
    assertThat(user.getAge()).isGreaterThan(18);
    assertThat(user.getEmail()).contains("@").endsWith(".com");

    // Collection assertions
    assertThat(users)
        .hasSize(3)
        .extracting(User::getName)
        .containsExactly("Alice", "Bob", "Charlie");

    // Object assertions
    assertThat(user)
        .hasFieldOrPropertyWithValue("name", "John")
        .hasFieldOrPropertyWithValue("age", 30);

    // Exception assertions
    assertThatThrownBy(() -> service.doSomething())
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("Invalid");

    // Custom assertions
    assertThat(user)
        .satisfies(u -> {
            assertThat(u.getName()).isNotEmpty();
            assertThat(u.getEmail()).contains("@");
        });
}
```

## Mockito

### Basic Mocking

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.InjectMocks;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository repository;

    @Mock
    private EmailService emailService;

    @InjectMocks
    private UserService service;

    @Test
    void createUser_withValidData_savesAndSendsEmail() {
        // Arrange
        User user = new User("john@example.com", "John");
        when(repository.save(any(User.class))).thenReturn(user);

        // Act
        service.createUser(user);

        // Assert
        verify(repository).save(user);
        verify(emailService).sendWelcomeEmail(user);
    }
}
```

### Stubbing Methods

```java
// Return value
when(repository.findById(1L)).thenReturn(Optional.of(user));

// Throw exception
when(repository.findById(999L)).thenThrow(new NotFoundException());

// Multiple calls
when(service.getValue())
    .thenReturn("first")
    .thenReturn("second")
    .thenThrow(new RuntimeException());

// Argument matchers
when(repository.findByEmail(anyString())).thenReturn(Optional.of(user));
when(calculator.add(eq(5), anyInt())).thenReturn(10);

// Custom matcher
when(repository.save(argThat(u -> u.getAge() > 18))).thenReturn(user);

// Answer with logic
when(repository.save(any())).thenAnswer(invocation -> {
    User input = invocation.getArgument(0);
    return input.toBuilder().id(1L).build();
});

// Void methods that throw
doThrow(new RuntimeException()).when(emailService).sendEmail(any());

// Void methods with answer
doAnswer(invocation -> {
    User user = invocation.getArgument(0);
    System.out.println("Sending email to: " + user.getEmail());
    return null;
}).when(emailService).sendWelcomeEmail(any());
```

### Verification

```java
// Verify method called
verify(repository).save(user);

// Verify with argument matchers
verify(emailService).sendEmail(eq("john@example.com"), anyString());

// Verify number of invocations
verify(repository, times(1)).save(user);
verify(repository, times(3)).findById(anyLong());
verify(repository, atLeast(1)).save(any());
verify(repository, atMost(2)).save(any());
verify(repository, never()).delete(any());

// Verify order
InOrder inOrder = inOrder(repository, emailService);
inOrder.verify(repository).save(user);
inOrder.verify(emailService).sendWelcomeEmail(user);

// Verify no more interactions
verify(repository).save(user);
verifyNoMoreInteractions(repository);

// Verify argument
ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
verify(repository).save(captor.capture());
User captured = captor.getValue();
assertEquals("john@example.com", captured.getEmail());
```

### Spies

```java
// Spy on real object
List<String> list = new ArrayList<>();
List<String> spy = spy(list);

// Can stub specific methods
when(spy.size()).thenReturn(100);

// Real methods are called unless stubbed
spy.add("one");
spy.add("two");

assertEquals(100, spy.size()); // Stubbed
assertEquals("one", spy.get(0)); // Real method
```

## Parameterized Tests

### Basic Parameterized Test

```java
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.*;

class CalculatorTest {

    @ParameterizedTest
    @ValueSource(ints = {1, 2, 3, 4, 5})
    void isPositive_withPositiveNumbers_returnsTrue(int number) {
        assertTrue(number > 0);
    }

    @ParameterizedTest
    @ValueSource(strings = {"", "  ", "\t", "\n"})
    void isBlank_withBlankStrings_returnsTrue(String input) {
        assertTrue(input.isBlank());
    }
}
```

### CSV Source

```java
@ParameterizedTest
@CsvSource({
    "1, 1, 2",
    "2, 3, 5",
    "10, 20, 30"
})
void add_withTwoNumbers_returnsSum(int a, int b, int expected) {
    assertEquals(expected, calculator.add(a, b));
}

@ParameterizedTest
@CsvFileSource(resources = "/test-data.csv", numLinesToSkip = 1)
void testWithCsvFile(int a, int b, int expected) {
    assertEquals(expected, calculator.add(a, b));
}
```

### Method Source

```java
@ParameterizedTest
@MethodSource("userProvider")
void testWithMethodSource(User user) {
    assertNotNull(user.getName());
    assertNotNull(user.getEmail());
}

static Stream<User> userProvider() {
    return Stream.of(
        new User("Alice", "alice@example.com"),
        new User("Bob", "bob@example.com"),
        new User("Charlie", "charlie@example.com")
    );
}

@ParameterizedTest
@MethodSource("argumentsProvider")
void testWithArguments(String name, int age, boolean active) {
    // Test code
}

static Stream<Arguments> argumentsProvider() {
    return Stream.of(
        Arguments.of("Alice", 30, true),
        Arguments.of("Bob", 25, false)
    );
}
```

### Enum Source

```java
@ParameterizedTest
@EnumSource(Role.class)
void testWithEnums(Role role) {
    assertNotNull(role);
}

@ParameterizedTest
@EnumSource(value = Role.class, names = {"ADMIN", "USER"})
void testSpecificRoles(Role role) {
    assertTrue(role == Role.ADMIN || role == Role.USER);
}
```

## Spring Boot Testing

### Unit Tests with Spring

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository repository;

    @InjectMocks
    private UserService service;

    @Test
    void createUser_withValidData_createsAndReturnsUser() {
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
        verify(repository).save(any(User.class));
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
    void createUser_withValidData_returnsCreated() throws Exception {
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\":\"John\",\"email\":\"john@example.com\"}"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.name").value("John"))
            .andExpect(jsonPath("$.email").value("john@example.com"));
    }

    @Test
    void getUser_withExistingId_returnsUser() throws Exception {
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

### Test Configuration

```java
@TestConfiguration
public class TestConfig {

    @Bean
    @Primary
    public EmailService emailService() {
        return new MockEmailService();
    }

    @Bean
    public Clock clock() {
        return Clock.fixed(Instant.parse("2024-01-01T00:00:00Z"), ZoneOffset.UTC);
    }
}
```

### Test Slices

```java
// Test only web layer
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Test
    void getUser_returnsUser() throws Exception {
        when(userService.findById(1L)).thenReturn(Optional.of(testUser));

        mockMvc.perform(get("/api/users/1"))
            .andExpect(status().isOk());
    }
}

// Test only JPA layer
@DataJpaTest
class UserRepositoryTest {

    @Autowired
    private UserRepository repository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    void findByEmail_withExistingEmail_returnsUser() {
        User user = entityManager.persist(new User("john@example.com", "John"));

        Optional<User> found = repository.findByEmail("john@example.com");

        assertThat(found).isPresent();
        assertThat(found.get().getName()).isEqualTo("John");
    }
}
```

### Test Database

```java
// Use H2 in-memory database
@SpringBootTest
@AutoConfigureTestDatabase(replace = Replace.ANY)
class UserServiceIntegrationTest {
    // Tests use H2 instead of production database
}

// Use Testcontainers for real database
@SpringBootTest
@Testcontainers
class UserServiceIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
        .withDatabaseName("testdb");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Test
    void testWithRealPostgres() {
        // Test runs against real PostgreSQL
    }
}
```

## Best Practices

### Test Naming

```java
// Pattern: methodName_condition_expectedBehavior
@Test
void createUser_withValidData_returnsUser() {}

@Test
void createUser_withDuplicateEmail_throwsException() {}

@Test
void findById_withNonExistentId_returnsEmpty() {}
```

### AAA Pattern

```java
@Test
void createUser_withValidData_savesAndSendsEmail() {
    // Arrange - Set up test data and mocks
    CreateUserRequest request = new CreateUserRequest("john@example.com", "John");
    when(repository.save(any())).thenReturn(savedUser);

    // Act - Execute the method being tested
    User result = service.createUser(request);

    // Assert - Verify the outcome
    assertThat(result).isNotNull();
    verify(emailService).sendWelcomeEmail(result);
}
```

### Test Data Builders

```java
class UserTestBuilder {
    private String name = "Test User";
    private String email = "test@example.com";
    private boolean active = true;

    public UserTestBuilder withName(String name) {
        this.name = name;
        return this;
    }

    public UserTestBuilder withEmail(String email) {
        this.email = email;
        return this;
    }

    public UserTestBuilder inactive() {
        this.active = false;
        return this;
    }

    public User build() {
        return User.builder()
            .name(name)
            .email(email)
            .active(active)
            .build();
    }
}

// Usage
@Test
void test() {
    User user = new UserTestBuilder()
        .withName("John")
        .inactive()
        .build();
}
```

### What to Test

**Do test:**
- Public API methods
- Business logic
- Edge cases and error handling
- Different input combinations

**Don't test:**
- Private methods (test via public interface)
- Simple getters/setters
- Framework code
- Third-party libraries

## See Also

- Main SKILL.md - Quick reference
- `spring-patterns.md` - Testing Spring components
- `streams.md` - Testing stream-based code
