# Layout Patterns

Structural patterns for different diagram types. Each type has a distinct visual form — do not reuse one type's layout for another.

---

## 1. Layered Architecture (Top-Down Stack)

**Use for**: Platform architectures, system layers, infrastructure stacks.

```
[Actor] → [Interface Layer] → [Core Components] → [Cross-cutting] → [Consumers]
```

- Hero element (actor/user) at top, centered
- Platform container with nested layers
- Consumer row at bottom
- Optional side arrows for flow annotations (policy down, audit up)
- Each layer gets its own gradient color
- Core components as equal-width sibling boxes

---

## 2. Sequence Diagram

**Use for**: Request/response lifecycles, authentication flows, API call chains, protocol handshakes.

```
  Actor A          Service B          Service C
    │                  │                  │
    │──── request ────▶│                  │
    │                  │──── delegate ───▶│
    │                  │◀─── response ────│
    │◀─── result ──────│                  │
    │                  │                  │
```

**SVG construction:**
- **Lifelines**: Vertical dashed lines (`stroke-dasharray="6,4"`) from each participant header down
- **Participant headers**: Rounded rects at top with name, gradient fill, shadow
- **Messages**: Horizontal arrows between lifelines with labels above
  - Solid arrow (→) for synchronous calls
  - Dashed arrow (-->) for responses
  - Open arrowhead for async
- **Activation bars**: Narrow filled rects on lifelines showing active processing (8-12px wide, semi-transparent)
- **Self-calls**: Curved arrow looping back to same lifeline
- **Notes/annotations**: Small boxes attached to lifelines or spanning between them
- **Numbering**: Optional step numbers on messages (circled digits)

**Spacing**: 200-250px between lifelines. 40-50px vertical gap between messages. Canvas typically wider than tall (1400×800 or 1600×900).

**Color strategy**: Each participant gets a distinct header color. Messages use neutral gray. Highlight critical messages with the participant's color.

---

## 3. Flow Diagram (Left-to-Right or Top-to-Bottom)

**Use for**: Data pipelines, process flows, token flows, request processing.

```
[Source] → [Process] → [Decision] → [Process] → [Destination]
                           ↓
                       [Alternate]
```

- Process steps as rounded rects
- Decisions as diamonds (rotated squares)
- Arrows with labels showing what flows between steps
- Parallel paths shown as branches that rejoin
- Color-code by stage or concern (auth=green, processing=blue, output=purple)

---

## 4. Threat Model / Data Flow Diagram (DFD)

**Use for**: Security analysis, attack surface mapping, trust boundary visualization.

```
┌─ ─ ─ ─ ─ ─ ─ TRUST BOUNDARY ─ ─ ─ ─ ─ ─ ─┐
│                                              │
│  [Internal Service]  ←→  [Internal Service]  │
│                                              │
└─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘
         ↕ data flow
┌─ ─ ─ ─ ─ ─ ─ EXTERNAL ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┐
│  [External Actor]    [Data Store]            │
└─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘
```

**SVG construction:**
- **Trust boundaries**: Large dashed rectangles (`stroke-dasharray="10,6"`, `rx=16`) with red/amber border, semi-transparent fill
- **Processes**: Rounded rects (blue/green gradient)
- **Data stores**: Parallel horizontal lines (open-top rectangle) or cylinder shape for databases
- **External entities**: Squares or rectangles with distinct color (darker, no rounded corners = untrusted)
- **Threat actors**: Red/dark boxes positioned outside trust boundaries
- **Data flows**: Labeled arrows between elements, color-coded by sensitivity
- **Control points**: Shield icons or checkmark badges where security controls are applied
- **STRIDE labels**: Optional threat category badges (Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation of Privilege)

**Color strategy**: Green=trusted internal, Blue=platform services, Red/Orange=threats/untrusted, Yellow=data stores, Dashed red=trust boundaries.

---

## 5. Swimlane / Cross-Functional Diagram

