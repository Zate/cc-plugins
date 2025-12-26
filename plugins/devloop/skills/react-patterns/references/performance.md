# React Performance Optimization

Comprehensive guide to optimizing React application performance.

## React.memo

### Basic Usage

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

### Custom Comparison Function

```typescript
const User = React.memo(
  function User({ user }: { user: User }) {
    return <div>{user.name}</div>;
  },
  (prevProps, nextProps) => {
    // Return true if props are equal (skip re-render)
    return prevProps.user.id === nextProps.user.id;
  }
);
```

### When to Use React.memo

**Good candidates:**
- Pure components that render the same output for the same props
- Components that re-render frequently with the same props
- Expensive render operations

**Don't use when:**
- Component always receives different props
- Render is already fast
- Comparison cost exceeds render cost

## Virtualization

### Long List Virtualization

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

### Variable Size Lists

```typescript
import { VariableSizeList } from 'react-window';

function VariableSizeListExample({ items }: { items: Item[] }) {
  const getItemSize = (index: number) => {
    // Dynamic height based on content
    return items[index].expanded ? 100 : 50;
  };

  return (
    <VariableSizeList
      height={400}
      itemCount={items.length}
      itemSize={getItemSize}
      width="100%"
    >
      {({ index, style }) => (
        <div style={style}>
          <Item item={items[index]} />
        </div>
      )}
    </VariableSizeList>
  );
}
```

### Grid Virtualization

```typescript
import { FixedSizeGrid } from 'react-window';

function VirtualizedGrid({ items }: { items: Item[] }) {
  const columnCount = 5;
  const rowCount = Math.ceil(items.length / columnCount);

  return (
    <FixedSizeGrid
      columnCount={columnCount}
      columnWidth={100}
      height={400}
      rowCount={rowCount}
      rowHeight={100}
      width={600}
    >
      {({ columnIndex, rowIndex, style }) => {
        const index = rowIndex * columnCount + columnIndex;
        return (
          <div style={style}>
            {items[index] && <Item item={items[index]} />}
          </div>
        );
      }}
    </FixedSizeGrid>
  );
}
```

## Code Splitting

### Component-Level Splitting

```typescript
// Lazy load components
const Dashboard = React.lazy(() => import('./Dashboard'));
const Profile = React.lazy(() => import('./Profile'));
const Settings = React.lazy(() => import('./Settings'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/profile" element={<Profile />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

### Route-Based Splitting

```typescript
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

const Home = lazy(() => import('./pages/Home'));
const About = lazy(() => import('./pages/About'));
const Contact = lazy(() => import('./pages/Contact'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<div>Loading...</div>}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/contact" element={<Contact />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}
```

### Named Exports with Lazy

```typescript
// Component.tsx
export function MyComponent() { ... }

// App.tsx
const MyComponent = lazy(() =>
  import('./Component').then(module => ({ default: module.MyComponent }))
);
```

### Preloading Components

```typescript
const Dashboard = lazy(() => import('./Dashboard'));

// Preload on hover
function Nav() {
  const preloadDashboard = () => {
    import('./Dashboard'); // Starts loading immediately
  };

  return (
    <nav>
      <Link to="/dashboard" onMouseEnter={preloadDashboard}>
        Dashboard
      </Link>
    </nav>
  );
}
```

## Memoization Strategies

### useMemo for Expensive Calculations

```typescript
function ProductList({ products, filter }: Props) {
  // Expensive filtering operation
  const filteredProducts = useMemo(() => {
    return products
      .filter(p => p.category === filter.category)
      .filter(p => p.price >= filter.minPrice)
      .sort((a, b) => b.price - a.price);
  }, [products, filter]);

  return <div>{filteredProducts.map(p => <Product key={p.id} {...p} />)}</div>;
}
```

### useCallback for Stable Function References

```typescript
function TodoList({ todos }: Props) {
  const [filter, setFilter] = useState('all');

  // Stable callback reference
  const handleToggle = useCallback((id: string) => {
    toggleTodo(id);
  }, []); // No dependencies, never changes

  // Memoize filtered list
  const filteredTodos = useMemo(() => {
    return todos.filter(todo =>
      filter === 'all' ? true :
      filter === 'active' ? !todo.completed :
      todo.completed
    );
  }, [todos, filter]);

  return (
    <div>
      {filteredTodos.map(todo => (
        <TodoItem
          key={todo.id}
          todo={todo}
          onToggle={handleToggle}
        />
      ))}
    </div>
  );
}

// Child component with React.memo
const TodoItem = React.memo(function TodoItem({
  todo,
  onToggle,
}: {
  todo: Todo;
  onToggle: (id: string) => void;
}) {
  return (
    <div>
      <input
        type="checkbox"
        checked={todo.completed}
        onChange={() => onToggle(todo.id)}
      />
      {todo.text}
    </div>
  );
});
```

## Bundle Size Optimization

### Import Analysis

```bash
# Analyze bundle size
npm run build -- --stats
npx webpack-bundle-analyzer build/bundle-stats.json
```

### Tree Shaking

```typescript
// Good: Import only what you need
import { Button } from '@mui/material';

// Bad: Imports entire library
import * as MUI from '@mui/material';
```

### Dynamic Imports for Large Libraries

```typescript
// Load heavy library only when needed
async function handleExport() {
  const XLSX = await import('xlsx');
  XLSX.writeFile(workbook, 'export.xlsx');
}
```

## Render Optimization

### Avoid Inline Object/Array Creation

```typescript
// Bad: Creates new object on every render
<Component style={{ margin: 10 }} />

// Good: Define outside or use useMemo
const style = { margin: 10 };
<Component style={style} />

// Bad: Creates new array on every render
<List items={items.filter(x => x.active)} />

// Good: Use useMemo
const activeItems = useMemo(() => items.filter(x => x.active), [items]);
<List items={activeItems} />
```

### Key Prop Optimization

```typescript
// Bad: Index as key (causes re-renders on reorder)
{items.map((item, index) => <Item key={index} {...item} />)}

// Good: Stable unique identifier
{items.map(item => <Item key={item.id} {...item} />)}

// Good: Composite key for nested lists
{categories.map(cat =>
  cat.items.map(item => <Item key={`${cat.id}-${item.id}`} {...item} />)
)}
```

## Performance Monitoring

### React DevTools Profiler

```typescript
import { Profiler } from 'react';

function App() {
  return (
    <Profiler id="App" onRender={onRenderCallback}>
      <Dashboard />
    </Profiler>
  );
}

function onRenderCallback(
  id: string,
  phase: "mount" | "update",
  actualDuration: number,
  baseDuration: number,
  startTime: number,
  commitTime: number
) {
  console.log(`${id} took ${actualDuration}ms to render`);
}
```

### Web Vitals

```typescript
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

getCLS(console.log);
getFID(console.log);
getFCP(console.log);
getLCP(console.log);
getTTFB(console.log);
```

## See Also

- Main skill: `react-patterns/SKILL.md`
- Hooks: `hooks.md`
- State management: `state-management.md`
