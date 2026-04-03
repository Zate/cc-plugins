---
name: blog
description: >-
  Create blog posts through a guided interview workflow that captures your voice, writes in your tone, and strips AI patterns from the output. Use when the user wants to write a blog post, create blog content, draft an article, or says "blog", "write a post", "blog post".
argument-hint: Optional topic or title for the blog post
user-invocable: true
allowed-tools: Read, Write, Edit, AskUserQuestion, Agent, Bash, Glob, Grep
---

# Blog Writer

Create blog posts through a guided conversational workflow. Interviews you about your topic, captures your voice from how you answer, writes a draft matching your tone, removes AI patterns, and publishes as markdown or HTML.

## Quick Start

If `$ARGUMENTS` is provided, use it as the initial topic. Otherwise, start by asking for a topic in Phase 1.

---

## Phase 1: Interview

**Goal**: Understand the topic AND capture how the user naturally communicates.

**CRITICAL**: Pay close attention to HOW the user answers — not just WHAT they say. Their word choices, sentence length, formality, humor, directness, and vocabulary ARE the voice profile.

Ask questions one group at a time using AskUserQuestion, then follow up with open-ended questions to capture natural voice.

### Step 1a: Topic & Audience

```yaml
AskUserQuestion:
  questions:
    - question: "What's this blog post about? Give me the elevator pitch."
      header: "Topic"
      multiSelect: false
      options:
        - label: "Technical tutorial"
          description: "How-to, walkthrough, or guide"
        - label: "Opinion / hot take"
          description: "Your perspective on something in your field"
        - label: "Story / experience"
          description: "Something that happened, lessons learned"
        - label: "Announcement / update"
          description: "Product launch, project update, news"
    - question: "Who are you writing this for?"
      header: "Audience"
      multiSelect: false
      options:
        - label: "Developers / technical"
          description: "People who write code"
        - label: "Business / leadership"
          description: "Decision makers, managers"
        - label: "General / mixed"
          description: "Broad audience, no assumed expertise"
        - label: "Community / peers"
          description: "People in your specific niche"
```

### Step 1b: Voice Capture Questions

These are open-ended to capture natural writing voice. Ask via AskUserQuestion with options that encourage free-text responses.

```yaml
AskUserQuestion:
  questions:
    - question: "In your own words, what's the ONE thing you want readers to walk away knowing?"
      header: "Core point"
      multiSelect: false
      options:
        - label: "Let me type it out"
          description: "Free-form answer (recommended — helps capture your voice)"
        - label: "I'm not sure yet"
          description: "We'll figure it out as we go"
    - question: "What's your take on this topic that most people get wrong or overlook?"
      header: "Your angle"
      multiSelect: false
      options:
        - label: "Let me explain"
          description: "Share your perspective in your own words"
        - label: "No strong contrarian take"
          description: "Straightforward coverage"
```

### Step 1c: Tone & Style Preferences

```yaml
AskUserQuestion:
  questions:
    - question: "How do you want this to feel when someone reads it?"
      header: "Tone"
      multiSelect: false
      options:
        - label: "Casual & conversational"
          description: "Like talking to a colleague over coffee"
        - label: "Direct & no-nonsense"
          description: "Get to the point, respect the reader's time"
        - label: "Thoughtful & nuanced"
          description: "Explore complexity, acknowledge tradeoffs"
        - label: "Energetic & opinionated"
          description: "Strong voice, not afraid to take a stance"
    - question: "How long should this be?"
      header: "Length"
      multiSelect: false
      options:
        - label: "Short (500-800 words)"
          description: "Quick read, punchy"
        - label: "Medium (800-1500 words)"
          description: "Standard blog length"
        - label: "Long (1500-2500 words)"
          description: "Deep dive, comprehensive"
        - label: "Whatever it takes"
          description: "Let the content dictate length"
```

### Step 1d: Build Voice Profile

After the interview, silently build a voice profile from the user's answers. Analyze:

1. **Vocabulary level**: Did they use jargon? Simple words? Mix?
2. **Sentence structure**: Short and punchy? Long and flowing? Varied?
3. **Formality**: Contractions? Slang? Professional language?
4. **Personality markers**: Humor? Sarcasm? Earnestness? Directness?
5. **Perspective**: First person? Second person? Inclusive "we"?
6. **Energy**: Excited? Measured? Skeptical? Enthusiastic?

Store this as an internal note — do NOT show the voice profile to the user. Just use it.

---

## Phase 2: Outline

**Goal**: Structure the post before writing.

Generate an outline based on interview answers. Include:
- Working title (2-3 options)
- Section breakdown with 1-line descriptions
- Estimated word count per section
- Key points to hit in each section

