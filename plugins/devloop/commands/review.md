---
description: Comprehensive code review for existing changes or PR
argument-hint: Optional file/PR to review
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill"]
---

# Code Review

Comprehensive code review workflow for existing changes, PRs, or specific files.

## Plan Integration

Code review is a read-only operation that doesn't modify the plan, but:
1. Check if `.devloop/plan.md` exists for context on what's being reviewed
2. Reference plan task descriptions in review comments when relevant
3. Note in review output if reviewed changes relate to specific plan tasks

See `Skill: plan-management` for plan format.

## When to Use

- Review uncommitted changes before commit
- Review a pull request
- Review specific files or modules
- Pre-merge quality gate
- Learning/understanding existing code

## Workflow

### Phase 1: Identify Scope

**Goal**: Determine what to review

Initial request: $ARGUMENTS

**Actions**:
1. Determine review scope:
   ```
   Use AskUserQuestion:
   - question: "What would you like to review?"
   - header: "Scope"
   - options:
     - Uncommitted changes (Review git diff - Recommended)
     - Staged changes (Review git diff --cached)
     - Recent commits (Review last N commits)
     - Specific files (I'll specify paths)
     - Pull request (Provide PR number/URL)
   ```

2. Gather the code to review:
   ```bash
   # Based on selection
   git diff                    # Uncommitted
   git diff --cached           # Staged
   git log -p -n 3            # Recent commits
   gh pr diff [number]        # PR
   ```

3. Create todo list for review phases

### Phase 2: Context Gathering

**Goal**: Understand what the changes are trying to accomplish

**Actions**:
1. Read the changed files
2. Understand the purpose:
   - What problem is being solved?
   - What approach was taken?
   - What patterns are being used?

3. If reviewing a PR, read the description
4. Identify related code that might be affected

### Phase 3: Multi-Perspective Review

**Goal**: Comprehensive review from multiple angles

**Actions**:
1. Launch review agents in parallel (model: sonnet for balanced, opus for critical code):

   **Core Reviews (always run):**
   ```
   - code-reviewer: Focus on correctness, bugs, logic errors
   - code-reviewer: Focus on code quality, readability, maintainability
   - code-reviewer: Focus on project conventions and patterns
   ```

   **Specialized Reviews (based on change type):**
   ```
   - If security-related: security-scanner agent
   - If performance-related: Focus on performance implications
   - If API changes: Focus on backwards compatibility
   ```

2. Invoke relevant skills:
   ```
   Skill: security-checklist  # If security-relevant
   Skill: [language]-patterns # Based on file types
   ```

### Phase 4: Consolidate Findings

**Goal**: Organize and prioritize issues

**Actions**:
1. Collect all findings from agents
2. Categorize by severity:

   | Severity | Description | Action |
   |----------|-------------|--------|
   | **Critical** | Bugs, security issues, data loss | Must fix |
   | **High** | Logic errors, performance issues | Should fix |
   | **Medium** | Code quality, maintainability | Consider fixing |
   | **Low** | Style, minor improvements | Optional |
   | **Nitpick** | Preferences, suggestions | Informational |

3. Remove duplicates and false positives
4. Add context and suggested fixes

### Phase 5: Present Findings

**Goal**: Communicate review results clearly

**Actions**:
1. Generate review report:

```markdown
## Code Review Report

### Summary
- **Files Reviewed**: [N]
- **Lines Changed**: +[added] / -[removed]
- **Issues Found**: [critical] critical, [high] high, [medium] medium, [low] low

### Overall Assessment
[APPROVE / REQUEST_CHANGES / COMMENT]

---

### Critical Issues (Must Fix)

#### 1. [Issue Title]
**File**: [path:line]
**Type**: [Bug/Security/Logic Error]

**Problem**:
[Description of the issue]

**Code**:
```[language]
[problematic code]
```

**Suggested Fix**:
```[language]
[fixed code]
```

---

### High Priority Issues

[Similar format]

---

### Medium Priority Issues

[Similar format]

---

### Low Priority / Suggestions

[Brief list format]

---

### Positive Observations

- [Good practice observed]
- [Well-designed pattern]

---

### Summary

**Recommendation**: [Approve / Request changes / Needs discussion]

**Key Actions**:
1. [Most important fix]
2. [Second most important]
3. [Third most important]
```

2. Ask user how to proceed:
   ```
   Use AskUserQuestion:
   - question: "Review complete. How would you like to proceed?"
   - header: "Action"
   - options:
     - Fix critical only (Address blockers only - Recommended)
     - Fix all issues (Apply suggested fixes)
     - Discuss (Let's talk about specific findings)
     - Accept as-is (Acknowledge and proceed)
   ```

### Phase 6: Apply Fixes (Optional)

**Goal**: Address identified issues

**Actions**:
1. If user chose to fix:
   - Apply fixes in priority order
   - Re-run relevant tests
   - Update review report

2. If user wants discussion:
   - Dive into specific issues
   - Explain rationale
   - Adjust recommendations

---

## Review Focus Areas

### Always Check
- [ ] Logic correctness
- [ ] Edge cases handled
- [ ] Error handling
- [ ] Input validation
- [ ] Resource cleanup
- [ ] Thread safety (if concurrent)

### Code Quality
- [ ] Single responsibility
- [ ] DRY (no duplication)
- [ ] Clear naming
- [ ] Appropriate comments
- [ ] Consistent style

### Security
- [ ] No hardcoded secrets
- [ ] Input sanitization
- [ ] Auth/authz checks
- [ ] SQL/command injection
- [ ] XSS prevention

### Performance
- [ ] No N+1 queries
- [ ] Appropriate caching
- [ ] No blocking calls
- [ ] Resource limits

### Testing
- [ ] Tests exist
- [ ] Tests are meaningful
- [ ] Edge cases tested
- [ ] No test pollution

---

## Model Usage

| Phase | Model | Rationale |
|-------|-------|-----------|
| Scope | haiku | Simple selection |
| Context | sonnet | Need understanding |
| Review | sonnet/opus | Depends on criticality |
| Consolidate | sonnet | Analysis needed |
| Present | haiku | Formatting |
| Fix | sonnet | Implementation |

Use opus for:
- Security-sensitive code
- Core business logic
- High-risk changes
- Financial/payment code
