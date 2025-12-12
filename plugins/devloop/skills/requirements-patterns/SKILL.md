---
name: requirements-patterns
description: Patterns for gathering, documenting, and validating software requirements. Includes user story formats, acceptance criteria templates, and scope management. Use during requirements gathering phase.
---

# Requirements Patterns

Patterns and templates for effective requirements gathering and documentation.

## When NOT to Use This Skill

- **Clear requirements**: User already provided detailed specs - just implement
- **Bug fixes**: The bug report IS the requirement
- **Refactoring**: Technical improvements don't need user stories
- **Spike/exploration**: Discovery work, not requirements gathering
- **Trivial features**: Over-documenting simple changes wastes time

## User Story Format

### Standard Format
```
As a [user type]
I want to [action]
So that [benefit]
```

### Enhanced Format (INVEST)
```
As a [specific user persona]
I want to [specific action with context]
So that [measurable business benefit]

Acceptance Criteria:
- Given [context], when [action], then [outcome]
```

## INVEST Criteria

Good user stories are:

| Criteria | Description | Check |
|----------|-------------|-------|
| **I**ndependent | Can be developed separately | No dependencies on incomplete work |
| **N**egotiable | Details can be discussed | Not over-specified |
| **V**aluable | Delivers user value | Clear benefit stated |
| **E**stimable | Can estimate effort | Enough detail to size |
| **S**mall | Fits in a sprint | Can complete in days, not weeks |
| **T**estable | Can verify completion | Has acceptance criteria |

## Acceptance Criteria Patterns

### Given-When-Then (Gherkin)
```
Given [precondition/context]
When [action/trigger]
Then [expected outcome]
```

### Checklist Format
```
Acceptance Criteria:
- [ ] User can [action]
- [ ] System validates [condition]
- [ ] Error displays when [failure case]
- [ ] Data is [stored/transformed] correctly
```

### Scenario-Based
```
Scenario: [Name]
  - Setup: [Initial state]
  - Action: [What user does]
  - Result: [What should happen]
  - Verification: [How to confirm]
```

## Requirements Categories

### Functional Requirements
What the system should do:
- Features and capabilities
- Business rules
- User interactions
- Data processing

### Non-Functional Requirements (NFRs)

| Category | Questions to Ask |
|----------|-----------------|
| **Performance** | Response time? Throughput? |
| **Scalability** | Users? Data volume? Growth? |
| **Security** | Auth? Data protection? Compliance? |
| **Reliability** | Uptime? Recovery? |
| **Usability** | Accessibility? UX standards? |
| **Maintainability** | Documentation? Code standards? |

## Scope Management

### In-Scope Definition
Explicitly list:
- Features included
- User types covered
- Platforms supported
- Integration points

### Out-of-Scope Definition
Explicitly exclude:
- Future enhancements
- Adjacent features
- Edge cases deferred
- Platforms not supported

### Scope Creep Prevention
1. Document scope boundaries clearly
2. Require change request for additions
3. Evaluate impact of every change
4. Say no to "while you're at it"
5. Track scope changes visibly

## Requirements Gathering Questions

### Understanding the Problem
- What problem are we solving?
- Who has this problem?
- How do they solve it today?
- What happens if we don't solve it?

### Understanding the Solution
- What does success look like?
- How will users interact with this?
- What data is involved?
- What systems are affected?

### Understanding Constraints
- What's the timeline?
- What resources are available?
- What technical constraints exist?
- What compliance requirements apply?

### Understanding Priority
- Is this blocking other work?
- What's the business impact?
- What's the cost of delay?
- Is there a deadline?

## Edge Cases Checklist

### Data Edge Cases
- [ ] Empty/null values
- [ ] Maximum length/size
- [ ] Invalid formats
- [ ] Special characters
- [ ] Unicode/emoji
- [ ] Duplicate entries

### User Edge Cases
- [ ] First-time user
- [ ] Power user
- [ ] Concurrent users
- [ ] User cancels mid-action
- [ ] User loses connection
- [ ] User on slow connection

### System Edge Cases
- [ ] Service unavailable
- [ ] Timeout scenarios
- [ ] Partial failures
- [ ] Rate limiting
- [ ] Resource exhaustion

## Definition of Done Template

Feature is complete when:
- [ ] All acceptance criteria pass
- [ ] Unit tests written and passing
- [ ] Integration tests passing
- [ ] Code review approved
- [ ] Documentation updated
- [ ] No critical/high bugs
- [ ] Security review (if applicable)
- [ ] Performance benchmarked (if applicable)

## Common Patterns

### CRUD Requirements
```
Create: User can create [entity] with [fields]
Read: User can view [entity] with [filters/search]
Update: User can edit [fields] on [entity]
Delete: User can remove [entity] with [confirmation]
```

### Workflow Requirements
```
State: [Entity] can be in states [A, B, C]
Transition: [Entity] moves from [A] to [B] when [trigger]
Validation: Transition requires [conditions]
Notification: [Users] notified on [transitions]
```

### Integration Requirements
```
Trigger: [Event] initiates integration
Data: [Fields] sent to [system]
Response: [Expected response] handled as [action]
Error: [Error cases] handled by [fallback]
Timing: Integration occurs [sync/async] within [SLA]
```

## Anti-Patterns to Avoid

### Vague Requirements
❌ "The system should be fast"
✅ "Page load time < 2 seconds on 3G connection"

### Solution as Requirement
❌ "Use Redis for caching"
✅ "Response time < 100ms for repeated queries"

### Missing Context
❌ "Add export feature"
✅ "As an analyst, I want to export reports to CSV so I can analyze in Excel"

### Assumed Knowledge
❌ "Handle the edge cases"
✅ "When X is empty, display message Y"

## See Also

- `Skill: complexity-estimation` - Estimate from requirements
- `Skill: testing-strategies` - Test from requirements
- `Skill: api-design` - API requirements patterns