Present the outline to the user:

```yaml
AskUserQuestion:
  questions:
    - question: "Here's the outline. How does it look?"
      header: "Outline"
      multiSelect: false
      options:
        - label: "Looks good, write it (Recommended)"
          description: "Proceed to drafting"
        - label: "Tweak it"
          description: "I have some changes"
        - label: "Start over"
          description: "This isn't what I had in mind"
```

If "Tweak it": Ask what to change, update outline, re-present.
If "Start over": Return to Phase 1 interview.

---

## Phase 3: Draft

**Goal**: Write the full blog post matching the user's voice.

### Writing Rules

Follow the voice profile from Phase 1. Additionally:

1. **Lead with the point** — no throat-clearing introductions
2. **Use the user's actual phrases** from interview answers where they fit naturally
3. **Vary sentence length** — mix short punchy sentences with longer ones
4. **Be specific** — concrete examples over abstract statements
5. **Skip the preamble** — no "In today's rapidly evolving landscape..."
6. **End strong** — no wishy-washy conclusions, no "In conclusion..."
7. **Use transitions the user would use** — not "Furthermore" and "Moreover"

### What NOT to Write

These patterns make writing sound like AI generated it. **Never use them:**

- "In today's [anything]..."
- "Let's dive in" / "Let's explore"
- "It's worth noting that..."
- "At the end of the day..."
- "This is a game-changer"
- "Importantly," / "Notably,"
- "In this blog post, we will..."
- "Without further ado"
- "The landscape of..."
- Rhetorical questions as transitions ("But what does this mean?")
- Three-item lists in every paragraph
- Starting every section with a question
- Ending with "What do you think? Let me know in the comments!"

Write the draft and save it to a working file at `.claude/blog-draft.md`.

---

## Phase 4: De-AI & Polish

**Goal**: Run the draft through a dedicated agent that strips remaining AI patterns and polishes the voice.

Invoke the `de-ai-writer` agent with:
- The draft from `.claude/blog-draft.md`
- The voice profile from Phase 1
- Instructions to audit and rewrite AI-sounding passages

The agent returns a cleaned version. Save to `.claude/blog-polished.md`.

---

## Phase 5: Review & Publish

**Goal**: User reviews the final draft, provides feedback, and chooses output format.

Present the polished draft in full (read from `.claude/blog-polished.md`).

```yaml
AskUserQuestion:
  questions:
    - question: "How's the draft? Be honest."
      header: "Review"
      multiSelect: false
      options:
        - label: "Love it, publish (Recommended)"
          description: "Export to final format"
        - label: "Close but needs changes"
          description: "Tell me what to adjust"
        - label: "Rewrite sections"
          description: "Specific sections need rework"
        - label: "Start the draft over"
          description: "Keep the outline, rewrite from scratch"
```

If changes needed: make edits, re-run Phase 4 de-AI pass, re-present.

### Publish

When approved:

```yaml
AskUserQuestion:
  questions:
    - question: "What format do you want?"
      header: "Format"
      multiSelect: false
      options:
        - label: "Markdown (.md) (Recommended)"
          description: "Clean markdown file"
        - label: "HTML (.html)"
          description: "Styled HTML with embedded CSS"
        - label: "Both"
          description: "Generate both formats"
    - question: "Where should I save it?"
      header: "Location"
      multiSelect: false
      options:
        - label: "Current directory"
          description: "Save right here"
        - label: "blog/ subdirectory"
          description: "Create blog/ folder if needed"
        - label: "Let me specify"
          description: "I'll type a custom path"
```

### Markdown Output

Write clean markdown with:
- Title as `# heading`
- Proper heading hierarchy
- No unnecessary frontmatter unless user requests it

### HTML Output

Write a self-contained HTML file with:
- Embedded CSS (clean, readable typography)
- Responsive layout (max-width ~700px centered)
- System font stack
- Proper meta tags (charset, viewport)
- No external dependencies

### Cleanup

After publishing, remove working files:
```bash
rm -f .claude/blog-draft.md .claude/blog-polished.md
```

Display the final file path and word count.

---

## Error Handling

- If user abandons mid-interview: working files are in `.claude/` — no cleanup needed, they're gitignored
- If de-AI agent fails: fall back to inline de-AI pass within the skill itself
- If user says "start over" at any phase: return to the appropriate earlier phase

## When to Use This Skill

- User wants to write a blog post
- User asks for help with blog content
- User says `/blog` or mentions creating blog content

## When NOT to Use This Skill

- User is writing documentation (use doc-generator)
- User wants to edit an existing blog post (just edit the file directly)
- User needs marketing copy or social media posts
