# SVG Design System

Toolkit of reusable SVG components for enterprise-grade diagrams. These are building blocks to select from — not a template to follow. Choose the components that fit the diagram type.

## SVG Document Structure

Every generated diagram follows this structure:

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}"
     font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif">
  <defs>
    <!-- Gradients, shadows, markers, patterns, icons -->
  </defs>

  <!-- Background -->
  <rect width="{width}" height="{height}" fill="#FAFBFC"/>

  <!-- Content groups, ordered back-to-front -->
</svg>
```

**Standard canvas sizes:**
- Architecture overview: `viewBox="0 0 1400 1000"`
- Flow diagram: `viewBox="0 0 1600 800"`
- Comparison: `viewBox="0 0 1400 700"`
- Compact/embed: `viewBox="0 0 1000 600"`

## Typography Scale

| Use | Size | Weight | Letter-spacing | Example |
|-----|------|--------|----------------|---------|
| Main title | 32-36px | 700 | -0.5px | "Enterprise Trust Platform" |
| Subtitle | 18-20px | 400 | 0 | "Architecture Vision" |
| Section label | 11-12px | 700 | 1.5-2px | "ENTERPRISE TRUST PLATFORM" |
| Box title | 17-20px | 600 | 0 | "Customer Identity Platform" |
| Box description | 13px | 400 | 0 | "Human & AI authentication" |
| Annotation | 12px | 400 | 0 | "Audit trail · Agent attribution" |
| Legend | 11px | 400 | 0 | "Atlassian Products" |
| Fine print | 9px | 400 | 0 | "© 2026" |

**Rules:**
- All text uses `text-anchor="middle"` for centered elements, `text-anchor="start"` for left-aligned
- Use `font-style="italic"` sparingly — only for taglines or quotes
- Category/section labels use uppercase + letter-spacing for visual distinction
- Apply `opacity="0.85"` to description text and `opacity="0.65"` to tertiary/fine detail text within dark boxes

## Gradient Definitions

Gradients give depth. Always use linear gradients, top-to-bottom (y1=0%, y2=100%).

**Pattern: Start ~15% lighter than end color.**

```xml
<!-- Primary blue (for main content boxes) -->
<linearGradient id="blueGrad" x1="0%" y1="0%" x2="0%" y2="100%">
  <stop offset="0%" stop-color="#0065FF"/>
  <stop offset="100%" stop-color="#0747A6"/>
</linearGradient>

<!-- Green (for admin/user elements) -->
<linearGradient id="greenGrad" x1="0%" y1="0%" x2="0%" y2="100%">
  <stop offset="0%" stop-color="#00A76F"/>
  <stop offset="100%" stop-color="#006644"/>
</linearGradient>

<!-- Purple (for observability/monitoring) -->
<linearGradient id="purpleGrad" x1="0%" y1="0%" x2="0%" y2="100%">
  <stop offset="0%" stop-color="#8777D9"/>
  <stop offset="100%" stop-color="#5243AA"/>
</linearGradient>

<!-- Product category gradients -->
<linearGradient id="prodBlue" x1="0%" y1="0%" x2="0%" y2="100%">
  <stop offset="0%" stop-color="#4C9AFF"/>
  <stop offset="100%" stop-color="#2684FF"/>
</linearGradient>

<linearGradient id="prodOrange" x1="0%" y1="0%" x2="0%" y2="100%">
  <stop offset="0%" stop-color="#FFB74D"/>
  <stop offset="100%" stop-color="#FF8B00"/>
</linearGradient>

<linearGradient id="prodTeal" x1="0%" y1="0%" x2="0%" y2="100%">
  <stop offset="0%" stop-color="#4DD0E1"/>
  <stop offset="100%" stop-color="#00B8D9"/>
</linearGradient>
```

**For container backgrounds**, use a two-stop gradient between near-white tones:

```xml
<linearGradient id="containerGrad" x1="0%" y1="0%" x2="0%" y2="100%">
  <stop offset="0%" stop-color="#F4F7FC"/>
  <stop offset="100%" stop-color="#E9EFF8"/>
</linearGradient>
```

**For side annotation arrows**, use a three-stop gradient that fades in:

```xml
<linearGradient id="arrowFadeGrad" x1="0%" y1="0%" x2="0%" y2="100%">
  <stop offset="0%" stop-color="#0052CC" stop-opacity="0.15"/>
  <stop offset="50%" stop-color="#0052CC" stop-opacity="0.6"/>
  <stop offset="100%" stop-color="#0052CC"/>
</linearGradient>
```

## Shadow Filters

Three levels of elevation:

```xml
<!-- Small shadow (sub-items, cards) -->
<filter id="shadowSm" x="-2%" y="-4%" width="104%" height="112%">
  <feDropShadow dx="0" dy="1" stdDeviation="3" flood-color="#172B4D" flood-opacity="0.08"/>
