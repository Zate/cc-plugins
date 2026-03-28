# Excalidraw Workflow

## Creation Flow

```
1. Plan layout    --> Estimate positions, choose camera sizes
2. create_view    --> Renders inline with streaming animations
3. User reviews   --> Sees diagram with camera pans
4. Iterate        --> Use checkpointId to restore + modify
5. Export          --> export_to_excalidraw for shareable URL
```

## Iteration with Checkpoints

After `create_view`, the response includes a `checkpointId`.

**To add elements:**
```json
[
  {"type": "restoreCheckpoint", "id": "<checkpointId>"},
  {"type": "rectangle", "id": "newBox", ...}
]
```

**To replace elements:**
```json
[
  {"type": "restoreCheckpoint", "id": "<checkpointId>"},
  {"type": "delete", "ids": "oldBox"},
  {"type": "rectangle", "id": "newBox", ...}
]
```

**To zoom/pan to a section:**
```json
[
  {"type": "restoreCheckpoint", "id": "<checkpointId>"},
  {"type": "cameraUpdate", "width": 400, "height": 300, "x": 200, "y": 100}
]
```

## Camera Animation Patterns

### Progressive Build (most common)
1. Zoom in on title area (M camera)
2. Draw title and subtitle
3. Pan to first section (M camera)
4. Draw section elements
5. Pan to next section
6. Repeat for each section
7. Zoom out to full view (L or XL camera)

### Section Focus
1. Start with overview (L camera)
2. Zoom into detail area (S camera)
3. Draw detail elements
4. Zoom back out

### Transform Animation
1. Draw initial state
2. Camera nudge (shift 1px)
3. Delete old elements
4. Draw new elements at same positions
5. Camera nudge again
6. Creates smooth transformation effect

## Export Options

| Method | Result |
|--------|--------|
| `export_to_excalidraw` | Shareable URL on excalidraw.com |
| Copy JSON from checkpoint | Can be pasted into any Excalidraw instance |
| Save `.excalidraw` file | Write JSON to local file for offline use |

## Tips

- Camera pans are the signature feature -- use them generously
- Draw progressively (shape -> label -> arrow) not by type (all shapes -> all arrows)
- Background zones should be drawn before the elements they contain
- Art/decorations go last
- Keep labels short -- long text overflows small shapes
- Test readability at the chosen camera size before finalizing
