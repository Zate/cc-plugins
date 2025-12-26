# Spring Patterns

Comprehensive Spring Boot patterns for dependency injection, configuration, and component management.

## Spring Dependency Injection

### Constructor Injection (Preferred)

Constructor injection is the recommended approach for required dependencies:

```java
@Service
@RequiredArgsConstructor // Lombok generates constructor
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;

    // Business methods...
    public User createUser(CreateUserRequest request) {
        User user = User.builder()
            .email(request.getEmail())
            .name(request.getName())
            .password(passwordEncoder.encode(request.getPassword()))
            .build();

        User saved = userRepository.save(user);
        emailService.sendWelcomeEmail(saved);
        return saved;
    }
}
```

**Why constructor injection?**
- Makes dependencies explicit and required
- Enables immutability (final fields)
- Easier to test (no reflection needed)
- Fails fast if dependencies missing

### Field Injection (Avoid)

```java
// Bad: Field injection
@Service
public class UserService {
    @Autowired
    private UserRepository userRepository; // Don't do this

    @Autowired
    private EmailService emailService; // Don't do this
}
```

**Problems with field injection:**
- Dependencies are hidden
- Cannot create immutable objects
- Harder to test (requires reflection)
- No compile-time safety

### Setter Injection (Optional Dependencies Only)

```java
@Service
public class UserService {
    private final UserRepository repository;
    private EmailService emailService; // Optional

    public UserService(UserRepository repository) {
        this.repository = repository;
    }

    @Autowired(required = false)
    public void setEmailService(EmailService emailService) {
        this.emailService = emailService;
    }
}
```

Use setter injection only for truly optional dependencies.

## Configuration Classes

### Basic Configuration

```java
@Configuration
public class AppConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public Clock clock() {
        return Clock.systemUTC();
    }
}
```

### Profile-Specific Beans

```java
@Configuration
public class AppConfig {

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

    @Bean
    @Profile("test")
    public EmailService testEmailService() {
        return new InMemoryEmailService();
    }
}
```

### Conditional Beans

```java
@Configuration
public class CacheConfig {

    @Bean
    @ConditionalOnProperty(name = "cache.enabled", havingValue = "true")
    public CacheManager cacheManager() {
        return new ConcurrentMapCacheManager("users", "products");
    }

    @Bean
    @ConditionalOnMissingBean(CacheManager.class)
    public CacheManager noCacheManager() {
        return new NoOpCacheManager();
    }
}
```

### External Configuration

```java
@Configuration
@ConfigurationProperties(prefix = "app")
public class AppProperties {
    private String name;
    private int maxConnections;
    private Duration timeout;

    // Getters and setters
}

// Usage in another component
@Service
@RequiredArgsConstructor
public class MyService {
    private final AppProperties properties;
}
```

## Component Scanning

### Explicit Component Scan

```java
@Configuration
@ComponentScan(basePackages = {
    "com.example.services",
    "com.example.repositories"
})
public class AppConfig {
}
```

### Exclude Patterns

```java
@SpringBootApplication(exclude = {
    DataSourceAutoConfiguration.class,
    SecurityAutoConfiguration.class
})
public class Application {
}
```

## Bean Lifecycle

### Initialization and Destruction

```java
@Component
public class DatabaseConnection {

    private Connection connection;

    @PostConstruct
    public void initialize() {
        connection = createConnection();
        System.out.println("Connection established");
    }

    @PreDestroy
    public void cleanup() {
        if (connection != null) {
            connection.close();
        }
        System.out.println("Connection closed");
    }
}
```

### InitializingBean and DisposableBean

```java
@Component
public class CacheWarmer implements InitializingBean, DisposableBean {

    @Override
    public void afterPropertiesSet() {
        // Warm up cache after all properties set
        warmCache();
    }

    @Override
    public void destroy() {
        // Clear cache on shutdown
        clearCache();
    }
}
```

## Scope Management

### Bean Scopes

```java
@Service
@Scope("singleton") // Default - one instance per container
public class SingletonService {
}

@Service
@Scope("prototype") // New instance each time
public class PrototypeService {
}

@Component
@Scope(value = WebApplicationContext.SCOPE_REQUEST, proxyMode = ScopedProxyMode.TARGET_CLASS)
public class RequestScopedBean {
}

@Component
@Scope(value = WebApplicationContext.SCOPE_SESSION, proxyMode = ScopedProxyMode.TARGET_CLASS)
public class SessionScopedBean {
}
```

## Aspect-Oriented Programming (AOP)

### Basic Aspect

```java
@Aspect
@Component
public class LoggingAspect {

    @Before("execution(* com.example.services.*.*(..))")
    public void logBefore(JoinPoint joinPoint) {
        System.out.println("Executing: " + joinPoint.getSignature());
    }

    @AfterReturning(
        pointcut = "execution(* com.example.services.*.*(..))",
        returning = "result"
    )
    public void logAfterReturning(JoinPoint joinPoint, Object result) {
        System.out.println("Method returned: " + result);
    }

    @Around("@annotation(com.example.annotations.Timed)")
    public Object measureTime(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();
        Object result = joinPoint.proceed();
        long duration = System.currentTimeMillis() - start;
        System.out.println(joinPoint.getSignature() + " took " + duration + "ms");
        return result;
    }
}
```

### Custom Annotations with AOP

```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Timed {
}

@Aspect
@Component
public class TimingAspect {

    @Around("@annotation(Timed)")
    public Object time(ProceedingJoinPoint joinPoint) throws Throwable {
        StopWatch stopWatch = new StopWatch();
        stopWatch.start();
        Object result = joinPoint.proceed();
        stopWatch.stop();
        System.out.println(joinPoint.getSignature() + " took " + stopWatch.getTotalTimeMillis() + "ms");
        return result;
    }
}
```

## Event-Driven Programming

### Publishing Events

```java
@Service
@RequiredArgsConstructor
public class UserService {
    private final ApplicationEventPublisher eventPublisher;

    public User createUser(CreateUserRequest request) {
        User user = // ... create user
        eventPublisher.publishEvent(new UserCreatedEvent(user));
        return user;
    }
}

public class UserCreatedEvent {
    private final User user;

    public UserCreatedEvent(User user) {
        this.user = user;
    }

    public User getUser() {
        return user;
    }
}
```

### Listening to Events

```java
@Component
public class UserEventListener {

    @EventListener
    public void handleUserCreated(UserCreatedEvent event) {
        System.out.println("User created: " + event.getUser().getEmail());
    }

    @EventListener
    @Async
    public void sendWelcomeEmail(UserCreatedEvent event) {
        // Send email asynchronously
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void afterCommit(UserCreatedEvent event) {
        // Only execute after transaction commits
    }
}
```

## Best Practices

### Do's
- Use constructor injection for required dependencies
- Make beans immutable where possible
- Use `@Profile` for environment-specific configuration
- Leverage Spring Boot auto-configuration
- Use events for cross-cutting concerns
- Keep configuration classes focused

### Don'ts
- Avoid field injection
- Don't create circular dependencies
- Don't abuse `@Autowired` - prefer explicit wiring
- Don't mix configuration styles (Java config + XML)
- Avoid prototype beans unless necessary
- Don't ignore bean lifecycle warnings

## See Also

- `dependency-injection.md` - DI patterns in depth
- `testing-junit.md` - Testing Spring components
- Main SKILL.md - Quick reference