</filter>

<!-- Medium shadow (primary boxes, pillars) -->
<filter id="shadow" x="-4%" y="-4%" width="108%" height="112%">
  <feDropShadow dx="0" dy="3" stdDeviation="6" flood-color="#172B4D" flood-opacity="0.12"/>
</filter>

<!-- Large shadow (floating overlays, hero elements) -->
<filter id="shadowLg" x="-3%" y="-3%" width="106%" height="110%">
  <feDropShadow dx="0" dy="4" stdDeviation="10" flood-color="#172B4D" flood-opacity="0.15"/>
</filter>
```

**Usage:** Apply via `filter="url(#shadow)"` on `<rect>` or `<g>` elements. Group (`<g>`) a rect + text together and apply shadow to the group for clean rendering.

## Arrow Markers

```xml
<marker id="arrowHead" markerWidth="12" markerHeight="8" refX="6" refY="4" orient="auto">
  <path d="M0,0 L12,4 L0,8 L3,4 Z" fill="#0052CC"/>
</marker>
```

Create colour variants by duplicating with different `fill` values. Apply via `marker-end="url(#arrowHead)"` on `<line>` or `<path>` elements.

**For dashed connecting lines** between related elements:
```xml
<line x1="..." y1="..." x2="..." y2="..." stroke="#DFE1E6" stroke-width="1" stroke-dasharray="3,3" opacity="0.5"/>
```

**For composition/interop connectors** between sibling elements:
```xml
<line x1="..." y1="..." x2="..." y2="..." stroke="white" stroke-width="1.5" stroke-dasharray="4,3" opacity="0.3"/>
<circle cx="{midpoint}" cy="{midpoint}" r="3" fill="#4C9AFF" opacity="0.5"/>
```

## Background Patterns

Subtle dot pattern for container regions:

```xml
<pattern id="dots" width="24" height="24" patternUnits="userSpaceOnUse">
  <circle cx="12" cy="12" r="0.7" fill="#0052CC" opacity="0.07"/>
</pattern>
```

Apply as a second `<rect>` layer over the container fill:
```xml
<rect x="..." y="..." width="..." height="..." rx="14" fill="url(#containerGrad)" stroke="#B3D4FF" stroke-width="2"/>
<rect x="..." y="..." width="..." height="..." rx="14" fill="url(#dots)"/>
```

## Icon Symbols

Define as `<symbol>` in `<defs>`, use via `<use href="#iconName" x="..." y="..." width="28" height="28"/>`.

Icons should be **subtle** — small (24-28px), partially transparent (`opacity="0.4"` on the `<use>` element), positioned in the top-left corner of their parent box. They reinforce meaning without demanding attention.

See `assets/svg-components.svg` for the full icon library.

## Box Construction Patterns

### Primary content box (pillar, service, component)

```xml
<g filter="url(#shadow)">
  <rect x="{x}" y="{y}" width="{w}" height="{h}" rx="10" fill="url(#blueGrad)"/>
  <use href="#iconKey" x="{x+10}" y="{y+8}" width="28" height="28" opacity="0.4"/>
  <text x="{x+25}" y="{y+32}" font-size="18" font-weight="600" fill="white">Title Line 1</text>
  <text x="{x+25}" y="{y+54}" font-size="18" font-weight="600" fill="white">Title Line 2</text>
  <line x1="{x+25}" y1="{y+66}" x2="{x+125}" y2="{y+66}" stroke="white" stroke-width="1" opacity="0.25"/>
  <text x="{x+25}" y="{y+88}" font-size="13" fill="white" opacity="0.85">Description line 1</text>
  <text x="{x+25}" y="{y+108}" font-size="13" fill="white" opacity="0.85">Description line 2</text>
  <text x="{x+25}" y="{y+128}" font-size="13" fill="white" opacity="0.65">Tertiary detail</text>
