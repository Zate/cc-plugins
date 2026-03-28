---
name: design-system
description: Shared design principles for all diagram formats -- color theory, composition, typography, accessibility, and quality standards. Referenced by format-specific skills (svg, mermaid, excalidraw, d2). Use when generating any visual diagram to ensure professional quality.
---

# Diagram Design System

Universal design principles for professional-quality diagrams. These rules apply regardless of output format (SVG, Mermaid, Excalidraw, D2). Format-specific skills handle syntax; this skill handles aesthetics and composition.

## Color

### Palette Size

Use **3-5 colors plus grays** per diagram. Maximum 7 distinct colors. Beyond that, humans cannot distinguish and remember meanings. If you need more categories, use shade variations within a hue family rather than adding new hues.

### Semantic Color Conventions

Use color to convey meaning, not decoration. These associations are widely understood in software engineering:

| Concept | Color | Light Theme Hex | Use For |
|---------|-------|-----------------|---------|
| Platform / Core | Blue | `#2563EB` | Primary system components, APIs, services |
| Data / Storage | Blue (darker) | `#1E40AF` | Databases, data stores, caches |
| Success / Healthy | Green | `#16A34A` | Active states, successful flows, admin |
| Security / Error | Red | `#DC2626` | Threats, errors, denied paths, trust boundaries |
| Warning / Caution | Amber | `#D97706` | Deprecations, risks, attention needed |
| Compute / Processing | Purple | `#7C3AED` | Processing nodes, AI/ML, observability |
| External / Third-Party | Teal | `#0891B2` | External systems, integrations, users |
| Inactive / Deprecated | Gray | `#6B7280` | Disabled, archived, low-priority |
| Infrastructure | Slate | `#475569` | Foundational platform, network |

### Color-Blind Safe Palette

8% of males have color vision deficiency. Always follow these rules:

1. **Never rely on color alone** -- pair with shape, pattern, label, or icon
2. **Avoid red-green adjacency** without additional differentiation
3. **Preferred safe palettes:**
   - IBM: `#648FFF`, `#785EF0`, `#DC267F`, `#FE6100`, `#FFB000`
   - Wong: `#E69F00`, `#56B4E9`, `#009E73`, `#F0E442`, `#0072B2`, `#D55E00`, `#CC79A7`

### Contrast (WCAG AA)

