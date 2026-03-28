# Diagrams Plugin Test Suite

Test prompts organized by format. Run each prompt, evaluate output against the quality checklist.

---

## SVG Tests

### SVG-1: Layered Architecture (Simple)
**Prompt**: "Draw a 3-layer architecture: Frontend (React SPA), API Gateway (Kong), Backend Services (Auth, Users, Payments)"
**Expected**: Top-down stack, 3 layers, gradient fills, shadow depth, SVG output

### SVG-2: Sequence Diagram (Medium)
**Prompt**: "Create an SVG sequence diagram showing OAuth2 authorization code flow between Browser, App Server, and Auth Provider."
**Expected**: 3 lifelines, 6+ messages, activation bars, step numbers

### SVG-3: Threat Model (SVG-specific)
**Prompt**: "Draw a threat model for a web app with: load balancer in DMZ, app server in trusted zone, database in restricted zone. Show trust boundaries and threat actors."
**Expected**: Dashed trust boundaries, threat actors outside boundaries, data flow arrows

### SVG-4: Comparison (SVG-specific)
**Prompt**: "Side-by-side comparison of Monolith vs Microservices. Show: Deployment, Scaling, Complexity, Team Independence."
**Expected**: Two equal panels, clear divider, matching rows

### SVG-5: Hub and Spoke (SVG-specific)
**Prompt**: "Hub-and-spoke diagram with API Gateway at center connected to 6 services."
**Expected**: Central hub, radial spokes, equal spacing, protocol labels

---

## Mermaid Tests

### MRM-1: Flowchart (Simple)
**Prompt**: "Create a Mermaid flowchart for a CI/CD pipeline: Code Push, Build, Test, Deploy Staging, Smoke Test, Deploy Prod."
**Expected**: Valid Mermaid syntax, flowchart LR, decision diamonds for tests

### MRM-2: Sequence (Medium)
**Prompt**: "Mermaid sequence diagram for user authentication: Client, API Gateway, Auth Service, Database."
**Expected**: Valid sequenceDiagram, activate/deactivate, solid + dashed arrows

### MRM-3: ER Diagram (Medium)
**Prompt**: "Mermaid ER diagram for an e-commerce system with Users, Orders, Products, LineItems, Payments."
**Expected**: Valid erDiagram, crow's foot notation, attributes with types

### MRM-4: State Machine (Simple)
**Prompt**: "Mermaid state diagram for order lifecycle: Created, Confirmed, Processing, Shipped, Delivered, Cancelled."
**Expected**: Valid stateDiagram-v2, transitions with labels, start/end markers

### MRM-5: Mind Map (Simple)
**Prompt**: "Mermaid mind map of a full-stack tech stack: Frontend, Backend, Database, Infrastructure."
**Expected**: Valid mindmap, 3-4 branches, 2-3 levels

---

## Excalidraw Tests

### EXC-1: Architecture Overview (Medium)
**Prompt**: "Create an Excalidraw diagram showing a 3-tier web architecture with frontend, backend, and database."
**Expected**: Labeled rectangles with pastel fills, arrows with bindings, camera panning

### EXC-2: Whiteboard Brainstorm (Simple)
**Prompt**: "Excalidraw whiteboard brainstorming the features for a new todo app."
**Expected**: Hand-drawn aesthetic, scattered boxes, grouping, informal feel

### EXC-3: Sequence with Animation (Medium)
**Prompt**: "Excalidraw sequence diagram showing how MCP tools work."
**Expected**: Lifeline dashes, progressive camera reveal, labeled arrows

---

## D2 Tests

### D2-1: Nested Architecture (Medium)
**Prompt**: "D2 diagram of AWS infrastructure: VPC with public subnet (ALB), private subnet (ECS, RDS)."
**Expected**: Valid D2, nested containers, shape types (cylinder, hexagon)

### D2-2: Microservices (Medium)
**Prompt**: "D2 diagram showing 5 microservices connected through an API gateway."
**Expected**: Valid D2, labeled connections, service containers

---

## Router Tests

### RTR-1: Auto-select SVG (default)
**Prompt**: "Draw a diagram showing the trust boundaries in our payment system."
**Expected**: Router selects SVG (threat model type, no format specified)

### RTR-2: Auto-select Mermaid (docs)
**Prompt**: "Create a diagram for the README showing our deployment flow."
**Expected**: Router selects Mermaid (README context)

### RTR-3: Auto-select Excalidraw (informal)
**Prompt**: "Quick whiteboard sketch of the new feature architecture."
**Expected**: Router selects Excalidraw (whiteboard/sketch signal)

### RTR-4: Explicit format override
**Prompt**: "Draw this as a Mermaid diagram: OAuth2 sequence flow."
**Expected**: Router uses Mermaid despite SVG being better for sequences

---

## Quality Checklist (All Formats)

### Universal
- [ ] Diagram type matches content (not generic box-and-arrow)
- [ ] Labels match requested terminology exactly
- [ ] Element count within complexity limits
- [ ] Color used semantically
- [ ] Text is readable at expected display size

### SVG-Specific
- [ ] Has `<title>`, `<desc>`, `role="img"`
- [ ] Uses `<defs>` for gradients, shadows, markers
- [ ] Has `viewBox` (no fixed width/height)
- [ ] System font stack
- [ ] No `rgba()` in fill/stroke (use fill-opacity)
- [ ] No CSS style on `<svg>` element

### Mermaid-Specific
- [ ] Valid syntax (renders without errors)
- [ ] Correct diagram type keyword
- [ ] Special characters escaped/quoted
- [ ] Labels under 30 characters

### Excalidraw-Specific
- [ ] Valid JSON elements array
- [ ] Camera update as first element
- [ ] 4:3 camera ratio
- [ ] Font size >= 14px
- [ ] Progressive draw order (not all shapes then all arrows)

### D2-Specific
- [ ] Valid D2 syntax
- [ ] All referenced nodes defined
- [ ] Nesting <= 4 levels
- [ ] Shapes semantically appropriate

## Running Tests

1. Start a session with the diagrams plugin loaded
2. Run each test prompt
3. Verify format selection (router tests) and output quality
4. Save outputs to `tests/output/`
5. Check against quality checklist
6. Document issues in `tests/results.md`
