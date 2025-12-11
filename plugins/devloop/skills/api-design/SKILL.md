---
name: api-design
description: Best practices for designing RESTful and GraphQL APIs. Covers endpoint naming, versioning, error handling, pagination, and documentation. Use when designing new APIs or reviewing existing ones.
---

# API Design

Best practices for designing clean, consistent, and developer-friendly APIs.

## REST API Conventions

### URL Structure
```
https://api.example.com/v1/resources
https://api.example.com/v1/resources/{id}
https://api.example.com/v1/resources/{id}/sub-resources
```

### Resource Naming
| Pattern | Example | Notes |
|---------|---------|-------|
| Plural nouns | `/users`, `/orders` | Consistent plurality |
| Kebab-case | `/user-profiles` | For multi-word resources |
| No verbs | `/users` not `/getUsers` | HTTP method is the verb |
| Hierarchical | `/users/{id}/orders` | Clear relationships |

### HTTP Methods

| Method | Purpose | Idempotent | Safe |
|--------|---------|------------|------|
| GET | Read resource(s) | Yes | Yes |
| POST | Create resource | No | No |
| PUT | Replace resource | Yes | No |
| PATCH | Partial update | No | No |
| DELETE | Remove resource | Yes | No |

### Status Codes

| Code | Meaning | Use Case |
|------|---------|----------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid input |
| 401 | Unauthorized | Missing/invalid auth |
| 403 | Forbidden | Auth valid, no permission |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | State conflict (duplicate) |
| 422 | Unprocessable | Validation failed |
| 429 | Too Many Requests | Rate limited |
| 500 | Server Error | Unexpected error |

## Request/Response Patterns

### Request Body
```json
{
  "data": {
    "name": "value",
    "nested": {
      "field": "value"
    }
  }
}
```

### Success Response
```json
{
  "data": {
    "id": "123",
    "type": "user",
    "attributes": {
      "name": "John",
      "email": "john@example.com"
    }
  },
  "meta": {
    "requestId": "abc-123"
  }
}
```

### Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  },
  "meta": {
    "requestId": "abc-123"
  }
}
```

### Collection Response
```json
{
  "data": [...],
  "meta": {
    "total": 100,
    "page": 1,
    "pageSize": 20
  },
  "links": {
    "self": "/users?page=1",
    "next": "/users?page=2",
    "prev": null
  }
}
```

## Pagination

### Offset Pagination
```
GET /users?page=2&pageSize=20
GET /users?offset=20&limit=20
```
- Simple to implement
- Inconsistent with changing data
- Poor performance on large offsets

### Cursor Pagination
```
GET /users?cursor=abc123&limit=20
```
- Consistent results
- Better performance
- Can't jump to specific page

### Keyset Pagination
```
GET /users?after_id=100&limit=20
```
- Best performance
- Requires sortable unique field
- No page numbers

## Filtering & Sorting

### Filtering
```
GET /users?status=active
GET /users?status=active,pending
GET /users?created_after=2024-01-01
GET /users?search=john
```

### Sorting
```
GET /users?sort=name
GET /users?sort=-created_at
GET /users?sort=name,-created_at
```

### Field Selection
```
GET /users?fields=id,name,email
GET /users?include=orders,profile
```

## Versioning Strategies

### URL Versioning (Recommended)
```
/v1/users
/v2/users
```
- Clear and explicit
- Easy to route
- Visible in logs

### Header Versioning
```
Accept: application/vnd.api+json; version=1
```
- Cleaner URLs
- Harder to test
- Easy to miss

### Query Parameter
```
/users?version=1
```
- Easy to test
- Can be forgotten
- Pollutes query string

## Authentication

### Bearer Token
```
Authorization: Bearer <token>
```

### API Key
```
X-API-Key: <key>
# or
?api_key=<key>  # Not recommended
```

### OAuth 2.0 Flows
| Flow | Use Case |
|------|----------|
| Authorization Code | Web apps, server-side |
| Client Credentials | Service-to-service |
| PKCE | Mobile, SPA |

## Rate Limiting

### Headers
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640000000
```

### Response (429)
```json
{
  "error": {
    "code": "RATE_LIMITED",
    "message": "Too many requests",
    "retryAfter": 60
  }
}
```

## GraphQL Considerations

### When to Use GraphQL
- Complex data relationships
- Multiple clients with different needs
- Rapid iteration needed
- Over/under-fetching problems

### When to Use REST
- Simple CRUD operations
- Caching is critical
- File upload/download
- Team familiarity

### GraphQL Best Practices
- Use DataLoader for N+1
- Implement query complexity limits
- Use persisted queries in production
- Provide clear error messages

## API Documentation

### Required Information
- Endpoint URL and method
- Authentication requirements
- Request parameters (path, query, body)
- Response format (success and error)
- Example requests/responses
- Rate limits
- Changelog

### OpenAPI/Swagger
```yaml
paths:
  /users/{id}:
    get:
      summary: Get user by ID
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: User found
```

## Security Checklist

- [ ] Use HTTPS only
- [ ] Validate all input
- [ ] Sanitize output
- [ ] Implement rate limiting
- [ ] Use authentication
- [ ] Check authorization
- [ ] Log security events
- [ ] Don't expose internal errors
- [ ] Set security headers
- [ ] Use CORS appropriately

## Anti-Patterns

### Avoid
- Verbs in URLs (`/getUser`)
- Inconsistent naming
- Deeply nested URLs (>3 levels)
- Exposing internal IDs
- Inconsistent error formats
- Missing pagination
- Ignoring HTTP semantics

## See Also

- `Skill: security-checklist` - API security
- `Skill: testing-strategies` - API testing
- `Skill: requirements-patterns` - API requirements
