---
description: Run a comprehensive security audit aligned with OWASP ASVS 5.0
argument-hint: Optional audit type (quick, standard, comprehensive) or specific domain
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "Task", "AskUserQuestion", "TodoWrite", "Skill"]
---

# Security Audit - Interactive Phased Workflow

A comprehensive security audit aligned with OWASP ASVS 5.0, with visibility and control at every step.

## Core Principles

- **Visibility**: User always sees what's happening
- **Control**: User can adjust at each phase
- **Progressive**: Findings build up visibly
- **Selective**: User controls final report content
- **Resumable**: Artifacts allow picking up where left off

## Environment Context

Use the `Skill: project-context` to detect project configuration if `.claude/project-context.json` doesn't exist.

---

## Phase 0: Triage

**Goal**: Parse arguments and determine audit scope

**Model**: haiku

**Actions**:
1. Check if `$ARGUMENTS` is provided:

   | Argument | Action |
   |----------|--------|
   | `quick` | Set level=L1, skip interactive scoping |
   | `standard` | Set level=L1+L2, skip interactive scoping |
   | `comprehensive` or `full` | Set level=L1+L2+L3, skip interactive scoping |
   | `auth` or `authentication` | Focus on V6, V7 chapters |
   | `api` | Focus on V4, V1, V2 chapters |
   | `frontend` or `web` | Focus on V3 chapter |
   | `crypto` | Focus on V11, V12 chapters |
   | (none) | Proceed to interactive Phase 1 |

2. Create initial todo list for tracking:
   ```
   - [ ] Phase 1: Discovery
   - [ ] Phase 2: Planning
   - [ ] Phase 3: Execution
   - [ ] Phase 4: Review
   - [ ] Phase 5: Report
   ```

3. Create `.claude/security/` directory if it doesn't exist

---

## Phase 1: Discovery

**Goal**: Understand the project's technology stack

**Model**: haiku

**Actions**:
1. Mark Phase 1 as in_progress in todos
2. Check for existing context:
   ```
   Use Read to check if `.claude/project-context.json` exists
   ```

3. If no context exists, invoke `Skill: project-context` to:
   - Detect languages from config files (package.json, go.mod, etc.)
   - Identify frameworks from dependencies
   - Find security-relevant features (auth, uploads, payments, etc.)
   - Write results to `.claude/project-context.json`

4. Read and analyze the project context:
   - Project type (web-api, web-app, cli, library)
   - Languages detected
   - Frameworks in use
   - Security-relevant features

5. Write discovery results to `.claude/security/discovery.json`:
   ```json
   {
     "timestamp": "2025-12-16T...",
     "languages": ["typescript", "go"],
     "frameworks": ["express", "react"],
     "features": ["authentication", "file-upload", "api"],
     "projectType": "web-app",
     "sourceDirectories": ["src/", "api/"]
   }
   ```

6. **Display findings to user** - show what was detected

7. **Get user confirmation**:
   ```
   Use AskUserQuestion:
   - question: "I detected the following stack:\n\n**Languages**: [list]\n**Frameworks**: [list]\n**Features**: [list]\n\nIs this correct?"
   - header: "Discovery"
   - options:
     - Correct (Continue to planning)
     - Adjust (Let me add/remove features)
     - Regenerate (Re-scan the codebase)
   ```

8. If "Adjust" selected, use AskUserQuestion with multiSelect to let user modify feature list

9. Mark Phase 1 as completed

---

## Phase 2: Planning

**Goal**: Map features to auditors and get user approval

**Model**: haiku

**Actions**:
1. Mark Phase 2 as in_progress
2. Read `.claude/security/discovery.json`

3. **Map features to relevant auditors**:

   **v2.0 Consolidated Auditors** (18 → 6 auditors for better efficiency)

   | Detected Feature | Relevant Auditors |
   |------------------|-------------------|
   | authentication | auth-security-auditor |
   | oauth | auth-security-auditor |
   | sessions | auth-security-auditor |
   | authorization | auth-security-auditor |
   | api | web-security-auditor, injection-auditor |
   | database | injection-auditor |
   | frontend/web | web-security-auditor |
   | file-upload | data-security-auditor |
   | crypto/encryption | data-security-auditor |
   | logging | data-security-auditor |
   | tls/https | web-security-auditor |
   | webrtc | web-security-auditor |
   | config/secrets | config-auditor |
   | architecture | architecture-auditor |

   **Auditor Capabilities**:
   - `injection-auditor`: SQL, NoSQL, Command, Template, Deserialization (V1)
   - `auth-security-auditor`: Auth, AuthZ, Session, JWT, OAuth (V6-V10)
   - `data-security-auditor`: Crypto, Data Protection, Files, Logging (V5, V11, V14, V16)
   - `web-security-auditor`: XSS, CSP, Validation, API, TLS, WebRTC (V2-V4, V12, V17)
   - `config-auditor`: Configuration security (V9)
   - `architecture-auditor`: Architecture and design (V2 architecture)

