# React State Management Patterns

Comprehensive guide to managing state in React applications.

## Context + Reducer Pattern

### Complete Implementation

```typescript
// 1. Define types
interface AuthState {
  user: User | null;
  loading: boolean;
}

type AuthAction =
  | { type: 'LOGIN_START' }
  | { type: 'LOGIN_SUCCESS'; user: User }
  | { type: 'LOGIN_FAILURE'; error: string }
  | { type: 'LOGOUT' };

// 2. Create reducer
function authReducer(state: AuthState, action: AuthAction): AuthState {
  switch (action.type) {
    case 'LOGIN_START':
      return { ...state, loading: true };
    case 'LOGIN_SUCCESS':
      return { user: action.user, loading: false };
    case 'LOGIN_FAILURE':
      return { ...state, loading: false };
    case 'LOGOUT':
      return { user: null, loading: false };
    default:
      return state;
  }
}

// 3. Create context
const AuthContext = createContext<{
  state: AuthState;
  dispatch: React.Dispatch<AuthAction>;
} | null>(null);

// 4. Create provider component
function AuthProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(authReducer, {
    user: null,
    loading: true,
  });

  // Optional: Add effects for persistence
  useEffect(() => {
    // Load user from localStorage on mount
    const savedUser = localStorage.getItem('user');
    if (savedUser) {
      dispatch({ type: 'LOGIN_SUCCESS', user: JSON.parse(savedUser) });
    } else {
      dispatch({ type: 'LOGOUT' });
    }
  }, []);

  useEffect(() => {
    // Save user to localStorage on change
    if (state.user) {
      localStorage.setItem('user', JSON.stringify(state.user));
    } else {
      localStorage.removeItem('user');
    }
  }, [state.user]);

  return (
    <AuthContext.Provider value={{ state, dispatch }}>
      {children}
    </AuthContext.Provider>
  );
}

// 5. Create custom hook
function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}

// 6. Create action creators (optional but recommended)
const authActions = {
  login: (email: string, password: string) => async (dispatch: Dispatch) => {
    dispatch({ type: 'LOGIN_START' });
    try {
      const user = await api.login(email, password);
      dispatch({ type: 'LOGIN_SUCCESS', user });
    } catch (error) {
      dispatch({ type: 'LOGIN_FAILURE', error: error.message });
    }
  },
  logout: () => ({ type: 'LOGOUT' as const }),
};
```

### Usage

```typescript
function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/dashboard" element={<Dashboard />} />
        </Routes>
      </Router>
    </AuthProvider>
  );
}

function Login() {
  const { state, dispatch } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    dispatch({ type: 'LOGIN_START' });
    try {
      const user = await api.login(email, password);
      dispatch({ type: 'LOGIN_SUCCESS', user });
    } catch (error) {
      dispatch({ type: 'LOGIN_FAILURE', error: error.message });
    }
  };

  return <form onSubmit={handleSubmit}>...</form>;
}
```

## Multiple Contexts Pattern

### Separate Concerns

```typescript
// Theme context
const ThemeContext = createContext<Theme | null>(null);

function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<Theme>('light');
  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

// User context
const UserContext = createContext<UserContextType | null>(null);

function UserProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  return (
    <UserContext.Provider value={{ user, setUser }}>
      {children}
    </UserContext.Provider>
  );
}

// Compose providers
function App() {
  return (
    <ThemeProvider>
      <UserProvider>
        <AppContent />
      </UserProvider>
    </ThemeProvider>
  );
}
```

### Provider Composition Helper

```typescript
function ComposeProviders({ providers, children }: {
  providers: React.ComponentType<{ children: React.ReactNode }>[];
  children: React.ReactNode;
}) {
  return providers.reduceRight(
    (child, Provider) => <Provider>{child}</Provider>,
    children
  );
}

// Usage
<ComposeProviders providers={[ThemeProvider, UserProvider, I18nProvider]}>
  <App />
</ComposeProviders>
```

## Local vs Global State

### Decision Framework

| State Type | Scope | Example | Storage |
|------------|-------|---------|---------|
| Local | Single component | Form input, toggle | `useState` |
| Lifted | Component tree | Shared form data | `useState` + props |
| Context | Feature area | Theme, i18n | `useContext` |
| Global | Entire app | Auth, user settings | Context + Reducer or Redux |

### Lifting State Up

```typescript
// Bad: Duplicated state
function Parent() {
  return (
    <>
      <ChildA /> {/* Has own count state */}
      <ChildB /> {/* Has own count state */}
    </>
  );
}

// Good: Lifted state
function Parent() {
  const [count, setCount] = useState(0);
  return (
    <>
      <ChildA count={count} onIncrement={() => setCount(c => c + 1)} />
      <ChildB count={count} />
    </>
  );
}
```

## State Initialization Patterns

### Lazy Initialization

```typescript
// Expensive initialization
const [state, setState] = useState(() => {
  const saved = localStorage.getItem('data');
  return saved ? JSON.parse(saved) : computeExpensiveDefault();
});
```

