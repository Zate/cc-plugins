---
description: Bootstrap a new project from documentation artifacts (PRD, specs, briefs) - generates CLAUDE.md and prepares for devloop
argument-hint: Path(s) to documentation files (PRD, specs, etc.)
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill", "WebFetch"]
---

# Devloop Bootstrap - New Project Setup

Set up a new project for devloop by generating CLAUDE.md from documentation artifacts.

## Purpose

Prepare a greenfield project (no code yet) for development with devloop by:
1. Reading provided documentation (PRD, specs, briefs, design docs)
2. Extracting project context and requirements
3. Generating a comprehensive CLAUDE.md
4. Setting up the devloop directory structure
5. Optionally creating an initial development plan

## When to Use

- Starting a new project from scratch
- Have PRD, specs, or design documents but no code
- Want to set up devloop before writing any code
- Converting business requirements into development-ready context

## When NOT to Use

- **Existing codebase**: Use `/init` instead to generate CLAUDE.md from existing code
- **No documentation**: Just start with `/devloop` and answer clarifying questions
- **Quick prototypes**: Over-engineering for throwaway code

---

## Workflow

### Phase 1: Document Analysis

**Goal**: Understand the project from provided documentation

**Actions**:

1. Create todo list for bootstrap process:
```
TodoWrite: [
  "Analyze provided documentation",
  "Determine tech stack",
  "Generate CLAUDE.md",
  "Set up devloop structure",
  "Offer next steps"
]
```

2. Check what was provided: $ARGUMENTS

3. If no documents provided, ask:
```
Use AskUserQuestion:
- question: "What documentation do you have for this project?"
- header: "Docs"
- options:
  - PRD/Requirements: I have a product requirements document
  - Technical specs: I have API specs, architecture docs, or design docs
  - Brief/Overview: I have a project brief or business case
  - Nothing yet: I just have an idea, no formal docs
```

4. For each document path provided:
   - Read the document
   - Extract key information:
     - Project name and purpose
     - Target users
     - Core features/requirements
     - Technical decisions (if any)
     - Constraints and non-functional requirements

5. Invoke the bootstrap skill:
```
Skill: project-bootstrap
```

### Phase 2: Tech Stack Determination

**Goal**: Establish the technology choices

**Actions**:

1. If tech stack is specified in documents, confirm:
```
Use AskUserQuestion:
- question: "The docs mention [tech]. Should I use this stack?"
- header: "Stack"
- options:
  - Yes, use specified: [tech stack from docs]
  - Let me choose: I want to pick something different
  - Need suggestions: Help me decide
```

2. If tech stack is NOT specified, ask:
```
Use AskUserQuestion:
- question: "What type of project is this?"
- header: "Type"
- options:
  - Web frontend: React/Vue/Angular frontend application
  - Backend API: REST/GraphQL API server
  - Full stack: Frontend + backend together
  - CLI tool: Command-line application
```

3. Based on project type, ask about language:
```
Use AskUserQuestion:
- question: "What's your preferred language/framework?"
- header: "Tech"
- options:
  - [Recommended for type]: [e.g., "TypeScript + React (Recommended)"]
  - [Alternative 1]: [e.g., "TypeScript + Vue"]
  - [Alternative 2]: [e.g., "JavaScript + React"]
  - Other: I have a specific preference
```

### Phase 3: Generate CLAUDE.md

**Goal**: Create the project memory file

**Actions**:

1. Create the CLAUDE.md file with extracted information:

```markdown
# [Project Name]

[Brief description from PRD/docs - 2-3 sentences max]

## Tech Stack

- **Language**: [chosen language]
- **Framework**: [chosen framework]
- **Database**: [if applicable]
- **Testing**: [test framework for stack]

## Project Structure

```
[project-name]/
├── [appropriate directories for stack]
└── ...
```

## Common Commands

```bash
# Development
[relevant command]  # Start dev server / run locally

# Testing
[relevant command]  # Run tests

# Building
[relevant command]  # Build for production
```

## Coding Conventions

- [Key convention 1 for the language]
- [Key convention 2 for the framework]
- [Any convention mentioned in docs]

## Architecture Notes

[Key architectural decisions from specs, or sensible defaults]

## Development Workflow

- Feature branches off main
- Tests required for new features
- [Any process from docs]
```

