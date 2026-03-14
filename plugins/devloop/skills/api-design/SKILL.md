---
name: api-design
description: This skill should be used for REST API, GraphQL, versioning, pagination, authentication, backend routes, web services, HTTP endpoints, server API design
---

# API Design

REST API design best practices.

## URL Structure

```
GET    /users          # List
GET    /users/:id      # Get one
POST   /users          # Create
PUT    /users/:id      # Replace
PATCH  /users/:id      # Update
DELETE /users/:id      # Delete
```

## Versioning

```
/api/v1/users          # URL versioning
Accept: application/vnd.api.v1+json  # Header
```

## Pagination

```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

## Error Responses

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": [{"field": "email", "issue": "invalid format"}]
  }
}
```

## Status Codes

| Code | Use |
|------|-----|
| 200 | Success |
| 201 | Created |
| 400 | Bad request |
| 401 | Unauthorized |
| 404 | Not found |
| 500 | Server error |
