---
name: svg
description: Generate professional-quality diagrams as raw SVG. Use when the diagram-router selects SVG, or when the user needs pixel-precise control, custom visuals, threat models, comparisons, Venn diagrams, or any diagram type that other formats cannot handle well. SVG is the most expressive format -- unlimited visual possibilities, browser-native rendering.
---

# SVG Diagram Skill

Generate professional, whitepaper-quality diagrams as raw SVG. Each diagram should look distinct -- the right visual form for the content, not a templated layout.

**When to use SVG over other formats:**
- User wants maximum visual quality and custom design
- Diagram type lacks native support in Mermaid/D2 (threat models, comparisons, Venn, hub-spoke)
- Pixel-precise positioning is needed
- Output must render in any browser without JS dependencies
- User explicitly requests SVG

**When another format may be better:**
- Quick documentation diagrams that will live in GitHub markdown (Mermaid)
- Informal whiteboard-style sketches (Excalidraw)
- Architecture diagrams where auto-layout is preferred over manual positioning (D2)

Consult the **design-system** skill for color, typography, composition, and quality rules that apply across all formats.

## Workflow

### 1. Understand Intent

Before generating anything, establish:

- **What story does the diagram tell?** The answer determines the diagram type.
- **Who is the audience?** (executives, engineers, customers, mixed)
- **What are the key relationships?** (hierarchy, sequence, data flow, comparison, threat surface)
- **Are there source documents?** Read them -- extract real terminology and structure.

### 2. Choose the Right Diagram Type

**This is the most important decision.** Do not default to a layered architecture stack. Each content type has a natural visual form:

| Content | Best Diagram Type | Why |
|---------|-------------------|-----|
| System components and layers | Layered architecture | Shows hierarchy and containment |
| Request/response lifecycle | Sequence diagram | Shows temporal ordering between actors |
| Data or process pipeline | Flow diagram (LTR or TTB) | Shows transformation steps |
| Attack surface / threat model | Threat flow with trust boundaries | Shows where controls intersect threats |
| Before/after or option comparison | Side-by-side comparison | Shows contrast |
| Central service with consumers | Hub and spoke | Shows radial relationships |
| Capability x category mapping | Matrix / grid | Shows coverage |
| State transitions | State machine | Shows conditions and transitions |
| Timeline with milestones | Roadmap / timeline | Shows progression |
| Org/team responsibility | Swimlane diagram | Shows who does what |
| Token/identity merging | Composition diagram | Shows inputs converging to output |
| Decision logic | Decision tree / flowchart | Shows branching paths |
| Set overlaps | Venn diagram | Shows shared/unique characteristics |

If the content could work as multiple types, choose the one that best highlights the **primary relationship** the reader needs to understand. When in doubt, ask the user.

Consult `${CLAUDE_SKILL_DIR}/references/layout-patterns.md` for structural guidance and SVG construction patterns for each type.

### 3. Generate the SVG

Build the SVG using the component library in `${CLAUDE_SKILL_DIR}/references/svg-design-system.md`. **Read the "Common SVG Mistakes" section first** -- it lists the most frequent errors. Core principles:

- **Always use `<defs>`** for gradients, shadows, markers -- define once, reference everywhere
- **System fonts** -- `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif`
- **Depth through gradients and shadows** -- not flat fills
- **Generous whitespace** -- padding is a design element
- **Visual hierarchy** through size, color weight, and elevation (shadows)

Beyond these fundamentals, **adapt the visual treatment to the diagram type**:

- A sequence diagram needs lifelines, activation bars, and message arrows -- not rounded boxes with bullet points
- A threat model needs trust boundaries (dashed regions), threat actors, and control points -- not a platform container
- A timeline needs a horizontal axis with markers -- not stacked layers
- A state machine needs circles/rounded-rects for states and labeled transitions

The design system references are a **toolkit of components**, not a template. Select the right components for the diagram type.

### 4. Iterate

Present the SVG and ask for feedback. Common refinements: information density, visual emphasis, terminology alignment, color palette, annotations.

## SVG Document Structure

Every generated SVG follows this structure:

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}"
     font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif"
     role="img" aria-labelledby="diagramTitle diagramDesc">
  <title id="diagramTitle">{Concise diagram title}</title>
  <desc id="diagramDesc">{1-2 sentence description}</desc>
  <defs>
    <!-- Gradients, shadows, markers, patterns -->
  </defs>
  <rect width="{width}" height="{height}" fill="#FAFBFC"/>
  <!-- Content groups, ordered back-to-front -->