4. **Only select auditors matching detected features** - Typical audit runs 3-5 auditors

5. Write plan to `.claude/security/plan.json`:
   ```json
   {
     "timestamp": "2025-12-16T...",
     "level": "L2",
     "selectedAuditors": [
       {"name": "injection-auditor", "reason": "API with database detected"},
       {"name": "auth-security-auditor", "reason": "Authentication feature detected"},
       {"name": "web-security-auditor", "reason": "Web frontend and API detected"}
     ],
     "excludedPaths": ["node_modules/", "vendor/"],
     "estimatedRequirements": 80
   }
   ```

6. **Present plan to user for approval**:
   ```
   Use AskUserQuestion:
   - question: "Here's the proposed audit plan:\n\n**Level**: L2 (Standard)\n**Auditors to run** (3 total):\n- injection-auditor: API with database detected\n- auth-security-auditor: Authentication feature detected\n- web-security-auditor: Web frontend and API detected\n\n**Estimated ASVS requirements**: ~80\n\nProceed with this plan?"
   - header: "Audit Plan"
   - options:
     - Proceed (Run these auditors)
     - Customize (Let me select which to run)
     - Quick scan (L1 only, faster)
     - Full scan (All applicable auditors, L1+L2+L3)
   ```

7. If "Customize" selected:
   ```
   Use AskUserQuestion:
   - question: "Select which auditors to run:"
   - header: "Auditors"
   - multiSelect: true
   - options:
     - [List only relevant auditors with descriptions]
   ```

8. Mark Phase 2 as completed

---

## Phase 3: Execution

**Goal**: Run selected auditors and show progress

**Model**: sonnet

**Actions**:
1. Mark Phase 3 as in_progress
2. Read `.claude/security/plan.json`
3. Create `.claude/security/findings/` directory

4. **Update todos with each auditor as a task**:
   ```
   - [x] Phase 1: Discovery
   - [x] Phase 2: Planning
   - [~] Phase 3: Execution
     - [ ] injection-auditor
     - [ ] auth-security-auditor
     - [ ] web-security-auditor
   - [ ] Phase 4: Review
   - [ ] Phase 5: Report
   ```

5. **Launch auditors in batches** using Task tool:
   - Launch 2-3 auditors in parallel (use `run_in_background: true`)
   - Each super-auditor uses mode detection to focus on relevant areas
   - Provide context: project type, languages, relevant directories

6. **Poll for progress** using TaskOutput:
   - Check status periodically with `block: false`
   - Display progress updates:
     ```
     ⏳ injection-auditor: running...
     ✓ auth-security-auditor: 5 findings
     ⏳ web-security-auditor: running...
     ```

7. **As each completes**, save findings to `.claude/security/findings/{auditor}.json`:
   ```json
   {
     "auditor": "injection-auditor",
     "timestamp": "2025-12-16T...",
     "findings": [
       {
         "id": "ENC-001",
         "severity": "high",
         "title": "SQL injection vulnerability",
         "description": "...",
         "file": "src/api/users.ts",
         "line": 45,
         "asvs": "V1.2.1",
         "recommendation": "..."
       }
     ],
     "summary": {
       "total": 3,
       "critical": 0,
       "high": 1,
       "medium": 2,
       "low": 0
     }
   }
   ```

8. Mark each auditor todo as completed when done
9. When all complete, show summary and mark Phase 3 as completed

---

## Phase 4: Review

**Goal**: Let user review and select findings for report

**Model**: sonnet

**Actions**:
1. Mark Phase 4 as in_progress
2. Read all findings from `.claude/security/findings/*.json`

3. **Aggregate and sort by severity**:
   - Group findings: Critical → High → Medium → Low → Info
   - Deduplicate: same file + same line + similar issue = duplicate
   - Keep most severe classification for duplicates

4. **Display findings grouped by severity** with context:
   ```
   ## Critical Findings (2)

   ### CRIT-001: SQL Injection in user API
   - File: src/api/users.ts:45
   - ASVS: V1.2.1
   - Code: `db.query("SELECT * FROM users WHERE id = " + userId)`

   ### CRIT-002: ...

   ## High Findings (5)
   ...
   ```

5. **For each severity level, ask user what to include**:
   ```
   Use AskUserQuestion:
   - question: "Found 2 Critical findings. Include in report?"
   - header: "Critical"
   - multiSelect: true
   - options:
     - CRIT-001: SQL Injection in user API
     - CRIT-002: Auth bypass in admin route
   ```

   Repeat for High, Medium (combine Low/Info or skip if many)

6. **Allow marking false positives**:
   ```
   Use AskUserQuestion:
   - question: "Mark any as false positives?"
   - header: "False Positives"
   - options:
     - No false positives (Continue)
     - Mark some (Let me select which are false positives)
   ```

