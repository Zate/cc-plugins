# Diagrams Test Suite

Run each prompt, save the SVG output, and evaluate against the quality checklist.

## Test Prompts

### Test 1: Layered Architecture (Simple)
**Prompt**: "Draw a 3-layer architecture: Frontend (React SPA), API Gateway (Kong), Backend Services (Auth, Users, Payments)"
**Expected**: Top-down stack, 3 layers, 3 services in bottom layer, gradient fills, shadow depth
**Canvas**: ~1400x800

### Test 2: Sequence Diagram (Medium)
**Prompt**: "Create a sequence diagram showing OAuth2 authorization code flow between Browser, App Server, and Auth Provider. Show: redirect to auth, user login, auth code return, token exchange, API call with token."
**Expected**: 3 lifelines, 6+ messages (mix of sync/async), activation bars, step numbers
**Canvas**: ~1200x900

### Test 3: Flow Diagram (Simple)
**Prompt**: "Visualize a CI/CD pipeline: Code Push → Build → Unit Tests → Integration Tests → Deploy to Staging → Smoke Tests → Deploy to Production. Mark the test stages with pass/fail decision points."
**Expected**: Left-to-right flow, decision diamonds for tests, 7-8 steps, clear directional arrows
**Canvas**: ~1600x600

### Test 4: Threat Model (Complex)
**Prompt**: "Draw a threat model for a web application with: Internet-facing load balancer, web server in DMZ, application server in trusted zone, database in restricted zone. Show trust boundaries, data flows, and threat actors."
**Expected**: Trust boundary dashed regions, threat actors outside boundaries, data flow arrows crossing boundaries
**Canvas**: ~1400x1000

### Test 5: State Machine (Medium)
**Prompt**: "Create a state machine for an order lifecycle: Created → Confirmed → Processing → Shipped → Delivered. Also show: Created → Cancelled, Processing → Failed → Retry → Processing."
**Expected**: Pill-shaped states, curved transition arrows, guard conditions, start/end markers
**Canvas**: ~1200x700

### Test 6: Comparison (Simple)
**Prompt**: "Side-by-side comparison of Monolith vs Microservices architecture. Show 4 factors: Deployment, Scaling, Complexity, Team Independence."
**Expected**: Two equal panels, clear divider, matching factor rows, color-coded strengths/weaknesses
**Canvas**: ~1400x700

### Test 7: Hub and Spoke (Medium)
**Prompt**: "Draw a hub-and-spoke diagram with an API Gateway at center connected to 6 services: Auth, Users, Products, Orders, Payments, Notifications."
**Expected**: Central hub with radial spokes, equal spacing, service labels, bidirectional arrows
**Canvas**: ~1000x1000

### Test 8: Timeline (Simple)
**Prompt**: "Create a project roadmap timeline: Q1 (Foundation), Q2 (Beta Launch), Q3 (GA Release), Q4 (Enterprise Features). Mark key milestones: MVP complete, public beta, v1.0, SOC2 certified."
**Expected**: Horizontal axis, 4 phases, 4 milestone markers, clear temporal flow
**Canvas**: ~1600x500

## Quality Checklist

For each generated SVG, evaluate:

### Structure
- [ ] Has `<title>` and `<desc>` elements
- [ ] Has `role="img"` on root SVG
- [ ] Uses `<defs>` for gradients, shadows, markers (not inline)
- [ ] Has `viewBox` set (no fixed width/height)
- [ ] Font family is system fonts stack

### Visual Quality
- [ ] Gradients applied to major elements (not flat fills)
- [ ] Shadows create depth hierarchy
- [ ] Text is readable (not truncated, not overlapping)
- [ ] Generous whitespace (elements not cramped)
- [ ] Color palette is consistent and semantic

### Layout
- [ ] Elements are aligned (not visually off-center)
- [ ] Boxes are sized proportionally to content
- [ ] Arrows/lines connect cleanly (no gaps, no overlaps with text)
- [ ] Legend present if 3+ colors used
- [ ] Canvas size is appropriate (not too much empty space, not cramped)

### Diagram-Type Specific
- [ ] Correct visual form for the diagram type (not a generic box-and-arrow)
- [ ] Type-specific elements present (lifelines for sequence, trust boundaries for threat model, etc.)
- [ ] Labels match the requested terminology exactly

### Common Issues to Watch For
- [ ] Text extends beyond box boundaries
- [ ] Arrows point to wrong elements or overlap text
- [ ] Elements positioned outside the viewBox
- [ ] Inconsistent font sizes within the same hierarchy level
- [ ] Missing or misaligned connecting lines
- [ ] Flat fills where gradients should be
- [ ] Shadows applied inconsistently
- [ ] Color used without semantic meaning

## Running Tests

1. Start a session with the diagrams plugin loaded
2. Run each test prompt
3. Save SVG output to `tests/output/test-N-type.svg`
4. Open in browser to visually inspect
5. Check against the quality checklist
6. Document issues in `tests/results.md`

Iterate: fix issues in the design system or skill, re-run failing tests.
