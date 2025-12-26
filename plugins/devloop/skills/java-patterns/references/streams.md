# Stream API Patterns

Comprehensive guide to Java Stream API for functional-style collection processing.

## Stream Basics

### Creating Streams

```java
// From collections
List<String> list = Arrays.asList("a", "b", "c");
Stream<String> stream = list.stream();

// From arrays
String[] array = {"a", "b", "c"};
Stream<String> stream = Arrays.stream(array);

// From values
Stream<String> stream = Stream.of("a", "b", "c");

// Empty stream
Stream<String> empty = Stream.empty();

// Infinite streams
Stream<Integer> infinite = Stream.iterate(0, n -> n + 1);
Stream<Double> random = Stream.generate(Math::random);

// Parallel streams
Stream<String> parallel = list.parallelStream();
```

## Common Operations

### Filter and Transform

```java
// Filter and transform
List<String> names = users.stream()
    .filter(user -> user.isActive())
    .map(User::getName)
    .collect(Collectors.toList());

// Filter with method reference
List<User> activeUsers = users.stream()
    .filter(User::isActive)
    .collect(Collectors.toList());

// Multiple transformations
List<String> upperNames = users.stream()
    .map(User::getName)
    .map(String::toUpperCase)
    .collect(Collectors.toList());

// FlatMap for nested collections
List<String> allTags = posts.stream()
    .flatMap(post -> post.getTags().stream())
    .distinct()
    .collect(Collectors.toList());
```

### Searching and Matching

```java
// Find first matching
Optional<User> admin = users.stream()
    .filter(user -> user.getRole() == Role.ADMIN)
    .findFirst();

// Find any (for parallel streams)
Optional<User> anyAdmin = users.parallelStream()
    .filter(user -> user.getRole() == Role.ADMIN)
    .findAny();

// Check if any match
boolean hasAdmin = users.stream()
    .anyMatch(user -> user.getRole() == Role.ADMIN);

// Check if all match
boolean allActive = users.stream()
    .allMatch(User::isActive);

// Check if none match
boolean noGuests = users.stream()
    .noneMatch(user -> user.getRole() == Role.GUEST);
```

### Sorting

```java
// Sort by single field
List<User> sorted = users.stream()
    .sorted(Comparator.comparing(User::getName))
    .collect(Collectors.toList());

// Sort descending
List<User> descending = users.stream()
    .sorted(Comparator.comparing(User::getCreatedAt).reversed())
    .collect(Collectors.toList());

// Sort by multiple fields
List<User> multiSort = users.stream()
    .sorted(Comparator
        .comparing(User::getRole)
        .thenComparing(User::getName))
    .collect(Collectors.toList());

// Custom comparator
List<User> custom = users.stream()
    .sorted((u1, u2) -> u1.getAge() - u2.getAge())
    .collect(Collectors.toList());
```

### Limiting and Skipping

```java
// Take first N elements
List<User> firstTen = users.stream()
    .limit(10)
    .collect(Collectors.toList());

// Skip first N elements
List<User> afterTen = users.stream()
    .skip(10)
    .collect(Collectors.toList());

// Pagination
List<User> page = users.stream()
    .skip(pageNumber * pageSize)
    .limit(pageSize)
    .collect(Collectors.toList());
```

### Distinct and Peek

```java
// Remove duplicates
List<String> uniqueNames = users.stream()
    .map(User::getName)
    .distinct()
    .collect(Collectors.toList());

// Peek for debugging (side-effect)
List<String> names = users.stream()
    .peek(user -> System.out.println("Processing: " + user))
    .map(User::getName)
    .peek(name -> System.out.println("Name: " + name))
    .collect(Collectors.toList());
```

## Collectors

### Basic Collectors

```java
// To List
List<User> list = users.stream()
    .collect(Collectors.toList());

// To Set
Set<User> set = users.stream()
    .collect(Collectors.toSet());

// To Map
Map<Long, User> map = users.stream()
    .collect(Collectors.toMap(User::getId, user -> user));

// To Map with duplicate handling
Map<String, User> byEmail = users.stream()
    .collect(Collectors.toMap(
        User::getEmail,
        user -> user,
        (existing, replacement) -> existing // Keep existing on duplicate
    ));
```

### Grouping

```java
// Group by single field
Map<Role, List<User>> byRole = users.stream()
    .collect(Collectors.groupingBy(User::getRole));

// Group and count
Map<Role, Long> countByRole = users.stream()
    .collect(Collectors.groupingBy(
        User::getRole,
        Collectors.counting()
    ));

// Group and collect specific field
Map<Role, List<String>> namesByRole = users.stream()
    .collect(Collectors.groupingBy(
        User::getRole,
        Collectors.mapping(User::getName, Collectors.toList())
    ));

// Multi-level grouping
Map<Role, Map<Boolean, List<User>>> byRoleAndActive = users.stream()
    .collect(Collectors.groupingBy(
        User::getRole,
        Collectors.groupingBy(User::isActive)
    ));
```

