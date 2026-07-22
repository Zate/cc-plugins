---
name: systemigram
description: "Generate polished systemigram SVGs — noun-phrase nodes connected by verb-phrase edges so every path reads as a coherent sentence."
version: "2.0.0"
author: "Zate Berg"
allowed-tools:
  - bash
  - open_files
  - expand_code_chunks
  - create_file
  - find_and_replace_code
  - grep
  - mcp__mdv__invoke_tool
tags:
  - diagrams
  - svg
  - systemigram
---

# Skill: systemigram

Generate **systemigrams**: SVG diagrams that map a system as a network of named concepts (noun-phrase nodes) connected by named relationships (verb-phrase edges) such that any path through the graph reads as a coherent sentence.

Use for sociotechnical systems, organizational/process models, platform architectures, governance flows — anywhere "boxes with arrows" understates the relationships and a flowchart misrepresents the structure.

**This skill assumes the `diagrams` skill is already loaded.** It refines and overrides the diagrams skill specifically for systemigrams. Where they conflict, this skill wins for systemigram outputs.

**The cardinal rule: polish is the goal, not an afterthought.** A systemigram that is "technically correct" (XML valid, arrows terminate, labels exist) but "visually crowded" (lines crossing nodes, labels orphaned, weight imbalanced) is a failure. The standard is *presentable to executives in a deck*. Iterate until that bar is met.

---

## 1. The Defining Property

> **Every path through a systemigram, read in order, must form a meaningful English sentence.**

This is the only test that matters. If you cannot read "Identity Platform → publishes → Specifications → constrains → Teams" out loud and have it mean something, the diagram is broken.

This single property cascades into every design choice:

- **Nodes are noun phrases.** Not actions. Not processes. Not steps. *Concepts, actors, artifacts, conditions.*
- **Edges are verb phrases.** Always. Every edge has a label. An unlabeled arrow is a bug.
- **Direction matters.** "X publishes Y" ≠ "Y publishes X". Arrowheads are not decorative.
- **Subject-verb-object grammar.** The chain `Source → verb → Target` must parse.

If a node would be a verb ("Authenticate User"), it's a sub-process — it belongs as an internal capability of a larger noun-phrase node ("Authentication Service"), or as the edge label between two other nodes.

---

## 2. The Systems Definition

A node in a systemigram is a **system in its own right**: a collection of objects centered on a common purpose, with defined inputs and outputs. Edges are the **contracts and interfaces** between those systems — they map outputs of one system into inputs of another.

Mental model: nodes are like functions in software, and edges are the contracts/interfaces/scripts that wire one function's output into another's input.

This is more than vocabulary. It's a constraint on what counts as a node:

- **A node has a mission.** You can write one sentence describing what it exists to do. If you can't, it's not a system — split it or merge it.
- **A node has inputs and outputs.** If nothing flows in or out, it's dead weight. Remove it.
- **A node is decomposable.** Every node is a system you could later expand into its own systemigram. This is what enables the layered approach (Section 7).
- **An edge is a contract.** "X publishes Y" implies X owes Y a stable artifact. "X informs Y" implies X feeds signal that Y consumes. The verb names the obligation.

When choosing nodes, ask: *what is the smallest set of named systems whose contracts I can write down?* That set is your nodes. The contracts are your edges.

---

## 3. Visual Language

Systemigrams have a recognizable visual idiom. Honor it.

### Nodes (ellipses)

- **Ellipses, not rectangles.** Rectangles read as boxes/processes; ellipses read as concepts. This is the single strongest visual signal that says "this is a systemigram."
- **Pale radial gradient fill.** White center fading to a soft tint of the node's domain color. Not flat color, not bold gradient. Keep fills very pale.
- **Color-matched stroke**, 2–2.4px wide. The hero/terminal node may use 2.6px to gain emphasis without changing color.
- **Dark text on light fill.** Use the dark variant of the domain color for headings (e.g. `#00644E` text on green fills). Never white text — that's a presentation deck convention, not a systemigram convention.
- **Two-line node labels are common.** Bold name on top, italic sub-mission below.
- **Sub-concepts inside parent ellipses are also ellipses**, smaller, with thinner strokes. Use them when a parent system has named components worth showing. For simpler nodes, dot-separated inline text works (e.g., "draft · stable · implemented").

