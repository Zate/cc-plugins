---
name: prepare
description: "Session checkpoint and memory promotion. Run before clearing context to preserve decisions, state, and durable knowledge."
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Prepare for Clear

Session checkpoint and memory promotion ritual. Run this before clearing context to preserve what matters.

## No-Op Guard

Before doing anything, check if there's meaningful state to persist:
- Read `~/.claude/nyx/current` — is there an active dimension?
- Check if the dimension state file was discussed or modified this session
- If there's nothing new to persist, say: "Nothing new to checkpoint. You're clear to go." and stop.

## Phase 1: Checkpoint Active Work

If there IS an active dimension:

1. Read the dimension state file at `~/.claude/nyx/dimensions/<name>.md`
2. Ask: "What's the active focus for next time?" — update the Active Focus section
3. Ask: "Anything to add to return notes?" — update the Return Notes section
4. If any decisions were made this session, append them to the Decision Log with today's date and rationale

If there are tasks in flight (check for devloop plan, native tasks), note their status in return notes.

## Phase 2: Memory Promotion

Review working-tier ctx nodes from this session:

1. Emit: `<ctx:recall query="tier:working"/>`
2. For each working-tier node, evaluate: Is this durable and reusable across future sessions?
   - **Promote** → change to reference or pinned tier (emit appropriate ctx:remember to supersede)
   - **Keep** → leave as working (still relevant to active work)
   - **Remove** → noise, let it age out naturally
3. For ambiguous items, ask the user: "Is [item] worth keeping long-term?"

## Phase 3: Clean State

1. Confirm dimension state file is current (show the updated return notes)
2. Confirm all decisions from this session are logged
3. Output a brief summary:
   - What was preserved (dimension state, promoted memories)
   - What was left as-is
   - Active dimension and its focus for next session
4. End with: "Ready for clear."
