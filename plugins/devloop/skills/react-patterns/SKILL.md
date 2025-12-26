---
name: react-patterns
description: This skill should be used when working with React/TypeScript code, implementing React features, reviewing React patterns, or when the user asks about "React hooks", "React components", "React state management", "React performance", "useEffect", "useState", "custom hooks", "React context".
whenToUse: |
  - Working with React/TypeScript code
  - Implementing React features and components
  - Reviewing React patterns and best practices
  - Understanding hooks (useState, useEffect, custom hooks)
  - Performance optimization with useMemo, useCallback, React.memo
whenNotToUse: |
  - Non-React code - use Vue, Angular, or Svelte patterns
  - React Native - mobile has different patterns
  - Class components - prefer hooks for new code
  - Server components only - RSC has different patterns
  - Simple static sites - over-engineering for basic HTML/CSS
---

# React Patterns

Modern React patterns and best practices. **Extends** `language-patterns-base` with React/TypeScript-specific guidance.

**React Version**: Targets React 18+. Concurrent features and automatic batching require React 18+.

> For universal principles (AAA testing, separation of concerns, naming), see `Skill: language-patterns-base`.

## When NOT to Use This Skill

- **Non-React code**: Use Vue, Angular, or Svelte-specific patterns instead
- **React Native**: Mobile has different patterns and constraints
- **Class components**: Legacy patterns - prefer hooks for new code
- **Server components only**: RSC has different patterns (data fetching, etc.)
- **Simple static sites**: Over-engineering for basic HTML/CSS pages

## Quick Reference

| Pattern | Use Case | Example |
|---------|----------|---------|
| Custom hooks | Reusable logic | `useUser()`, `useLocalStorage()` |
| Compound components | Related component groups | `<Tabs><Tabs.Tab/></Tabs>` |
| Render props | Flexible rendering | `<Mouse render={pos => ...}/>` |
| Context + Reducer | Complex state | Auth context, theme context |
| Controlled components | Form inputs | `value={value} onChange={...}` |

## Component Design

### Functional Components with TypeScript

```typescript
interface ButtonProps {
  variant: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
}

function Button({
  variant,
  size = 'md',
  disabled = false,
  onClick,
  children,
}: ButtonProps) {
  return (
    <button
      className={`btn btn-${variant} btn-${size}`}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
```

### Component Composition

```typescript
// Prefer composition over props drilling
function Dashboard() {
  return (
    <Layout>
      <Layout.Header>
        <Navigation />
      </Layout.Header>
      <Layout.Main>
        <Content />
      </Layout.Main>
      <Layout.Footer>
        <Footer />
      </Layout.Footer>
    </Layout>
  );
}
```

## Forms

### Controlled Components

```typescript
function LoginForm() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    login(email, password);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />
      <button type="submit">Login</button>
    </form>
  );
}
```

## Accessibility (a11y)

### Essential Patterns

```typescript
// Semantic HTML
<button onClick={handleClick}>Submit</button>  // Good
<div onClick={handleClick}>Submit</div>        // Bad

// Labels for inputs
<label htmlFor="email">Email</label>
<input id="email" type="email" />

// ARIA for dynamic content
<div role="alert" aria-live="polite">
  {errorMessage}
</div>

// Keyboard navigation
<button
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleAction();
    }
  }}
>
  Action
</button>
```

## Anti-Patterns to Avoid

- **Prop drilling**: Use context instead
- **Inline functions in render**: Causes unnecessary re-renders
- **Missing keys in lists**: React can't track items
- **Direct DOM manipulation**: Use refs properly
- **Overusing useEffect**: Consider alternatives first

## References

For comprehensive patterns and examples, see these reference files:

### Hooks (`references/hooks.md`)
- Custom hook patterns (data fetching, localStorage, debounce)
- `useState`, `useEffect`, `useMemo`, `useCallback`, `useRef`
- `useContext`, `useReducer`
- Effect dependencies and cleanup
- Rules of hooks

### State Management (`references/state-management.md`)
- Context + Reducer pattern (complete implementation)
- Multiple contexts and provider composition
- Local vs global state decision framework
- State initialization and derived state
- Advanced reducer patterns and middleware
- State persistence (localStorage, sessionStorage)

### Performance (`references/performance.md`)
- `React.memo` and custom comparison
- Virtualization for long lists (FixedSizeList, VariableSizeList, Grid)
- Code splitting and lazy loading
- Memoization strategies (`useMemo`, `useCallback`)
- Bundle size optimization
- Render optimization patterns
- Performance monitoring with Profiler and Web Vitals

### Testing (`references/testing.md`)
- React Testing Library patterns
- Querying elements (by role, label, text)
- User interaction testing (forms, clicks, typing)
- Async testing (`waitFor`, `findBy`)
- Mocking (API calls, modules, MSW)
- Testing hooks with `renderHook`
- Testing context providers
- Accessibility testing with jest-axe

## See Also

- `Skill: language-patterns-base` - Universal principles
- `Skill: testing-strategies` - Comprehensive test strategies
- `Skill: architecture-patterns` - High-level design