### Edges (curves + verb labels)

- **Always Bezier curves**, never straight lines, never L-shaped paths. Use quadratic (`Q`) for one bend, cubic (`C`) for two, or chain multiple cubic segments via hinge points for tight routings around obstacles.
- **One arrowhead per edge**, at the destination. The arrowhead color matches the edge color.
- **Curve gently for short edges, more aggressively for long ones.** Default bend factor: 12–25% of chord length perpendicular offset. For long arcs that need to clear obstacles, bend up to 40% or use a multi-segment path.
- **Edges start and end at ellipse boundaries**, not centers. Use the geometric edge formula (Section 6). Use a pad of ≥10px so the arrowhead clears the destination stroke cleanly. **Pad of 4–6px is too small** — the arrowhead's visible body extends ~8px back from the path endpoint and will visually intersect the ellipse stroke.

### Edge labels — strict rules

These are non-negotiable:

1. **Every edge has a label.** A verb phrase. No unlabeled arrows.
2. **Labels are always horizontal.** Never rotated to follow the curve.
3. **Labels are centered on the actual curve midpoint.** Compute it; do not eyeball. For quadratic Bezier, midpoint at `t=0.5` is `0.25*(P0+P2) + 0.5*Pctrl`. For cubic, it's `0.125*P0 + 0.375*P1 + 0.375*P2 + 0.125*P3`.
4. **The layout must reserve enough whitespace for both the arrow AND the label.** If a curve's midpoint lands inside another node, the layout is wrong, not the label. Move the nodes or reroute the curve.
5. **Label rectangles use white fill, color-matched stroke (1–1.3px), 3px corner radius, ~12px font, 600–700 weight in the edge color.** The fill masks any line behind it cleanly.

### Color semantics

| Color | Meaning |
|-------|---------|
| Green | Source/positive/outcome system; the things you want to flow |
| Blue | Agent system (the team, user, or actor that operates) |
| Purple | Governance, framework, constraint, oversight |
| Red | Risk, gap, problem, prevented state |
| Gray | Neutral mechanism, intermediary, process node |
| Amber/orange | Distinguished accent — use sparingly for the **one** edge or node that deserves spotlight (typically a feedback/learning loop) |

Keep the palette to 4–6 distinct colors max. Color is meaning, not decoration.

**Edge color rule (deterministic):**

- **Spine and supporting edges**: take the source's domain color
- **Governance edges**: always purple (regardless of source)
- **Feedback/learning loops**: always amber (regardless of source)
- **Prevented relationships**: always dashed red

### Edge weight rule (deterministic)

- **Spine edges** (the main narrative): 2.4px
- **Supporting edges**: 1.8px
- **Governance edges**: 2.0px
- **Loop edges**: 2.6px (slightly heavier, visual accent)
- **Prevented edges**: 1.8px, dashed `6,3`
- **Anchors/ownership edges**: 2.0px, dashed `6,3`

Visual weight matches conceptual weight. The spine is what you want the reader's eye to follow; it gets the heaviest stroke.

### Whitespace is content

Well-composed systemigrams are 30–50% whitespace. The eye needs room to absorb each sub-system before relating it to the next. If your diagram feels crowded, the answer is almost always "make the canvas bigger" — never "shrink the nodes."

Default starting canvas: **1200 × 900 minimum, expand to 1280–1400 wide for 8+ nodes**.

---

## 4. The Cardinal Rules (Bug Class Definitions)

These rules came from real diagrams that looked "almost done" but failed the polish bar. Each one is a specific bug class. **Validate every diagram against all of them before declaring done.**

### Rule 1: No arrow may pass through any node it does not terminate at

Not the ellipse interior. Not the stroke. Not even glancingly. If a path passes through any non-terminal node — even by 1px — the diagram is broken.

**Detection:** for each edge, sample the Bezier curve at multiple `t` values (t=0, 0.1, 0.2, ..., 1.0). For each sample point `(x, y)`, check whether it lies inside any node ellipse other than the source and destination. If yes, the edge is broken.

**Fix:** push the Bezier control points further from the obstacle (perpendicular to the chord, outside the obstacle). If quadratic Bezier with high bend can't clear the obstacle, switch to a multi-segment cubic with an explicit hinge point outside the obstacle.

