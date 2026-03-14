# CWE-89: SQL Injection — Triage Criteria

## TRUE_POSITIVE when:
- User-controlled input is concatenated or interpolated into a SQL string
- f-strings, format(), %, or + used to build queries with external input
- Raw SQL (text(), raw(), execute()) with variable interpolation
- Input comes from HTTP request, CLI args, or file reads

## FALSE_POSITIVE when:
- Query uses parameterized placeholders (%s, ?, :param) with separate values
- ORM methods used (Django .filter(), SQLAlchemy model queries, GORM .Where with ?)
- Input is hardcoded/constant (no user-controlled data)
- Code is in test files using controlled test data
- The interpolated value is an integer from validated input (e.g., FastAPI path param typed as int)

## SEVERITY adjustment:
- CRITICAL: Public endpoint, no auth required, direct user input to query
- HIGH: Authenticated endpoint, user input to query
- MEDIUM: Internal/admin endpoint, or input partially validated
- LOW: Test file, example code, or CLI tool with trusted operator input
