# Agentic Identity Foundations

## What This Is

![Scale Model Analogy](architecture/scale-model-analogy.svg)

This is a **scale model**.

When a city plans to redesign its marina, there are two things that get built before any engineering blueprints are drawn. First, an artist's rendering — beautiful, aspirational, but not grounded in structural reality. Second, a scale model — detailed, proportional, sitting in the project office where every team can gather around it, point at pieces, and say *"this is how the boardwalk connects to the breakwater"* or *"this is where the fuel dock needs to go relative to the channel."*

Neither is an engineering blueprint. Neither is a construction schedule. But the scale model is what gives every team — from the structural engineers to the electricians to the marina operators — a shared, tangible understanding of what they're building and how their piece fits into the whole.

**This project is that scale model for AI agent identity at a large SaaS company.**

It's a functional, end-to-end demonstration of how AI agents should be created, registered, authenticated, authorized, and observed — across trust domains in a multi-tenant SaaS ecosystem. Every service runs. Every token is real. Every policy evaluates. You can invoke an agent, watch the OBO token exchange happen, see the authorization decision, and read the audit trail.

### Why a scale model matters

Think about building a space station. Its job is to orbit, hold air, and provide a safe place for people to do extraordinary work. But if the teams building it aren't aligned on how it's supposed to look — and more importantly, if they're not using compatible materials, the same measurement systems, the same docking interfaces — then even if they manage to assemble something that *looks* like the artist's impression, it won't do its basic job. It won't hold air.

Scale models exist so that:

- **Engineers deep in one subsystem** can still see how their piece connects to the whole
- **Decision-makers** can evaluate trade-offs with a concrete, shared reference point
- **Teams working independently** build toward the same vision with compatible interfaces
- **The vision can evolve** — the final product may look different from the model, and that's fine, as long as the evolution is shared and understood

This demo is not production code. It will not be deployed. But it is the thing we sit around together, point at, and use to make the detailed architectures, designs, and execution plans that *will* build the real thing.

![The Demo Platform](architecture/architecture-overview.svg)

---

## Contents

- [Start Here](#start-here) — find your path based on your role
- [Architecture](#architecture) — the 5-document journey from vision to implementation
- [Customer 0](#customer-0) — the first concrete demo (a corporate security team)
- [Reference](#reference) — glossary, RFC compliance, phases, stakeholders

---

## Start Here

| Document | Purpose |
|----------|---------|
| [Architecture Overview](architecture/INDEX.md) | **New to this project / Executive** — visual tour, then [Gap Analysis](customer0/GAP-ANALYSIS.md) for status |
| [Blueprint](architecture/BLUEPRINT.md) | **Product manager** — the vision and core argument, then [Customer 0 PRD](customer0/CUSTOMER0-PRD.md) |
| [Data Model](architecture/DATA-MODEL.md) | **Engineer** — implementation details, then [Phases](reference/PHASES.md) for deliverables |
| [RFC Compliance](reference/RFC-COMPLIANCE.md) | **Compliance** — IETF mapping, then Blueprint for context on deviations |
| [Glossary](reference/GLOSSARY.md) | **Looking up a term** — terminology reference |

---

## Architecture

**Start here →** [Architecture Overview](architecture/INDEX.md) — a visual, diagram-first tour (~10 min)

Then read the five documents in order. Each builds on the one before it:

| Document | Purpose |
|----------|---------|
| [Architectural Blueprint](architecture/BLUEPRINT.md) | The problem, the solution, and the complete architecture |
| [Identity Model](architecture/IDENTITY-MODEL.md) | The primitives — Principal, Subject, Actor, Account, and how agents map onto the same framework as humans |
| [Federation Lifecycle](architecture/FEDERATION-LIFECYCLE.md) | The journey — how a principal evolves across trust boundaries, trust chains, validation, revocation |
| [Tokens & Audit](architecture/TOKEN-ANATOMY.md) | The tokens — three token types, OBO claim anatomy, and the audit trail structure |
| [Data Model & APIs](architecture/DATA-MODEL.md) | The implementation — SPIFFE IDs, token formats, JWT claims, API contracts, audit events |

---

## Customer 0

The first concrete implementation — a corporate security team governing AI agents accessing sensitive financial data.

| Document | Purpose |
|----------|---------|
| [Overview](customer0/README.md) | What Customer 0 demonstrates and why |
| [Architecture](customer0/ARCHITECTURE.md) | System design, service layout, OBO flow |
| [PRD](customer0/CUSTOMER0-PRD.md) | Product requirements |
| [Demo Script](customer0/DEMO-SCRIPT.md) | Step-by-step walkthrough |
| [Gap Analysis](customer0/GAP-ANALYSIS.md) | Requirements coverage matrix |
| [Implementation Plan](customer0/IMPLEMENTATION-PLAN.md) | Build sequence and milestones |

---

## Reference

| Document | Purpose |
|----------|---------|
| [Glossary](reference/GLOSSARY.md) | Terminology — WIMSE, SPIFFE, AIMS, RFC terms, agent types |
| [RFC Compliance](reference/RFC-COMPLIANCE.md) | Section-by-section mapping to `draft-klrc-aiagent-auth-00` |
| [Implementation Phases](reference/PHASES.md) | 5-phase build roadmap with milestones |
| [Users & Stakeholders](reference/USERS.md) | Audience-specific paths, test credentials |
