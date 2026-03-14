# CWE-78: OS Command Injection — Triage Criteria

## TRUE_POSITIVE when:
- User input reaches os.system(), subprocess with shell=True, exec(), eval()
- String interpolation/concatenation builds shell commands with external data
- Backtick execution with user-controlled content
- child_process.exec() with user input in Node.js

## FALSE_POSITIVE when:
- Command arguments are hardcoded constants (e.g., subprocess.run(["git", "status"]))
- Input is from a strictly controlled allowlist
- subprocess.run() uses a list (not string) with shell=False (default)
- Code is a CLI tool where the operator IS the user (intentional)
- The executed command has no user-controlled components

## SEVERITY adjustment:
- CRITICAL: Web-facing endpoint, user input to shell command
- HIGH: Authenticated endpoint, user input to shell command
- MEDIUM: Internal service, limited input to shell command
- LOW: CLI tool (operator-controlled), build scripts, deployment scripts
