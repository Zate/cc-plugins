---
name: mermaid
description: Generate diagrams using Mermaid syntax -- the most LLM-friendly text-based diagram format. Use when the diagram-router selects Mermaid, or when diagrams will live in GitHub/GitLab markdown, documentation, or when quick generation with broad diagram type coverage is needed. Renders natively on major platforms.
---

# Mermaid Diagram Skill

Generate diagrams using Mermaid's Markdown-inspired syntax. Mermaid is the most token-efficient and LLM-reliable diagram format, with native rendering in GitHub, GitLab, Obsidian, Notion, and many documentation platforms.

**When to use Mermaid:**
- User explicitly asks for Mermaid format
- User wants inline-editable text diagrams in version control
- User wants to convert an existing SVG/diagram to a simpler text format
- Mermaid-specific types like Gantt, Sankey, or git graphs

**When another format is better:**
- Maximum visual quality and custom design (SVG)
- Informal whiteboard/sketch aesthetic (Excalidraw)
- Threat models, comparisons, Venn diagrams (SVG -- Mermaid lacks these types)
- Complex architecture with nested containers (D2)

Consult the **design-system** skill for color, composition, and quality rules.

## Supported Diagram Types

| Type | Syntax Keyword | Best For |
|---|---|---|
| Flowchart | `flowchart TD` or `flowchart LR` | Process flows, decision trees, pipelines |
| Sequence | `sequenceDiagram` | API calls, request lifecycles, protocols |
| Class | `classDiagram` | OOP design, domain models |
| State | `stateDiagram-v2` | Object lifecycles, state machines |
| ER Diagram | `erDiagram` | Database schemas, data models |
| Gantt | `gantt` | Project timelines, schedules |
| Mind Map | `mindmap` | Topic hierarchies, brainstorming |
| Timeline | `timeline` | Chronological events |
| Sankey | `sankey-beta` | Volume/flow distribution |
| Pie | `pie` | Simple proportions |
| Git Graph | `gitGraph` | Branch/merge visualization |
| C4 Context | `C4Context` | System context diagrams |

## Syntax Quick Reference

### Flowchart
```mermaid
flowchart TD
    A[Start] --> B{Decision?}
    B -->|Yes| C[Action A]
    B -->|No| D[Action B]
    C --> E[End]
    D --> E
```

Direction: `TD` (top-down), `LR` (left-right), `BT` (bottom-top), `RL` (right-left).

Node shapes:
- `[text]` -- rectangle
- `(text)` -- rounded rectangle
- `{text}` -- diamond (decision)
- `([text])` -- stadium/pill
- `[[text]]` -- subroutine
- `[(text)]` -- cylinder (database)
- `((text))` -- circle

Subgraphs for grouping:
```mermaid
flowchart LR
    subgraph Frontend
        A[React App] --> B[API Client]
    end
    subgraph Backend
        C[API Server] --> D[(Database)]
    end
    B --> C
```

### Sequence Diagram
```mermaid
sequenceDiagram
    participant B as Browser
    participant S as Server
    participant DB as Database

    B->>S: GET /api/users
    activate S
    S->>DB: SELECT * FROM users
    DB-->>S: results
    S-->>B: 200 OK (JSON)
    deactivate S
```

Arrow types:
- `->>` solid with arrowhead
- `-->>` dashed with arrowhead
- `-x` solid with cross
- `-)` solid with open arrow (async)

### State Diagram
```mermaid
stateDiagram-v2
    [*] --> Created
    Created --> Active: approve
    Active --> Suspended: suspend
    Suspended --> Active: reactivate
    Active --> Revoked: revoke
    Revoked --> [*]
```

### ER Diagram
```mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ LINE_ITEM : contains
    PRODUCT ||--o{ LINE_ITEM : "is in"

    USER {
        int id PK
        string name
        string email
    }
    ORDER {
        int id PK
        int user_id FK
        date created_at
    }
```

### Mind Map
```mermaid
mindmap
  root((Project))
    Frontend
      React
      TypeScript
      Tailwind
    Backend
      Go
      PostgreSQL
      Redis
    Infrastructure
      AWS
      Kubernetes
      Terraform
```

### Gantt Chart
```mermaid
gantt
    title Project Roadmap
    dateFormat YYYY-MM-DD
    section Phase 1
        Design           :a1, 2026-01-01, 14d
        Implementation   :a2, after a1, 21d
    section Phase 2
        Testing          :b1, after a2, 14d
        Release          :milestone, after b1, 0d
```

## Styling

Mermaid supports limited theming. Use `%%{init: {...}}%%` directives:

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#EFF6FF', 'primaryBorderColor': '#2563EB', 'primaryTextColor': '#1E293B'}}}%%
flowchart TD
    A[Node] --> B[Node]
```

Available themes: `default`, `dark`, `forest`, `neutral`, `base` (customizable).

For most cases, use `default` or `neutral` theme -- they render well across platforms.

## Common Mistakes to Avoid

1. **Special characters in labels** -- wrap in quotes: `A["Label with (parens)"]`
2. **Semicolons in labels** -- use `#semi;` entity
3. **Long labels** -- Mermaid auto-wraps but results can be ugly. Keep labels under 30 characters.
4. **Too many nodes** -- Mermaid's auto-layout struggles above 20-25 nodes. Split into subgraphs or multiple diagrams.
5. **Complex styling inline** -- Mermaid is not SVG. Accept its styling limitations rather than fighting them.
6. **Mixing arrow styles** -- be consistent: `->>` for all requests, `-->>` for all responses.
7. **Forgetting `v2`** -- use `stateDiagram-v2` not `stateDiagram` for modern features.

## Output Format

Write Mermaid diagrams in fenced code blocks:

````markdown
```mermaid
flowchart TD
    A --> B
```
````

If saving to a file, use `.mmd` extension for standalone Mermaid files.

## Rendering

| Platform | Native Support |
|---|---|
| GitHub (README, issues, PRs) | Yes |
| GitLab (markdown) | Yes |
| Obsidian | Yes |
| Notion | Yes |
| VS Code (with extension) | Yes |
| Docusaurus | Yes (plugin) |
| Confluence | Via Mermaid plugin |

For offline rendering: `npx @mermaid-js/mermaid-cli mmdc -i diagram.mmd -o diagram.svg`

## Quality Checklist

Before presenting a Mermaid diagram:

- [ ] Correct diagram type keyword (`flowchart`, `sequenceDiagram`, etc.)
- [ ] Labels are concise (under 30 characters)
- [ ] Node count is under 25 (split if more)
- [ ] Consistent arrow styles for same relationship types
- [ ] Subgraphs used for logical grouping when 3+ related nodes exist
- [ ] Direction (TD/LR) matches the natural flow of the content
- [ ] Special characters properly escaped or quoted