- **Normal text on backgrounds**: contrast ratio >= 4.5:1
- **Large text** (18px+ or 14px bold): >= 3:1
- **Non-text elements** (borders, icons, chart segments): >= 3:1 against adjacent colors
- **White text** on gradient fills (#0052CC, #006644, #5243AA) meets AA
- **Never** place mid-tone text on mid-tone backgrounds

### Light vs Dark Theme

Design for **light theme by default** (white/light gray background). Most documentation, presentations, and print uses light backgrounds.

| Element | Light Theme | Dark Theme |
|---------|-------------|------------|
| Background | `#FFFFFF` or `#F8FAFC` | `#0F172A` or `#1E293B` |
| Primary text | `#1E293B` | `#F1F5F9` |
| Secondary text | `#64748B` | `#94A3B8` |
| Node fill | Light pastels | Muted darks |
| Node stroke | Medium tones | Slightly brighter |
| Connectors | `#94A3B8` | `#475569` |

---

## Layout & Composition

### Flow Direction

- **Left-to-right (LTR)**: Data flow, process pipelines, request lifecycles
- **Top-to-bottom (TTB)**: Architecture layers (user at top, infrastructure at bottom), hierarchies
- **Never mix directions** in the same diagram without explicit visual cues
- Arrow direction must match flow direction

### Spacing

| Element | Spacing |
|---------|---------|
| Between peer nodes | 40-60px |
| Padding inside nodes | 12-16px |
| Padding inside groups/containers | 20-30px |
| Gap between node and connector label | 8px |
| Edge routing clearance from unconnected nodes | >= 10px |
| Diagram margins | 40px+ |

**Rule: All gaps of the same semantic type must be identical.** If two peer nodes are 50px apart, all peer nodes at that level must be 50px apart.

### Alignment

Nodes should snap to an implicit grid. Consistent x/y positioning signals intentional design. Center-align or left-align text consistently within a diagram -- never mix alignment styles for the same element type.

### Grouping and Containment

- **Bounding boxes** (rounded rectangles with light fill) for logical groupings
- **Group labels**: top-left corner, inside the boundary
- **Maximum 3 levels of nesting** -- beyond that, split into separate diagrams
- **Dashed borders** for logical/virtual groupings; solid borders for concrete/physical boundaries
- Group fill color should be lighter/more transparent than contained node fills

### Complexity Management

| Elements | Action |
|----------|--------|
| 3-6 | Generate directly, compact canvas |
| 7-15 | Standard canvas, clear grouping |
| 16-20 | Consider splitting; ask user if unclear |
| 20+ | Must split into overview + detail diagrams |

Additional split signals:
- More than 3 nesting levels
- Edge crossings exceed ~30% of total connections
- Diagram answers two different questions (make two diagrams)

**Splitting strategy:**
1. Overview diagram: top-level components, max 7-10 nodes
2. Detail diagrams: one per major component
3. Consistent styling across overview and detail for cross-referencing

---

## Typography

### Size Hierarchy

| Element | Size | Weight |
|---------|------|--------|
| Diagram title | 20-24px | Bold (700) |
| Group/boundary label | 14-16px | Semi-bold (600) |
| Node label | 12-14px | Medium/Semi-bold (500-600) |
| Edge/connector label | 10-12px | Regular (400) |
| Annotation/note | 10-11px | Regular/Italic |
| Legend text | 10-12px | Regular (400) |

**Rules:**
- Maintain >= 2px size difference between hierarchy levels
- Never go below 10px -- it becomes illegible
- Title should be 1.5-2x the size of node labels

### Font Usage

- **Sans-serif** (primary): `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif`
- **Monospace** (code/technical): `'SF Mono', 'Cascadia Code', Consolas, 'Liberation Mono', Menlo, 'Courier New', monospace`
- **Bold**: Node names, group titles, key terms (scannability)
- **Italic**: Annotations, optional metadata (signals "supplementary")
- **Monospace**: Code identifiers, ports, API paths, config values

### Text in Nodes

- Maximum ~20 characters per node label; prefer meaningful abbreviation over truncation
- Maximum 2-3 lines inside a node
- If more text needed, use annotation/tooltip outside the node

---

## Visual Quality Markers

### What Makes a Diagram Look "Designed"

1. **Grid alignment** -- consistent x/y positioning
2. **Visual hierarchy** -- size, color, and weight variation between element types
3. **Minimal edge crossings** -- reroute or restructure
4. **Consistent spacing** -- equal gaps between peer elements
5. **Breathing room** -- generous whitespace, especially at margins
6. **Title and legend** -- titled diagrams look finished; legends when color carries meaning

### Consistency Rules (Non-Negotiable)

1. **Same type = same style**: All databases look identical, all services look identical
2. **Same level = same size**: Peer components at the same level have the same dimensions
3. **Same relationship = same line style**: All "calls" arrows look the same
4. **Same semantic = same color**: Blue means "data" everywhere, not just in one area
5. **Alignment**: Nodes snap to a grid
6. **Spacing**: Equal gaps between peer elements, predictable padding

### Anti-Patterns to Avoid

1. **Rainbow soup**: Too many unrelated colors with no semantic meaning
2. **Hairball**: Too many crossing connections -- split the diagram
3. **Giant node**: One node 3x larger without semantic reason
4. **Floating labels**: Text near but not clearly associated with any element
5. **Inconsistent arrows**: Mixing styles without defined meaning
6. **Tiny text on large canvas**: Zoomed out too far to read
7. **3D effects**: Perspective, 3D boxes -- adds noise without information
8. **Color without meaning**: Using color decoratively rather than semantically
9. **Text overflow**: Labels that extend beyond their container boundaries

### Effects: When They Help vs Hurt

| Effect | Use When | Avoid When |
|--------|----------|------------|
| **Gradient** | Subtle on primary elements for depth | Applied uniformly to everything |
| **Drop shadow** | Lifting 1-2 key elements above the plane | Applied to every node |
| **Border/stroke** | Defining boundaries, showing containment | Thick borders on everything |
| **Border radius** | 4-8px for modern look | Fully circular for non-circular concepts |
| **Opacity** | Fading background/inactive elements (0.3-0.5) | Fading important elements |

---

## Diagram Type Selection

When the user describes what they want but does not specify a diagram type, select based on the primary relationship they need to communicate:

| User Intent | Best Diagram Type |
|---|---|
| "How does the system work overall?" | Architecture (layered) or C4 Context |
| "How do these services communicate?" | Sequence diagram |
| "Walk me through this process" | Flowchart |
| "Who handles each step?" | Swimlane |
| "What states can this be in?" | State machine |
| "Show the database schema" | ER diagram |
| "What depends on what?" | Dependency graph |
| "Compare these options" | Comparison (side-by-side) or table |
| "Show the project timeline" | Gantt / timeline |
| "What's the security boundary?" | Threat model / DFD |
| "Brainstorm / map this topic" | Mind map |
| "Show traffic distribution" | Sankey diagram |
| "What overlaps between these?" | Venn diagram |
| "What's the decision logic?" | Decision tree |
| "Central service with consumers" | Hub and spoke |
| "How is it deployed?" | Deployment diagram |
| "Org structure / hierarchy" | Tree / org chart |

If the content could work as multiple types, choose the one that highlights the **primary relationship** the reader needs to understand. When genuinely ambiguous, ask the user.

---

## Quality Checklist

Before presenting any diagram, verify:

- [ ] Title present and descriptive
- [ ] Legend present if 3+ colors carry meaning
- [ ] Text readable (no truncation, no overlap, minimum 10px)
- [ ] Consistent spacing between peer elements
- [ ] Consistent styling for same-type elements
- [ ] Color used semantically (not decoratively)
- [ ] Maximum element count not exceeded for the diagram type
- [ ] Flow direction is consistent throughout
- [ ] Accessibility: color is not the sole differentiator
