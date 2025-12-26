# React Testing Patterns

Comprehensive guide to testing React components with React Testing Library.

## Testing Philosophy

**Guiding Principle**: Test your components the way users interact with them.

- Query by accessible elements (labels, roles, text)
- Interact via user events (click, type, submit)
- Assert on visible behavior, not implementation

## React Testing Library Basics

### Rendering Components

```typescript
import { render, screen } from '@testing-library/react';

test('renders welcome message', () => {
  render(<Welcome name="John" />);
  expect(screen.getByText('Welcome, John')).toBeInTheDocument();
});
```

### Querying Elements

```typescript
// By role (preferred)
screen.getByRole('button', { name: /submit/i });
screen.getByRole('textbox', { name: /email/i });

// By label text
screen.getByLabelText('Email');

// By placeholder
screen.getByPlaceholderText('Enter email');

// By text content
screen.getByText('Welcome');

// By test ID (last resort)
screen.getByTestId('custom-element');
```

### Query Variants

| Variant | Returns | When to Use |
|---------|---------|-------------|
| getBy | Element or throw | Element should exist |
| queryBy | Element or null | Element may not exist |
| findBy | Promise\<Element\> | Async elements |
| getAllBy | Element[] | Multiple elements |
| queryAllBy | Element[] or [] | Multiple, may not exist |
| findAllBy | Promise\<Element[]\> | Async multiple |

## User Interaction Testing

### Form Submission

```typescript
import { render, screen, fireEvent } from '@testing-library/react';

test('submits form with user data', async () => {
  const onSubmit = jest.fn();
  render(<LoginForm onSubmit={onSubmit} />);

  // Fill in form
  fireEvent.change(screen.getByLabelText('Email'), {
    target: { value: 'test@example.com' },
  });
  fireEvent.change(screen.getByLabelText('Password'), {
    target: { value: 'password123' },
  });

  // Submit
  fireEvent.click(screen.getByRole('button', { name: /submit/i }));

  // Assert
  expect(onSubmit).toHaveBeenCalledWith({
    email: 'test@example.com',
    password: 'password123',
  });
});
```

### User Events (Preferred)

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

test('types into input', async () => {
  const user = userEvent.setup();
  render(<Input />);

  const input = screen.getByRole('textbox');
  await user.type(input, 'Hello World');

  expect(input).toHaveValue('Hello World');
});

test('clicks button', async () => {
  const user = userEvent.setup();
  const handleClick = jest.fn();
  render(<Button onClick={handleClick}>Click Me</Button>);

  await user.click(screen.getByRole('button'));

  expect(handleClick).toHaveBeenCalledTimes(1);
});
```

## Async Testing

### Waiting for Elements

```typescript
import { render, screen, waitFor } from '@testing-library/react';

test('loads and displays user data', async () => {
  render(<UserProfile userId="123" />);

  // Wait for element to appear
  const name = await screen.findByText('John Doe');
  expect(name).toBeInTheDocument();
});

