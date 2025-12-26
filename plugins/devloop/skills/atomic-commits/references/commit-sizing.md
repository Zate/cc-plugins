# Commit Size Guidelines

## Ideal: 50-200 lines changed
- Easy to review in one sitting
- Clear scope and intent
- Low cognitive load for reviewer

## Acceptable: 200-300 lines
- Still reviewable but requires more focus
- Should have very clear structure
- Consider if it can be split

## Warning: 300-500 lines
- Getting difficult to review thoroughly
- High chance of issues being missed
- Split if at all possible

## Red Flag: > 500 lines
- Too large for effective review
- Must split unless truly atomic (rare)
- Examples of valid large commits:
  - Generated code (clearly marked)
  - Large rename/move operation
  - Initial project scaffold

---

## Grouping Guidelines

### When to Group Tasks into One Commit

**Group these:**
- Feature implementation + its tests
- Model + its validation logic
- API endpoint + its request/response types
- Component + its styles (if co-located)
- Related small fixes (each < 20 lines)

**Grouping criteria:**
1. Tasks are in the same functional area
2. Combined size is < 500 lines
3. Changes make more sense together than apart
4. Reviewer benefits from seeing them together

### When to Keep Commits Separate

**Separate these:**
- Backend and frontend changes
- Feature code and refactoring
- Bug fixes and new features
- Database changes and application code
- Different modules/packages

**Separation criteria:**
1. Different areas of expertise to review
2. Different risk profiles
3. Changes are independently useful
4. Easier to revert one without the other

---

## Decision Flow

```
Task Complete
     │
     ├─► Is it < 100 lines AND self-contained?
     │   YES → Commit now
     │   NO  ↓
     │
     ├─► Is next task tightly coupled?
     │   NO  → Commit now
     │   YES ↓
     │
     ├─► Would combined be < 500 lines?
     │   NO  → Commit now
     │   YES ↓
     │
     └─► Group with next task
```

### After Each Task, Ask:

```
1. Is this task self-contained?
   YES → Consider committing now
   NO  → What does it depend on?

2. Is the next task tightly related?
   YES → Consider grouping
   NO  → Commit now

3. What's the combined line count?
   < 300 → Grouping is fine
   > 300 → Probably commit separately

4. Would a reviewer benefit from seeing these together?
   YES → Group them
   NO  → Commit separately
```
