Feature: Todo list management

Goal: Allow users to create, organize, and track personal tasks

Scope
In: create task, edit task, delete task, mark complete/incomplete, list tasks
Out: shared lists, recurring tasks, subtasks, due date reminders, tags/labels

Dependencies
- Requires: user authentication
- Triggers: none
- Blocked by: none

## TM-1: Task Creation

- WHEN user submits task with valid title THE SYSTEM SHALL save task as incomplete and display in list
- IF user submits empty title THEN THE SYSTEM SHALL display "Title is required"
- IF user submits title exceeding 500 characters THEN THE SYSTEM SHALL display "Title too long"

**Examples:**
| Input | Result |
|-------|--------|
| "Buy milk" | Task "Buy milk", incomplete |
| "Call dentist at 3pm" | Task "Call dentist at 3pm", incomplete |
| "" | Error: "Title is required" |

## TM-2: Task Completion

- WHEN user marks incomplete task as complete THE SYSTEM SHALL update status and show completion indicator
- WHEN user marks complete task as incomplete THE SYSTEM SHALL update status and remove completion indicator

**Examples:**
| Before | Action | After |
|--------|--------|-------|
| "Buy milk" (incomplete) | mark complete | "Buy milk" (complete, ✓) |
| "Buy milk" (complete) | mark incomplete | "Buy milk" (incomplete) |

## TM-3: Task Editing

- WHEN user edits task title THE SYSTEM SHALL save changes and display updated title

**Examples:**
| Before | Edit | After |
|--------|------|-------|
| "Buy milk" | "Buy oat milk" | "Buy oat milk" |

## TM-4: Task Deletion

- WHEN user deletes task THE SYSTEM SHALL remove task from list permanently

## TM-5: Task List

- WHEN user opens task list THE SYSTEM SHALL display all tasks belonging to that user

THE SYSTEM SHALL only show tasks belonging to authenticated user (ubiquitous)

Permissions

Standard ownership (user can only access own tasks)

Input Validation

IV1: Title is required
IV2: Title maximum 500 characters

Data Model

T1: tasks
- id (globally unique ID)
- user_id (reference to user)
- title (text)
- completed (yes/no)
- created_at (date/time)
- updated_at (date/time)

Out of Scope

- Shared lists, task assignment
- Recurring tasks
- Subtasks / nested tasks
- Due date reminders
- Tags / labels / categories
