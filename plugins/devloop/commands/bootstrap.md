---
description: Bootstrap a new project from documentation artifacts (PRD, specs, briefs) - generates CLAUDE.md and prepares for devloop
argument-hint: Path(s) to documentation files (PRD, specs, etc.)
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill", "WebFetch"]
---

# Devloop Bootstrap - New Project Setup

Set up a new project for devloop by generating CLAUDE.md from documentation artifacts.

## When to Use

- Starting a new project from scratch
- Have PRD, specs, or design documents but no code
- Want to set up devloop before writing any code

## When NOT to Use

- **Existing codebase**: Use `/init` instead
- **No documentation**: Just start with `/devloop`
- **Quick prototypes**: Over-engineering for throwaway code

---

## Workflow

### Phase 1: Document Analysis

**Goal**: Understand the project from provided documentation

1. Create todo list for bootstrap process
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

4. For each document, extract:
   - Project name and purpose
   - Target users
   - Core features/requirements
   - Technical decisions (if any)
   - Constraints and non-functional requirements

5. Invoke: `Skill: project-bootstrap`

### Phase 2: Tech Stack Determination

**Goal**: Establish the technology choices

1. If tech stack is specified in documents, confirm with user
2. If NOT specified, ask about project type:
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

3. Based on type, ask about language/framework preference

### Phase 3: Generate CLAUDE.md

**Goal**: Create the project memory file

1. Use template: `templates/bootstrap/claudemd-template.md`
2. Fill placeholders with extracted information
3. Ask user to review
4. Write CLAUDE.md to project root

### Phase 4: Set Up Devloop Structure

**Goal**: Prepare devloop directory and optional plan

1. Create directory: `mkdir -p .devloop`

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

3. If plan requested, use template: `templates/bootstrap/initial-plan-template.md`

### Phase 5: Next Steps

**Goal**: Guide user to start development

1. Summarize what was created
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

---

## Templates

Load templates for generation:

| Template | Purpose |
|----------|---------|
| `templates/bootstrap/claudemd-template.md` | CLAUDE.md structure and stack-specific defaults |
| `templates/bootstrap/initial-plan-template.md` | Plan structure and scaffolding tasks by stack |
| `templates/bootstrap/examples.md` | Input handling, examples, best practices |

```
Read: plugins/devloop/templates/bootstrap/claudemd-template.md
Read: plugins/devloop/templates/bootstrap/initial-plan-template.md
Read: plugins/devloop/templates/bootstrap/examples.md
```

---

## Related Commands

| Command | When to Use |
|---------|-------------|
| `/devloop:bootstrap` | New project, have docs, no code |
| `/init` | Existing project, need CLAUDE.md |
| `/devloop` | Ready to implement features |
| `/devloop:continue` | Resume from bootstrap plan |
