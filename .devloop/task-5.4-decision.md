# Task 5.4 Decision: Hook Prompt Extraction

**Date**: 2025-12-26
**Task**: Consider hook prompt extraction
**Decision**: EXTRACT - Stop hook prompt extracted to separate file

## Analysis

Analyzed all 9 prompt hooks in `plugins/devloop/hooks/hooks.json`:

| Hook Type | Lines | Characters | Decision |
|-----------|-------|------------|----------|
| **Stop** | 62 | 2,108 | ✅ EXTRACT |
| UserPromptSubmit | 22 | 1,057 | ❌ Keep inline (acceptable) |
| PreToolUse (file validation) | 19 | 958 | ❌ Keep inline |
| PreToolUse (write validation) | 11 | 548 | ❌ Keep inline |
| PreToolUse (bash validation) | 9 | 413 | ❌ Keep inline |
| PostToolUse (bash analysis) | 8 | 351 | ❌ Keep inline |
| PostToolUse (task completion) | 7 | 257 | ❌ Keep inline |
| Notification (issue detection) | 7 | 293 | ❌ Keep inline |
| Notification (milestone) | 3 | 122 | ❌ Keep inline |

**Key Finding**: Stop hook was **2.8x longer** than next longest prompt (UserPromptSubmit).

## Extraction Results

### Before
```json
"prompt": "Before stopping, evaluate the current state...\n\n[2,108 characters of inline JSON-escaped markdown]"
```

### After
```json
"promptFile": "${CLAUDE_PLUGIN_ROOT}/hooks/prompts/stop-routing.md"
```

### Metrics
- **Character reduction**: 2,040 chars saved (96.7% reduction in that section)
- **Extracted to**: `plugins/devloop/hooks/prompts/stop-routing.md` (62 lines, 2,113 chars)
- **hooks.json**: Remains 147 lines total, but much cleaner (no long inline string)

## Benefits

1. **Maintainability**: Routing logic easier to edit in markdown file
2. **Readability**: Proper syntax highlighting, no JSON escaping
3. **JSON cleanliness**: hooks.json more scannable
4. **Best practices**: Large prompts external (per plugin-dev guidelines)
5. **Version control**: Diffs clearer when editing routing logic

## Why Not Extract Others?

- **UserPromptSubmit** (22 lines): Acceptable size, keyword mapping fits inline
- **Other prompts** (3-19 lines): All short enough for inline format
- **Trade-off**: File references add indirection; only worth it for very large prompts

## Recommendation

**No further extraction needed.** Stop hook was the only prompt exceeding best practice thresholds (>50 lines or >2000 chars).

## Testing

Hook functionality preserved:
- ✅ Prompt content identical (copy-paste from inline to file)
- ✅ File path uses `${CLAUDE_PLUGIN_ROOT}` for portability
- ✅ Timeout unchanged (20 seconds)
- ✅ JSON valid after change

## Files Changed

1. **Created**: `plugins/devloop/hooks/prompts/stop-routing.md`
2. **Modified**: `plugins/devloop/hooks/hooks.json` (line 115: `prompt` → `promptFile`)

## Conclusion

**Decision: EXTRACT implemented successfully.**

Stop hook prompt extraction improves code quality without functional changes. Task complete.
