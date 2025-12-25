# **Skill Module: Framework & Rendering**

## **Context**

This module defines the selection of UI frameworks and rendering strategies based on application needs.

## **1\. Rendering Paradigms**

### **React Server Components (RSC)**

* **Role:** The default for dynamic, data-heavy applications (Dashboards, SaaS cores).  
* **Mechanism:** Components execute on the server, streaming serialized HTML/Data to the client.  
* **Benefit:** Zero bundle size for server-only logic; secure access to DB/Microservices directly in UI code.  
* **Constraint:** Requires "Dual Mental Model" (Server vs. Client boundaries).

### **Islands Architecture**

* **Role:** The default for content-heavy sites (Marketing, Docs, Blogs).  
* **Mechanism:** Static HTML by default; hydrates only interactive widgets.  
* **Benefit:** Near-zero JavaScript payload; max SEO performance.  
* **Framework:** Astro.

## **2\. Framework Selection**

### **Next.js 15+ (The Enterprise Standard)**

* **Philosophy:** Server-centric, Infrastructure-aware.  
* **Use Case:** Enterprise apps requiring broad ecosystem support and "batteries-included" features (Auth, SaaS starters).  
* **Trade-off:** High complexity (Black Box); opinionated caching/routing; vendor affinity (Vercel).

### **TanStack Start (The Transparent Challenger)**

* **Philosophy:** Client-first, Standards-based.  
* **Use Case:** Highly interactive "app-like" dashboards; teams valuing Type Safety and transparency.  
* **Key Feature:** Best-in-class Type Safety for routes/loaders; treats server as an enhancement, not the primary driver.

### **SvelteKit / SolidStart (Performance Specialists)**

* **Use Case:** Performance-critical apps (e.g., trading terminals).  
* **SolidStart:** Highest raw performance (Signals).  
* **SvelteKit:** Smallest bundle size (Compiler-based).

## **Strategic Recommendation**

* **Hybrid Approach:** Use **Astro** for the public marketing site. Use **Next.js** or **TanStack Start** for the logged-in SaaS application.