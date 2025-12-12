# Devloop Commands Reference

Complete documentation for all 9 slash commands in the devloop plugin.

---

## Quick Reference

| Command | Purpose | Arguments |
|---------|---------|-----------|
| `/devloop` | Full 12-phase feature workflow | Feature description |
| `/devloop:continue` | Resume from existing plan | Optional step number |
| `/devloop:quick` | Fast implementation for small tasks | Task description |
| `/devloop:spike` | Technical exploration/POC | What to explore |
| `/devloop:review` | Comprehensive code review | Optional file/PR |
| `/devloop:ship` | Git commit and PR creation | Optional message |
| `/devloop:bug` | Report a bug for tracking | Optional description |
| `/devloop:bugs` | View and manage tracked bugs | Optional filter/ID |
| `/devloop:statusline` | Configure status bar display | None |

---

## Workflow Commands

### /devloop

**Full feature development workflow with 12 phases.**

```bash
/devloop Add user authentication with OAuth
/devloop Implement rate limiting for API endpoints
/devloop Add dark mode support
```

**Arguments**: Feature description (required)

**What It Does**:
1. **Phase 0 - Triage**: Classifies task type
2. **Phase 1 - Discovery**: Gathers requirements
3. **Phase 2 - Complexity**: Estimates effort, recommends spike if needed
4. **Phase 3 - Exploration**: Deep codebase analysis
5. **Phase 4 - Clarification**: Resolves ambiguities
6. **Phase 5 - Architecture**: Designs implementation approach
7. **Phase 6 - Planning**: Creates task breakdown
8. **Phase 7 - Implementation**: Builds the feature
9. **Phase 8 - Testing**: Generates and runs tests
10. **Phase 9 - Review**: Code quality and security review
11. **Phase 10 - Validation**: Definition of Done check
12. **Phase 11 - Git**: Commits and PR creation
13. **Phase 12 - Summary**: Documents completion

**When to Use**:
- New features requiring architectural decisions
- Complex changes touching multiple systems
- Features that need requirements clarification
- Work that benefits from structured approach

**When NOT to Use**:
- Simple bug fixes → use `/devloop:quick`
- Unknown feasibility → use `/devloop:spike`
- Just need code review → use `/devloop:review`

**Output**: Saves plan to `.claude/devloop-plan.md`

---

### /devloop:continue

**Resume work from an existing plan.**

```bash
/devloop:continue                    # Resume next pending task
/devloop:continue step 3             # Jump to specific step
/devloop:continue implementation     # Resume at phase name
```

**Arguments**: Optional step number or phase name

**What It Does**:
1. Reads `.claude/devloop-plan.md`
2. Identifies current state and next task
3. Marks task as in-progress
4. Continues implementation
5. Updates plan progress

**When to Use**:
- Starting a new session on existing work
- After breaks or context switches
- When plan file exists from previous `/devloop`

**When NOT to Use**:
- No plan file exists
- Starting fresh work
- Plan is complete or outdated

**Output**: Picks up where you left off, updates plan file

---

### /devloop:quick

**Streamlined workflow for small, well-defined tasks.**

```bash
/devloop:quick Fix the typo in UserService
/devloop:quick Add logging to payment handler
/devloop:quick Update the config default value
```

**Arguments**: Task description (required)

**What It Does**:
1. **Understand** (2-3 min): Quick context gathering
2. **Implement** (5-15 min): Direct implementation
3. **Verify** (2-3 min): Run relevant tests
4. **Done** (1 min): Brief summary

**When to Use**:
- Bug fixes with known cause
- Small feature additions following existing patterns
- Configuration changes
- Documentation updates
- Test additions for existing code

**When NOT to Use**:
- New features with unclear requirements
- Changes touching multiple systems
- Performance-sensitive changes
- Security-related changes
- Anything needing architecture decisions

**Escalation**: If complexity is discovered, prompts to switch to full `/devloop`

---

### /devloop:spike

**Technical exploration for unknown feasibility.**

```bash
/devloop:spike Can we migrate from REST to GraphQL?
/devloop:spike Evaluate WebSocket vs SSE for real-time updates
/devloop:spike Prototype the new caching strategy
```

**Arguments**: What to explore (required)

**What It Does**:
1. **Define Goals**: Sets scope and success criteria
2. **Research**: Searches codebase and external resources
3. **Prototype**: Builds minimal proof of concept
4. **Evaluate**: Assesses findings with complexity estimator
5. **Report**: Documents conclusions and recommendations

**When to Use**:
- New technology or pattern not yet in codebase
- Uncertain feasibility or complexity
- Multiple viable approaches to evaluate
- Performance concerns to benchmark
- Integration with unknown external systems

**When NOT to Use**:
- Feasibility is clear
- Implementation approach is obvious
- Time-sensitive work that can't wait for exploration

**Output**: Spike report with feasibility assessment, recommended approach, and next steps

---

## Review & Quality Commands

### /devloop:review

**Comprehensive code review for existing changes.**

```bash
/devloop:review                      # Review recent changes
/devloop:review src/auth/            # Review specific directory
/devloop:review PR #123              # Review pull request
```

**Arguments**: Optional file path, directory, or PR number

**What It Does**:
1. Identifies scope (recent changes, specific files, or PR)
2. Launches parallel review agents:
   - Code quality and correctness
   - Security vulnerabilities
   - Project convention adherence
3. Consolidates findings by severity
4. Provides actionable fix suggestions

**Agents Used**: code-reviewer, security-scanner

