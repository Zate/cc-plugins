# Documentation & Diagram Style Guide

This guide captures the principles, patterns, and standards we've established for all documentation and diagrams in this project. Every doc and diagram should follow these guidelines.

---

## Voice & Tone

- **Direct and confident.** Never apologize for content or hedge with meta-preamble ("before we talk about X, we need to...", "this document tells three stories"). Just state it.
- **Lead with the concrete, not the abstract.** Questions > definitions. Examples > theory. "When an agent reads a doc on behalf of Alice, *who* is acting?" beats "This section defines identity concepts."
- **Write for the smartest person in the room who happens not to know this topic yet.** An exec should be able to follow. An engineer should find it useful. Neither should feel talked down to.
- **Hook first.** Every document and section should open with a question, a problem, or a payoff — not a summary of what's coming.

---

## Document Structure

### Progressive Disclosure Model

Documentation follows a strict 3-layer progressive disclosure model:

1. **README.md** — "What is this and why?" Scale model analogy, persona routing. ~2 min.
2. **INDEX.md** — "Show me the whole thing." One diagram per concept, brief previews. ~10 min.
3. **Blueprint + deeper docs** — "Deconstruct it." Full detail, progressively deeper. ~15 min each.

**Rules:**
- Each level must give COMPLETE understanding at that depth — not "go read the real doc."
- Each level must make you WANT to go deeper — tease what's in the next level.
- No content should appear at multiple levels without adding value (duplication = noise).
- The same diagram should NOT appear in README and INDEX — each level gets its own level of visual.
- Cross-reference links go DOWN (overview → detail) and SIDEWAYS (related docs), never up.

### The Authz/Observability Thread

Every architecture document should weave authorization and observability into its narrative. This is not an optional add-on — **it's the PURPOSE of the architecture.**

- **Identity Model**: At each concept, ask "what can authz evaluate?" Does this concept carry information the policy engine needs?
- **Federation**: At each state, ask "what does the receiving domain's policy engine see?" Does this state give the policy engine more to work with?
- **Policy Engine**: This is the core authz document — the sink that explains what all the identity concepts feed into.
- **Data Model**: Ask "what tokens carry for authz to consume." Every claim in a token exists because the policy engine needs it.

The reader should never feel like authz is a separate topic. It's the throughline that connects identity model → federation → policy engine → tokens.

### Section Pattern

