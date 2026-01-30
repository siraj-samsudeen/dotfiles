---
name: derive-tests-from-spec
description: Expand feather-spec into Gherkin scenarios (including edge cases) for user review before implementation. Groups match spec IDs. Creates checkpoint for scenario approval.
---

# Derive Tests From Spec

## Overview

Expand lightweight feather-spec requirements into complete Gherkin scenarios. This is where edge cases are added. User reviews scenarios before implementation begins.

**Core principle:** Feather-spec is light (client sign-off). This skill expands it to full test coverage.

**Announce at start:** "I'm using derive-tests-from-spec to generate Gherkin scenarios for review."

## The Problem This Solves

Feather-spec intentionally excludes edge cases to keep it light. But implementation needs complete coverage. This skill bridges the gap:

```
feather-spec (light)  →  derive-tests-from-spec  →  Full Gherkin (complete)
    4 requirements           (THIS SKILL)            12 scenarios
    client signs off                                 you review
```

## Process

### Step 1: Read the Feather-Spec

Identify:
- Requirement groups (QT-1, QT-2, etc.)
- EARS statements in each group
- Data model constraints
- Out of scope items

### Step 2: Expand Each Group to Gherkin

For each requirement group:

1. **Happy path scenarios** - Direct translation of EARS
2. **Edge case scenarios** - What wasn't in the spec but needs testing
3. **Error scenarios** - What happens when things go wrong

### Step 3: Present for Review (Checkpoint)

User reviews all Gherkin scenarios before implementation. This is **Checkpoint: Gherkin Review**.

## EARS → Gherkin Expansion

### WHEN (Event-Driven) → Happy Path + Edge Cases

**Spec (light):**
```
WHEN I type and press Enter, THE SYSTEM SHALL create a task
```

**Gherkin (expanded):**
```gherkin
# Happy path (from spec)
Scenario: Create task quickly
  When I type "Buy groceries" and press Enter
  Then "Buy groceries" appears in my task list

# Edge cases (added by this skill)
Scenario: Empty input is ignored
  When I press Enter with nothing typed
  Then no task is created

Scenario: Whitespace-only input is ignored
  When I type "   " and press Enter
  Then no task is created

Scenario: Input clears after creation
  When I create a task
  Then the input field is empty
```

### IF/THEN (Error Cases) → Error Scenarios

**Spec:**
```
IF task title exceeds 500 characters THEN THE SYSTEM SHALL show error
```

**Gherkin:**
```gherkin
Scenario: Title too long shows error
  When I type a 501-character title
  Then I see "Title must be 500 characters or less"
  And no task is created
```

### WHILE (State-Driven) → State Scenarios

**Spec:**
```
WHILE task is in progress THE SYSTEM SHALL show timer
```

**Gherkin:**
```gherkin
Scenario: Timer shows for in-progress tasks
  Given a task with status "in progress"
  Then I see a timer on that task

Scenario: Timer hidden for other statuses
  Given a task with status "todo"
  Then I do not see a timer on that task
```

## Output Format

Generate grouped Gherkin that matches spec structure:

```markdown
# Gherkin Scenarios: [Feature Name]

**Spec:** `docs/specs/[feature].md`

---

## QT-1: Quick Task Creation

### From Spec (Happy Path)

```gherkin
Scenario: Create task quickly
  When I type "Buy groceries" and press Enter
  Then "Buy groceries" appears in my task list
```

### Edge Cases (Added)

```gherkin
Scenario: Empty input is ignored
  When I press Enter with nothing typed
  Then no task is created

Scenario: Whitespace-only input is ignored
  When I type "   " and press Enter
  Then no task is created

Scenario: Input clears after creation
  When I create a task
  Then the input field is empty
```

---

## QT-2: Quick Task Visibility

### From Spec (Happy Path)

```gherkin
Scenario: Quick tasks are private by default
  When I create a quick task
  Then only I can see it

Scenario: Assigning to teammate shares the task
  Given I have a private quick task
  When I assign it to Alice
  Then Alice can see it
```

### Edge Cases (Added)

```gherkin
Scenario: Unassigning returns to private
  Given I assigned my task to Alice
  When I remove the assignee
  Then only I can see it again
```

---

## QT-3: Project Task

### From Spec (Happy Path)

```gherkin
Scenario: Project tasks are team-visible
  Given I am in project "Website Redesign"
  When I create a task "Update homepage"
  Then my teammates can see it
```

### Edge Cases (Added)

```gherkin
Scenario: Moving task to project makes it shared
  Given I have a private quick task
  When I move it to project "Website Redesign"
  Then my teammates can see it
```

---

## Summary

| Group | From Spec | Edge Cases | Total |
|-------|-----------|------------|-------|
| QT-1 | 1 | 3 | 4 |
| QT-2 | 2 | 1 | 3 |
| QT-3 | 1 | 1 | 2 |
| **Total** | **4** | **5** | **9** |

---

## Checkpoint: Gherkin Review

Please review these scenarios before implementation:

- [ ] Happy path scenarios match your intent?
- [ ] Edge cases are worth testing?
- [ ] Any scenarios to add?
- [ ] Any scenarios to remove?

**Your response:** "Approved" / "Add: [scenario]" / "Remove: [scenario]" / "Change: [scenario]"
```

## Edge Case Categories

When expanding, consider these categories:

### Input Edge Cases
- Empty input
- Whitespace-only input
- Very long input
- Special characters
- Unicode/emoji

### State Edge Cases
- Already in target state
- Conflicting states
- Rapid state changes

### Boundary Edge Cases
- First item
- Last item
- Only item
- Maximum items
- Zero items

### Permission Edge Cases
- Own vs. others' items
- Shared vs. private
- Role-based access

### Timing Edge Cases
- Concurrent modifications
- Stale data
- Offline/reconnect

## What NOT to Add

Don't add scenarios for:
- Implementation details (internal state management)
- Technical edge cases user wouldn't encounter
- Scenarios covered by framework (auth, CSRF, etc.)
- Duplicate coverage across groups

## Test Level Mapping

After Gherkin is approved, map to test levels:

| Scenario Type | Test Level |
|---------------|------------|
| Happy path | E2E (Playwright) |
| User-visible edge cases | E2E or Integration |
| Technical edge cases | Unit test |

```markdown
## Test Level Mapping

| Scenario | Level | File |
|----------|-------|------|
| Create task quickly | E2E | e2e/quick-task.spec.ts |
| Empty input ignored | Unit | unit/inline-task-form.test.ts |
| Private by default | E2E | e2e/quick-task.spec.ts |
```

## Checkpoint Gate

**Do NOT proceed to implementation until user approves Gherkin scenarios.**

This checkpoint ensures:
1. All user-expressed requirements have scenarios
2. Edge cases are appropriate (not over-tested)
3. User understands what will be tested
4. Traceability from spec → scenarios → tests

## Relationship to Other Skills

```
feather-spec (light)
     ↓
review-design (Checkpoint 1: artifacts)
     ↓
derive-tests-from-spec (THIS SKILL)
     ↓
Checkpoint: Gherkin Review ← USER APPROVES HERE
     ↓
write-plan-from-spec (implementation plan)
     ↓
Implementation (TDD from Gherkin)
```

## Traceability

All scenarios trace back to spec groups:

```
Spec Group    →    Gherkin Scenario         →    Test File
QT-1              Create task quickly            e2e/quick-task.spec.ts
QT-1              Empty input ignored            unit/inline-task-form.test.ts
QT-2              Private by default             e2e/quick-task.spec.ts
```

Feedback can reference: "QT-2 scenario 'Private by default' failed"
