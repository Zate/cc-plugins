# **Skill Module: The Golden Stack (2026 Reference)**

## **Context**

This is the prescriptive "Smart Simplicity" stack for a new SaaS project starting in 2026\.

## **The Stack Definition**

| Layer | Technology | Rationale |
| :---- | :---- | :---- |
| **Architecture** | **Modular Monolith** | Balance of velocity and structure. |
| **Repo Tooling** | **Nx** or **Turborepo** | Governance (Nx) or Speed (Turbo). |
| **Framework** | **Next.js** OR **TanStack Start** | Ecosystem Safety vs. Type Safety. |
| **Language** | **TypeScript (Strict)** | Non-negotiable for AI reasoning. |
| **Styling** | **Tailwind CSS v4** | Compile-time, zero-config. |
| **Components** | **shadcn/ui** | Headless, copy-paste ownership. |
| **Mutations** | **Server Actions** | Simplicity and colocation. |
| **Data Fetching** | **TanStack Query** | Caching and Optimistic UI. |
| **Database** | **Neon (Postgres)** | Branching workflow for CI/CD. |
| **ORM** | **Drizzle** | Type-safe SQL, lightweight. |
| **E2E Testing** | **Playwright** | Industry standard, AI-ready. |
| **Auth** | **Clerk / Auth0** | Passkey support, managed security. |

## **Implementation Priority**

1. **Initialize Monorepo:** Set up boundaries immediately.  
2. **Define .cursorrules:** Establish the "rules of engagement" for AI.  
3. **Deploy Database:** Connect Neon with branching enabled.  
4. **Scaffold UI:** Use v0.dev to generate shadcn/ui layouts.