---
name: excalidraw
description: Generate diagrams with a hand-drawn whiteboard aesthetic using Excalidraw. Use when the diagram-router selects Excalidraw, or when the user wants informal sketches, whiteboard-style visuals, or diagrams they can edit later in Excalidraw. Renders inline with streaming animations. REQUIRES the Excalidraw MCP server (claude_ai Excalidraw) -- check availability before using.
---

# Excalidraw Diagram Skill

Generate diagrams using the Excalidraw MCP tools. Produces hand-drawn-style visuals that render inline with draw-on animations and camera panning.

## IMPORTANT: External Dependency

This skill requires the **Excalidraw MCP server** (`mcp__claude_ai_Excalidraw__*` tools). This is an Anthropic-provided MCP server that may be available in Claude Code but is **not part of this plugin** and **not guaranteed to be present**.

**Before using this skill, you MUST check availability:**

1. Look for `mcp__claude_ai_Excalidraw__create_view` in the available tools list
2. If NOT available: **do not attempt to use this skill** -- fall back to SVG and inform the user: "Excalidraw rendering requires the Excalidraw MCP server which isn't available in this session. I'll generate this as SVG instead."
3. If available: proceed with the workflow below

**This skill will not work without the MCP server.** There is no fallback Excalidraw generation -- the MCP tools ARE the rendering engine.

**When to use Excalidraw (if available):**
- User explicitly asks for Excalidraw / whiteboard / sketch / hand-drawn
- Diagrams for brainstorming, early design, or informal communication
- User wants to edit the diagram later (export to excalidraw.com)
- Visual explanations with progressive reveal (camera animations)

**When another format is better:**
- Formal documentation or whitepapers (SVG)
- Pixel-precise positioning (SVG)
- MCP server not available (SVG)

Consult the **design-system** skill for color theory, composition, and quality rules.

## Workflow

### 1. Check Availability and Read Format Reference

First, confirm `mcp__claude_ai_Excalidraw__create_view` is in the available tools. If not, stop and fall back to SVG.

If available, call `mcp__claude_ai_Excalidraw__read_me` to load the element format, color palette, and tips. Do this once per session.

### 2. Plan the Diagram

Before generating elements:
- Identify all elements (boxes, arrows, labels) and their relationships
- Plan the spatial layout on a grid (estimate x, y, width, height for each)
- Choose camera size: S (400x300), M (600x450), L (800x600), XL (1200x900)
- Plan camera sequence for progressive reveal (zoom into sections, then zoom out)

### 3. Generate with `create_view`

Build the JSON elements array following these rules:

**Element ordering (critical for streaming):**
1. `cameraUpdate` first (set initial viewport)
2. Background zones/regions
3. For each logical group: shape -> label -> arrows -> next shape
4. Camera pans between sections
5. Decorative elements last

**Camera animation strategy:**
- Start zoomed in on the title or first section
- Pan/zoom to each section as you draw it
- End with a zoom-out showing the full diagram
- Users love camera pans -- use them generously

**Sizing rules:**
- Minimum shape: 120x60 for labeled elements
- Minimum fontSize: 16 for body text, 20 for titles
- Minimum gap between elements: 20-30px
- Camera must be 4:3 ratio (400x300, 600x450, 800x600, 1200x900, 1600x1200)

### 4. Iterate with Checkpoints

After `create_view`, the response includes a `checkpointId`. To modify:
- Start the next elements array with `{"type": "restoreCheckpoint", "id": "<checkpointId>"}`
- Add new elements or use `{"type": "delete", "ids": "id1,id2"}` to remove
- Never reuse deleted element IDs

### 5. Export

When the user is happy, use `mcp__claude_ai_Excalidraw__export_to_excalidraw` to get a shareable URL at excalidraw.com where they can further edit.

## Color Palette

Use the Excalidraw pastel fills for shape backgrounds:

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

For background zones (use opacity: 30-35):

| Zone | Hex | Use For |
|---|---|---|
| Blue zone | `#dbe4ff` | UI / frontend layer |
| Purple zone | `#e5dbff` | Logic / agent layer |
| Green zone | `#d3f9d8` | Data / tool layer |

## Element Patterns

### Labeled Box (preferred -- saves tokens)

```json
{
  "type": "rectangle", "id": "r1", "x": 100, "y": 100,
  "width": 200, "height": 80,
  "roundness": { "type": 3 },
  "backgroundColor": "#a5d8ff", "fillStyle": "solid",
  "strokeColor": "#4a9eed",
  "label": { "text": "Service Name", "fontSize": 16 }
}
```

### Connected Arrow with Binding

```json
{
  "type": "arrow", "id": "a1", "x": 300, "y": 140,
  "width": 150, "height": 0,
  "points": [[0,0], [150,0]],
  "endArrowhead": "arrow",
  "startBinding": { "elementId": "r1", "fixedPoint": [1, 0.5] },
  "endBinding": { "elementId": "r2", "fixedPoint": [0, 0.5] },
  "label": { "text": "REST API", "fontSize": 14 }
}
```

### Background Zone

```json
{
  "type": "rectangle", "id": "zone1", "x": 80, "y": 80,
  "width": 500, "height": 300,
  "backgroundColor": "#d3f9d8", "fillStyle": "solid",
  "roundness": { "type": 3 },
  "strokeColor": "#22c55e", "strokeWidth": 1,
  "opacity": 35
}
```

## Common Mistakes to Avoid

1. **Non-4:3 camera ratio** -- causes distortion. Use exact sizes: 400x300, 600x450, 800x600, 1200x900
2. **Font too small** -- minimum 14px for annotations, 16px for labels, 20px for titles
3. **No cameraUpdate first** -- always start with a cameraUpdate element
4. **Light text on white** -- minimum text color on white: `#757575`. Use dark variants for colored text
5. **Reusing deleted IDs** -- always assign new IDs to replacement elements
6. **All elements then all arrows** -- draw progressively: shape -> its label -> its arrows -> next shape
7. **Skipping camera pans** -- camera movement makes diagrams engaging, use generously
8. **Elements outside camera viewport** -- ensure content falls within the camera view with padding

## Dark Mode

If requested, add a massive dark background as the FIRST element:
```json
{"type": "rectangle", "id": "darkbg", "x": -4000, "y": -3000,
 "width": 10000, "height": 7500,
 "backgroundColor": "#1e1e2e", "fillStyle": "solid",
 "strokeColor": "transparent", "strokeWidth": 0}
```

Then use dark fill variants: `#1e3a5f` (blue), `#1a4d2e` (green), `#2d1b69` (purple), `#5c3d1a` (orange). Text: `#e5e5e5` (primary), `#a0a0a0` (secondary).

## MCP Tools Reference

| Tool | Purpose |
|---|---|
| `mcp__claude_ai_Excalidraw__read_me` | Load format reference (once per session) |
| `mcp__claude_ai_Excalidraw__create_view` | Render diagram from JSON elements |
| `mcp__claude_ai_Excalidraw__export_to_excalidraw` | Export to shareable excalidraw.com URL |
| `mcp__claude_ai_Excalidraw__save_checkpoint` | Save current state |
| `mcp__claude_ai_Excalidraw__read_checkpoint` | Restore saved state |
