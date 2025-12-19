---
name: golangci-setup
description: Set up golangci-lint with devloop's strict configuration template
allowed_tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
---

# golangci-setup

Set up golangci-lint with devloop's strict configuration for Go projects.

## Overview

This command creates a `.golangci.yml` configuration file in your project root using devloop's strict linter template. The template enables 45+ linters with sensible defaults for professional Go development.

## Usage

```
/devloop:golangci-setup
```

## What It Does

1. Checks if `.golangci.yml` already exists
2. If exists, asks for confirmation before overwriting
3. Creates the configuration from devloop's strict template
4. Optionally verifies golangci-lint is installed

## Workflow

### Step 1: Check Prerequisites

First, verify the project environment:

```bash
# Check if this is a Go project
if [ -f "go.mod" ]; then
    echo "Go project detected"
else
    echo "Warning: No go.mod found - this may not be a Go project"
fi

# Check if golangci-lint is installed
if command -v golangci-lint &> /dev/null; then
    golangci-lint --version
else
    echo "golangci-lint not found"
fi
```

If golangci-lint is not installed, inform the user:

```
golangci-lint is not installed. Install it with:

# macOS
brew install golangci-lint

# Linux
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin

# Go install
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

### Step 2: Check Existing Configuration

Check if `.golangci.yml` already exists:

```bash
if [ -f ".golangci.yml" ]; then
    echo "Existing .golangci.yml found"
fi
```

If it exists:

```
Use AskUserQuestion:
- question: "A .golangci.yml already exists. What would you like to do?"
- header: "Config"
- multiSelect: false
- options:
  - Overwrite (Replace with devloop's strict template)
  - Merge (Keep existing and add missing linters) - NOT IMPLEMENTED
  - View diff (Show differences between existing and template)
  - Cancel (Keep existing configuration)
```

If "View diff" selected, show the key differences between existing config and template.

### Step 3: Create Configuration

Read the template from devloop's templates directory and create the configuration.

The template is located at: `${CLAUDE_PLUGIN_ROOT}/templates/golangci.yml`

Use the Read tool to read the template, then use the Write tool to create `.golangci.yml` in the project root.

The template includes:

**Default Linters (6)**:
- errcheck, gosimple, govet, ineffassign, staticcheck, unused

**Additional Strict Linters (39)**:
- bodyclose, contextcheck, cyclop, dupl, durationcheck
- errorlint, exhaustive, funlen, gocognit, goconst
- gocritic, gocyclo, godot, gofmt, goimports
- gosec, lll, misspell, nakedret, nestif
- nilerr, nolintlint, prealloc, predeclared, revive
- sqlclosecheck, stylecheck, tparallel, unconvert, unparam, whitespace

**Settings**:
- Function length: 50 lines / 40 statements
- Cyclomatic complexity: 10
- Cognitive complexity: 15
- Line length: 120 characters
- Nesting complexity: 4

**Exclusions**:
- Test files excluded from funlen and dupl checks
- Interface implementations excluded from unparam "always receives"

### Step 4: Confirm Success

After creating the file:

```markdown
## golangci-lint Configuration Created

Created `.golangci.yml` with devloop's strict configuration.

**Enabled**: 45 linters
**Settings**: Complexity 10, Function length 50 lines, Line length 120

### Next Steps

1. Run `golangci-lint run` to check your code
2. Fix any issues found
3. The devloop hook will automatically lint Go files as you edit them

### Customizing

Edit `.golangci.yml` to:
- Disable specific linters: Add to `linters.disable`
- Adjust thresholds: Modify `linters-settings`
- Add exclusions: Update `issues.exclude-rules`
```

### Step 5: Offer Next Actions

```
Use AskUserQuestion:
- question: "What would you like to do next?"
- header: "Next"
- multiSelect: false
- options:
  - Run linter (Run golangci-lint on the project now)
  - Continue working (Go back to what I was doing)
  - View config (Show the created configuration)
```

If "Run linter" selected:

```bash
golangci-lint run ./...
```

Report the results and offer to fix any issues found.

---

## Template Reference

The configuration template is based on `templates/golangci.yml.template` in the cc-plugins repository. It represents an opinionated but practical set of linters for professional Go development.

## Integration with Hooks

Once `.golangci.yml` exists, the devloop PostToolUse hook will automatically run golangci-lint on any Go files you edit. Lint errors are added to Claude's context so issues can be fixed immediately.

To disable automatic linting temporarily, you can rename or remove `.golangci.yml`.
