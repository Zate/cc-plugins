## Spike Report: Engineer Agent Improvements

**Date**: 2024-12-23
**Status**: Analysis Complete
**Scope**: `plugins/devloop/agents/engineer.md` and related skills

---

## Executive Summary

Analysis of the engineer sub-agent identified several opportunities to improve execution quality, skill configuration, prompt structure, and mode handling. The engineer agent is central to the devloop workflow but has gaps in skill coverage, lacks explicit guidance on model escalation, and has inconsistent mode transitions.

---

## Questions Investigated

1. Can we improve the prompts? → **Yes**, several structural improvements identified
2. Does it have the right skills? → **Partially**, missing critical skills
3. Are skills setup optimally? → **No**, some conflicts and gaps exist

---

## Findings

### 1. Skill Configuration Issues

**Current Skills:**
```yaml
skills: architecture-patterns, go-patterns, react-patterns, java-patterns, python-patterns, git-workflows, refactoring-analysis, plan-management, tool-usage-policy
```

**Problems Identified:**

#### A. Missing Critical Skills

| Missing Skill | Why It's Needed |
|---------------|-----------------|
| `complexity-estimation` | Engineer should assess task complexity before diving deep, especially in architect mode |
| `testing-strategies` | Implementation tasks often require understanding test requirements |
| `api-design` | Referenced in main devloop workflow for implementation but not available to engineer |
| `database-patterns` | Referenced in main devloop workflow for data model work |
| `task-checkpoint` | Would ensure consistent post-task verification |
| `project-context` | Auto-detects tech stack, reducing manual skill selection |

#### B. Conflicting Skill: `refactoring-analysis`

The `refactoring-analysis` skill explicitly states:
> "IMPORTANT: Always invoke the refactor-analyzer agent to perform the analysis."

This creates confusion since the engineer has its own "refactorer mode" but the skill tells it to delegate.

**Options:**
- Remove the skill from engineer and rely on delegation, OR
- Update the skill to be usable directly by engineer without requiring a separate agent

#### C. Recommended Skill Configuration

```yaml
skills: 
  # Core skills (always relevant)
  - tool-usage-policy      # For consistent tool usage
  - plan-management        # For plan awareness
  - architecture-patterns  # For design decisions
  
  # Language skills (invoke based on project)
  - go-patterns
  - react-patterns  
  - java-patterns
  - python-patterns
  
  # Workflow skills
  - git-workflows          # For git mode
  - task-checkpoint        # NEW: For consistent verification
  
  # Context skills
  - project-context        # NEW: For auto-detecting tech stack
  - complexity-estimation  # NEW: For assessing task difficulty
  
  # Domain skills (invoke when relevant)
  - api-design             # NEW: For API implementation
  - database-patterns      # NEW: For data model work
  - testing-strategies     # NEW: For understanding test requirements
```

---

### 2. Prompt Structure Improvements

#### A. Missing Model Escalation Guidance

The agent uses `model: sonnet` but has no guidance on when to escalate to opus.

**Recommended Addition:**

```markdown
<model_escalation>
## When to Recommend Escalation to Opus

Suggest escalation (via output, not self-escalation) when:
- Architecture decision affects 5+ files or 3+ systems
- Security-sensitive code paths (auth, crypto, payment)
- Performance-critical hot paths identified
- Complex async/concurrency patterns required
- User explicitly asks for "thorough" or "comprehensive" analysis

**Output format:**
> ⚠️ This task has high complexity/stakes. Consider running with opus model for deeper analysis.
</model_escalation>
```

#### B. Missing Anti-Pattern Section

Currently no guidance on what NOT to do.

**Recommended Addition:**

```markdown
<constraints>
<constraint type="scope">Do NOT implement features without user approval of architecture</constraint>
<constraint type="scope">Do NOT skip exploration phase for unfamiliar codebases</constraint>
<constraint type="scope">Do NOT make security-related changes without flagging for review</constraint>
<constraint type="scope">Do NOT modify test files while implementing features (separate concerns)</constraint>
<constraint type="efficiency">Do NOT read more than 10 files in exploration without synthesizing findings</constraint>
<constraint type="efficiency">Do NOT invoke multiple skills for the same language (pick one)</constraint>
</constraints>
```

