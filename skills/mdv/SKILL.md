---
name: mdv
description: "Collaborative document viewport for human+agent co-editing of markdown, diagrams (SVG, Mermaid, D2), and visual content."
version: "1.0.0"
author: "Zate Berg"
allowed-tools:
  - mcp__mdv__invoke_tool
  - mcp__mdv__get_tool_schema
  - open_files
  - expand_code_chunks
  - find_and_replace_code
  - create_file
  - bash
  - grep
tags:
  - documents
  - collaboration
  - visual
---

# MDV Skill: Collaborative Document Viewport

MDV is a **shared viewport** that lets you and the user see the same rendered document simultaneously. Changes from either side appear in real-time. This is your equivalent of pair-programming in an IDE, but for documents: markdown, diagrams, tables, and visual content.

**Mental model:** Without mdv, you're writing markdown blind. You can produce structurally correct content, but you can't see how it renders: whether the table is readable, whether the SVG diagram looks good at the rendered size, whether the heading hierarchy creates a scannable layout. MDV gives you eyes.

**When to use this skill:**
- The user says "let's work on this doc" or "help me polish this"
- The user asks you to create or edit a document with visual elements (diagrams, tables, complex layouts)
- You need to verify how something renders (SVG, Mermaid, D2, tables)
- The user references something they're looking at ("see that section?" "the diagram looks off")
- You're iterating on visual quality, not just content correctness
- The user wants to collaborate on documentation destined for Confluence or other publishing targets

**When NOT to use this skill:**
- Pure code editing (use normal file tools)
- Simple text-only markdown with no visual elements
- The user hasn't mentioned mdv and the task doesn't involve visual output
- Quick one-shot content generation where iteration isn't needed

**Tip:** When working with SVG diagrams, the `diagrams` skill provides construction patterns and quality principles. Use it alongside mdv for iterative diagram refinement — generate with `diagrams`, review with `mdv`.

---

## Part 1: The Collaboration Model

### 1.1 The Shared Viewport

MDV runs as a desktop application with an MCP server. When the user opens a file in mdv, both of you can see it rendered. The user sees it in the mdv window; you see it through MCP tools (context queries, screenshots). When either of you edits the underlying file, mdv live-reloads and both see the change instantly.

```
┌─────────────────────────────────────────────┐
│                 MDV Window                   │
│  ┌─────────────────────────────────────────┐ │
│  │         Rendered Document               │ │
│  │   (markdown, SVG, tables, diagrams)     │ │
│  │                                         │ │
│  │   Both human and agent see this.        │ │
│  │   File edits trigger live reload.       │ │
│  └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
        ↕                       ↕
   Human eyes              Agent MCP tools
   Human edits             Agent file edits
        ↕                       ↕
    ┌─────────────────────────────────┐
    │      Shared filesystem          │
    │   (markdown, SVG, assets)       │
    └─────────────────────────────────┘
```

**Key insight:** You don't edit through mdv. You edit the source files directly (with `find_and_replace_code`, `create_file`, etc.) and mdv renders the result. MDV is your viewport, not your editor.

### 1.2 The Edit-Render-Review Loop

This is the core collaboration workflow:

1. **Orient** — Understand what's on screen (context, outline, screenshot)
2. **Edit** — Make changes to the source file using normal file tools
3. **Verify** — Take a screenshot or check context to see how the change rendered
4. **Discuss** — Talk with the user about what looks good, what needs work
5. **Iterate** — Repeat until both human and agent are satisfied

The loop can be initiated by either party:
- **User-initiated:** "That heading hierarchy feels off" → you check context, agree/disagree, make changes
- **Agent-initiated:** "I've updated the table; let me take a screenshot to verify the layout" → screenshot → "The columns are uneven, let me adjust"

### 1.3 Awareness: Is MDV Running?

Before attempting mdv operations, check if mdv is active:

```
Tool: list_contexts
Params: {}
```

- **If contexts exist:** mdv is running. Check which file is active, orient yourself.
- **If no contexts / tool unavailable:** mdv is not running or not connected. You can suggest: "Want me to open this in mdv so we can collaborate on it visually?"

**Do not assume mdv is running.** Always check first. If the user references something visual but mdv isn't available, work with file tools and mention that mdv could help.

### 1.3.1 Troubleshooting: When MDV Isn't Working

If `list_contexts` fails or the mdv MCP tools aren't available at all, diagnose and guide the user:

