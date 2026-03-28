# Excalidraw Workflow

## Creation Flow

```
1. Plan layout    --> Estimate positions, sizes, connections
2. Build JSON     --> Construct the .excalidraw file structure
3. Write file     --> Save as .excalidraw using Write tool
4. User views     --> Opens in Excalidraw app/web/VS Code/Obsidian
5. Iterate        --> User requests changes, update and re-save
```

## File Structure

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

## Element Construction Order

Build elements in this order for clean relationships:
1. Background zones/groups (largest rectangles, low opacity)
2. Shapes (rectangles, ellipses, diamonds)
3. Bound text (text with `containerId` referencing shapes)
4. Arrows (with `startBinding`/`endBinding` referencing shapes)
5. Standalone labels/annotations

## Binding Checklist

For every arrow-shape connection:
1. Arrow has `startBinding.elementId` or `endBinding.elementId` pointing to the shape
2. Shape has `boundElements` array including `{ "type": "arrow", "id": "arrow-id" }`

For every text-inside-shape:
1. Text has `containerId` pointing to the shape
2. Shape has `boundElements` array including `{ "type": "text", "id": "text-id" }`

Missing either side of the binding means the connection won't work in Excalidraw.

## Viewing Options

| Tool | How to Open |
|------|-------------|
| Excalidraw web | excalidraw.com -- drag & drop or File > Open |
| VS Code | Install Excalidraw extension, double-click .excalidraw file |
| Obsidian | Install Excalidraw plugin, embed or open file |
| Desktop app | Open with Excalidraw desktop |

## Tips

- Use descriptive element IDs (`"box-auth-service"` not `"r1"`) for easier iteration
- Keep labels short -- long text overflows small shapes
- Use `fontFamily: 1` (Virgil) for the hand-drawn aesthetic, `2` (Helvetica) for cleaner text
- Generous spacing prevents the hand-drawn style from looking cluttered
- Background zones at low opacity (30-40) create visual grouping without overwhelming
