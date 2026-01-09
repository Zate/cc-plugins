# Ship - Commit and Push

Finalize work: commit changes, optionally create PR, and clean up.

## When to Use

- Work is complete and tested
- Ready to commit and/or create PR
- Plan tasks are done

## Process

### Step 1: Review Changes

```bash
git status
git diff
```

Show user what will be committed:
```
Changes to be committed:
  Modified: 3 files
  Added: 2 files
  Deleted: 1 file

Summary:
- Implemented JWT authentication
- Added validation tests
- Updated documentation
```

### Step 2: Verify Quality

Run checks:

```bash
# Format check
uv run ruff format --check .
uv run ruff check --select I .

# Run tests
uv run pytest -v

# Optionally: type check
uv run mypy . --ignore-missing-imports
```

If checks fail:
```
⚠️ Quality checks failed:
- Formatting issues found
- 2 tests failing

Fix issues before shipping? (yes/no)
- yes: Auto-fix and retry
- no: Ship anyway (not recommended)
```

### Step 3: Check Plan Completion (if exists)

If `.devloop/plan.md` exists:

```bash
bash plugins/rovodev/scripts/check-plan-complete.sh
```

Parse result:
```json
{"complete": false, "total": 10, "done": 8, "pending": 2}
```

If not complete:
```
⚠️ Plan not complete: 2 of 10 tasks pending

Pending tasks:
- [ ] Task 3.1: Add integration tests
- [ ] Task 3.2: Update API docs

Ship anyway? (yes/no/show)
- yes: Proceed with commit
- no: Continue working
- show: Show full plan
```

### Step 4: Create Commit

Ask for commit approach:

```
Ready to commit. How?

1. Auto - Generate conventional commit message
2. Custom - You write the message
3. Review - Show full diff first
```

#### Option 1: Auto (Recommended)

Analyze changes and generate conventional commit:

```bash
# Detect type from changes
# - Added features → feat:
# - Bug fixes → fix:
# - Tests only → test:
# - Docs only → docs:
# - Refactoring → refactor:

git commit -m "feat(auth): implement JWT authentication

- Add JWT token generation and validation
- Implement middleware for route protection
- Add comprehensive test coverage
- Update API documentation"
```

#### Option 2: Custom

Prompt user for message:
```
Enter commit message (conventional format):
<type>(<scope>): <description>

Example: feat(auth): add JWT authentication
```

Validate format and commit.

#### Option 3: Review

```bash
git diff --stat
git diff
```

Show full diff, then return to step 4.

### Step 5: Push (if on branch)

```bash
git push origin $(git branch --show-current)
```

### Step 6: Create PR (optional)

Ask user:
```
Code committed and pushed.

Create pull request? (yes/no/later)
- yes: Create PR now
- no: Skip PR
- later: Instructions for manual PR
```

If yes:

**Detect platform**:
```bash
git remote -v | grep -q github && echo "github" || echo "bitbucket"
```

**GitHub**:
Use GitHub CLI if available:
```bash
gh pr create \
  --title "feat(auth): JWT authentication" \
  --body "$(cat .devloop/plan.md)" \
  --base main
```

**Bitbucket**:
Use Bitbucket API (if in CI with PETA):
```bash
curl -X POST \
  -H "Authorization: Bearer $BITBUCKET_ACCESS_TOKEN" \
  -d '{
    "title": "feat(auth): JWT authentication",
    "source": {"branch": {"name": "feat/jwt-auth"}},
    "destination": {"branch": {"name": "main"}},
    "description": "..."
  }' \
  "https://api.bitbucket.org/2.0/repositories/$WORKSPACE/$REPO/pullrequests"
```

**Neither**:
```
Create PR manually:
1. Go to repository
2. Create PR from branch 'feat/jwt-auth' to 'main'
3. Title: feat(auth): JWT authentication
4. Include plan.md in description
```

### Step 7: Clean Up

If plan is complete:

```bash
# Archive the plan
mkdir -p .devloop/archive
mv .devloop/plan.md .devloop/archive/$(date +%Y-%m-%d)-[feature-slug].md

# Clean up state files
rm -f .devloop/next-action.json
```

Tell user:
```
✅ Shipped!

- Commit: abc1234
- Branch: feat/jwt-auth
- PR: #123 (if created)
- Plan archived: .devloop/archive/2026-01-09-jwt-auth.md

Next steps:
- Merge PR when approved
- Clean up local branch after merge
```

## Commit Message Guidelines

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Formatting (no code change)
- `refactor:` - Code restructuring
- `test:` - Adding/fixing tests
- `chore:` - Maintenance, deps, build

### Scope

Project area affected:
- `auth` - Authentication
- `cli` - CLI commands
- `mcp` - MCP server
- `config` - Configuration
- `docs` - Documentation
- `api` - API endpoints

### Examples

```
feat(auth): implement JWT authentication

Add JWT token generation and validation with RS256 signing.
Includes middleware for protecting routes and refresh token support.

Closes: RDA-123

---

fix(cli): handle whitespace in directory paths

Use shlex.split() instead of str.split() to properly handle
paths containing spaces.

Fixes: RDA-456

---

docs(readme): update installation instructions

Add uv version requirement and troubleshooting section.

---

test(auth): add JWT validation edge cases

Cover expired tokens, malformed signatures, and missing claims.
```

## Pre-Ship Checklist

Before committing:

- [ ] All tests pass
- [ ] Code formatted (ruff)
- [ ] No debug code left behind
- [ ] Documentation updated
- [ ] Breaking changes documented
- [ ] Commit message follows conventions

## Fast Track (YOLO Mode)

If user wants to skip checks:

```bash
git add -A
git commit -m "wip: [description]"
git push
```

⚠️ Not recommended for main branch!

---

**Ready to ship?**