**Symptom: MCP tools not found / `mcp__mdv__invoke_tool` unavailable**
The mdv MCP server isn't configured in the agent's MCP config.
> "It looks like the mdv MCP server isn't wired up yet. You'll need to add it to your config — here's what it looks like:
> ```json
> {
>   "mcpServers": {
>     "mdv": {
>       "command": "mdv-mcp"
>     }
>   }
> }
> ```
> `mdv-mcp` is the persistent MCP proxy (recommended — survives MDV restarts and exposes `open_path`). Check your `~/.rovodev/mcp.json` (or the project-level `.rovodev/mcp.json`). After adding it, restart your agent session."

**Symptom: MCP tool call returns connection error / timeout**
The mdv application isn't running, or the MCP bridge can't connect.
> "The mdv MCP bridge can't connect — mdv might not be running. Try launching it:
> ```bash
> mdv                    # opens the mdv app
> mdv /path/to/file.md   # opens a specific file
> ```
> If `mdv` isn't found, you may need to install it first — see the mdv project's install instructions for your platform."

**Symptom: `list_contexts` returns empty but mdv is running**
The user has mdv open but hasn't opened a file yet, or mdv lost its connection.
> "mdv is running but doesn't have a file open. Try opening a file in mdv — you can drag one in or use File → Open. Once a file is loaded, I'll be able to see it too."

**Symptom: `get_screenshot` returns errors or blank**
Rendering issue in mdv — check console errors.
> Use `get_console_errors(level: "error")` and `get_debug_logs(component: "server", level: "error")` to diagnose. Report specific errors to the user with suggested fixes.

**General fallback:** If you can't resolve the issue, always offer to continue without mdv:
> "I can't connect to mdv right now, but I can still work on the document using file tools. We just won't have the shared visual preview. Want to proceed that way, or would you rather troubleshoot mdv first?"

### 1.4 Context Awareness Patterns

**The user mentions a document casually:**
> "Let's keep working on that architecture doc"

Your response: Check `list_contexts` to see if it's already open. If yes, orient with `get_document_outline`. If no, check if you can identify the file from conversation context and suggest opening it.

**The user points at something on screen:**
> "See that diagram? It's too wide"

Your response: Use `get_current_context` (focused mode) or `get_selection_context` to understand what they're pointing at. Take a `get_screenshot` to see it yourself. Then address the issue.

**The user starts a fresh collaboration session:**
> "I need to write a design doc for the new auth service"

Your response: Create the document with file tools, then suggest: "Want to open this in mdv so we can iterate on the layout together?"

---

## Part 2: MCP Tool Reference

All tools are in the `mdv` MCP toolset. Use `mcp__mdv__invoke_tool` to call them.

### 2.1 Orientation Tools (What's on screen?)

| Tool | Purpose | When to Use |
|---|---|---|
| `list_contexts` | List all open mdv instances | First call in any session; check if mdv is active |
| `get_current_context` | Viewport state: elements, focus, metadata | Understand what user is looking at |
| `get_document_outline` | Heading hierarchy with block IDs | Navigate document structure; find sections |
| `get_visible_elements` | Filtered elements by type | Find specific content (tables, code blocks, etc.) |
| `get_block_by_id` | Full detail for a specific block | Get SVG source, full table content, code block text |
| `get_selection_context` | User's current text selection | Respond to "what about this part?" |
| `get_screenshot` | Pixel-perfect screenshot of viewport | **See** what the user sees; verify visual changes |
| `get_screenshot_raw` | Raw unprocessed PNG (no resize/JPEG) | Debugging only — when you suspect get_screenshot is distorting the image |

### 2.2 Navigation Tools (Move the viewport)

| Tool | Purpose | When to Use |
|---|---|---|
| `open_path` | **Universal navigation** — open any file/dir, jump to a block, launch MDV if not running | Use for everything: opening files, switching docs, jumping to sections. Works whether MDV is running or not. |
| `scroll_to_element` | Scroll to a block within the current file | When you're already on the right file and want to scroll to a visible/known block |
| `switch_workspace` | Switch workspace tab | When user has multiple documents/directories open |
| `get_directory_tree` | File tree for workspace | Find files to navigate to |
| `navigate_to` | Navigate within the currently open workspace | Only use when MDV is running and the file is already in the active workspace. Prefer `open_path` — it handles all cases. |

**Navigation rule: always use `open_path`.** It handles every case in one call:
- No path → opens current working directory
- Directory → opens as workspace tab
- File → opens parent as workspace (if needed), then navigates to file
- File + `block_id` → navigates to file AND scrolls to the specific section

