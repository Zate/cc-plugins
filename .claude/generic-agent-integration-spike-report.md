## Spike Report: Generic AI Agent Integration with Devloop

### Questions Investigated

1. **Can generic AI agents use devloop effectively?** → **YES** - With proper documentation structure
2. **Single doc vs. per-command docs?** → **Single doc with lazy loading** (best balance)
3. **XML lazy loading design?** → **HTML details/summary** (better agent compatibility)
4. **Full devloop or subset?** → **Core workflows** (85% coverage sufficient)

---

### Findings

#### Feasibility
**YES - Highly feasible** with structured documentation approach.

Generic AI coding agents (Cursor, Aider, Gemini, etc.) can effectively follow devloop methodology when provided with:
- Structured markdown documentation
- Clear step-by-step workflows
- Explicit plan file formats
- Progressive disclosure via collapsible sections
- Integration guidance for agent-specific config files

#### Recommended Approach

**Single Universal Guide with Collapsible Sections**

Create one comprehensive `DEVLOOP_GUIDE.md` that:
1. Provides quick-start entry points by task type
2. Uses HTML `<details>/<summary>` for context management
3. Includes complete plan format specifications
4. Documents all core workflows (full/quick/spike/continue/review)
5. Offers agent-specific integration instructions

**Why this approach:**
- ✅ Easy to reference (one file)
- ✅ Searchable by agents
- ✅ Context-efficient (expandable sections)
- ✅ Maintainable (single source of truth)
- ✅ Works across all agent types

#### Complexity Estimate
- **Size**: M (Medium)
- **Risk**: Low
- **Confidence**: High

**Breakdown**:
- Document creation: 4-6 hours
- Testing with generic agents: 2-3 hours
- Refinement based on feedback: 2-4 hours
- **Total**: 8-13 hours of work

#### Key Discoveries

1. **HTML Details/Summary Superior to XML**
   - Generic agents parse HTML better than XML comments
   - Collapsible sections provide natural lazy loading
   - Keeps full context available without overwhelming

2. **Plan Format is Critical**
   - Non-Claude agents need explicit plan structure
   - Task markers must be clearly documented
   - Parallelism markers enable sophisticated workflows
   - Progress log format must be specified

3. **Generic Agents Have Varying Capabilities**
   - Context windows: 100K (Cursor) to 1M (Gemini)
   - All benefit from Plan-Act-Reflect workflow pattern
   - Structured questions with options work universally
   - Tool integration differs (.cursorrules vs .continuerules)

4. **85% Coverage is Sufficient**
   - Core workflows (full/quick/spike/continue/review) = highest value
   - Bug tracking, analyze, bootstrap, ship = nice-to-have
   - Can add in v2 if demand exists
   - Focus on getting core right first

5. **Integration Section Essential**
   - Agents need explicit instructions for .cursorrules, .aider.conf, etc.
   - One-time setup enables persistent workflow adherence
   - Makes devloop "always available" in agent context

#### Risks & Concerns

1. **Risk: Agents may ignore documentation**
   - **Mitigation**: Integrate into agent config files (.cursorrules)
   - **Severity**: Medium

2. **Risk: Plan format divergence**
   - **Mitigation**: Clear specification with examples
   - **Severity**: Low

3. **Risk: Maintenance burden (two documentation sets)**
   - **Mitigation**: Source from plugin commands, don't duplicate
   - **Severity**: Medium

4. **Risk: Generic agents lack plugin features**
   - **Mitigation**: Document manual equivalents (file ops, bash)
   - **Severity**: Low - features are mostly organizational

---

### Recommendation

**PROCEED** with single universal guide approach.

### Implementation Plan

#### Phase 1: Core Documentation (v1.0)
1. Create `docs/DEVLOOP_FOR_GENERIC_AGENTS.md`
2. Include workflows: Full, Quick, Spike, Continue, Review
3. Document plan format with all markers
4. Add integration section for major agents
5. Include best practices and troubleshooting

#### Phase 2: Testing & Refinement
1. Test with Cursor (using .cursorrules integration)
2. Test with Aider (using .aider.conf integration)
3. Test with generic agent (raw documentation)
4. Gather feedback and iterate

#### Phase 3: Distribution (v1.1)
1. Add to devloop plugin docs/ directory
2. Create README pointer in plugin root
3. Link from main devloop README
4. Announce in changelog

