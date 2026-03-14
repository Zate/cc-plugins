# CWE-22: Path Traversal — Triage Criteria

## TRUE_POSITIVE when:
- User-controlled input used in file path construction (open(), readFile(), os.Open())
- No path canonicalization or directory boundary check
- Path components from HTTP params, query strings, or form data
- File upload with user-controlled filename without sanitization

## FALSE_POSITIVE when:
- Path is constructed from constants/config only
- os.path.join + os.path.realpath + startswith check (proper canonicalization)
- Path.resolve() + is_relative_to() check in Python
- Framework handles path safely (static file serving with restricted root)
- Input is validated against an allowlist of filenames

## SEVERITY adjustment:
- CRITICAL: Can read arbitrary files (e.g., /etc/passwd, .env)
- HIGH: Can read files outside intended directory
- MEDIUM: Limited traversal (e.g., within uploads/ directory)
- LOW: Read-only, restricted file types
