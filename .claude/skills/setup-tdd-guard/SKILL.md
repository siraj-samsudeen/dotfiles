---
name: setup-tdd-guard
description: Set up TDD Guard with Vitest to enforce test-first development. Blocks implementation code until tests exist.
---

# Set Up TDD Guard

## Overview

TDD Guard is a Claude Code hook that prevents writing implementation code until tests exist. It uses a Vitest reporter to track test state and blocks Edit/Write tools on non-test files when tests are failing or missing.

## When to Use

- New projects where you want to enforce TDD
- Projects with Vitest already configured (or willing to add it)
- When you want Claude to follow strict test-first discipline

## Git Workflow

**Before starting:**
```bash
git status  # Must be clean (no uncommitted changes)
```

**After completing all steps:**
```bash
git add -A
git commit -m "Set up TDD Guard with Vitest"
```

This ensures setup changes are atomic and reversible.

## Prerequisites

- Node.js project with `package.json`
- Vitest (will be installed if missing)

## Installation Steps

### 1. Install Dependencies

```bash
npm install -D vitest jsdom @testing-library/react @testing-library/jest-dom tdd-guard-vitest
```

### 2. Create vitest.config.ts

```typescript
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import path from "path";
import { VitestReporter } from "tdd-guard-vitest";

export default defineConfig({
  plugins: [react()],
  test: {
    environment: "jsdom",
    globals: true,
    reporters: ["default", new VitestReporter(__dirname)],
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

**Key parts:**
- `VitestReporter(__dirname)` - Reports test state to `.claude/tdd-guard/data/test.json`
- `globals: true` - Enables `describe`, `it`, `expect` without imports
- `setupFiles` - For jest-dom matchers
- `coverage.thresholds` - **Fails tests if coverage drops below 100%**
- `coverage.exclude` - Ignores test files, config, and generated code

### 3. Create Test Setup File

Create `src/test/setup.ts`:

```typescript
import "@testing-library/jest-dom/vitest";
```

### 4. Install Coverage Support

```bash
npm install -D @vitest/coverage-v8
```

### 5. Add npm Scripts

In `package.json`:

```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage"
  }
}
```

### 6. Add coverage to .gitignore

```
coverage/
```

### 7. Create Claude Hook

Create `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit|TodoWrite",
        "hooks": [
          {
            "type": "command",
            "command": "tdd-guard"
          }
        ]
      }
    ]
  }
}
```

### 8. Restart Claude Code Session

The hook only loads on session start. Run `/clear` or exit and reopen.

## How It Works

1. **VitestReporter** writes test state to `.claude/tdd-guard/data/test.json`
2. **PreToolUse hook** runs `tdd-guard` CLI before any Write/Edit
3. **tdd-guard** checks:
   - Is the file a test file? Allow.
   - Are tests passing? Allow.
   - Otherwise? Block with message.

## Verification

After setup, try asking Claude to implement something:

```
User: "add a priority field to todos"
```

Claude should be blocked until tests for the priority field exist and are failing (RED state).

## File Structure After Setup

```
project/
├── .claude/
│   ├── settings.json          # Hook configuration
│   └── tdd-guard/
│       └── data/
│           └── test.json      # Test state (auto-generated)
├── src/
│   └── test/
│       └── setup.ts           # Jest-dom matchers
├── vitest.config.ts           # Vitest + TDD Guard reporter
└── package.json               # Test scripts
```

## Troubleshooting

### Hook not working
- Restart Claude Code session after creating `.claude/settings.json`
- Verify `tdd-guard` is in PATH: `npx tdd-guard --help`

### Tests not being tracked
- Run `npm test` at least once to generate test.json
- Check `.claude/tdd-guard/data/test.json` exists

### Wrong environment errors
- Ensure `environment: "jsdom"` for React component tests
- Use `environmentMatchGlobs` for different test types (see Convex testing skill)