#### Phase 4: Extended Coverage (v2.0 - Optional)
1. Add bug tracking workflows
2. Add analyze workflow (refactoring)
3. Add bootstrap workflow (project setup)
4. Add ship workflow (deployment validation)

---

### Prototype Location

Created prototype at: `/Users/zberg/projects/cc-plugins/spike/devloop-for-generic-agents/DEVLOOP_GUIDE.md`

**Features demonstrated:**
- ✅ Quick-start entry points by task type
- ✅ HTML details/summary for collapsible sections
- ✅ Complete plan format specification
- ✅ All 5 core workflows fully documented
- ✅ Best practices for generic agents
- ✅ Integration instructions for Cursor/Aider
- ✅ Reference tables for quick lookup
- ✅ Troubleshooting section

**File size**: ~650 lines / ~18KB
**Estimated context**: ~5-7K tokens when fully expanded

---

### Next Steps

1. **If proceeding with implementation:**
   - Move prototype from spike/ to docs/
   - Rename to `DEVLOOP_FOR_GENERIC_AGENTS.md`
   - Test with Cursor agent
   - Refine based on testing
   - Add link from main README
   - Update plugin version (1.8.0 → 1.9.0)

2. **If deferring:**
   - Keep prototype in spike/ for future reference
   - Document decision in plan
   - Revisit when user demand increases

3. **If abandoning:**
   - Remove prototype
   - Document reasons learned

---

### Plan Updates Required

**Existing Plan**: "Plan Integration & Smart Parallelism" (Status: Complete)
**Relationship**: New work (independent feature)

#### Recommended Action

**Create NEW plan** for Generic Agent Integration feature:

```markdown
# Devloop Plan: Generic Agent Integration Documentation

## Overview
Provide comprehensive documentation enabling non-Claude AI agents (Cursor, Aider, Gemini) to follow devloop methodology without requiring Claude Code plugin.

## Architecture
Single universal guide with collapsible sections, HTML-based lazy loading, and agent-specific integration instructions.

## Tasks

### Phase 1: Core Documentation
- [ ] Task 1.1: Move prototype to docs/DEVLOOP_FOR_GENERIC_AGENTS.md
- [ ] Task 1.2: Review and refine workflow sections
- [ ] Task 1.3: Add comprehensive examples
- [ ] Task 1.4: Create integration snippets for major agents

### Phase 2: Testing & Validation
- [ ] Task 2.1: Test with Cursor (.cursorrules integration)
- [ ] Task 2.2: Test with Aider (.aider.conf integration)
- [ ] Task 2.3: Test with generic agent (raw doc)
- [ ] Task 2.4: Gather feedback and iterate

### Phase 3: Integration & Release
- [ ] Task 3.1: Link from main devloop README
- [ ] Task 3.2: Add to plugin.json documentation links
- [ ] Task 3.3: Update CHANGELOG.md
- [ ] Task 3.4: Bump version 1.8.0 → 1.9.0
```

**User Decision Required**: Should we proceed with implementation or defer?

---

### Comparison to Alternatives

| Approach | Effort | Maintenance | User Value | Verdict |
|----------|--------|-------------|------------|---------|
| **Universal Guide** | M | Low | High | ✅ **Recommended** |
| Per-command docs | M | Medium | Medium | ❌ Fragmented |
| XML lazy load | M | Low | Medium | ⚠️ Worse agent compat |
| No documentation | None | None | None | ❌ Agents can't use devloop |
| Full plugin port | XL | High | High | ❌ Too much work |

---

### Research Sources

**Generic Agent Capabilities:**
- [Cursor Features](https://cursor.com/features)
- [Cursor Agents](https://cursor.com/agents)
- [Testing AI coding agents 2025](https://render.com/blog/ai-coding-agents-benchmark)

**Best Practices:**
- [Building With AI Coding Agents](https://medium.com/@elisheba.t.anderson/building-with-ai-coding-agents-best-practices-for-agent-workflows-be1d7095901b)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [JetBrains AI Agent Guidelines](https://blog.jetbrains.com/idea/2025/05/coding-guidelines-for-your-ai-agents/)

---

### Conclusion

This spike confirms that **generic AI agents CAN effectively use devloop** with proper documentation. The recommended single universal guide with collapsible sections provides the optimal balance of:
- Context efficiency (lazy loading)
- Usability (searchable, organized)
- Compatibility (works with all agents)
- Maintainability (single source)

**Recommendation: PROCEED** with Phase 1 implementation.