### Rule 2: Every label sits on its actual arrow midpoint

Not above. Not below. Not 30px to the side. ON the curve midpoint, computed mathematically.

**Detection:** for each edge, compute the actual Bezier midpoint at `t=0.5`. The label rect's center must be within 5px of that point.

**Fix:** recompute the midpoint and reposition the label rect.

### Rule 3: No label rectangle overlaps any node ellipse

A label that visually touches or overlaps an ellipse boundary reads as crowding, even if mathematically clear.

**Detection:** for each label rectangle (computed from midpoint, width, height ≈22px), check whether any of its 4 corners or center lies inside any node ellipse.

**Fix:** either reroute the edge so its midpoint lands in clear whitespace, or move the relevant nodes apart to create whitespace at the midpoint.

### Rule 4: Every arrowhead lands fully outside its destination ellipse

The arrowhead body extends ~8px back from the path endpoint. With pad too small, the arrowhead body sits inside the destination's stroke or interior, looking buried.

**Detection:** the path endpoint must be at least `arrowhead_length + ellipse_stroke_width` outside the destination's boundary. Practically: use pad ≥ 10px in the boundary-edge calculation.

**Fix:** recompute endpoint with larger pad.

### Rule 5: Verb tense is consistent across all edges

All present-tense singular: publishes, anchors, informs, constrains, enables, builds, encounters, triggers, generates, sequences, prevents, feeds-new. Mixed plurals (constrain vs constrains) read as careless.

### Rule 6: Type hierarchy is consistent

- Hero/terminal node: 16px bold title
- Primary nodes: 15px bold title + 12px italic sub-mission + 12px child list
- Secondary nodes: 14px bold title + 12px child list
- All sub-text uses the same pattern within a tier

### Rule 7: Visual weight matches conceptual weight

The spine arrows are the thickest. Supporting arrows are thinner. Governance arrows are styled distinctly (color, dash). The hero node has the heaviest stroke.

### Rule 8: Visual mass is balanced left/right and top/bottom

If the right side of the diagram is dense and the left side is empty, redistribute. If top is empty and bottom is crowded, redistribute. The eye wants visual equilibrium.

---

## 5. The Spine

Every systemigram has a **spine**: a single sentence you can read through the diagram that captures the system's primary narrative. Identify the spine *first*, before placing any nodes.

**The spine is a narrative, not a layout rail.** The spine sentence tells you which nodes are most important and how they relate — it does NOT mean those nodes must sit on a horizontal line. A 5-node spine arranged in a gentle arc, an L-shape, or even a triangle is perfectly valid if it gives every edge room to breathe and every label room to land. Forcing all spine nodes onto one straight line is a layout failure, not a convention.

**The layout question to ask:** *Given these nodes and edges, what spatial arrangement gives every edge a clear, unobstructed path and every label enough whitespace to sit cleanly on its curve?* Answer that question first. The spine sentence is a reading order, not a drawing instruction.

**Common layout patterns** (choose based on what gives the most whitespace):

- **Loose arc or curve**: spine nodes follow a gentle curve across the canvas. Gives more natural edge routing than a straight line and avoids the "crammed" look.
- **Cluster + satellite**: a hub node in the center with related nodes orbiting at comfortable distances. Ideal when one system coordinates many others.
- **Two-row**: primary flow across the top, supporting/feedback systems below. Good when you have 5+ spine nodes — split them across two rows rather than compressing into one.
- **Diagonal spine**: spine flows top-left to bottom-right (or any diagonal). Frees up the other two quadrants for context nodes with long, graceful arcs.
- **Dual spine**: two parallel narratives that converge on a shared sink. Label each spine with subtle banner text (e.g., "— BUILD PATH —" in tracked-out gray caps).

**Minimum inter-node gap rule (non-negotiable):** The gap between the nearest edges of any two ellipses must be **at least 120px**. Less than that and there is no room for an edge label between them. If two nodes are connected by an edge, the label for that edge must have clear whitespace to sit on the curve midpoint — if it doesn't, the nodes are too close and must be moved apart, not the label shrunk.

**Test your spine** by reading it aloud. If you stumble or have to insert mental words to make it work, the spine is wrong. Rewrite until it reads as natural English.

---

## 6. Geometry: The Math That Matters

