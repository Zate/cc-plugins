# **Skill Module: Component Design & Styling**

## **Context**

This module defines how UI is constructed, styled, and made accessible.

## **1\. Component Philosophy**

* **Pattern:** "Copy-Paste" Distribution (Headless UI).  
* **Library:** **shadcn/ui**.  
* **Why:** Developers own the code (it lives in the repo, not node\_modules). Eliminates fighting against library overrides.  
* **Agentic Synergy:** AI agents can easily read and modify local component files, unlike compiled external libraries.

## **2\. Styling Engine**

* **Standard:** **Tailwind CSS v4**.  
* **Configuration:** Zero-config detection engine.  
* **Architecture:** Compile-time (compatible with RSC).  
* **Legacy:** Avoid runtime CSS-in-JS (styled-components, Emotion) due to performance cost and RSC incompatibility.

## **3\. Responsive Design**

* **New Standard:** **Container Queries** (@container).  
* **Shift:** Style components based on their *parent size*, not the *browser viewport*.  
* **Benefit:** True modularity; components work in Sidebar, Main, or Modal without code changes.

## **4\. Accessibility (A11y)**

* **Baseline:** WCAG compliance is mandatory (legal \+ AI readability).  
* **Tooling:**  
  * **Radix UI / React Aria:** Handle keyboard nav/focus management invisibly.  
  * **Automated Testing:** Axe, BrowserStack Accessibility.  
  * **Agentic Testing:** Use AI to simulate screen reader navigation flows.