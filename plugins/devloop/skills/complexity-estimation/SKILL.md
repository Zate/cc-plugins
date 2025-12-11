---
name: complexity-estimation
description: Framework for estimating task complexity using T-shirt sizing. Provides scoring criteria, risk factors, and guidance on when spikes/POCs are needed. Use at the start of features to set expectations.
---

# Complexity Estimation

Framework for estimating software task complexity and identifying risks.

## T-Shirt Size Reference

| Size | Score Range | Characteristics |
|------|-------------|-----------------|
| **XS** | 7-10 | Single file, clear pattern, <1 hour |
| **S** | 11-15 | Few files, existing patterns, half day |
| **M** | 16-22 | Multiple components, some new patterns, 1-2 days |
| **L** | 23-28 | Cross-cutting, new architecture, 3-5 days |
| **XL** | 29-35 | Major feature, significant unknowns, 1+ week |

## Scoring Factors

Rate each factor 1-5:

### 1. Files Touched
| Score | Files |
|-------|-------|
| 1 | 1-3 files |
| 2 | 4-6 files |
| 3 | 7-10 files |
| 4 | 11-15 files |
| 5 | 16+ files |

### 2. New Concepts
| Score | Description |
|-------|-------------|
| 1 | Uses existing patterns exactly |
| 2 | Minor adaptation of existing patterns |
| 3 | Combines patterns in new way |
| 4 | Introduces new pattern to codebase |
| 5 | New architecture required |

### 3. Integration Points
| Score | Description |
|-------|-------------|
| 1 | Self-contained, no integrations |
| 2 | Single integration point |
| 3 | 2-3 integration points |
| 4 | Multiple systems involved |
| 5 | Complex multi-system orchestration |

### 4. Data Changes
| Score | Description |
|-------|-------------|
| 1 | No data changes |
| 2 | New fields on existing models |
| 3 | New models, no migrations |
| 4 | Migrations required |
| 5 | Complex data transformation/migration |

### 5. Testing Complexity
| Score | Description |
|-------|-------------|
| 1 | Unit tests only |
| 2 | Unit + simple integration |
| 3 | Complex integration tests |
| 4 | E2E tests required |
| 5 | Multi-environment testing needed |

### 6. Regression Risk
| Score | Description |
|-------|-------------|
| 1 | Isolated, no risk |
| 2 | Low risk, good test coverage |
| 3 | Medium risk, shared code |
| 4 | High risk, core system |
| 5 | Critical path, high blast radius |

### 7. Uncertainty
| Score | Description |
|-------|-------------|
| 1 | Crystal clear requirements |
| 2 | Minor clarifications needed |
| 3 | Some ambiguity, decisions needed |
| 4 | Significant unknowns |
| 5 | Exploratory, many unknowns |

## Risk Categories

### Technical Risks
- New technology/framework not used before
- Performance requirements unclear
- Scalability concerns
- Platform/environment constraints

### Integration Risks
- External API dependencies
- Breaking change potential
- Version compatibility
- Data format mismatches

### Data Risks
- Migration complexity
- Data integrity concerns
- Backup/recovery requirements
- Consistency requirements

### Timeline Risks
- Dependencies on other teams
- External blockers
- Resource availability
- Learning curve

### Security Risks
- Authentication/authorization changes
- Data exposure potential
- Input validation needs
- Compliance requirements

## Spike Indicators

Recommend a spike/POC when:

1. **Total score ≥ 25** (L or XL)
2. **Any single factor = 5**
3. **Uncertainty factor ≥ 4**
4. **New technology** not in codebase
5. **Performance critical** without benchmarks
6. **Multiple integration points** with unknowns

## Spike Outcomes

A spike should answer:
- Is this technically feasible?
- What's the actual complexity?
- What are the blockers?
- What approach should we take?

Spike deliverables:
- Working proof of concept
- Technical decision document
- Revised complexity estimate
- Implementation recommendations

## Common Estimation Mistakes

### Under-estimation
- Forgetting tests
- Missing edge cases
- Ignoring code review time
- Not accounting for learning curve
- Assuming happy path only

### Over-estimation
- Padding for uncertainty
- Not recognizing existing patterns
- Treating simple as complex
- Fear of unfamiliar technology

## Estimation Tips

1. **Break down first** - Estimate components, sum up
2. **Compare to past** - What similar thing took how long?
3. **Ask clarifying questions** - Remove uncertainty
4. **Identify the unknown** - Spike if needed
5. **Include everything** - Tests, docs, review
6. **Be honest** - Don't pad, don't minimize

## See Also

- `Skill: workflow-selection` - Choose right workflow
- `Skill: architecture-patterns` - For complex designs
- `Skill: testing-strategies` - Test complexity estimation