**Finding block IDs:**
- Already visible on screen → `blockId` field is on every element in `get_current_context` / `get_visible_elements` — you already have it
- Off-screen headings → `get_document_outline(include_ids: true)`
- Off-screen paragraphs/tables/code → `search_document(query: "...")`

### 2.3 Search Tools (Find content)

| Tool | Purpose | When to Use |
|---|---|---|
| `search_document` | Full-text search across blocks | Find specific content, locate sections by keyword |

### 2.4 Diagnostic Tools (Debug rendering)

| Tool | Purpose | When to Use |
|---|---|---|
| `get_console_errors` | JavaScript console errors | Diagrams not rendering, layout broken |
| `get_debug_logs` | Backend debug logs | MCP tool failures, path resolution issues |
| `get_token_usage` | Session token consumption summary | Check which tools are burning tokens; get per-tool breakdown |

### 2.5 Token Efficiency

**Token costs by tool (approximate):**

| Tool | Typical cost | Notes |
|------|-------------|-------|
| `get_document_outline` | ~200–500 tokens | ✅ Very cheap. Best first orientation call |
| `get_current_context` (focused) | ~500–2,000 tokens | ✅ Use `max_text_length: 200` |
| `get_visible_elements` | ~500–3,000 tokens | ✅ Filter by `element_types` |
| `get_block_by_id` | ~500–3,000 tokens | ⚠️ SVG XML stripped by default (use `include_svg_source: true` to get it) |
| `get_screenshot` | ~2,000–8,000 tokens | ✅ Use when you need to see visual rendering. Optimized JPEG, efficient by default. |
| `get_screenshot_raw` (full PNG) | ~500K–2M tokens | 🚫 Debugging/pixel-inspection only |
| `get_token_usage` | ~200 tokens | ✅ On-demand session token summary |

**Simple rule: text vs. visual**
- **Need to know about content?** Use `get_current_context`, `get_document_outline`, `get_visible_elements`, or `search_document`. Fast, cheap, text-based.
- **Need to see how something renders?** Use `get_screenshot`. It's efficient and works directly in your context.
- **`get_screenshot_raw`** — only for pixel-level debugging. Don't use routinely.

**Other efficiency tips:**
- **`max_text_length: 200`** — Truncate element text when scanning large documents
- **`detail_level: "summary"`** — Strip full content from block metadata when you just need structure
- **`limit` / `offset`** — Paginate large documents instead of dumping everything
- **`element_types` filter** — Only get the types you care about
- **SVG source opt-in** — `get_block_by_id` strips SVG XML by default. Use `include_svg_source: true` only when you need to edit the SVG.

**Default to efficient calls.** A document outline + focused context is usually enough. Add `get_screenshot` when visual rendering matters.

---

## Part 3: Agent Behavior Principles

These rules govern how you collaborate. They matter more than any tool sequence.

**1. Suggest mdv once, then follow the user's lead.**
If you recognize a task that would benefit from visual collaboration, suggest mdv once. If the user doesn't engage with the suggestion, drop it and work with file tools. Don't re-suggest every turn.

**2. Match the user's pace.**
Quick instructions mean quick responses — minimal ceremony, minimal narration. Longer, more deliberate messages mean you can afford to orient, screenshot, and discuss. Read the rhythm and match it.

**3. Visual verification is for significant changes.**
Take a screenshot after diagram edits, table restructuring, layout changes. Not after every line edit. You have eyes now; use them when they add value — not as a reflex.

**4. Propose, don't prescribe.**
On visual choices, offer and ask: "I've made the diagram taller — does that look better?" Not: "The optimal aspect ratio for this diagram is 16:9." The user sees the rendered output; you're assisting their judgment, not replacing it.

**5. Orient fast, then be useful.**
When joining mid-stream, orient in 2 tool calls maximum (`list_contexts` → `get_document_outline`), then address the ask. Don't reconstruct the whole document before starting.

**6. Never ask "should I use mdv?" mid-task.**
If you're already in a collaboration session and mdv is running, just use it. Asking permission mid-flow is a momentum-killer.

**7. Follow redirects immediately.**
If the user changes direction — "actually forget the diagram, let's just write the text" — drop the current thread immediately. No protest, no "but we were almost done." Follow.

---

## Part 4: Workflow Patterns

Five common entry points. Each has a different starting state and a different first move.

### 4.1 Fresh Start: Building a Doc from Scratch

