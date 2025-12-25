# **Skill Module: Data & State Management**

## **Context**

This module defines data flow patterns, mutation strategies, and client-side reactivity.

## **1\. Data Fetching & Mutation**

### **Server Actions (Next.js Default)**

* **Mechanism:** RPC-style functions executed on server, called from client.  
* **Pros:** Progressive enhancement (works without JS); Code collocation.  
* **Cons:** Potential waterfall requests if unmanaged.

### **tRPC (Type-Safety Standard)**

* **Mechanism:** Shared types between client/server; API treated as typed function calls.  
* **Pros:** Absolute end-to-end type safety; build fails if contract breaks.  
* **Recommendation:** Use for complex, data-heavy enterprise apps.

## **2\. State Management**

* **Global Stores (Redux):** Legacy. Do not use.  
* **Server State:** Managed by **TanStack Query** (or SWR). Handles caching, deduping, revalidation.  
* **Client State:**  
  * **Signals:** The new standard for fine-grained reactivity (SolidJS, Preact, React Compiler). Updates DOM directly without VDOM diffing.  
  * **Zustand:** Preferred for simple global client stores (e.g., UI preferences).

## **3\. User Experience Patterns**

* **Optimistic Updates:** Mandatory for "Instant App" feel.  
  * **Flow:** UI updates immediately on user action \-\> Request sent in background \-\> Rollback if fail.  
  * **Tooling:** useOptimistic (Next.js) or TanStack Query.