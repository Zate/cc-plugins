---
# Devloop Configuration Template
# Copy this file to your project's .claude/ directory as devloop.local.md
# Customize the settings below for your project

# Definition of Done - Customize criteria for your project
definition_of_done:
  code:
    - All tasks in todo list completed
    - Code follows project conventions
    - No TODO/FIXME in new production code
    - No hardcoded secrets or credentials
    - No debug statements (console.log, print, etc.)
  testing:
    - Unit tests written for new code
    - All tests passing
    - No skipped tests without justification
    # Uncomment and adjust for coverage requirements:
    # - Coverage >= 80%
  quality:
    - Code review completed (confidence >= 80)
    - No critical security issues
    - No high-severity bugs identified
    - Build succeeds without errors
  documentation:
    - README updated if public API changed
    - Code comments for complex logic
    # Uncomment if project uses changelog:
    # - CHANGELOG entry added
  integration:
    - Changes are committable (no uncommitted debug code)
    - Branch is up to date with base

# Model preferences - Override default model selection
# Uncomment and adjust as needed
# model_preferences:
#   exploration: sonnet     # Default: sonnet
#   architecture: sonnet    # Default: sonnet (opus for complex)
#   implementation: sonnet  # Default: sonnet
#   review: sonnet          # Default: sonnet (opus for critical)
#   testing: haiku          # Default: haiku

# Workflow preferences
workflow:
  # Skip phases for simpler projects (not recommended for large features)
  # skip_phases: []

  # Auto-approve certain phases (use with caution)
  # auto_approve:
  #   - complexity_assessment  # Skip complexity check prompt
  #   - planning               # Auto-approve task plan

  # Default branch naming pattern
  branch_pattern: "feature/{ticket}-{description}"

  # Commit message format (conventional, angular, or custom)
  commit_format: conventional

# Project-specific skills to always invoke
# auto_skills:
#   - go-patterns           # For Go projects
#   - react-patterns        # For React projects
#   - java-patterns         # For Java projects
#   - python-patterns       # For Python projects

# Test configuration
testing:
  # Test command override (auto-detected by default)
  # command: "npm test"

  # Coverage threshold (optional)
  # coverage_threshold: 80

  # Test file patterns
  patterns:
    - "**/*.test.ts"
    - "**/*.test.js"
    - "**/*_test.go"
    - "**/test_*.py"

# Security scanning configuration
security:
  # Severity threshold for blocking (critical, high, medium, low)
  block_threshold: high

  # Patterns to ignore (e.g., test files, examples)
  ignore_patterns:
    - "**/test/**"
    - "**/tests/**"
    - "**/*.test.*"
    - "**/examples/**"
    - "**/fixtures/**"

# Git integration
git:
  # Default base branch for PRs
  base_branch: main

  # PR template sections to include
  pr_sections:
    - summary
    - changes
    - testing
    - checklist

  # Auto-add labels based on changes
  # auto_labels:
  #   - feature
  #   - bug
  #   - docs

---

# Project-Specific Notes

Add any project-specific notes, conventions, or context that should be considered during development.

## Architecture Notes

<!-- Document key architectural decisions or patterns -->

## Common Patterns

<!-- Document common patterns used in this project -->

## Known Issues

<!-- Document any known issues or technical debt -->

## External Dependencies

<!-- Document external services, APIs, or dependencies -->