This is where most diagrams fail. Fix it with computation, not eyeballing. **Use `systemigram.py geom` for all geometry calculations** — do not write throwaway Python inline.

### Node anchor points (the 8-point system)

Every ellipse has **8 named attachment points** — N, NE, E, SE, S, SW, W, NW — computed on the ellipse boundary. **All connectors must originate and terminate at one of these 8 points**, not at arbitrary boundary positions computed toward a target center.

This constraint makes layouts predictable, enforces visual cleanliness, and makes gap-checking trivial: if the NE anchor of node A is too close to the SW anchor of node B, those nodes are too close together and must be moved.

```
            N
      NW ·     · NE
    W  ·  (node)  ·  E
      SW ·     · SE
            S
```

**Anchor math:** for direction unit vector `(dx, dy)`, the boundary point on ellipse `(cx, cy, rx, ry)` is:
```
t  = 1 / sqrt((dx/rx)² + (dy/ry)²)
bx = cx + t·dx  +  pad·dx
by = cy + t·dy  +  pad·dy
```
Use `pad=22` for connector **destinations** (arrowhead endpoints). The validator's arrowhead clearance check uses `pad=10` internally, so your endpoint must be at least 10px further out than that — pad=22 guarantees ≥10px clearance. Use `pad=12` for connector **sources** (tail endpoints, which the validator doesn't check for clearance).

**CLI — get all 8 anchors for a node:**
```
python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom anchors <cx> <cy> <rx> <ry> [--pad 12]
```
Output: one line per anchor — `N  (x, y)`, `NE  (x, y)`, etc.

**CLI — auto-select best src/dst anchor pair for an edge:**
```
python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom best_anchor <src_cx> <src_cy> <src_rx> <src_ry> <dst_cx> <dst_cy> <dst_rx> <dst_ry> [--pad 12]
```
Output: `src  E  (x, y)` / `dst  W  (x, y)` — the closest anchor pair by straight-line distance.

**Workflow:** call `geom anchors` on every node first to get its 8 attachment points. Then call `geom best_anchor` to find the natural connection pair. Use those exact `(x, y)` values as the start/end points of every edge path. Do NOT compute arbitrary boundary points toward target centers.

**Anchor selection override:** `best_anchor` picks the closest pair, which is almost always correct. Override manually only when routing requires it — e.g., two nodes at the same y-level should use `E→W` even if `NE→NW` is fractionally closer, to keep the edge horizontal and clean.

### Gap enforcement (the 120px rule)

Before computing any edge geometry, verify every connected node pair satisfies the minimum gap:

```
python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom gap <cx1> <cy1> <rx1> <ry1> <cx2> <cy2> <rx2> <ry2>
```
Output: `gap  247.0px  [OK]` or `gap  43.0px  [WARNING: gap < 120px]`

**Run `geom gap` on every connected pair before proceeding.** If any pair returns a warning, move those nodes apart and recompute. The gap check is the first geometry step, not the last.

### Edge boundary formula

Given an ellipse at center `(cx, cy)` with radii `(rx, ry)`, the boundary point in the direction of point `(px, py)`, plus a pad outward:

```python
def edge_pt(cx, cy, rx, ry, px, py, pad=10):
    dx, dy = px - cx, py - cy
    if dx == 0 and dy == 0: return cx, cy
    t = 1.0 / math.sqrt((dx/rx)**2 + (dy/ry)**2)
    bx, by = cx + t*dx, cy + t*dy
    L = math.hypot(dx, dy)
    bx += pad * dx / L
    by += pad * dy / L
    return round(bx, 1), round(by, 1)
```

**Use pad ≥ 10 for arrowhead destinations.** Pad of 4–6 leaves the arrowhead body inside the ellipse stroke.

CLI shorthand:
```
python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom boundary <cx> <cy> <rx> <ry> <px> <py> [--pad 10]
```

### Quadratic Bezier control point

For a curve from `(x1, y1)` to `(x2, y2)` with bend factor `b` (signed: positive = right of chord traveling forward, negative = left):

```python
def quad_ctrl(x1, y1, x2, y2, bend):
    mx, my = (x1+x2)/2, (y1+y2)/2
    dx, dy = x2-x1, y2-y1
    L = math.hypot(dx, dy)
    px, py = -dy/L, dx/L  # perpendicular unit vector
    return round(mx + px*L*bend, 1), round(my + py*L*bend, 1)
```

