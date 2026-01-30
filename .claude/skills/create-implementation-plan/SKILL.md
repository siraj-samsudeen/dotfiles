---
name: create-implementation-plan
description: Create implementation plans from specs. Use when you have approved specs and need to plan implementation. Outputs implementation-plan.md.
---

# Create Implementation Plan

## Overview

Create implementation plans that reference approved specs. Plans describe WHAT to build in behavioral terms. The executing agent discovers HOW. **Outputs: `docs/specs/<feature>/implementation-plan.md`**

**Core principle:** Plans specify behavior and verification, not code.

**Announce at start:** "I'm using create-implementation-plan to create the implementation plan."

**Prerequisites:**
- Approved spec in `docs/specs/<feature>/spec.md`
- Design review passed (if design.md exists)

**Save plans to:** `docs/specs/<feature>/implementation-plan.md`

## What Plans Should NOT Contain

| Don't Include | Why |
|---------------|-----|
| Full code implementations | Agent should write fresh, TDD-style |
| Specific function signatures | Discovered during implementation |
| Import statements | Discovered during implementation |
| Line-by-line instructions | Over-constrains the solution |

## What Plans SHOULD Contain

| Include | Why |
|---------|-----|
| Spec reference | Single source of truth |
| Acceptance criteria (from spec) | Defines "done" |
| Task breakdown | Manageable chunks |
| Test strategy | What proves each task works |
| File locations | Where to look/create |
| Dependencies between tasks | Execution order |

## Plan Document Structure

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** Use superpowers:executing-plans to implement this plan.

**Spec:** `docs/specs/<feature>/spec.md`

**Goal:** [One sentence from spec]

**Approach:** [2-3 sentences on implementation strategy]

---

## Tasks

### Task 1: [Behavioral Description]

**Implements:** [Which acceptance criteria from spec]

**Files:**
- Test: `tests/path/to/test.ts`
- Implementation: `src/path/to/file.ts`

**Acceptance:**
- [ ] Test exists that verifies [WHEN X THE SYSTEM SHALL Y]
- [ ] Test fails before implementation (TDD red)
- [ ] Implementation makes test pass (TDD green)
- [ ] Manual verification: [specific check if applicable]

**Depends on:** None | Task N

---

### Task 2: [Behavioral Description]

...
```

## Task Granularity

Each task should:
- Implement ONE acceptance criterion (or closely related set)
- Be completable in one session
- Have clear pass/fail verification
- Be independently testable

**Too big:** "Implement task CRUD"
**Right size:** "Implement create task with required fields"

## Deriving Tasks from Specs

Map spec sections to tasks:

| Spec Section | Becomes |
|--------------|---------|
| Each WHEN clause | One task (or grouped if trivial) |
| Each IF/THEN clause | Error handling task |
| Business Validation rules | Validation task |
| Permissions section | Auth task |
| Data Model | Schema/migration task (first) |

**Example mapping:**

```
Spec says:
  WHEN user creates task THE SYSTEM SHALL save task with status "todo"
  WHEN user creates task without title THE SYSTEM SHALL reject with error

Tasks:
  Task 1: Create task with valid data → saves with status "todo"
  Task 2: Create task validation → rejects missing title
```

## Test Strategy Section

Every plan must include:

```markdown
## Test Strategy

**Unit tests:** [What isolated logic to test]

**Integration tests:** [What cross-component flows to verify]
- [ ] [Specific flow from spec, e.g., "Create task appears in task list"]

**Manual verification:** [What to check visually/interactively]
- [ ] [Specific check, e.g., "New task shows in UI after creation"]
```

This prevents "tests pass but feature broken" by requiring multiple verification layers.

## Verification Checklist (for the plan itself)

Before marking plan complete:

- [ ] Every acceptance criterion in spec has a task
- [ ] Every task references which spec criteria it implements
- [ ] Every task has testable acceptance conditions
- [ ] Integration tests are specified (not just unit tests)
- [ ] Manual verification steps included where applicable
- [ ] No code is embedded in the plan
- [ ] Dependencies between tasks are explicit

## Anti-Patterns

| Don't | Do |
|-------|-----|
| Embed 2600 lines of code | Reference spec, describe behavior |
| "Implement the backend" | "Create task saves with status 'todo'" |
| Assume tests = verification | Require integration + manual checks |
| Skip spec reference | Always link to source of truth |
| Copy spec into plan | Reference spec, don't duplicate |

## Execution Handoff

After saving the plan:

**"Plan complete and saved to `docs/plans/<filename>.md`.**

**Before execution:**
1. Run `derive-tests-from-spec` to generate test cases from acceptance criteria
2. Choose execution approach:
   - **Subagent-Driven (this session)** - Fresh agent per task, review between
   - **Parallel Session (separate)** - Batch execution with checkpoints

**Which approach?"**

## Relationship to Other Skills

```
create-spec          →  create-implementation-plan  →  derive-tests-from-spec  →  execute
(spec.md)               (implementation-plan.md)        (how to verify)           (build it)
```

The plan is a bridge between spec and execution. It organizes work without dictating implementation.
