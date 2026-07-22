# PRD: `systemigram` CLI

A single-file Python CLI that automates the geometry, validation, and SVG-snippet generation needed to build polished systemigrams. Replaces the ad-hoc Python scratch scripts that get written every time a systemigram is built.

## Problem Statement

Building a polished systemigram requires repeated, error-prone geometry: computing ellipse boundary intersections, choosing Bezier control points that produce the right curve shape without crossing other nodes, locating the curve's actual midpoint for label placement, sampling the curve to detect collisions with non-terminal nodes, and emitting valid SVG snippets in a consistent style.

Today this is done by writing throwaway Python at every step, eyeballing results, and iterating against screenshots. Mistakes are common: arrows that pierce nodes, labels orphaned 50px from their curves, arrowheads buried in ellipse interiors, multi-segment paths whose hinge points are guessed.

**Goal:** a `systemigram` CLI that turns these recurring tasks into one-line invocations and validates a finished SVG against the cardinal rules from `SKILL.md`.

## Users and Usage Context

- **Primary user:** an AI agent (Skippy, or any successor) building systemigrams during a session
- **Secondary user:** the human reviewing the diagram and asking for changes
- **Invocation context:** the agent has open file access and a Python interpreter; CLI is invoked via `python systemigram.py <subcommand> [args]`
- **Deliverables:** the CLI either prints SVG snippets (to stdout) for the agent to insert into an SVG file, or validates an existing SVG file and prints a structured pass/fail report

## Non-Goals