CLI shorthand:
```
python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom ctrl <x1> <y1> <x2> <y2> --bend <b>
```

### Bezier midpoints (for label placement)

```python
def quad_mid(x1, y1, cxv, cyv, x2, y2):
    """Quadratic Bezier point at t=0.5"""
    return 0.25*(x1+x2) + 0.5*cxv, 0.25*(y1+y2) + 0.5*cyv

def cubic_mid(x1, y1, c1x, c1y, c2x, c2y, x2, y2):
    """Cubic Bezier point at t=0.5"""
    return 0.125*x1 + 0.375*c1x + 0.375*c2x + 0.125*x2, \
           0.125*y1 + 0.375*c1y + 0.375*c2y + 0.125*y2
```

CLI shorthand:
```
python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom midpoint quad <x1> <y1> <cx> <cy> <x2> <y2>
python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom midpoint cubic <x1> <y1> <c1x> <c1y> <c2x> <c2y> <x2> <y2>
```

### Sampling Bezier curves to detect node intersection

```python
def sample_cubic(x1,y1, c1x,c1y, c2x,c2y, x2,y2, n=20):
    """Return n points along the cubic curve."""
    for i in range(n+1):
        t = i / n
        u = 1 - t
        x = u**3*x1 + 3*u**2*t*c1x + 3*u*t**2*c2x + t**3*x2
        y = u**3*y1 + 3*u**2*t*c1y + 3*u*t**2*c2y + t**3*y2
        yield (x, y)

def in_ellipse(px, py, cx, cy, rx, ry, pad=0):
    return ((px-cx)/(rx+pad))**2 + ((py-cy)/(ry+pad))**2 < 1.0
```

CLI shorthand:
```
python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom in_ellipse <px> <py> <cx> <cy> <rx> <ry>
```

For every edge, sample its curve and check each sample against every non-terminal node. If any sample is inside, the edge is broken.

### Routing around obstacles: multi-segment cubics

When a single quadratic or cubic Bezier can't bend enough to clear an obstacle (its convex hull still crosses the obstacle), use **two cubic segments joined at an explicit hinge point**:

```
M startX,startY  C ctrl1ax,ctrl1ay ctrl1bx,ctrl1by hingeX,hingeY  C ctrl2ax,ctrl2ay ctrl2bx,ctrl2by endX,endY
```

The hinge point is chosen to lie in clear whitespace, outside any obstacle. This forces the curve to actually pass through that point. Each segment is a cubic with its own control points pulling the curve into shape.

This is essential for long-range edges like learning loops that need to traverse most of the diagram.

---

## 7. Layered Stages

Complex systemigrams should be **built in stages**, each stage adding one or two new nodes/edges to the previous one. The reader sees the simple narrative first, then sees how the nuance was layered on.

Three stages is usually enough:

1. **Spine** (the sentence). Source → Sink with 3–5 nodes on the line. Maximum whitespace, maximum legibility. This is the version a busy executive reads in 5 seconds.
2. **+Problem and recovery.** Add the gap/risk node and the recovery mechanism. Add 2–4 nodes.
3. **+Governance and feedback loops.** Add the oversight layer, the learning loops, the prevented states. This is the full picture.

**Visual continuity across stages:** keep nodes in the same screen positions across stages. Newly added nodes appear in fresh positions; old nodes don't move. This lets the reader's eye anchor.

**Faded styling for prior layers** (optional): when you add a new layer, render the previous layer's nodes/edges at reduced opacity (0.4–0.5) so the new content pops.

---

## 8. Workflow

**For every geometry step, use `systemigram.py` — do not write throwaway Python.**

