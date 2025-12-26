# Bootstrap Examples and Input Handling

## Supported Document Types

| Extension | Handling |
|-----------|----------|
| `.md` | Read as markdown, extract sections |
| `.txt` | Read as plain text |
| `.yaml/.yml` | Parse as structured data (API specs) |
| `.json` | Parse as structured data |
| `.pdf` | Read and extract text content |

## Multiple Documents

If multiple paths provided, read all and synthesize:
```
/devloop:bootstrap ./docs/PRD.md ./specs/api.yaml ./brief.txt
```

## URL Support

Can fetch remote documents:
```
/devloop:bootstrap https://docs.google.com/document/d/xxx/export?format=txt
```

---

## Example: From PRD

```
/devloop:bootstrap ./PRD.md

# Reads PRD, extracts:
# - Product name and description
# - Target users
# - Feature list
# - Any technical requirements mentioned
```

## Example: From API Spec

```
/devloop:bootstrap ./openapi.yaml

# Reads OpenAPI spec, extracts:
# - API purpose
# - Endpoints structure
# - Data models
# - Authentication method
```

## Example: Interactive (No Args)

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
