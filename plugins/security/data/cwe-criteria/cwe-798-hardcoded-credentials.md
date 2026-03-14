# CWE-798: Hardcoded Credentials — Triage Criteria

## TRUE_POSITIVE when:
- API keys, tokens, or passwords assigned as string literals in source code
- AWS access keys (AKIA prefix) in code
- Private keys (BEGIN PRIVATE KEY) embedded in source
- Connection strings with credentials (postgresql://user:pass@host)
- JWT secrets as string constants

## FALSE_POSITIVE when:
- Value is a placeholder ("changeme", "xxx", "your-api-key-here", empty string)
- Value is in a test file and is obviously fake (test123, password, abc123)
- Value is a hash (SHA256, bcrypt output), not a secret
- Value is a public key (not a private key)
- Value is in .env.example or .env.template (documentation, not real secrets)
- Value is loaded from environment variable at runtime

## SEVERITY adjustment:
- CRITICAL: Production API keys, database passwords, private keys
- HIGH: Service account credentials, webhook secrets
- MEDIUM: Development/staging credentials in config files
- LOW: Test fixtures, example values, documentation