1. **Identify the spine.** Write the sentence before drawing anything. Read it aloud.
2. **List the nodes.** For each, write one sentence stating its mission. If you can't, drop it or merge it.
3. **List the edges.** Each edge is `(source, verb_phrase, target, category)`. Read each one aloud as a sentence.
4. **Plan spatial positions — freely, not linearly.** This is the most important layout step. Do NOT default to placing all nodes on a single horizontal line. Instead:
   - Ask: *which nodes have the most edges?* Place high-degree nodes centrally or with more surrounding space.
   - Ask: *which edges will be longest?* Route those through open canvas area, not through clusters.
   - Ask: *where does every edge label need to land?* Reserve that whitespace before committing to positions.
   - **Enforce the 120px minimum gap**: compute `gap = distance_between_centers - rx1 - rx2 - ry_factor`. If gap < 120px for any connected pair, move nodes apart. Do this check *before* computing edge geometry.
   - Use the full 2D canvas. Nodes can be arranged in arcs, clusters, diagonals, two rows, or any shape that gives edges room. Prefer arrangements where long edges travel through open space and short edges connect nearby nodes.
   - A node that only receives feedback or governance relationships often belongs above or below the main cluster, not inline with it.
5. **Compute geometry with `systemigram.py` — anchors first, edges second.**
   - **Step 5a — Gap check every connected pair** (before anything else):
     `python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom gap <cx1> <cy1> <rx1> <ry1> <cx2> <cy2> <rx2> <ry2>`
     Move nodes apart if gap < 120px. Do not proceed until all pairs pass.
   - **Step 5b — Compute 8 anchors for every node:**
     `python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom anchors <cx> <cy> <rx> <ry> --pad 12`
     Record all 8 points. These are the only valid edge endpoints.
   - **Step 5c — Select anchor pair for each edge:**
     `python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom best_anchor <src_cx> <src_cy> <src_rx> <src_ry> <dst_cx> <dst_cy> <dst_rx> <dst_ry>`
     Override the suggestion only when routing requires it (see Section 6).
   - **Step 5d — Compute Bezier control points and label midpoints:**
     - Control points: `python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom ctrl <x1> <y1> <x2> <y2> --bend <b>`
     - Label midpoints: `python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom midpoint quad <x1> <y1> <cx> <cy> <x2> <y2>`
   - **Step 5e — Intersection check** (sample each curve against non-terminal nodes):
     `python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom in_ellipse <px> <py> <cx> <cy> <rx> <ry>`
6. **Validate before drawing.** For each edge, sample the curve and confirm no sample point lies inside any non-terminal node. For each label, confirm the rectangle doesn't overlap any node.
7. **Generate SVG.** Edges first (so node fills cover any path that strays inside), then nodes on top.
   - Boilerplate: `python ~/.rovodev/skills/systemigram/scripts/systemigram.py init <output.svg>`
   - Node snippet: `python ~/.rovodev/skills/systemigram/scripts/systemigram.py node --cx <cx> --cy <cy> --rx <rx> --ry <ry> --tier primary --label "Name" --sub-mission "mission"`
   - Edge snippet: `python ~/.rovodev/skills/systemigram/scripts/systemigram.py edge <x1> <y1> <rx1> <ry1> <x2> <y2> <rx2> <ry2> <category> <verb>`
8. **Validate XML and font sizes** with the diagrams skill checks.
   - Full validation: `python ~/.rovodev/skills/systemigram/scripts/systemigram.py validate <output.svg>`
9. **Visually verify.** Open in MDV (or equivalent), screenshot. Look at the rendered output critically against all 8 cardinal rules.
10. **Iterate.** Polish issues are not "good enough" — they are bugs. Fix every one before declaring done.
11. **For complex systems, build the staged versions.** Spine first, then mid, then full.
    - Arrow snippet: `python ~/.rovodev/skills/systemigram/scripts/systemigram.py arrow <x1> <y1> <x2> <y2> --apex <ax> <ay> --style loop`
    - Loop snippet: `python ~/.rovodev/skills/systemigram/scripts/systemigram.py loop <x1> <y1> <rx1> <ry1> <x2> <y2> <rx2> <ry2> [--via <vx> <vy>]`

---

## 9. Common Mistakes (Bug Catalog)

