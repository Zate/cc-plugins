# Security Plugin Improvement Analysis

## Current State Analysis

### Plugin Structure
- **18 specialized auditor agents** (authentication, encoding, API, crypto, etc.)
- **11 skills** (ASVS requirements, vulnerability patterns, remediation guides)
- **2 commands** (/security, /security:audit)
- **Hooks** for real-time validation (PreToolUse/PostToolUse)
- **Version**: 1.3.0

### Identified Issues

#### 1. Token Inefficiency
- **Problem**: 18 agents × ~350 lines each = massive token overhead
- **Evidence**: Each auditor repeats similar structure:
  - Audit workflow (8 phases)
  - Findings format template
  - Severity classification table
  - Output format examples
  - ASVS requirements reference
  - CWE mappings
- **Impact**: High token cost, slower execution, context bloat

#### 2. Agent Consolidation Opportunity
- **Current**: 18 specialized agents with significant overlap
- **Devloop precedent**: Consolidated 18 → 9 agents (v2.0)
- **Consolidation potential**:
  - Injection-related: encoding-auditor, api-auditor, validation-auditor
  - Auth-related: authentication-auditor, authorization-auditor, session-auditor, token-auditor, oauth-auditor
  - Data-related: crypto-auditor, data-protection-auditor, file-auditor, logging-auditor
  - Web-related: frontend-auditor, communication-auditor, webrtc-auditor
  - Keep standalone: config-auditor, architecture-auditor

#### 3. Consistency Issues
- **Problem**: Running audit multiple times yields different results
- **Causes**:
  - Non-deterministic file traversal
  - No standardized search order
  - Agent variations in interpretation
  - Different context on each run
- **Solution needed**: Deterministic patterns, standardized workflows

#### 4. Modification Safety
- **Current state**: Agents say "read-only" but no hard enforcement
- **Hooks block modifications** but agent instructions could be clearer
- **Risk**: Agent could accidentally modify code during scan
- **Solution needed**:
  - Explicit `allowed-tools` without Write/Edit
  - Clear warnings in agent prompts
  - Documentation that hooks provide safety layer

#### 5. Plugin Architecture Clarity
- **Current**: Single plugin with two purposes
  1. Audit scanning (commands + agents)
  2. Real-time blocking (hooks)
- **Question**: Should these be split?
  - **Option A**: Keep unified, improve documentation
  - **Option B**: Split into security-audit + security-guard

---

## Devloop Plugin Learnings

### Key Improvements from Devloop v2.0+

1. **Super-Agent Pattern**
   - Consolidated 18 → 9 agents
   - Multi-mode operation (engineer has 4 modes)
   - Mode detection from context
   - Result: 50% token reduction

2. **XML-Structured Prompts**
   - `<system_role>`, `<capabilities>`, `<mode_detection>`
   - Clearer organization
   - Better parsing for Claude
   - See: `engineer.md` structure

3. **Strategic Model Selection**
   - haiku (0.2x): Classification, simple analysis
   - sonnet (1x): Standard implementation
   - opus (5x): Critical review only
   - Applied consistently across agents

4. **Centralized Knowledge**
   - Skills contain shared patterns
   - Agents reference skills, don't duplicate
   - Example: `complexity-estimation` skill used by multiple agents

5. **Command Orchestration Pattern**
   - Commands stay in control
   - Agents are helpers, not silent controllers
   - User sees progress at every phase
   - Example: `/security:audit` is phased with checkpoints

---

## Proposed Improvements

### 1. Consolidate Agents: 18 → 5

#### New Super-Auditors

**A. injection-auditor** (consolidates 3 agents)
- Replaces: encoding-auditor, validation-auditor, parts of api-auditor
- ASVS: V1 (Encoding & Sanitization), V4 (Validation)
- Modes:
  - sql-injection
  - command-injection
  - nosql-injection
  - template-injection
  - deserialization
  - output-encoding
- Model: sonnet
- Skills: asvs-requirements, vuln-patterns-core, vuln-patterns-languages

