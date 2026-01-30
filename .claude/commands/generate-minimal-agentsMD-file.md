---
description: Generate a minimal AGENTS.md file that only includes what AI actually needs
---

# Generate Minimal AGENTS.md

Create a minimal AGENTS.md file for this project. Only include what I actually need in my context window.

## The Test

Before including anything, ask: "Can I discover this with `ls` or `Glob` in 1 second?"
If yes → don't include it.

## What to INCLUDE

1. **What is this?** - One sentence: purpose + who it's for
2. **Stack** - Only unusual combos or key architectural decisions (e.g., "offline-first")
3. **Structure** - Top-level folders + any non-obvious organization patterns
   - Good: "components organized by domain: ui/, clients/, tasks/"
   - Bad: listing every file in every folder

## What to OMIT

- Standard commands (npm run start/build/test) → I know these
- Universal conventions (PascalCase, camelCase) → I know these
- File listings → I'll Glob when needed
- Explanations of standard tools → I know React, TypeScript, etc.
- Detailed tree structures → I can `ls` the folder

## Template

```markdown
# [Project Name]

[One sentence: what is this and who is it for?]

## Stack
[Tech + any key architectural decisions like "offline-first" or "monorepo"]

## Structure
src/folder/     - what's in it, note any non-obvious organization
src/other/      - brief description
```

## Example Output

```markdown
# TaskFlow

Todo/project management app for a 2-person dev team managing tasks across clients.

## Stack
Expo (React Native) + Supabase + PowerSync (offline-first sync)

## Structure
src/app/        - Expo Router screens (auth, tabs, clients, projects)
src/components/ - organized by domain: ui/, clients/, projects/, tasks/
src/lib/        - supabase.ts, powersync.ts, schema.ts
src/hooks/      - useAuth, useClients, useProjects, useTasks
```

Target: Under 15 lines. If I can discover it in 1 second, don't tell me.
