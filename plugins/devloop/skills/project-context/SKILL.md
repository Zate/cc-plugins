---
name: project-context
description: Detects project tech stack, languages, frameworks, and features. Use when you need to understand the project structure for development workflows, architecture decisions, or tooling selection.
---

# Project Context Detection

Detects and provides context about the current project's technology stack, features, and structure.

## When to Use This Skill

- **Starting feature development** - To scope applicable agents and patterns
- **Architecture planning** - To understand existing tech stack constraints
- **Test strategy selection** - To determine which testing frameworks apply
- **Project onboarding** - To quickly understand the tech stack

## When NOT to Use This Skill

- **Context already known** - Don't re-detect if `.claude/project-context.json` is fresh
- **Single file review** - Overkill for reviewing a single file
- **Non-code tasks** - Documentation, configuration-only work

## Project Context Schema

The skill produces or reads `.claude/project-context.json`:

```json
{
  "name": "project-name",
  "type": "web-api | web-app | cli | library | mobile | other",
  "languages": ["typescript", "python", "go", ...],
  "frameworks": ["express", "django", "react", ...],
  "features": {
    "authentication": true | false,
    "oauth": true | false,
    "file-upload": true | false,
    "websockets": true | false,
    "database": true | false,
    "api": true | false,
    "graphql": true | false,
    "payments": true | false,
    "email": true | false,
    "logging": true | false
  },
  "directories": {
    "source": "src/",
    "tests": "tests/",
    "config": "config/"
  },
  "detected_at": "2025-12-15T10:30:00Z",
  "security_notes": []
}
```

## Detection Strategies

### Language Detection

| Indicator | Language |
|-----------|----------|
| `*.ts`, `*.tsx`, `tsconfig.json` | TypeScript |
| `*.js`, `*.jsx`, `*.mjs` | JavaScript |
| `*.py`, `requirements.txt`, `pyproject.toml` | Python |
| `*.go`, `go.mod` | Go |
| `*.rs`, `Cargo.toml` | Rust |
| `*.java`, `pom.xml`, `build.gradle` | Java |
| `*.rb`, `Gemfile` | Ruby |
| `*.php`, `composer.json` | PHP |
| `*.cs`, `*.csproj` | C# |

### Framework Detection

| Indicator | Framework |
|-----------|-----------|
| `express` in package.json | Express.js |
| `fastify` in package.json | Fastify |
| `next` in package.json | Next.js |
| `react` in package.json | React |
| `vue` in package.json | Vue.js |
| `angular` in package.json | Angular |
| `django` in requirements | Django |
| `flask` in requirements | Flask |
| `fastapi` in requirements | FastAPI |
| `gin-gonic` in go.mod | Gin |
| `fiber` in go.mod | Fiber |
| `spring` in pom.xml | Spring |
| `rails` in Gemfile | Rails |
| `laravel` in composer.json | Laravel |

### Feature Detection

| Feature | Detection Method |
|---------|------------------|
| authentication | Auth middleware, passport, JWT imports, login routes |
| oauth | OAuth libraries, social auth configs, OIDC |
| file-upload | Multer, file upload handlers, S3 clients |
| websockets | Socket.io, WS library, WebSocket handlers |
| database | ORM imports, database clients, migration files |
| api | REST routes, API directories, OpenAPI specs |
| graphql | GraphQL libraries, schema files, resolvers |
| payments | Stripe, PayPal, payment webhooks |
| email | Nodemailer, SendGrid, email templates |
| logging | Winston, Bunyan, logging middleware |

### Project Type Classification

| Type | Indicators |
|------|------------|
| web-api | API routes, no frontend build, REST/GraphQL |
| web-app | Frontend framework + backend routes |
| cli | Bin entry, commander/yargs, no web server |
| library | npm publish config, no app entry point |
| mobile | React Native, Flutter, mobile SDKs |

## Security Feature Mapping

When context is detected, map to relevant security concerns:

| Feature | Security Domains |
|---------|------------------|
| authentication | V6 (Authentication), V7 (Session) |
| oauth | V10 (OAuth/OIDC) |
| file-upload | V5 (File Handling) |
| api | V4 (API Security), V1 (Encoding) |
| database | V2 (Validation), V14 (Data Protection) |
| graphql | V4 (API Security), introspection |
| payments | PCI DSS, V12 (Communications) |
| websockets | V17 (WebRTC/WS), V6 (Auth) |

## Usage

### Automatic Detection

Run the build script to generate/update context:

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/build-project-context.sh
```

### Manual Override

Create or edit `.claude/project-context.json` directly for:
- Projects with non-standard structure
- Additional security notes
- Custom feature flags

### Reading Context

When context exists and is fresh (<24h old):

1. Read `.claude/project-context.json`
2. Use detected info for audit scoping
3. Skip re-detection unless requested

### Freshness Check

```bash
# Check if context is stale (>24h)
if [ -f .claude/project-context.json ]; then
  detected_at=$(jq -r '.detected_at' .claude/project-context.json)
  # Compare with current time
fi
```

## Integration

### With Devloop Workflows

The devloop agents use project context to:
1. Select appropriate language-specific patterns (Go, React, Java, Python)
2. Customize test generation strategies
3. Choose relevant architecture patterns

### With Code Architect

The code-architect agent uses project context to:
1. Apply framework-specific design patterns
2. Suggest appropriate directory structures
3. Recommend compatible libraries

### With Security Plugin

This skill is designed to be identical to the security plugin's project-context skill, allowing both plugins to share the same detection logic and generated context.

## Output Example

```json
{
  "name": "ecommerce-api",
  "type": "web-api",
  "languages": ["typescript", "sql"],
  "frameworks": ["express", "prisma", "jest"],
  "features": {
    "authentication": true,
    "oauth": true,
    "file-upload": true,
    "websockets": false,
    "database": true,
    "api": true,
    "graphql": false,
    "payments": true,
    "email": true,
    "logging": true
  },
  "directories": {
    "source": "src/",
    "tests": "tests/",
    "config": "config/"
  },
  "detected_at": "2025-12-15T10:30:00Z",
  "security_notes": [
    "Payment processing detected - PCI DSS considerations apply",
    "File uploads detected - validate types and scan for malware"
  ]
}
```

## See Also

- `scripts/build-project-context.sh` - Detection script
- `Skill: workflow-selection` - Choosing development workflows
- `Skill: go-patterns` - Go-specific patterns
- `Skill: react-patterns` - React-specific patterns
- `Skill: java-patterns` - Java-specific patterns
- `Skill: python-patterns` - Python-specific patterns
