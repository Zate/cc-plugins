# View Generation

Views are auto-generated whenever an issue is created, updated, or deleted.

## Regeneration Triggers

| Action | Regenerate Views |
|--------|------------------|
| Create issue | Yes - all views |
| Update issue status | Yes - all views |
| Update issue priority | Yes - all views |
| Update issue type | Yes - all views |
| Delete issue | Yes - all views |
| Update other fields | Yes - index.md only |

## View Generation Algorithm

```python
# Pseudocode for view generation

def regenerate_views():
    issues = parse_all_issues(".devloop/issues/*.md")

    # Generate index.md
    generate_index(issues)

    # Generate type-specific views
    generate_bugs_view(filter(issues, type="bug"))
    generate_features_view(filter(issues, type="feature"))

    # Generate backlog (open features + tasks)
    backlog = filter(issues,
        type in ["feature", "task"] AND status="open")
    generate_backlog_view(backlog)

def generate_index(issues):
    # Count by status
    counts = count_by_status(issues)

    # Group open by priority (critical, high, medium, low)
    open_by_priority = group_by(
        filter(issues, status="open"),
        "priority"
    )

    # Get in-progress issues
    in_progress = filter(issues, status="in-progress")

    # Get recent done (last 10)
    recent_done = sort_by_updated(
        filter(issues, status="done")
    )[:10]

    # Write index.md with template
```

## View Consistency

Agents MUST regenerate views after ANY issue modification:

1. After creating issue → regenerate all views
2. After updating issue → regenerate all views
3. After deleting issue → regenerate all views

**The issue files are the source of truth. Views are derived.**
