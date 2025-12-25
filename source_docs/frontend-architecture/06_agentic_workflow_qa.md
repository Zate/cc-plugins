# **Skill Module: Agentic Workflow & QA**

## **Context**

This module outlines the operational workflow for AI-augmented engineering and quality assurance.

## **1\. The Agentic Workflow**

* **Tools:** **Cursor** (IDE), **v0.dev** (UI Scaffolding).  
* **Method:** "Vibe Coding" / Orchestration.  
  * Human: Defines Spec/PRD \-\> Orchestrates \-\> Reviews.  
  * AI: Scaffolds \-\> Implements \-\> Refactors.  
* **Configuration:** .cursorrules is critical. It must explicitly define:  
  * Tech stack (e.g., "Use Shadcn/UI").  
  * Patterns (e.g., "Prefer Zod for validation").  
  * Formatting rules.

## **2\. Testing Strategy**

* **Primary Tool:** **Playwright**.  
* **Integration:** **MCP (Model Context Protocol)**.  
  * Allows AI to "see" the browser and generate/repair tests.  
* **Self-Healing:** AI agents automatically fix tests when selectors change.  
* **Principle:** "If AI writes the code, Human/System must write the test."

## **3\. Performance Metrics**

* **Primary Metric:** **INP (Interaction to Next Paint)**. Replaces FID.  
* **Goal:** Responsiveness to clicks/keys.  
* **Optimization:** Yield to main thread (scheduler.yield), use Web Workers, React Concurrent features.

## **4\. Security**

* **Supply Chain:** Use **Socket.dev** to detect malicious packages (behavioral analysis, not just CVEs).  
* **Auth:** **Passkeys** (WebAuthn) and **OIDC**. Passwordless by default.  
* **CSP:** Strict Content Security Policy using **Nonces** for streaming SSR compatibility.