### Partitioning

```java
// Partition by boolean predicate
Map<Boolean, List<User>> activePartition = users.stream()
    .collect(Collectors.partitioningBy(User::isActive));

List<User> active = activePartition.get(true);
List<User> inactive = activePartition.get(false);
```

### Joining

```java
// Join strings
String names = users.stream()
    .map(User::getName)
    .collect(Collectors.joining(", "));

// Join with prefix/suffix
String html = users.stream()
    .map(User::getName)
    .collect(Collectors.joining(", ", "<ul><li>", "</li></ul>"));
```

### Summarizing

```java
// Summarize int values
IntSummaryStatistics stats = users.stream()
    .collect(Collectors.summarizingInt(User::getAge));

System.out.println("Count: " + stats.getCount());
System.out.println("Sum: " + stats.getSum());
System.out.println("Min: " + stats.getMin());
System.out.println("Max: " + stats.getMax());
System.out.println("Average: " + stats.getAverage());

// Summarize double values
DoubleSummaryStatistics priceStats = orders.stream()
    .collect(Collectors.summarizingDouble(Order::getTotal));
```

## Reduce Operations

### Basic Reduce

```java
// Sum with reduce
int totalAge = users.stream()
    .map(User::getAge)
    .reduce(0, Integer::sum);

// Product
int product = numbers.stream()
    .reduce(1, (a, b) -> a * b);

// Max value
Optional<Integer> max = numbers.stream()
    .reduce(Integer::max);

// Concatenate strings
String concatenated = words.stream()
    .reduce("", (a, b) -> a + " " + b);
```

### Specialized Reduce

```java
// Sum with mapToInt
int totalAge = users.stream()
    .mapToInt(User::getAge)
    .sum();

// Average
double averageAge = users.stream()
    .mapToInt(User::getAge)
    .average()
    .orElse(0.0);

// Max
int maxAge = users.stream()
    .mapToInt(User::getAge)
    .max()
    .orElse(0);

// Min
int minAge = users.stream()
    .mapToInt(User::getAge)
    .min()
    .orElse(0);
```

## Best Practices

### Readable Chains

```java
// Good: Readable chain with clear steps
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

### Parallel Streams

```java
// Use parallel for CPU-intensive operations on large datasets
List<Result> results = items.parallelStream()
    .map(this::expensiveOperation)
    .collect(Collectors.toList());

// Don't use parallel for:
// - Small datasets (overhead > benefit)
// - I/O operations (thread blocking)
// - Operations that modify shared state
```

### Avoiding Common Mistakes

```java
// Bad: Reusing stream (IllegalStateException)
Stream<User> stream = users.stream();
long count = stream.count();
List<User> list = stream.collect(Collectors.toList()); // ERROR

// Good: Create new stream
long count = users.stream().count();
List<User> list = users.stream().collect(Collectors.toList());

// Bad: Modifying source during stream
users.stream()
    .forEach(user -> users.remove(user)); // ConcurrentModificationException

// Good: Collect then modify
List<User> toRemove = users.stream()
    .filter(someCondition)
    .collect(Collectors.toList());
users.removeAll(toRemove);
```

### Performance Tips

```java
// Use primitive streams when possible
int sum = numbers.stream()
    .mapToInt(Integer::intValue) // Avoid boxing
    .sum();

// Short-circuit operations early
Optional<User> found = users.stream()
    .filter(expensiveCheck) // Put expensive operations last
    .findFirst(); // Stops at first match

// Avoid unnecessary boxing
// Bad
int sum = users.stream()
    .map(User::getAge) // Returns Stream<Integer>
    .reduce(0, Integer::sum);

// Good
int sum = users.stream()
    .mapToInt(User::getAge) // Returns IntStream
    .sum();
```

## Advanced Patterns

### Custom Collectors

```java
// Create custom collector
Collector<User, ?, Map<Role, Set<String>>> customCollector =
    Collector.of(
        HashMap::new,
        (map, user) -> {
            map.computeIfAbsent(user.getRole(), k -> new HashSet<>())
               .add(user.getName());
        },
        (map1, map2) -> {
            map2.forEach((role, names) ->
                map1.merge(role, names, (s1, s2) -> {
                    s1.addAll(s2);
                    return s1;
                }));
            return map1;
        }
    );
```

### Teeing (Java 12+)

```java
// Process stream with two collectors simultaneously
record Stats(long count, double average) {}

Stats stats = numbers.stream()
    .collect(Collectors.teeing(
        Collectors.counting(),
        Collectors.averagingInt(Integer::intValue),
        Stats::new
    ));
```

## See Also

- Main SKILL.md - Quick reference
- `testing-junit.md` - Testing stream-based code
- `dependency-injection.md` - Using streams in services
