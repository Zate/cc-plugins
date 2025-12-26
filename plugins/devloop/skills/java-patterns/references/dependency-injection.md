# Dependency Injection Patterns

Deep dive into dependency injection patterns, lifecycle management, and advanced DI concepts in Java and Spring.

## Core DI Concepts

### What is Dependency Injection?

Dependency Injection is a design pattern where objects receive their dependencies from external sources rather than creating them internally.

**Without DI (tight coupling):**
```java
public class UserService {
    private UserRepository repository = new UserRepositoryImpl(); // Hard-coded dependency
    private EmailService emailService = new SmtpEmailService(); // Hard-coded dependency

    public void createUser(User user) {
        repository.save(user);
        emailService.sendWelcomeEmail(user);
    }
}
```

**With DI (loose coupling):**
```java
public class UserService {
    private final UserRepository repository;
    private final EmailService emailService;

    public UserService(UserRepository repository, EmailService emailService) {
        this.repository = repository;
        this.emailService = emailService;
    }

    public void createUser(User user) {
        repository.save(user);
        emailService.sendWelcomeEmail(user);
    }
}
```

### Benefits of DI

1. **Testability** - Easy to inject mocks/stubs for testing
2. **Flexibility** - Swap implementations without changing code
3. **Maintainability** - Clear dependencies, easier to understand
4. **Decoupling** - Classes don't depend on concrete implementations
5. **Reusability** - Components can be reused in different contexts

## Constructor Injection (Recommended)

### Basic Constructor Injection

```java
@Service
public class UserService {
    private final UserRepository repository;
    private final EmailService emailService;

    // Constructor injection
    public UserService(UserRepository repository, EmailService emailService) {
        this.repository = repository;
        this.emailService = emailService;
    }
}
```

### With Lombok

```java
@Service
@RequiredArgsConstructor // Generates constructor for final fields
public class UserService {
    private final UserRepository repository;
    private final EmailService emailService;
    // Constructor automatically generated
}
```

### Multiple Constructors

```java
@Service
public class UserService {
    private final UserRepository repository;
    private final EmailService emailService;
    private final AuditService auditService;

    // Primary constructor (Spring will use this)
    @Autowired
    public UserService(
        UserRepository repository,
        EmailService emailService,
        AuditService auditService
    ) {
        this.repository = repository;
        this.emailService = emailService;
        this.auditService = auditService;
    }

    // Convenience constructor for testing
    public UserService(UserRepository repository, EmailService emailService) {
        this(repository, emailService, new NoOpAuditService());
    }
}
```

### Why Constructor Injection?

