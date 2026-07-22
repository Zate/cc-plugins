# Documentation Editing Process & Philosophy

This document captures the end-to-end process for creating, reviewing, and refining documentation and diagrams in this project. It preserves the workflow, decision-making approach, and editorial philosophy that produced the current docs — so that anyone (human or AI) continuing this work produces results that feel like part of the same body of work.

**Companion documents:**
- [`STYLE-GUIDE.md`](./STYLE-GUIDE.md) — visual standards, color palette, diagram rules, review checklist
- [`CLAUDE.md`](../CLAUDE.md) — agent-specific instructions, tool workflows, file locations

---

## The Core Philosophy

### Scale Model Thinking

This project is a **scale model** — not production code, not an artist's impression, not engineering blueprints. It's the thing teams sit around, point at, and use to build shared understanding before the detailed work begins.

The documentation serves the same purpose: it's not a spec, not a tutorial, not marketing copy. It's a set of interconnected documents that build a **shared mental model** of how agentic identity should work. Every doc, every diagram, every word should contribute to that shared understanding.

### Progressive Disclosure

The documentation is structured in layers. Each layer gives you a **complete understanding at that depth** — you should never feel like "I need to go read the real doc to understand this." But each layer should also make you **want to go deeper** — you should feel like "I understand this, but I bet there's more to it."

| Layer | Document | Purpose | Reading Time |
|-------|----------|---------|-------------|
| 1 | `README.md` | What is this, why does it exist, where do I go? | ~2 min |
| 2 | `architecture/INDEX.md` | Show me the whole architecture — one diagram per concept | ~10 min |
| 3 | `architecture/BLUEPRINT.md` + 4 deeper docs | Deconstruct each concept in full detail | ~15 min each |

**Key rules:**
- Content at a higher layer should NOT be duplicated at a lower layer. Each layer adds, not repeats.
- Diagrams at a higher layer should be **simpler** than diagrams at a lower layer — they show the essence, not the detail.
- Going from layer 2 to layer 3 should feel like **zooming in** — same concepts, more depth.
- Going from layer 3 back to layer 2 should feel like **zooming out** — "ah yes, I can see how that section fits into the bigger picture."

### The Decomposition Principle

When we finish writing or revising a deeper doc (e.g., IDENTITY-MODEL.md), we go back up to INDEX.md and ensure:

1. The INDEX section for that doc **previews** the key stories — enough to understand at surface level
2. The INDEX uses a **different, higher-level diagram** — not the same SVG
3. The deeper doc feels like a **natural expansion** of what INDEX showed
4. Someone reading only INDEX walks away informed. Someone reading both walks away deeper.

This is the most important editorial principle. Every time we finish a doc, we ask: "Does INDEX → this doc feel like decomposition? Would I click 'go deeper' from INDEX?"

### Purpose-Driven Content

Every document should answer: **what is this section's purpose? What should the reader come away with?**

- Don't blindly copy format — figure out what format works for the MESSAGE being communicated. The medium serves the message, never the reverse.
- Authorization and observability aren't just downstream concepts — they're the **REASON** identity architecture exists. Thread them throughout, not as an afterthought.
- When writing about federation, the reader needs to understand **WHY** trust crosses boundaries (so authorization works correctly on the other side). "Here are the federation states" is incomplete without "here's why we need each state for the receiving domain's policy engine to work."

---

## The Editing Workflow

### Phase 1: Read the Full Document

Before making any changes, read the entire document. Understand:
- What is it trying to say?
- Who is the audience?
- What's the narrative arc — does it have one?
- Where does it fit in the progressive disclosure model?

### Phase 2: Structural Assessment

Evaluate the document holistically:

1. **Does the opening hook?** The first paragraph should make someone want to keep reading. Questions, problems, or payoffs — not meta ("this document covers...").

2. **Is it substance-first?** The actual content (architecture, concepts, models) should come before meta context (standards alignment, deviations, navigation). Meta goes at the end.

3. **Is there a clear narrative?** Each section should build on the previous one. The reader should never think "why am I reading this now?"

4. **Is anything said more than once?** If a diagram, a table, and a paragraph all say the same thing — pick two at most. Diagram + one text format.

5. **Are the sections parallel?** If one section uses a table for comparison, similar sections should too. If one section opens with a diagram, similar sections should too. Consistency creates trust.

6. **Does the doc weave authorization and observability into the narrative?** These aren't separate topics to append at the end — they're the PURPOSE of everything we're building. Does the reader understand how identity decisions feed into authorization?

7. **Does each section answer WHY, not just WHAT?** For example, federation states aren't just a list — they exist so the policy engine has progressively more to work with. Authz context needs to grow at each step.

### Phase 3: Visual Walkthrough (Top to Bottom)

