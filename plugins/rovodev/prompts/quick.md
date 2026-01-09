# Quick - Fast Fixes

Handle small, well-defined tasks without the full planning overhead.

## When to Use

**Good for Quick**:
- Bug fixes with known solution
- Typo corrections
- Documentation updates
- Dependency updates
- Simple refactoring
- Adding tests for existing code
- Formatting/linting fixes

**NOT for Quick** (use `@rovodev` instead):
- New features
- Architecture changes
- Multi-file refactoring
- Anything requiring investigation
- Breaking changes

## Process

### Step 1: Validate Scope

Confirm the task is truly "quick":
- Can be done in < 15 minutes
- Solution is clear
- No investigation needed
- Low risk of breaking changes

If not quick, suggest: "This looks non-trivial. Let's use `@rovodev` to plan it properly."

### Step 2: Execute Directly

**No planning overhead**:
- No `.devloop/plan.md` needed
- No branch creation prompt
- Just do the work

**Steps**:
1. Make the change
2. Run relevant tests
3. Verify with `git diff`

### Step 3: Validate

Before finishing:

```bash
# Run tests related to change
uv run pytest path/to/test_file.py -v

# Check formatting
uv run ruff format --check .
uv run ruff check --select I .

# If needed, auto-fix
uv run ruff format .
```

### Step 4: Commit (Optional)

Offer to commit:

```
✓ Change complete

Files modified:
- path/to/file.py

Would you like to commit?
- yes: Create conventional commit
- no: Leave unstaged
- review: Show full diff first
```

If yes, create conventional commit:

```bash
git add [files]
git commit -m "fix: [concise description]

[Optional body with more context]"
```

## Commit Message Format

Use conventional commits:

```
<type>(<scope>): <description>

[optional body]
```

**Types**:
- `fix:` - Bug fixes
- `docs:` - Documentation
- `style:` - Formatting (no code change)
- `refactor:` - Code restructuring
- `test:` - Adding/fixing tests
- `chore:` - Maintenance tasks

**Examples**:
```
fix(cli): handle whitespace in directory paths
docs(readme): update installation instructions
test(auth): add JWT validation test cases
chore(deps): upgrade ruff to 0.2.0
```

## Example Flows

### Bug Fix
```
User: Fix the whitespace bug in /directories command

Quick:
1. Find bug in cli/commands.py:45
2. Change: path.split() → shlex.split(path)
3. Test: pytest tests/test_commands.py::test_directories_with_spaces -v
4. Commit: fix(cli): handle whitespace in directory paths
✓ Done
```

### Documentation
```
User: Update the quickstart docs to mention uv requirement

Quick:
1. Edit docs/QUICKSTART.md
2. Add "Requires: uv >= 0.1.0"
3. Commit: docs(quickstart): add uv version requirement
✓ Done
```

### Test Addition
```
User: Add test for empty config handling

Quick:
1. Add test_empty_config() to tests/test_config.py
2. Run: pytest tests/test_config.py::test_empty_config -v
3. Commit: test(config): add empty config handling test
✓ Done
```

## Integration with Plans

If working within an existing plan, you can still use `@quick` for small detours:

1. Note in progress log: `- [timestamp]: Quick fix - [description]`
2. Continue with planned work

But if the "quick fix" reveals bigger issues, stop and:
- Update the plan with new tasks
- Or run `@spike` to investigate

## Safety Checks

Before committing, verify:
- [ ] Tests pass
- [ ] No unintended changes (`git diff`)
- [ ] Follows project style (ruff, etc.)
- [ ] Commit message follows conventions

## When to Abort

Stop and use `@rovodev` if:
- Taking longer than expected (>15 min)
- Uncovering related issues
- Change is riskier than thought
- Need to modify multiple areas

Tell user: "This is bigger than expected. Let's plan it with `@rovodev`."

---

**What's the quick fix?**