| Mistake | Why it's wrong | Fix |
|---------|---------------|-----|
| Rectangular nodes | Reads as flowchart | Always ellipses |
| Straight or L-shaped edges | Reads as wireframe | Bezier curves only |
| Unlabeled arrows | Breaks "reads as a sentence" | Every edge has a verb-phrase label |
| Label floating in whitespace | Reader can't tell which arrow | Place on actual curve midpoint |
| Label rotated to follow curve | Hurts readability | Always horizontal |
| Arrowhead inside ellipse interior | Pad too small | Use pad ≥ 10 in boundary calc |
| Edges start/end at node centers | No boundary math done | Use `geom anchors` + `geom best_anchor`; snap to named anchor points |
| Edges connect at arbitrary boundary points | Connections look random and inconsistent | Always use one of the 8 named anchors (N/NE/E/SE/S/SW/W/NW) |
| Curve passes through unrelated node | Bend too small or layout wrong | Increase bend, use hinge point, or move nodes |
| Curves use convex hull that crosses obstacle | Single Bezier can't clear it | Multi-segment cubic with hinge |
| White text on bold-fill ellipses | Presentation-deck style | Pale fill, dark text |
| Every node a unique color | Color loses meaning | 4–6 colors max, by domain |
| Nodes packed tightly | Reader can't separate sub-systems | Make canvas bigger; never shrink nodes |
| All spine nodes forced onto one horizontal line | Layout fights the relationships; labels have no room | Use 2D space freely — arcs, clusters, diagonals, two-row layouts |
| Gap between adjacent nodes < 120px | No room for edge label on curve midpoint | Move nodes apart; enforce 120px minimum gap before computing geometry |
| Trying to fit all nodes in one diagram | Reader drowns | Stage it: spine, mid, full |
| Verb labels that are sentences | Edge labels are short phrases | "publishes" not "is responsible for publishing" |
| Verb tense inconsistent (mix singular/plural) | Reads as careless | All present-tense singular |
| Type hierarchy uneven across nodes | Reads as inconsistent | Define tiers; apply uniformly |
| Visual weight ≠ conceptual weight | Reader's eye goes to wrong thing | Spine = thickest, hero = strongest |
| Visual mass unbalanced (one side dense, other empty) | Diagram feels lopsided | Redistribute nodes |
| Declaring done at "technically correct" | Polish bugs ignored | Polish IS the goal — iterate |
| Writing throwaway Python for geometry | Inconsistent, wasteful | Use `python ~/.rovodev/skills/systemigram/scripts/systemigram.py geom ...` |

---

## 10. SVG Boilerplate

Use `python ~/.rovodev/skills/systemigram/scripts/systemigram.py init <output.svg>` to generate the boilerplate SVG with all defs pre-populated. The CLI writes the full `<defs>` block with the 6 radial gradients, 6 arrow markers, and shadow filter.

For reference, the systemigram-specific `<defs>` additions:

```xml
<radialGradient id="gGreen" cx="35%" cy="35%" r="75%">
  <stop offset="0%" stop-color="#FFFFFF"/>
  <stop offset="60%" stop-color="#E3FCEF"/>
  <stop offset="100%" stop-color="#ABF5D1"/>
</radialGradient>
<radialGradient id="gBlue" cx="35%" cy="35%" r="75%">
  <stop offset="0%" stop-color="#FFFFFF"/><stop offset="60%" stop-color="#DEEBFF"/><stop offset="100%" stop-color="#B3D4FF"/>
</radialGradient>
<radialGradient id="gPurple" cx="35%" cy="35%" r="75%">
  <stop offset="0%" stop-color="#FFFFFF"/><stop offset="60%" stop-color="#EAE6FF"/><stop offset="100%" stop-color="#C0B6F2"/>
</radialGradient>
<radialGradient id="gRed" cx="35%" cy="35%" r="75%">
  <stop offset="0%" stop-color="#FFFFFF"/><stop offset="60%" stop-color="#FFEBE6"/><stop offset="100%" stop-color="#FFBDAD"/>
</radialGradient>
<radialGradient id="gGray" cx="35%" cy="35%" r="75%">
  <stop offset="0%" stop-color="#FFFFFF"/><stop offset="60%" stop-color="#F4F5F7"/><stop offset="100%" stop-color="#DFE1E6"/>
</radialGradient>
<radialGradient id="gAmber" cx="35%" cy="35%" r="75%">
  <stop offset="0%" stop-color="#FFFFFF"/><stop offset="60%" stop-color="#FFFAE6"/><stop offset="100%" stop-color="#FFE380"/>
</radialGradient>

<marker id="arrGreen" markerWidth="9" markerHeight="7" refX="8" refY="3.5" orient="auto">
  <path d="M0,0 L9,3.5 L0,7 z" fill="#00875A"/></marker>
<!-- repeat: arrBlue (#0747A6), arrPurple (#5243AA), arrRed (#BF2600), arrGray (#42526E) -->
<!-- amber accent, slightly larger -->
<marker id="arrAmber" markerWidth="11" markerHeight="9" refX="9" refY="4.5" orient="auto">
  <path d="M0,0 L11,4.5 L0,9 z" fill="#974F00"/></marker>
```

