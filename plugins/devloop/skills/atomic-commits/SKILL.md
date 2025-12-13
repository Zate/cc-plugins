# Atomic Commits Skill

Guidance for creating reviewable, atomic commits that capture logical units of work.

## When to Use This Skill

Use this skill when:
- Deciding whether to commit after completing a task
- Determining if multiple tasks should be grouped into one commit
- Planning how to structure commits for a feature
- Reviewing commit size and scope before committing

## When NOT to Use This Skill

- For commit message formatting (use `Skill: git-workflows`)
- For branch strategy decisions (use `Skill: git-workflows`)
- When doing exploratory/spike work (commits less important)

---

## Core Principle: Reviewable Commits

Every commit should be:
1. **Reviewable**: Someone can understand it in 5-15 minutes
2. **Atomic**: One logical change, not multiple unrelated changes
3. **Buildable**: Project compiles/builds after the commit
4. **Testable**: Tests pass (or are intentionally skipped with note)
5. **Revertable**: Can be reverted without breaking unrelated features

---

## Commit Decision Matrix

| Scenario | Decision | Rationale |
|----------|----------|-----------|
| Single file, < 50 lines | Commit | Trivially reviewable |
| Single feature implementation | Commit | Self-contained unit |
| Feature + its unit tests | **Group → 1 commit** | Logically coupled, tests validate feature |
| Backend API endpoint | Commit separately | Self-contained, reviewable alone |
| Frontend consuming that API | Separate commit | Different concern, different review focus |
| Database migration | Commit alone | High-risk, needs isolated review |
| Refactoring across files | Commit alone | Isolate risk, easy to revert |
| Config/env changes | Commit alone | Easy to identify and revert |
| Bug fix | Commit alone | Clear history for bisecting |
| Multiple bug fixes | Separate commits | Each fix independently revertable |

---

## Commit Size Guidelines

### Ideal: 50-200 lines changed
- Easy to review in one sitting
- Clear scope and intent
- Low cognitive load for reviewer

### Acceptable: 200-300 lines
- Still reviewable but requires more focus
- Should have very clear structure
- Consider if it can be split

### Warning: 300-500 lines
- Getting difficult to review thoroughly
- High chance of issues being missed
- Split if at all possible

### Red Flag: > 500 lines
- Too large for effective review
- Must split unless truly atomic (rare)
- Examples of valid large commits:
  - Generated code (clearly marked)
  - Large rename/move operation
  - Initial project scaffold

---

## Grouping Guidelines

### When to Group Tasks into One Commit

**Group these:**
- Feature implementation + its tests
- Model + its validation logic
- API endpoint + its request/response types
- Component + its styles (if co-located)
- Related small fixes (each < 20 lines)

**Grouping criteria:**
1. Tasks are in the same functional area
2. Combined size is < 500 lines
3. Changes make more sense together than apart
4. Reviewer benefits from seeing them together

### When to Keep Commits Separate

**Separate these:**
- Backend and frontend changes
- Feature code and refactoring
- Bug fixes and new features
- Database changes and application code
- Different modules/packages

**Separation criteria:**
1. Different areas of expertise to review
2. Different risk profiles
3. Changes are independently useful
4. Easier to revert one without the other

---

## Commit Message Format with Task References

When committing task(s) from a devloop plan, include task references:

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

---

## Workflow: Deciding When to Commit

### After Each Task, Ask:

```
1. Is this task self-contained?
   YES → Consider committing now
   NO  → What does it depend on?

2. Is the next task tightly related?
   YES → Consider grouping
   NO  → Commit now

3. What's the combined line count?
   < 300 → Grouping is fine
   > 300 → Probably commit separately

4. Would a reviewer benefit from seeing these together?
   YES → Group them
   NO  → Commit separately
```

### Decision Flow
```
Task Complete
     │
     ├─► Is it < 100 lines AND self-contained?
     │   YES → Commit now
     │   NO  ↓
     │
     ├─► Is next task tightly coupled?
     │   NO  → Commit now
     │   YES ↓
     │
     ├─► Would combined be < 500 lines?
     │   NO  → Commit now
     │   YES ↓
     │
     └─► Group with next task
```

---

## Examples

### Example 1: Feature with Tests (Group)
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

### Example 2: Backend + Frontend (Separate)
```
Task 4.1: Add avatar upload API
Task 4.2: Add avatar upload UI component

Decision: SEPARATE
Reason: Different concerns, different reviewers might look at each

Commits:
1. feat(api): add avatar upload endpoint - Task 4.1
2. feat(ui): add avatar upload component - Task 4.2
```

### Example 3: Multiple Small Fixes (Group)
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

### Example 4: Refactoring (Separate)
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
❌ feat: implement everything

Added user auth, profile pages, admin panel, fixed some bugs,
refactored database layer, and updated dependencies.

Changes across 47 files, +2847 -892 lines
```

### 2. "Work In Progress Commit"
```
❌ wip: stuff

Various changes, will clean up later.
```

### 3. "Mixed Concerns Commit"
```
❌ feat(auth): add login and fix unrelated CSS bug

Added login functionality.
Also fixed that CSS bug from last week.
```

### 4. "Partial Feature Commit"
```
❌ feat(users): add user service (part 1 of 3)

This commit adds half the user service.
Next commit will add the other half.
[Leaves code in broken state]
```

---

## Phase Boundaries

Phase boundaries in the devloop plan are natural commit points:

**At phase completion:**
1. All grouped changes MUST be committed
2. No pending uncommitted work should carry to next phase
3. This ensures clean phase transitions
4. Makes it easy to identify what each phase delivered

```
Phase 2: Authentication ✓
  - [x] Task 2.1: JWT tokens       → Committed: abc1234
  - [x] Task 2.2: Token tests      → Committed: abc1234 (grouped)
  - [x] Task 2.3: Password hashing → Committed: def5678
  - [x] Task 2.4: Login endpoint   → Committed: ghi9012

[All Phase 2 work committed before starting Phase 3]

Phase 3: User Profiles
  - [ ] Task 3.1: Profile model
  ...
```

---

## Integration

This skill is used by:
- `Skill: task-checkpoint` - Commit decision during task completion
- `/devloop:continue` - After task execution
- `/devloop:ship` - Before shipping a feature

References:
- `Skill: git-workflows` - Commit message conventions
- `Skill: plan-management` - Task tracking in plan file