Every section in a document should follow this pattern (matching Blueprint's style):

1. **Section heading**
2. **One connecting sentence** — what this section shows and why it matters
3. **Diagram** (if applicable) — visual first, text second
4. **Structured text** — table or bold-lead inline definitions. NOT subsection headings with paragraphs.
5. → **Flow into next section**

### Content Rules

- **Every section tells ONE thing.** If you're saying the same thing three ways (diagram + table + paragraphs), pick two at most. Diagram + one text format.
- **Diagram shows structure or relationships.** Text shows meaning with examples. They complement, not duplicate.
- **Tables for comparisons** across categories (e.g., 1P vs 2P vs 3P, old vs new).
- **Bold-lead definitions** for concepts with examples (e.g., "**Principal** — any entity that *can* authenticate...").
- **Never use `### Subsection` headings for a list of peer items.** Use a table or bold-lead paragraphs instead. Subsection headings create visual weight that implies more depth than is there.
- **Code blocks only for actual code/tokens** — not for formulas that could be inline (`Actor = Subject + Executor` is fine as inline code).
- **When describing states/transitions/modes, include what changes for authorization at each step.** Don't just list the states — explain what the policy engine gains at each transition.
- **The word 'can' in tables should describe what authz CAN DO, not just what the principal CAN DO.** For example, instead of "Agent can read files," write "Policy engine can verify the agent's delegated permissions."
- **Tables with 'What authz sees' or 'What authz can do' columns are preferred** over tables without. These force the authz narrative into the structure.

### Opening Pattern

- ❌ "This document tells three stories: 1. The Primitives..."
- ❌ "Before we talk about agents, we need a shared vocabulary..."
- ✅ "When an agent reads a Confluence page on behalf of Alice, *who* is acting?"
- ✅ "⚠️ **The Problem** — AI agents today lack proper identity governance..."

### Navigation

Every deep doc has two navigation elements:

**Top breadcrumb** — shows where you are in the Architecture Journey. Plain paragraph (NOT a blockquote — renders as Info boxes in mdv). The current doc is bold, the others are links:

```
📖 **Architecture Journey:** [① Blueprint](./BLUEPRINT.md) · **② Identity Model** · [③ Federation](./FEDERATION-LIFECYCLE.md) · [④ Authorization & Policy](./AUTHORIZATION-POLICY.md) · [⑤ Tokens & Audit](./TOKEN-ANATOMY.md)
```

**Bottom footer** — shows where to go next (sequential) and what's related (sideways). Separated by a `---` rule. Plain text, no blockquotes:

```
📖 **Next →** [Federation Lifecycle](./FEDERATION-LIFECYCLE.md) — one-line description of what it covers

**Related:** [Data Model](./DATA-MODEL.md) for the JWT claims | [Blueprint](./BLUEPRINT.md) for the authorization overview
```

The final doc (Data Model) uses a completion marker instead of "Next":

```
📖 **🏁 Architecture Journey Complete.** Onward links to reference material and Customer 0.
```

**Rules:**
- Cross-references go DOWN (overview → detail) and SIDEWAYS (related docs), never up
- Breadcrumbs are plain paragraphs with 📖, NOT blockquotes
- "Related" links should explain *why* you'd go there, not just name the doc
- Customer 0 docs follow the same pattern with their own sequence

---

## Diagram Standards

### Quality Bar

The `agent-lifecycle.svg` diagram is our reference for quality. What makes it work:

- **Generous whitespace** — boxes don't crowd each other
- **Visual hierarchy** — one element is the hero (larger, filled), others are subordinate
- **Minimal text per box** — 2-3 lines max, dot-separated keywords not sentences
- **Curved arrows** that flow naturally, labels positioned clearly away from overlaps
- **Color used semantically** — blue=active, orange=warning, red=terminal, gray=initial
- **Compact supporting info** tucked in unused space

### Diagram Type Selection

Choose the diagram type that matches the content:

| Content | Diagram Type | Example |
|---------|-------------|---------|
| States + transitions | State machine | `agent-lifecycle.svg` |
| Sequence of operations | Flow diagram | `policy-evaluation-flow.svg` |
| Side-by-side comparison | Card row or table diagram | `delegation-spectrum.svg` |
| Before/after transformation | Split panel | `identity-before-after.svg` |
| Concept relationships | Entity relationship | `identity-primitives.svg` |
| Layered model | Pyramid or stack | `aims-rfc-stack.svg` |
| System components | Layered architecture | `architecture-overview.svg` |
| Multiple scenarios | Stacked rows | `identity-overview.svg` |

### Visual Rules

- **Text: minimum 12px.** Nothing smaller. Ever.
- **No text overflow.** Every text element must fit within its container with margin.
- **No internal SVG titles** if the section heading already provides the title. Avoid redundancy.
- **System fonts only:** `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`
- **Canvas sizing:** use `viewBox` for scaling. Prefer 960px wide. Height varies by content — don't be afraid of tall diagrams if they need it.

### Color Palette

Use a cohesive, accessible color palette consistently (this one is modeled on Atlassian's public design system):

| Color | Usage | Hex |
|-------|-------|-----|
| Navy/Blue gradient | Platform, primary, human principal | `#0065FF` → `#0747A6` |
| Purple gradient | Agent principal | `#6554C0` → `#403294` |
| Green | Safe, allowed, audit success | `#E3FCEF` / `#36B37E` / `#006644` |
| Amber/Orange | Caution, medium trust, warning | `#FFF0B3` / `#FF8B00` / `#974F0C` |
| Red | Danger, denied, highest trust/risk | `#FFEBE6` / `#FF5630` / `#BF2600` |
| Gray | Neutral, background, initial state | `#F4F5F7` / `#DFE1E6` / `#6B778C` |
| Dark navy | Text, headings | `#172B4D` / `#44546F` |

**Semantic meaning must be consistent across all diagrams:**
- Blue = human identity / platform / primary
- Purple = agent identity (always — never use purple for humans)
- Green = success / allowed / positive outcome
- Red = denied / danger / terminal state
- Amber = caution / medium / needs attention

### Trust/Severity Badges

Use pill shapes (`rx="10-14"`) with semantic colors:
- Green pill: lowest trust, safe, allowed
- Blue pill: primary pattern, platform
- Amber pill: higher trust, caution
- Red pill: highest trust, danger, denied

### Diagram Must Feel Like What It Represents

- A **spectrum** should look graduated (colors progressing, sizes changing)
- A **hierarchy** should look layered (pyramid, stack)
- A **transformation** should feel like before/after (faded old → vibrant new)
- A **flow** should have clear directionality (left-to-right or top-to-bottom)
- **Symmetry matters** — rows should be the same width, columns should align

### Progressive Disclosure in Diagrams

INDEX sections use a **higher-level overview diagram** — NOT the same diagram as the deeper doc:
- INDEX diagrams: show the essence (e.g., 3 scenarios in stacked rows)
- Deeper doc diagrams: show the full model (e.g., 4 concepts with relationships, 4-card spectrum with 5 dimensions)
- The deeper doc diagram should feel like a decomposition of what INDEX showed

---

## Confluence Sync

When updating Confluence pages to match local docs:

- Use `get_confluence_page` to fetch HTML, edit it, then `update_confluence_page` to push.
- SVG diagrams cannot be uploaded via MCP tools — use `ac:structured-macro` info callouts as placeholders.
- Placeholder format: `📊 Diagram: [filename.svg]` with a brief description of what it shows.
- User uploads SVGs manually as attachments and replaces callouts.
- Ensure all child page links use correct Confluence page IDs.

---

## Checklist

Run through this for every doc in `docs/`:

**Opening:**
- [ ] No blockquote breadcrumbs — use plain paragraph with 📖
- [ ] Opens with a hook (question, problem, payoff) — not meta
- [ ] First paragraph hooks even a non-technical reader
- [ ] Links to AuthN North Star / RFC where relevant, with context

**Structure:**
- [ ] Substance-first — meta context at the end, not the top
- [ ] Bullet lists with 6+ items → comparison table instead
- [ ] No duplicate content between this doc and INDEX
- [ ] Section headings match what INDEX says about this doc

**Diagrams:**
- [ ] No internal SVG title if section heading provides it
- [ ] All text ≥ 12px, no overflows
- [ ] Diagram type matches content
- [ ] Diagram serves a purpose the text can't — not decoration
- [ ] Colors used consistently (blue=human, purple=agent, green=allowed, red=denied)

**Navigation:**
- [ ] Top breadcrumb present (plain `📖` paragraph, not blockquote)
- [ ] Bottom footer present (`📖 **Next →**` + `**Related:**`)
- [ ] Cross-references go DOWN and SIDEWAYS, never up
- [ ] "Related" links explain *why*, not just name the doc

**Terminology:**
- [ ] Uses Principal/Subject/Actor/Account per IDENTITY-MODEL.md definitions
- [ ] First mention of RFC includes full title + datatracker link
- [ ] Acronyms expanded on first use (AIMS, OBO, ABAC, SPIFFE)
- [ ] "Non-Human" capitalised when referring to principal type

**Quality:**
- [ ] Read as exec — makes sense without deep technical knowledge
- [ ] Read as engineer — enough detail to be useful
- [ ] No stray code blocks, broken formatting, or orphaned sections
- [ ] Consistent table formatting across sections

**Authorization Thread:**
- [ ] Does the doc explain how its concepts feed into authorization decisions?
- [ ] Does each state/transition/mode note what changes for the policy engine?
- [ ] Are observability/audit implications mentioned where relevant?