Open the document in mdv (or a markdown viewer) and scroll through it visually. For each screen:

- **Does it look balanced?** Or is one section crammed and another spacious?
- **Do diagrams feel like they belong in the same family?** Same visual style, same color palette, same depth of finish?
- **Is anything overlapping, cut off, or misaligned?** Text in SVGs is the most common offender.
- **Does the diagram serve a purpose the text can't?** If you removed the diagram, would you lose anything? If not, the diagram is decoration.

### Phase 4: Section-by-Section Refinement

Work through each section applying the **section pattern**:

1. **Heading** — clear, descriptive
2. **Connecting sentence** — what this shows and why it matters (one line)
3. **Diagram** — visual first, text second
4. **Structured text** — table or bold-lead inline definitions
5. → **Flow to next section**

For each section, ask:
- Could the bullet list be a table? (If 6+ items comparing things, yes)
- Are there `### Subsection` headings for peer items? (Replace with bold-lead paragraphs or a table)
- Does the text explain what the diagram already shows? (Remove the duplication)
- Does the connecting sentence set up the diagram, or just describe what follows?

### Phase 5: Diagram Quality Pass

For every diagram in the document:

1. **Run the overflow check** — all text ≥12px, nothing extends beyond its container
2. **Check the title** — if the section heading already says what it is, strip the internal SVG title
3. **Check the type** — is this the right diagram type for this content? (See STYLE-GUIDE.md)
4. **Check the colors** — blue=human, purple=agent, green=allowed, red=denied. Consistent everywhere.
5. **Check the feel** — a spectrum should look graduated, a transformation should look before/after, a flow should have clear directionality
6. **Compare with siblings** — does this diagram look like it belongs with the other diagrams on this page?

### Phase 6: Holistic Review

Read the document as three different people:

1. **As an executive** — Do I understand the key message in 2 minutes? Can I skim the diagrams and tables and get it?
2. **As an engineer** — Is there enough detail to be useful? Are the examples concrete?
3. **As a product manager** — Do I understand why this matters? Can I explain it to someone else?

If any persona bounces, the document needs more work.

### Phase 7: Upward Propagation

After finishing a document, go back up the stack:

1. **Check INDEX.md** — does the section for this doc preview the right stories? Does the diagram feel like a higher-level version?
2. **Check README.md** — does the table description still match what the doc actually covers?
3. **Check Confluence** — is the corresponding page in sync? Update it with the same content and diagram placeholders.

---

## The Diagram Creation Process

### Step 1: Define the Purpose

Before drawing anything, answer:
- What is this diagram for? What does it show that text can't?
- What diagram type fits? (flow, comparison, state machine, relationship, etc.)
- How does it relate to diagrams above/below in the progressive disclosure stack?

### Step 2: Content First, Style Second

Sketch the content — what boxes, what labels, what connections. Get the information architecture right before thinking about colors, gradients, or shadows.

### Step 3: Build the SVG

Follow the standards in STYLE-GUIDE.md:
- System fonts, 12px minimum text, no overflows
- Semantic colors (blue=human, purple=agent, green=allowed, red=denied)
- `viewBox` for scaling, typically 960px wide
- Gradients for depth, shadows for lift, rounded corners for polish

### Step 4: Validate

Run the diagram quality checker:
```bash
# Check all diagrams
python3 scripts/check-diagrams.py

# Check a specific diagram
python3 scripts/check-diagrams.py docs/architecture/my-diagram.svg

# Or via make
make check-diagrams
```

The script checks: minimum font size (12px), text overflow (right and bottom), valid XML, and near-edge warnings. Fix all ❌ issues before committing. ⚠️ warnings are advisory.

### Step 5: Review in Context

View the diagram in the document (via mdv or browser). Ask:
- Does it look like it belongs with the other diagrams on this page?
- Is it too complex for this level of the progressive disclosure stack?
- Does it feel like what it represents? (A spectrum looks graduated, a hierarchy looks layered)

### Step 6: Get Feedback, Iterate

Diagram creation is iterative. Common feedback patterns we've seen:

| Feedback | Typical Fix |
|----------|------------|
| "It's too crowded" | Increase canvas height, add whitespace between elements |
| "Words are overlapping" | Widen containers, shorten labels, check overflow calculations |
| "It doesn't feel like X" | Change diagram type or visual treatment to match the concept |
| "It looks bland" | Add gradient fills, shadows, semantic colors, visual hierarchy |
| "It's saying the same thing as the text" | Remove either the diagram or the redundant text |
| "These diagrams don't look related" | Match container styles, colors, fonts, border treatments |
| "Too much detail for this level" | Create a simpler overview version for the higher layer |

---

## The Confluence Sync Process

