---
name: deployment-readiness
description: Comprehensive deployment validation checklist and test design for production readiness. Use when validating features are ready for deployment or designing deployment tests.
---

# Deployment Readiness

Comprehensive checklist and guidance for validating production readiness.

## When NOT to Use This Skill

- **Local development**: Dev environments don't need full production checks
- **Spike/POC work**: Prototypes aren't meant for deployment
- **Draft PRs**: Work-in-progress doesn't need deployment validation
- **Partial features**: Behind feature flags - validate when flag is removed
- **Already deployed**: Use monitoring/observability, not this checklist

## Quick Checklist

### Code Quality
- [ ] All tests pass
- [ ] Build succeeds (no errors, no critical warnings)
- [ ] Linting passes
- [ ] No TODO/FIXME in production code
- [ ] No console.log/print debug statements
- [ ] No commented-out code blocks

### Documentation
- [ ] README.md updated (if public API changed)
- [ ] CHANGELOG.md updated
- [ ] API documentation current
- [ ] Configuration documented
- [ ] Migration guide (if breaking changes)

### Testing
- [ ] Unit test coverage meets threshold
- [ ] Integration tests pass
- [ ] E2E tests pass (if applicable)
- [ ] Smoke tests defined
- [ ] Performance tests pass (if applicable)

### Security
- [ ] No secrets/credentials in code
- [ ] No hardcoded API keys
- [ ] Dependencies scanned for vulnerabilities
- [ ] Input validation complete
- [ ] Authentication/authorization tested

### Infrastructure
- [ ] Migrations tested (if applicable)
- [ ] Environment variables documented
- [ ] Health check endpoints functional
- [ ] Rollback procedure documented
- [ ] Monitoring/alerting configured

## Validation by Project Type

### Frontend Projects

**Build Validation**:
```bash
npm run build
# Check for:
# - No TypeScript errors
# - No ESLint errors
# - Bundle size within limits
# - Assets optimized
```

**Additional Checks**:
- [ ] No console errors in browser
- [ ] Responsive design verified
- [ ] Accessibility basics (a11y)
- [ ] SEO meta tags (if applicable)
- [ ] Loading performance acceptable

### Backend Projects

**Build Validation**:
```bash
# Go
go build ./... && go test ./...

# Java
mvn clean package

# Python
pip install -e . && pytest
```

**Additional Checks**:
- [ ] API endpoints documented
- [ ] Database migrations reversible
- [ ] Rate limiting configured
- [ ] Error responses standardized
- [ ] Logging structured

### CLI Projects

**Validation**:
```bash
# Build and test
go build -o myapp ./cmd/myapp
./myapp --help
./myapp --version
```

**Additional Checks**:
- [ ] Help text complete and clear
- [ ] Exit codes appropriate (0 success, 1 error)
- [ ] Error messages actionable
- [ ] Configuration file documented

## Smoke Tests

### What is a Smoke Test?
Quick validation that core functionality works after deployment.

### Smoke Test Patterns

**API Smoke Test**:
```bash
#!/bin/bash
# smoke-test.sh

BASE_URL="${BASE_URL:-http://localhost:3000}"

# Health check
curl -f "$BASE_URL/health" || exit 1

# Auth endpoint
curl -f "$BASE_URL/api/auth/status" || exit 1

# Core functionality
curl -f "$BASE_URL/api/users" -H "Authorization: Bearer $TOKEN" || exit 1

echo "Smoke tests passed!"
```

**Frontend Smoke Test**:
```javascript
// smoke.test.js
describe('Smoke Tests', () => {
  it('loads the home page', () => {
    cy.visit('/');
    cy.contains('Welcome');
  });

  it('login flow works', () => {
    cy.visit('/login');
    cy.get('[data-testid="email"]').type('test@example.com');
    cy.get('[data-testid="password"]').type('password');
    cy.get('[data-testid="submit"]').click();
    cy.url().should('include', '/dashboard');
  });
});
```

## Health Checks

### Health Check Endpoint Pattern

```go
// Go
func healthHandler(w http.ResponseWriter, r *http.Request) {
    health := map[string]interface{}{
        "status": "healthy",
        "timestamp": time.Now().UTC(),
        "version": version,
        "checks": map[string]string{
            "database": checkDatabase(),
            "cache": checkCache(),
            "external_api": checkExternalAPI(),
        },
    }

    if hasUnhealthyCheck(health["checks"]) {
        w.WriteHeader(http.StatusServiceUnavailable)
        health["status"] = "unhealthy"
    }

    json.NewEncoder(w).Encode(health)
}
```

```typescript
// TypeScript/Express
app.get('/health', async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    cache: await checkCache(),
    memory: checkMemory(),
  };

  const healthy = Object.values(checks).every(c => c.status === 'ok');

  res.status(healthy ? 200 : 503).json({
    status: healthy ? 'healthy' : 'unhealthy',
    timestamp: new Date().toISOString(),
    version: process.env.VERSION,
    checks,
  });
});
```

## Pre-Deployment Commands

### Run Before Deploying

```bash
# JavaScript/TypeScript
npm run lint && npm test && npm run build

# Go
go vet ./... && go test ./... && go build ./...

# Java
mvn verify

# Python
black --check . && pytest && pip wheel .
```

## Rollback Readiness

### Before Deploying, Ensure:
1. Previous version is tagged
2. Database migration is reversible
3. Feature flags can disable new code
4. Rollback procedure is documented

### Rollback Checklist
- [ ] Can revert to previous container/binary
- [ ] Database can be migrated down
- [ ] Cache can be invalidated
- [ ] Feature flags configured
- [ ] Team knows rollback procedure

## Common Deployment Blockers

### Code Issues
- Failing tests
- Build errors
- Unresolved merge conflicts
- Missing dependencies

### Configuration Issues
- Missing environment variables
- Incorrect API endpoints
- Wrong database credentials
- Missing secrets

### Infrastructure Issues
- Insufficient resources
- Network configuration
- SSL certificate issues
- DNS not propagated

## See Also

- `references/smoke-tests.md` - Detailed smoke test patterns
- `references/health-checks.md` - Health check implementation
- `references/rollback.md` - Rollback strategies