</svg>
```

### Required Accessibility Elements

- `role="img"` on the root `<svg>` element
- `<title>` with a concise diagram name
- `<desc>` with a 1-2 sentence description
- `aria-labelledby="diagramTitle diagramDesc"`

### Canvas Sizes

| Diagram Type | Recommended viewBox |
|---|---|
| Architecture | `0 0 1400 1000` |
| Sequence | `0 0 1400 800` to `0 0 1600 900` |
| Flow | `0 0 1400 600` to `0 0 1600 800` |
| Threat model | `0 0 1400 900` |
| Timeline | `0 0 1500 600` to `0 0 1500 700` |
| State machine | `0 0 1200 800` |
| Comparison | `0 0 1400 700` |
| Compact/embed | `0 0 1000 600` |

## SVG-Specific Rules

### Common Mistakes to Avoid

1. **DO NOT use CSS `style` attribute on `<svg>`** -- use SVG attributes directly. CSS `background` does not work when SVG is used as `<img>` source.
2. **DO NOT use `rgba()` in fill/stroke** -- use `fill="white" fill-opacity="0.18"` instead.
3. **DO NOT make diagonal gradients** unless intentional -- use `x1="0%" y1="0%" x2="0%" y2="100%"` for top-to-bottom.
4. **DO NOT use V-shaped arrowheads** (open chevrons) -- use filled triangles: `M0,0 L12,4 L0,8 L3,4 Z`.
5. **DO NOT use `text-transform` as SVG attribute** -- it is CSS-only. Write the text in uppercase directly.
6. **ALWAYS use background `<rect>`** -- not CSS background. `<rect width="{w}" height="{h}" fill="#FAFBFC"/>` as first child after `<defs>`.

### Arrow and Layout Clearance Rules

These rules prevent the most common SVG quality issues -- overlapping arrows, lines running through boxes, and labels colliding with elements.

**Arrow routing -- NEVER route through unrelated boxes:**
- Before drawing any arrow/line path, check whether it crosses through a box it is not connected to
- If a straight line would pass through an intermediate box, route AROUND it using L-shaped or Z-shaped paths with enough clearance
- Minimum clearance between an arrow path and any unrelated box edge: **20px**

**Parallel arrow separation:**
- When multiple arrows run parallel (same direction, nearby coordinates), maintain **minimum 30px separation** between them
- If two L-shaped routes share a vertical or horizontal segment, offset them visually so they are clearly distinct paths, not a single thick line
- Label each parallel path clearly so the reader can trace individual connections

**Arrow-to-label clearance:**
- Arrow labels must not overlap the arrow line itself -- offset labels **8-12px** perpendicular to the line
- Labels must not overlap any box they are not labeling -- check that label text bounds do not intersect nearby elements
- For vertical arrows, place labels to the left or right (not centered on the line where they become unreadable)

**Box-to-box clearance:**
- Minimum gap between boxes at the same level: **40px** (enough for arrows to route between them)
- Minimum gap between a container boundary (trust boundary, group box) and its contained elements: **20px** on all sides
- Dashed boundary indicators (like PCI DSS scope) must fully enclose their target with **15px+ padding** on all sides -- never clip the edge of a box

**Annotation and badge placement:**
- Security control badges (shield icons, TLS/AUTH/WAF pills) should be placed ON the boundary line between zones, not floating in space
- Badges must not overlap arrow paths or box labels
- If a badge would collide with an arrow, move the badge along the boundary to a clear spot

**Self-check before output:**
After constructing the SVG, mentally trace each arrow path and verify:
1. Does this line pass through any box it is not connected to? If yes, reroute.
2. Is this line visually distinguishable from nearby parallel lines? If no, add separation.
3. Does any label overlap a line, box, or other label? If yes, reposition.
4. Do all container/scope boundaries fully enclose their targets with padding? If no, expand.

### Token Budget Awareness

SVG is token-expensive (~24x more tokens than Mermaid for equivalent diagrams). Manage this by:

- Reusing `<defs>` aggressively -- define gradients, shadows, markers once
- Using `<use href="#id">` for repeated elements (icons, patterns)
- Keeping element count within complexity limits
- Preferring simple geometric shapes over complex paths where possible
- Using `<symbol>` for icon libraries rather than inline paths

## Additional Resources

- **`${CLAUDE_SKILL_DIR}/references/svg-design-system.md`** -- SVG toolkit: gradients, shadows, typography, icons, element construction patterns
- **`${CLAUDE_SKILL_DIR}/references/layout-patterns.md`** -- Structural patterns for 12+ diagram types with SVG construction guidance
- **`${CLAUDE_SKILL_DIR}/assets/svg-components.svg`** -- Reusable SVG `<defs>` block (gradients, shadows, markers, icons)

## Anti-Patterns

- **Do not** default to layered-architecture for everything -- choose the diagram type that fits the content
- **Do not** crowd text into boxes -- if it does not fit, the box is too small
- **Do not** reuse the same layout across different diagrams -- each should look distinct
- **Do not** add detail the user did not ask for -- match the requested abstraction level
- **Do not** skip the `<defs>` block -- inline styles waste tokens and break consistency
