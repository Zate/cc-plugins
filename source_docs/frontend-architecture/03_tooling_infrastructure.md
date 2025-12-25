# **Skill Module: Tooling & Infrastructure**

## **Context**

This module covers the build chain, database layer, and physical infrastructure requirements.

## **1\. Build & Bundle**

* **Rust-Based Tooling:** The standard. Webpack is legacy.  
* **Vite:** The default bundler for flexibility (TanStack Start, SvelteKit, SPA). Instant dev server start.  
* **Turbopack:** The default for Next.js. Optimized for incremental builds in large monorepos.  
* **Rspack:** Drop-in Webpack replacement for legacy migration (Enterprise only).

## **2\. Linting & Formatting**

* **Biome:** The modern standard. Replaces ESLint \+ Prettier.  
* **Benefit:** Orders of magnitude faster (Rust); unified configuration eliminates conflicts.

## **3\. Database Strategy**

* **Serverless Postgres (Neon):** The default for relational data.  
  * **Killer Feature:** "Database Branching"—instantly clone production DB (schema+data) for every Pull Request.  
* **Edge SQL (Turso / Cloudflare D1):** Use for global apps requiring read replicas close to users.

## **4\. Edge Constraints**

* **Environment:** Edge runtimes (Cloudflare Workers, Vercel Edge) support limited Node.js APIs.  
* **Requirement:** All libraries (crypto, image processing) must be "Edge-aware" or "Isomorphic."  
* **Caching:** Use **Redis (Upstash)** for ephemeral state/caching at the edge.