### Derived State

```typescript
// Bad: Duplicating state
function UserList({ users }) {
  const [filteredUsers, setFilteredUsers] = useState([]);

  useEffect(() => {
    setFilteredUsers(users.filter(u => u.active));
  }, [users]);

  return <div>{filteredUsers.map(...)}</div>;
}

// Good: Computed on render
function UserList({ users }) {
  const filteredUsers = users.filter(u => u.active);
  return <div>{filteredUsers.map(...)}</div>;
}

// Better: Memoized if expensive
function UserList({ users }) {
  const filteredUsers = useMemo(
    () => users.filter(u => u.active),
    [users]
  );
  return <div>{filteredUsers.map(...)}</div>;
}
```

## Advanced Reducer Patterns

### Middleware Pattern

```typescript
type Middleware = (action: Action, state: State) => Action | null;

function createReducerWithMiddleware(
  reducer: Reducer,
  middlewares: Middleware[]
) {
  return (state: State, action: Action) => {
    let processedAction = action;

    for (const middleware of middlewares) {
      const result = middleware(processedAction, state);
      if (result === null) return state; // Cancel action
      processedAction = result;
    }

    return reducer(state, processedAction);
  };
}

// Logging middleware
const logger: Middleware = (action, state) => {
  console.log('Action:', action, 'State:', state);
  return action;
};

// Usage
const reducer = createReducerWithMiddleware(myReducer, [logger]);
```

### Immer for Immutability

```typescript
import { useImmerReducer } from 'use-immer';

function reducer(draft: State, action: Action) {
  switch (action.type) {
    case 'ADD_TODO':
      // Mutate draft directly
      draft.todos.push(action.todo);
      break;
    case 'TOGGLE_TODO':
      const todo = draft.todos.find(t => t.id === action.id);
      if (todo) {
        todo.completed = !todo.completed;
      }
      break;
  }
}

const [state, dispatch] = useImmerReducer(reducer, initialState);
```

## State Machine Pattern

### Explicit State Machine

```typescript
type State =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: Data }
  | { status: 'error'; error: Error };

type Action =
  | { type: 'FETCH' }
  | { type: 'SUCCESS'; data: Data }
  | { type: 'ERROR'; error: Error }
  | { type: 'RESET' };

function reducer(state: State, action: Action): State {
  switch (state.status) {
    case 'idle':
      if (action.type === 'FETCH') return { status: 'loading' };
      return state;

    case 'loading':
      if (action.type === 'SUCCESS') {
        return { status: 'success', data: action.data };
      }
      if (action.type === 'ERROR') {
        return { status: 'error', error: action.error };
      }
      return state;

    case 'success':
      if (action.type === 'RESET') return { status: 'idle' };
      return state;

    case 'error':
      if (action.type === 'RESET') return { status: 'idle' };
      return state;
  }
}
```

## Redux Integration (When Needed)

### When to Use Redux

**Good candidates:**
- Large app with many features
- Complex state logic
- State needs to be accessed everywhere
- Time-travel debugging needed
- Team familiar with Redux

**Not needed when:**
- Small app with simple state
- Context + Reducer is sufficient
- Learning overhead not justified

### Redux Toolkit Pattern

```typescript
import { createSlice, configureStore } from '@reduxjs/toolkit';

const userSlice = createSlice({
  name: 'user',
  initialState: { user: null, loading: false },
  reducers: {
    loginStart: (state) => {
      state.loading = true;
    },
    loginSuccess: (state, action) => {
      state.user = action.payload;
      state.loading = false;
    },
    logout: (state) => {
      state.user = null;
    },
  },
});

const store = configureStore({
  reducer: {
    user: userSlice.reducer,
  },
});

// Usage
dispatch(userSlice.actions.loginStart());
```

## State Persistence

### LocalStorage Sync

```typescript
function usePersistedState<T>(key: string, initialValue: T) {
  const [state, setState] = useState<T>(() => {
    const saved = localStorage.getItem(key);
    return saved ? JSON.parse(saved) : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(state));
  }, [key, state]);

  return [state, setState] as const;
}
```

### SessionStorage for Temporary State

```typescript
function useSessionState<T>(key: string, initialValue: T) {
  const [state, setState] = useState<T>(() => {
    const saved = sessionStorage.getItem(key);
    return saved ? JSON.parse(saved) : initialValue;
  });

  useEffect(() => {
    sessionStorage.setItem(key, JSON.stringify(state));
  }, [key, state]);

  return [state, setState] as const;
}
```

## Anti-Patterns

### Avoid

- **Prop drilling** - Use context instead
- **Over-using global state** - Keep state local when possible
- **Duplicating state** - Derive from single source of truth
- **State in refs** - Use state for reactive values
- **setState in render** - Compute during render or use effect

## See Also

- Main skill: `react-patterns/SKILL.md`
- Hooks: `hooks.md`
- Performance: `performance.md`
