---
name: diagram-router
description: Automatically select the best diagram format (SVG, Mermaid, Excalidraw, D2) and diagram type based on user intent. Use when the user asks to create, draw, visualize, or diagram something and has not specified a format. Routes to the appropriate format-specific skill.
---

# Diagram Router

Select the best output format and diagram type for the user's request, then delegate to the format-specific skill.

## Step 1: Did the User Specify a Format?

If the user explicitly requests a format, use it:
- "Draw this in SVG" / "as SVG" / "raw SVG" --> **svg** skill
- "Mermaid diagram" / "in mermaid" / "as mermaid" --> **mermaid** skill
- "Excalidraw" / "whiteboard style" / "hand-drawn" --> **excalidraw** skill
- "D2 diagram" / "in d2" --> **d2** skill

If they specified a format, skip to Step 3.

## Step 2: Select Format from Context

**Default: SVG. Always.** SVG produces the highest visual quality, handles every diagram type, and renders everywhere (browsers, GitHub, docs, presentations). Only route away from SVG when the user explicitly names another format.

| Context Signal | Format | Why |
|---|---|---|
| No specific signal | **SVG** | Best quality, most flexible, browser-native |
| "For the README" / "in markdown" / "GitHub" | **SVG** | GitHub renders SVG natively. Quality matters. |
| "Quick" / "simple" / "basic" | **SVG** | Still SVG -- it handles simple diagrams well too |
| User explicitly says "mermaid" | **Mermaid** | They asked for it |
| User explicitly says "excalidraw" / "whiteboard" / "sketch" / "hand-drawn" | **Excalidraw** | Hand-drawn aesthetic, saves .excalidraw file |
| User explicitly says "d2" | **D2** | They asked for it |

**The rule is simple: SVG unless the user says otherwise.** The user can always convert later ("convert that to mermaid", "make that an excalidraw", etc.).

## Step 3: Select Diagram Type

If the user described what they want to visualize but did not name a diagram type, infer it:

| What They Described | Diagram Type |
|---|---|
| System components, layers, platform | Layered architecture |
| Service communication, API calls, request flow | Sequence diagram |
| Steps in a process, pipeline, workflow | Flowchart |
| Who handles each step, team responsibilities | Swimlane |
| Object lifecycle, status transitions | State machine |
| Database tables and relationships | ER diagram |
| Module/package dependencies | Dependency graph |
| Option A vs option B, before/after | Comparison (side-by-side) |
| Project phases, milestones, releases | Timeline / Gantt |
| Security boundaries, attack surface | Threat model / DFD |
| Topics and subtopics, brainstorm | Mind map |
| Central service with consumers | Hub and spoke |
| Set overlaps, shared characteristics | Venn diagram |
| Decision logic, branching conditions | Decision tree |
| Volume distribution, traffic flow | Sankey diagram |
| Team structure, hierarchy | Org chart / tree |
| Cloud infrastructure, network topology | Network diagram |
| How software maps to infrastructure | Deployment diagram |

If ambiguous, briefly confirm with the user: "This sounds like a [type] -- does that match what you have in mind?"

## Step 4: Delegate

Load the selected format skill and follow its workflow:

- **SVG**: Consult the `svg` skill and its references (svg-design-system.md, layout-patterns.md)
- **Mermaid**: Consult the `mermaid` skill
- **Excalidraw**: Consult the `excalidraw` skill
- **D2**: Consult the `d2` skill

Always consult the **design-system** skill for color, composition, and quality rules regardless of format.

## Step 5: Handle Conversion Requests

Users frequently want to convert between formats or extract styles. Common patterns:

**Format conversion:**
- "Convert that SVG to mermaid" --> Read the SVG, extract the structure, generate equivalent Mermaid syntax
- "Can we make that a D2 file instead?" --> Read the source, translate to D2's container/connection syntax
- "Export that as Excalidraw" --> Rebuild using Excalidraw JSON elements + MCP tools

**Style extraction from images:**
- "Here's a screenshot of a diagram style I like -- make ours look like that" --> Analyze the image for color palette, layout style, typography, element shapes, then apply those visual choices to the content
- "Match the style of this existing diagram" --> Extract design tokens (colors, border radius, spacing, font sizes) and apply to new content

**Cross-format iteration:**
- User starts with SVG for quality, later asks for Mermaid for embedding in docs
- User starts with Excalidraw for brainstorming, later asks for SVG for the final polished version
- User provides a hand-drawn sketch or screenshot and asks for a clean version

When converting, preserve:
1. **All content** -- labels, relationships, grouping
2. **Semantic meaning** -- which elements are primary/secondary, flow direction
3. **Design intent** -- colors, emphasis, hierarchy (adapt to target format's capabilities)

Accept that some fidelity is lost when converting to simpler formats (SVG to Mermaid loses custom positioning and gradients). Mention this to the user.
