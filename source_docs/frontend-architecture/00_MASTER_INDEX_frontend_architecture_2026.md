# **Master Index: Modern Frontend SaaS Architecture (2025-2026)**

## **Purpose**

This document serves as the root node for the "Modern Frontend SaaS Architect" skill set. It outlines the core philosophy of "Smart Simplicity" and provides a routing table to specialized sub-documents.

## **Core Philosophy: Smart Simplicity**

The architectural meta for 2025/2026 has shifted from fragmentation (Micro-frontends) to consolidation (Modular Monoliths).

* **Primary Goal:** Build systems that are resilient, performant by default, and structurally optimized for AI collaboration (Agentic Engineering).  
* **Key Constraint:** Minimize "Understanding Drift"—ensuring the system remains comprehensible despite the high volume of AI-generated code.  
* **Default Stance:** Type-safety, portability, and "batteries-included" governance over bespoke configuration.

## **Knowledge Graph (Sub-Documents)**

### [**01\_strategic\_architecture.md**](./01_strategic_architecture.md)

Topic: High-level system design and decision matrices.  
Load this when: determining the project structure (Monolith vs. Micro-frontend) or establishing repository governance rules.  
Key Concepts: Modular Monoliths, Nx/Turborepo, Agentic Codebase Structure.

### [**02\_framework\_rendering.md**](./02_framework_rendering.md)

Topic: Rendering patterns and framework selection.  
Load this when: deciding between Next.js and TanStack Start, or choosing a rendering strategy (RSC vs. Islands) for a specific route.  
Key Concepts: React Server Components (RSC), Hybrid Rendering, Islands Architecture.

### [**03\_tooling\_infrastructure.md**](./03_tooling_infrastructure.md)

Topic: Build systems, databases, and edge infrastructure.  
Load this when: configuring CI/CD, selecting a database, or optimizing build times.  
Key Concepts: Rust-based tooling (Vite/Turbopack), Biome, Serverless Postgres (Neon), Edge Constraints.

### [**04\_component\_system.md**](./04_component_system.md)

Topic: UI composition, styling, and accessibility.  
Load this when: building the design system, creating new UI components, or writing CSS.  
Key Concepts: Headless UI (shadcn), Tailwind v4, Container Queries, Automated Accessibility.

### [**05\_data\_state.md**](./05_data_state.md)

Topic: Data fetching, mutations, and state management.  
Load this when: implementing API layers, handling form submissions, or managing client-side reactivity.  
Key Concepts: Server Actions, tRPC, Signals, Optimistic Updates.

### [**06\_agentic\_workflow\_qa.md**](./06_agentic_workflow_qa.md)

Topic: AI-integrated development workflows, testing, and security.  
Load this when: writing tests, configuring AI coding assistants, or auditing security.  
Key Concepts: Cursor IDE Rules, Playwright \+ MCP, Supply Chain Security, INP Metrics.

### [**07\_golden\_stack\_reference.md**](./07_golden_stack_reference.md)

Topic: The definitive "Golden Stack" recommendation for 2026\.  
Load this when: you need a specific, opinionated list of technologies to initialize a new project.  
Key Concepts: The "Smart Simplicity" Stack definition.