#### C. Improved Skill Integration Instructions

Current skill integration just lists when to invoke skills. Needs explicit workflow integration.

**Recommended Addition:**

```markdown
<skill_workflow>
## Skill Usage During Modes

### Explorer Mode
1. First: Invoke `tool-usage-policy` (always)
2. If project type unknown: Invoke `project-context` to detect
3. Then: Invoke appropriate language pattern skill

### Architect Mode
1. First: Invoke `architecture-patterns`
2. Then: Invoke language-specific skill (go-patterns, react-patterns, etc.)
3. If API design: Invoke `api-design`
4. If data models: Invoke `database-patterns`

### Refactorer Mode
1. Invoke `refactoring-analysis` for methodology (or use built-in patterns)
2. Use language-specific skill for idiom checking

### Git Mode
1. Invoke `git-workflows` for complex operations
2. Skip skill invocation for simple commits
</skill_workflow>
```

---

### 3. Mode Detection Improvements

#### A. Add Complexity-Aware Mode Selection

Current mode detection is purely keyword-based. Needs complexity awareness.

**Recommended Addition:**

```markdown
<mode_selection_refinement>
After initial mode detection, assess complexity:

**Simple (proceed directly):**
- Single file changes
- Following established patterns
- Clear, specific request

**Medium (standard workflow):**
- 2-5 files affected
- Some new patterns needed
- Clear requirements

**Complex (enhanced workflow):**
- 5+ files affected
- New architectural patterns
- Unclear requirements
→ Consider invoking `complexity-estimation` skill first
→ May need multiple architect approaches
</mode_selection_refinement>
```

#### B. Add Cross-Mode Awareness

Some tasks span multiple modes. Need guidance.

**Recommended Addition:**

```markdown
<multi_mode_tasks>
Some tasks require multiple modes. Execute in order:

**"Add authentication to the API":**
1. Explorer mode: Understand current auth patterns
2. Architect mode: Design auth approach
3. (User approval)
4. Implementation (return to caller)

**"Refactor and commit the changes":**
1. Refactorer mode: Analyze and execute
2. Git mode: Stage and commit
</multi_mode_tasks>
```

---

### 4. Output Format Improvements

#### A. Structured Exploration Output

Explorer mode says to include file references but doesn't specify a standard format.

**Recommended Addition:**

```markdown
<explorer_output_format>
## [Feature/Component] Exploration Summary

### Entry Points
| File | Line | Description |
|------|------|-------------|
| path/to/file.go | 42 | Main handler |

### Execution Flow
1. `file.go:42` → Receives request
2. `service.go:88` → Processes data
3. ...

### Key Components
- **ComponentA** (`path/file.go`): Responsibility
- **ComponentB** (`path/other.go`): Responsibility

### Architecture Insights
- Pattern used: [Repository/Service/etc]
- Notable: [Any interesting findings]

### Essential Files for Understanding
1. `path/to/main.go` - Entry point
2. `path/to/service.go` - Core logic
3. ...
</explorer_output_format>
```

#### B. Token-Conscious Output Guidelines

**Recommended Addition:**

```markdown
<output_efficiency>
## Token-Conscious Output

- Exploration summaries: Max 500 tokens
- Architecture proposals: Max 800 tokens per approach
- Refactoring reports: Max 1000 tokens
- Git summaries: Max 200 tokens

If findings exceed these limits:
1. Prioritize most important items
2. Offer to elaborate on specific areas
3. Use AskUserQuestion to let user choose focus
</output_efficiency>
```

---

### 5. Workflow Enforcement Improvements

#### A. Add Parallel Execution Awareness

**Recommended Addition:**

```markdown
<parallel_execution>
## Parallel Task Handling

When invoked with context indicating parallel tasks:

1. Check for `[parallel:X]` markers in plan context
2. If implementing parallel group, consider:
   - Read all relevant files FIRST (parallel reads)
   - Implement in order of least dependencies
   - Flag any discovered dependencies

**DO parallelize:**
- Reading multiple independent files
- Exploring different code areas

**DON'T parallelize:**
- Writing to the same file
- Changes with shared state
</parallel_execution>
```

#### B. Add Plan Synchronization Checkpoint

**Recommended Addition:**