2. Ask user to review:
```
Use AskUserQuestion:
- question: "I've drafted CLAUDE.md. How does it look?"
- header: "Review"
- options:
  - Looks good: Save it as-is
  - Minor tweaks: I'll edit it after
  - Major changes: Let's revise together
```

3. Write the CLAUDE.md file to project root

### Phase 4: Set Up Devloop Structure

**Goal**: Prepare devloop directory and optional plan

**Actions**:

1. Create .claude directory:
```bash
mkdir -p .claude
```

2. Ask about initial plan:
```
Use AskUserQuestion:
- question: "Would you like me to create an initial development plan?"
- header: "Plan"
- options:
  - Yes, from requirements: Extract features from docs into a plan
  - Yes, but minimal: Just the scaffolding tasks
  - No, I'll plan later: Just set up CLAUDE.md for now
```

3. If plan requested, create `.claude/devloop-plan.md`:

```markdown
# Devloop Plan: [Project Name] - Initial Setup

**Created**: [Date]
**Status**: Ready to Start
**Current Phase**: Scaffolding

## Overview
[Project description from bootstrap]

## Tasks

### Phase 1: Project Scaffolding
- [ ] Initialize project structure
- [ ] Set up build tooling and dependencies
- [ ] Configure test framework
- [ ] Add linting and formatting
- [ ] Create initial README

### Phase 2: Core Feature - [First Feature]
- [ ] [Task derived from requirements]
- [ ] [Task derived from requirements]

## Progress Log
- [Date]: Project bootstrapped with devloop
```

### Phase 5: Next Steps

**Goal**: Guide user to start development

**Actions**:

1. Summarize what was created:
```
## Bootstrap Complete

Created:
- CLAUDE.md - Project context and conventions
- .claude/ - Devloop directory
[- .claude/devloop-plan.md - Initial plan (if created)]

Your project is ready for devloop!
```

2. Offer next steps:
```
Use AskUserQuestion:
- question: "Ready to start development. What would you like to do?"
- header: "Next"
- options:
  - Start implementing: Begin with /devloop:continue (Recommended)
  - Plan first feature: Run /devloop with first feature
  - I'll take it from here: Just finish bootstrap
```

3. If user chooses to continue:
   - If plan exists: Suggest `/devloop:continue`
   - If no plan: Suggest `/devloop [first feature from docs]`

---

## Input Handling

### Supported Document Types

| Extension | Handling |
|-----------|----------|
| `.md` | Read as markdown, extract sections |
| `.txt` | Read as plain text |
| `.yaml/.yml` | Parse as structured data (API specs) |
| `.json` | Parse as structured data |
| `.pdf` | Read and extract text content |

### Multiple Documents

If multiple paths provided, read all and synthesize:
```
/devloop:bootstrap ./docs/PRD.md ./specs/api.yaml ./brief.txt
```

### URL Support

Can fetch remote documents:
```
/devloop:bootstrap https://docs.google.com/document/d/xxx/export?format=txt
```

---

## Examples

### From PRD
```
/devloop:bootstrap ./PRD.md

# Reads PRD, extracts:
# - Product name and description
# - Target users
# - Feature list
# - Any technical requirements mentioned
```

### From API Spec
```
/devloop:bootstrap ./openapi.yaml

# Reads OpenAPI spec, extracts:
# - API purpose
# - Endpoints structure
# - Data models
# - Authentication method
```

### From Brief
```
/devloop:bootstrap

# No args - asks interactively:
# - What's the project about?
# - Who are the users?
# - What tech stack?
```

---

## Best Practices

### DO
- Start with whatever documentation you have
- Be honest about tech decisions not yet made
- Keep CLAUDE.md concise and expandable
- Review generated content before proceeding

### DON'T
- Over-specify before writing code
- Include secrets or credentials
- Add every possible convention
- Skip the review step

---

## Model Usage

| Phase | Model | Rationale |
|-------|-------|-----------|
| Document Analysis | sonnet | Need comprehension |
| Tech Stack | haiku | Simple choices |
| Generate CLAUDE.md | sonnet | Quality writing |
| Setup Structure | haiku | Simple file ops |
| Next Steps | haiku | Simple routing |

---

## Related Commands

| Command | When to Use |
|---------|-------------|
| `/devloop:bootstrap` | New project, have docs, no code |
| `/init` | Existing project, need CLAUDE.md |
| `/devloop` | Ready to implement features |
| `/devloop:continue` | Resume from bootstrap plan |
