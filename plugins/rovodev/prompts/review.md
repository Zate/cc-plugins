# Review - Code Review

Perform code review for changes, PRs, or specific files.

## Review Modes

### Mode 1: Staged Changes Review

Review what's currently staged for commit:

```bash
git diff --cached
```

**Focus**:
- Functional correctness
- Code quality and style
- Test coverage
- Potential bugs

### Mode 2: Branch/PR Review

Review all changes in current branch vs main:

```bash
git diff main...HEAD
```

**Focus**:
- Architecture and design
- Breaking changes
- Documentation updates
- Migration/upgrade paths

### Mode 3: File/Module Review

Review specific files or modules:

**Focus**:
- Code organization
- Patterns and idioms
- Maintainability
- Refactoring opportunities

## Review Process

### Step 1: Understand Scope

Clarify what to review:
- Specific files?
- Staged changes?
- Branch/PR?
- Focus areas (security, performance, style)?

### Step 2: Analyze Code

Check for:

**Correctness**:
- [ ] Logic is sound
- [ ] Edge cases handled
- [ ] Error handling present
- [ ] Type safety (where applicable)

**Quality**:
- [ ] Follows project conventions (AGENTS.md)
- [ ] Clear naming
- [ ] Appropriate abstractions
- [ ] No code duplication

**Testing**:
- [ ] Tests exist for new code
- [ ] Tests cover edge cases
- [ ] Existing tests still pass
- [ ] No test-only changes without reason

**Style** (Rovo Dev specific):
- [ ] Imports at top of file
- [ ] Line length ≤ 120
- [ ] Ruff compliant
- [ ] Conventional commits (if reviewing commits)

**Documentation**:
- [ ] Docstrings for public APIs
- [ ] README updates if needed
- [ ] Comments for complex logic

### Step 3: Generate Feedback

Categorize findings:

```markdown
## Review: [Feature/File Name]

### 🔴 Issues (Must Fix)
- **file.py:45** - Logic error: Missing null check
- **test.py:120** - Test doesn't cover error case

### 🟡 Suggestions (Should Consider)
- **file.py:30** - Consider extracting to helper function
- **file.py:67** - Variable name could be clearer

### 🟢 Positive (Good Work)
- Clean error handling in auth flow
- Comprehensive test coverage
- Clear documentation

### ✅ Checklist
- [x] Tests pass
- [x] Follows style guide
- [ ] Documentation updated
- [ ] No breaking changes
```

### Step 4: Offer Actions

Present options:

```
Review complete. Next steps?

1. Fix issues → Start fixing automatically
2. Discuss → Talk through specific items
3. Ship anyway → Issues are minor
4. Generate PR comment → Format as PR review
```

## Review Criteria

### Code Quality Standards

**Good Code**:
```python
def validate_config(config: dict) -> bool:
    """Validate configuration dictionary.
    
    Args:
        config: Configuration dictionary to validate
        
    Returns:
        True if valid, False otherwise
        
    Raises:
        ValueError: If config is None
    """
    if config is None:
        raise ValueError("Config cannot be None")
    
    required_keys = ["api_key", "endpoint"]
    return all(key in config for key in required_keys)
```

**Issues**:
```python
def validate(c):  # ❌ Unclear name, no types, no docs
    if c == None:  # ❌ Use 'is None'
        return False  # ❌ Should raise exception
    if not "api_key" in c:  # ❌ Use 'in' idiomatically
        return False
    if not "endpoint" in c:
        return False
    return True  # ❌ Could be one-liner with all()
```

### Test Quality Standards

**Good Test**:
```python
def test_validate_config_with_missing_key():
    """Test validation fails when required key is missing."""
    config = {"api_key": "test123"}
    
    result = validate_config(config)
    
    assert result is False
```

**Issues**:
```python
def test_validate():  # ❌ Unclear what's being tested
    c = {"api_key": "test123"}
    assert validate_config(c) == False  # ❌ Use 'is False'
    # ❌ No docstring
    # ❌ No assertion message
    # ❌ Doesn't test error cases
```

## Rovo Dev Specific Checks

### Import Pattern
```python
# ✅ Good - imports at top
from pathlib import Path
from typing import Optional

def process_file(path: Path) -> Optional[str]:
    ...
```

```python
# ❌ Bad - unless performance critical
def process_file(path):
    from pathlib import Path  # Avoid unless necessary
    ...
```

### Package Structure
```python
# ✅ Good - specific package imports
uv run --package atlassian-cli-rovodev pytest

# ✅ Good - package-specific build
uv build --package atlassian-cli-rovodev
```

### Formatting
```bash
# Must pass
uv run ruff format --check .
uv run ruff check --select I .
```

## PR Review Mode

For PR reviews, format output for GitHub/Bitbucket:

```markdown
## Summary
[Overall assessment]

## Changes
- ✅ Feature X implemented correctly
- ⚠️ Missing tests for edge case Y
- 🔴 Bug in error handling (see inline comments)

## Inline Comments

**packages/cli/commands.py:45**
```suggestion
-    if path.split():
+    if shlex.split(path):
```
Handles whitespace in paths correctly.

## Recommendation
✅ Approve with minor changes
```

---

**What would you like to review?**
