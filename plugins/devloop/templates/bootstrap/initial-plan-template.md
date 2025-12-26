# Initial Plan Template for Bootstrap

Use when creating `.devloop/plan.md` from documentation artifacts.

## Template

```markdown
# Devloop Plan: [Project Name] - Initial Setup

**Created**: [Date]
**Status**: Ready to Start
**Current Phase**: Scaffolding

## Overview
[Project description from bootstrap]

## Tasks

### Phase 1: Project Scaffolding
- [ ] Task 1.1: Initialize project structure
- [ ] Task 1.2: Set up build tooling and dependencies
- [ ] Task 1.3: Configure test framework
- [ ] Task 1.4: Add linting and formatting
- [ ] Task 1.5: Create initial README

### Phase 2: Core Feature - [First Feature]
- [ ] Task 2.1: [Task derived from requirements]
- [ ] Task 2.2: [Task derived from requirements]
- [ ] Task 2.3: [Task derived from requirements]

## Progress Log
- [Date]: Project bootstrapped with devloop
```

## Scaffolding Tasks by Stack

### TypeScript + React
```markdown
### Phase 1: Project Scaffolding
- [ ] Task 1.1: Initialize with Vite/Next.js/CRA
- [ ] Task 1.2: Configure TypeScript (strict mode)
- [ ] Task 1.3: Set up Jest + React Testing Library
- [ ] Task 1.4: Configure ESLint + Prettier
- [ ] Task 1.5: Create initial README and .gitignore
```

### TypeScript + Node/Express
```markdown
### Phase 1: Project Scaffolding
- [ ] Task 1.1: Initialize Node.js project with TypeScript
- [ ] Task 1.2: Set up Express with typed routes
- [ ] Task 1.3: Configure Jest/Vitest for testing
- [ ] Task 1.4: Add ESLint + Prettier
- [ ] Task 1.5: Create README, .gitignore, Dockerfile
```

### Python + FastAPI
```markdown
### Phase 1: Project Scaffolding
- [ ] Task 1.1: Initialize Python project with Poetry/pip
- [ ] Task 1.2: Set up FastAPI with type hints
- [ ] Task 1.3: Configure pytest with fixtures
- [ ] Task 1.4: Add Black, isort, ruff for linting
- [ ] Task 1.5: Create README, requirements.txt, Dockerfile
```

### Go
```markdown
### Phase 1: Project Scaffolding
- [ ] Task 1.1: Initialize Go module
- [ ] Task 1.2: Set up project structure (cmd/, internal/, pkg/)
- [ ] Task 1.3: Configure go test with testify
- [ ] Task 1.4: Add golangci-lint configuration
- [ ] Task 1.5: Create README, Makefile, Dockerfile
```

## Deriving Features from PRD

When reading a PRD, look for:

1. **User Stories** → Features → Tasks
   ```
   "As a user, I want to log in..."
   → Phase: Authentication
   → Tasks: Login form, Password validation, Session management
   ```

2. **Requirements sections** → Phase organization
   ```
   "Must-have features: ..."
   → Phases for MVP

   "Nice-to-have features: ..."
   → Later phases or separate plan
   ```

3. **Non-functional requirements** → Infrastructure tasks
   ```
   "Must handle 1000 concurrent users"
   → Phase: Performance & Scaling
   → Tasks: Load testing, Caching, Database optimization
   ```
