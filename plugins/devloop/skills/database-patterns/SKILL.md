---
name: database-patterns
description: This skill should be used when designing database schemas, optimizing queries, planning indexes, or when the user asks about 'database schema', 'database indexes', 'query optimization', 'database migrations', 'normalization', 'SQL performance', 'database relationships', 'connection pooling'.
---

# Database Patterns

Best practices for database design, optimization, and maintenance.

## When NOT to Use This Skill

- **In-memory data structures**: This is for persistent storage, not runtime data
- **File-based storage**: JSON/YAML configs don't need database patterns
- **Existing schema**: When schema is locked and you're just querying
- **NoSQL key-value**: Simple key-value stores have different patterns
- **ORM handles it**: When your framework abstracts the database layer

## Schema Design Principles

### Normalization Levels

| Level | Description | When to Use |
|-------|-------------|-------------|
| 1NF | No repeating groups | Always |
| 2NF | No partial dependencies | Usually |
| 3NF | No transitive dependencies | Often |
| BCNF | Every determinant is a key | Complex systems |
| Denormalized | Intentional redundancy | Read-heavy, reporting |

### When to Denormalize
- Read performance is critical
- Data changes infrequently
- Reporting/analytics queries
- Calculated fields frequently accessed
- Reducing JOIN complexity

## Naming Conventions

### Tables
```sql
-- Plural, snake_case
users
order_items
user_preferences
```

### Columns
```sql
-- snake_case, descriptive
user_id          -- Foreign key
created_at       -- Timestamps
is_active        -- Booleans
email_address    -- Descriptive
```

### Indexes
```sql
-- idx_table_columns
idx_users_email
idx_orders_user_id_created_at
```

### Constraints
```sql
-- type_table_columns
pk_users
fk_orders_user_id
uq_users_email
chk_orders_amount
```

## Index Strategies

### When to Create Indexes
- Primary keys (automatic)
- Foreign keys (usually)
- Columns in WHERE clauses
- Columns in JOIN conditions
- Columns in ORDER BY
- Columns with high selectivity

### Index Types

| Type | Use Case | Example |
|------|----------|---------|
| B-tree | Default, most queries | `CREATE INDEX` |
| Hash | Exact equality only | `USING HASH` |
| GiST | Geometric, full-text | PostGIS, tsvector |
| GIN | Arrays, JSONB | `USING GIN` |
| Partial | Subset of rows | `WHERE is_active` |
| Covering | Include extra columns | `INCLUDE (name)` |

### Composite Index Order
```sql
-- Order matters: left-to-right
CREATE INDEX idx_orders_user_date
ON orders(user_id, created_at);

-- This index helps:
WHERE user_id = 1
WHERE user_id = 1 AND created_at > '2024-01-01'

-- This index does NOT help:
WHERE created_at > '2024-01-01'  -- user_id not specified
```

## Query Optimization

### EXPLAIN ANALYZE
```sql
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'test@example.com';
```

### Common Optimizations

| Problem | Solution |
|---------|----------|
| Full table scan | Add appropriate index |
| N+1 queries | Use JOINs or batch loading |
| Large result sets | Add pagination |
| Slow JOINs | Ensure FK indexes exist |
| Complex subqueries | Consider CTEs or temp tables |

### Query Anti-Patterns
```sql
-- Avoid: Function on indexed column
WHERE LOWER(email) = 'test@example.com'
-- Better: Functional index or case-insensitive collation

-- Avoid: OR on different columns
WHERE user_id = 1 OR email = 'test@example.com'
-- Better: UNION of two queries

-- Avoid: SELECT *
SELECT * FROM users
-- Better: Select only needed columns

-- Avoid: NOT IN with NULLs
WHERE id NOT IN (SELECT user_id FROM deleted_users)
-- Better: NOT EXISTS or LEFT JOIN IS NULL
```

## Data Types

### Choosing Types
| Data | Recommended Type | Notes |
|------|-----------------|-------|
| UUID | `uuid` / `CHAR(36)` | Use native UUID if available |
| Money | `DECIMAL(19,4)` | Never use FLOAT |
| Email | `VARCHAR(255)` | With constraint/validation |
| Status | `ENUM` or `VARCHAR` | ENUM for fixed set |
| JSON | `JSONB` (Postgres) | Indexed, queryable |
| Timestamps | `TIMESTAMP WITH TIME ZONE` | Always store UTC |

### ID Strategies

| Strategy | Pros | Cons |
|----------|------|------|
| Auto-increment | Simple, sequential | Predictable, single point |
| UUID v4 | Distributed, unique | Larger, not sortable |
| UUID v7 | Sortable, unique | Newer, less support |
| ULID | Sortable, URL-safe | Less common |

## Migration Best Practices

### Safe Migration Patterns

```sql
-- 1. Add column (nullable first)
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- 2. Backfill data
UPDATE users SET phone = '' WHERE phone IS NULL;

-- 3. Add constraint
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;
```

### Dangerous Operations
| Operation | Risk | Mitigation |
|-----------|------|------------|
| Add NOT NULL column | Locks table | Add nullable, backfill, constrain |
| Drop column | Data loss | Soft delete first, verify unused |
| Rename column | Breaks queries | Deploy code first |
| Change type | Data loss | Create new column, migrate |
| Add index | Locks (some DBs) | Use CONCURRENTLY |

### Migration Checklist
- [ ] Reviewed by DBA/senior
- [ ] Tested on production-size data
- [ ] Has rollback plan
- [ ] Runs in reasonable time
- [ ] No exclusive locks on busy tables
- [ ] Backwards compatible

## Relationships

### One-to-Many
```sql
-- Users have many orders
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  ...
);
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

### Many-to-Many
```sql
-- Users have many roles, roles have many users
CREATE TABLE user_roles (
  user_id INTEGER REFERENCES users(id),
  role_id INTEGER REFERENCES roles(id),
  PRIMARY KEY (user_id, role_id)
);
```

### Self-Referential
```sql
-- Categories with parent categories
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  parent_id INTEGER REFERENCES categories(id),
  name VARCHAR(100)
);
```

## Soft Deletes

### Implementation
```sql
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP;

-- Query active users
SELECT * FROM users WHERE deleted_at IS NULL;

-- Soft delete
UPDATE users SET deleted_at = NOW() WHERE id = 1;
```

### Considerations
- Add to all foreign key relationships
- Create views for "active" records
- Consider cascading soft deletes
- Index deleted_at for performance

## Audit Patterns

### Timestamp Columns
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  -- ... other columns
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by INTEGER REFERENCES users(id),
  updated_by INTEGER REFERENCES users(id)
);
```

### Audit Table
```sql
CREATE TABLE audit_log (
  id SERIAL PRIMARY KEY,
  table_name VARCHAR(100),
  record_id INTEGER,
  action VARCHAR(10),  -- INSERT, UPDATE, DELETE
  old_values JSONB,
  new_values JSONB,
  changed_by INTEGER,
  changed_at TIMESTAMP DEFAULT NOW()
);
```

## Connection Management

### Pool Sizing
```
connections = (core_count * 2) + effective_spindle_count
```

### Best Practices
- Use connection pooling
- Set appropriate timeouts
- Close connections properly
- Monitor connection count
- Use read replicas for reads

## See Also

- `Skill: api-design` - API over database
- `Skill: testing-strategies` - Database testing
- `Skill: security-checklist` - Database security
