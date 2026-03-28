---
name: d2
description: Generate diagrams using D2 (Terrastruct) -- a modern, clean diagram scripting language with excellent auto-layout. Use when the diagram-router selects D2, or when the user wants clean architecture diagrams, nested containers, or prefers D2's aesthetic. Requires the d2 CLI binary.
---

# D2 Diagram Skill

Generate diagrams using D2's declarative syntax. D2 produces clean, modern-looking diagrams with excellent auto-layout, nested containers, and multiple layout engines.

**When to use D2:**
- Architecture diagrams with nested components (D2's container nesting is excellent)
- Clean, modern aesthetic without manual positioning
- User has d2 installed or prefers it
- Network/infrastructure diagrams
- Deployment diagrams with hierarchical grouping

**When another format is better:**
- Maximum visual customization (SVG)
- Diagrams in GitHub/GitLab markdown (Mermaid -- D2 doesn't render natively)
- Whiteboard/sketch aesthetic (Excalidraw)
- ER diagrams, Gantt charts (Mermaid has better support)

Consult the **design-system** skill for color, composition, and quality rules.

## Syntax Quick Reference

### Basic Connections

```d2
server -> database: query
database -> server: results
client -> server: HTTPS
```

Arrow types:
- `->` directed (default)
- `<->` bidirectional
- `--` undirected

### Shapes and Labels

```d2
# Named with label
api: API Gateway

# Shapes
db: Database {
  shape: cylinder
}
user: User {
  shape: person
}
decision: Route? {
  shape: diamond
}
queue: Messages {
  shape: queue
}
```

Available shapes: `rectangle` (default), `square`, `page`, `parallelogram`, `document`, `cylinder`, `queue`, `package`, `step`, `callout`, `stored_data`, `person`, `diamond`, `oval`, `circle`, `hexagon`, `cloud`.

### Containers (Nested)

D2's killer feature -- nested containers for hierarchy:

```d2
aws: AWS {
  vpc: VPC {
    public: Public Subnet {
      alb: Load Balancer {
        shape: hexagon
      }
    }
    private: Private Subnet {
      app: App Server
      db: Database {
        shape: cylinder
      }
      app -> db: SQL
    }
    public.alb -> private.app: HTTP
  }
}
```

### Sequence Diagrams

```d2
shape: sequence_diagram

client: Client
server: Server
db: Database

client -> server: POST /users
server -> db: INSERT INTO users
db -> server: OK
server -> client: 201 Created
```

### SQL Tables

```d2
users: Users {
  shape: sql_table
  id: int {constraint: primary_key}
  name: varchar
  email: varchar {constraint: unique}
}

orders: Orders {
  shape: sql_table
  id: int {constraint: primary_key}
  user_id: int {constraint: foreign_key}
  total: decimal
}

users -> orders: has many
```

### Classes

```d2
classes: {
  UserService: {
    shape: class
    +getUser(id): User
    +createUser(data): User
    -validateEmail(email): bool
  }
}
```

## Styling

```d2
server: Server {
  style: {
    fill: "#EFF6FF"
    stroke: "#2563EB"
    border-radius: 8
    font-color: "#1E293B"
    shadow: true
  }
}

# Connection styling
server -> db: {
  style: {
    stroke: "#64748B"
    stroke-dash: 4
  }
}
```

### Themes

D2 has built-in themes. Set at the top of the file:

```d2
vars: {
  d2-config: {
    theme-id: 200
  }
}
```

Theme IDs: 0 (default), 1 (neutral grey), 3 (flagship terrastruct), 4 (cool classics), 100 (mixed berry blue), 200 (grape soda), 300 (aubergine). Dark themes: 200-302.

### Layout Engines

D2 supports multiple layout engines:

| Engine | Best For | Install |
|---|---|---|
| dagre (default) | General purpose, fast | Built-in |
| ELK | Complex hierarchies, wide graphs | Built-in |
| TALA | Architecture diagrams (proprietary) | Requires license |

Set via CLI flag: `d2 --layout elk diagram.d2 output.svg`

## Common Mistakes to Avoid

1. **Undeclared connections** -- reference nodes before connecting: define `a: Label` before `a -> b`
2. **Missing colons** -- labels need a colon: `server: API Server` not `server API Server`
3. **Nested path separators** -- use `.` for nested references: `aws.vpc.app` not `aws/vpc/app`
4. **Forgetting shape** -- containers don't need explicit shape; leaf nodes default to rectangle
5. **Style outside element** -- styles must be inside the element block: `server: { style: { ... } }`
6. **Too deep nesting** -- 3-4 levels max for readability

## Output Format

Save as `.d2` file. Render to SVG or PNG:

```bash
# Render to SVG
d2 diagram.d2 diagram.svg

# Render to PNG
d2 --format png diagram.d2 diagram.png

# Watch mode (live preview)
d2 --watch diagram.d2 diagram.svg
```

## Setup Detection

Before generating D2, check if the user has it installed:

```bash
command -v d2 && d2 --version
```

If not installed, suggest:
```bash
# macOS
brew install d2

# Linux (script)
curl -fsSL https://d2lang.com/install.sh | sh -s --

# Go install
go install oss.terrastruct.com/d2@latest
```

## Quality Checklist

Before presenting a D2 diagram:

- [ ] Connections reference defined nodes
- [ ] Container nesting is max 3-4 levels deep
- [ ] Labels are present on all connections that need explanation
- [ ] Shapes are semantically appropriate (cylinder for DB, person for user)
- [ ] Theme specified if not using default
- [ ] File saves with `.d2` extension
