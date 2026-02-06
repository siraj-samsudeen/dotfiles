---
name: setup-convex-testing
description: Set up integration testing for React + Convex + Vite projects. Enables testing React components with real Convex backend function execution.
---

# Set Up Convex Testing for React + Vite

## Overview

This skill sets up **complete testing infrastructure** for Convex projects:

1. **Integration tests** - React components with real Convex backend execution via [convex-test-provider](https://www.npmjs.com/package/convex-test-provider)
2. **Coverage** - 100% coverage target with `@vitest/coverage-v8`
3. **MECE tests** - No redundant tests, each test covers a distinct state

> **TDD enforcement:** Use `/feather:setup-tdd-guard` to add TDD Guard hooks and pre-commit coverage checks.

The goal is **Phoenix LiveView-style tests** where one test exercises both UI and backend simultaneously.

## When to Use

- New React + Convex + Vite projects
- When you want integration tests (not just mocked UI tests)
- When starting TDD with full coverage

## Git Workflow

**Before starting:**
```bash
git status  # Must be clean (no uncommitted changes)
```

**After completing all steps:**
```bash
git add -A
git commit -m "Set up Convex testing infrastructure"
```

This ensures setup changes are atomic and reversible.

---

## Official Convex Testing Architecture

The [official Convex testing guide](https://stack.convex.dev/testing-react-components-with-convex) recommends a 3-layer architecture:

```
Layer 3: Real Integration Tests (Vitest + jsdom + real local Convex backend)
         ↑ Covers the seam between React and Convex — zero mocking
         ↑ Slower, requires running local backend binary

Layer 2: Thin React Component Tests (Vitest + jsdom + vi.mock("convex/react"))
         ↑ Covers rendering logic, user interactions, loading/error states
         ↑ Fast, one mock boundary (convex/react hooks only)

Layer 1: Backend Function Tests (Vitest + convex-test)
         ↑ Covers all Convex functions — queries, mutations, actions, auth
         ↑ Fast, no mocking (convex-test simulates the backend in JS)
```

**Recommended distribution:**
- Layer 1: ~60-70% of tests (fast, covers all backend logic)
- Layer 2: ~20-30% of tests (covers all UI states and interactions)
- Layer 3: ~5-10% of tests (covers critical happy paths end-to-end)

### The Gap We Solve

There's no official way to connect `convex-test` (Layer 1) directly to React's `useQuery` hook. The options are:

| Approach | Pros | Cons |
|----------|------|------|
| Layer 3 (real local backend) | Zero mocking, full stack | Requires running backend binary, slower |
| Layer 2 (mock convex/react) | Fast, simple | Doesn't test real backend functions |
| **Our approach ([convex-test-provider](https://www.npmjs.com/package/convex-test-provider))** | Tests real functions + React together, npm package | Queries run once per mount (no live subscriptions) |

**[convex-test-provider](https://www.npmjs.com/package/convex-test-provider) creates a "Layer 2.5"** - using convex-test's in-memory DB connected to React without running a local backend. This was originally a custom `ConvexTestProvider` built in this skill, now published as an npm package.

---

## Discovery: Approaches We Investigated

### Approach 1: `t.convexClient` (Does NOT Exist)

Some examples online suggest:

```tsx
// THIS DOES NOT WORK - convexClient doesn't exist
const t = convexTest(schema);
render(
  <ConvexProvider client={t.convexClient}>
    <TodoList />
  </ConvexProvider>
);
```

**Reality check:** `convex-test@0.0.41` returns these properties:

```
['withIdentity', 'query', 'mutation', 'action', 'queryFromPath',
 'mutationFromPath', 'actionFromPath', 'runInComponent', 'run',
 'fun', 'fetch', 'finishInProgressScheduledFunctions',
 'finishAllScheduledFunctions', 'registerComponent']

Has convexClient? false
```

### Approach 2: ConvexReactClientFake (convex-helpers)

The `convex-helpers` package has a `fakeConvexClient` but:
- Not designed for convex-test integration
- Requires manually implementing each query/mutation
- Doesn't execute real backend functions

### Approach 3: convex-test-provider ✅

We built a minimal bridge that wraps `convex-test` in a fake client compatible with `ConvexProvider`. This was originally a custom `ConvexTestProvider` in this skill, now published as **[convex-test-provider](https://www.npmjs.com/package/convex-test-provider)** on npm.

**This is what we use.**

---

## Installation Steps

### 1. Install Dependencies

```bash
npm install -D convex-test convex-test-provider @edge-runtime/vm @vitest/coverage-v8
```

### 2. Update vitest.config.ts

```typescript
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  test: {
    environment: "jsdom",
    environmentMatchGlobs: [
      ["convex/**", "edge-runtime"],  // Convex files need edge-runtime
    ],
    server: { deps: { inline: ["convex-test"] } },  // Required for convex-test
    globals: true,
    setupFiles: ["./src/test/setup.ts"],
    coverage: {
      provider: "v8",
      reporter: ["text", "json", "html"],
      exclude: [
        "node_modules/",
        "src/test/",
        "**/*.test.{ts,tsx}",
        "**/*.config.{ts,js}",
        "convex/_generated/",
      ],
      thresholds: {
        lines: 100,
        branches: 100,
        functions: 100,
        statements: 100,
      },
    },
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
```

**Key additions:**
- `environmentMatchGlobs` - Uses `edge-runtime` for `convex/**` files, `jsdom` for everything else
- `server.deps.inline` - Required for `convex-test` to work properly
- `coverage.thresholds` - **Fails tests if coverage drops below 100%**
- `coverage.exclude` - Ignores test files, config, and generated code

### 3. Create Convex Test Setup

Create `convex/test.setup.ts`:

```typescript
/// <reference types="vite/client" />
import { createConvexTest, renderWithConvex } from "convex-test-provider";
import schema from "./schema";

export const modules = import.meta.glob("./**/!(*.*.*)*.*s");
export const test = createConvexTest(schema, modules);
export { renderWithConvex };
```

**What this gives you:**

| Export | Purpose |
|--------|---------|
| `modules` | Module discovery for convex-test |
| `test` | Custom Vitest `test` function with fixtures (`client`, `userId`, `seed`, `createUser`) |
| `renderWithConvex` | Testing Library render wrapped with `ConvexTestProvider` |

**Available test fixtures:**

| Fixture | Description |
|---------|-------------|
| `testClient` | Raw convex-test client (unauthenticated) |
| `userId` | Current user's ID (user auto-created) |
| `client` | Authenticated client for the current user |
| `seed(table, data)` | Insert data, auto-fills `userId` field |
| `createUser()` | Create another authenticated user |

**Query behavior:**
- Queries execute **once** when the component mounts
- UI does not re-render after a mutation in the same test
- Assert backend state via `client.query()`, or re-mount to query again

---

## Test Patterns

### Integration Tests (React + Convex) — Primary Approach

`src/components/TodoList.integration.test.tsx`:

```tsx
import { screen } from "@testing-library/react";
import { describe, expect } from "vitest";
import { test, renderWithConvex } from "../../convex/test.setup";
import { TodoList } from "./TodoList";

describe("TodoList (integration)", () => {
  test("shows empty state when no todos exist", async ({ client }) => {
    renderWithConvex(<TodoList />, client);

    // Wait for query to resolve
    expect(await screen.findByText("No todos yet")).toBeInTheDocument();
  });

  test("renders todos from real backend in correct order", async ({ client, seed }) => {
    // Seed data via convex-test
    await seed("todos", { text: "First todo", completed: false });
    await seed("todos", { text: "Second todo", completed: true });

    renderWithConvex(<TodoList />, client);

    // Wait for real query to resolve and render
    expect(await screen.findByText("Second todo")).toBeInTheDocument();
    expect(screen.getByText("First todo")).toBeInTheDocument();

    // Verify newest first (Second was inserted after First)
    const items = screen.getAllByRole("listitem");
    expect(items[0]).toHaveTextContent("Second todo");
    expect(items[1]).toHaveTextContent("First todo");
  });
});
```

### Multi-user Tests

```tsx
import { describe, expect } from "vitest";
import { test } from "../../convex/test.setup";
import { api } from "../../convex/_generated/api";

describe("Access control", () => {
  test("users only see their own todos", async ({ client, createUser }) => {
    // Alice creates a todo
    await client.mutation(api.todos.create, { text: "Alice's todo" });

    // Bob can't see Alice's todo
    const bob = await createUser();
    const bobTodos = await bob.query(api.todos.list, {});
    expect(bobTodos).toHaveLength(0);
  });
});
```

### Unit Tests (Mocked) — For Transient States Only

`src/components/TodoList.test.tsx`:

```tsx
/**
 * Unit Test for TodoList - Loading State Only
 *
 * Loading state requires mocking since it's a transient state.
 * All other tests are integration tests.
 */

import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { TodoList } from "./TodoList";

vi.mock("convex/react", () => ({
  useQuery: vi.fn(),
}));

import { useQuery } from "convex/react";

describe("TodoList (loading state)", () => {
  it("shows loading state while query is pending", () => {
    vi.mocked(useQuery).mockReturnValue(undefined);

    render(<TodoList />);

    expect(screen.getByText("Loading...")).toBeInTheDocument();
  });
});
```

### Backend Tests (Layer 1) — For Complex Logic

Only needed for complex business logic that's easier to test in isolation:

```typescript
// convex/todos.test.ts
import { convexTest } from "convex-test";
import { describe, expect, it } from "vitest";
import schema from "./schema";
import { api } from "./_generated/api";
import { modules } from "./test.setup";

describe("todos.list", () => {
  it("returns empty array when no todos exist", async () => {
    const t = convexTest(schema, modules);
    const todos = await t.query(api.todos.list);
    expect(todos).toEqual([]);
  });

  it("returns todos in descending order (newest first)", async () => {
    const t = convexTest(schema, modules);

    await t.run(async (ctx) => {
      await ctx.db.insert("todos", { text: "First", completed: false });
    });
    await t.run(async (ctx) => {
      await ctx.db.insert("todos", { text: "Second", completed: false });
    });

    const todos = await t.query(api.todos.list);
    expect(todos[0].text).toBe("Second");
    expect(todos[1].text).toBe("First");
  });
});
```

> **Discovery: Backend tests are often redundant!**
>
> Integration tests execute real Convex functions via `ConvexTestProvider`. Running coverage without backend tests still shows **100% coverage** on `convex/todos.ts`.
>
> **Recommendation:** Skip separate backend tests for simple functions. Integration tests give coverage on both UI and backend. Only write backend-only tests for complex business logic.

---

## Test Strategy Decision Guide

| What you're testing | Layer | Approach |
|---------------------|-------|----------|
| Query returns correct data | Integration | ConvexTestProvider + real function |
| Component shows loading spinner | Mock | `vi.mock("convex/react")` |
| Component shows empty state | Integration | Real query returns `[]` |
| Component shows error state | Mock | Mock rejected promise |
| Data ordering/filtering | Integration | Seed data, verify render order |
| Business rules / calculations | Backend | convex-test directly |
| Auth rules (who can see what) | Backend | `t.withIdentity()` |

**Rule of thumb:** Use integration tests by default. Use mocks only for states you can't reliably produce (loading, errors).

---

## MECE Test Design

Tests should be **MECE**: Mutually Exclusive, Collectively Exhaustive.

### Example: TodoList Component

The component has 3 possible states:

```tsx
function TodoList() {
  const todos = useQuery(api.todos.list);

  if (todos === undefined) return <div>Loading...</div>;      // State 1
  if (todos.length === 0) return <div>No todos yet</div>;     // State 2
  return <ul>{todos.map(...)}</ul>;                           // State 3
}
```

**MECE test matrix:**

| Test | State | Approach |
|------|-------|----------|
| Loading | `undefined` | Mock |
| Empty | `[]` | Integration |
| Render + Order | `[...items]` | Integration |

**3 tests = 100% coverage, no redundancy.**

### Anti-pattern: Overlapping Tests

```typescript
// BAD: These tests overlap
it("returns empty array", ...)           // Backend test
it("shows empty state", ...)             // Integration test - ALSO tests empty array!
```

---

## Data Seeding Patterns

### Via `seed` fixture (Recommended — auto-fills userId)

```tsx
test("with seeded data", async ({ seed }) => {
  await seed("todos", { text: "Test todo", completed: false });
});
```

### Via Mutations (Tests more of the stack)

```tsx
test("via mutation", async ({ client }) => {
  await client.mutation(api.todos.create, { text: "Test todo" });
});
```

### Direct DB Insert (Low-level, when you need full control)

```tsx
test("direct insert", async ({ testClient }) => {
  await testClient.run(async (ctx) => {
    await ctx.db.insert("todos", { text: "Test todo", completed: false });
  });
});
```

### Multi-user Scenarios

```tsx
test("multi-user", async ({ client, createUser }) => {
  await client.mutation(api.todos.create, { text: "Alice's todo" });

  const bob = await createUser();
  const bobTodos = await bob.query(api.todos.list, {});
  expect(bobTodos).toHaveLength(0);
});
```

---

## Coverage Setup

### Add npm script

```json
{
  "scripts": {
    "test": "vitest",
    "test:coverage": "vitest run --coverage"
  }
}
```

### Add to .gitignore

```
coverage/
```

### Verify coverage

```bash
npm run test:coverage
```

Target: **100% coverage** on production files.

> **Pre-commit enforcement:** Use `/feather:setup-tdd-guard` to add a pre-commit hook that blocks commits when coverage < 100%.

---

## File Structure

```
project/
├── convex/
│   ├── test.setup.ts          # Module discovery + createConvexTest helpers
│   └── todos.ts               # Convex functions
├── src/
│   ├── components/
│   │   ├── TodoList.tsx
│   │   ├── TodoList.test.tsx              # Mock test (loading state only)
│   │   └── TodoList.integration.test.tsx  # Integration tests
│   └── test/
│       └── setup.ts                # Jest-dom matchers
├── vitest.config.ts
└── package.json
```

---

## Alternative: Layer 3 (Real Local Backend)

If you need to test mutations, actions, or real-time updates, use a real local backend:

### Prerequisites
1. Install Convex CLI: `npm install -g convex`
2. Start local backend: `npx convex backend start`
3. Create a `clearAll` mutation for test cleanup

### Integration Test with Real Backend

```tsx
// src/components/TodoList.e2e.test.tsx
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { ConvexProvider, ConvexReactClient } from "convex/react";
import { ConvexClient } from "convex/browser";
import { describe, test, expect, beforeEach, afterEach } from "vitest";
import { api } from "../../convex/_generated/api";
import TodoList from "./TodoList";

const BACKEND_URL = "http://127.0.0.1:3210";

let reactClient: ConvexReactClient;
let adminClient: ConvexClient;

beforeEach(() => {
  reactClient = new ConvexReactClient(BACKEND_URL);
  adminClient = new ConvexClient(BACKEND_URL);
});

afterEach(async () => {
  await adminClient.mutation(api.testing.clearAll, {});
  await adminClient.close();
  await reactClient.close();
});

test("adding a todo via UI appears in the list", async () => {
  render(
    <ConvexProvider client={reactClient}>
      <TodoList />
    </ConvexProvider>
  );

  // Wait for initial load
  await waitFor(() => {
    expect(screen.getByText(/no todos/i)).toBeTruthy();
  });

  // Interact with real component
  const input = screen.getByPlaceholderText(/add/i);
  await userEvent.type(input, "New todo");
  await userEvent.keyboard("{Enter}");

  // Real mutation fires, backend processes, subscription updates
  await waitFor(() => {
    expect(screen.getByText("New todo")).toBeTruthy();
  });
});
```

**Tradeoffs vs ConvexTestProvider:**
- ✅ Full stack testing including mutations
- ✅ Real WebSocket subscriptions
- ❌ Requires running local backend
- ❌ Slower tests
- ❌ More complex CI setup

---

## Troubleshooting

### "Cannot find module 'convex-test'"
- Add to vitest.config.ts: `server: { deps: { inline: ["convex-test"] } }`

### Convex functions fail in tests
- Ensure `environmentMatchGlobs: [["convex/**", "edge-runtime"]]`

### Tests hang or timeout
- Use `await screen.findByText()` not `screen.getByText()` for async
- Check that `ConvexTestProvider` query promise resolves

### "modules" import error
- Ensure `convex/test.setup.ts` exists with the glob pattern

---

## References

- [convex-test-provider (npm)](https://www.npmjs.com/package/convex-test-provider) — The provider package used in this skill
- [convex-test-provider (GitHub)](https://github.com/siraj-samsudeen/convex-test-provider) — Source and contributing guide
- [Convex Testing Docs](https://docs.convex.dev/testing)
- [convex-test Library](https://docs.convex.dev/testing/convex-test)
- [Testing React Components with Convex (blog)](https://stack.convex.dev/testing-react-components-with-convex)
- [Local Backend Testing](https://docs.convex.dev/testing/convex-backend)
