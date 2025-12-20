---
name: language-patterns-base
description: Base template for language-specific pattern skills. Defines common sections (error handling, testing, project structure, anti-patterns) that language skills extend with language-specific details.
---

# Language Patterns Base Template

This is a **base template** that language-specific pattern skills (go-patterns, python-patterns, java-patterns, react-patterns, etc.) should extend with concrete, language-specific examples.

## When NOT to Use This Skill

This base template itself should not be invoked directly. Instead:

- **DO** invoke language-specific skills (go-patterns, python-patterns, etc.) when working in those languages
- **DO NOT** invoke this skill - it's a template/reference for creating language skills
- **DO NOT** provide generic advice when language-specific guidance is available

Language skills should include their own "When NOT to Use" section covering:
- When the task is trivial (reading files, simple operations)
- When exploring unfamiliar codebases (use search/analysis first)
- When the user asks for different language/framework guidance
- When basic documentation lookup would suffice

## Universal Error Handling Principles

All languages should follow these core principles:

### 1. Fail Fast, Fail Clearly
- Validate inputs at boundaries (API endpoints, public functions)
- Provide actionable error messages with context
- Don't swallow errors silently - log or propagate them

### 2. Error Context
```
Bad:  "Invalid input"
Good: "Invalid email format for user registration: expected format 'user@domain.com', got 'invalid'"
```

### 3. Error Boundaries
- Handle errors at appropriate abstraction levels
- Don't catch exceptions you can't handle meaningfully
- Distinguish between recoverable and fatal errors

### 4. Error Types
Language skills should provide concrete examples of:
- **Validation errors**: User input problems (recoverable)
- **Infrastructure errors**: Network, DB, filesystem (may be transient)
- **Programming errors**: Null pointers, assertion failures (bugs)
- **Business logic errors**: Insufficient funds, duplicate email (recoverable)

## Universal Testing Patterns

### AAA Pattern (Arrange-Act-Assert)
```
# Arrange: Set up test data and conditions
user = create_test_user(email="test@example.com")

# Act: Execute the behavior being tested
result = register_user(user)

# Assert: Verify the outcome
assert result.success == True
assert result.user_id is not None
```

### Test Structure Principles

1. **One Concept Per Test**
   - Test a single behavior or requirement
   - Name tests clearly: `test_registration_rejects_duplicate_email`

2. **Independent Tests**
   - Tests should not depend on execution order
   - Clean up resources after each test
   - Use test fixtures/setup for common state

3. **Test Data Management**
   - Use factories/builders for complex objects
   - Keep test data minimal and relevant
   - Avoid hardcoded "magic" values - use constants

4. **Mocking Strategy**
   - Mock external dependencies (APIs, databases, filesystem)
   - Don't mock the system under test
   - Verify mock interactions when behavior matters

### Test Categories
Language skills should provide examples for:
- **Unit tests**: Single function/class in isolation
- **Integration tests**: Multiple components working together
- **End-to-end tests**: Full user workflows
- **Contract tests**: API/interface compliance

## Universal Project Structure Principles

### 1. Separation of Concerns
```
project/
├── domain/          # Business logic (pure, no dependencies)
├── infrastructure/  # External integrations (DB, API, filesystem)
├── interfaces/      # Entry points (HTTP, CLI, gRPC)
└── tests/           # Test code mirroring source structure
```

### 2. Dependency Direction
- **Core domain** should have no dependencies on infrastructure
- **Infrastructure** depends on domain interfaces
- **Interfaces** orchestrate domain and infrastructure

### 3. Configuration Management
- Separate configuration from code
- Use environment variables for deployment-specific settings
- Provide sensible defaults for development
- Never commit secrets

### 4. File Organization
Language skills should specify:
- Naming conventions (PascalCase, snake_case, kebab-case)
- File/module size guidelines
- Directory structure for different project sizes
- Where to place tests (co-located vs separate directory)