**B. auth-security-auditor** (consolidates 5 agents)
- Replaces: authentication-auditor, authorization-auditor, session-auditor, token-auditor, oauth-auditor
- ASVS: V6 (Authentication), V7 (Authorization), V10 (Session)
- Modes:
  - password-security
  - mfa-analysis
  - session-management
  - authorization-checks
  - oauth-integration
- Model: sonnet
- Skills: asvs-requirements, vuln-patterns-core, remediation-auth

**C. data-security-auditor** (consolidates 4 agents)
- Replaces: crypto-auditor, data-protection-auditor, file-auditor, logging-auditor
- ASVS: V11 (Crypto), V12 (Data), V13 (Files), V14 (Logging)
- Modes:
  - cryptography
  - data-protection
  - file-upload
  - sensitive-logging
- Model: sonnet
- Skills: asvs-requirements, vuln-patterns-core, remediation-crypto

**D. web-api-auditor** (consolidates 4 agents)
- Replaces: frontend-auditor, api-auditor (REST parts), communication-auditor, webrtc-auditor
- ASVS: V3 (Frontend), V4 (API), V15 (Communication), V16 (WebRTC)
- Modes:
  - xss-analysis
  - api-security
  - tls-config
  - webrtc-security
- Model: sonnet
- Skills: asvs-requirements, vuln-patterns-core, vuln-patterns-languages

**E. Keep Standalone** (2 agents)
- config-auditor (V9 - Configuration)
- architecture-auditor (V2 - Architecture)
- Reason: Unique focus, minimal overlap

#### Result: 18 → 6 agents (~66% reduction)

### 2. XML-Structured Prompt Format

Apply engineer.md structure to all auditors:

```markdown
---
name: injection-auditor
description: ...
model: sonnet
color: red
skills: asvs-requirements, vuln-patterns-core
---

<system_role>
You are a Security Auditor specializing in injection prevention.
Your primary goal is: Detect and report injection vulnerabilities.

<identity>
    <role>Injection Security Specialist</role>
    <expertise>SQL, NoSQL, Command, Template, Deserialization</expertise>
    <personality>Thorough, precise, security-focused</personality>
</identity>
</system_role>

<capabilities>
<capability priority="core">
    <name>SQL Injection Detection</name>
    <description>Identify parameterization issues, string concat in queries</description>
</capability>
...
</capabilities>

<mode_detection>
<instruction>
Determine vulnerability types from project context before scanning.
Focus on detected languages and frameworks.
</instruction>

<mode name="sql-injection">
    <triggers>
        <trigger>Database detected in project-context.json</trigger>
        <trigger>SQL keywords in codebase</trigger>
    </triggers>
    <focus>Parameterized queries, ORM usage, string concatenation</focus>
</mode>
...
</mode_detection>

<workflow>
...
</workflow>

<output_format>
...
</output_format>
```

### 3. Improve Consistency

**A. Deterministic File Traversal**
```markdown
## File Discovery Order

1. Read `.claude/project-context.json` for source directories
2. Use Glob with deterministic patterns:
   - Sort alphabetically
   - Process root files first
   - Then subdirectories depth-first
3. For each file:
   - Apply mode-specific Grep patterns
   - Record line numbers for findings
   - Use consistent severity classification
```

**B. Standardized Detection Patterns**
- Move all regex patterns to `vuln-patterns-core` skill
- Reference skill from agents instead of duplicating
- Version patterns so changes are tracked
- Example:
  ```markdown
  **SQL Injection Detection:**
  Invoke `Skill: vuln-patterns-core` → section "SQL Injection Patterns"
  Apply patterns to files in deterministic order
  ```

**C. Deduplication in Auditor**
- Each auditor deduplicates its own findings before returning
- Use: (file_path, line_number, vulnerability_type) as unique key
- Keep highest severity when duplicates found

### 4. Ensure No Modifications

**A. Agent `allowed-tools`**
```yaml
allowed-tools:
  - Read
  - Glob
  - Grep
  # Explicitly NOT: Write, Edit, MultiEdit, Bash
```

**B. Add Safety Warning to Prompts**
```markdown
<safety>
⚠️ **READ-ONLY OPERATION** ⚠️

This agent performs ANALYSIS ONLY and MUST NOT modify code.

<rules>
- NEVER use Write, Edit, or MultiEdit tools
- NEVER suggest code changes directly in files
- Only REPORT findings with recommendations
- Hooks will block modifications as additional safety
</rules>
</safety>
```

