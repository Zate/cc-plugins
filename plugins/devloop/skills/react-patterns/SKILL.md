---
name: react-patterns
description: This skill should be used for React hooks, components, state management, performance
whenToUse: React code, hooks, components, React performance
whenNotToUse: Non-React code
---

# React Patterns

Idiomatic React/TypeScript patterns.

## Functional Components

```tsx
interface Props {
  name: string;
  onClick: () => void;
}

const Button: React.FC<Props> = ({ name, onClick }) => (
  <button onClick={onClick}>{name}</button>
);
```

## Hooks

```tsx
// State
const [count, setCount] = useState(0);

// Effect with cleanup
useEffect(() => {
  const timer = setInterval(() => tick(), 1000);
  return () => clearInterval(timer);
}, []);

// Memoization
const expensive = useMemo(() => compute(data), [data]);
const handler = useCallback(() => doThing(id), [id]);
```

## Custom Hooks

```tsx
function useLocalStorage<T>(key: string, initial: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key);
    return stored ? JSON.parse(stored) : initial;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue] as const;
}
```

## Performance

- Use `React.memo` for expensive components
- Avoid inline objects/functions in props
- Use `key` prop correctly in lists