## Universal Anti-Patterns to Avoid

### 1. Ignoring Errors
```
Bad:
try:
    result = risky_operation()
except:
    pass  # Silent failure

Good:
try:
    result = risky_operation()
except SpecificError as e:
    logger.error(f"Failed to complete operation: {e}")
    raise
```

### 2. Poor Naming
```
Bad:  getData(), doStuff(), tmp, x, mgr
Good: fetchUserProfile(), validateEmail(), temporaryToken, userId, userManager
```

### 3. Magic Numbers and Strings
```
Bad:
if user.age > 18:  # What's special about 18?

Good:
MINIMUM_AGE_FOR_REGISTRATION = 18
if user.age > MINIMUM_AGE_FOR_REGISTRATION:
```

### 4. God Objects/Functions
- Single class/function doing too many things
- Violates Single Responsibility Principle
- Hard to test, understand, and modify

### 5. Premature Optimization
- Write clear code first, optimize when profiling shows bottlenecks
- "Premature optimization is the root of all evil" - Donald Knuth

### 6. Copy-Paste Programming
- Duplication hides the concept that should be abstracted
- Changes require updates in multiple places (error-prone)
- Extract common logic into reusable functions/classes

### 7. Tight Coupling
- Direct dependencies on concrete implementations
- Hard to test (can't mock dependencies)
- Hard to change (ripple effects)
- Use interfaces/protocols for loose coupling

## Universal Code Style Principles

### 1. Consistency
- Follow language-specific style guides (PEP 8, gofmt, Google Java Style)
- Use automated formatters to enforce style
- Consistency > personal preference

### 2. Readability
- Code is read far more often than written
- Optimize for clarity, not cleverness
- Use meaningful names that reveal intent

### 3. Comments
```
Bad:  # Increment i (states the obvious)
Good: # Retry with exponential backoff (explains why)
```

- Comment **why**, not **what**
- Code should be self-documenting when possible
- Use docstrings/documentation comments for public APIs

### 4. Formatting
- Consistent indentation (spaces vs tabs per language convention)
- Reasonable line length (80-120 characters)
- Whitespace to group related logic
- Vertical spacing to separate concerns

## How to Extend This Base Template

When creating a language-specific pattern skill:

### 1. Copy This Structure
Start with these sections and add language-specific details:
- When NOT to Use (customize for your language)
- Quick Reference (language-specific patterns)
- Error Handling (concrete code examples in your language)
- Testing Patterns (actual test framework syntax)
- Project Structure (language-specific conventions)
- Anti-Patterns (language-specific gotchas)

### 2. Add Language-Specific Sections
Examples from existing skills:
- **Go**: Interfaces, Goroutines & Channels, Resource Management
- **Python**: Type Hints, Async Patterns, Decorators
- **Java**: Dependency Injection, Streams, Optional Handling
- **React**: Hooks, Component Design, State Management

### 3. Provide Concrete Examples
Replace generic principles with actual code in your language:
```
Base Template:       "Validate inputs at boundaries"
Go Skill:            func CreateUser(email string) error { if !isValidEmail(email) { return fmt.Errorf("invalid email: %s", email) } }
Python Skill:        def create_user(email: str) -> User: if not is_valid_email(email): raise ValueError(f"Invalid email: {email}")
```

### 4. Link to Authoritative Resources
- Official language documentation
- Community style guides
- Popular framework docs
- Testing framework documentation

## See Also

Language-specific pattern skills in this plugin:
- **devloop:go-patterns** - Go-specific best practices
- **devloop:python-patterns** - Python-specific best practices
- **devloop:java-patterns** - Java and Spring best practices
- **devloop:react-patterns** - React and TypeScript best practices

Architecture and design skills:
- **devloop:architecture-patterns** - High-level design patterns
- **devloop:api-design** - RESTful and GraphQL API design
- **devloop:database-patterns** - Database design and optimization