*"I need to write a design doc for the new auth service."*

```
1. Create the document with file tools (create_file)
2. Suggest mdv once: "Want to open this in mdv so we can iterate on the layout together?"
3. If yes: list_contexts → confirm file is open → get_document_outline
4. Build structure first (headings, sections), verify layout with get_screenshot
5. Add content section by section
6. When diagrams are needed: load diagrams skill → generate SVG → place in doc → verify in mdv
7. Polish pass when content is complete (see 4.4)
8. Handoff when ready (see 4.5)
```

**Key behavior:** Create first, suggest mdv second. Don't gate the work on whether mdv is open. If the user says "no thanks" to mdv, keep building with file tools — the doc still gets done.

### 4.2 Mid-Stream Join: Picking Up an Existing Doc

*"Help me with this section" / "Let's keep working on that architecture doc."*

```
1. list_contexts → is the doc already open in mdv?
2. get_document_outline (include_ids: true) → understand structure
3. get_current_context (mode: "focused") → what is the user looking at right now?
4. Address the specific ask immediately — don't narrate your orientation steps
5. Verify only if you made a visual change (get_screenshot)
```

**Key behavior:** Two tool calls to orient, then be immediately useful. The user is already in a flow — join it. Skip the screenshot during orientation unless the user specifically asks what you see.

### 4.3 Diagram-First: Creating a Visual for the Doc

*"I need a diagram showing the federation lifecycle." / "Can you draw the three-layer auth model?"*

```
1. Load the diagrams skill (get_skill("diagrams"))
2. Understand intent: what story does this visual tell? Who is the audience?
3. Choose visual type (consult diagrams skill §2.1)
4. Generate SVG following diagrams skill workflow
5. Place SVG in the document (inline or as referenced file)
6. open_path(path: "doc.md", block_id: "diagram-block-id") to jump to the diagram location in mdv
7. get_screenshot → verify rendering at embed scale
8. Iterate with user on layout, colors, sizing using edit → screenshot loop
9. Return to document flow when diagram is done
```

**The clean handoff:** The diagrams skill owns type selection, SVG construction, and design system. MDV owns placement, visual verification, and iteration with the user. You don't need to reload the diagrams skill for iteration — once the SVG is in the doc, you're in mdv territory.

### 4.4 Polish Pass: Making a Finished Doc Look Good

*"The doc is mostly done — help me make it look good." / "Something feels off about the layout."*

```
1. get_screenshot → overall visual impression
2. get_document_outline → structural overview
3. Identify issues and name them specifically:
   - Dense paragraphs with no visual breaks
   - Missing or inconsistent heading hierarchy
   - Tables with unbalanced columns
   - Diagrams that are too small or too large relative to surrounding text
   - Orphaned headings (heading at bottom of screen with no content below)
   - Sections that feel equally weighted when one should be dominant
4. Work section by section: scroll_to_element → get_screenshot → edit → verify
5. Check the whole doc again when section work is done
```

**Think like a designer, not just a writer.** The questions to ask:
- Is there enough whitespace between sections?
- Does the heading hierarchy create a scannable structure?
- Are diagrams sized appropriately relative to surrounding text?
- Does the document flow logically and visually from top to bottom?
- Would a table work better as a list here? Would a list work better as a table?

### 4.5 Handoff: Publishing to Confluence

*"It's ready — let's publish it."*

```
1. Final get_screenshot → confirm it looks right in mdv
2. Set expectations before publishing:
   ⚠️  SVG diagrams will become file attachments in Confluence, not inline SVGs.
       They render via Confluence's attachment preview, not as native SVG.
       This is a current limitation of most Confluence MCP image upload tools.
3. Load the Confluence skill (get_skill("confluence"))
4. Follow Confluence skill workflow for page creation/update
5. After publishing: get_confluence_page → verify rendered output
6. If diagrams look wrong in Confluence: note for user, raise with whoever owns your MCP tooling
```

**Don't surprise the user at publish time.** If the doc has SVG diagrams, name the limitation before you start the publish process. The workaround is out-of-band (MCP tooling owner) — your job is to set expectations and get the text content published cleanly.

### 4.6 Multi-Document Work

*"Can you also check the companion doc?" / "I have two files open."*

```
1. list_contexts → see all open instances and workspace tabs
2. switch_workspace (workspace_id) → switch to the right tab
3. open_path(path, block_id) → open specific file and section
4. Work in that context, then switch back as needed
```

---

## Part 5: Anti-Patterns

