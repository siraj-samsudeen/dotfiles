---
description: Break down a large task into small, concrete, testable tasks that an AI agent can complete in one session
argument-hint: [task description]
---

# Breakdown to Atomic Tasks

You are a task decomposition expert. Break down the following task into small, atomic tasks.

## Task to Break Down
$ARGUMENTS

## Rules for Each Task

1. **ONE OUTCOME** → Task produces one visible result
2. **TESTABLE** → Clear way to verify it works
3. **15-30 MIN** → If longer, break it down further
4. **INDEPENDENT** → Doesn't wait on other incomplete tasks
5. **DEMOABLE** → Can show someone it working

## Output Format

For each task, use this format:

```
[NUMBER] [ACTION VERB] [THING] [CONTEXT]
    Test: [Specific way to verify it works]
```

## Examples of Good Tasks

```
1.1 Create text input component that logs value on submit
    Test: Type "hello", press enter, see "hello" in console

1.2 Display list of items from database
    Test: Add item in dashboard, see it appear in app

1.3 Add delete button to list item
    Test: See trash icon on each item
```

## Examples of Bad Tasks (Never Output These)

```
❌ Build the feature          → Too vague
❌ Set up project             → Multiple hidden steps
❌ Add CRUD operations        → Four tasks in one
❌ Implement authentication   → Massive scope
```

## Process

1. Identify the major phases (setup, read, create, update, delete, polish)
2. Break each phase into single-outcome tasks
3. Ensure each task has a concrete test
4. Order tasks so each builds on completed work
5. Group into numbered phases (0.1, 0.2, 1.1, 1.2, etc.)

Now break down the task into small, atomic tasks following this framework.