</g>
```

### Sub-item box (within a container)

```xml
<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="6" fill="white" stroke="#00875A" stroke-width="1" opacity="0.9"/>
<text x="{x + w/2}" y="{y + h/2 + 5}" text-anchor="middle" font-size="13" font-weight="500" fill="#006644">Label</text>
```

### Container region (grouping box)

```xml
<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="10" fill="url(#adminExpGrad)" stroke="#00875A" stroke-width="1.5" filter="url(#shadowSm)"/>
<text x="{x+25}" y="{y+24}" font-size="16" font-weight="600" fill="#006644">Container Title</text>
```

### Product/consumer box (small, colored)

```xml
<rect x="{x}" y="{y}" width="130" height="50" rx="8" fill="url(#prodBlue)"/>
<text x="{x+65}" y="{y+30}" text-anchor="middle" font-size="14" font-weight="600" fill="white">Product Name</text>
```

## Color Tokens

### Atlassian Design System

| Token | Value | Use |
|-------|-------|-----|
| Blue 700 | #0052CC | Primary brand, headings |
| Blue 400 | #2684FF | Secondary blue, links |
| Blue 100 | #DEEBFF | Light backgrounds |
| Green 600 | #006644 | Admin/user elements |
| Green 100 | #E3FCEF | Admin container backgrounds |
| Purple 500 | #6554C0 | Observability, monitoring |
| Purple 100 | #EAE6FF | Purple container backgrounds |
| Orange 500 | #FF8B00 | AI/agent elements |
| Teal 500 | #00B8D9 | Third-party, integrations |
| Neutral 800 | #172B4D | Body text |
| Neutral 500 | #505F79 | Secondary text |
| Neutral 200 | #DFE1E6 | Borders, dividers |
| Neutral 30 | #FAFBFC | Page background |

### Semantic Colours

| Meaning | Primary | Gradient start | Gradient end |
|---------|---------|----------------|--------------|
| Platform/core | Blue | #0065FF | #0747A6 |
| User/admin | Green | #00A76F | #006644 |
| Monitoring | Purple | #8777D9 | #5243AA |
| Warning/risk | Orange | #FFB74D | #FF8B00 |
| External/3P | Teal | #4DD0E1 | #00B8D9 |
| Error/deny | Red | #FF6B6B | #DE350B |
| Success/allow | Green | #69DB7C | #00875A |

## Spacing and Padding

| Element | Internal padding | Gap between siblings | Border radius |
|---------|-----------------|---------------------|---------------|
| Platform container | 25px | — | 14px |
| Primary box | 25px left, 12px top | 25-30px | 10px |
| Sub-item box | 10px | 12-15px | 6px |
| Product box | centered text | 8-12px | 8px |
| Legend item | 6px gap dot-to-text | 30px between items | — |

## Full-Length Side Arrows

For directional flow annotations along the sides of the diagram:

```xml
<!-- Pill-shaped background -->
<rect x="{x-26}" y="{top}" width="52" height="{height}" rx="26" fill="url(#arrowFadeGrad)" opacity="0.12"/>

<!-- Arrow line with marker -->
<line x1="{x}" y1="{top+offset}" x2="{x}" y2="{bottom-offset}" stroke="#0052CC" stroke-width="2.5" marker-end="url(#arrowHead)" opacity="0.7"/>

<!-- Label (above arrow) -->
<text x="{x}" y="{top+30}" text-anchor="middle" font-size="12" font-weight="600" fill="#0052CC" letter-spacing="0.5">LABEL</text>
<text x="{x}" y="{top+46}" text-anchor="middle" font-size="12" font-weight="600" fill="#0052CC" letter-spacing="0.5">LINE 2</text>
```

---

## Diagram-Type-Specific Elements

The elements above (boxes, arrows, shadows) are universal. Below are elements specific to certain diagram types. Only use these when building that diagram type.

### Sequence Diagram Elements

**Lifeline (vertical dashed line from participant header):**
```xml
<line x1="{cx}" y1="{headerBottom}" x2="{cx}" y2="{diagramBottom}" stroke="#DFE1E6" stroke-width="1.5" stroke-dasharray="6,4"/>
```

**Participant header (top of lifeline):**
```xml
<g filter="url(#shadow)">
  <rect x="{x}" y="{y}" width="180" height="50" rx="8" fill="url(#blueGrad)"/>
  <text x="{x+90}" y="{y+30}" text-anchor="middle" font-size="15" font-weight="600" fill="white">Participant</text>