After any document changes, sync to Confluence:

1. **Read the current page** — `get_confluence_page` to fetch HTML
2. **Build new HTML** — convert markdown to Confluence-compatible HTML:
   - Tables with `<thead>`, `<tbody>`
   - Bold, italic, code tags
   - Internal links → Confluence page URLs
   - SVG references → `ac:structured-macro` info callout placeholders
3. **Push the update** — `update_confluence_page` with a version message
4. **Document which SVGs need manual upload** — user attaches them as Confluence attachments

### Page URL Mapping

Keep a mapping table from local file to its published Confluence page, so the sync
step above knows which page to update for which file. Example shape (redacted —
the original had real internal space/page links for a specific project):

| Local File | Confluence Page |
|------------|----------------|
| `docs/README.md` | [Project Docs Home](#) |
| `docs/architecture/INDEX.md` | [Architecture & Design](#) |
| `docs/architecture/BLUEPRINT.md` | [Architecture Blueprint](#) |
| `docs/architecture/DATA-MODEL.md` | [Data Model](#) |

---

## What "Done" Looks Like

A document is done when:

- [ ] It passes the full checklist in STYLE-GUIDE.md
- [ ] The opening hooks — you'd keep reading
- [ ] Every section follows the section pattern (heading → sentence → diagram → structured text)
- [ ] No content is said more than twice (diagram + one text format max)
- [ ] All diagrams pass the quality bar (12px min, no overflows, semantic colors, right type)
- [ ] Reading as exec/engineer/PM — all three get value
- [ ] INDEX section for this doc previews the right stories with a higher-level diagram
- [ ] README table description matches the current content
- [ ] Confluence page is in sync with diagram placeholders noted
- [ ] You'd be proud to send this to someone senior

---

## Lessons Learned

Things we discovered through iteration that should be preserved:

1. **Three representations of the same thing is always too many.** Diagram + table + paragraphs = pick two. Usually diagram + bold-lead paragraphs, or diagram + comparison table.

2. **"Trust" is not the right axis for comparing delegation modes.** The right dimensions are observability, control, and authority. "Identify As" is not "lowest trust" — it's foundational for federation.

3. **Subsection headings (`###`) for peer items make docs feel like essays.** Replace with bold-lead paragraphs or comparison tables for a more scannable result.

4. **Blockquotes render as "Info" boxes in mdv.** Three stacked blockquotes look terrible. Use plain paragraphs with emoji markers (⚠️ ✅ 📄) instead.

5. **The same diagram at two levels breaks progressive disclosure.** INDEX and deeper docs must have different diagrams for the same concept — INDEX shows the essence, deeper docs show the full model.

6. **Diagram style must be consistent across a page.** If one diagram has rounded containers with gradient fills, all diagrams on that page should. Mixing flat boxes with rich diagrams looks like two different authors.

7. **Color meaning must be locked.** Blue = human/platform. Purple = agent. Green = allowed. Red = denied. Amber = caution. If you use purple for a human in one diagram, you've broken the mental model everywhere.

8. **The opening paragraph is the most important paragraph.** If it starts with "This document covers..." or "Before we discuss...", the reader is already losing interest. Start with the question the reader already has.

9. **Every doc edit should propagate upward.** Changed the Blueprint? Check INDEX. Changed INDEX? Check README. The layers must stay coherent.

10. **Diagrams should feel like what they represent.** A spectrum should look graduated. A transformation should look before/after (faded → vibrant). A flow should have clear directionality. A hierarchy should look layered. If the visual metaphor doesn't match the concept, the diagram fails regardless of how polished it looks.

11. **Authorization is the thread.** Every architecture document should answer "so what can authorization do with this?" The identity model exists so authz can evaluate correctly. Federation exists so the right attributes arrive for authorization. The data model exists so tokens carry what authz needs. If a section doesn't answer this question, it's not carrying its weight in the narrative.

12. **Narrative arc matters more than completeness.** A doc that tells 3 stories well beats a doc that covers 10 topics shallowly. Ask "what is the reader's journey?" not "what topics should we include?" Every section should build on the previous one, leading somewhere.

13. **Build the deeper doc first, then compose upward.** We consistently found it easier to write the full detailed doc (like IDENTITY-MODEL.md), then go back to INDEX and compose a higher-level preview. Trying to write both simultaneously leads to duplicated content and mismatched levels of detail.

14. **The 'so what' test for sections.** If you remove a section and the doc still tells its story, that section either belongs in a different doc or can be cut. Every section must be load-bearing in its document's narrative arc.

15. **Every diagram needs a distinct purpose from the text around it.** If the text already explains it and the diagram just restates it visually, remove one or the other. The diagram should show what the text can't (relationships, flow, comparison at a glance).
