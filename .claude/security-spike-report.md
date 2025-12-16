# Spike Report: Interactive Phased Security Audit

**Date**: 2025-12-16
**Status**: Complete
**Outcome**: Recommended approach identified

## Problem Statement

The current security audit workflow has poor UX:
- Spawns a single orchestrator agent that goes silent
- User sees no progress, appears hung
- No opportunity for user input between phases
- All-or-nothing approach to findings

## Questions Investigated

1. **How can we make the audit more interactive?** → Phase-based with user checkpoints
2. **How do we show progress during agent execution?** → Background tasks with polling
3. **How do we let users customize the audit?** → Artifacts + AskUserQuestion between phases

## Recommended Approach

### Key Change: Command Orchestrates, Not Agent

Instead of spawning an `audit-orchestrator` agent that does everything silently, the `/security:audit` **command itself** should orchestrate the phases, staying in the main conversation where the user can see progress.

### Phase Structure

```
┌─────────────────────────────────────────────────────────┐
│ Phase 1: DISCOVERY                                      │
│ • Detect languages, frameworks, features               │
│ • Create .claude/security/discovery.json               │
│ • Show findings to user                                │
│ • AskUserQuestion: Confirm/modify detected features    │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 2: PLANNING                                       │
│ • Map features → relevant auditors                     │
│ • Create .claude/security/plan.json                    │
│ • Show proposed auditors with rationale                │
│ • AskUserQuestion: Enable/disable auditors, set level  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 3: EXECUTION                                      │
│ • Spawn auditors as background tasks                   │
│ • Poll TaskOutput for progress                         │
│ • Show live updates: "✓ encoding-auditor: 3 findings"  │
│ • Save findings to .claude/security/findings/*.json   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 4: REVIEW                                         │
│ • Present findings grouped by severity                 │
│ • Show code snippets for context                       │
│ • AskUserQuestion: Which findings to include?          │
│ • Mark false positives for exclusion                   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ Phase 5: REPORT                                         │
│ • Compile included findings                            │
│ • Generate .claude/security/audit-{timestamp}.md       │
│ • Generate .claude/security/audit-{timestamp}.json     │
│ • AskUserQuestion: Next steps?                         │
└─────────────────────────────────────────────────────────┘
```

### Artifact Structure

```
.claude/security/
├── discovery.json          # Phase 1 output
├── plan.json               # Phase 2 output
├── findings/               # Phase 3 output
│   ├── encoding-auditor.json
│   ├── validation-auditor.json
│   └── ...
├── reviewed-findings.json  # Phase 4 output
├── audit-2025-12-16.md     # Phase 5 output
└── audit-2025-12-16.json   # Phase 5 output (machine-readable)
```

### Implementation Details

#### Phase 1: Discovery
```markdown
1. Use Glob to find: package.json, requirements.txt, go.mod, etc.
2. Use Read to parse config files
3. Use Grep to detect feature patterns (auth, uploads, etc.)
4. Write discovery.json
5. Display findings in conversation
6. AskUserQuestion with multiSelect for features to include/exclude
```

#### Phase 2: Planning
```markdown
1. Read discovery.json
2. Map features to auditors using skill knowledge
3. Write plan.json with auditor list and rationale
4. Display proposed plan
5. AskUserQuestion:
   - Which auditors to run (multiSelect)
   - Audit level (L1/L2/L3)
   - Paths to exclude
```

#### Phase 3: Execution
```markdown
1. Read plan.json
2. For each auditor in plan:
   - Launch via Task with run_in_background: true
   - Store task_id
3. Poll loop:
   - Use TaskOutput(block=false) to check status
   - Display progress: "⏳ encoding-auditor running..."
   - When complete: "✓ encoding-auditor: 5 findings"
4. Write each auditor's findings to findings/{auditor}.json
5. Continue until all complete
```

#### Phase 4: Review
```markdown
1. Read all findings/*.json
2. Aggregate and sort by severity
3. Display grouped findings with snippets
4. For each severity level, AskUserQuestion:
   - "Include these Critical findings?" (multiSelect)
   - Allow marking as false positive
5. Write reviewed-findings.json
```

#### Phase 5: Report
```markdown
1. Read reviewed-findings.json
2. Generate markdown report using audit-report skill
3. Generate JSON export
4. Write to .claude/security/audit-{timestamp}.*
5. Display summary
6. AskUserQuestion: Next steps?
   - Fix critical issues
   - Log as bugs (/devloop:bug)
   - Run another audit
   - Done
```

## Complexity Estimate

- **Size**: Medium (M)
- **Risk**: Low - refactoring existing code, not new concepts
- **Confidence**: High

| Component | Effort | Notes |
|-----------|--------|-------|
| Rewrite audit.md command | M | Main orchestration logic |
| Phase artifact schemas | S | JSON structures |
| Progress display logic | S | TaskOutput polling |
| Remove/deprecate orchestrator | S | Or repurpose as helper |
| Testing | M | Multiple phase transitions |

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Long-running phases timeout | Use background tasks, save state in artifacts |
| User abandons mid-audit | Artifacts allow resume |
| Too many AskUserQuestions | Provide smart defaults, skip if using --quick |

## Benefits

1. **Visibility** - User always sees what's happening
2. **Control** - User can adjust at each phase
3. **Resumability** - Artifacts allow picking up where left off
4. **Selective** - User chooses which findings to include
5. **Transparency** - Each phase's output is inspectable

## Recommendation

**Proceed with implementation**. The phased approach addresses all UX concerns:
- No silent hanging - constant user feedback
- Customizable - user input at each gate
- Progressive - findings build up visibly
- Selective - user controls final report content

## Next Steps

1. Rewrite `commands/audit.md` with phased workflow
2. Create artifact JSON schemas
3. Update domain auditors to output structured JSON
4. Test full flow end-to-end
5. Update README with new workflow documentation
