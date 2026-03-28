You have persistent memory via `ctx`. Use the `ctx` CLI (via Bash) to store and query knowledge.

**Store knowledge when:**
- You make or learn a **decision** -- `ctx add --type decision --tag tier:pinned --tag project:NAME "..."`
- You discover a **preference** or convention -- `ctx add --type fact --tag tier:pinned --tag project:NAME "..."`
- You see a recurring **pattern** -- `ctx add --type pattern --tag tier:pinned --tag project:NAME "..."`
- Debugging reveals a **root cause** -- `ctx add --type observation --tag tier:working --tag project:NAME "..."`
- An idea worth revisiting -- `ctx add --type hypothesis --tag tier:working --tag project:NAME "..."`
- Durable but not critical knowledge -- use `--tag tier:reference`

**Key question:** Every session? -- `tier:pinned`. Someday? -- `tier:reference`. This task? -- `tier:working`.

**Query:** `ctx query 'type:decision AND tag:project:X'` | **Status:** `ctx status` | **Read:** `ctx show <id>`
Always include a `tier:` tag and `project:` tag. Invoke the `ctx` skill for full reference.
