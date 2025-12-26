# Release Workflow

## Complete Release Steps

### Step 1: Determine Version
```
1. Parse commits since last tag
2. Apply version bump rules
3. Calculate new version number
```

### Step 2: Update Version Files
```
1. Find version file(s) in project
2. Update version string
3. Stage changes
```

### Step 3: Update CHANGELOG
```
1. Check if CHANGELOG.md exists
2. If yes:
   - Parse commits into sections
   - Generate new version entry
   - Prepend to CHANGELOG.md
3. If no:
   - Ask user if they want to create one
```

### Step 4: Create Release Commit
```bash
git add -A
git commit -m "chore(release): v1.2.3

- Bump version to 1.2.3
- Update CHANGELOG.md"
```

### Step 5: Create Tag
```bash
git tag -a v1.2.3 -m "Release v1.2.3"
```

### Step 6: Update Plan
```
Add Progress Log entry:
- YYYY-MM-DD HH:MM: Released v1.2.3 - [summary of release]
```

---

## Tagging

### Tag Creation
```bash
# Annotated tag (recommended)
git tag -a v1.2.3 -m "Release v1.2.3"

# Push tag
git push origin v1.2.3
```

### Tag Naming Convention
```
v1.2.3        # Standard release
v1.2.3-rc.1   # Release candidate
v1.2.3-beta.1 # Beta release
```

### When to Tag
- After version bump commit
- Before pushing to remote
- After CHANGELOG is updated

---

## At Phase Completion

```
When all tasks in a phase are [x] complete:

1. Collect commits for this phase:
   git log <phase-start-commit>..HEAD --oneline

2. Determine version bump from commits

3. Present to user:
   Use AskUserQuestion:
   - question: "Phase complete. Based on commits, suggest [MINOR] bump. Proceed?"
   - header: "Version"
   - options:
     - Accept suggested (Bump to v1.3.0)
     - Different bump (Let me choose)
     - Skip versioning (No version change now)
     - Custom version (Enter specific version)
```

## At Feature Ship

```
When running /devloop:ship:

1. Check if version bump is warranted
2. If yes, update version file(s)
3. Generate/update CHANGELOG entry
4. Commit version bump: "chore(release): bump version to v1.3.0"
5. Optionally create git tag
```

---

## Project Configuration

In `.devloop/local.md`:

```yaml
---
auto_version: true      # Suggest version bumps automatically
version_file: package.json  # Primary version file location
changelog: true         # Maintain CHANGELOG.md
auto_tag: false         # Create git tags automatically (or prompt)
---
```

---

## Release Commit Format

```
chore(release): v1.2.3

- Bump version to 1.2.3
- Update CHANGELOG.md
```