### Choose the Right Tool: Text vs. Visual
- **Need to know about content, structure, or text?** → `get_current_context`, `get_document_outline`, `get_visible_elements`, `search_document`. These are fast and cheap.
- **Need to see how something actually renders?** → `get_screenshot`. It's efficient (optimized JPEG, ~2K–8K tokens) — use it directly when visual quality matters.
- **Never use `get_screenshot_raw`** unless you need pixel-level inspection. It's ~100x larger than the default.

### Don't Skip Orientation — But Don't Over-Orient
Never start editing without knowing what's on screen. But orient in 2 calls maximum, then act. A lengthy "let me first understand the full document" preamble before addressing a simple ask is just as bad as diving in blind.

### Don't Edit Through Guesswork
If you're modifying a diagram or complex layout, get the source first with `get_block_by_id`. Don't assume you know what the SVG XML or Mermaid code looks like. Read it, then edit it.

### Don't Forget Live Reload
MDV watches the filesystem. You don't need to "refresh" or "reload" after editing. Just edit the file and mdv updates. Don't add unnecessary tool calls to "update the view."

### Don't Dump Full Viewport Context Unnecessarily
A full `get_current_context(mode: "viewport", include_blocks: true)` on a long document can be enormous. Start with `mode: "focused"` or use `detail_level: "summary"` and `max_text_length: 200`. Drill down only when needed.

### Don't Add Ceremony Where It Doesn't Help
MDV shines for visual collaboration: documents with diagrams, complex tables, layouts that need polish. For a quick README edit or a pure-text change, normal file tools are fine. Don't suggest mdv, don't take screenshots, don't narrate your tool calls. Just do the work.

### Don't Re-Suggest MDV After the User Declined
If the user passed on the mdv suggestion, that's their call. Work with file tools and move on. Bringing it up again is friction, not helpfulness.

### Don't Let the Tool Loop Become the Work
The edit → screenshot → discuss → edit loop is a means to an end. If the document looks good and the user is happy, stop iterating. The goal is a great document, not a perfect collaboration process.

---

### Don't Request SVG Source Unless You're Editing It
`get_block_by_id` strips SVG XML by default (it can be 10–200KB = 2,500–50,000 tokens). If you see `has_svg_source: true` in the response, the XML is available — request it with `include_svg_source: true` only when you're actually going to edit the SVG.

---

## Part 6: Conversation Patterns

### Suggesting MDV Naturally

When you recognize a task that would benefit from visual collaboration, suggest it naturally:

- ✅ "I'll create the doc. Want to open it in mdv so we can iterate on the layout together?"
- ✅ "I can edit the SVG, but it'd be easier if we had mdv open so I can see how it renders. Want to fire it up?"
- ✅ "Since we're going to iterate on this diagram, let's use mdv so we both see the same thing."
- ❌ "I recommend utilizing the MDV collaborative document viewport tool to establish a shared visual context." (robotic)
- ❌ "Please open mdv and navigate to the file, then tell me when it's ready." (too instructional)

### Describing What You See

When you take a screenshot, describe what you observe in terms the user can relate to:

- ✅ "The table renders fine but the third column is wider than it needs to be, pushing everything right."
- ✅ "The SVG looks good at this size. The labels are readable and the flow direction is clear."
- ❌ "I have captured a screenshot of the viewport region showing rendered content." (useless)
- ❌ "The SVG element at block-7 contains 14 path elements and 6 text elements." (source analysis, not visual)

### Responding to Visual References

When the user says something like "that looks weird" or "fix the spacing there":

1. Don't ask "which part?" if you can figure it out from context
2. Check `get_current_context` (focused) or `get_selection_context` first
3. If still ambiguous, ask specifically: "Are you looking at the diagram in the Architecture section, or the table below it?"

---

## Part 7: Format-Specific Guidance

### SVG Diagrams
- Source is XML in the markdown file (inline SVG or referenced file)
- Use `get_block_by_id` to retrieve SVG source
- Edit the SVG XML directly in the source file
- Verify rendering with `get_screenshot`
- **Pair with the diagrams skill** for creation; use mdv for verification and iteration

### Mermaid Diagrams
- Source is a fenced code block with `mermaid` language tag
- MDV renders Mermaid live
- Edit the Mermaid code in the source file; mdv re-renders automatically
- Use `get_screenshot` to verify the rendered output

### D2 Diagrams
- Source is a fenced code block with `d2` language tag
- MDV renders D2 live
- Same edit-verify pattern as Mermaid