**When to Use**:
- Before creating pull requests
- After significant code changes
- When inheriting unfamiliar code
- Periodic codebase health checks

**When NOT to Use**:
- During active development (wait until stable)
- For throwaway prototypes
- When immediate iteration is priority

**Output**: Review report with issues by severity and suggested fixes

---

### /devloop:ship

**Git integration for committing and creating PRs.**

```bash
/devloop:ship                        # Interactive commit flow
/devloop:ship "Add user auth"        # Commit with message
/devloop:ship --pr                   # Create pull request
```

**Arguments**: Optional commit message or PR title

**What It Does**:
1. Runs dod-validator to verify completion
2. If tests fail, offers to run test-runner
3. Stages appropriate files
4. Creates conventional commit message
5. Optionally creates pull request

**Agents Used**: dod-validator, test-runner, git-manager

**When to Use**:
- After DoD validation passes
- Ready to commit changes
- Creating pull requests
- Completing feature work

**When NOT to Use**:
- Work is incomplete
- Tests are failing
- Review issues are outstanding

**Safety Features**:
- Won't commit if tests fail (unless overridden)
- Validates DoD criteria first
- Creates conventional commit messages
- Never force pushes without explicit approval

---

## Bug Tracking Commands

### /devloop:bug

**Report a bug for later tracking.**

```bash
/devloop:bug                         # Interactive bug report
/devloop:bug The login button is misaligned on mobile
```

**Arguments**: Optional bug description

**What It Does**:
1. Gathers bug details (title, description, priority)
2. Identifies related files
3. Creates bug report in `.claude/bugs/BUG-NNN.md`
4. Updates bug index

**When to Use**:
- Non-critical issues found during development
- Issues that shouldn't block current work
- Tracking technical debt
- Logging flaky tests

**When NOT to Use**:
- Critical bugs (fix immediately)
- Production issues (use issue tracker)
- Issues being fixed in current session

**Output**: Bug report with ID, saved to `.claude/bugs/`

---

### /devloop:bugs

**View and manage tracked bugs.**

```bash
/devloop:bugs                        # List all open bugs
/devloop:bugs high                   # Filter by priority
/devloop:bugs BUG-003                # View specific bug
/devloop:bugs fix                    # Start fixing bugs
/devloop:bugs fix BUG-003            # Fix specific bug
/devloop:bugs close BUG-003          # Close a bug
```

**Arguments**: Optional filter, bug ID, or action

**Actions**:
- `(none)` - List open bugs
- `high/medium/low` - Filter by priority
- `BUG-NNN` - View specific bug details
- `fix` - Start fixing bugs (highest priority first)
- `fix BUG-NNN` - Fix specific bug
- `close BUG-NNN` - Mark bug as fixed/won't-fix

**When to Use**:
- Reviewing tracked issues
- Planning bug fix sessions
- Closing resolved bugs
- Prioritizing technical debt

---

## Configuration Commands

### /devloop:statusline

**Configure the Claude Code status bar with devloop information.**

```bash
/devloop:statusline
```

**Arguments**: None

**What It Does**:
1. Explains statusline feature
2. Presents configuration options
3. Updates user's Claude Code settings
4. Configures status bar to show:
   - Current model
   - Git branch
   - Plan progress
   - Open bug count

**When to Use**:
- Initial devloop setup
- Customizing status bar display
- After installing devloop plugin

**Output**: Configures `~/.claude/settings.json` with statusline command

---

## Command Comparison

### By Use Case

| Scenario | Command |
|----------|---------|
| New feature, complex | `/devloop` |
| Small fix, clear scope | `/devloop:quick` |
| Unknown if possible | `/devloop:spike` |
| Ready to commit | `/devloop:ship` |
| Reviewing code | `/devloop:review` |
| Continuing work | `/devloop:continue` |
| Track a bug | `/devloop:bug` |
| Manage bugs | `/devloop:bugs` |

### By Workflow Phase

| Phase | Primary Command |
|-------|-----------------|
| Starting new work | `/devloop` |
| Resuming work | `/devloop:continue` |
| Small tasks | `/devloop:quick` |
| Exploration | `/devloop:spike` |
| Pre-commit | `/devloop:review` |
| Shipping | `/devloop:ship` |

### By Time Investment

| Time | Command | Phases |
|------|---------|--------|
| 10-20 min | `/devloop:quick` | 4 simplified phases |
| 30-60 min | `/devloop:spike` | 5 exploration phases |
| 1-4 hours | `/devloop` | 12 complete phases |
| 15-30 min | `/devloop:review` | Review only |
| 5-10 min | `/devloop:ship` | Commit/PR only |

---

## Tips & Best Practices

### Starting Work
1. Check for existing plan: `ls .claude/devloop-plan.md`
2. If exists, use `/devloop:continue`
3. If not, choose appropriate workflow command

### During Development
- Use `/devloop:quick` for small tasks within larger features
- Log non-blocking issues with `/devloop:bug`
- Review periodically with `/devloop:review`

### Before Committing
1. Run `/devloop:review` for final check
2. Use `/devloop:ship` for clean commit flow
3. Don't skip DoD validation

### Bug Management
- Keep `.claude/bugs/` in `.gitignore` (local tracking)
- Or commit to share across team
- Periodically review with `/devloop:bugs`

---

## See Also

- [Agents Documentation](agents.md) - Agents invoked by commands
- [Skills Documentation](skills.md) - Skills consulted during workflows
- [Workflow Documentation](workflow.md) - Detailed phase descriptions
- [Configuration Documentation](configuration.md) - Setup and environment
