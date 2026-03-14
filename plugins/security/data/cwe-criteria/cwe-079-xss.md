# CWE-79: Cross-Site Scripting (XSS) — Triage Criteria

## TRUE_POSITIVE when:
- User input is inserted into HTML without encoding/escaping
- innerHTML, outerHTML, document.write() with user data
- dangerouslySetInnerHTML with unsanitized input
- Server-side template rendering with |safe, {% autoescape off %}, or raw output
- Response headers set from user input (header injection)

## FALSE_POSITIVE when:
- Framework auto-escapes (React JSX, Angular templates, Django templates without |safe)
- Output is sanitized (DOMPurify, bleach.clean, escape())
- Content is not rendered in HTML context (JSON API response, file download)
- Input is from a trusted source (admin-only, config)
- The application is a pure API with no HTML rendering

## SEVERITY adjustment:
- HIGH: Stored XSS (user input saved and rendered to other users)
- HIGH: Reflected XSS in public-facing pages
- MEDIUM: DOM-based XSS requiring specific user interaction
- LOW: XSS in admin-only interface
- LOW: Self-XSS only (user can only attack themselves)