- Not a full SVG editor or drag-and-drop GUI
- Not a graph layout solver (the human/agent decides node positions)
- Not a renderer (SVG is interpreted by the browser/MDV/etc.)
- Not language-agnostic (Python only, since that's what the agent already uses)

## Subcommand Surface

### `init <output.svg> [--width W] [--height H]`

Emit an empty SVG with the systemigram boilerplate `<defs>` (gradients for green/blue/purple/red/gray/amber, all five color-matched arrow markers plus amber, shadow filter, font-family, white background).

Default canvas: 1280 × 960. Override with `--width` and `--height`.

```
python systemigram.py init my_diagram.svg --width 1380
```

### `node <id> <cx> <cy> <rx> <ry> <domain> <title> [--sub-mission TEXT] [--children "a · b · c"] [--tier hero|primary|secondary]`

Emit the SVG snippet for a single node ellipse with consistent type hierarchy.

- `domain`: `green | blue | purple | red | gray | amber`
- `tier`: defaults to `primary`. Determines title font size (16 hero, 15 primary, 14 secondary), stroke width, and which sub-text fields render.

```
python systemigram.py node IP 200 150 140 78 green "Identity Platform" \
    --sub-mission "foundational layer" \
    --children "Foundation Capabilities · Interface Specs"
```

Output: a `<g>` block (ellipse + 1–3 text lines) ready to paste into the SVG body.

### `edge <src_x> <src_y> <src_rx> <src_ry> <dst_x> <dst_y> <dst_rx> <dst_ry> <verb> <category> [--bend FACTOR] [--hint left|right] [--pad N]`

Compute and emit a single quadratic-Bezier edge with verb label.

- Computes boundary endpoints on both source and destination ellipses (default pad=10)
- Computes Bezier control point with default bend factor by category (spine 0.12, gov 0.18, supp 0.18, prevent 0.22), perpendicular offset side via `--hint`
- Computes curve midpoint at t=0.5 for label position
- Emits the path, label rectangle, and label text in the correct color/weight/stroke per category

```
python systemigram.py edge 200 150 140 78 640 150 140 68 publishes spine
```

Output: three SVG elements (path, rect, text) ready to paste.

### `arrow <x1> <y1> <x2> <y2> --apex <ax> <ay> [--style spine|gov|supp|loop|prevent|amber]`

The "draw an arrow with a specific shape" subcommand. Given start, end, and the desired apex of the parabola, compute the quadratic Bezier control point that produces a curve passing through that apex, then emit the SVG path.

This solves the "I want the arrow to bend so its peak is here" problem that comes up constantly and is currently solved by guess-and-check.

Math: for a quadratic Bezier from P0 to P2 with control point P1, the curve point at t=0.5 is `0.25*(P0+P2) + 0.5*P1`. Solving for P1 given desired midpoint M: `P1 = 2*M - 0.5*(P0+P2)`.

```
python systemigram.py arrow 200 500 1080 500 --apex 640 440 --style spine
```

Output: the path snippet `<path d="M 200,500 Q 850,360 1080,500" .../>` (correct math), with style-determined stroke color and width.

### `loop <src_x> <src_y> <src_rx> <src_ry> <dst_x> <dst_y> <dst_rx> <dst_ry> <verb> --via <vx> <vy> [--via2 <v2x> <v2y>]`

Generate a multi-segment cubic Bezier path that hinges through one or two specified via-points. Used for long-range edges (typically learning loops) that need to thread between obstacles.

If only `--via` is given, generates a single cubic with control points around the via point. If `--via2` is also given, generates two cubic segments joined at the first via with the second segment heading toward via2 then the destination.

Computes label position at the via point (or midpoint of the path through both vias).

```
python systemigram.py loop 820 730 150 78 640 150 140 68 feeds-new --via 900 400
```

### `validate <input.svg>`

Parse an existing SVG and run all rules from `SKILL.md` Section 11. Print structured pass/fail report.

Rules implemented:

1. **XML parses cleanly**
2. **All `<text>` font-sizes ≥ 12px** (except white-on-gradient subtitles at 11px)
3. **Gradient count ≤ 6**
4. **Every `<path>` has `marker-end`** (i.e. is an arrow, not just a curve)
5. **Every arrow path has an associated `<rect>` + `<text>` label nearby** (within 30px of the path's midpoint)
6. **Every label is horizontal** (no `transform="rotate(..."` on label `<text>`)
7. **No path samples lie inside any non-terminal node ellipse** (sample 21 points along each path, check against every ellipse other than first/last terminating ellipse heuristically identified by proximity to path endpoints)
8. **Every arrowhead-end-point is at least 10px outside the destination ellipse**
9. **No label rectangle overlaps any node ellipse**

Output format:

```
SYSTEMIGRAM VALIDATION REPORT
File: my_diagram.svg
Canvas: 1280 × 960

✓ XML valid
✓ Font sizes: 47/47 ≥ 12px
✓ Gradient count: 6 ≤ 6
✓ All 12 paths are arrows (have marker-end)
✓ All 12 arrows have labels
✓ All labels horizontal

⚠ Path "feeds-new" (M 820,652 C 900,460 900,280 640,218): sample at t=0.7 (804,303) is 8px from AIF Framework boundary. RECOMMEND: increase control point x by 30px.

✗ Label "constrains" rect [383,335]-[473,357] overlaps with AIF Framework ellipse.

PASSED: 9/11 checks
FAILED: 2 issues — see above
```

The structured output lets the agent parse fixes deterministically.

### `geom <subcommand>` — geometry helper queries

Pure-math helpers that don't generate SVG, just compute and print numeric values.

- `geom boundary <cx> <cy> <rx> <ry> <px> <py> [--pad N]` → boundary point
- `geom ctrl <x1> <y1> <x2> <y2> <bend>` → quadratic control point
- `geom midpoint quad <x1> <y1> <cx> <cy> <x2> <y2>` → quadratic midpoint
- `geom midpoint cubic <x1> <y1> <c1x> <c1y> <c2x> <c2y> <x2> <y2>` → cubic midpoint
- `geom in_ellipse <px> <py> <cx> <cy> <rx> <ry>` → bool

For when the agent needs a quick geometry check without committing to a full edge.

```
python systemigram.py geom boundary 640 400 150 78 820 730 --pad 10
# → (783.4, 470.6)
```

### `spine <verb1> <noun1> <verb2> <noun2> ...`

Convenience: take a sentence read aloud and print it back parsed as a chain of `(node, verb, node)` triples for sanity-checking.

```
python systemigram.py spine "Identity Platform" publishes Specifications constrains Teams build "Customer Outcomes"
# Identity Platform → publishes → Specifications → constrains → Teams → build → Customer Outcomes
# 3 edges, 4 nodes
# WARNING: 'build' is plural form — use 'builds' for present-tense singular consistency
```

Catches verb-tense inconsistency before it ends up in the SVG.

## Domain / Style Constants

Centralized in the script, not exposed as flags (these are the systemigram visual identity):

```python
DOMAIN = {
    'green':  {'stroke': '#00875A', 'text': '#00644E', 'grad': 'gGreen',  'arrow': 'arrGreen'},
    'blue':   {'stroke': '#0747A6', 'text': '#0747A6', 'grad': 'gBlue',   'arrow': 'arrBlue'},
    'purple': {'stroke': '#5243AA', 'text': '#403294', 'grad': 'gPurple', 'arrow': 'arrPurple'},
    'red':    {'stroke': '#BF2600', 'text': '#9F1F00', 'grad': 'gRed',    'arrow': 'arrRed'},
    'gray':   {'stroke': '#42526E', 'text': '#172B4D', 'grad': 'gGray',   'arrow': 'arrGray'},
    'amber':  {'stroke': '#974F00', 'text': '#974F00', 'grad': 'gAmber',  'arrow': 'arrAmber'},
}

CATEGORY = {
    'spine':   {'width': 2.4, 'dash': None,  'bend': 0.12, 'force_color': None},
    'gov':     {'width': 2.0, 'dash': None,  'bend': 0.18, 'force_color': 'purple'},
    'supp':    {'width': 1.8, 'dash': None,  'bend': 0.18, 'force_color': None},
    'loop':    {'width': 2.6, 'dash': None,  'bend': 0.40, 'force_color': 'amber'},
    'prevent': {'width': 1.8, 'dash': '6,3', 'bend': 0.22, 'force_color': 'red'},
    'anchors': {'width': 2.0, 'dash': '6,3', 'bend': 0.18, 'force_color': 'purple'},
}

TIER = {
    'hero':      {'title_size': 16, 'title_weight': 700, 'stroke_width': 2.6},
    'primary':   {'title_size': 15, 'title_weight': 700, 'stroke_width': 2.0},
    'secondary': {'title_size': 14, 'title_weight': 700, 'stroke_width': 1.6},
}
```

## Implementation Notes

- **Single file**, `systemigram.py`, no external dependencies beyond Python stdlib (`math`, `argparse`, `xml.etree.ElementTree` for `validate`).
- Subcommand routing via `argparse` subparsers.
- All output to stdout (the agent paste-buffers it). `validate` writes to stdout in human-readable format with a `--json` flag for machine parsing.
- Float coordinates rounded to 1 decimal place in SVG output.
- Rect width auto-computed from label text (`max(50, len(text) * font_size * 0.62 + 16)`).
- Label rect height fixed at 22px.
- Sample density for validation: 21 points along each path (t=0, 0.05, 0.10, ..., 1.0).

## Acceptance Criteria

The CLI is "done" when:

1. All subcommands work and produce SVG that pastes directly into a systemigram file
2. `validate` correctly identifies the bug classes from `SKILL.md` Section 4
3. The agentic identity systemigram (`~/.beercan/docs/diagrams/agentic_identity_systemigram.svg`) can be **regenerated end-to-end from CLI calls** in a script and the result is byte-equivalent to the hand-built version
4. The CLI catches at least 3 categories of polish bugs the agent has historically missed: arrowheads buried in ellipses, labels orphaned from curves, paths passing through non-terminal nodes
5. Total file size under 800 lines of Python (it's a focused tool, not a framework)

## Future Extensions (Out of Scope for v1)

- `compose <stage1.svg> <stage2.svg>` to interleave staged diagrams
- `theme <name>` for alternate color palettes
- `auto-layout` for initial node placement given a node/edge spec
- HTML/PNG export for embedding outside SVG-aware contexts
- Live preview integration with MDV