**Advantages:**
- Dependencies are immutable (final fields)
- Dependencies are required (can't create object without them)
- Easy to test (no reflection needed)
- Fails fast if dependencies are missing
- Thread-safe

**When to use:**
- Always, for required dependencies
- Default choice for all services

## Field Injection (Avoid)

### How it Works

```java
@Service
public class UserService {
    @Autowired
    private UserRepository repository; // Injected via reflection

    @Autowired
    private EmailService emailService; // Injected via reflection
}
```

### Why Avoid Field Injection?

**Problems:**
1. **Cannot make fields final** - Mutability issues
2. **Dependencies are hidden** - Not visible in constructor
3. **Harder to test** - Requires reflection or Spring context
4. **Circular dependencies** - Easier to create by accident
5. **Framework coupling** - Tied to Spring annotations

**Acceptable use case:**
- Test classes with `@MockBean` or `@Autowired` test fixtures

## Setter Injection (Optional Dependencies)

### When to Use

Use setter injection only for **optional** dependencies:

```java
@Service
public class UserService {
    private final UserRepository repository; // Required
    private EmailService emailService; // Optional

    public UserService(UserRepository repository) {
        this.repository = repository;
    }

    @Autowired(required = false)
    public void setEmailService(EmailService emailService) {
        this.emailService = emailService;
    }

    public void createUser(User user) {
        repository.save(user);

        if (emailService != null) {
            emailService.sendWelcomeEmail(user);
        }
    }
}
```

### With Default Values

```java
@Service
public class NotificationService {
    private EmailService emailService = new NoOpEmailService(); // Default

    @Autowired(required = false)
    public void setEmailService(EmailService emailService) {
        this.emailService = emailService;
    }
}
```

## Lifecycle Management

### Bean Scopes

```java
// Singleton (default) - One instance per container
@Service
@Scope("singleton")
public class UserService {
}

// Prototype - New instance each time
@Service
@Scope("prototype")
public class RequestProcessor {
}

// Request - One instance per HTTP request
@Component
@Scope(value = WebApplicationContext.SCOPE_REQUEST, proxyMode = ScopedProxyMode.TARGET_CLASS)
public class RequestContext {
}

// Session - One instance per HTTP session
@Component
@Scope(value = WebApplicationContext.SCOPE_SESSION, proxyMode = ScopedProxyMode.TARGET_CLASS)
public class UserSession {
}
```

### Initialization Callbacks

```java
@Service
public class CacheService {

    private Cache cache;

    // Option 1: @PostConstruct
    @PostConstruct
    public void initialize() {
        cache = loadCache();
        System.out.println("Cache initialized");
    }

    // Option 2: InitializingBean interface
    @Override
    public void afterPropertiesSet() {
        cache = loadCache();
    }

    // Option 3: Custom init method
    @Bean(initMethod = "initialize")
    public CacheService cacheService() {
        return new CacheService();
    }
}
```

### Destruction Callbacks

```java
@Service
public class DatabaseConnection {

    private Connection connection;

    @PostConstruct
    public void connect() {
        connection = createConnection();
    }

    // Option 1: @PreDestroy
    @PreDestroy
    public void cleanup() {
        if (connection != null) {
            connection.close();
        }
        System.out.println("Connection closed");
    }

    // Option 2: DisposableBean interface
    @Override
    public void destroy() {
        cleanup();
    }

    // Option 3: Custom destroy method
    @Bean(destroyMethod = "cleanup")
    public DatabaseConnection databaseConnection() {
        return new DatabaseConnection();
    }
}
```

## Qualifiers

### Resolving Multiple Implementations

```java
// Multiple implementations
@Service
@Qualifier("smtp")
public class SmtpEmailService implements EmailService {
}

@Service
@Qualifier("sendgrid")
public class SendGridEmailService implements EmailService {
}

// Inject specific implementation
@Service
@RequiredArgsConstructor
public class UserService {
    @Qualifier("smtp")
    private final EmailService emailService;
}

// Or with constructor
@Service
public class UserService {
    private final EmailService emailService;

    public UserService(@Qualifier("smtp") EmailService emailService) {
        this.emailService = emailService;
    }
}
```

### Primary Bean

```java
@Service
@Primary // This will be injected if no qualifier specified
public class SmtpEmailService implements EmailService {
}

@Service
public class SendGridEmailService implements EmailService {
}

@Service
public class UserService {
    private final EmailService emailService; // SmtpEmailService injected
}
```

### Custom Qualifiers

```java
@Target({ElementType.FIELD, ElementType.METHOD, ElementType.PARAMETER, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Qualifier
public @interface Production {
}

@Service
@Production
public class ProductionEmailService implements EmailService {
}

@Service
public class UserService {
    private final EmailService emailService;

    public UserService(@Production EmailService emailService) {
        this.emailService = emailService;
    }
}
```

## Conditional Injection

### Based on Properties

```java
@Service
@ConditionalOnProperty(name = "email.enabled", havingValue = "true")
public class SmtpEmailService implements EmailService {
}

@Service
@ConditionalOnProperty(name = "email.enabled", havingValue = "false", matchIfMissing = true)
public class MockEmailService implements EmailService {
}
```

### Based on Class Presence

```java
@Configuration
@ConditionalOnClass(RedisTemplate.class)
public class RedisCacheConfig {

    @Bean
    public CacheManager redisCacheManager() {
        return new RedisCacheManager();
    }
}
```

### Based on Missing Bean

```java
@Configuration
public class CacheConfig {

    @Bean
    @ConditionalOnMissingBean(CacheManager.class)
    public CacheManager defaultCacheManager() {
        return new InMemoryCacheManager();
    }
}
```

### Profile-Based

```java
@Service
@Profile("production")
public class ProductionEmailService implements EmailService {
}

@Service
@Profile("development")
public class MockEmailService implements EmailService {
}

@Service
@Profile("test")
public class InMemoryEmailService implements EmailService {
}
```

## Circular Dependencies

### Problem

```java
@Service
public class ServiceA {
    private final ServiceB serviceB;

    public ServiceA(ServiceB serviceB) {
        this.serviceB = serviceB;
    }
}

@Service
public class ServiceB {
    private final ServiceA serviceA;

    public ServiceB(ServiceA serviceA) { // Circular dependency!
        this.serviceA = serviceA;
    }
}
```

### Solution 1: Setter Injection

```java
@Service
public class ServiceA {
    private final ServiceB serviceB;

    public ServiceA(ServiceB serviceB) {
        this.serviceB = serviceB;
    }
}

@Service
public class ServiceB {
    private ServiceA serviceA;

    @Autowired
    public void setServiceA(ServiceA serviceA) {
        this.serviceA = serviceA;
    }
}
```

### Solution 2: Lazy Injection

```java
@Service
public class ServiceA {
    private final ServiceB serviceB;

    public ServiceA(@Lazy ServiceB serviceB) {
        this.serviceB = serviceB;
    }
}

@Service
public class ServiceB {
    private final ServiceA serviceA;

    public ServiceB(ServiceA serviceA) {
        this.serviceA = serviceA;
    }
}
```

### Solution 3: Refactor Design

```java
// Extract common logic to new service
@Service
public class SharedService {
    public void doSharedWork() {
        // Common logic
    }
}

@Service
@RequiredArgsConstructor
public class ServiceA {
    private final SharedService sharedService;
}

@Service
@RequiredArgsConstructor
public class ServiceB {
    private final SharedService sharedService;
}
```

## Advanced Patterns

### Factory Pattern with DI

```java
public interface NotificationService {
    void send(String message);
}

@Component
public class NotificationServiceFactory {

    private final Map<String, NotificationService> services;

    // Spring injects all implementations
    public NotificationServiceFactory(List<NotificationService> services) {
        this.services = services.stream()
            .collect(Collectors.toMap(
                service -> service.getClass().getSimpleName(),
                service -> service
            ));
    }

    public NotificationService getService(String type) {
        return services.get(type);
    }
}
```

### Strategy Pattern with DI

```java
public interface PaymentStrategy {
    void processPayment(Order order);
    String getType();
}

@Service
public class CreditCardPayment implements PaymentStrategy {
    @Override
    public String getType() { return "CREDIT_CARD"; }
}

@Service
public class PayPalPayment implements PaymentStrategy {
    @Override
    public String getType() { return "PAYPAL"; }
}

@Service
public class PaymentProcessor {

    private final Map<String, PaymentStrategy> strategies;

    public PaymentProcessor(List<PaymentStrategy> strategyList) {
        this.strategies = strategyList.stream()
            .collect(Collectors.toMap(
                PaymentStrategy::getType,
                strategy -> strategy
            ));
    }

    public void process(Order order) {
        PaymentStrategy strategy = strategies.get(order.getPaymentType());
        strategy.processPayment(order);
    }
}
```

### Template Method with DI

```java
public abstract class BaseService<T> {

    protected final Repository<T> repository;
    protected final Validator validator;

    protected BaseService(Repository<T> repository, Validator validator) {
        this.repository = repository;
        this.validator = validator;
    }

    public T save(T entity) {
        beforeSave(entity);
        validator.validate(entity);
        T saved = repository.save(entity);
        afterSave(saved);
        return saved;
    }

    protected void beforeSave(T entity) {
        // Hook for subclasses
    }

    protected void afterSave(T entity) {
        // Hook for subclasses
    }
}

@Service
public class UserService extends BaseService<User> {

    private final EmailService emailService;

    public UserService(
        UserRepository repository,
        Validator validator,
        EmailService emailService
    ) {
        super(repository, validator);
        this.emailService = emailService;
    }

    @Override
    protected void afterSave(User user) {
        emailService.sendWelcomeEmail(user);
    }
}
```

## Best Practices

### Do's

1. **Prefer constructor injection** for required dependencies
2. **Use final fields** to ensure immutability
3. **Keep constructors simple** - just assign fields
4. **Inject interfaces** not implementations
5. **Use `@RequiredArgsConstructor`** to reduce boilerplate
6. **Make dependencies explicit** in the constructor
7. **Use qualifiers** when multiple implementations exist

### Don'ts

1. **Avoid field injection** except in tests
2. **Don't create circular dependencies**
3. **Don't inject too many dependencies** (>5 is a code smell)
4. **Don't mix DI styles** in the same class
5. **Don't do work in constructors** - use `@PostConstruct`
6. **Don't make beans prototype** unless necessary
7. **Don't inject prototype beans into singletons** without proxies

### Code Smells

**Too many dependencies:**
```java
// Bad: God class with too many dependencies
public class UserService {
    public UserService(
        UserRepository repo,
        EmailService email,
        SmsService sms,
        NotificationService notification,
        AuditService audit,
        LoggingService logging,
        CacheService cache,
        ValidationService validation
    ) {
        // Too many! This class does too much
    }
}
```

**Solution:** Break into smaller, focused services.

## See Also

- `spring-patterns.md` - Spring-specific DI patterns
- `testing-junit.md` - Testing with mocked dependencies
- Main SKILL.md - Quick reference
