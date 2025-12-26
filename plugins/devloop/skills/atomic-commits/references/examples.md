# Atomic Commit Examples

## Example 1: Feature with Tests (Group)

```
Task 3.1: Implement user profile endpoint
Task 3.2: Add tests for user profile endpoint

Decision: GROUP
Reason: Tests validate the feature, reviewer sees both together

Commit:
feat(users): add user profile endpoint - Tasks 3.1, 3.2

- Task 3.1: GET /api/users/:id endpoint with profile data
- Task 3.2: Unit and integration tests for profile endpoint
```

## Example 2: Backend + Frontend (Separate)

```
Task 4.1: Add avatar upload API
Task 4.2: Add avatar upload UI component

Decision: SEPARATE
Reason: Different concerns, different reviewers might look at each

Commits:
1. feat(api): add avatar upload endpoint - Task 4.1
2. feat(ui): add avatar upload component - Task 4.2
```

## Example 3: Multiple Small Fixes (Group)

```
Task 5.1: Fix typo in error message (5 lines)
Task 5.2: Fix off-by-one in pagination (12 lines)
Task 5.3: Fix null check in user lookup (8 lines)

Decision: GROUP
Reason: All small, all fixes, combined is trivially reviewable

Commit:
fix(core): address minor bugs - Tasks 5.1, 5.2, 5.3

- Task 5.1: Fixed typo in validation error message
- Task 5.2: Fixed off-by-one error in pagination offset
- Task 5.3: Added null check before user lookup
```

## Example 4: Refactoring (Separate)

```
Task 6.1: Extract auth middleware to separate file
Task 6.2: Add rate limiting to auth endpoints

Decision: SEPARATE
Reason: Refactoring should be isolated from feature changes

Commits:
1. refactor(auth): extract middleware to dedicated file - Task 6.1
2. feat(auth): add rate limiting to endpoints - Task 6.2
```

---

## Anti-Patterns to Avoid

### 1. "Friday Afternoon Commit"
```
feat: implement everything

Added user auth, profile pages, admin panel, fixed some bugs,
refactored database layer, and updated dependencies.

Changes across 47 files, +2847 -892 lines
```

### 2. "Work In Progress Commit"
```
wip: stuff

Various changes, will clean up later.
```

### 3. "Mixed Concerns Commit"
```
feat(auth): add login and fix unrelated CSS bug

Added login functionality.
Also fixed that CSS bug from last week.
```

### 4. "Partial Feature Commit"
```
feat(users): add user service (part 1 of 3)

This commit adds half the user service.
Next commit will add the other half.
[Leaves code in broken state]
```

---

## Commit Message Format with Task References

### Single Task Commit
```
<type>(<scope>): <description> - Task X.Y

<body explaining what and why>

Refs: #issue (if applicable)
```

**Example:**
```
feat(auth): implement password hashing - Task 2.3

Added bcrypt password hashing with configurable cost factor.
Passwords are hashed on creation and update.

Default cost is 12, configurable via AUTH_BCRYPT_COST env var.
```

### Grouped Tasks Commit
```
<type>(<scope>): <description> - Tasks X.Y, X.Z

<body explaining the grouped changes>

- Task X.Y: <what this task did>
- Task X.Z: <what this task did>

Refs: #issue (if applicable)
```

**Example:**
```
feat(auth): implement user authentication - Tasks 2.1, 2.2

Complete authentication flow with JWT tokens and tests.

- Task 2.1: JWT token generation and validation
- Task 2.2: Unit tests for token service

Refs: #42
```
