# Project Bootstrap Skill

Best practices for bootstrapping new projects with CLAUDE.md and preparing them for devloop workflows.

## When to Use

- Starting a new project from scratch
- Setting up CLAUDE.md for the first time
- Converting documentation artifacts (PRD, specs) into project context
- Preparing a greenfield project for devloop

## When NOT to Use

- **Existing codebase**: Use `/init` for projects with code already
- **Quick additions**: Don't over-engineer simple file additions
- **No documentation**: If no PRD/specs exist, use `/devloop` to start directly

---

## CLAUDE.md Best Practices

### Core Principle: Onboard Claude into Your Project

CLAUDE.md should answer three questions:
1. **WHAT**: The tech stack, project structure, key directories
2. **WHY**: The project's purpose and goals
3. **HOW**: Conventions, workflows, and development practices

### Structure Template

```markdown
# Project Name

Brief description of what this project does and its primary purpose.

## Tech Stack

- **Language**: [Primary language]
- **Framework**: [Main framework]
- **Database**: [If applicable]
- **Testing**: [Test framework]

## Project Structure

```
project/
├── src/           # Source code
├── tests/         # Test files
├── docs/          # Documentation
└── ...
```

## Common Commands

```bash
# Development
[command]  # Description

# Testing
[command]  # Description

# Building
[command]  # Description
```

## Coding Conventions

- [Convention 1]
- [Convention 2]
- [Convention 3]

## Architecture Notes

[Key architectural decisions and patterns]

## Development Workflow

[How to contribute, PR process, etc.]
```

---

## Extracting from PRDs

### What to Extract

| PRD Section | CLAUDE.md Section |
|-------------|-------------------|
| Product overview | Project description |
| Technical requirements | Tech stack |
| User stories | (Feed to requirements-gatherer) |
| Non-functional requirements | Architecture notes |
| Success metrics | (Feed to test planning) |

### Key Questions to Answer

1. **What problem does this solve?** → Project description
2. **Who are the users?** → Context for development
3. **What's the MVP scope?** → Initial feature planning
4. **What are the constraints?** → Architecture notes

---

## Extracting from Technical Specs

### What to Extract

| Spec Section | CLAUDE.md Section |
|--------------|-------------------|
| API endpoints | Architecture notes |
| Data models | Project structure hints |
| Integration points | Dependencies |
| Performance requirements | Non-functional notes |

### API Spec Patterns

If API spec provided:
- Document base URL pattern
- Note authentication method
- List key endpoints structure
- Capture error handling conventions

---

## Tech Stack Selection

### Common Stacks by Project Type

**Web Frontend**:
```markdown
- **Language**: TypeScript
- **Framework**: React 18+ / Next.js 14+
- **Styling**: Tailwind CSS
- **Testing**: Vitest + Playwright
```

**Backend API**:
```markdown
- **Language**: Go 1.21+ / TypeScript
- **Framework**: Chi / Express / Fastify
- **Database**: PostgreSQL
- **Testing**: Go test / Jest
```

**Full Stack**:
```markdown
- **Frontend**: React + TypeScript
- **Backend**: Node.js / Go
- **Database**: PostgreSQL
- **Testing**: Jest + Playwright
```

**CLI Tool**:
```markdown
- **Language**: Go / Rust
- **Framework**: Cobra / Clap
- **Testing**: Built-in test framework
```

---

## Directory Structure Patterns

### Standard Layouts

**Go Project**:
```
project/
├── cmd/           # Application entrypoints
├── internal/      # Private application code
├── pkg/           # Public libraries
├── api/           # API definitions
└── tests/         # Integration tests
```

**TypeScript Project**:
```
project/
├── src/
│   ├── components/
│   ├── hooks/
│   ├── utils/
│   └── types/
├── tests/
└── public/
```

**Python Project**:
```
project/
├── src/
│   └── project_name/
├── tests/
├── docs/
└── scripts/
```

---

## Coding Conventions by Language

### Go Conventions
```markdown
## Coding Conventions

- Use `gofmt` for formatting
- Error handling: return errors, don't panic
- Interfaces in consumer packages
- Table-driven tests preferred
```

### TypeScript Conventions
```markdown
## Coding Conventions

- Strict TypeScript (no `any`)
- Functional components with hooks
- Named exports over default exports
- Use `?.` optional chaining
```

### Python Conventions
```markdown
## Coding Conventions

- Use type hints throughout
- Follow PEP 8 style
- pytest for testing
- Black for formatting
```

---

## Progressive Disclosure

### Start Minimal

Initial CLAUDE.md should be concise:
- Project overview (2-3 sentences)
- Tech stack (bullet list)
- Key commands (3-5 most used)
- One critical convention

### Expand as Needed

Add detail when:
- A convention is repeatedly violated
- A pattern needs explanation
- A workflow is non-obvious

### Avoid Over-Documentation

Don't include:
- Obvious language features
- Standard framework patterns
- Information available in official docs
- Every possible convention

---

## Integration with Devloop

### After Bootstrap

1. CLAUDE.md provides context for all phases
2. SessionStart hook can detect planned language
3. code-architect reads CLAUDE.md for conventions
4. Reviewers check against documented conventions

### Creating Initial Plan

If user wants to start implementing immediately:
```markdown
# Devloop Plan: [Project Name] - Initial Setup

**Status**: Ready to Start
**Current Phase**: Discovery

## Overview
[From PRD/brief]

## Tasks

### Phase 1: Project Scaffolding
- [ ] Initialize project structure
- [ ] Set up build tooling
- [ ] Configure test framework
- [ ] Add CI/CD basics

### Phase 2: Core Foundation
- [ ] [First feature from requirements]
```

---

## Validation Checklist

Before completing bootstrap, verify:

- [ ] Project purpose is clear
- [ ] Tech stack is documented
- [ ] Key directories are listed
- [ ] Essential commands are included
- [ ] At least one convention is noted
- [ ] No secrets or credentials included
- [ ] File is concise (under 100 lines ideal)

---

## References

- [Claude Code CLAUDE.md Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Using CLAUDE.md Files](https://claude.com/blog/using-claude-md-files)
