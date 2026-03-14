---
name: database-patterns
description: This skill should be used for database schema design, indexes, query optimization, migrations, SQL, PostgreSQL, MySQL, ORM patterns, data modeling, database relationships
---

# Database Patterns

Database design and optimization patterns.

## Schema Design

- Use appropriate data types
- Add NOT NULL where applicable
- Use foreign keys for relationships
- Index frequently queried columns

## Indexing

```sql
-- Single column
CREATE INDEX idx_users_email ON users(email);

-- Composite (order matters)
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at);
```

## Query Optimization

### N+1 Problem

```sql
-- Bad: N+1 queries
SELECT * FROM users;
SELECT * FROM orders WHERE user_id = 1;
SELECT * FROM orders WHERE user_id = 2;
...

-- Good: JOIN or eager load
SELECT u.*, o.* FROM users u
LEFT JOIN orders o ON o.user_id = u.id;
```

## Migrations

- One migration per change
- Up and down migrations
- Never modify deployed migrations
- Test rollback

## Connection Pooling

- Reuse connections
- Set appropriate pool size
- Handle connection timeouts
