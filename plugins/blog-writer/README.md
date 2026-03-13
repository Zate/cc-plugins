# Blog Writer

A Claude Code plugin that creates blog posts through conversation. It interviews you about your topic, picks up on your natural voice from how you answer, writes a draft that sounds like you, strips out AI-generated patterns, and exports the final post as markdown or HTML.

## Install

```bash
/plugin marketplace add Zate/cc-plugins
/plugin install blog-writer
```

## Usage

```bash
/blog                           # Start the full workflow
/blog "why we switched to Go"   # Start with a topic
```

## How It Works

The plugin runs a 5-phase workflow:

### 1. Interview
Asks you about your topic, audience, and key points. The questions are designed to capture not just what you want to say, but how you naturally say it — your vocabulary, sentence structure, humor, and directness become the voice profile for your post.

### 2. Outline
Generates a structured outline with title options and section breakdown. You review and adjust before any writing happens.

### 3. Draft
Writes the full post matching your voice profile. Follows rules like leading with the point, using your actual phrases from the interview, and varying sentence structure.

### 4. De-AI Pass
A specialized agent audits the draft for AI-generated patterns — corporate vocabulary ("leverage", "utilize", "robust"), structural repetition (everything in threes), template openings ("In today's rapidly evolving..."), and hedging language. Rewrites flagged passages to match your voice.

### 5. Review & Publish
You read the polished draft, request changes if needed, then export as:
- **Markdown** (.md) — clean, portable
- **HTML** (.html) — self-contained with embedded CSS, responsive typography
- **Both** — get both formats

## What Gets Stripped

The de-AI agent has a concrete checklist of patterns it removes:

- Template openings ("In today's...", "Have you ever wondered...")
- Transition crutches ("Furthermore", "It's worth noting", "Let's dive in")
- Corporate vocabulary (utilize → use, leverage → take advantage of, robust → solid)
- Structural patterns (everything in threes, question-answer rhythm, uniform paragraph length)
- Weak endings ("In conclusion", "What do you think?", "The future is bright")
- Hedging ("It's important to note", "One could argue", "Needless to say")

## Output

Blog posts are saved to your chosen location. Working files (`.claude/blog-draft.md`, `.claude/blog-polished.md`) are cleaned up after publishing.

## Components

| Component | Type | Purpose |
|-----------|------|---------|
| `/blog` | Skill | Main orchestration — runs the 5-phase workflow |
| `de-ai-writer` | Agent | Specialized editor that strips AI patterns |