7. Write reviewed findings to `.claude/security/reviewed-findings.json`:
   ```json
   {
     "timestamp": "2025-12-16T...",
     "included": [...],
     "excluded": [...],
     "falsePositives": [...],
     "summary": {
       "total": 15,
       "included": 12,
       "excluded": 2,
       "falsePositives": 1
     }
   }
   ```

8. Mark Phase 4 as completed

---

## Phase 5: Report

**Goal**: Generate final audit report

**Model**: sonnet

**Actions**:
1. Mark Phase 5 as in_progress
2. Read `.claude/security/reviewed-findings.json`

3. **Generate markdown report** using `Skill: audit-report`:
   ```markdown
   # Security Audit Report

   **Project**: [name]
   **Date**: [date]
   **Scope**: [audit type and chapters]
   **Auditors Run**: [list]

   ## Executive Summary

   - **Total Findings**: [count]
   - **Critical**: [count]
   - **High**: [count]
   - **Medium**: [count]
   - **Low**: [count]

   ### Risk Assessment
   [Overall risk level and key concerns]

   ## Findings

   ### Critical Findings
   [Detailed findings with ASVS mapping]

   ### High Findings
   [...]

   ## Recommendations

   ### Immediate Actions
   1. [Most urgent fixes]

   ### Short-term Improvements
   1. [Important but not urgent]

   ## Appendix

   ### ASVS Coverage
   [Requirements checked vs total]

   ### Methodology
   [Audit approach and limitations]
   ```

4. Write report to `.claude/security/audit-{timestamp}.md`

5. **Generate machine-readable JSON** to `.claude/security/audit-{timestamp}.json`

6. **Display summary in conversation**:
   ```
   ## Security Audit Complete

   **Findings**: 15 total (2 critical, 5 high)

   ### Top Issues
   1. [Critical] SQL injection in /api/users - V1.2.1
   2. [Critical] Auth bypass in /admin - V6.2.1
   3. [High] Missing CSRF protection - V3.5.1

   **Full report**: .claude/security/audit-2025-12-16.md
   ```

7. **Offer next steps**:
   ```
   Use AskUserQuestion:
   - question: "How would you like to proceed?"
   - header: "Next Steps"
   - options:
     - View full report (Open the detailed findings)
     - Fix critical issues (Start remediation)
     - Log as bugs (Track findings in /devloop:bugs)
     - Run another audit (Change scope and re-run)
     - Done (End audit session)
   ```

8. If "Log as bugs" selected, use `/devloop:bug` or bug-catcher agent for each finding

9. Mark Phase 5 as completed and all todos complete

---

## Artifact Structure

All audit artifacts are saved to `.claude/security/`:

```
.claude/security/
├── discovery.json          # Phase 1 output - detected tech stack
├── plan.json               # Phase 2 output - selected auditors
├── findings/               # Phase 3 output - raw auditor results
│   ├── injection-auditor.json
│   ├── auth-security-auditor.json
│   ├── web-security-auditor.json
│   ├── data-security-auditor.json (if applicable)
│   ├── config-auditor.json (if applicable)
│   └── architecture-auditor.json (if applicable)
├── reviewed-findings.json  # Phase 4 output - user-approved findings
├── audit-2025-12-16.md     # Phase 5 output - final report
└── audit-2025-12-16.json   # Phase 5 output - machine-readable
```

This structure allows:
- **Resumability**: Pick up where you left off
- **Transparency**: Inspect any phase's output
- **Reuse**: Re-run report without re-running auditors

---

## Model Selection Reference

| Phase | Model | Rationale |
|-------|-------|-----------|
| 0. Triage | haiku | Simple argument parsing |
| 1. Discovery | haiku | File detection is straightforward |
| 2. Planning | haiku | Mapping features to auditors |
| 3. Execution | sonnet | Domain auditors need deep analysis |
| 4. Review | sonnet | Context-aware deduplication |
| 5. Report | sonnet | Comprehensive report generation |

---

## Quick Reference: Arguments

```bash
/security:audit              # Interactive - full phased workflow
/security:audit quick        # Quick scan (L1 only, minimal interaction)
/security:audit standard     # Standard audit (L1 + L2)
/security:audit comprehensive # Full audit (all levels)
/security:audit auth         # Focus on authentication (V6, V7)
/security:audit api          # Focus on API security (V1, V2, V4)
/security:audit frontend     # Focus on frontend (V3)
/security:audit crypto       # Focus on cryptography (V11, V12)
```

---

## Error Handling

| Issue | Resolution |
|-------|------------|
| No source files found | Ask user for source directory |
| Auditor timeout | Note partial results, continue with others |
| Unknown framework | Fall back to generic checks, note in report |
| No findings | Celebrate! Verify scope wasn't too narrow |
| User abandons mid-audit | Artifacts allow resume later |

---

## See Also

- `/security` - Plugin overview and quick status
- `Skill: asvs-requirements` - ASVS 5.0 reference
- `Skill: project-context` - Tech stack detection
- `Skill: audit-report` - Report formatting
