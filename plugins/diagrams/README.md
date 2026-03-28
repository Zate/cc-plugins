# diagrams

Generate amazing diagrams using text-based formats. Supports 4 output formats, 20+ diagram types, and a shared design system for professional quality.

## Usage

Just describe what you want. The plugin automatically selects the best format and diagram type:

```
Draw a sequence diagram showing the OAuth2 authorization code flow
Create an architecture diagram for our microservices platform
Sketch a quick whiteboard of the deployment topology
Show the database schema for the e-commerce system
```

Or specify a format explicitly:

```
Create a Mermaid flowchart for the CI/CD pipeline
Draw this as an SVG with custom styling
Make an Excalidraw diagram I can edit later
Generate a D2 diagram of the network topology
```

## Output Formats

| Format | Strength | Best For |
|--------|----------|---------|
| **SVG** (default) | Maximum visual quality, browser-native | Custom visuals, threat models, comparisons, any diagram type |
| **Excalidraw** | Hand-drawn aesthetic, editable | Whiteboard sketches, brainstorming, collaborative visuals |
| **Mermaid** | Renders in GitHub/GitLab natively | Documentation, quick diagrams, markdown-embedded |
| **D2** | Clean auto-layout, nested containers | Architecture diagrams, network/infra, deployment |

## Diagram Types

| Type | Supported Formats |
|------|-------------------|
| Architecture (layered, C4) | SVG, D2, Mermaid |
| Sequence diagrams | SVG, Mermaid, D2, Excalidraw |
| Flowcharts / process flows | SVG, Mermaid, D2, Excalidraw |
| State machines | SVG, Mermaid, D2 |
| ER diagrams | Mermaid, D2 |
| Class / UML diagrams | Mermaid, D2 |
| Gantt / timelines | Mermaid |
| Mind maps | Mermaid, Excalidraw |
| Threat models / DFD | SVG |
| Comparisons (side-by-side) | SVG, Excalidraw |
| Hub and spoke | SVG, D2 |
| Decision trees | SVG, Mermaid |
| Dependency graphs | D2, Mermaid |
| Network / infrastructure | D2, SVG |
| Venn diagrams | SVG |
| Sankey diagrams | Mermaid |
| Org charts / trees | Mermaid, D2 |

## Skills

| Skill | Purpose |
|-------|---------|
| `diagram-router` | Auto-selects format and diagram type from user intent |
| `svg` | Raw SVG generation with full design system |
| `mermaid` | Mermaid syntax generation |
| `excalidraw` | Excalidraw JSON via MCP tools with streaming animations |
| `d2` | D2 declarative diagram scripting |
| `design-system` | Shared color theory, composition, typography, accessibility |

## Design System

All formats share a consistent design system:

- **Semantic colors**: blue=platform, green=success, red=security, purple=compute, amber=warning, teal=external
- **WCAG AA accessible**: 4.5:1 contrast for text, color-blind safe palettes
- **Typography hierarchy**: title > group > node > edge > annotation
- **Complexity guidance**: max 15-20 elements per diagram, split beyond that
- **Quality checklist**: consistency, alignment, spacing, legends

## Accessibility

- SVGs include `<title>`, `<desc>`, and `role="img"` for screen readers
- Color is never the sole differentiator -- shapes, labels, and icons reinforce meaning
- WCAG AA contrast ratios for all text on backgrounds
- Color-blind safe palettes (IBM, Wong) available as alternatives

## Requirements

| Format | Requires |
|--------|----------|
| SVG | Nothing (browser-native) |
| Mermaid | Nothing (renders in GitHub/GitLab) or `npx @mermaid-js/mermaid-cli` for CLI |
| Excalidraw | Excalidraw MCP server (`mcp__claude_ai_Excalidraw`) -- **not included with this plugin**, may be available as an Anthropic-provided MCP in some Claude Code environments. Falls back to SVG if unavailable. |
| D2 | `d2` CLI binary ([install](https://d2lang.com/)) |
