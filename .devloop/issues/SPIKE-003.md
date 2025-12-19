---
id: SPIKE-003
type: spike
title: Investigate golangci-lint hook integration for Go file editing
status: done
priority: medium
created: 2025-12-19T12:00:00
updated: 2025-12-19T12:30:00
reporter: user
assignee: null
labels: [golang, hooks, linting]
related-files:
  - templates/golangci.yml.template
timebox: 2 hours
---

# SPIKE-003: Investigate golangci-lint hook integration for Go file editing

## Description

Research and prototype a golangci-lint plugin that provides authoritative linting configuration and automatic hook-based linting when editing Go files.

## Investigation Goals

1. **Hook mechanism**: Determine the best hook approach (PostToolUse on Edit/Write?)
2. **Conditional activation**: How to detect Go files and golangci-lint availability
3. **Config setup**: Strategy for deploying .golangci.yml from template
4. **Error reporting**: Best way to return lint errors to context (direct vs message)
5. **User experience**: Balance between helpful and intrusive

## Key Questions

- [ ] Should the hook run on every Go file edit, or batch at certain points?
- [ ] How to handle missing golangci-lint installation gracefully?
- [ ] Should the .golangci.yml be auto-created or require explicit setup?
- [ ] What's the optimal way to show lint errors - inline vs summary?
- [ ] Should we lint just the edited file or the whole package?

## Proposed Approaches

### Approach A: PostToolUse Hook on Edit/Write
- Trigger after any Edit or Write to *.go files
- Run `golangci-lint run <file>` on just the edited file
- Return errors directly to context
- Pros: Immediate feedback
- Cons: Could be noisy/slow for rapid edits

### Approach B: Stop Hook (End of Response)
- Trigger at end of assistant response
- Collect all edited Go files during response
- Run `golangci-lint run` on all of them at once
- Return summary of errors
- Pros: Less intrusive, batched
- Cons: Delayed feedback

### Approach C: Command-based (Not Hook)
- Provide `/golangci:lint` command instead
- User triggers when ready
- Pros: User control
- Cons: Not automatic

## Related Template

Based on `templates/golangci.yml.template` which includes:
- Default + additional strict linters (45+ linters)
- Reasonable thresholds (complexity: 10, funlen: 50 lines)
- Test file exclusions

## Context

- This would be a new plugin for the marketplace
- Should follow the command orchestration pattern
- Needs to gracefully handle missing dependencies

## Success Criteria

- [ ] Clear recommendation on hook approach
- [ ] Working prototype hook
- [ ] Strategy for .golangci.yml management
- [ ] Graceful degradation when golangci-lint not installed
- [ ] Minimal user friction

## Notes

User mentioned: "only enabled/happen when required" and "only have it setup the yml, and call golangci-lint if its installed"

Key constraints:
1. Only activate for Go files
2. Only run if golangci-lint is installed
3. Setup yml on demand, not automatically
4. Return errors to context for fixing
5. Nice user messaging

## Resolution

- **Resolved**: 2025-12-19
- **Recommendation**: Proceed with PostToolUse hook approach
- **Spike Report**: `.devloop/spikes/golangci-lint-hook.md`
- **Summary**: PostToolUse hook is the best approach - provides direct file path access, immediate feedback, and matches existing plugin patterns. Implementation is straightforward (S-size, Low risk).