Standard ellipse pattern (primary node):

```xml
<ellipse cx="CX" cy="CY" rx="RX" ry="RY"
         fill="url(#gGreen)" stroke="#00875A" stroke-width="2" filter="url(#sh)"/>
<text x="CX" y="CY-18" text-anchor="middle" font-size="15" font-weight="700" fill="#00644E">Node Name</text>
<text x="CX" y="CY+4"  text-anchor="middle" font-size="12" font-style="italic" fill="#00644E">sub-mission</text>
<text x="CX" y="CY+25" text-anchor="middle" font-size="12" fill="#00644E">child · child · child</text>
```

Standard edge pattern:

```xml
<path d="M X1,Y1 Q CX,CY X2,Y2"
      stroke="#00875A" stroke-width="2.4" fill="none" marker-end="url(#arrGreen)"/>
<rect x="LBLX-W/2" y="LBLY-11" width="W" height="22" rx="3"
      fill="white" stroke="#00875A" stroke-width="1"/>
<text x="LBLX" y="LBLY+4" text-anchor="middle"
      font-size="12" font-weight="600" fill="#00875A">verb</text>
```

---

## 11. Validation Checklist (Run Before Declaring Done)

Run `python ~/.rovodev/skills/systemigram/scripts/systemigram.py validate <output.svg>` first — it checks all 9 cardinal-rule categories automatically. Then verify the remaining visual checks manually:

- [ ] **`python ~/.rovodev/skills/systemigram/scripts/systemigram.py validate <output.svg>` passes all 9 checks**
- [ ] **Spine sentence reads aloud as natural English**
- [ ] **Every edge has a label**
- [ ] **Every label is a verb phrase (not a sentence, not a noun)**
- [ ] **Every node is a noun phrase (not a verb)**
- [ ] **Every node has at least one inbound or outbound edge** (no orphans)
- [ ] **Verb tense is consistent across all edges** (all present-tense singular)
- [ ] **No edge passes through any non-terminal node** — sample the curve at multiple t values; check each against every non-terminal ellipse
- [ ] **Every label rectangle sits on its actual curve midpoint** (within 5px of computed midpoint)
- [ ] **No label rectangle overlaps any node ellipse**
- [ ] **All labels are horizontal** (no rotation)
- [ ] **Every arrowhead lands fully outside its destination** (use pad ≥ 10)
- [ ] **Color usage is by meaning** (per the deterministic rule)
- [ ] **Edge weight matches edge category** (per the deterministic rule)
- [ ] **Type hierarchy consistent across nodes** (hero / primary / secondary tiers)
- [ ] **Visual mass roughly balanced** (no one quadrant dense + opposite empty)
- [ ] **Whitespace is at least 25–30% of the canvas**
- [ ] **Diagram passes the "would I put this in an executive deck" test**

---

## 12. When NOT to Use a Systemigram

Systemigrams are excellent for sociotechnical and organizational systems. They are wrong for:

- **Sequential workflows** where strict step ordering matters → flowchart
- **State machines** where transitions are the point → state diagram
- **Network topology** where physical/logical connections are the point → network diagram
- **Data flow with timing** → sequence diagram
- **Pure hierarchy** with no horizontal relationships → tree
- **Single-actor processes** → numbered steps

The systemigram's superpower is showing how multiple systems interact through named contracts. If there aren't multiple systems with contracts between them, pick a different diagram type.

---

## Reference

- **Diagrams skill** (`~/.rovodev/skills/diagrams/SKILL.md`) — base SVG conventions
- **Companion CLI** (`~/.rovodev/skills/systemigram/scripts/systemigram.py`) — automates geometry, validation, and snippet generation. Run `python ~/.rovodev/skills/systemigram/scripts/systemigram.py --agent-help` for a command index.
- **PRD** (`skills/systemigram/PRD.md`) — full CLI specification
