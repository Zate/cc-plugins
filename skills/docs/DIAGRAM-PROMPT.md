# How to Build Great SVG Architecture Diagrams

This is a prompt/skill document. It teaches an AI agent how to build the kind of hand-crafted SVG diagrams that we've established as our quality bar. It captures not just the rules, but the *thinking process* that produces good results.

**This is not a style guide** (see `STYLE-GUIDE.md` for color palettes, font sizes, checklist). This is the craft — the decision-making, the SVG construction patterns, and the reference examples that produce diagrams people look at and say "that's golden."

---

## The Thinking Process (Before You Write Any SVG)

Most agents fail at diagrams because they jump straight to SVG code. Don't. Think first.

### Step 1: What is this diagram FOR?

Answer these questions before writing a single `<rect>`:

1. **What concept am I showing?** (Not "what does the doc say" — what is the *one thing* this diagram communicates?)
2. **What can't the text do?** (If the text already explains it clearly, you don't need a diagram)
3. **What should the reader take away in 5 seconds?** (This is your north star — if the diagram doesn't deliver this at a glance, it fails)
4. **What diagram type matches this concept?** (A spectrum should look graduated. A flow should have directionality. A comparison should show things side by side. Don't use a flow diagram for a comparison.)
5. **Does this diagram need to show what authorization sees?** If the concept feeds into authz decisions, consider adding an "authz sees" column or badge. This forces clarity on WHY the concept matters.

### Step 2: What is the visual metaphor?

The diagram must **feel like what it represents**:

| Concept | Visual Metaphor | Example |
|---------|----------------|---------|
| A spectrum/range | Graduated cards, left-to-right progression | delegation-spectrum.svg |
| A transformation | Before/after split, faded old → vibrant new | identity-before-after.svg |
| A lifecycle/flow | Boxes with arrows, clear directionality | federation-lifecycle-states.svg |
| Parallel scenarios | Stacked rows, aligned columns | identity-overview.svg |
| A hierarchy/stack | Pyramid or vertical layers | aims-rfc-stack.svg |
| Component relationships | Boxes with connections, grouped by domain | architecture-overview.svg |

If you can't name the visual metaphor, you're not ready to draw.

### Step 3: Plan the layout on a grid

Before SVG code, decide:
- **Canvas size**: 960px wide (standard). Height varies — don't be afraid of tall.
- **How many visual groups?** (containers, rows, columns)
- **What's the hero element?** (one element should be visually dominant — larger, filled, colored)
- **What's the reading direction?** (left-to-right, top-to-bottom, or both)
- **Where does the whitespace go?** (generous gaps between groups, not cramped)

---

## The SVG Construction Patterns

### The Boilerplate

Every diagram starts with this exact structure:

```xml
<svg viewBox="0 0 960 HEIGHT" xmlns="http://www.w3.org/2000/svg"
     font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif">
  <defs>
    <!-- Shadow filter — gives boxes subtle lift -->
    <filter id="sh">
      <feGaussianBlur in="SourceAlpha" stdDeviation="3"/>
      <feOffset dy="2"/>
      <feComponentTransfer>
        <feFuncA type="linear" slope="0.08"/>
      </feComponentTransfer>
      <feMerge>
        <feMergeNode/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>

    <!-- Gradients — define all you need here -->
    <linearGradient id="bgBlue" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0065FF"/>
      <stop offset="100%" stop-color="#0747A6"/>
    </linearGradient>
    <linearGradient id="bgPurple" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#6554C0"/>
      <stop offset="100%" stop-color="#403294"/>
    </linearGradient>
    <linearGradient id="bgNavy" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#0747A6"/>
      <stop offset="100%" stop-color="#172B4D"/>
    </linearGradient>

    <!-- Arrow marker -->
    <marker id="arr" markerWidth="8" markerHeight="6" refX="8" refY="3" orient="auto">
      <path d="M0,0 L8,3 L0,6" fill="#6B778C"/>
    </marker>
  </defs>

  <!-- Background -->
  <rect width="960" height="HEIGHT" fill="#FAFBFC"/>

  <!-- YOUR DIAGRAM CONTENT HERE -->

</svg>
```

**Key details:**
- `#FAFBFC` background — warm off-white, not pure white
- Shadow filter at `slope="0.08"` — barely visible, just enough lift
- Gradients go top-to-bottom (`y1="0" y2="1"`) for depth
- Arrow markers are small (8×6), fill `#6B778C` (medium gray, not black)

### The Container Pattern

Group related elements inside a container with a rounded border:

```xml
<!-- Domain container with dashed border -->
<rect x="20" y="70" width="920" height="150" rx="12" fill="none" 
      stroke="#DFE1E6" stroke-width="1" stroke-dasharray="6,4"/>
<text x="480" y="88" font-size="12" font-weight="600" text-anchor="middle" 
      fill="#6B778C">Home Domain</text>
```

**Container types we use:**
- **Solid border** (`stroke="#DFE1E6"`) — default grouping
- **Dashed border** (`stroke-dasharray="6,4"`) — domain boundaries, trust boundaries
- **Colored dashed border** (`stroke="#006644"` + `fill="#F0FFF4"`) — special zones like federation
- **Thick colored border** (`stroke="#0052CC" stroke-width="2"`) — hero/primary container

### The Box Pattern

Individual elements (services, concepts, states):

```xml
<!-- Standard box with shadow -->
<g filter="url(#sh)">
  <rect x="100" y="72" width="160" height="52" rx="8" fill="url(#bgBlue)"/>
  <text x="180" y="95" font-size="14" font-weight="700" text-anchor="middle" 
        fill="white">Principal</text>
  <text x="180" y="112" font-size="11" text-anchor="middle" 
        fill="rgba(255,255,255,0.85)">who can authenticate</text>
</g>
```

**Box hierarchy:**
1. **Hero box** — gradient fill, larger (`width="370" height="75"`), bolder text (18px)
2. **Standard box** — gradient or white fill, normal size (`width="160" height="52"`), 14-15px text
3. **Secondary box** — white fill with colored border, smaller text (12px)
4. **Muted box** — `fill="#F4F5F7"` (gray), lighter text (`fill="#42526E"`)

### The Connection Pattern

Arrows between elements:

```xml
<!-- Simple arrow -->
<line x1="195" y1="138" x2="265" y2="138" stroke="#6B778C" stroke-width="1.5" 
      marker-end="url(#arr)"/>

<!-- Label on arrow -->
<text x="230" y="128" font-size="12" text-anchor="middle" fill="#42526E">Proof</text>
```

**Connection rules:**
- Arrow labels go ABOVE the line (lower y value), not on top of it
- Leave at least 20px gap between the box edge and the arrow start
- Use `stroke-dasharray="4,3"` for optional/secondary connections
- Arrow color matches the theme (gray for neutral, green for trust, blue for primary)

### The Badge Pattern

Trust levels, status indicators:

```xml
<!-- Pill badge -->
<rect x="120" y="296" width="200" height="28" rx="14" fill="#E3FCEF" 
      stroke="#36B37E" stroke-width="1"/>
<text x="220" y="315" font-size="12" font-weight="600" text-anchor="middle" 
      fill="#006644">Full observability and control</text>
```

**Badge colors:**
- Green pill (`#E3FCEF` / `#36B37E`) — positive, allowed, success
- Red pill (`#FFEBE6` / `#FF5630`) — negative, denied, danger
- Blue pill (`#DEEBFF` / `#4C9AFF`) — primary, platform
- Amber pill (`#FFF0B3` / `#FF8B00`) — caution, medium

### The Numbered Step Pattern

Sequential processes (used in federation diagram):

```xml
<!-- Step circle -->
<circle cx="120" cy="305" r="14" fill="#006644"/>
<text x="120" y="310" font-size="13" font-weight="700" text-anchor="middle" 
      fill="#FFFFFF">1</text>

<!-- Step label -->
<text x="155" y="298" font-size="13" font-weight="600" fill="#172B4D">
  Home IdP signs assertion</text>
<text x="155" y="316" font-size="12" fill="#6B778C">
  sub · iss · acr · amr claims</text>

<!-- Dashed connector to next step -->
<line x1="340" y1="305" x2="383" y2="305" stroke="#006644" stroke-width="1" 
      stroke-dasharray="4,3" marker-end="url(#arrG)"/>
```

### The Side-by-Side Comparison Pattern

Before/after, old/new (used in identity-before-after.svg):

```xml
<!-- LEFT: faded, struck through -->
<text x="46" y="98" font-size="13" fill="#97A0AF" text-decoration="line-through">
  🔑  Static API keys · long-lived</text>

<!-- CENTER: transformation arrow -->
<text x="480" y="170" font-size="32" text-anchor="middle" fill="#0052CC">→</text>
<text x="480" y="200" font-size="12" font-weight="600" text-anchor="middle" 
      fill="#0052CC">becomes</text>

<!-- RIGHT: vibrant, bold leads -->
<text x="546" y="98" font-size="13" fill="#172B4D">
  🛡️  <tspan font-weight="600">SPIFFE ID</tspan> · identity proofing · trust score</text>
```

**The visual contrast is what makes this work:**
- Left side: `fill="#97A0AF"` (faded gray) + `text-decoration="line-through"`
- Right side: `fill="#172B4D"` (dark, readable) + `<tspan font-weight="600">` for key terms
- Left header: `fill="#F4F5F7"` (gray background)
- Right header: gradient fill (vibrant, alive)

### The Stacked Rows Pattern

Multiple scenarios with aligned columns (used in identity-overview.svg):

```xml
<!-- Column headers -->
<text x="160" y="22" font-size="12" font-weight="600" text-anchor="middle" 
      fill="#6B778C">WHO</text>
<text x="430" y="22" font-size="12" font-weight="600" text-anchor="middle" 
      fill="#6B778C">IDENTITY RESULT</text>
<text x="630" y="22" font-size="12" font-weight="600" text-anchor="middle" 
      fill="#6B778C">OBSERVABILITY</text>

<!-- Row container (all same width!) -->
<rect x="20" y="36" width="680" height="100" rx="12" fill="white" 
      stroke="#DFE1E6" stroke-width="1.5" filter="url(#sh)"/>

<!-- Row label -->
<text x="36" y="56" font-size="13" font-weight="700" fill="#172B4D">
  Human uses an app</text>
<text x="200" y="56" font-size="11" fill="#626F86">
  Direct login · OAuth session</text>
```

**Critical rules for stacked rows:**
- ALL rows must be the same width — symmetry matters
- Column positions must align across rows
- The hero row gets a colored border (`stroke="#0052CC" stroke-width="2"`)
- Use a right-side callout for the connecting message ("Same primitives")

---

## The Color System

Colors have **semantic meaning** that must be consistent across all diagrams:

| Element | Fill | Stroke | Text |
|---------|------|--------|------|
| Human principal | `url(#bgBlue)` | — | white |
| Agent principal | `url(#bgPurple)` | — | white |
| Hero/primary element | `url(#bgBlue)` or `url(#bgNavy)` | — | white |
| Secondary on white | `#DEEBFF` | `#4C9AFF` | `#0052CC` |
| Agent result on white | `#EAE6FF` | `#6554C0` | `#403294` |
| Success/audit | `#E3FCEF` | `#36B37E` | `#006644` |
| Warning/caution | `#FFF0B3` or `#FFF7E6` | `#FF8B00` | `#974F0C` |
| Danger/denied | `#FFEBE6` | `#FF5630` | `#BF2600` |
| Muted/initial | `#F4F5F7` | `#DFE1E6` | `#42526E` or `#6B778C` |
| Container border | — | `#DFE1E6` | — |
| Domain boundary (dashed) | `none` | `#DFE1E6` | `#6B778C` |
| Trust boundary (dashed) | `#F0FFF4` | `#006644` | `#006644` |
| Background | `#FAFBFC` | — | — |
| Primary text | — | — | `#172B4D` |
| Secondary text | — | — | `#44546F` or `#626F86` |
| Muted text | — | — | `#6B778C` or `#97A0AF` |
| White-on-gradient secondary | — | — | `rgba(255,255,255,0.85)` |
| White-on-gradient tertiary | — | — | `rgba(255,255,255,0.7)` |

**Never mix meanings.** Blue always means human/platform. Purple always means agent. Green always means success/allowed. If you use purple for a human in one diagram, you've broken the mental model everywhere.

---

## Text Sizing and Overflow Prevention

### Size Hierarchy

| Purpose | Font Size | Weight |
|---------|-----------|--------|
| Hero element title | 17-18px | 700 |
| Standard element title | 14-15px | 700 |
| Element subtitle/description | 11-12px | 400 |
| Section label | 12-13px | 600-700 |
| Muted/supporting text | 11-12px | 400 |
| Badge text | 11-12px | 600 |
| Arrow label | 12px | 400-600 |

**Absolute minimum: 12px.** Exception: 11px for white-on-gradient subtitles and badge text, but never for primary content. 10px is for `font-size="10"` labels in extremely tight spaces only (e.g., "Subject" label under a small box).

### Overflow Prevention

Before finalising any diagram, calculate text width:

```
text_width ≈ character_count × font_size × 0.55 (normal)
text_width ≈ character_count × font_size × 0.60 (bold)
```

For `text-anchor="middle"`:
- `left = x - text_width / 2`
- `right = x + text_width / 2`

Both `left` and `right` must be within the container bounds with margin. If a label says "Federation · Identify As" at 13px bold, that's ~22 chars × 13 × 0.6 = 172px wide. Centered at x=300 means it spans 214-386. Make sure the container is at least that wide plus padding.

**Run the checker:** `python3 scripts/check-diagrams.py your-diagram.svg`

---

## Common Mistakes and Fixes

| Mistake | Why it fails | Fix |
|---------|-------------|-----|
| Flat boxes on a line with arrows | Looks like a wireframe, not a diagram | Add containers, shadows, gradients, visual hierarchy |
| All elements the same size/style | No visual hierarchy, everything competes | Make one element the hero (larger, gradient-filled) |
| Text labels on top of arrows/boxes | Overlapping, unreadable | Labels above arrows, inside or clearly outside boxes |
| Too many different colors | Visual noise, no semantic meaning | Lock to the color system above, max 3-4 colors per diagram |
| Canvas too small for content | Cramped, overlapping | Increase height. Don't be afraid of 500-600px tall |
| Same diagram at INDEX and deeper doc | Breaks progressive disclosure | Simpler version for INDEX, detailed version for deeper doc |
| Title inside SVG when heading provides it | Redundant, wastes vertical space | Remove the `<text>` title element |
| Mixing diagram styles on one page | Looks like two different authors | Match containers, colors, fonts, border treatments |
| Using trust as a ranking axis | Trust isn't a single dimension — observability, control, authority are all separate | Use multi-dimensional comparison or remove the ranking |
| Diagram says the same thing at two doc levels | Breaks progressive disclosure | Simpler version for INDEX, detailed for deeper doc |

---

## Reference Examples

The best diagrams in this project, and what makes them work:

### `federation-lifecycle-states.svg` — The Gold Standard
- **3-layer layout** (Home Domain → Federation → Receiving Domain) with dashed domain borders
- **Visual hierarchy**: Principal and Local Principal are hero elements (gradient fill, larger)
- **Numbered steps** in the federation layer with dashed connectors
- **Color coding**: gray=initial, blue outline=identity, blue gradient=principal, amber=federated, navy=local
- **Bottom insight line** tying it all together

### `identity-before-after.svg` — The Transformation
- **Split panel** with visual contrast (faded left, vibrant right)
- **Strikethrough text** on the old world — immediately communicates "this is dead"
- **Emoji icons** + bold tspan leads on the new world — scannable, alive
- **Red/green badges** at the bottom — "no observability" vs "full observability"
- **Center arrow** with "becomes" — clear transformation narrative

### `identity-overview.svg` — The Parallel Scenarios
- **Three symmetric rows**, all same width — visual balance
- **Column headers** (WHO / IDENTITY RESULT / OBSERVABILITY) — aligned across all rows
- **Color consistency**: blue=human, purple=agent, light blue=identity result, green=audit
- **Hero row** (OBO) with blue border — stands out from the other two
- **Right callout** with color key and "Same primitives / Different mechanisms / Same model"

### `delegation-spectrum.svg` — The Cards
- **Four cards** showing peer concepts, each with structured info
- **Hero card** (OBO) is gradient-filled blue, others are white with colored headers
- **No misleading axis** — no "trust" ranking, just "four ways principals interact"
- **Structured card content**: what it does, use case, Actor notation, key detail

---

## The Iteration Loop

Diagrams are rarely right on the first try. The successful pattern we follow:

1. **Build v1** based on the thinking process above
2. **View it in context** (mdv, browser) — does it look right in the document?
3. **Check for**: overlapping text, cramped spacing, wrong diagram type, missing visual hierarchy
3.5. **Check for purpose alignment**: Does this diagram serve the narrative of the section it's in? Would the section lose something without it? If not, it's decoration — reconsider whether you need the diagram at all.
4. **Get feedback** — common patterns:
   - "It's too crowded" → add height, whitespace
   - "The words overlap" → widen containers, shorten labels
   - "It doesn't feel like X" → change diagram type or visual treatment
   - "It looks bland" → add gradients, shadows, semantic colors, hero element
   - "These don't look related" → match container styles across diagrams on the page
5. **Run the checker**: `python3 scripts/check-diagrams.py your-diagram.svg`
6. **Iterate** until it passes both the checker AND the visual review

Typically takes 2-4 iterations to get a diagram right. That's normal. Don't try to get it perfect on the first pass.