**Use for**: Multi-team processes, responsibility mapping, handoff flows.

```
│  Team A       │  Team B       │  Team C       │
│               │               │               │
│  [Step 1] ───────▶[Step 2] ──────▶[Step 3]   │
│               │       │       │               │
│               │       ▼       │               │
│               │  [Step 4] ────────▶[Step 5]   │
```

**SVG construction:**
- **Lanes**: Vertical columns separated by thin lines, alternating background shades
- **Lane headers**: Top row with team/role names, bold text, subtle gradient
- **Process steps**: Rounded rects positioned within their lane
- **Arrows**: Cross lanes horizontally for handoffs, within lanes vertically for sequences
- **Decision points**: Diamonds spanning a lane

**Color strategy**: Each lane gets a subtle tint (very light, 5-10% opacity of the lane's accent color). Steps use the lane's accent color as gradient.

---

## 6. State Machine / Lifecycle Diagram

**Use for**: Entity lifecycles, status transitions, agent states, workflow states.

```
    ┌──────────┐
    │  Created │
    └────┬─────┘
         │ approve
         ▼
    ┌──────────┐     suspend      ┌───────────┐
    │  Active  │ ───────────────▶ │ Suspended  │
    └────┬─────┘                  └─────┬──────┘
         │ revoke                       │ reactivate
         ▼                              │
    ┌──────────┐ ◀──────────────────────┘
    │  Revoked │
    └──────────┘
```

**SVG construction:**
- **States**: Rounded rectangles or pill shapes (`rx` = half height for pill). Gradient fill.
- **Initial state**: Filled circle (small, solid) with arrow to first state
- **Final/terminal state**: Double-circle or distinct color (red for revoked, gray for archived)
- **Transitions**: Curved arrows between states with labels
  - Use `<path>` with cubic bezier curves, not straight lines
  - Labels positioned along the curve
- **Self-transitions**: Loop arrows returning to the same state
- **Guards/conditions**: `[condition]` text on transitions in smaller italic font

**Color strategy**: Active/happy states in blue/green, warning states in orange, terminal states in red/gray. Transitions in neutral gray.

---

## 7. Composition / Merge Diagram

**Use for**: Token composition, identity merging, data aggregation, anything where multiple inputs combine.

```
[Input A]  ──┐
             ├──▶ [Composition Process] ──▶ [Output]
[Input B]  ──┘
```

**SVG construction:**
- **Input elements**: Positioned left or top, distinct colors per source
- **Merge point**: Central element, visually prominent (largest, deepest shadow)
- **Output**: Positioned right or bottom, uses combined visual treatment
- **Converging arrows**: From each input to the merge point
- **Operation callout**: Label or badge showing the operation (e.g., "∩ intersection")
- **Detail panel**: Expanded view of the output showing how fields from each input contribute

**Key visual**: The converging arrows + merge point are the hero of this diagram. Make them visually strong.

---

## 8. Timeline / Roadmap

**Use for**: Implementation phases, release plans, maturity models.

```
    Phase 1              Phase 2              Phase 3
  ┌──────────┐        ┌──────────┐        ┌──────────┐
  │Foundation│        │Expansion │        │ Maturity │
  └──────────┘        └──────────┘        └──────────┘
  ─────●──────────────────●──────────────────●──────────▶
     0 mo               6 mo               12 mo
```

**SVG construction:**
- **Timeline axis**: Horizontal line with circle markers at milestones
- **Phase cards**: Positioned above or alternating above/below the axis
- **Milestone markers**: Circles on the axis, sized by importance
- **Duration spans**: Horizontal bars showing time ranges
- **Connecting lines**: Dashed lines from phase cards to their position on the axis

**Color strategy**: Progressive color shift (green → blue → purple) to show maturity progression.

---

## 9. Hub and Spoke

**Use for**: Central services with peripherals, API gateways, event buses.

- Central hub element (largest, strongest shadow)
- Spokes arranged radially (evenly distributed)
- Connecting lines/arrows from hub to spokes
- Optional grouping of spokes by category (color-coded sectors)

---

## 10. Comparison (Side-by-Side)

**Use for**: Current vs. target state, before/after, option A vs. B.

- Two equal-width panels with matching vertical alignment
- Central divider with "vs" or arrow annotation
- Identical structure on both sides for easy visual scanning
- Color-code: left=current (muted), right=target (vibrant)

---

## 11. Matrix / Grid

**Use for**: Capability mapping, RACI charts, feature coverage, compliance matrices.

- Fixed header row and column
- Cells color-coded by value (green=yes, red=no, yellow=partial, gray=N/A)
- Cell size: 100-140px wide, 50-70px tall
- Tight gaps (4-6px) for grid cohesion

---

## 12. Decision Tree / Flowchart

**Use for**: Decision logic, troubleshooting guides, classification algorithms.

```
        [Question?]
        /          \
      Yes           No
      /               \
  [Action A]      [Question B?]
                  /            \
                Yes             No
                /                 \
            [Action B]        [Action C]
```

- Questions as diamonds
- Actions/outcomes as rounded rects
- Yes/No labels on branches
- Tree expands downward or rightward
- Leaf nodes (final actions) use distinct color from decision nodes

---

## General Principles (All Types)

### Whitespace
| Between | Gap |
|---------|-----|
| Major sections | 40-60px |
| Sibling elements | 25-30px |
| Title → description | 10-15px |
| Text lines | 1.4× font-size |

### Connecting Lines
| Relationship | Style |
|-------------|-------|
| Containment | Dashed, light |
| Data flow | Solid with arrowhead |
| Temporal sequence | Solid with filled arrowhead |
| Trust boundary | Heavy dashed, red/amber |
| Optional/async | Dashed with open arrowhead |

### Typography
- Title: 28-36px bold
- Subtitle: 16-20px regular
- Section labels: 11-12px uppercase, letter-spaced
- Box titles: 16-20px semibold
- Descriptions: 12-14px regular
- Annotations: 11-12px, reduced opacity

### Arrow Routing

**Never route arrows through unrelated boxes.** This is the most common layout defect.

When connecting two elements that are not adjacent:
1. **Check the path** -- does a straight line cross through any box it is not connected to?
2. **If yes, route around** -- use L-shaped (one bend) or Z-shaped (two bends) paths
3. **Maintain 20px clearance** from any unrelated box edge

**Routing strategies by layout:**

| Situation | Strategy |
|-----------|----------|
| Vertical connection crossing a horizontal row of boxes | Route to the LEFT or RIGHT of the intermediate boxes, then turn back in |
| Multiple arrows from one source to many targets | Fan out from distinct exit points on the source box (top, right, bottom) -- do not stack all on one side |
| Parallel routes to nearby targets | Maintain 30px minimum separation between parallel lines |
| Crossing a trust/zone boundary | Route perpendicular to the boundary, place security badge on the crossing point |

**Arrow label placement:**
- Horizontal arrows: label ABOVE the line, 8px offset
- Vertical arrows: label to the LEFT or RIGHT, 8px offset
- Never center a label directly on a line -- it becomes unreadable
- Labels must not extend into nearby boxes

**Container/scope boundaries:**
- Dashed scope indicators (PCI DSS, trust boundaries) must fully enclose their target elements
- Minimum padding between scope boundary and enclosed elements: 15px all sides
- Scope labels go in the top-right or top-left corner INSIDE the boundary, not on the edge

### Canvas Sizes
| Diagram Type | Recommended viewBox |
|-------------|-------------------|
| Architecture | 1400×1000 |
| Sequence | 1400×800 to 1600×900 |
| Flow | 1400×600 to 1600×800 |
| Threat model | 1400×900 to 1520×980 |
| Timeline | 1500×600 to 1500×700 |
| State machine | 1200×800 |
| Comparison | 1400×700 |
| Matrix | varies by dimensions |