```markdown
<plan_sync>
## Plan Synchronization

Before starting significant work:
1. Read `.devloop/plan.md` if exists
2. Identify relevant task(s)
3. Note task acceptance criteria

After completing work:
1. Return structured output indicating:
   - Which task(s) were addressed
   - Whether acceptance criteria were met
   - Recommended plan updates

**Format:**
```markdown
### Task Completion Status
- Task X.Y: [Complete/Partial/Blocked]
- Acceptance: [Met/Not Met/Partially Met]
- Plan update: [Mark complete/Add progress note/Add blocker]
```
</plan_sync>
```

---

### 6. Delegation Improvements

#### A. Expand Delegation Table

Current delegation is limited. Recommended expansion:

```markdown
<delegation>
<delegate_to agent="devloop:code-reviewer" when="Quality review needed">
    <reason>Specialized for code review with confidence scoring</reason>
</delegate_to>
<delegate_to agent="devloop:qa-engineer" when="Test creation needed">
    <reason>Specialized for test generation and execution</reason>
</delegate_to>
<delegate_to agent="devloop:security-scanner" when="Security analysis needed">
    <reason>Specialized for OWASP and vulnerability scanning</reason>
</delegate_to>
<delegate_to agent="devloop:complexity-estimator" when="Task sizing unclear">
    <reason>Specialized for effort estimation before deep work</reason>
</delegate_to>
<delegate_to agent="devloop:doc-generator" when="Documentation needed">
    <reason>Specialized for README, API docs, and inline documentation</reason>
</delegate_to>
</delegation>
```

#### B. Add Self-Awareness for Limitations

**Recommended Addition:**

```markdown
<limitations>
## Known Limitations

This agent should NOT attempt to:
- Perform comprehensive security audits (use security-scanner)
- Generate comprehensive test suites (use qa-engineer)
- Create detailed documentation (use doc-generator)
- Make final deployment decisions (use task-planner DoD mode)

When these needs arise, delegate or recommend the appropriate agent.
</limitations>
```

---

## Recommended Changes Summary

| Area | Change | Priority | Effort |
|------|--------|----------|--------|
| Skills | Add `complexity-estimation` skill | High | Low |
| Skills | Add `project-context` skill | High | Low |
| Skills | Add `task-checkpoint` skill | Medium | Low |
| Skills | Add `api-design`, `database-patterns`, `testing-strategies` | Medium | Low |
| Skills | Remove or clarify `refactoring-analysis` conflict | Medium | Medium |
| Prompt | Add model escalation guidance | High | Low |
| Prompt | Add anti-pattern constraints | High | Low |
| Prompt | Improve skill workflow instructions | Medium | Medium |
| Modes | Add complexity-aware mode selection | Medium | Medium |
| Modes | Add cross-mode awareness | Low | Medium |
| Output | Add structured exploration output format | Medium | Low |
| Output | Add token-conscious guidelines | Low | Low |
| Workflow | Add parallel execution awareness | Medium | Medium |
| Workflow | Add plan synchronization checkpoint | High | Medium |
| Delegation | Expand delegation table | Low | Low |
| Delegation | Add self-awareness for limitations | Low | Low |

---

## Quick Wins (Highest Impact, Lowest Effort)

1. **Add `complexity-estimation` skill** - Helps the engineer right-size its approach
2. **Add `project-context` skill** - Auto-detects language, reducing manual skill selection
3. **Add anti-pattern constraints** - Prevents common mistakes
4. **Add model escalation guidance** - Knows when to flag for opus
5. **Improve skill workflow instructions** - Clear WHEN to invoke each skill in each mode

---

## Next Steps

1. [ ] Update `engineer.md` skills list
2. [ ] Add model escalation section to engineer.md
3. [ ] Add constraints/anti-patterns section to engineer.md
4. [ ] Add skill workflow section to engineer.md
5. [ ] Add structured output formats to engineer.md
6. [ ] Add plan sync checkpoint section to engineer.md
7. [ ] Review and update delegation section
8. [ ] Test changes with sample workflows

---

## Files Affected

- `plugins/devloop/agents/engineer.md` - Primary changes
- `plugins/devloop/skills/refactoring-analysis/SKILL.md` - Clarify usage
- Potentially create new skill: `plugins/devloop/skills/workflow-loop/SKILL.md`