**C. Document Hook Safety**
```markdown
## Security Guardrails

The security plugin has TWO layers of protection:

1. **Agent Design**: Auditors have no Write/Edit tools
2. **Hooks**: PreToolUse hooks block dangerous operations

This defense-in-depth ensures scans are always read-only.
```

### 5. Plugin Architecture Decision

**Recommendation: Keep Unified, Improve Documentation**

Reasons:
- Scanning and blocking are complementary features
- Users expect both from a "security" plugin
- Splitting adds installation complexity
- Current structure works, just needs clarity

Improvements:
```markdown
# Security Plugin

## Two Complementary Features

### 1. Security Audit (Manual Scan)
Commands: `/security:audit`
Agents: 6 auditors
Purpose: Comprehensive ASVS 5.0 aligned security review
When: On-demand, before releases, security reviews

### 2. Security Guard (Real-time Protection)
Hooks: PreToolUse on Write/Edit/Bash
Purpose: Block dangerous patterns during development
When: Automatic, every file write and bash command

Both features share:
- Skills (vulnerability-patterns, asvs-requirements)
- Detection logic (centralized in skills)
- Severity classification
```

---

## Implementation Plan

### Phase 1: Create Super-Auditors
1. Create `injection-auditor.md` (consolidate 3)
2. Create `auth-security-auditor.md` (consolidate 5)
3. Create `data-security-auditor.md` (consolidate 4)
4. Create `web-api-auditor.md` (consolidate 4)
5. Test each with sample projects

### Phase 2: Update Command
1. Update `audit.md` to reference new 6 auditors
2. Simplify Phase 2 (Planning) with fewer auditors
3. Update artifact structure
4. Test full audit flow

### Phase 3: Safety Enhancements
1. Add `allowed-tools` to all agent frontmatter
2. Add `<safety>` sections to all agents
3. Update README with layered security model
4. Add tests for read-only verification

### Phase 4: Consistency Improvements
1. Enhance `vuln-patterns-core` with all detection regex
2. Add deterministic file ordering to workflow
3. Standardize severity classification
4. Test for consistent results across runs

### Phase 5: Documentation
1. Update README with new architecture
2. Document super-auditor modes
3. Create migration guide (v1.3 → v2.0)
4. Update marketplace.json description

### Phase 6: Cleanup
1. Move old agents to `agents/_archive/`
2. Update version to 2.0.0
3. Test full plugin end-to-end
4. Commit and push

---

## Expected Outcomes

| Metric | Current | Improved | Improvement |
|--------|---------|----------|-------------|
| Agents | 18 | 6 | 66% reduction |
| Avg Agent Size | ~350 lines | ~250 lines | 28% reduction |
| Token Usage (audit) | ~15,000 | ~6,000 | 60% reduction |
| Consistency | Variable | Deterministic | ✓ |
| Modification Risk | Low (hooks only) | None (tools + hooks) | ✓ |
| Architecture Clarity | Unclear | Documented | ✓ |

---

## Questions Answered

### Q1: Can we consolidate agents?
**A**: Yes, 18 → 6 agents (66% reduction) using super-agent pattern from devloop

### Q2: Can we ensure no modifications without user approval?
**A**: Yes, via:
1. Explicit `allowed-tools` (no Write/Edit)
2. Safety warnings in prompts
3. Hooks as second layer
4. Documentation of read-only guarantee

### Q3: Can we get consistent results across runs?
**A**: Yes, via:
1. Deterministic file traversal order
2. Standardized detection patterns in skills
3. Consistent severity classification
4. Deduplication in auditors

### Q4: Should we split into scan vs warn/block plugins?
**A**: No, keep unified because:
1. Features are complementary
2. Users expect integrated security
3. Shared skills and detection logic
4. Just improve documentation to clarify purposes

---

## Next Steps

1. Get user approval for consolidation approach
2. Implement Phase 1 (create super-auditors)
3. Test with sample projects
4. Iterate based on findings
5. Complete remaining phases
6. Release as v2.0.0
