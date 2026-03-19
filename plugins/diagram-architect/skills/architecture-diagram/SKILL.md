---
name: architecture-diagram
description: Generate enterprise-grade architecture diagrams as SVG files. Use when the user asks to create, draw, or visualize any system architecture, sequence flow, threat model, state machine, or technical diagram.
---

# Architecture Diagram Skill

Generate enterprise-grade, whitepaper-quality diagrams as SVG files. Each diagram should look distinct — the right visual form for the content, not a templated layout.

**Output format: SVG only.** Do not use Excalidraw, Mermaid, or other intermediate formats.

## Workflow

### 1. Understand Intent

Before generating anything, establish:

- **What story does the diagram tell?** The answer determines the diagram type.
- **Who is the audience?** (executives, engineers, customers, mixed)
- **What are the key relationships?** (hierarchy, sequence, data flow, comparison, threat surface)
- **Are there source documents?** Read them — extract real terminology and structure.

### 2. Choose the Right Diagram Type

**This is the most important decision.** Do not default to a layered architecture stack. Each content type has a natural visual form:

| Content | Best Diagram Type | Why |
|---------|-------------------|-----|
| System components and layers | Layered architecture | Shows hierarchy and containment |
| Request/response lifecycle | Sequence diagram | Shows temporal ordering between actors |
| Data or process pipeline | Flow diagram (L→R or T→B) | Shows transformation steps |
| Attack surface / threat model | Threat flow with trust boundaries | Shows where controls intersect threats |
| Before/after or option comparison | Side-by-side comparison | Shows contrast |
| Central service with consumers | Hub and spoke | Shows radial relationships |
| Capability × category mapping | Matrix / grid | Shows coverage |
| State transitions | State machine | Shows conditions and transitions |
| Timeline with milestones | Roadmap / timeline | Shows progression |
| Org/team responsibility | Swimlane diagram | Shows who does what |
| Token/identity merging | Composition diagram | Shows inputs converging to output |
| Decision logic | Decision tree / flowchart | Shows branching paths |

If the content could work as multiple types, choose the one that best highlights the **primary relationship** the reader needs to understand. When in doubt, ask the user.

Consult `references/layout-patterns.md` for structural guidance and SVG construction patterns for each type.

### 3. Generate the SVG

Build the SVG using the design system in `references/svg-design-system.md`. **Read the "Common SVG Mistakes" section first** — it lists the most frequent errors. Core principles:

- **Always use `<defs>`** for gradients, shadows, markers — define once, reference everywhere
- **System fonts** — `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif`
- **Depth through gradients and shadows** — not flat fills
- **Generous whitespace** — padding is a design element
- **Visual hierarchy** through size, color weight, and elevation (shadows)

Beyond these fundamentals, **adapt the visual treatment to the diagram type**:

- A sequence diagram needs lifelines, activation bars, and message arrows — not rounded boxes with bullet points
- A threat model needs trust boundaries (dashed regions), threat actors, and control points — not a platform container
- A timeline needs a horizontal axis with markers — not stacked layers
- A state machine needs circles/rounded-rects for states and labeled transitions

The design system in the references is a **toolkit of components**, not a template. Select the right components for the diagram type.

### 4. Iterate

Present the SVG and ask for feedback. Common refinements: information density, visual emphasis, terminology alignment, color palette, annotations.

## Design Fundamentals

These apply to ALL diagram types:

| Principle | Application |
|-----------|------------|
| System fonts, not hand-drawn | Professional audience expects clean typography |
| Gradient fills for depth | Subtle top-to-bottom on major elements |
| Drop shadows for elevation | Distinguish foreground from background elements |
| Color-coded with legend | When using 3+ colors, include a legend |
| Consistent terminology | Labels must match the accompanying document exactly |
| `viewBox` for scaling | SVGs should scale cleanly to any container |

## Color Palette

Match to the organisation or context. If no brand context, use a professional blue-dominant palette.

- **Atlassian**: Blues (#0052CC, #2684FF), Green (#006644), Purple (#6554C0), Orange (#FF8B00), Teal (#00B8D9)
- **Neutral**: Navy (#1B2A4A), Steel (#4A5568), Slate (#64748B)
- Use color semantically: green=user/admin, blue=platform/core, purple=observability, orange=agents/AI, teal=external/3P, red=threats/deny

## Additional Resources

- **`references/svg-design-system.md`** — SVG toolkit: gradients, shadows, typography, icons, element construction patterns
- **`references/layout-patterns.md`** — Structural patterns for 12+ diagram types with SVG construction guidance
- **`assets/svg-components.svg`** — Reusable SVG `<defs>` block (gradients, shadows, markers, icons)

## Required Elements

Every SVG must include:
- `role="img"` on the root `<svg>` element
- `<title>` with a concise diagram name
- `<desc>` with a 1-2 sentence description
- These are accessibility requirements, not optional

## Complexity Check

Before generating, estimate element count:
- **3-6 elements**: Generate directly, compact canvas
- **7-15 elements**: Standard canvas, group related elements
- **16+ elements**: Ask the user — should we split this into multiple diagrams or raise the abstraction level?

If text is getting truncated or boxes overlap, the diagram is too dense. Simplify before adding detail.

## Anti-Patterns

- **Do not** default to layered-architecture for everything — choose the diagram type that fits the content
- **Do not** generate Excalidraw, Mermaid, or PlantUML
- **Do not** crowd text into boxes — if it doesn't fit, the box is too small
- **Do not** reuse the same layout across different diagrams — each should look distinct
- **Do not** add detail the user didn't ask for — match the requested abstraction level
