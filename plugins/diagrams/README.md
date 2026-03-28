# diagrams

Generate amazing diagrams using text-based formats. Supports SVG, Mermaid, Excalidraw, D2, and more. 12+ diagram types with a full design system.

## Usage

Ask Claude to create a diagram:

```
Draw a sequence diagram showing the OAuth2 authorization code flow
Create a layered architecture diagram for our microservices platform
Visualize the threat model for the payment processing system
```

The skill chooses the right diagram type based on content, not a default template.

## Diagram Types

| Type | Use For |
|------|---------|
| Layered Architecture | System components, platform stacks, infrastructure |
| Sequence Diagram | Request/response flows, API chains, handshakes |
| Flow Diagram | Data pipelines, process steps, token flows |
| Threat Model / DFD | Security analysis, attack surface, trust boundaries |
| Swimlane | Multi-team processes, responsibility mapping |
| State Machine | Entity lifecycles, status transitions |
| Composition | Token aggregation, identity merging |
| Timeline / Roadmap | Implementation phases, milestones |
| Hub and Spoke | Central services with consumers |
| Comparison | Before/after, option A vs B |
| Matrix / Grid | Capability mapping, RACI charts |
| Decision Tree | Decision logic, troubleshooting flows |

## Design System

Diagrams use an Atlassian-inspired design system:

- **Gradients** for depth (not flat fills)
- **Three-tier shadows** for elevation hierarchy
- **System fonts** for clean, professional typography
- **Semantic colors**: blue=platform, green=admin, purple=observability, orange=AI, teal=external, red=threats
- **10 reusable SVG icons**: shield, key, lock, eye, gear, globe, database, lightning, users, checkmark

## Output

Pure SVG — no Mermaid, Excalidraw, or PlantUML intermediaries. Diagrams scale cleanly via `viewBox` and render in any browser or document.

## Accessibility

Generated SVGs include `<title>` and `<desc>` elements for screen readers. High-contrast color combinations meet WCAG AA requirements for text readability.

## Complexity Guidance

For best results:
- **Simple** (3-6 elements): Compact canvas (1000x600), single diagram type
- **Medium** (7-15 elements): Standard canvas (1400x1000), clear grouping
- **Complex** (16+ elements): Consider splitting into multiple diagrams or using a higher-level view with drill-downs

SVGs with 20+ boxes and extensive labels can exceed 15KB. If a diagram feels crowded, it's too complex for a single view.
