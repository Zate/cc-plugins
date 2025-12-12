---
name: react-patterns
description: React and TypeScript best practices including hooks, component design, state management, performance optimization, and accessibility. Use when building React applications or making React-specific decisions.
---

# React Patterns

Modern React patterns and best practices for building maintainable applications.

**React Version**: These patterns target React 18+. Concurrent features and automatic batching require React 18+.

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

## Hooks

### Custom Hook Pattern

```typescript
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchUser() {
      try {
        setLoading(true);
        const data = await api.getUser(userId);
        if (!cancelled) {
          setUser(data);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err as Error);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    fetchUser();

    return () => {
      cancelled = true;
    };
  }, [userId]);

  return { user, loading, error };
}
```

### useEffect Dependencies

```typescript
// Good: All dependencies listed
useEffect(() => {
  const handler = () => doSomething(value);
  window.addEventListener('resize', handler);
  return () => window.removeEventListener('resize', handler);
}, [value]); // value is used, so it's a dependency

// Good: Stable callback reference
const handleClick = useCallback(() => {
  console.log(count);
}, [count]);
```

### Common Hooks Reference

```typescript
// State
const [state, setState] = useState(initialValue);

// Effect (side effects)
useEffect(() => {
  // effect
  return () => { /* cleanup */ };
}, [deps]);

// Memoized values
const memoized = useMemo(() => expensiveCalc(a, b), [a, b]);

// Stable callbacks
const callback = useCallback(() => fn(a), [a]);

// Refs (mutable value that doesn't trigger re-render)
const ref = useRef<HTMLDivElement>(null);

// Context
const value = useContext(MyContext);

// Reducer (complex state)
const [state, dispatch] = useReducer(reducer, initialState);
```

## State Management

### Context + Reducer Pattern

```typescript
// Define types
interface AuthState {
  user: User | null;
  loading: boolean;
}

type AuthAction =
  | { type: 'LOGIN_START' }
  | { type: 'LOGIN_SUCCESS'; user: User }
  | { type: 'LOGOUT' };

// Reducer
function authReducer(state: AuthState, action: AuthAction): AuthState {
  switch (action.type) {
    case 'LOGIN_START':
      return { ...state, loading: true };
    case 'LOGIN_SUCCESS':
      return { user: action.user, loading: false };
    case 'LOGOUT':
      return { user: null, loading: false };
    default:
      return state;
  }
}

// Context
const AuthContext = createContext<{
  state: AuthState;
  dispatch: React.Dispatch<AuthAction>;
} | null>(null);

// Provider
function AuthProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(authReducer, {
    user: null,
    loading: true,
  });

  return (
    <AuthContext.Provider value={{ state, dispatch }}>
      {children}
    </AuthContext.Provider>
  );
}

// Hook
function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}
```

## Performance

### React.memo for Expensive Components

```typescript
const ExpensiveList = React.memo(function ExpensiveList({
  items,
}: {
  items: Item[];
}) {
  return (
    <ul>
      {items.map((item) => (
        <ExpensiveItem key={item.id} item={item} />
      ))}
    </ul>
  );
});
```

### Virtualization for Long Lists

```typescript
import { FixedSizeList } from 'react-window';

function VirtualizedList({ items }: { items: Item[] }) {
  return (
    <FixedSizeList
      height={400}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {({ index, style }) => (
        <div style={style}>
          <Item item={items[index]} />
        </div>
      )}
    </FixedSizeList>
  );
}
```

### Code Splitting

```typescript
// Lazy load components
const Dashboard = React.lazy(() => import('./Dashboard'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Dashboard />
    </Suspense>
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

## Testing

### React Testing Library

```typescript
import { render, screen, fireEvent } from '@testing-library/react';

test('submits form with user data', async () => {
  const onSubmit = jest.fn();
  render(<LoginForm onSubmit={onSubmit} />);

  fireEvent.change(screen.getByLabelText('Email'), {
    target: { value: 'test@example.com' },
  });
  fireEvent.change(screen.getByLabelText('Password'), {
    target: { value: 'password123' },
  });
  fireEvent.click(screen.getByRole('button', { name: /submit/i }));

  expect(onSubmit).toHaveBeenCalledWith({
    email: 'test@example.com',
    password: 'password123',
  });
});
```

## Anti-Patterns to Avoid

- **Prop drilling**: Use context instead
- **Inline functions in render**: Causes unnecessary re-renders
- **Missing keys in lists**: React can't track items
- **Direct DOM manipulation**: Use refs properly
- **Overusing useEffect**: Consider alternatives first

## See Also

- `references/hooks.md` - Advanced hook patterns
- `references/performance.md` - Performance optimization
- `references/testing.md` - Testing strategies