### Tables
- Markdown tables render with proper alignment in mdv
- Check column widths and readability visually with screenshots
- Consider whether a table is the right format or if a list/description would be clearer

### Mixed Content Documents
- Documents with multiple diagram types, tables, and prose benefit most from mdv
- Navigate section by section: `get_document_outline` → `scroll_to_element` → `get_screenshot`
- Don't try to optimize the whole document at once; work section by section

---

## Examples

### Example 1: Diagram Iteration

**User says:** "The diagram in the architecture doc looks a bit cramped — can you fix it?"

**Agent does:**
1. `list_contexts` → confirms the doc is open in mdv
2. `get_document_outline` → finds the diagram block ID
3. `get_block_by_id` → reads the SVG source
4. `get_screenshot` → sees the cramped layout
5. Edits the SVG in the source file (increases spacing, adjusts canvas size)
6. `get_screenshot` → verifies the fix
7. "I've increased the canvas height and spread the nodes out — does that look better?"

### Example 2: Polish Pass

**User says:** "Something feels off about the layout of this design doc."

**Agent does:**
1. `get_screenshot` → takes overall visual impression
2. Identifies: orphaned heading at bottom of first screen, one table with unbalanced columns
3. `scroll_to_element` → navigates to the table
4. `get_screenshot` → confirms the column issue
5. Edits the markdown table to rebalance columns
6. Adds a section break before the orphaned heading
7. `get_screenshot` → verifies both fixes
8. "Fixed two things: rebalanced the table columns and moved the heading so it's not stranded at the bottom. How does it feel now?"

### Example 3: Fresh Doc with Diagram

**User says:** "Let's build a design doc for the new auth service. I'll need a flow diagram."

**Agent does:**
1. `create_file` → creates `auth-service-design.md` with skeleton structure
2. Suggests mdv: "Want to open this in mdv so we can see how it renders as we build?"
3. If yes: `list_contexts` → confirms open → `get_document_outline`
4. Builds content section by section, verifying layout with `get_screenshot` after major additions
5. When ready for diagram: loads diagrams skill, generates SVG auth flow diagram
6. Places SVG in doc, `open_path(path, block_id)` to jump to diagram location, `get_screenshot` → verifies at embed scale
7. Iterates on diagram with user until satisfied, then returns to doc content

---

## Reference Files

- **Companion skill:** `diagrams` — SVG generation, design system, 15 layout patterns, validation checklist. Load with `get_skill("diagrams")` when creating new diagrams. MDV handles placement and visual iteration; diagrams skill handles generation.
- **Showcase diagrams:** `collaboration-model.svg`, `workflow-loop.svg` — visual references for the mdv collaboration model and edit·render·review loop.

---

## Quick Reference: Common Tool Sequences

**"What am I looking at? (text)"**
```
list_contexts → get_current_context(mode: "focused", max_text_length: 200)
```

**"What am I looking at? (visual)"**
```
get_screenshot()
```

**"What's the document structure?"** (~200–500 tokens)
```
get_document_outline(include_ids: true)
```

**"What's in the focused area?"** (~500–2K tokens)
```
get_current_context(mode: "focused", max_text_length: 200)
```

**"Let me assess the visual quality"**
```
get_screenshot()
```

**"Navigate to a specific section (already visible)"**
```
get_current_context or get_visible_elements → find blockId on the element → scroll_to_element(block_id: "...", highlight: true)
```

**"Navigate to a specific section (off-screen)"**
```
get_document_outline(include_ids: true) → open_path(path: "current-file.md", block_id: "heading-...")
```

**"Open a different file"**
```
open_path(path: "docs/design.md")
```

**"Open a file and jump to a section"**
```
open_path(path: "docs/design.md", block_id: "heading-architecture")
```

**"Open current repo / launch MDV"**
```
open_path()   ← no arguments, opens cwd
```

**"Get the SVG source to edit"**
```
get_document_outline(include_ids: true) → get_block_by_id(block_id: "...", include_svg_source: true)
```

**"How many tokens have I used this session?"**
```
get_token_usage()
```

**"Which specific tool cost the most?"**
```
get_token_usage(tool: "get_screenshot")
```

**"Verify my edit looks right"**
```
[edit file] → get_screenshot()
```

**"What did the user select?"**
```
get_selection_context → get_screenshot(region: "selection")
```

**"Debug: diagram not rendering"**
```
get_console_errors(level: "error") → get_debug_logs(component: "server", level: "error")
```
