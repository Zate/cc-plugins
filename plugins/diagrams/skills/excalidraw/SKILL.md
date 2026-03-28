---
name: excalidraw
description: Generate diagrams with a hand-drawn whiteboard aesthetic by writing .excalidraw files directly. Use when the user wants informal sketches, whiteboard-style visuals, or diagrams they can open and edit in Excalidraw. Saves a local .excalidraw file -- viewing/rendering is handled separately.
---

# Excalidraw Diagram Skill

Generate diagrams by writing `.excalidraw` files directly. The output is a JSON file in the Excalidraw format that can be opened in the Excalidraw desktop app, web app (excalidraw.com), VS Code extension, or Obsidian plugin.

**IMPORTANT: Do NOT use the Excalidraw MCP tools** (`mcp__claude_ai_Excalidraw__*`), even if they are available. We generate the file ourselves for full control over quality and layout. The MCP tools produce lower quality results and require uploading to excalidraw.com.

**When to use Excalidraw:**
- User explicitly asks for Excalidraw / whiteboard / sketch / hand-drawn style
- Diagrams for brainstorming, early design, or informal communication
- User wants an editable diagram file they can refine in Excalidraw

**When another format is better:**
- Formal documentation or whitepapers (SVG)
- Pixel-precise positioning (SVG)
- Inline in GitHub markdown (Mermaid)

Consult the **design-system** skill for color, composition, and quality rules.

## Workflow

### 1. Plan the Layout

Before generating the file:
- Identify all elements (boxes, arrows, labels) and their relationships
- Plan the spatial layout on a grid (estimate x, y, width, height for each)
- Use generous spacing: 40-60px between peer elements, 20-30px padding inside groups

### 2. Build the Excalidraw JSON

An `.excalidraw` file is JSON with this top-level structure:

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "diagrams-plugin",
  "elements": [ ... ],
  "appState": {
    "viewBackgroundColor": "#ffffff",
    "gridSize": null
  },
  "files": {}
}
```

### 3. Write the File

Save with `.excalidraw` extension using the Write tool. The user handles viewing/rendering.

## Element Format

### Required Fields (all elements)

Every element needs: `type`, `id` (unique string), `x`, `y`, `width`, `height`, `version`, `versionNonce`, `isDeleted`, `groupIds`, `boundElements`, `seed`.

Use this template for default fields:

```json
{
  "version": 1,
  "versionNonce": 1,
  "isDeleted": false,
  "fillStyle": "solid",
  "strokeWidth": 2,
  "strokeStyle": "solid",
  "roughness": 1,
  "opacity": 100,
  "groupIds": [],
  "frameId": null,
  "roundness": null,
  "seed": 1,
  "updated": 1,
  "locked": false,
  "link": null
}
```

Generate unique `id` values for each element (use descriptive strings like `"box-auth-service"`, `"arrow-to-db"`). Generate unique `seed` values per element (use incrementing integers: 1000, 1001, 1002...).

### Element Types

**Rectangle:**
```json
{
  "type": "rectangle",
  "id": "box-1",
  "x": 100, "y": 100,
  "width": 200, "height": 80,
  "strokeColor": "#1e1e1e",
  "backgroundColor": "#a5d8ff",
  "fillStyle": "solid",
  "roundness": { "type": 3 },
  "seed": 1000
}
```

**Ellipse:**
```json
{
  "type": "ellipse",
  "id": "oval-1",
  "x": 100, "y": 100,
  "width": 150, "height": 100,
  "strokeColor": "#1e1e1e",
  "backgroundColor": "#b2f2bb",
  "fillStyle": "solid",
  "seed": 1001
}
```

**Diamond:**
```json
{
  "type": "diamond",
  "id": "decision-1",
  "x": 100, "y": 100,
  "width": 120, "height": 120,
  "strokeColor": "#1e1e1e",
  "backgroundColor": "#fff3bf",
  "fillStyle": "solid",
  "seed": 1002
}
```

**Text:**
```json
{
  "type": "text",
  "id": "label-1",
  "x": 150, "y": 130,
  "width": 100, "height": 25,
  "text": "Service Name",
  "fontSize": 20,
  "fontFamily": 1,
  "textAlign": "center",
  "verticalAlign": "middle",
  "strokeColor": "#1e1e1e",
  "seed": 1003
}
```

`fontFamily`: 1 = Virgil (hand-drawn), 2 = Helvetica, 3 = Cascadia (code).

**Bound Text (text inside a shape):**

To put text inside a shape, create a text element with `containerId` pointing to the shape, and add the text to the shape's `boundElements`:

Shape:
```json
{
  "type": "rectangle",
  "id": "box-1",
  "boundElements": [{ "type": "text", "id": "label-box-1" }],
  ...
}
```

Text:
```json
{
  "type": "text",
  "id": "label-box-1",
  "containerId": "box-1",
  "x": 120, "y": 125,
  "width": 160, "height": 25,
  "text": "Auth Service",
  "fontSize": 20,
  "fontFamily": 1,
  "textAlign": "center",
  "verticalAlign": "middle",
  ...
}
```

**Arrow:**
```json
{
  "type": "arrow",
  "id": "arrow-1",
  "x": 300, "y": 140,
  "width": 150, "height": 0,
  "points": [[0, 0], [150, 0]],
  "strokeColor": "#1e1e1e",
  "startArrowhead": null,
  "endArrowhead": "arrow",
  "startBinding": {
    "elementId": "box-1",
    "focus": 0,
    "gap": 5,
    "fixedPoint": [1, 0.5]
  },
  "endBinding": {
    "elementId": "box-2",
    "focus": 0,
    "gap": 5,
    "fixedPoint": [0, 0.5]
  },
  "seed": 1004
}
```

Arrow `points` are offsets from `x, y`. For multi-segment arrows, add intermediate points: `[[0,0], [100,0], [100,80], [200,80]]`.

Shapes with bound arrows need `boundElements` entries:
```json
"boundElements": [
  { "type": "arrow", "id": "arrow-1" }
]
```

### fixedPoint Reference

`fixedPoint: [x, y]` where 0,0 is top-left and 1,1 is bottom-right:
- Top center: `[0.5, 0]`
- Bottom center: `[0.5, 1]`
- Left center: `[0, 0.5]`
- Right center: `[1, 0.5]`

## Color Palette

Use Excalidraw's pastel fills for shape backgrounds:

| Fill Color | Hex | Use For |
|---|---|---|
| Light Blue | `#a5d8ff` | Input, sources, primary nodes |
| Light Green | `#b2f2bb` | Success, output, completed |
| Light Orange | `#ffd8a8` | Warning, pending, external |
| Light Purple | `#d0bfff` | Processing, middleware, special |
| Light Red | `#ffc9c9` | Error, critical, alerts |
| Light Yellow | `#fff3bf` | Notes, decisions, planning |
| Light Teal | `#c3fae8` | Storage, data, memory |
| Light Pink | `#eebefa` | Analytics, metrics |