test('shows error message on failure', async () => {
  render(<UserProfile userId="invalid" />);

  // Wait for condition
  await waitFor(() => {
    expect(screen.getByRole('alert')).toHaveTextContent('Failed to load');
  });
});
```

### Async State Updates

```typescript
test('updates state after API call', async () => {
  const user = userEvent.setup();
  render(<AsyncComponent />);

  await user.click(screen.getByRole('button', { name: /load/i }));

  await waitFor(() => {
    expect(screen.getByText('Loaded')).toBeInTheDocument();
  });
});
```

## Mocking

### Mocking API Calls

```typescript
import { render, screen } from '@testing-library/react';
import { rest } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  rest.get('/api/user/:id', (req, res, ctx) => {
    return res(ctx.json({ id: '1', name: 'John Doe' }));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test('loads user data', async () => {
  render(<UserProfile userId="1" />);

  expect(await screen.findByText('John Doe')).toBeInTheDocument();
});
```

### Mocking Modules

```typescript
// Mock entire module
jest.mock('./api', () => ({
  getUser: jest.fn(),
}));

import { getUser } from './api';

test('handles API error', async () => {
  (getUser as jest.Mock).mockRejectedValue(new Error('Network error'));

  render(<UserProfile userId="1" />);

  expect(await screen.findByText('Failed to load')).toBeInTheDocument();
});
```

## Testing Hooks

### Custom Hook Testing

```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { useUser } from './useUser';

test('loads user data', async () => {
  const { result } = renderHook(() => useUser('123'));

  expect(result.current.loading).toBe(true);

  await waitFor(() => {
    expect(result.current.loading).toBe(false);
  });

  expect(result.current.user).toEqual({ id: '123', name: 'John' });
});
```

### Hook with Props Update

```typescript
test('refetches on id change', async () => {
  const { result, rerender } = renderHook(
    ({ id }) => useUser(id),
    { initialProps: { id: '123' } }
  );

  await waitFor(() => expect(result.current.loading).toBe(false));
  expect(result.current.user?.id).toBe('123');

  // Update props
  rerender({ id: '456' });

  await waitFor(() => expect(result.current.loading).toBe(false));
  expect(result.current.user?.id).toBe('456');
});
```

## Testing Context

### With Provider

```typescript
import { render, screen } from '@testing-library/react';
import { ThemeProvider } from './ThemeContext';

function renderWithTheme(ui: React.ReactElement, theme = 'light') {
  return render(
    <ThemeProvider value={theme}>
      {ui}
    </ThemeProvider>
  );
}

test('renders with theme', () => {
  renderWithTheme(<ThemedButton />, 'dark');
  expect(screen.getByRole('button')).toHaveClass('dark-theme');
});
```

### Custom Render Helper

```typescript
import { render, RenderOptions } from '@testing-library/react';
import { Provider } from 'react-redux';
import { BrowserRouter } from 'react-router-dom';

function customRender(
  ui: React.ReactElement,
  {
    store = createTestStore(),
    ...renderOptions
  }: CustomRenderOptions = {}
) {
  function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <Provider store={store}>
        <BrowserRouter>
          {children}
        </BrowserRouter>
      </Provider>
    );
  }

  return render(ui, { wrapper: Wrapper, ...renderOptions });
}

// Re-export everything
export * from '@testing-library/react';
export { customRender as render };
```

## Snapshot Testing

### Component Snapshots

```typescript
import { render } from '@testing-library/react';

test('matches snapshot', () => {
  const { container } = render(<Button variant="primary">Click</Button>);
  expect(container.firstChild).toMatchSnapshot();
});
```

### When to Use Snapshots

**Good for:**
- Static UI components
- Preventing unintended visual changes
- Complex markup structures

**Avoid for:**
- Dynamic content (timestamps, IDs)
- Components with many props
- Replacing proper assertions

## Accessibility Testing

### jest-axe Integration

```typescript
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

test('has no accessibility violations', async () => {
  const { container } = render(<LoginForm />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

## Best Practices

### Do

- Test user behavior, not implementation
- Use accessible queries (role, label)
- Test error states and edge cases
- Keep tests simple and focused
- Use `userEvent` over `fireEvent`

### Don't

- Test implementation details
- Query by class names or IDs
- Assert on component state directly
- Create overly complex test setup
- Use `act()` directly (RTL handles it)

## Common Patterns

### Testing Lists

```typescript
test('renders list of items', () => {
  render(<TodoList todos={mockTodos} />);

  const items = screen.getAllByRole('listitem');
  expect(items).toHaveLength(3);
  expect(items[0]).toHaveTextContent('Buy milk');
});
```

### Testing Conditional Rendering

```typescript
test('shows loading state', () => {
  render(<UserProfile loading={true} />);
  expect(screen.getByText('Loading...')).toBeInTheDocument();
});

test('shows error state', () => {
  render(<UserProfile error="Failed to load" />);
  expect(screen.getByRole('alert')).toHaveTextContent('Failed to load');
});
```

### Testing Debounced Input

```typescript
test('debounces search input', async () => {
  const user = userEvent.setup();
  const onSearch = jest.fn();
  render(<SearchInput onSearch={onSearch} />);

  const input = screen.getByRole('textbox');
  await user.type(input, 'test');

  // Wait for debounce
  await waitFor(() => {
    expect(onSearch).toHaveBeenCalledWith('test');
  }, { timeout: 1000 });
});
```

## See Also

- Main skill: `react-patterns/SKILL.md`
- Testing strategies: `Skill: testing-strategies`
- Hooks: `hooks.md`
