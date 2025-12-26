# React Hooks Reference

Comprehensive guide to React hooks patterns and best practices.

## Custom Hook Pattern

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

## useEffect Best Practices

### Dependencies

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

### Cleanup Functions

```typescript
// Good: Always cleanup side effects
useEffect(() => {
  const subscription = api.subscribe(userId);
  return () => subscription.unsubscribe();
}, [userId]);

// Good: Cancel async operations
useEffect(() => {
  let cancelled = false;

  async function load() {
    const data = await fetch(url);
    if (!cancelled) {
      setData(data);
    }
  }

  load();
  return () => { cancelled = true; };
}, [url]);
```

### Common Pitfalls

```typescript
// Bad: Missing dependency
useEffect(() => {
  doSomething(value);
}, []); // value should be in deps

// Bad: Infinite loop
useEffect(() => {
  setCount(count + 1);
}, [count]); // Re-runs every time count changes

// Good: Use functional update
useEffect(() => {
  setCount(prev => prev + 1);
}, []); // Only runs once
```

## Common Hooks Reference

### useState

```typescript
// Basic usage
const [state, setState] = useState(initialValue);

// With function initializer (expensive calculation)
const [state, setState] = useState(() => expensiveCalc());

// Functional updates
setState(prevState => prevState + 1);

// Multiple state variables
const [name, setName] = useState('');
const [age, setAge] = useState(0);
```

### useEffect

```typescript
// Run on every render
useEffect(() => {
  // effect
});

// Run once (component mount)
useEffect(() => {
  // effect
}, []);

// Run when dependencies change
useEffect(() => {
  // effect
}, [dep1, dep2]);

// Cleanup
useEffect(() => {
  // effect
  return () => { /* cleanup */ };
}, [deps]);
```

### useMemo

```typescript
// Memoize expensive calculations
const memoized = useMemo(() => {
  return expensiveCalc(a, b);
}, [a, b]);

// Don't overuse
const simple = a + b; // No useMemo needed

// Good use case
const sortedList = useMemo(() => {
  return items.slice().sort((a, b) => a.value - b.value);
}, [items]);
```

### useCallback

```typescript
// Memoize callback functions
const handleClick = useCallback(() => {
  doSomething(value);
}, [value]);

// Pass to memoized child components
const MemoChild = React.memo(Child);
<MemoChild onClick={handleClick} />

// Don't overuse
const simple = () => console.log('hi'); // No useCallback needed
```

### useRef

```typescript
// DOM references
const inputRef = useRef<HTMLInputElement>(null);
useEffect(() => {
  inputRef.current?.focus();
}, []);

// Mutable values that don't trigger re-render
const countRef = useRef(0);
countRef.current += 1; // Doesn't cause re-render

// Previous value tracking
const usePrevious = (value: any) => {
  const ref = useRef();
  useEffect(() => {
    ref.current = value;
  }, [value]);
  return ref.current;
};
```

### useContext

```typescript
// Create context
const ThemeContext = createContext<Theme | null>(null);

// Use context
function ThemedButton() {
  const theme = useContext(ThemeContext);
  if (!theme) {
    throw new Error('Must be used within ThemeProvider');
  }
  return <button style={{ color: theme.color }}>Button</button>;
}

// Provide context
<ThemeContext.Provider value={theme}>
  <App />
</ThemeContext.Provider>
```

### useReducer

```typescript
// Define reducer
type State = { count: number };
type Action = { type: 'increment' } | { type: 'decrement' };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { count: state.count + 1 };
    case 'decrement':
      return { count: state.count - 1 };
    default:
      return state;
  }
}

// Use reducer
const [state, dispatch] = useReducer(reducer, { count: 0 });

// Dispatch actions
dispatch({ type: 'increment' });
```

## Custom Hook Patterns

### Data Fetching Hook

```typescript
function useApi<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function fetch() {
      try {
        const response = await api.get<T>(url);
        if (!cancelled) {
          setData(response);
          setLoading(false);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err as Error);
          setLoading(false);
        }
      }
    }

    fetch();
    return () => { cancelled = true; };
  }, [url]);

  return { data, loading, error };
}
```

### Local Storage Hook

```typescript
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const item = localStorage.getItem(key);
    return item ? JSON.parse(item) : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue] as const;
}
```

### Window Size Hook

```typescript
function useWindowSize() {
  const [size, setSize] = useState({
    width: window.innerWidth,
    height: window.innerHeight,
  });

  useEffect(() => {
    const handleResize = () => {
      setSize({
        width: window.innerWidth,
        height: window.innerHeight,
      });
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return size;
}
```

### Debounce Hook

```typescript
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => clearTimeout(handler);
  }, [value, delay]);

  return debouncedValue;
}
```

## Rules of Hooks

1. **Only call hooks at the top level** - Don't call in loops, conditions, or nested functions
2. **Only call hooks from React functions** - Function components or custom hooks
3. **Custom hooks must start with "use"** - Naming convention enforced by linter
4. **Dependencies must be honest** - Include all values used in effect

## See Also

- Main skill: `react-patterns/SKILL.md`
- State patterns: `state-management.md`
- Performance: `performance.md`
