# **Skill Module: Strategic Architecture**

## **Context**

This module guides high-level architectural decisions for SaaS platforms in the 2025/2026 cycle.

## **1\. The Modular Monolith (Standard)**

* **Definition:** A single repository where code is organized into strictly defined, encapsulated modules (e.g., "Marketing," "Dashboard," "Shared UI").  
* **Why:** Solves "dependency hell" and reduces operational overhead compared to Micro-frontends.  
* **Tooling:** Must use a Monorepo tool to enforce boundaries.  
  * **Nx:** Preferred for governance. Can enforce rules like "Feature libraries cannot import other Feature libraries."  
  * **Turborepo:** Preferred for raw speed and simplicity in smaller teams.  
* **Agentic Benefit:** AI agents reason better over a "Unified Graph" where all context is available in one place, rather than scattered across repo boundaries.

## **2\. Micro-Frontends (Anti-Pattern)**

* **Status:** Deprecated for 95% of use cases.  
* **Risks:** High operational complexity, redundant library loading (degrading Core Web Vitals), and fragile type safety.  
* **Exception Criteria:** Only valid for organizations with 100+ frontend engineers where deployment coordination is the primary bottleneck.

## **3\. Agentic Architecture**

* **Principle:** Codebases must be "AI-Readable."  
* **Requirement A (Explicitness):** Prioritize explicit logic over "magic" abstractions. Typed code guides agent reasoning.  
* **Requirement B (Context Anchors):** Maintain .cursorrules and comprehensive documentation files. These serve as the "long-term memory" for AI agents.  
* **Requirement C (Drift Mitigation):** The architecture must support rigorous automated testing to counter "Understanding Drift" (where AI output exceeds human comprehension).

## **Decision Matrix**

| Pattern | Ideal Team Size | Performance Risk | 2026 Verdict |
| :---- | :---- | :---- | :---- |
| **Modular Monolith** | 5 \- 100 | Low | **Standard** |
| **Micro-frontends** | 100+ | High (LCP/INP) | Specialized Only |
| **Islands** | Content Teams | Minimal | Best for Content Sites |