For background zones (use lower opacity: 30-40):

| Zone | Hex | Use For |
|---|---|---|
| Blue zone | `#dbe4ff` | UI / frontend layer |
| Purple zone | `#e5dbff` | Logic / agent layer |
| Green zone | `#d3f9d8` | Data / tool layer |

Stroke colors: use darker variants of the fill (`#1971c2` for blue, `#2f9e44` for green, etc.) or `#1e1e1e` for neutral.

## Sizing Rules

- Minimum shape: 120x60 for labeled elements
- Minimum fontSize: 16 for body text, 20 for titles, 14 for annotations only
- Minimum gap between elements: 30px
- Arrow labels: keep short (under 20 characters)

## Common Mistakes to Avoid

1. **Missing `boundElements`** on shapes that have arrows or text -- arrows won't visually connect
2. **Missing `containerId`** on text inside shapes -- text won't be bound to the shape
3. **Duplicate IDs** -- every element must have a unique `id`
4. **Duplicate seeds** -- every element needs a unique `seed` value
5. **Font too small** -- minimum 14px, prefer 16-20px
6. **Forgetting default fields** -- missing `version`, `versionNonce`, `isDeleted`, etc. can cause parse errors
7. **Arrow points not matching width/height** -- the last point's offsets should equal `width` and `height`

## Output

Save the file with `.excalidraw` extension:
```
diagram-name.excalidraw
```

The user can open it in:
- **Excalidraw web**: excalidraw.com (drag and drop or File > Open)
- **VS Code**: Excalidraw extension
- **Obsidian**: Excalidraw plugin
- **Desktop**: Excalidraw desktop app

## Dark Mode

Set in `appState`:
```json
"appState": {
  "viewBackgroundColor": "#1e1e2e",
  "theme": "dark"
}
```

Use dark fill variants: `#1e3a5f` (blue), `#1a4d2e` (green), `#2d1b69` (purple), `#5c3d1a` (orange). Stroke: `#e5e5e5` or `#a0a0a0`. Text: `#e5e5e5`.