</g>
```

**Activation bar (shows active processing on a lifeline):**
```xml
<rect x="{cx-5}" y="{activationStart}" width="10" height="{duration}" rx="3" fill="#0052CC" opacity="0.15"/>
```

**Synchronous message (solid arrow):**
```xml
<line x1="{fromCx}" y1="{msgY}" x2="{toCx}" y2="{msgY}" stroke="#505F79" stroke-width="1.5" marker-end="url(#arrowGray)"/>
<text x="{midX}" y="{msgY-8}" text-anchor="middle" font-size="12" font-weight="500" fill="#172B4D">message label</text>
```

**Response message (dashed arrow):**
```xml
<line x1="{fromCx}" y1="{msgY}" x2="{toCx}" y2="{msgY}" stroke="#505F79" stroke-width="1.5" stroke-dasharray="6,3" marker-end="url(#arrowGray)"/>
<text x="{midX}" y="{msgY-8}" text-anchor="middle" font-size="12" fill="#505F79" font-style="italic">response</text>
```

**Step number badge on a message:**
```xml
<circle cx="{x}" cy="{msgY}" r="10" fill="#0052CC"/>
<text x="{x}" y="{msgY+4}" text-anchor="middle" font-size="9" font-weight="700" fill="white">1</text>
```

### Threat Model / DFD Elements

**Trust boundary (dashed region):**
```xml
<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="16" fill="#FFF5F5" fill-opacity="0.3" stroke="#DE350B" stroke-width="2" stroke-dasharray="10,6"/>
<text x="{x+15}" y="{y+20}" font-size="11" font-weight="700" fill="#DE350B" letter-spacing="1.5">TRUST BOUNDARY</text>
```

**Data store (open-top rectangle / database shape):**
```xml
<g filter="url(#shadowSm)">
  <rect x="{x}" y="{y}" width="{w}" height="{h}" rx="0" fill="#FFF8E1" stroke="#FF8B00" stroke-width="1.5"/>
  <line x1="{x}" y1="{y+24}" x2="{x+w}" y2="{y+24}" stroke="#FF8B00" stroke-width="1"/>
  <text x="{x+w/2}" y="{y+16}" text-anchor="middle" font-size="12" font-weight="600" fill="#FF8B00">Data Store</text>
</g>
```

**Threat actor (external, untrusted):**
```xml
<g filter="url(#shadow)">
  <rect x="{x}" y="{y}" width="{w}" height="{h}" rx="4" fill="url(#redGrad)"/>
  <text x="{x+w/2}" y="{y+h/2+5}" text-anchor="middle" font-size="14" font-weight="600" fill="white">Threat Actor</text>
</g>
```

**Control point / security checkpoint:**
```xml
<g>
  <circle cx="{x}" cy="{y}" r="14" fill="#006644" filter="url(#shadowSm)"/>
  <use href="#iconShield" x="{x-9}" y="{y-9}" width="18" height="18"/>
</g>
```

### State Machine Elements

**State (pill shape):**
```xml
<g filter="url(#shadow)">
  <rect x="{x}" y="{y}" width="160" height="50" rx="25" fill="url(#blueGrad)"/>
  <text x="{x+80}" y="{y+30}" text-anchor="middle" font-size="14" font-weight="600" fill="white">Active</text>
</g>
```

**Terminal state (double border):**
```xml
<g filter="url(#shadow)">
  <rect x="{x}" y="{y}" width="160" height="50" rx="25" fill="url(#redGrad)"/>
  <rect x="{x+3}" y="{y+3}" width="154" height="44" rx="22" fill="none" stroke="white" stroke-width="1.5" opacity="0.4"/>
  <text x="{x+80}" y="{y+30}" text-anchor="middle" font-size="14" font-weight="600" fill="white">Revoked</text>
</g>
```

**Initial state marker:**
```xml
<circle cx="{x}" cy="{y}" r="8" fill="#172B4D"/>
```

**Transition (curved arrow with label):**
```xml
<path d="M{x1},{y1} C{cx1},{cy1} {cx2},{cy2} {x2},{y2}" fill="none" stroke="#505F79" stroke-width="1.5" marker-end="url(#arrowGray)"/>
<text x="{labelX}" y="{labelY}" text-anchor="middle" font-size="11" fill="#505F79">transition label</text>
```

### Timeline Elements

**Timeline axis:**
```xml
<line x1="{left}" y1="{axisY}" x2="{right}" y2="{axisY}" stroke="#DFE1E6" stroke-width="3" stroke-linecap="round"/>
```

**Milestone marker:**
```xml
<circle cx="{x}" cy="{axisY}" r="8" fill="url(#blueGrad)" stroke="white" stroke-width="2" filter="url(#shadowSm)"/>
<text x="{x}" y="{axisY+24}" text-anchor="middle" font-size="11" fill="#505F79">6 months</text>
```

**Phase span (colored bar above/below axis):**
```xml
<rect x="{start}" y="{axisY-4}" width="{duration}" height="8" rx="4" fill="url(#blueGrad)" opacity="0.3"/>
```

### Decision Tree Elements

**Decision diamond:**
```xml
<g filter="url(#shadow)" transform="translate({cx},{cy})">
  <rect x="-60" y="-40" width="120" height="80" rx="6" fill="url(#purpleGrad)" transform="rotate(45)"/>
  <text x="0" y="5" text-anchor="middle" font-size="13" font-weight="600" fill="white">Decision?</text>
</g>
```

**Branch label (Yes/No on connecting line):**
```xml
<text x="{x}" y="{y}" text-anchor="middle" font-size="11" font-weight="600" fill="#006644">Yes</text>
```
